import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/cleaning_api.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';
import 'package:saimpex_vendor/home_cleaning/model/service_kind.dart';
import 'package:saimpex_vendor/home_cleaning/view/service_kind_blocks.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaners/assign_cleaner_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaners/cleaner_widgets.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaner.dart';
import 'package:saimpex_vendor/home_cleaning/view/chat/home_cleaning_conversation_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaning_booking_action.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaning_booking_format.dart';

/// Booking details: opens with the list row, then loads
/// `GET serviceBookingDetail?order_id=ID` and acts through
/// POST updateServiceBookingStatus.
class BookingDetailsView extends StatefulWidget {
  const BookingDetailsView({super.key, required this.booking});

  /// Row from the bookings list (shown until the detail call returns).
  final CleaningBooking booking;

  static const _orange = Color(0xFFFF5216);
  static const _ink = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF9E9E9E);

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  final _serviceKey = GlobalKey();
  double _fadeEnd = 360;

  late CleaningBooking _booking;
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureFade());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await CleaningApi.get(
      ApiEndPoints.serviceBookingDetail,
      query: {'order_id': _booking.id},
    );
    if (!mounted) return;
    final raw = res.map['booking'];
    setState(() {
      _loading = false;
      if (res.ok && raw is Map) {
        _booking = CleaningBooking.fromJson(Map<String, dynamic>.from(raw));
        _loaded = true;
      } else {
        _error = res.message ?? '';
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureFade());
  }

  Future<void> _act({required bool reject}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final updated = await runCleaningBookingAction(context, _booking, reject: reject);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (updated != null) _booking = updated;
    });
    if (updated != null) _load();
  }

  void _measureFade() {
    final box = _serviceKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !mounted) return;
    final mid = box.localToGlobal(Offset.zero).dy + box.size.height / 2;
    if ((mid - _fadeEnd).abs() > 1) {
      setState(() => _fadeEnd = mid);
    }
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: appFont('Inter', 
        color: const Color(0xFF9AA3B2),
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _noteBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.sticky_note_2_outlined,
            color: Color(0xFFFF5216),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: appFont('Inter', 
                color: const Color(0xFF7A4E32),
                fontWeight: FontWeight.w500,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: BookingDetailsView._orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: BookingDetailsView._orange.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: appFont('Inter', 
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  List<Widget> _content(BuildContext context) {
    final b = _booking;
    final notes = b.notes?.trim();
    final cancelText = [b.rejectReason, b.rejectNote]
        .whereType<String>()
        .where((e) => e.trim().isNotEmpty)
        .join('\n');
    return [
      if (_error != null && !_loaded) ...[
        _LoadErrorBanner(message: _error!, onRetry: _load),
        const SizedBox(height: 12),
      ],
      _CustomerCard(booking: b),
      const SizedBox(height: 12),
      _ServiceCard(key: _serviceKey, booking: b),
      // Laundry / car wash parts (V14).
      if (ServiceKinds.isLaundry) ...[
        const SizedBox(height: 12),
        LaundryBookingBlock(booking: b),
      ],
      if (ServiceKinds.isCarWash) CarWashBookingBlock(booking: b),
      // Home cleaning: the assigned cleaner with Change (V16, Figma 10868:12059).
      if (ServiceKinds.isCleaning && b.cleaner != null) ...[
        const SizedBox(height: 12),
        _AssignedCleanerCard(
          cleaner: b.cleaner!,
          canChange: !b.isCompleted && !b.isCancelled && !b.isInProgress,
          onChange: () async {
            final changed = await AssignCleanerView.open(context, b);
            if (changed == true) _load();
          },
        ),
      ],
      if (ServiceKinds.isCleaning && b.spaceLines.isNotEmpty) ...[
        const SizedBox(height: 16),
        _sectionLabel(S.of(context).cleaningSpacesHeader),
        const SizedBox(height: 8),
        _LinesCard(lines: b.spaceLines),
      ],
      if (ServiceKinds.isCleaning && b.addonLines.isNotEmpty) ...[
        const SizedBox(height: 16),
        _sectionLabel(S.of(context).cleaningMakeItExtraCleanHeader),
        const SizedBox(height: 8),
        _LinesCard(lines: b.addonLines),
      ],
      if (b.supplyLine != null) ...[
        const SizedBox(height: 16),
        _ProductsCard(fee: b.supplyLine!.lineTotal, isCompleted: b.isCompleted),
      ],
      // The customer brings the products (`product_supply`, §6.40).
      if (ServiceKinds.isCleaning && b.supplyLine == null && b.raw['product_supply'] == 'customer') ...[
        const SizedBox(height: 16),
        _noteBox(S.of(context).cleaningCustomerProvidesProductsDesc),
      ],
      if (notes != null && notes.isNotEmpty) ...[
        const SizedBox(height: 16),
        _sectionLabel(S.of(context).cleaningSpecialNotesHeader),
        const SizedBox(height: 8),
        _noteBox(notes),
      ],
      if (b.isCancelled && cancelText.isNotEmpty) ...[
        const SizedBox(height: 16),
        _sectionLabel(S.of(context).cleaningBookingCancelReasonHeader),
        const SizedBox(height: 8),
        _noteBox(cancelText),
      ],
      if (b.address != null) ...[
        const SizedBox(height: 12),
        _LocationCard(
          label: b.raw['address_label']?.toString(),
          address: b.address!,
          latitude: b.latitude,
          longitude: b.longitude,
        ),
      ],
      const SizedBox(height: 16),
      _sectionLabel(S.of(context).paymentSummary),
      const SizedBox(height: 8),
      _PaymentCard(booking: b),
      if (b.isCompleted || b.isCancelled)
        const SizedBox.shrink()
      else ...[
        const SizedBox(height: 16),
        if (b.isInProgress || b.isAccepted || b.isReady)
          _primaryButton(
            ServiceKinds.actionLabel(context, b.status, needsCleaner: b.needsCleaner),
            () => _act(reject: false),
          )
        else
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _act(reject: true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BookingDetailsView._ink,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFE0E0E0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      S.of(context).reject,
                      style: appFont('Inter', 
                        color: const Color(0xFF424242),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _primaryButton(
                  S.of(context).cleaningAcceptBooking,
                  () => _act(reject: false),
                ),
              ),
            ],
          ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _fadeEnd,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFE8DC),
                      Color(0xFFFFF3EC),
                      Color(0xFFFFFFFF),
                    ],
                    stops: [0, 0.5, 1],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top + 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          S.of(context).cleaningBookingDetails,
                          style: appFont('Inter', 
                            color: BookingDetailsView._ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: InkWell(
                            onTap: () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFE0D0),
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: BookingDetailsView._orange,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        if (_loading)
                          const Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: BookingDetailsView._orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: BookingDetailsView._orange,
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      children: _content(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadErrorBanner extends StatelessWidget {
  const _LoadErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final text = message.trim().isEmpty ? S.of(context).cleaningBookingLoadFailed : message;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE0D0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: appFont('Inter', 
                color: const Color(0xFF757575),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              S.of(context).tryAgain,
              style: appFont('Inter', 
                color: BookingDetailsView._orange,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.booking});

  final CleaningBooking booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final phone = b.customerPhone;
    final created = b.createdAt;
    final ({String label, Color color}) pill = !ServiceKinds.isCleaning
        ? ServiceKinds.statusPill(context, b.status)
        : b.isInProgress
        ? (label: S.of(context).cleaningStatusInProgress, color: const Color(0xFF1E6BE6))
        : b.isCompleted
        ? (label: S.of(context).completed, color: const Color(0xFF009624))
        : b.isOnTheWay
        ? (label: S.of(context).cleaningBookingStatusOnTheWay, color: const Color(0xFF009624))
        : b.isAccepted
        ? (label: S.of(context).cleaningStatusAccepted, color: const Color(0xFF009624))
        : b.isCancelled
        ? (label: S.of(context).cleaningBookingStatusCancelled, color: const Color(0xFFBA1B1B))
        : (label: S.of(context).cleaningStatusNew, color: const Color(0xFFFF9800));
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'lib/home_cleaning/Assets/images/account.png',
                width: 16,
                height: 16,
                color: BookingDetailsView._orange,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 6),
              Text(
                S.of(context).cleaningCustomerHeader,
                style: appFont('Inter', 
                  color: BookingDetailsView._orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pill.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  pill.label,
                  style: appFont('Inter', 
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFFDECEC),
                  child: Text(
                    b.initial,
                    style: appFont('Inter', 
                      color: BookingDetailsView._orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appFont('Inter', 
                          color: BookingDetailsView._ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (phone != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          phone,
                          textDirection: TextDirection.ltr,
                          style: appFont('Inter', 
                            color: BookingDetailsView._muted,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => HomeCleaningConversationView(
                          customerName: b.displayName,
                          orderId: b.displayCode,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: BookingDetailsView._orange,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'lib/home_cleaning/Assets/images/chat.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).cleaningRequestIdHeader,
                  style: appFont('Inter', 
                    color: BookingDetailsView._muted,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: b.displayCode,
                        style: appFont('Inter', 
                          color: BookingDetailsView._orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (created != null)
                        TextSpan(
                          text: ' • ${CleaningBookingFormat.dateTime(created)}',
                          style: appFont('Inter', 
                            color: BookingDetailsView._muted,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({super.key, required this.booking});

  final CleaningBooking booking;

  @override
  Widget build(BuildContext context) {
    final name = booking.serviceName;
    final slot = CleaningBookingFormat.slot(booking);
    return _WhiteCard(
      child: Row(
        children: [
          // Service image (`service_image`, §6.40), or a neutral tile.
          Container(
            width: 64,
            height: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: (booking.raw['service_image']?.toString() ?? '').startsWith('http')
                ? Image.network(
                    booking.raw['service_image'].toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.cleaning_services_outlined, color: BookingDetailsView._orange, size: 30),
                  )
                : const Icon(
                    Icons.cleaning_services_outlined,
                    color: BookingDetailsView._orange,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name != null)
                  Text(
                    name,
                    style: appFont('Inter', 
                      color: BookingDetailsView._ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                if (slot != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF42A5F5),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          slot,
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: appFont('Inter', 
                            color: const Color(0xFF616161),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinesCard extends StatelessWidget {
  const _LinesCard({required this.lines});

  final List<CleaningBookingLine> lines;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _SpaceTile(
              title: lines[i].name,
              detail: '${CleaningBookingFormat.money(lines[i].price)} x ${lines[i].quantity}',
              total: CleaningBookingFormat.money(lines[i].lineTotal),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown only when the booking has a `supply` line (customer chose vendor
/// products and the service has a supply fee).
class _ProductsCard extends StatelessWidget {
  const _ProductsCard({required this.fee, this.isCompleted = false});

  final double fee;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isCompleted
                  ? S.of(context).cleaningCleaningProducts
                  : S.of(context).cleaningCleaningProductsHeader,
              style: appFont('Inter', 
                color: isCompleted
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF9AA3B2),
                fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w600,
                fontSize: isCompleted ? 14 : 12,
                letterSpacing: isCompleted ? 0.2 : 0.6,
              ),
            ),
            const Spacer(),
            Text(
              '+${CleaningBookingFormat.money(fee)}',
              style: appFont('Inter', 
                color: const Color(0xFFFF5216),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6F2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).cleaningProviderWillProvideProducts,
                style: appFont('Inter', 
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                S.of(context).cleaningProductsProvidedByProvider,
                style: appFont('Inter', 
                  color: const Color(0xFF5C534E),
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.address, this.label, this.latitude, this.longitude});

  /// Saved address title, e.g. "Sahara View Home" (`address_label`, §6.40).
  final String? label;

  final String address;
  final double? latitude;
  final double? longitude;

  @override
  Widget build(BuildContext context) {
    final hasMap = latitude != null &&
        longitude != null &&
        !(latitude == 0 && longitude == 0);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E0EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasMap)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: _BookingMap(target: LatLng(latitude!, longitude!)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 3.5,
                  height: 38,
                  decoration: BoxDecoration(
                    color: BookingDetailsView._orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((label ?? '').trim().isNotEmpty && label != 'null')
                        Text(
                          label!.trim(),
                          style: appFont('Inter', color: const Color(0xFF1D1B20), fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      Text(
                        address,
                        style: (label ?? '').trim().isNotEmpty && label != 'null'
                            ? appFont('Inter', color: const Color(0xFF6B7280), fontWeight: FontWeight.w500, fontSize: 13)
                            : appFont('Inter', color: const Color(0xFF1D1B20), fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingMap extends StatelessWidget {
  const _BookingMap({required this.target});

  final LatLng target;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: target, zoom: 15.2),
        markers: {
          Marker(markerId: const MarkerId('booking'), position: target),
        },
        zoomControlsEnabled: false,
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        liteModeEnabled: true,
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.booking});

  final CleaningBooking booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final type = CleaningBookingFormat.paymentType(context, b.paymentType);
    final paidOn = b.paidOn;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).paymentDetails,
            style: appFont('Inter', 
              color: const Color(0xFFFF5216),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          _PayRow(S.of(context).cleaningTotal, CleaningBookingFormat.money(b.total)),
          if (type != null) ...[
            const SizedBox(height: 12),
            _PayRow(
              S.of(context).paymentType,
              type,
              valueColor: const Color(0xFFFF5216),
            ),
          ],
          if (paidOn != null) ...[
            const SizedBox(height: 12),
            _PayRow(S.of(context).paymentOn, CleaningBookingFormat.dateTime(paidOn)),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 1, color: Color(0xFF3A3A3A)),
          ),
          _PayRow(
            S.of(context).cleaningTotalPaid,
            CleaningBookingFormat.money(b.totalPaid),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _SpaceTile extends StatelessWidget {
  const _SpaceTile({
    required this.title,
    required this.detail,
    required this.total,
  });

  final String title;
  final String detail;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: appFont('Inter', 
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: appFont('Inter', 
                    color: const Color(0xFF8A8A8A),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            total,
            style: appFont('Inter', 
              color: const Color(0xFFFF5216),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow(
    this.label,
    this.value, {
    this.valueColor = Colors.white,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final labelStyle = appFont('Inter', 
      color: emphasize ? Colors.white : const Color(0xFFE4E4E4),
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
      fontSize: emphasize ? 15 : 13.5,
    );
    final valueStyle = appFont('Inter', 
      color: valueColor,
      fontWeight: emphasize || valueColor != Colors.white
          ? FontWeight.w700
          : FontWeight.w600,
      fontSize: emphasize ? 16 : 13.5,
    );
    return Row(
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, textAlign: TextAlign.end, style: valueStyle),
        ),
      ],
    );
  }
}

/// "Assigned cleaner" card with Change (V16).
class _AssignedCleanerCard extends StatelessWidget {
  const _AssignedCleanerCard({required this.cleaner, required this.canChange, required this.onChange});

  final Cleaner cleaner;
  final bool canChange;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cleanerBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.assignedCleaner, style: cleanerText(12, FontWeight.w500, cleanerMuted)),
        const SizedBox(height: 8),
        Row(children: [
          CleanerAvatar(cleaner: cleaner),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cleaner.name, style: cleanerText(15, FontWeight.w600, cleanerInk)),
              Text(
                [if (cleaner.rating != null) '${cleaner.rating!.toStringAsFixed(1)} ★', if ((cleaner.phone ?? '').isNotEmpty) cleaner.phone!].join(' • '),
                style: cleanerText(12, FontWeight.w400, cleanerMuted),
              ),
            ]),
          ),
          if (canChange)
            OutlinedButton(
              onPressed: onChange,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: cleanerOrange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(s.change, style: cleanerText(13, FontWeight.w600, cleanerOrange)),
            ),
        ]),
      ]),
    );
  }
}
