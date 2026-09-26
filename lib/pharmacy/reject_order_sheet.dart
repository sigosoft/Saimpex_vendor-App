import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

/// Pharmacy Reject Order bottom sheet. Returns selected reason, or null.
Future<String?> showPharmacyRejectOrderSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => const PharmacyRejectOrderSheet(),
  );
}

class PharmacyRejectOrderSheet extends StatefulWidget {
  const PharmacyRejectOrderSheet({super.key});

  @override
  State<PharmacyRejectOrderSheet> createState() =>
      _PharmacyRejectOrderSheetState();
}

class _PharmacyRejectOrderSheetState extends State<PharmacyRejectOrderSheet> {
  static const Color _titleRed = Color(0xFFE84B5E);
  static const Color _orange = Color(0xFFFF5C26);
  static const Color _border = Color(0xFFE0E0E0);
  static const Color _descGray = Color(0xFF6B6B6B);
  static const int _otherMaxLength = 100;
  static const int _otherIndex = 3;

  static const reasons = [
    'Out of Stock',
    'Temporary Store Closure',
    'Invalid or Unclear Prescription',
    'Other',
  ];

  int? selectedIndex;
  final otherController = TextEditingController();

  bool get isOtherSelected => selectedIndex == _otherIndex;

  bool get _canConfirm {
    if (selectedIndex == null) return false;
    if (isOtherSelected) return otherController.text.trim().isNotEmpty;
    return true;
  }

  @override
  void dispose() {
    otherController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_canConfirm) return;
    if (isOtherSelected) {
      Navigator.of(context).pop(otherController.text.trim());
      return;
    }
    Navigator.of(context).pop(reasons[selectedIndex!]);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 20, 20, 18 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: _titleRed,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Reject Order',
                      style: TextStyle(
                        color: _titleRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Please select a reason. The customer will be notified accordingly',
                style: TextStyle(
                  color: _descGray,
                  fontWeight: FontWeight.w400,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < reasons.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _ReasonTile(
                  label: reasons[i],
                  selected: selectedIndex == i,
                  onTap: () => setState(() => selectedIndex = i),
                ),
              ],
              if (isOtherSelected) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Other Reason',
                        style: TextStyle(
                          color: AppColors.textBody,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '${otherController.text.length} / $_otherMaxLength',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w400,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: otherController,
                  maxLength: _otherMaxLength,
                  maxLines: 4,
                  minLines: 3,
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_otherMaxLength),
                  ],
                  style: const TextStyle(
                    color: AppColors.homeValue,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF3F3F3),
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF333333),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: _border, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          softWrap: false,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _orange.withValues(alpha: 0.32),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _canConfirm ? _confirm : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            disabledBackgroundColor:
                                _orange.withValues(alpha: 0.45),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white70,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirm Reject',
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
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

  static const Color _border = Color(0xFFE0E0E0);
  static const Color _orange = Color(0xFFFF5C26);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? _orange.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _orange : _border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? _orange : const Color(0xFFBDBDBD),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 12,
                        height: 12,
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
                  style: TextStyle(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
