import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/home_cleaning/controller/cleaning_api.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';

/// Home cleaning shell state (bottom nav) plus the home/bookings data:
/// GET serviceDashboard, GET home (membership only), GET serviceBookings,
/// POST serviceAvailability, POST updateServiceBookingStatus.
class HomeCleaningController extends GetxController {
  static const int pageSize = 20;

  // ── Shell ──────────────────────────────────────────────────────────────
  int navIndex = 0;
  int filterIndex = 0;

  void selectNav(int index) {
    if (index == navIndex) return;
    navIndex = index;
    update();
  }

  void setNavIndex(int index) {
    navIndex = index;
    update();
  }

  // ── Header / dashboard ────────────────────────────────────────────────
  CleaningDashboard? dashboard;
  bool dashboardLoading = false;
  String? dashboardError;
  CleaningMembership? membership;

  bool acceptingBookings = true;
  bool? storeOpen;
  bool togglingAvailability = false;

  // ── Bookings list ─────────────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  List<CleaningBooking> bookings = [];
  bool bookingsLoading = false;
  bool loadingMore = false;
  String? bookingsError;
  bool hasMore = false;
  int _page = 1;
  int _seq = 0;
  Timer? _debounce;
  String _lastKeyword = '';

  /// Bookings with a status change in flight (buttons disabled).
  final Set<int> busyIds = {};

  CleaningBookingTab get tab => CleaningBookingTab.values[filterIndex];

  /// Count for a filter chip from the dashboard `status_mix`; null until loaded.
  int? countFor(CleaningBookingTab t) => dashboard?.countFor(t);

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    refreshAll();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> refreshAll() async {
    await Future.wait([loadDashboard(), loadMembership(), loadBookings()]);
  }

  Future<void> loadDashboard() async {
    dashboardLoading = true;
    dashboardError = null;
    update();
    final res = await CleaningApi.get(ApiEndPoints.serviceDashboard);
    if (res.ok) {
      dashboard = CleaningDashboard.fromJson(res.map);
      acceptingBookings = dashboard!.acceptingBookings ?? acceptingBookings;
      storeOpen = dashboard!.isOpen;
    } else {
      dashboardError = res.message ?? '';
    }
    dashboardLoading = false;
    update();
  }

  /// The membership card has no service-vertical source; GET home returns it
  /// (`membership` is null when the vendor has no subscription). `limit` is
  /// required by that endpoint, 1 keeps the order payload small.
  Future<void> loadMembership() async {
    final res = await CleaningApi.get(ApiEndPoints.home, query: {'limit': 1});
    membership = res.ok ? CleaningMembership.fromJson(res.map['membership']) : null;
    update();
  }

  void selectFilter(int index) {
    if (index == filterIndex) return;
    filterIndex = index;
    bookings = [];
    update();
    loadBookings();
  }

  void _onSearchChanged() {
    final keyword = searchController.text.trim();
    if (keyword == _lastKeyword) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _lastKeyword = keyword;
      loadBookings();
    });
  }

  /// `GET serviceBookings?status=S&limit=20&page=N[&keyword=K]`
  /// The ACCEPTED chip covers two statuses (2 accepted, 8 on the way); the
  /// endpoint filters by one status, so both are fetched and merged.
  Future<void> loadBookings({bool more = false}) async {
    if (more && (loadingMore || bookingsLoading || !hasMore)) return;
    final seq = ++_seq;
    final page = more ? _page + 1 : 1;
    if (more) {
      loadingMore = true;
    } else {
      bookingsLoading = true;
      bookingsError = null;
    }
    update();

    final keyword = searchController.text.trim();
    final results = await Future.wait(tab.statuses.map((status) {
      final query = <String, dynamic>{
        'status': status,
        'limit': pageSize,
        'page': page,
      };
      if (keyword.isNotEmpty) query['keyword'] = keyword;
      return CleaningApi.get(ApiEndPoints.serviceBookings, query: query);
    }));
    if (seq != _seq) return; // a newer request superseded this one

    final failed = results.where((r) => !r.ok).toList();
    if (failed.isNotEmpty) {
      if (more) {
        loadingMore = false;
      } else {
        bookingsLoading = false;
        bookingsError = failed.first.message ?? '';
      }
      update();
      return;
    }

    final fresh = <CleaningBooking>[];
    var anyMore = false;
    for (final r in results) {
      final paginator = r.map['bookings'];
      List rows = const [];
      if (paginator is Map) {
        rows = paginator['data'] is List ? paginator['data'] as List : const [];
        final current = int.tryParse('${paginator['current_page']}') ?? page;
        final last = int.tryParse('${paginator['last_page']}') ?? current;
        if (current < last) anyMore = true;
      } else if (paginator is List) {
        rows = paginator;
      }
      fresh.addAll(rows
          .whereType<Map>()
          .map((e) => CleaningBooking.fromJson(Map<String, dynamic>.from(e))));
    }

    final merged = <int, CleaningBooking>{
      if (more) for (final b in bookings) b.id: b,
      for (final b in fresh) b.id: b,
    };
    bookings = merged.values.toList()..sort((a, b) => b.id.compareTo(a.id));
    _page = page;
    hasMore = anyMore;
    bookingsLoading = false;
    loadingMore = false;
    update();
  }

  /// POST serviceAvailability {accepting_bookings: 1|2}. Returns an error
  /// message (server text when available) or null on success.
  Future<String?> toggleAccepting(bool value) async {
    if (togglingAvailability) return null;
    final previous = acceptingBookings;
    acceptingBookings = value;
    togglingAvailability = true;
    update();
    final res = await CleaningApi.post(
      ApiEndPoints.serviceAvailability,
      {'accepting_bookings': value ? 1 : 2},
    );
    togglingAvailability = false;
    if (res.ok) {
      final accepting = res.map['accepting_bookings'];
      if (accepting != null) {
        acceptingBookings = accepting.toString() == '1';
      }
      update();
      return null;
    }
    acceptingBookings = previous;
    update();
    return res.message ?? '';
  }

  /// POST updateServiceBookingStatus. Refreshes the list and counters on
  /// success.
  Future<CleaningApiResult> updateBookingStatus(
    CleaningBooking booking,
    int status, {
    String? reason,
    String? note,
  }) async {
    busyIds.add(booking.id);
    update();
    final res = await CleaningBookingActions.updateStatus(
      booking.id,
      status,
      reason: reason,
      note: note,
    );
    busyIds.remove(booking.id);
    update();
    if (res.ok) {
      unawaited(loadBookings());
      unawaited(loadDashboard());
    }
    return res;
  }
}

class CleaningBookingActions {
  const CleaningBookingActions._();

  /// Allowed transitions for home cleaning (server enforces them):
  /// 1 -> 2 | 10, 2 -> 8 | 3 | 10, 8 -> 3 | 10, 3 -> 9 | 10.
  /// `reason` is required for 10 (max 255), `note` optional (max 100).
  static Future<CleaningApiResult> updateStatus(
    int orderId,
    int status, {
    String? reason,
    String? note,
  }) {
    final body = <String, dynamic>{'order_id': orderId, 'status': status};
    if (reason != null && reason.trim().isNotEmpty) body['reason'] = reason.trim();
    if (note != null && note.trim().isNotEmpty) body['note'] = note.trim();
    return CleaningApi.post(ApiEndPoints.updateServiceBookingStatus, body);
  }
}
