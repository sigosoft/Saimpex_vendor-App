import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/home_cleaning/view/booking_details_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/reject_booking_sheet.dart';

class HomeCleaningController extends GetxController {
  bool acceptingBookings = true;
  int navIndex = 0;
  int filterIndex = 0;

  void toggleAccepting(bool value) {
    acceptingBookings = value;
    update();
  }

  void selectNav(int index) {
    if (index == navIndex) return;
    navIndex = index;
    update();
  }

  void selectFilter(int index) {
    filterIndex = index;
    update();
  }
}

class HomeCleaningHome extends StatefulWidget {
  const HomeCleaningHome({super.key});

  @override
  State<HomeCleaningHome> createState() => _HomeCleaningHomeState();
}

class _HomeCleaningHomeState extends State<HomeCleaningHome> {
  late final HomeCleaningController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<HomeCleaningController>()
        ? Get.find<HomeCleaningController>()
        : Get.put(HomeCleaningController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeCleaningController>(
      builder: (_) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFFFF9F6),
            body: Column(
              children: [
                Expanded(
                  child: switch (controller.navIndex) {
                    0 => _HomeTab(controller: controller),
                    1 => const _PlaceholderTab(title: 'Bookings'),
                    2 => const _PlaceholderTab(title: 'My Services'),
                    3 => const _PlaceholderTab(title: 'Chat'),
                    _ => const _PlaceholderTab(title: 'Account'),
                  },
                ),
                _BottomNav(
                  selectedIndex: controller.navIndex,
                  onSelect: controller.selectNav,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.controller});

  final HomeCleaningController controller;

  static const _bookings = [
    _Booking(
      name: 'Ahmed',
      service: 'Regular Cleaning',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      tasks: [
        _Task('Bedroom × 4'),
        _Task('Kitchen × 1'),
        _Task('Fridge Cleaning × 1'),
      ],
    ),
    _Booking(
      name: 'Bilal',
      service: 'Pest Control & Disinfection',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      tasks: [
        _Task('Bedroom × 4'),
        _Task('Kitchen × 1'),
        _Task('Fridge Cleaning × 1'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bookings = controller.filterIndex == 0 ? _bookings : const <_Booking>[];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF1EB), Color(0xFFFFF9F6), Color(0xFFFFF9F6)],
          stops: [0, 0.28, 1],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 10, 16, 20),
        children: [
          const _WelcomeHeader(),
          const SizedBox(height: 14),
          const _MemberCard(),
          const SizedBox(height: 12),
          _StatusCard(
            accepting: controller.acceptingBookings,
            onToggle: (value) {
              HapticFeedback.lightImpact();
              controller.toggleAccepting(value);
            },
          ),
          const SizedBox(height: 12),
          const _MetricsGrid(),
          const SizedBox(height: 14),
          const _TotalsRow(),
          const SizedBox(height: 18),
          _SectionHeader(onSeeAll: () => controller.selectNav(1)),
          const SizedBox(height: 12),
          const _SearchField(),
          const SizedBox(height: 12),
          _Filters(
            selectedIndex: controller.filterIndex,
            onSelect: controller.selectFilter,
          ),
          const SizedBox(height: 14),
          if (bookings.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Text(
                'No bookings here',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            )
          else
            for (final booking in bookings) ...[
              _BookingCard(booking: booking),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _Booking {
  const _Booking({
    required this.name,
    required this.service,
    required this.orderId,
    required this.timeAgo,
    required this.tasks,
  });

  final String name;
  final String service;
  final String orderId;
  final String timeAgo;
  final List<_Task> tasks;
}

class _Task {
  const _Task(this.label);

  final String label;
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'lib/water/Assets/Images/home_top_icon.png',
          height: 42,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.storefront,
            color: Color(0xFFFF5722),
            size: 28,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Welcome to Saimpex Vendor!',
            style: GoogleFonts.inter(
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.1,
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration:  BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0), width:.1),
            boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.black,
            size: 26,
          ),
        ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'lib/home_cleaning/Assets/images/silver member.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Silver Member',
              style: GoogleFonts.inter(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 253, 249, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Expires in 7 days',
              style: GoogleFonts.inter(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.accepting, required this.onToggle});

  final bool accepting;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2E7D32);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_outlined, color: Color.fromARGB(255, 59, 133, 62), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: accepting ? 'Open' : 'Closed',
                        style: GoogleFonts.inter(
                          color: accepting ? green  : const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: accepting ? ' • Accepting bookings' : ' • Not accepting',
                        style: GoogleFonts.inter(
                          color: accepting ? green : const Color(0xFFBA1B1B),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Today: 08:00 - 22:00',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onToggle(!accepting),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: accepting ? const Color(0xFFFF6B00) : const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: accepting ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricCard(
                count: '2',
                label: "Today's Bookings",
                countColor: Colors.white,
                circleGradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF8A3D), Color(0xFFFFB300)],
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: '2',
                label: 'Upcoming',
                circle: Color(0xFFC8E6C9),
                countColor: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricCard(
                count: '2',
                label: 'In Progress',
                circle: Color(0xFFFFB300),
                countColor: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: '2',
                label: 'Completed',
                circle: Color(0xFF43A047),
                countColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.count,
    required this.label,
    required this.countColor,
    this.circle,
    this.circleGradient,
  });

  final String count;
  final String label;
  final Color countColor;
  final Color? circle;
  final Gradient? circleGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: circleGradient == null ? circle : null,
              gradient: circleGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: GoogleFonts.inter(
                color: countColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
              fontSize: 14,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow();

  static const _label = Color(0xFF8D6E63);
  static const _value = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 6, 4, 2),
      child: Row(
        children: [
          Expanded(child: _TotalItem(title: 'BOOKINGS', value: '15')),
          _TotalDivider(),
          Expanded(child: _TotalItem(title: 'COMPLETED', value: '2')),
          _TotalDivider(),
          Expanded(
            child: _TotalItem(
              title: 'REVENUE',
              value: '830',
              suffix: 'MRU',
              showTrend: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalDivider extends StatelessWidget {
  const _TotalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: const Color(0xFFE6D5C3),
    );
  }
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({
    required this.title,
    required this.value,
    this.suffix,
    this.showTrend = false,
  });

  final String title;
  final String value;
  final String? suffix;
  final bool showTrend;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTrend) ...[
              const Icon(Icons.trending_up, size: 13, color: Color(0xFF2E7D32)),
              const SizedBox(width: 4),
            ],
            Text(
              title,
              style: GoogleFonts.inter(
                color: _TotalsRow._label,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                color: _TotalsRow._value,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  suffix!,
                  style: GoogleFonts.inter(
                    color: _TotalsRow._label,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'BOOKINGS',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See All',
            style: GoogleFonts.inter(
              color: const Color(0xFFFF5722),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        style: GoogleFonts.inter(color: const Color(0xFF1A1A1A), fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by ID, name',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFFBDBDBD),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFBDBDBD), size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _labels = ['New Bookings', 'Accepted', 'In Progress'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFFF6D00), Color(0xFFFFC107)],
                          )
                        : null,
                    color: selected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: selected ? null : Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Text(
                    _labels[index],
                    style: GoogleFonts.inter(
                      color: selected ? Colors.white : const Color(0xFF424242),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (selected && index == 0)
                  Positioned(
                    right: -2,
                    top: -8,
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '02',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFF6D00),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final _Booking booking;

  static const _orange = Color(0xFFFF5722);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingDetailsView(
              customerName: booking.name,
              serviceName: booking.service,
              orderId: booking.orderId,
            ),
          ),
        );
      },
      child: Container(
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
                backgroundColor: const Color(0xFFFDECEC),
                child: Text(
                  booking.name[0],
                  style: GoogleFonts.inter(
                    color: _orange,
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
                      booking.name,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      booking.service,
                      style: GoogleFonts.inter(
                        color: _orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.orderId} • ${booking.timeAgo}',
                      style: GoogleFonts.inter(
                        color: const Color.fromARGB(255, 95, 95, 95),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 243, 170, 0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'NEW',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final task in booking.tasks)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Text(
                      task.label,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF424242),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 16,
                    color: Color(0xFF42A5F5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '15 Aug 2026, 2:00 PM - 4:00 PM',
                    softWrap: false,
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: _orange),
                  const SizedBox(height: 4),
                  Text(
                    'Sahara View',
                    softWrap: false,
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      showRejectBookingSheet(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Reject',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF424242),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => HapticFeedback.lightImpact(),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Accept Booking',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
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
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF9F6),
      alignment: Alignment.center,
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _labels = ['Home', 'Bookings', 'My Services', 'Chat', 'Account'];
  static const _icons = [
    'lib/home_cleaning/Assets/images/home.png',
    'lib/home_cleaning/Assets/images/bookings.png',
    'lib/home_cleaning/Assets/images/my services.png',
    'lib/home_cleaning/Assets/images/chat.png',
    'lib/home_cleaning/Assets/images/account.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segment = constraints.maxWidth / _labels.length;
              return SizedBox(
                width: constraints.maxWidth,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      left: selectedIndex * segment + (segment - 40) / 2,
                      top: 0,
                      width: 40,
                      height: 40,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFFFF5722),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(_labels.length, (index) {
                        final selected = selectedIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (index == selectedIndex) return;
                              HapticFeedback.selectionClick();
                              onSelect(index);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: Center(
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(end: selected ? 1 : 0),
                                      duration: const Duration(milliseconds: 280),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, t, _) {
                                        return Image.asset(
                                          _icons[index],
                                          width: 22,
                                          height: 22,
                                          color: Color.lerp(
                                            const Color(0xFF8D7B74),
                                            Colors.white,
                                            t,
                                          ),
                                          colorBlendMode: BlendMode.srcIn,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 280),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                    color: selected
                                        ? const Color(0xFFFF5722)
                                        : const Color(0xFF8D7B74),
                                  ),
                                  child: Text(
                                    _labels[index],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
