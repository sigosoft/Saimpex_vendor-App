import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/water/controller/subscription_calendar_controller.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

class SubscriptionCalendarView extends StatefulWidget {
  const SubscriptionCalendarView({super.key});

  @override
  State<SubscriptionCalendarView> createState() =>
      _SubscriptionCalendarViewState();
}

class _SubscriptionCalendarViewState extends State<SubscriptionCalendarView> {
  late final WaterSubscriptionCalendarController controller;

  static const Color _morningBlue = Color(0xFF2F80ED);
  static const Color _afternoonOrange = Color(0xFFFF5E21);
  static const Color _pausedBrown = Color(0xFF8D4B3A);

  @override
  void initState() {
    super.initState();
    controller = WaterSubscriptionCalendarController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final weekDays = const [
    _DayItem(day: 'MON', date: '12', count: '12'),
    _DayItem(day: 'TUE', date: '13', count: '8'),
    _DayItem(day: 'WED', date: '14', count: '18'),
    _DayItem(day: 'THU', date: '15', count: '9'),
    _DayItem(day: 'FRI', date: '16', count: '11'),
    _DayItem(day: 'SAT', date: '17', count: '7'),
    _DayItem(day: 'SUN', date: '18', count: '5'),
  ];

  final slots = const [
    _SlotGroup(
      timeLabel: '8:00 – 10:00 AM',
      iconColor: Color(0xFF5B8DEF),
      deliveries: [
        _DeliveryItem(
          name: 'Ahmed Mohamed',
          orderId: '#22789007',
          frequency: 'Weekly',
          product: 'Drinking Water 19L x2',
          slotLabel: 'Morning Slot (8:00 - 10:00)',
        ),
      ],
    ),
    _SlotGroup(
      timeLabel: '10:00 – 12:00 PM',
      iconColor: Color(0xFFF2A000),
      deliveries: [
        _DeliveryItem(
          name: 'Mariem Ali',
          orderId: '#22789008',
          frequency: 'Daily',
          product: 'Drinking Water 19L x2',
          slotLabel: 'Morning Slot (10:00 - 12:00)',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WaterSubscriptionCalendarController>(
      init: controller,
      global: false,
      builder: (_) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F4),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF0E8),
                Color(0xFFFFF8F4),
                Color(0xFFF7F7F7),
              ],
              stops: [0, 0.22, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      const _StatsGrid(
                        total: '18',
                        morning: '10',
                        afternoon: '6',
                        paused: '2',
                        morningColor: _morningBlue,
                        afternoonColor: _afternoonOrange,
                        pausedColor: _pausedBrown,
                      ),
                      const SizedBox(height: 18),
                      _WeeklyPlannerHeader(
                        monthLabel: 'AUG 2026',
                        onPrev: () {},
                        onNext: () {},
                      ),
                      const SizedBox(height: 12),
                      _WeekStrip(
                        days: weekDays,
                        selectedIndex: controller.selectedDayIndex,
                        onSelect: controller.selectDay,
                      ),
                      const SizedBox(height: 16),
                      _SearchField(controller: controller.searchController),
                      const SizedBox(height: 12),
                      _FilterChips(
                        filters: controller.filters,
                        selectedIndex: controller.selectedFilterIndex,
                        onSelect: controller.selectFilter,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Wednesday, 14 Aug 2026',
                        style: TextStyle(
                          color: Color(0xFF1E212C),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '18 Scheduled Deliveries',
                        style: TextStyle(
                          color: Color(0xFF8E8E8E),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final slot in slots) ...[
                        _SlotHeader(
                          timeLabel: slot.timeLabel,
                          iconColor: slot.iconColor,
                        ),
                        const SizedBox(height: 10),
                        for (final d in slot.deliveries) ...[
                          _SubscriptionCard(item: d),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 4),
                      ],
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

class _DayItem {
  const _DayItem({
    required this.day,
    required this.date,
    required this.count,
  });

  final String day;
  final String date;
  final String count;
}

class _SlotGroup {
  const _SlotGroup({
    required this.timeLabel,
    required this.iconColor,
    required this.deliveries,
  });

  final String timeLabel;
  final Color iconColor;
  final List<_DeliveryItem> deliveries;
}

class _DeliveryItem {
  const _DeliveryItem({
    required this.name,
    required this.orderId,
    required this.frequency,
    required this.product,
    required this.slotLabel,
  });

  final String name;
  final String orderId;
  final String frequency;
  final String product;
  final String slotLabel;
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
              'Subscription Calendar',
              style: TextStyle(
                color: Color(0xFF1E212C),
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
                    border: Border.all(color: const Color(0xFFFFD8C8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFFFF5E21),
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.total,
    required this.morning,
    required this.afternoon,
    required this.paused,
    required this.morningColor,
    required this.afternoonColor,
    required this.pausedColor,
  });

  final String total;
  final String morning;
  final String afternoon;
  final String paused;
  final Color morningColor;
  final Color afternoonColor;
  final Color pausedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'TOTAL',
                value: total,
                labelColor: const Color(0xFF9E9E9E),
                valueColor: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'MORNING',
                value: morning,
                labelColor: morningColor,
                valueColor: morningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'AFTERNOON',
                value: afternoon,
                labelColor: afternoonColor,
                valueColor: afternoonColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'PAUSED',
                value: paused,
                labelColor: pausedColor,
                valueColor: pausedColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w600,
              fontSize: 28,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyPlannerHeader extends StatelessWidget {
  const _WeeklyPlannerHeader({
    required this.monthLabel,
    required this.onPrev,
    required this.onNext,
  });

  final String monthLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'WEEKLY PLANNER',
          style: TextStyle(
            color: Color(0xFF1E212C),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onPrev,
          child: const Icon(Icons.chevron_left, size: 20, color: Color(0xFF757575)),
        ),
        Text(
          monthLabel,
          style: const TextStyle(
            color: Color(0xFF5A5A5A),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        InkWell(
          onTap: onNext,
          child: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF757575)),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.days,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_DayItem> days;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFF5E21) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: selected ? 0.12 : 0.04),
                    blurRadius: selected ? 10 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.day,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF8E8E8E),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.date,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (selected)
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.count,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    )
                  else
                    Text(
                      day.count,
                      style: const TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search by subscription ID, name',
        hintStyle: const TextStyle(
          color: Color(0xFFB0B0B0),
          fontSize: 13.5,
        ),
        prefixIcon: const Icon(Icons.search, color: Color(0xFFB0B0B0)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF5E21)),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filters,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFF5E21) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: selected
                    ? null
                    : Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotHeader extends StatelessWidget {
  const _SlotHeader({
    required this.timeLabel,
    required this.iconColor,
  });

  final String timeLabel;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.wb_sunny_outlined, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          timeLabel,
          style: const TextStyle(
            color: Color(0xFF8E8E8E),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Divider(color: Color(0xFFE6E6E6), thickness: 1),
        ),
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.item});

  final _DeliveryItem item;

  static const Color _orange = Color(0xFFFF5E21);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.avatarPink,
                child: Text(
                  item.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.avatarText,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: Color(0xFF1E212C),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            1, 0, 0, 0, 0,
                            0, 1, 0, 0, 0,
                            0, 0, 1, 0, 0,
                            1, 1, 1, 0, 0,
                          ]),
                          child: Image.asset(
                            AppAssets.deliveryIcon,
                            width: 14,
                            height: 14,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.delivery_dining_rounded,
                              size: 14,
                              color: _orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Delivery',
                          style: TextStyle(
                            color: _orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '  ${item.orderId}',
                          style: const TextStyle(
                            color: Color(0xFF8E8E8E),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '• Active',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.frequency,
                      style: const TextStyle(
                        color: Color(0xFF7B1FA2),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product,
                  style: const TextStyle(
                    color: Color(0xFF1E212C),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(0xFF8E8E8E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.slotLabel,
                      style: const TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _orange,
                      side: const BorderSide(color: _orange),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Chat With Customer',
                      softWrap: false,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Call Customer',
                      softWrap: false,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
