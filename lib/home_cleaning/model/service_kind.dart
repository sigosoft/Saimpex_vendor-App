import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// The service section serves three vendor types on the same `service*`
/// endpoints (task V14): home cleaning (9), laundry (7) and car wash (8).
/// Statuses, tabs, counters, action labels and reject reasons differ; the
/// backend's flow is in VendorScreenData (nextStep / labelsFor).
enum ServiceKind { homeCleaning, laundry, carWash }

class ServiceKinds {
  const ServiceKinds._();

  /// The signed-in vendor's kind; set by [load] before the section opens.
  static ServiceKind current = ServiceKind.homeCleaning;

  static ServiceKind fromVendorType(String? vendorType) => switch (vendorType?.trim()) {
        '7' => ServiceKind.laundry,
        '8' => ServiceKind.carWash,
        _ => ServiceKind.homeCleaning,
      };

  static Future<ServiceKind> load() async {
    current = fromVendorType((await getSavedObject('vendorType'))?.toString());
    return current;
  }

  static bool get isCleaning => current == ServiceKind.homeCleaning;
  static bool get isLaundry => current == ServiceKind.laundry;
  static bool get isCarWash => current == ServiceKind.carWash;

  /// Section name for titles.
  static String title(BuildContext context) => switch (current) {
        ServiceKind.laundry => S.of(context).serviceKindLaundry,
        ServiceKind.carWash => S.of(context).serviceKindCarWash,
        ServiceKind.homeCleaning => S.of(context).serviceKindHomeCleaning,
      };

  // ── Bookings tabs ──────────────────────────────────────────────────────

  /// Server statuses under each filter chip, in order.
  static List<List<int>> get tabStatuses => isCleaning
      ? const [[1], [2, 8], [3], [9], [10]]
      : const [[1], [2], [3], [4], [9], [10]];

  static List<String> tabLabels(BuildContext context) {
    final s = S.of(context);
    return switch (current) {
      ServiceKind.homeCleaning => [s.cleaningNewBookings, s.accepted, s.cleaningInProgress, s.cleaningCompleted, s.cancelled],
      ServiceKind.laundry => [s.cleaningNewBookings, s.laundryWaitingForPickup, s.cleaningInProgress, s.laundryReadyForDelivery, s.laundryDelivered, s.cancelled],
      ServiceKind.carWash => [s.cleaningNewBookings, s.carWashWaitingForVehicle, s.cleaningInProgress, s.carWashReadyForPickup, s.cleaningCompleted, s.cancelled],
    };
  }

  /// Second home counter: "Upcoming" (cleaning), "Waiting for Pickup"
  /// (laundry), "Waiting for Vehicle" (car wash).
  static String secondCounterLabel(BuildContext context) => switch (current) {
        ServiceKind.laundry => S.of(context).laundryWaitingForPickup,
        ServiceKind.carWash => S.of(context).carWashWaitingForVehicle,
        ServiceKind.homeCleaning => S.of(context).cleaningUpcoming,
      };

  // ── Status pill and next action ───────────────────────────────────────

  static ({String label, Color color}) statusPill(BuildContext context, int status) {
    final s = S.of(context);
    const green = Color(0xFF009624);
    const blue = Color(0xFF1E6BE6);
    const red = Color(0xFFBA1B1B);
    const orange = Color(0xFFFF9800);
    if (status == 10) return (label: s.cleaningBookingStatusCancelled, color: red);
    if (status == 1) return (label: s.cleaningStatusNew, color: orange);
    if (status == 3) return (label: s.cleaningStatusInProgress, color: blue);
    switch (current) {
      case ServiceKind.homeCleaning:
        if (status == 9) return (label: s.completed, color: green);
        if (status == 8) return (label: s.cleaningBookingStatusOnTheWay, color: green);
        return (label: s.cleaningStatusAccepted, color: green);
      case ServiceKind.laundry:
        if (status == 9) return (label: s.laundryDelivered, color: green);
        if (status == 4) return (label: s.laundryReadyForDelivery, color: green);
        return (label: s.laundryWaitingForPickup, color: orange);
      case ServiceKind.carWash:
        if (status == 9) return (label: s.completed, color: green);
        if (status == 4) return (label: s.carWashReadyForPickup, color: green);
        return (label: s.carWashWaitingForVehicle, color: orange);
    }
  }

  /// Label of the main button for a booking in [status] (not new, not
  /// done), matching the server's next step.
  static String actionLabel(BuildContext context, int status, {bool needsCleaner = false}) {
    final s = S.of(context);
    if (isCleaning && needsCleaner) return s.assignCleaner;
    switch (current) {
      case ServiceKind.homeCleaning:
        // Backend flow (VendorScreenData): 2 → On the Way, 8 → Start Cleaning,
        // 3 → Completed. Assign Cleaner comes first when the booking needs one.
        return switch (status) {
          3 => s.cleaningMarkAsCompleted,
          8 => s.cleaningStartCleaning,
          _ => s.cleaningMarkOnTheWay,
        };
      case ServiceKind.laundry:
        return switch (status) {
          2 => s.laundryConfirmPickup,
          3 => s.laundryMarkReadyForDelivery,
          _ => s.laundryMarkAsDelivered,
        };
      case ServiceKind.carWash:
        return switch (status) {
          2 => s.carWashMarkVehiclesReceived,
          3 => s.carWashMarkReadyForPickup,
          _ => s.cleaningMarkAsCompleted,
        };
    }
  }

  // ── Reject reasons ────────────────────────────────────────────────────

  /// `(value sent as reason, label shown)`; the last one is "Other" (free
  /// text in `note`). Same English values as the backend's ServiceOptions;
  /// laundry uses the car wash list there too.
  static List<(String, String)> rejectReasons(BuildContext context) {
    final s = S.of(context);
    if (isCleaning) {
      return [
        ('No cleaner available', s.cleaningRejectReasonNoCleaner),
        ('Outside our service area', s.cleaningRejectReasonOutsideArea),
        ('Service temporarily unavailable', s.cleaningRejectReasonServiceUnavailable),
        ('Other', s.cleaningRejectReasonOther),
      ];
    }
    return [
      ('Slot is fully booked', s.rejectReasonSlotFull),
      ('Unable to accept at the selected time', s.rejectReasonTimeUnavailable),
      ('Temporary operational issue', s.rejectReasonOperationalIssue),
      ('Other', s.cleaningRejectReasonOther),
    ];
  }
}
