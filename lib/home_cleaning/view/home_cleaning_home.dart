import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/home_cleaning_controller.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';
import 'package:saimpex_vendor/home_cleaning/view/booking_details_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/chat/home_cleaning_messages_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaning_booking_action.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaning_booking_format.dart';
import 'package:saimpex_vendor/home_cleaning/view/home_cleaning_account_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/my_services_view.dart';

// HomeCleaningController lives in controller/; re-exported so the other
// home cleaning tabs keep importing it from here.
export 'package:saimpex_vendor/home_cleaning/controller/home_cleaning_controller.dart'
    show HomeCleaningController;

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
                    1 => _BookingsTab(controller: controller),
                    2 => MyServicesView(controller: controller),
                    3 => HomeCleaningMessagesView(controller: controller),
                    _ => HomeCleaningAccountView(controller: controller),
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

const _pageGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF1EB), Color(0xFFFFF9F6), Color(0xFFFFF9F6)],
    stops: [0, 0.28, 1],
  ),
);

/// Loads the next page when the list is scrolled near its end.
bool _onScrollLoadMore(ScrollNotification n, HomeCleaningController c) {
  if (n.metrics.axis == Axis.vertical &&
      n.metrics.pixels >= n.metrics.maxScrollExtent - 240 &&
      c.hasMore &&
      !c.loadingMore &&
      !c.bookingsLoading) {
    c.loadBookings(more: true);
  }
  return false;
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.controller});

  final HomeCleaningController controller;

  @override
  Widget build(BuildContext context) {
    final dashboard = controller.dashboard;
    return Container(
      decoration: _pageGradient,
      child: RefreshIndicator(
        color: const Color(0xFFFF5722),
        onRefresh: controller.refreshAll,
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) => _onScrollLoadMore(n, controller),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 10, 16, 20),
            children: [
              const _WelcomeHeader(),
              if (controller.membership != null) ...[
                const SizedBox(height: 14),
                _MemberCard(
                  name: controller.membership!.name!,
                  expiresInDays: controller.membership!.expiresInDays,
                ),
              ],
              const SizedBox(height: 12),
              _StatusCard(
                open: controller.storeOpen ?? controller.acceptingBookings,
                accepting: controller.acceptingBookings,
                todayHours: dashboard?.todayHours,
                busy: controller.togglingAvailability,
                onToggle: (value) async {
                  HapticFeedback.lightImpact();
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  final fallback = S.of(context).cleaningBookingAvailabilityFailed;
                  final error = await controller.toggleAccepting(value);
                  if (error != null) {
                    messenger?.showSnackBar(
                      SnackBar(content: Text(error.isEmpty ? fallback : error)),
                    );
                  }
                },
              ),
              if (dashboard == null && controller.dashboardError != null) ...[
                const SizedBox(height: 12),
                _ErrorState(
                  message: controller.dashboardError!,
                  onRetry: controller.loadDashboard,
                  compact: true,
                ),
              ],
              const SizedBox(height: 12),
              _MetricsGrid(dashboard: dashboard),
              const SizedBox(height: 14),
              _TotalsRow(dashboard: dashboard),
              const SizedBox(height: 18),
              _SectionHeader(onSeeAll: () => controller.selectNav(1)),
              const SizedBox(height: 12),
              _SearchField(controller: controller.searchController),
              const SizedBox(height: 12),
              _Filters(
                selectedIndex: controller.filterIndex,
                onSelect: controller.selectFilter,
                countFor: controller.countFor,
              ),
              const SizedBox(height: 14),
              ..._bookingListChildren(context, controller),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom-nav "Bookings" tab: the same list with search, filters and paging.
class _BookingsTab extends StatelessWidget {
  const _BookingsTab({required this.controller});

  final HomeCleaningController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _pageGradient,
      child: RefreshIndicator(
        color: const Color(0xFFFF5722),
        onRefresh: () async {
          await Future.wait([controller.loadBookings(), controller.loadDashboard()]);
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) => _onScrollLoadMore(n, controller),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 10, 16, 20),
            children: [
              SizedBox(
                height: 44,
                child: Center(
                  child: Text(
                    S.of(context).cleaningBookings,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SearchField(controller: controller.searchController),
              const SizedBox(height: 12),
              _Filters(
                selectedIndex: controller.filterIndex,
                onSelect: controller.selectFilter,
                countFor: controller.countFor,
              ),
              const SizedBox(height: 14),
              ..._bookingListChildren(context, controller),
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> _bookingListChildren(BuildContext context, HomeCleaningController c) {
  if (c.bookingsLoading && c.bookings.isEmpty) {
    return const [
      Padding(
        padding: EdgeInsets.only(top: 28),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFFF5722)),
          ),
        ),
      ),
    ];
  }
  if (c.bookingsError != null && c.bookings.isEmpty) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _ErrorState(message: c.bookingsError!, onRetry: c.loadBookings),
      ),
    ];
  }
  if (c.bookings.isEmpty) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 28),
        child: Text(
          S.of(context).cleaningNoBookingsHere,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF9E9E9E),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    ];
  }
  return [
    for (final booking in c.bookings) ...[
      _BookingCard(
        booking: booking,
        busy: c.busyIds.contains(booking.id),
        onAction: (reject) => runCleaningBookingAction(context, booking, reject: reject),
      ),
      const SizedBox(height: 12),
    ],
    if (c.loadingMore)
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF5722)),
          ),
        ),
      ),
  ];
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry, this.compact = false});

  final String message;
  final Future<void> Function() onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = message.trim().isEmpty ? S.of(context).cleaningBookingLoadFailed : message;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0D0)),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(
              S.of(context).tryAgain,
              style: GoogleFonts.inter(
                color: const Color(0xFFFF5722),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
            S.of(context).welcomeToSaimpexVendor,
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
  const _MemberCard({required this.name, this.expiresInDays});

  final String name;
  final int? expiresInDays;

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
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          if (expiresInDays != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 253, 249, 255),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                S.of(context).expiresInDays(expiresInDays.toString()),
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
  const _StatusCard({
    required this.open,
    required this.accepting,
    required this.todayHours,
    required this.busy,
    required this.onToggle,
  });

  final bool open;
  final bool accepting;
  final String? todayHours;
  final bool busy;
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
                        text: open
                            ? S.of(context).cleaningOpenStatus
                            : S.of(context).cleaningClosedStatus,
                        style: GoogleFonts.inter(
                          color: open ? green  : const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: ' • ${accepting ? S.of(context).cleaningAcceptingBookings : S.of(context).cleaningNotAccepting}',
                        style: GoogleFonts.inter(
                          color: accepting ? green : const Color(0xFFBA1B1B),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (todayHours != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    S.of(context).cleaningTodayHours(todayHours!),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: busy ? null : () => onToggle(!accepting),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: busy ? 0.6 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 30,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: accepting ? const Color(0xFFFF6B00) : const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: accepting
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _count(int? v) => v?.toString() ?? '–';

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.dashboard});

  final CleaningDashboard? dashboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricCard(
                count: _count(dashboard?.todayBookings),
                label: S.of(context).cleaningTodaysBookings,
                countColor: Colors.white,
                circleGradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF8A3D), Color(0xFFFFB300)],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: _count(dashboard?.upcoming),
                label: S.of(context).cleaningUpcoming,
                circle: Color(0xFFC8E6C9),
                countColor: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricCard(
                count: _count(dashboard?.inProgress),
                label: S.of(context).cleaningInProgress,
                circle: Color(0xFFFFB300),
                countColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: _count(dashboard?.completed),
                label: S.of(context).cleaningCompleted,
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
  const _TotalsRow({required this.dashboard});

  final CleaningDashboard? dashboard;

  static const _label = Color(0xFF8D6E63);
  static const _value = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    final revenue = dashboard?.revenue;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
      child: Row(
        children: [
          Expanded(
            child: _TotalItem(
              title: S.of(context).cleaningBookingsHeader,
              value: _count(dashboard?.totalBookings),
            ),
          ),
          const _TotalDivider(),
          Expanded(
            child: _TotalItem(
              title: S.of(context).completed,
              value: _count(dashboard?.completed),
            ),
          ),
          const _TotalDivider(),
          Expanded(
            child: _TotalItem(
              title: S.of(context).cleaningRevenueHeader,
              value: revenue == null ? '–' : CleaningBookingFormat.number(revenue),
              suffix: 'MRU',
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
  });

  final String title;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
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
          S.of(context).cleaningBookingsHeader,
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
            S.of(context).viewAll,
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
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.inter(color: const Color(0xFF1A1A1A), fontSize: 14),
        decoration: InputDecoration(
          hintText: S.of(context).searchByIdName,
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
  const _Filters({
    required this.selectedIndex,
    required this.onSelect,
    required this.countFor,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final int? Function(CleaningBookingTab tab) countFor;

  static List<String> _labelsOf(BuildContext context) => [
        S.of(context).cleaningNewBookings,
        S.of(context).accepted,
        S.of(context).cleaningInProgress,
        S.of(context).cleaningCompleted,
        S.of(context).cancelled,
      ];

  @override
  Widget build(BuildContext context) {
    final labels = _labelsOf(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          // Badge: bookings in this chip's statuses (serviceDashboard
          // status_mix); not shown on Cancelled, as in the design.
          final count = index < 4 ? countFor(CleaningBookingTab.values[index]) : null;
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
                    labels[index],
                    style: GoogleFonts.inter(
                      color: selected ? Colors.white : const Color(0xFF424242),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (selected && count != null)
                  PositionedDirectional(
                    end: -2,
                    top: -8,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      height: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        count.toString().padLeft(2, '0'),
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

/// Status pill text + colour shared by the list card.
({String label, Color color}) _statusPill(BuildContext context, CleaningBooking b) {
  if (b.isInProgress) {
    return (label: S.of(context).cleaningStatusInProgress, color: const Color(0xFF1E6BE6));
  }
  if (b.isCompleted) {
    return (label: S.of(context).completed, color: const Color(0xFF009624));
  }
  if (b.isOnTheWay) {
    return (label: S.of(context).cleaningBookingStatusOnTheWay, color: const Color(0xFF009624));
  }
  if (b.isCancelled) {
    return (label: S.of(context).cleaningBookingStatusCancelled, color: const Color(0xFFBA1B1B));
  }
  return (label: S.of(context).cleaningStatusAccepted, color: const Color(0xFF009624));
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.busy,
    required this.onAction,
  });

  final CleaningBooking booking;
  final bool busy;
  final void Function(bool reject) onAction;

  static const _orange = Color(0xFFFF5722);

  bool get _isDetailedStatus => !booking.isNew;

  @override
  Widget build(BuildContext context) {
    final service = booking.serviceName ?? '';
    final timeAgo = CleaningBookingFormat.timeAgo(context, booking.createdAt);
    final meta = [booking.displayCode, if (timeAgo.isNotEmpty) timeAgo];
    final chips = booking.chipLines;
    final slot = CleaningBookingFormat.slot(booking);
    final address = booking.address;
    final pill = _statusPill(context, booking);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingDetailsView(booking: booking),
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
                  booking.initial,
                  style: GoogleFonts.inter(
                    color: _orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _isDetailedStatus
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  booking.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: pill.color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  pill.label,
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
                          const SizedBox(height: 3),
                          Text.rich(
                            TextSpan(
                              children: [
                                if (service.isNotEmpty)
                                  TextSpan(
                                    text: '$service - ',
                                    style: GoogleFonts.inter(
                                      color: _orange,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                TextSpan(
                                  text: meta.join(' - '),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF757575),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: 1.2,
                            ),
                          ),
                          if (service.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              service,
                              style: GoogleFonts.inter(
                                color: _orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 2),
                          Text(
                            meta.join(' • '),
                            style: GoogleFonts.inter(
                              color: const Color.fromARGB(255, 95, 95, 95),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
              if (!_isDetailedStatus) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 243, 170, 0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    S.of(context).cleaningStatusNew,
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
            ],
          ),
          if (chips.isNotEmpty) ...[
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
                  for (final line in chips)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: Text(
                        CleaningBookingFormat.chip(line),
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
          ],
          if (_isDetailedStatus) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          ],
          if (slot != null || address != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (slot != null)
                  Flexible(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                          color: Color(0xFF42A5F5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          slot,
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF616161),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (slot != null && address != null) const SizedBox(width: 16),
                if (address != null)
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: _orange),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF616161),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (booking.isCompleted || booking.isCancelled)
            const SizedBox.shrink()
          else ...[
            const SizedBox(height: 14),
            if (booking.isInProgress || booking.isAccepted)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: busy ? null : () => onAction(false),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _orange.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: busy
                      ? const _ButtonSpinner()
                      : Text(
                          booking.isInProgress
                              ? S.of(context).cleaningMarkAsCompleted
                              : S.of(context).cleaningStartCleaning,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: busy ? null : () => onAction(true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A1A1A),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          S.of(context).reject,
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
                        onPressed: busy ? null : () => onAction(false),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _orange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _orange.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: busy
                            ? const _ButtonSpinner()
                            : Text(
                                S.of(context).cleaningAcceptBooking,
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
        ],
      ),
    ),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static List<String> _labelsOf(BuildContext context) => [
        S.of(context).home,
        S.of(context).cleaningBookings,
        S.of(context).cleaningMyServices,
        S.of(context).chat,
        S.of(context).account,
      ];
  static const _icons = [
    'lib/home_cleaning/Assets/images/home.png',
    'lib/home_cleaning/Assets/images/bookings.png',
    'lib/home_cleaning/Assets/images/my services.png',
    'lib/home_cleaning/Assets/images/chat.png',
    'lib/home_cleaning/Assets/images/account.png',
  ];

  @override
  Widget build(BuildContext context) {
    final labels = _labelsOf(context);
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
              final segment = constraints.maxWidth / labels.length;
              return SizedBox(
                width: constraints.maxWidth,
                child: Stack(
                  children: [
                    AnimatedPositionedDirectional(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      start: selectedIndex * segment + (segment - 40) / 2,
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
                      children: List.generate(labels.length, (index) {
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
                                    labels[index],
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
