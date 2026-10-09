import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
    barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
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
  String? _error;

  @override
  void initState() {
    super.initState();
    open24Hours = widget.initialOpen24Hours;
    startTime = widget.initialStartTime;
    endTime = widget.initialEndTime;
  }

  int _minutes(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return hour * 60 + minute;
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF5317),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1C1D1B),
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
      _error = null;
    });
  }

  void _save() {
    if (!open24Hours && _minutes(endTime) <= _minutes(startTime)) {
      setState(() => _error = 'End time must be after start time');
      return;
    }
    Navigator.of(context).pop(
      EditWorkingHourResult(
        open24Hours: open24Hours,
        startTime: startTime,
        endTime: endTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x33000000),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Center(
              child: Text(
                'Edit Working Hour',
                style: GoogleFonts.inter(
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.day,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111111),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      '24-Hour Open',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1C1D1B),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: open24Hours,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      thumbColor: const WidgetStatePropertyAll(Colors.white),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFFFF5216);
                        }
                        return const Color(0xFFE9E8E4);
                      }),
                      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          open24Hours = value;
                          _error = null;
                          if (value) {
                            startTime = '00:00';
                            endTime = '23:59';
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _timeLabel('Start Time')),
                    const SizedBox(width: 12),
                    Expanded(child: _timeLabel('End Time')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TimeBox(
                        value: startTime,
                        onTap: () => _pickTime(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeBox(
                        value: endTime,
                        onTap: () => _pickTime(isStart: false),
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFBA1B1B),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF626E7E),
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
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33FF5317),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 44,
                          child: FilledButton(
                            onPressed: _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5317),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Save',
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
        ],
      ),
    );
  }

  Widget _timeLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: const Color(0xFFA3A3A3),
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F3F3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: const Color(0xFF3E3E3E),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
