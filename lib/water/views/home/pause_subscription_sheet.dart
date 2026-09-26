import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

/// Shows the Pause Subscription bottom sheet. Returns the selected reason, or null.
Future<String?> showPauseSubscriptionSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => const PauseSubscriptionSheet(),
  );
}

class PauseSubscriptionSheet extends StatefulWidget {
  const PauseSubscriptionSheet({super.key});

  @override
  State<PauseSubscriptionSheet> createState() => _PauseSubscriptionSheetState();
}

class _PauseSubscriptionSheetState extends State<PauseSubscriptionSheet> {
  static const Color _orange = AppColors.primaryOrange;
  static const Color _border = AppColors.fieldBorder;
  static const int _otherMaxLength = 100;
  static const int _otherIndex = 4;

  static const reasons = [
    'Out of Stock',
    'Temporary Store Closure',
    'Water Supply Issue',
    'Customer Requested Pause',
    'Other',
  ];

  int? selectedIndex;
  final otherController = TextEditingController();

  bool get isOtherSelected => selectedIndex == _otherIndex;

  @override
  void dispose() {
    otherController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (selectedIndex == null) return;
    if (isOtherSelected) {
      final text = otherController.text.trim();
      if (text.isEmpty) return;
      Navigator.of(context).pop(text);
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
        padding: EdgeInsets.fromLTRB(20, 18, 20, 18 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.pause,
                    color: _orange,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Pause Subscription',
                      style: TextStyle(
                        color: _orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderMuted),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color.fromARGB(255, 96, 95, 95),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Future deliveries will be paused. Today's active order won't be affected",
                style: TextStyle(
                  color: Color.fromARGB(255, 87, 86, 86),
                  fontWeight: FontWeight.w400,
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Reason For Pausing',
                style: TextStyle(
                  color: AppColors.textBody,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < reasons.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _PauseReasonTile(
                  label: reasons[i],
                  selected: selectedIndex == i,
                  onTap: () => setState(() => selectedIndex = i),
                ),
              ],
              if (isOtherSelected) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Other Reason',
                        style: TextStyle(
                          color: AppColors.textBody,
                          fontWeight: FontWeight.w700,
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
                    fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.fieldBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderMuted),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textBody,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: _border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
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
                          onPressed: selectedIndex == null ? null : _confirm,
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pause, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Pause',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
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

class _PauseReasonTile extends StatelessWidget {
  const _PauseReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const Color _orange = AppColors.primaryOrange;
  static const Color _border = AppColors.fieldBorder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
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
                    color: selected ? _orange : AppColors.unselectedGray,
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
                  style: const TextStyle(
                    color: AppColors.homeValue,
                    fontWeight: FontWeight.w500,
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
