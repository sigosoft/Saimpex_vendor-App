import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String?> showRejectBookingSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => const RejectBookingSheet(),
  );
}

class RejectBookingSheet extends StatefulWidget {
  const RejectBookingSheet({super.key});

  @override
  State<RejectBookingSheet> createState() => _RejectBookingSheetState();
}

class _RejectBookingSheetState extends State<RejectBookingSheet> {
  static const _red = Color(0xFFE53935);
  static const _orange = Color(0xFFFF5722);
  static const _border = Color(0xFFE0E0E0);
  static const _text = Color(0xFF424242);

  static const _reasons = [
    'No cleaner available',
    'Outside our service area',
    'Service temporarily unavailable',
    'Other',
  ];
  static const _otherIndex = 3;
  static const _otherMax = 100;

  int? _selected;
  final _otherController = TextEditingController();

  bool get _isOther => _selected == _otherIndex;

  bool get _canConfirm {
    if (_selected == null) return false;
    if (_isOther) return _otherController.text.trim().isNotEmpty;
    return true;
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_canConfirm) return;
    HapticFeedback.lightImpact();
    final reason = _isOther ? _otherController.text.trim() : _reasons[_selected!];
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 18, 20, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: _red, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reject Booking',
                  style: GoogleFonts.inter(
                    color: _red,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(Icons.close, size: 18, color: Color(0xFF757575)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Please select a reason. The customer will be\nnotified accordingly',
            style: GoogleFonts.inter(
              color: const Color(0xFF9E9E9E),
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _reasons.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _ReasonTile(
              label: _reasons[i],
              selected: _selected == i,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selected = i);
              },
            ),
          ],
          if (_isOther) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Other Reason',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF212121),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${_otherController.text.length} / $_otherMax',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _otherController,
              maxLength: _otherMax,
              minLines: 3,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              inputFormatters: [
                LengthLimitingTextInputFormatter(_otherMax),
              ],
              style: GoogleFonts.inter(
                color: const Color(0xFF212121),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _text,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _orange.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _canConfirm ? _confirm : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _orange,
                        disabledBackgroundColor: _orange.withValues(alpha: 0.45),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm Reject',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _orange = Color(0xFFFF5722);
  static const _border = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _orange : _border),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _orange : const Color(0xFFBDBDBD),
                  width: 1.6,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: _orange,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: const Color(0xFF424242),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
