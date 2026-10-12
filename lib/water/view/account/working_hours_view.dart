import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/water/view/account/edit_working_hour_dialog.dart';

class WorkingHoursView extends StatefulWidget {
  const WorkingHoursView({super.key});

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF1C1D1B);
  static const day = Color(0xFF2A2A2A);
  static const muted = Color(0xFF5A423B);
  static const closed = Color(0xFFBA1B1B);
  static const allDayHours = '12:00 AM - 11:59 PM';

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
    final today = schedule[DateTime.now().weekday - 1];
    final todayHours = open24Hours ? WorkingHoursView.allDayHours : today.hours;
    final todayClosed = !open24Hours && today.closed;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE7DF), Color(0xFFFFF1EB), Colors.white],
              stops: [0, 0.28, 0.48],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    _CurrentStatusCard(
                      todayHours: todayHours,
                      todayClosed: todayClosed,
                      open24Hours: open24Hours,
                      on24HourChanged: (value) {
                        HapticFeedback.lightImpact();
                        setState(() => open24Hours = value);
                      },
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Weekly Schedule',
                      style: GoogleFonts.inter(
                        color: WorkingHoursView.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < schedule.length; i++) ...[
                            if (i > 0)
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F3F3)),
                            _DayRow(
                              item: schedule[i],
                              hours: open24Hours ? WorkingHoursView.allDayHours : null,
                              onEdit: () => _editDay(i),
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
            Text(
              'Working Hours',
              style: GoogleFonts.inter(
                color: WorkingHoursView.ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
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
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: WorkingHoursView.orange,
                    size: 26,
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
    required this.todayHours,
    required this.todayClosed,
    required this.open24Hours,
    required this.on24HourChanged,
  });

  final String todayHours;
  final bool todayClosed;
  final bool open24Hours;
  final ValueChanged<bool> on24HourChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Status',
            style: GoogleFonts.inter(
              color: const Color(0xFF8A7B76),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: GoogleFonts.inter(
                color: WorkingHoursView.ink,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              children: [
                const TextSpan(text: 'Today: '),
                TextSpan(
                  text: todayHours,
                  style: TextStyle(
                    color: todayClosed ? WorkingHoursView.closed : WorkingHoursView.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.all_inclusive_rounded,
                color: WorkingHoursView.orange,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                '24-Hour Open',
                style: GoogleFonts.inter(
                  color: WorkingHoursView.ink,
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
                    return WorkingHoursView.orange;
                  }
                  return const Color(0xFFE9E8E4);
                }),
                trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
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
    this.hours,
    required this.onEdit,
  });

  final _DayHours item;
  final String? hours;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final closed = hours == null && item.closed;
    final label = hours ?? item.hours;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.day,
                  style: GoogleFonts.inter(
                    color: WorkingHoursView.day,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: closed ? WorkingHoursView.closed : WorkingHoursView.muted,
                    fontWeight: closed ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            behavior: HitTestBehavior.opaque,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: AssetImage('lib/water/Assets/Images/edit.png'),
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  color: WorkingHoursView.orange,
                  size: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
