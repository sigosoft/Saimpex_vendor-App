import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';
import 'package:saimpex_vendor/resources/fonts.dart';

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

// ── Laundry ─────────────────────────────────────────────────────────────

class LaundryBookingBlock extends StatelessWidget {
  const LaundryBookingBlock({super.key, required this.booking});

  final CleaningBooking booking;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final r = booking.raw;
    final speed = _str(r['processing_label']) ?? _str(r['turnaround']);
    final estimate = _num(r['estimate_kg']);
    final actual = _num(r['actual_kg']);
    final rate = _num(r['rate_per_kg']);
    final pickupSlot = _str(r['pickup_slot']);
    final turnaround = _str(r['delivery_turnaround']);
    final pickupAddress = _str(r['pickup_address']);
    final deliveryAddress = _str(r['delivery_address']);
    final pending = r['additional_payment_pending'] == true;
    final extra = _num(r['additional_payment']) ?? _num(r['balance_due']) ?? 0;
    final paid = _num(r['total_paid']) ?? 0;
    final summary = _str(r['summary']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (speed != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: _tint, borderRadius: BorderRadius.circular(20)),
                    child: Text(speed, style: _t(12, FontWeight.w600, _orange)),
                  ),
                ),
              if (estimate != null) ...[
                const SizedBox(height: 8),
                _row(s.laundryCustomerEstimate(_kg(estimate)),
                    rate != null ? '${_mru(estimate * rate)} MRU' : '', color: actual == null ? _orange : _ink),
                if (actual != null)
                  _row(s.laundryActualWeight(_kg(actual)), rate != null ? '${_mru(actual * rate)} MRU' : '',
                      color: _orange, bold: true),
              ] else if (summary != null) ...[
                const SizedBox(height: 8),
                Text(summary, style: _t(13, FontWeight.w500, _soft)),
              ],
            ],
          ),
        ),
        if (pickupSlot != null) ...[
          _label(s.laundryPickupSlot),
          _card(child: Row(children: [
            const Icon(Icons.event_outlined, size: 18, color: _orange),
            const SizedBox(width: 10),
            Expanded(child: Text(pickupSlot, style: _t(13, FontWeight.w600, _ink))),
          ])),
        ],
        if (turnaround != null) ...[
          _label(s.laundryDeliveryTurnaround),
          _card(child: Row(children: [
            const Icon(Icons.schedule_outlined, size: 18, color: _orange),
            const SizedBox(width: 10),
            Expanded(child: Text(turnaround, style: _t(13, FontWeight.w600, _ink))),
          ])),
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
        if (pending && extra > 0) ...[
          const SizedBox(height: 16),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Text(s.laundryPaymentStatus, style: _t(13, FontWeight.w600, _ink)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(6)),
                    child: Text(s.laundryAdditionalPaymentPending, style: _t(10, FontWeight.w700, Colors.white)),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _amountBox(s.laundryAlreadyPaid, paid),
                  const SizedBox(width: 8),
                  _amountBox(s.laundryFinalAmount, paid + extra),
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
    final place = _str(booking.raw['service_location']) ?? _str(booking.raw['place']) ?? _str(booking.raw['address_label']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vehicles.isNotEmpty) ...[
          _label(s.carWashVehicles),
          for (final v in vehicles) ...[
            _vehicle(s, v),
            const SizedBox(height: 10),
          ],
        ],
        if (place != null) ...[
          _label(s.carWashServiceLocation),
          _card(child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: _tint, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.local_car_wash_outlined, size: 18, color: _orange),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(place, style: _t(14, FontWeight.w600, _ink))),
          ])),
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
    final service = _str(v['service']);
    final price = _num(v['price']);
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: _tint, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.directions_car_outlined, color: _orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plate ?? type ?? '—', textDirection: TextDirection.ltr, style: _t(14, FontWeight.w700, _ink)),
                    if (plate != null && type != null) Text(type, style: _t(12, FontWeight.w500, _soft)),
                    if (service != null) Text(service, style: _t(12, FontWeight.w500, _soft)),
                  ],
                ),
              ),
              if (price != null) Text('${_mru(price)} MRU', style: _t(14, FontWeight.w700, _orange)),
            ],
          ),
          if (addons.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(s.carWashAddOns.toUpperCase(), style: _t(11, FontWeight.w600, _muted)),
            for (final a in addons)
              _row('• ${_str(a['name']) ?? ''}', '+${_mru(_num(a['price']) ?? 0)} MRU'),
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
                suffixText: 'kg',
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
                      _row(s.laundryInvoiceDifference, '${difference > 0 ? '+' : ''}${_mru(difference)} MRU',
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
