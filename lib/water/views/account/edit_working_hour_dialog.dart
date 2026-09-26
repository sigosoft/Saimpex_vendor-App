import 'package:flutter/material.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

class EditWorkingHourResult {
  const EditWorkingHourResult({
    required this.open24Hours,
    required this.startTime,
    required this.endTime,
  });

  final bool open24Hours;
  final String startTime;
  final String endTime;
}

Future<EditWorkingHourResult?> showEditWorkingHourDialog(
  BuildContext context, {
  required String day,
  String startTime = '00:00',
  String endTime = '23:59',
  bool open24Hours = false,
}) {
  return showDialog<EditWorkingHourResult>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => EditWorkingHourDialog(
      day: day,
      initialStartTime: startTime,
      initialEndTime: endTime,
      initialOpen24Hours: open24Hours,
    ),
  );
}

class EditWorkingHourDialog extends StatefulWidget {
  const EditWorkingHourDialog({
    super.key,
    required this.day,
    this.initialStartTime = '00:00',
    this.initialEndTime = '23:59',
    this.initialOpen24Hours = false,
  });

  final String day;
  final String initialStartTime;
  final String initialEndTime;
  final bool initialOpen24Hours;

  @override
  State<EditWorkingHourDialog> createState() => _EditWorkingHourDialogState();
}

class _EditWorkingHourDialogState extends State<EditWorkingHourDialog> {
  late bool open24Hours;
  late String startTime;
  late String endTime;

  @override
  void initState() {
    super.initState();
    open24Hours = widget.initialOpen24Hours;
    startTime = widget.initialStartTime;
    endTime = widget.initialEndTime;
  }

  Future<void> _pickTime({required bool isStart}) async {
    final parts = (isStart ? startTime : endTime).split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 0,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryOrange,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isStart) {
        startTime = formatted;
      } else {
        endTime = formatted;
      }
      open24Hours = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Text(
                'Edit Working Hour',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.5,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.day,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '24-Hour Open',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      Switch(
                        value: open24Hours,
                        thumbColor: const WidgetStatePropertyAll(Colors.white),
                        trackColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primaryOrange;
                          }
                          return const Color(0xFFE2E5E9);
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.transparent;
                          }
                          return const Color(0xFFC5CAD1);
                        }),
                        trackOutlineWidth: const WidgetStatePropertyAll(1.2),
                        onChanged: (v) {
                          setState(() {
                            open24Hours = v;
                            if (v) {
                              startTime = '00:00';
                              endTime = '23:59';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeField(
                          label: 'Start Time',
                          value: startTime,
                          enabled: !open24Hours,
                          onTap: () => _pickTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeField(
                          label: 'End Time',
                          value: endTime,
                          enabled: !open24Hours,
                          onTap: () => _pickTime(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.inventoryResetBtn,
                              foregroundColor: AppColors.textDark,
                              elevation: 0,
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
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(
                                EditWorkingHourResult(
                                  open24Hours: open24Hours,
                                  startTime: startTime,
                                  endTime: endTime,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: AppColors.primaryOrange
                                  .withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
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
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 46,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: enabled ? AppColors.textDark : AppColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
