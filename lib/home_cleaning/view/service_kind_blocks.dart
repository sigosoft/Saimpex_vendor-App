import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaning_booking_format.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/bidi_text.dart';

// Laundry and car wash parts of Booking Details (task V14), Figma "Vendor
// Apps": laundry Waiting Order Detail Page (9714:87154), After checking
// weight (9714:87310), Verify Weight sheet (9714:86314); car wash Accepted
// detail page (9714:82626).

const Color _ink = Color(0xFF1A1A1A);
const Color _muted = Color(0xFF9AA3B2);
const Color _soft = Color(0xFF5F6B7A);
const Color _orange = Color(0xFFFF5216);
const Color _tint = Color(0xFFFFF4EC);
const Color _red = Color(0xFFE53935);

double? _num(dynamic v) => v == null ? null : double.tryParse(v.toString());

String _mru(num v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

String _kg(num v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

String? _str(dynamic v) {
  final t = v?.toString().trim();
  return t == null || t.isEmpty || t == 'null' ? null : t;
}

TextStyle _t(double size, FontWeight w, Color c) => appFont('Inter', fontSize: size, fontWeight: w, color: c);

Widget _card({required Widget child, Color color = Colors.white}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: child,
    );

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text.toUpperCase(), style: _t(12, FontWeight.w600, _muted).copyWith(letterSpacing: 0.6)),
    );

Widget _row(String l, String v, {Color color = _ink, bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(l, style: _t(13, FontWeight.w500, _soft))),
          Text(v, style: _t(bold ? 15 : 13, bold ? FontWeight.w700 : FontWeight.w600, color)),
        ],
      ),
    );

/// Laundry processing time as stored ("Express", "Standard (24h)") in the
/// app language; other values are shown as sent.
String laundryProcessingLabel(S s, String value) => switch (value.trim().toLowerCase()) {
      'express' => s.processingExpress,
      'standard' || 'standard (24h)' || 'standard delivery (ready in 24 hours)' => s.processingStandard24h,
      _ => value,
    };

// ── Laundry ─────────────────────────────────────────────────────────────

/// Turnaround tag of a laundry booking (Figma: "Standard (24h)" or a yellow
/// "Express"), from `turnaround` (stored value) or `processing_label`.
({String label, bool express})? laundryTurnaround(S s, CleaningBooking b) {
  final raw = _str(b.raw['turnaround']) ?? _str(b.raw['processing']) ?? _str(b.raw['processing_label']);
  if (raw == null) return null;
  return (label: laundryProcessingLabel(s, raw), express: raw.trim().toLowerCase() == 'express');
}

class LaundryTurnaroundTag extends StatelessWidget {
  const LaundryTurnaroundTag({super.key, required this.label, required this.express});

  final String label;
  final bool express;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: express ? const Color(0xFFFFC107) : _tint,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: _t(10.5, FontWeight.w700, express ? _ink : _orange)),
      );
}

/// Weight lines of a laundry booking: "Estimated 3 kg" with the estimate
/// price before the weight check, then "Customer estimate (3 kg)" and
/// "Actual weight (3.6 kg)" with their prices after it (Figma Home card,
/// service card). Nothing for a booking that is not priced per kg.
class LaundryWeightLines extends StatelessWidget {
  const LaundryWeightLines({super.key, required this.booking, this.showEstimatePrice = true});

  final CleaningBooking booking;

  /// The home card shows "Estimated 3 kg" alone (the price is on the detail).
  final bool showEstimatePrice;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final r = booking.raw;
    final estimate = _num(r['estimate_kg']);
    final actual = _num(r['actual_kg']);
    final rate = _num(r['rate_per_kg']);
    if (estimate == null) return const SizedBox.shrink();
    if (actual == null) {
      return _row(s.lnfEstimatedKg(_kg(estimate)),
          showEstimatePrice && rate != null ? '${_mru(estimate * rate)} MRU' : '', color: _orange, bold: true);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row(s.laundryCustomerEstimate(_kg(estimate)), rate != null ? '${_mru(estimate * rate)} MRU' : ''),
        _row(s.laundryActualWeight(_kg(actual)), rate != null ? '${_mru(actual * rate)} MRU' : '', color: _orange, bold: true),
      ],
    );
  }
}

/// Laundry service card of Booking Details (Figma New / Waiting Order
/// Detail): image, service name, turnaround tag, then the weight lines (or
/// the picked garments / summary for a service not priced per kg).
class LaundryServiceCard extends StatelessWidget {
  const LaundryServiceCard({super.key, required this.booking});

  final CleaningBooking booking;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final b = booking;
    final name = b.serviceName;
    final image = _str(b.raw['service_image']);
    final tag = laundryTurnaround(s, b);
    final perKg = _num(b.raw['estimate_kg']) != null;
    final garments = b.chipLines;
    final summary = _str(b.raw['summary']);
    Widget tile(Widget child) => Container(
          width: 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: _tint, borderRadius: BorderRadius.circular(12)),
          child: child,
        );
    const fallback = Icon(Icons.local_laundry_service_outlined, color: _orange, size: 28);
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              tile(image != null && image.startsWith('http')
                  ? Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback)
                  : fallback),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name ?? '—', style: _t(15, FontWeight.w700, _ink)),
              ),
              if (tag != null) ...[
                const SizedBox(width: 8),
                LaundryTurnaroundTag(label: tag.label, express: tag.express),
              ],
            ],
          ),
          if (perKg || garments.isNotEmpty || summary != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFF7F7F8), borderRadius: BorderRadius.circular(12)),
              child: perKg
                  ? LaundryWeightLines(booking: b)
                  : garments.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final g in garments)
                              _row(g.quantity > 1 ? '${g.name} × ${g.quantity}' : g.name,
                                  g.price > 0 ? '${_mru(g.lineTotal)} MRU' : ''),
                          ],
                        )
                      : Text(summary!, style: _t(13, FontWeight.w500, _soft)),
            ),
          ],
        ],
      ),
    );
  }
}

/// A date chip and a time chip (Figma laundry PICKUP SLOT / DELIVERY
/// TURNAROUND). [window] is the server's "25 Aug 2026, 2:00 PM – 4:00 PM";
/// when it doesn't parse it is shown whole.
class LaundrySlotChips extends StatelessWidget {
  const LaundrySlotChips({super.key, this.start, this.end, this.window});

  final DateTime? start;
  final DateTime? end;
  final String? window;

  static final RegExp _windowPattern = RegExp(r'^(\d{1,2} [A-Za-z]{3} \d{4}), (.+)$');

  Widget _chip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: const Color(0xFF42A5F5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: _t(12.5, FontWeight.w600, const Color(0xFF424242))),
          ),
        ]),
      );

  Widget _pair(String date, String time) => Row(children: [
        Expanded(flex: 4, child: _chip(Icons.calendar_today_outlined, date)),
        const SizedBox(width: 10),
        Expanded(flex: 5, child: _chip(Icons.access_time_rounded, time)),
      ]);

  static const _months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
  static final RegExp _dayPattern = RegExp(r'^(\d{1,2}) ([A-Za-z]{3}) (\d{4})$');
  static final RegExp _timePattern = RegExp(r'^(\d{1,2}):(\d{2}) ([AaPp][Mm])$');

  /// "25 Aug 2026" (the server's Carbon `d M Y`, always English).
  static DateTime? _parseDay(String text) {
    final m = _dayPattern.firstMatch(text.trim());
    final month = m == null ? -1 : _months.indexOf(m.group(2)!.toLowerCase());
    if (m == null || month < 0) return null;
    return DateTime(int.parse(m.group(3)!), month + 1, int.parse(m.group(1)!));
  }

  /// "2:00 PM" (Carbon `g:i A`) on [day].
  static DateTime? _parseTime(DateTime day, String text) {
    final m = _timePattern.firstMatch(text.trim());
    if (m == null) return null;
    final h = int.parse(m.group(1)!) % 12 + (m.group(3)!.toLowerCase() == 'pm' ? 12 : 0);
    return DateTime(day.year, day.month, day.day, h, int.parse(m.group(2)!));
  }

  @override
  Widget build(BuildContext context) {
    final from = start;
    if (from != null) {
      final to = end;
      return _pair(
        CleaningBookingFormat.date(from),
        to == null ? CleaningBookingFormat.time(from) : '${CleaningBookingFormat.time(from)} - ${CleaningBookingFormat.time(to)}',
      );
    }
    final text = window?.trim();
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    final m = _windowPattern.firstMatch(text);
    final day = m == null ? null : _parseDay(m.group(1)!);
    if (m == null || day == null) return _chip(Icons.calendar_today_outlined, text);
    // "2:00 PM – 4:00 PM" (same day) or "2:00 PM – 26 Aug 2026, 4:00 PM".
    final times = m.group(2)!.split('–').map((e) => e.trim()).toList();
    final a = _parseTime(day, times.first);
    final b = times.length > 1 ? _parseTime(day, times[1]) : null;
    final time = a == null
        ? m.group(2)!
        : times.length < 2
            ? CleaningBookingFormat.time(a)
            : b == null
                ? '${CleaningBookingFormat.time(a)} - ${times[1]}'
                : '${CleaningBookingFormat.time(a)} - ${CleaningBookingFormat.time(b)}';
    return _pair(CleaningBookingFormat.date(day), time);
  }
}

/// Laundry parts of Booking Details under the service card: PICKUP SLOT,
/// DELIVERY TURNAROUND, PICKUP & DELIVERY and, once the weight check asked
/// for more, the Payment Status block (Figma After checking weight).
class LaundryBookingBlock extends StatelessWidget {
  const LaundryBookingBlock({super.key, required this.booking});

  final CleaningBooking booking;

  /// The weight check added an amount: Payment Status replaces the dark
  /// PAYMENT DETAILS card (Figma After checking weight / Ready / Delivered).
  static bool showsPaymentStatus(CleaningBooking b) => (_num(b.raw['additional_payment']) ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final r = booking.raw;
    final pickupSlot = _str(r['pickup_slot']);
    final turnaround = _str(r['delivery_turnaround']);
    final pickupAddress = _str(r['pickup_address']);
    final deliveryAddress = _str(r['delivery_address']);
    final pending = r['additional_payment_pending'] == true;
    final extra = _num(r['additional_payment']) ?? _num(r['balance_due']) ?? 0;
    // See CleaningBooking.paidAmount / finalAmount (paid + extra double-counted
    // the top-up after pickup).
    final finalAmount = booking.finalAmount;
    final paid = booking.paidAmount ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (booking.scheduledFor != null || pickupSlot != null) ...[
          _label(s.laundryPickupSlot),
          LaundrySlotChips(start: booking.scheduledFor, end: booking.slotEnd, window: pickupSlot),
        ],
        if (turnaround != null) ...[
          _label(s.laundryDeliveryTurnaround),
          LaundrySlotChips(window: turnaround),
        ],
        if (pickupAddress != null || deliveryAddress != null) ...[
          _label(s.laundryPickupAndDelivery),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pickupAddress != null) _point(Icons.radio_button_checked, _orange, s.laundryPickup, pickupAddress),
                if (pickupAddress != null && deliveryAddress != null) const SizedBox(height: 12),
                if (deliveryAddress != null) _point(Icons.check_circle_outline, const Color(0xFF16A34A), s.laundryDelivery, deliveryAddress),
              ],
            ),
          ),
        ],
        if (extra > 0) ...[
          const SizedBox(height: 16),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(child: Text(s.laundryPaymentStatus, style: _t(13, FontWeight.w600, _ink))),
                  const SizedBox(width: 8),
                  // Figma: orange "Additional payment pending" until the
                  // customer pays, then a green "Paid".
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: pending ? _orange : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: pending
                        ? Text(s.laundryAdditionalPaymentPending, style: _t(10, FontWeight.w700, Colors.white))
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.check_circle, size: 12, color: Color(0xFF16A34A)),
                            const SizedBox(width: 4),
                            Text(s.lnfPaid, style: _t(10, FontWeight.w700, const Color(0xFF16A34A))),
                          ]),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _amountBox(s.laundryAlreadyPaid, paid),
                  const SizedBox(width: 8),
                  _amountBox(s.laundryFinalAmount, finalAmount),
                  const SizedBox(width: 8),
                  _amountBox(s.laundryBalanceDue, extra, highlight: true),
                ]),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _point(IconData icon, Color color, String title, String address) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: _t(11, FontWeight.w600, color)),
                const SizedBox(height: 2),
                Text(address, style: _t(13, FontWeight.w600, _ink)),
              ],
            ),
          ),
        ],
      );

  Widget _amountBox(String label, double amount, {bool highlight = false}) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: highlight ? _tint : const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(10),
            border: highlight ? Border.all(color: _orange) : null,
          ),
          child: Column(children: [
            Text(label, textAlign: TextAlign.center, style: _t(11, FontWeight.w500, _soft)),
            const SizedBox(height: 4),
            Text('${_mru(amount)} MRU', style: _t(13, FontWeight.w700, highlight ? _orange : _ink)),
          ]),
        ),
      );
}

// ── Car wash ────────────────────────────────────────────────────────────

class CarWashBookingBlock extends StatelessWidget {
  const CarWashBookingBlock({super.key, required this.booking});

  final CleaningBooking booking;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final vehicles = booking.raw['vehicles'] is List
        ? (booking.raw['vehicles'] as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList()
        : <Map<String, dynamic>>[];
    // Figma car wash detail: VEHICLES, one card per vehicle with its
    // add-ons. The service location is drawn by the details screen (it has
    // the map).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vehicles.isNotEmpty) ...[
          _label(s.carWashVehicles),
          for (var i = 0; i < vehicles.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _vehicle(s, vehicles[i]),
          ],
        ],
      ],
    );
  }

  Widget _vehicle(S s, Map<String, dynamic> v) {
    final addons = v['addons'] is List
        ? (v['addons'] as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList()
        : <Map<String, dynamic>>[];
    final plate = _str(v['plate']);
    final type = _str(v['type']);
    // `service` is the item's English name; the booking has it localized.
    final service = booking.serviceName ?? _str(v['service']);
    final price = _num(v['price']);
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Figma: vehicle picture with the type under it. The booking
              // has no vehicle image, so the tile keeps a car icon.
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 44,
                    decoration: BoxDecoration(color: _tint, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.directions_car_outlined, color: _orange),
                  ),
                  if (type != null && plate != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 64),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF5F6B7A), borderRadius: BorderRadius.circular(6)),
                      child: Text(type, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: _t(10, FontWeight.w600, Colors.white)),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plate ?? type ?? '—', textDirection: TextDirection.ltr, style: _t(14, FontWeight.w700, _ink)),
                    if (service != null) ...[
                      const SizedBox(height: 2),
                      Text(service, style: _t(12, FontWeight.w500, _soft)),
                    ],
                  ],
                ),
              ),
              if (price != null) Text('${_mru(price)} MRU', style: _t(14, FontWeight.w700, _orange)),
            ],
          ),
          if (addons.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(s.carWashAddOns.toUpperCase(), style: _t(11, FontWeight.w600, _muted).copyWith(letterSpacing: 0.6)),
            const SizedBox(height: 4),
            for (final a in addons)
              _row(_str(a['name']) ?? '', signedMru('+', _mru(_num(a['price']) ?? 0))),
          ],
        ],
      ),
    );
  }
}

// ── Verify weight (laundry, Confirm Pickup on a per-kg service) ─────────

/// What the vendor chose on the Verify Weight sheet.
class VerifyWeightResult {
  const VerifyWeightResult({required this.kg, required this.paymentRequest});

  final double kg;

  /// True: ask the customer for the difference (status stays). False:
  /// confirm the pickup with this weight.
  final bool paymentRequest;
}

Future<VerifyWeightResult?> showVerifyWeightSheet(BuildContext context, CleaningBooking booking) {
  return showModalBottomSheet<VerifyWeightResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _VerifyWeightSheet(booking: booking),
  );
}

class _VerifyWeightSheet extends StatefulWidget {
  const _VerifyWeightSheet({required this.booking});

  final CleaningBooking booking;

  @override
  State<_VerifyWeightSheet> createState() => _VerifyWeightSheetState();
}

class _VerifyWeightSheetState extends State<_VerifyWeightSheet> {
  late final _kgCtrl = TextEditingController(text: _initial());

  String _initial() {
    final a = _num(widget.booking.raw['actual_kg']);
    return a == null ? '' : _kg(a);
  }

  @override
  void dispose() {
    _kgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final r = widget.booking.raw;
    final estimate = _num(r['estimate_kg']) ?? 0;
    final rate = _num(r['rate_per_kg']) ?? 0;
    final actual = double.tryParse(_kgCtrl.text.replaceAll(',', '.'));
    final estimateAmount = estimate * rate;
    final actualAmount = (actual ?? 0) * rate;
    final difference = actualAmount - estimateAmount;
    final valid = actual != null && actual >= 0.1;
    // Already asked for this weight: the next step is to confirm the pickup.
    final requested = r['additional_payment_pending'] == true && _num(r['actual_kg']) == actual;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: Text(s.laundryVerifyWeight, style: _t(17, FontWeight.w700, _ink))),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ]),
            // Figma Verify Weight: the customer, booking code and service
            // above the estimate.
            Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFDECEC),
                child: Text(widget.booking.initial, style: _t(14, FontWeight.w700, _orange)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (widget.booking.displayName.isNotEmpty)
                    Text(widget.booking.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: _t(14, FontWeight.w700, _ink)),
                  Text(isolated(widget.booking.displayCode), style: _t(12, FontWeight.w500, _soft)),
                ]),
              ),
              if (widget.booking.serviceName != null)
                Container(
                  constraints: const BoxConstraints(maxWidth: 140),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(6)),
                  child: Text(widget.booking.serviceName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: _t(11, FontWeight.w600, const Color(0xFF1E6BE6))),
                ),
            ]),
            const SizedBox(height: 12),
            _card(
              color: const Color(0xFFF7F7F8),
              child: _row(s.laundryCustomerEstimate(_kg(estimate)), '${_mru(estimateAmount)} MRU', color: _orange, bold: true),
            ),
            const SizedBox(height: 14),
            Text(s.laundryActualWeightLabel, style: _t(13, FontWeight.w600, _soft)),
            const SizedBox(height: 6),
            TextField(
              controller: _kgCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                suffixText: s.unitKg,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            if (valid) ...[
              const SizedBox(height: 14),
              _card(
                color: const Color(0xFFF7F8FF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(child: Text(s.laundryPriceBreakdown, style: _t(13, FontWeight.w700, _ink))),
                      Text(s.laundryRatePerKg(_mru(rate)), style: _t(12, FontWeight.w600, _soft)),
                    ]),
                    const SizedBox(height: 6),
                    _row(s.laundryCustomerEstimate(_kg(estimate)), '${_mru(estimateAmount)} MRU'),
                    _row(s.laundryActualWeight(_kg(actual)), '${_mru(actualAmount)} MRU', bold: true),
                    if (difference.abs() >= 0.01)
                      _row(s.laundryInvoiceDifference, signedMru(difference > 0 ? '+' : '-', _mru(difference.abs())),
                          color: difference > 0 ? _orange : _red),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: !valid
                    ? null
                    : () => Navigator.of(context).pop(VerifyWeightResult(
                          kg: actual,
                          // More than the customer paid: ask for it first.
                          paymentRequest: difference > 0.009 && !requested,
                        )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  disabledBackgroundColor: _orange.withValues(alpha: 0.4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  valid && difference > 0.009 && !requested ? s.laundrySendPaymentRequest : s.laundryConfirmPickup,
                  style: _t(15, FontWeight.w700, Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
