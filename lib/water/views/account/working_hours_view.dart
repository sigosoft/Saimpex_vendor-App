import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/views/account/edit_working_hour_dialog.dart';

class WorkingHoursView extends StatefulWidget {
  const WorkingHoursView({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WorkingHoursView()),
    );
  }

  @override
  State<WorkingHoursView> createState() => _WorkingHoursViewState();
}

class _WorkingHoursViewState extends State<WorkingHoursView> {
  bool open24Hours = false;

  final schedule = [
    _DayHours(day: 'Monday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Tuesday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Wednesday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Thursday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Friday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Saturday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Sunday', hours: 'Closed', closed: true),
  ];

  Future<void> _editDay(int index) async {
    final item = schedule[index];
    final result = await showEditWorkingHourDialog(
      context,
      day: item.day,
      startTime: item.startTime,
      endTime: item.endTime,
      open24Hours: item.open24Hours,
    );
    if (result == null || !mounted) return;

    setState(() {
      if (result.open24Hours) {
        schedule[index] = item.copyWith(
          hours: '24-Hour Open',
          closed: false,
          open24Hours: true,
          startTime: '00:00',
          endTime: '23:59',
        );
      } else {
        schedule[index] = item.copyWith(
          hours: _formatRange(result.startTime, result.endTime),
          closed: false,
          open24Hours: false,
          startTime: result.startTime,
          endTime: result.endTime,
        );
      }
    });
  }

  String _formatRange(String start, String end) {
    return '${_to12Hour(start)} - ${_to12Hour(end)}';
  }

  String _to12Hour(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${h12.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundMid,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundTop,
                AppColors.backgroundMid,
                Colors.white,
              ],
              stops: [0, 0.2, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    children: [
                      _CurrentStatusCard(
                        open24Hours: open24Hours,
                        on24HourChanged: (v) =>
                            setState(() => open24Hours = v),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Weekly Schedule',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < schedule.length; i++) ...[
                              _DayRow(
                                item: schedule[i],
                                onEdit: () => _editDay(i),
                              ),
                              if (i < schedule.length - 1)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Divider(
                                    height: 1,
                                    color: AppColors.divider,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayHours {
  const _DayHours({
    required this.day,
    required this.hours,
    this.closed = false,
    this.open24Hours = false,
    this.startTime = '08:00',
    this.endTime = '22:00',
  });

  final String day;
  final String hours;
  final bool closed;
  final bool open24Hours;
  final String startTime;
  final String endTime;

  _DayHours copyWith({
    String? hours,
    bool? closed,
    bool? open24Hours,
    String? startTime,
    String? endTime,
  }) {
    return _DayHours(
      day: day,
      hours: hours ?? this.hours,
      closed: closed ?? this.closed,
      open24Hours: open24Hours ?? this.open24Hours,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'Working Hours',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primaryOrange,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentStatusCard extends StatelessWidget {
  const _CurrentStatusCard({
    required this.open24Hours,
    required this.on24HourChanged,
  });

  final bool open24Hours;
  final ValueChanged<bool> on24HourChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT STATUS',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Today: ',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
                TextSpan(
                  text: '08:00 AM - 10:00 PM',
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.all_inclusive_rounded,
                color: AppColors.primaryOrange,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '24-Hour Open',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
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
                trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.transparent;
                  }
                  return const Color(0xFFC5CAD1);
                }),
                trackOutlineWidth: const WidgetStatePropertyAll(1.2),
                onChanged: on24HourChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.item,
    required this.onEdit,
  });

  final _DayHours item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.day,
                    style: TextStyle(
                      color: item.closed
                          ? AppColors.textSecondary
                          : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.hours,
                    style: TextStyle(
                      color: item.closed
                          ? const Color(0xFFC4452D)
                          : AppColors.textSecondary,
                      fontWeight:
                          item.closed ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit_square,
              color: AppColors.primaryOrange,
              size: 20,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryOrange.withValues(alpha: 0.55),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
