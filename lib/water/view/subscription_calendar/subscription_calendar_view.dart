import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/water/controller/subscription_calendar_controller.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/view/chat/chat_view.dart';

class SubscriptionCalendarView extends StatefulWidget {
  const SubscriptionCalendarView({super.key});

  @override
  State<SubscriptionCalendarView> createState() =>
      _SubscriptionCalendarViewState();
}

class _SubscriptionCalendarViewState extends State<SubscriptionCalendarView> {
  late final WaterSubscriptionCalendarController controller;

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

  static const weekDays = [
    _DayItem(day: 'MON', date: '12', count: '12'),
    _DayItem(day: 'TUE', date: '13', count: '8'),
    _DayItem(day: 'WED', date: '14', count: '18'),
    _DayItem(day: 'THU', date: '15', count: '9'),
    _DayItem(day: 'FRI', date: '16', count: '11'),
    _DayItem(day: 'SAT', date: '17', count: '7'),
    _DayItem(day: 'SUN', date: '18', count: '5'),
  ];

  static const slots = [
    _SlotGroup(
      timeLabel: '8:00 - 10:00 AM',
      iconColor: Color(0xFFFF9800),
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
      timeLabel: '10:00 - 12:00 PM',
      iconColor: Color(0xFFFFB74D),
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
      builder: (_) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFFFF9F6),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF1EB),
                    Color(0xFFFFF9F6),
                    Color(0xFFFFF9F6),
                  ],
                  stops: [0, 0.22, 1],
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.paddingOf(context).top + 8),
                  _Header(onBack: () => Navigator.of(context).maybePop()),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        const _StatsGrid(),
                        const SizedBox(height: 18),
                        const _WeeklyPlannerHeader(),
                        const SizedBox(height: 10),
                        _WeekStrip(
                          days: weekDays,
                          selectedIndex: controller.selectedDayIndex,
                          onSelect: controller.selectDay,
                        ),
                        const SizedBox(height: 14),
                        _SearchField(controller: controller.searchController),
                        const SizedBox(height: 12),
                        _FilterChips(
                          filters: controller.filters,
                          selectedIndex: controller.selectedFilterIndex,
                          onSelect: controller.selectFilter,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Wednesday, 14 Aug 2026',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '18 Scheduled Deliveries',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        for (final slot in slots) ...[
                          _SlotHeader(
                            timeLabel: slot.timeLabel,
                            iconColor: slot.iconColor,
                          ),
                          const SizedBox(height: 10),
                          for (final delivery in slot.deliveries) ...[
                            _SubscriptionCard(item: delivery),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            Text(
              'Subscription Calendar',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
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
                    border: Border.all(color: const Color(0xFFFFE0D0)),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFFFF5216),
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'TOTAL',
                value: '18',
                color: Color(0xFF1A1A1A),
                labelColor: Color(0xFF9E9E9E),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'MORNING',
                value: '10',
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'AFTERNOON',
                value: '6',
                color: Color(0xFFFF5722),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'PAUSED',
                value: '2',
                color: Color(0xFF5D4037),
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
    required this.color,
    this.labelColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: labelColor ?? color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 26,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyPlannerHeader extends StatelessWidget {
  const _WeeklyPlannerHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'WEEKLY PLANNER',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.4,
          ),
        ),
        const Spacer(),
        const Icon(Icons.chevron_left, size: 18, color: Color(0xFF9E9E9E)),
        Text(
          'AUG 2026',
          style: GoogleFonts.inter(
            color: const Color(0xFF757575),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9E9E9E)),
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
    return Row(
      children: [
        for (var index = 0; index < days.length; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(
            child: _DayCard(
              day: days[index],
              selected: index == selectedIndex,
              onTap: () => onSelect(index),
            ),
          ),
        ],
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final _DayItem day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = selected ? Colors.white : const Color(0xFF9E9E9E);
    final date = selected ? Colors.white : const Color(0xFF1A1A1A);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: 86,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF5722) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.12 : 0.04),
              blurRadius: selected ? 10 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.day,
              style: GoogleFonts.inter(
                color: label,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              day.date,
              style: GoogleFonts.inter(
                color: date,
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 1,
                  ),
                ),
              )
            else
              Text(
                day.count,
                style: GoogleFonts.inter(
                  color: const Color(0xFFBDBDBD),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  height: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(
          color: const Color(0xFF1A1A1A),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Search by subscription ID, name',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFFBDBDBD),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFBDBDBD),
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
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
      height: 34,
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
                color: selected ? const Color(0xFFFF5722) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: selected
                    ? null
                    : Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Text(
                filters[index],
                style: GoogleFonts.inter(
                  color: selected ? Colors.white : const Color(0xFF424242),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1,
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
          style: GoogleFonts.inter(
            color: const Color(0xFF757575),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Divider(color: Color(0xFFEEEEEE), thickness: 1, height: 1),
        ),
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.item});

  final _DeliveryItem item;

  static const Color _orange = Color(0xFFFF5722);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
                radius: 20,
                backgroundColor: const Color(0xFFF8BBD0),
                child: Text(
                  item.name[0].toUpperCase(),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFE91E63),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.deliveryIcon,
                          width: 14,
                          height: 14,
                          color: _orange,
                          colorBlendMode: BlendMode.srcIn,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.delivery_dining_rounded,
                            size: 14,
                            color: _orange,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Delivery',
                          style: GoogleFonts.inter(
                            color: _orange,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.orderId,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w400,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Active',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.frequency,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9C27B0),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.1,
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
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color.fromARGB(255, 100, 99, 99),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.slotLabel,
                      style: GoogleFonts.inter(
                        color: const Color.fromARGB(255, 100, 99, 99),
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
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                ChatView.open(context, customerName: item.name);
              },
              icon: Image.asset(
                'lib/water/Assets/Images/chat.png',
                width: 18,
                height: 18,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
              label: Text(
                'Chat with Customer',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
