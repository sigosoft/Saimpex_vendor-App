import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/models/home_order.dart';
import 'package:saimpex_vendor/water/views/home/reject_order_sheet.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key, required this.order});

  final HomeOrder order;

  static const Color _orange = Color(0xFFFF5E21);
  static const Color _title = Color(0xFF1E212C);
  static const Color _muted = Color(0xFF8E8E8E);
  static const Color _cardShadow = Color(0x0F000000);

  @override
  Widget build(BuildContext context) {
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
                      if (order.deliveryPartnerName != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'DELIVERY PARTNER',
                          style: TextStyle(
                            color: _muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DeliveryPartnerCard(
                          name: order.deliveryPartnerName!,
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'ORDER ITEMS (1)',
                        style: TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _OrderItemCard(),
                      const SizedBox(height: 16),
                      const Text(
                        'PAYMENT SUMMARY',
                        style: TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _PaymentSummary(
                        isOnline: order.isOnlinePayment,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Order Timeline',
                        style: TextStyle(
                          color: _title,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _OrderTimeline(
                        isDelivery: order.isDelivery,
                        status: order.status,
                        hasDeliveryPartner: order.deliveryPartnerName != null,
                      ),
                    ],
                  ),
                ),
                _BottomActions(
                  status: order.status,
                  isDelivery: order.isDelivery,
                  onReject: () => showRejectOrderSheet(context),
                  onAccept: () {},
                  onPrepare: () {},
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
              'Order Details',
              style: TextStyle(
                color: OrderDetailsView._title,
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
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: OrderDetailsView._orange,
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

  final HomeOrder order;

  static const Color _labelOrange = Color(0xFFE67E4D);
  static const Color _newBadge = Color(0xFFF39C12);
  static const Color _acceptedBadge = Color(0xFF2EAD5B);
  static const Color _pillShadow = Color(0x14000000);

  (String, Color) get _statusBadge {
    return switch (order.status) {
      HomeOrderStatus.newOrder => ('NEW', _newBadge),
      HomeOrderStatus.accepted => ('ACCEPTED', _acceptedBadge),
      HomeOrderStatus.preparing => ('PREPARING', const Color(0xFFFF8A00)),
      HomeOrderStatus.ready => ('READY', const Color(0xFF2EAD5B)),
      HomeOrderStatus.delivered => ('DELIVERED', const Color(0xFF2EAD5B)),
      HomeOrderStatus.cancelled => ('CANCELLED', const Color(0xFF9E9E9E)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final typeColor =
        order.isDelivery ? OrderDetailsView._orange : const Color(0xFF2F80ED);
    final (badgeLabel, badgeColor) = _statusBadge;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
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
                color: Color.fromARGB(255, 247, 80, 2),
                size: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                'CUSTOMER',
                style: TextStyle(
                  color: Color.fromARGB(255, 247, 80, 2),
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
          _SoftPill(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFFFE4E8),
                  child: Text(
                    order.customerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFC62828),
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
                          color: OrderDetailsView._title,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '+222 45 12 34 56',
                        style: TextStyle(
                          color: Color(0xFF9E9E9E),
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
                    color: OrderDetailsView._orange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: OrderDetailsView._orange.withValues(alpha: 0.35),
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
                child: _SoftPill(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REQUEST ID',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
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
                                color: OrderDetailsView._orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const TextSpan(
                              text: ' - Today - 10:45 AM',
                              style: TextStyle(
                                color: Color(0xFF5A5A5A),
                                fontWeight: FontWeight.w400,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _SoftPill(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'DELIVERY TYPE',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!order.isDelivery)
                            Text(
                              '(',
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          if (!order.isDelivery) const SizedBox(width: 2),
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
                          Text(
                            order.orderType,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                          if (!order.isDelivery) const SizedBox(width: 2),
                          if (!order.isDelivery)
                            Text(
                              ')',
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
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
                  color: _labelOrange,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'DELIVERY ADDRESS',
                  style: TextStyle(
                    color: _labelOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _SoftPill(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFFFF0E6),
                    child: Icon(
                      Icons.home_outlined,
                      color: OrderDetailsView._orange,
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
                            color: OrderDetailsView._title,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Near Marhaba Supermarket, Nouakchott',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
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

class _SoftPill extends StatelessWidget {
  const _SoftPill({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _CustomerCard._pillShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: OrderDetailsView._cardShadow,
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
              color: const Color(0xFFE8E8E8),
              child: Image.asset(
                AppAssets.waterCan19L,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.water_drop,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drinking Water 19L',
                  style: TextStyle(
                    color: OrderDetailsView._title,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '50 MRU',
                  style: TextStyle(
                    color: OrderDetailsView._orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Qty: 1',
              style: TextStyle(
                color: Color(0xFF555555),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const _PayRow(label: 'Item total', value: '50 MRU'),
          const SizedBox(height: 10),
          const _PayRow(label: 'Delivery fee', value: '20 MRU'),
          const SizedBox(height: 10),
          const _PayRow(label: 'Tax', value: '10 MRU'),
          const SizedBox(height: 10),
          _PayRow(
            label: 'Payment type',
            value: isOnline ? 'Online Payment' : 'Cash on Delivery',
            valueColor: OrderDetailsView._orange,
          ),
          const SizedBox(height: 10),
          const _PayRow(
            label: 'Payment on',
            value: 'Feb 07, 2026 10:45 AM, Today',
            valueColor: Color(0xFFB0B0B0),
            valueSize: 12,
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF444444), height: 1),
          const SizedBox(height: 12),
          const Row(
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
                '80 MRU',
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

class _DeliveryPartnerCard extends StatelessWidget {
  const _DeliveryPartnerCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFFFE0D0),
                child: Text(
                  initials.isEmpty ? 'D' : initials,
                  style: const TextStyle(
                    color: OrderDetailsView._orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2EAD5B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: OrderDetailsView._title,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFC107),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: TextStyle(
                        color: OrderDetailsView._title,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '(124 reviews)',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w400,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: OrderDetailsView._orange,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: OrderDetailsView._orange.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.phone, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({
    required this.isDelivery,
    required this.status,
    this.hasDeliveryPartner = false,
  });

  final bool isDelivery;
  final HomeOrderStatus status;
  final bool hasDeliveryPartner;

  static const Color _containerBg = Color(0xFFF8F7F4);
  static const String _stamp = 'Feb 07, 2026 10:45 AM';

  static const deliveryBase = [
    (Icons.check_rounded, 'Order Received'),
    (Icons.check_rounded, 'Order Accepted'),
    (Icons.local_drink_outlined, 'Preparing'),
    (Icons.check_rounded, 'Ready for Dispatch'),
    (Icons.delivery_dining_outlined, 'Delivery Partner Assigned'),
    (Icons.check_rounded, 'Picked Up by Rider'),
    (Icons.home_outlined, 'Order Delivered'),
  ];

  static const selfPickupBase = [
    (Icons.check_rounded, 'Order Received'),
    (Icons.check_rounded, 'Order Accepted'),
    (Icons.local_drink_outlined, 'Preparing'),
    (Icons.check_rounded, 'Ready for Pickup'),
    (Icons.check_rounded, 'Picked Up by Customer'),
  ];

  int get _completedCount {
    return switch (status) {
      HomeOrderStatus.newOrder => 1,
      HomeOrderStatus.accepted => 2,
      HomeOrderStatus.preparing => 3,
      HomeOrderStatus.ready => isDelivery
          ? (hasDeliveryPartner ? 5 : 4)
          : 4,
      HomeOrderStatus.delivered => isDelivery ? 7 : 5,
      HomeOrderStatus.cancelled => 1,
    };
  }

  @override
  Widget build(BuildContext context) {
    final base = isDelivery ? deliveryBase : selfPickupBase;
    final completed = _completedCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: _containerBg,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          for (var i = 0; i < base.length; i++)
            _TimelineStep(
              icon: base[i].$1,
              title: base[i].$2,
              subtitle: i < completed ? _stamp : '',
              active: i < completed,
              showLine: i < base.length - 1,
              lineActive: i < completed - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.showLine,
    required this.lineActive,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final bool showLine;
  final bool lineActive;

  static const Color _inactiveCircle = Color(0xFFE8EEF5);
  static const Color _inactiveIcon = Color(0xFFAAB7C6);
  static const Color _inactiveText = Color(0xFF97A6B9);
  static const Color _lineInactive = Color(0xFFE8EEF5);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: active ? OrderDetailsView._orange : _inactiveCircle,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: OrderDetailsView._orange
                                  .withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: active ? Colors.white : _inactiveIcon,
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: lineActive
                          ? OrderDetailsView._orange
                          : _lineInactive,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showLine ? 22 : 0, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: active ? OrderDetailsView._title : _inactiveText,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.status,
    required this.isDelivery,
    required this.onReject,
    required this.onAccept,
    required this.onPrepare,
  });

  final HomeOrderStatus status;
  final bool isDelivery;
  final VoidCallback onReject;
  final VoidCallback onAccept;
  final VoidCallback onPrepare;

  String? get _primaryLabel {
    return switch (status) {
      HomeOrderStatus.accepted => 'Prepare Order',
      HomeOrderStatus.preparing => 'Mark as Ready',
      HomeOrderStatus.ready when !isDelivery => 'Mark as Picked Up',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final primaryLabel = _primaryLabel;
    final showRejectAccept = status == HomeOrderStatus.newOrder ||
        status == HomeOrderStatus.delivered;

    if (primaryLabel == null && !showRejectAccept) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SafeArea(
        top: false,
        child: primaryLabel != null
            ? SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color:
                            OrderDetailsView._orange.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onPrepare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OrderDetailsView._orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      primaryLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A1A1A),
                          side: const BorderSide(color: Color(0xFFD0D0D0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Reject',
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
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: OrderDetailsView._orange
                                  .withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OrderDetailsView._orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Accept Order',
                            style: TextStyle(
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
      ),
    );
  }
}
