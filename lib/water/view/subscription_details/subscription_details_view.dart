import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/model/home_order.dart';
import 'package:saimpex_vendor/water/view/chat/chat_view.dart';
import 'package:saimpex_vendor/water/view/home/pause_subscription_sheet.dart';

class SubscriptionDetailsView extends StatelessWidget {
  const SubscriptionDetailsView({super.key, required this.order});

  final SubscriptionOrder order;
  bool get _isPaused => order.status == SubscriptionOrderStatus.paused;
  bool get _isActive => order.status == SubscriptionOrderStatus.active;
  bool get _isNew => order.status == SubscriptionOrderStatus.newOrder;
  /// New + Active share the full schedule layout from the design.
  bool get _showDeliverySchedule => _isActive || _isNew;

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
                AppColors.backgroundBottom,
              ],
              stops: [0, 0.2, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(onBack: () => Navigator.of(context).maybePop()),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _CustomerCard(order: order),
                      if (_isPaused) ...[
                        const SizedBox(height: 12),
                        _PausedStatusCard(order: order),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'PLAN SUMMARY',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _ProductCard(),
                      const SizedBox(height: 12),
                      _PlanGrid(
                        frequency: order.planName,
                        timeSlot: order.timeSlot,
                        startDate: 'Jul-22-2026',
                        endDate: 'Aug-22-2026',
                      ),
                      if (_showDeliverySchedule) ...[
                        const SizedBox(height: 10),
                        _NextDeliveryBar(
                          value: order.nextDelivery ?? 'Tomorrow',
                        ),
                        const SizedBox(height: 18),
                        const _SectionTitle(
                          title: 'UPCOMING DELIVERIES',
                          action: 'See All',
                        ),
                        const SizedBox(height: 10),
                        const _UpcomingDeliveriesCard(),
                      ],
                      const SizedBox(height: 18),
                      const _SectionTitle(
                        title: 'DELIVERY HISTORY',
                        action: 'See All',
                        titleColor: AppColors.sectionTitle,
                      ),
                      const SizedBox(height: 10),
                      const _DeliveryHistoryCard(),
                      const SizedBox(height: 18),
                      const Text(
                        'PAYMENT SUMMARY',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _PaymentSummary(),
                    ],
                  ),
                ),
                _BottomActions(
                  status: order.status,
                  pausedByVendor: order.pausedByVendor,
                  customerName: order.customerName,
                  onPause: () => showPauseSubscriptionSheet(context),
                ),
              ],
            ),
          ),
        ),
      ),
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
              'Subscription Details',
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
                    border: Border.all(
                      color: AppColors.primaryOrange.withValues(
                        alpha: 0.35,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
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

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.order});

  final SubscriptionOrder order;

  static List<BoxShadow> get _softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final typeColor = order.isDelivery
        ? AppColors.primaryOrange
        : AppColors.selfPickupBlue;

    final (badgeLabel, badgeColor) = switch (order.status) {
      SubscriptionOrderStatus.newOrder ||
      SubscriptionOrderStatus.active =>
        ('ACTIVE', AppColors.activeGreen),
      SubscriptionOrderStatus.paused =>
        ('PAUSED', AppColors.primaryOrange),
      SubscriptionOrderStatus.cancelled =>
        ('CANCELLED', AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_search_outlined,
                color: AppColors.primaryOrange,
                size: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                'CUSTOMER',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: _softShadow,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.avatarPink,
                  child: Text(
                    order.customerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.avatarText,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '+222 45 12 34 56',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange
                            .withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.phone, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REQUEST ID',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: order.orderId,
                              style: const TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const TextSpan(
                              text: ' • Today • 10:45 AM',
                              style: TextStyle(
                                color: AppColors.textMeta,
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: const Text(
                          'DELIVERY TYPE',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              1, 0, 0, 0, 0,
                              0, 1, 0, 0, 0,
                              0, 0, 1, 0, 0,
                              1, 1, 1, 0, 0,
                            ]),
                            child: Image.asset(
                              order.isDelivery
                                  ? AppAssets.deliveryIcon
                                  : AppAssets.selfPickupIcon,
                              width: 14,
                              height: 14,
                              errorBuilder: (_, _, _) => Icon(
                                order.isDelivery
                                    ? Icons.delivery_dining
                                    : Icons.shopping_bag_outlined,
                                size: 14,
                                color: typeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              order.isDelivery ? 'Delivery' : 'Self Pickup',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (order.isDelivery) ...[
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryOrange,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'DELIVERY ADDRESS',
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: _softShadow,
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.orangeSoftBg,
                    child: Icon(
                      Icons.home_outlined,
                      color: AppColors.primaryOrange,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sahara View Home',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Near Marhaba Supermarket, Nouakchott',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w400,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.softGrayAlt,
              child: Image.asset(
                AppAssets.waterCan19L,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.water_drop,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Drinking Water 19L',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.softGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Qty: 1',
                    style: TextStyle(
                      color: AppColors.textLabel,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanGrid extends StatelessWidget {
  const _PlanGrid({
    required this.frequency,
    required this.timeSlot,
    required this.startDate,
    required this.endDate,
  });

  final String frequency;
  final String timeSlot;
  final String startDate;
  final String endDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _PlanTile(
                icon: Icons.sync_rounded,
                label: 'Frequency',
                value: frequency,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PlanTile(
                icon: Icons.access_time_rounded,
                label: 'Time Slot',
                value: timeSlot,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PlanTile(
                icon: Icons.calendar_month_outlined,
                label: 'Start',
                value: startDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PlanTile(
                icon: Icons.calendar_month_outlined,
                label: 'End',
                value: endDate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.planPurpleBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.planPurple),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.planPurpleSoft,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.planPurple,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextDeliveryBar extends StatelessWidget {
  const _NextDeliveryBar({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.planPurpleBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            color: AppColors.planPurple,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Delivery',
                  style: TextStyle(
                    color: AppColors.planPurpleSoft,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.planPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.planPurple,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _PausedStatusCard extends StatelessWidget {
  const _PausedStatusCard({required this.order});

  final SubscriptionOrder order;
  @override
  Widget build(BuildContext context) {
    final pausedBy = order.pausedByVendor ? 'You' : 'Customer';
    final pausedOn = order.pausedOn ?? 'Jul-24-2026 - 10:30 AM';
    final reason = order.pauseReason;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.pausedCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.pausedCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.pausedAmber,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.pause_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Currently Paused',
                style: TextStyle(
                  color: AppColors.pausedAmber,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PausedMetaRow(label: 'PAUSED BY:', value: pausedBy),
          const SizedBox(height: 6),
          _PausedMetaRow(label: 'PAUSED ON:', value: pausedOn),
          if (order.pausedByVendor &&
              reason != null &&
              reason.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _PausedMetaRow(label: 'REASON:', value: reason),
          ],
        ],
      ),
    );
  }
}

class _PausedMetaRow extends StatelessWidget {
  const _PausedMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.labelGray,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    this.titleColor = AppColors.textSecondary,
  });

  final String title;
  final String action;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            color: AppColors.primaryOrange,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _UpcomingDeliveriesCard extends StatelessWidget {
  const _UpcomingDeliveriesCard();

  static const items = [
    ('23', 'Tomorrow', '08:30 AM'),
    ('24', 'Sunday', '08:30 AM'),
    ('25', 'Saturday', '08:30 AM'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
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
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.planPurpleBg,
                    child: Text(
                      items[i].$1,
                      style: const TextStyle(
                        color: AppColors.planPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[i].$2,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.planPurple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    items[i].$3,
                    style: const TextStyle(
                      color: AppColors.planPurple,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryHistoryCard extends StatelessWidget {
  const _DeliveryHistoryCard();
  static const items = [
    (true, 'Delivered', 'Order #22789104 • 23-Jul-2026'),
    (true, 'Delivered', 'Order #22789104 • 24-Jul-2026'),
    (false, 'In Progress', 'Order #22789112 • Processing'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 22),
            _DeliveryHistoryRow(
              delivered: items[i].$1,
              title: items[i].$2,
              subtitle: items[i].$3,
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryHistoryRow extends StatelessWidget {
  const _DeliveryHistoryRow({
    required this.delivered,
    required this.title,
    required this.subtitle,
  });

  final bool delivered;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final accent = delivered
        ? AppColors.deliveredGreen
        : AppColors.progressBlue;
    final bg = delivered
        ? AppColors.deliveredBg
        : AppColors.progressBg;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            delivered
                ? Icons.check_circle_outline_rounded
                : Icons.sync_rounded,
            size: 20,
            color: accent,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.detailGray,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.paymentCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          _PayRow(label: 'Subscription Amount', value: '9000 MRU'),
          SizedBox(height: 10),
          _PayRow(
            label: 'Subscription Savings',
            value: '-4500 MRU',
            valueColor: AppColors.primaryOrange,
          ),
          SizedBox(height: 10),
          _PayRow(label: 'Estimated Delivery Fee', value: '900 MRU'),
          SizedBox(height: 10),
          _PayRow(label: 'Tax', value: '100 MRU'),
          SizedBox(height: 10),
          _PayRow(
            label: 'Payment on',
            value: 'Feb 07, 2026 10:45 AM, Today',
            valueColor: AppColors.textHint,
            valueSize: 12,
          ),
          SizedBox(height: 12),
          Divider(color: AppColors.paymentDivider, height: 1),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Total payed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              Text(
                '5500 MRU',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
    this.valueSize = 13.5,
  });

  final String label;
  final String value;
  final Color valueColor;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w500,
              fontSize: valueSize,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.status,
    required this.pausedByVendor,
    required this.customerName,
    required this.onPause,
  });

  final SubscriptionOrderStatus status;
  final bool pausedByVendor;
  final String customerName;
  final VoidCallback onPause;

  Widget _chatButton({required BuildContext context, bool fullWidth = false}) {
    return SizedBox(
      height: 50,
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: () => ChatView.open(context, customerName: customerName),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryOrange,
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: AppColors.primaryOrange,
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 18),
              SizedBox(width: 6),
              Text(
                'Chat With Customer',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    double iconSize = 18,
  }) {
    return SizedBox(
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustomerPaused =
        status == SubscriptionOrderStatus.paused && !pausedByVendor;
    final isVendorPaused =
        status == SubscriptionOrderStatus.paused && pausedByVendor;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SafeArea(
        top: false,
        child: isCustomerPaused
            ? _chatButton(context: context, fullWidth: true)
            : Row(
                children: [
                  Expanded(child: _chatButton(context: context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isVendorPaused
                        ? _primaryButton(
                            label: 'Resume',
                            icon: Icons.play_arrow_rounded,
                            iconSize: 20,
                            onPressed: () {},
                          )
                        : _primaryButton(
                            label: 'Pause',
                            icon: Icons.pause,
                            onPressed: onPause,
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
