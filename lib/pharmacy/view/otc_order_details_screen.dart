part of 'order_details_screen.dart';

class _OtcOrderDetailsPage extends StatelessWidget {
  const _OtcOrderDetailsPage({
    required this.name,
    required this.phone,
    required this.requestId,
    required this.requestMeta,
    required this.selfPickup,
    required this.cashOnDelivery,
    this.accepted = false,
    this.preparing = false,
    this.ready = false,
    this.partnerAssigned = false,
    this.delivered = false,
    this.cancelled = false,
    this.isLoading = false,
    this.orderDetailData,
    this.orderId,
    this.orderRawId,
  });

  final String name;
  final String phone;
  final String requestId;
  final String requestMeta;
  final bool selfPickup;
  final bool cashOnDelivery;
  final bool accepted;
  final bool preparing;
  final bool ready;
  final bool partnerAssigned;
  final bool delivered;
  final bool cancelled;
  final bool isLoading;
  final PharmacyOrderDetailData? orderDetailData;
  final dynamic orderId;
  final dynamic orderRawId;

  static const Color _orange = Color(0xFFFF5722);
  static const Color _badge = Color(0xFFF99D1C);
  static const Color _acceptedBadge = Color(0xFF22C55E);
  static const Color _section = Color(0xFFB0B7C3);

  static const _timeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Order Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(title: 'Order Accepted', icon: Icons.check_rounded),
    _TimelineStep(
      title: 'Preparing Medicines',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
    ),
    _TimelineStep(title: 'Picked Up by Rider', icon: Icons.check_rounded),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _acceptedDeliveryTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Order Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Order Accepted',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Preparing Medicines',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
    ),
    _TimelineStep(title: 'Picked Up by Rider', icon: Icons.check_rounded),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _preparingDeliveryTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Order Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Order Accepted',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Preparing Medicines',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
      completed: true,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
    ),
    _TimelineStep(title: 'Picked Up by Rider', icon: Icons.check_rounded),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _readyDeliveryTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Order Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Order Accepted',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Preparing Medicines',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
      completed: true,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
      completed: true,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
    ),
    _TimelineStep(title: 'Picked Up by Rider', icon: Icons.check_rounded),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _assignedPartnerTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Order Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Order Accepted',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Preparing Medicines',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
      completed: true,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
      completed: true,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
      completed: true,
    ),
    _TimelineStep(title: 'Picked Up by Rider', icon: Icons.check_rounded),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _deliveredTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Order Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Order Accepted',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Preparing Medicines',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
      completed: true,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
      completed: true,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
      completed: true,
    ),
    _TimelineStep(
      title: 'Picked Up by Rider',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Order Delivered',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.home_outlined,
      completed: true,
    ),
  ];

  static const _selfPickupTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Order Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(title: 'Order Accepted', icon: Icons.check_rounded),
    _TimelineStep(title: 'Preparing', icon: Icons.assignment_outlined),
    _TimelineStep(title: 'Ready for Pickup', icon: Icons.check_rounded),
    _TimelineStep(title: 'Picked Up by Customer', icon: Icons.check_rounded),
  ];

  List<_TimelineStep> _buildTimelineSteps() {
    final logs = orderDetailData?.statusLogs ?? [];
    String? getLogTime(int status) {
      for (final log in logs) {
        if (log.status == status &&
            log.createdAt != null &&
            log.createdAt!.trim().isNotEmpty) {
          return log.createdAt;
        }
      }
      return null;
    }

    final receivedSubtitle =
        getLogTime(1) ?? (requestMeta.isNotEmpty ? requestMeta : null);
    final acceptedSubtitle = getLogTime(2);
    final preparingSubtitle = getLogTime(3);
    final readySubtitle = getLogTime(4);
    final deliveredSubtitle = getLogTime(9);

    if (selfPickup) {
      return [
        _TimelineStep(
          title: 'Order Received',
          subtitle: receivedSubtitle,
          icon: Icons.check_rounded,
          completed: true,
        ),
        _TimelineStep(
          title: 'Order Accepted',
          subtitle: acceptedSubtitle,
          icon: Icons.check_rounded,
          completed: accepted || preparing || ready || delivered,
        ),
        _TimelineStep(
          title: 'Preparing',
          subtitle: preparingSubtitle,
          icon: Icons.assignment_outlined,
          completed: preparing || ready || delivered,
        ),
        _TimelineStep(
          title: 'Ready for Pickup',
          subtitle: readySubtitle,
          icon: Icons.check_rounded,
          completed: ready || delivered,
        ),
        _TimelineStep(
          title: 'Picked Up by Customer',
          subtitle: deliveredSubtitle,
          icon: Icons.check_rounded,
          completed: delivered,
        ),
      ];
    }

    return [
      _TimelineStep(
        title: 'Order Received',
        subtitle: receivedSubtitle,
        icon: Icons.check_rounded,
        completed: true,
      ),
      _TimelineStep(
        title: 'Order Accepted',
        subtitle: acceptedSubtitle,
        icon: Icons.check_rounded,
        completed:
            accepted || preparing || ready || partnerAssigned || delivered,
      ),
      _TimelineStep(
        title: 'Preparing Medicines',
        subtitle: preparingSubtitle,
        icon: Icons.medication_outlined,
        customIcon: _TimelineCustomIcon.capsule,
        completed: preparing || ready || partnerAssigned || delivered,
      ),
      _TimelineStep(
        title: 'Ready for Dispatch',
        subtitle: readySubtitle,
        icon: Icons.inventory_2_outlined,
        customIcon: _TimelineCustomIcon.openBox,
        completed: ready || partnerAssigned || delivered,
      ),
      _TimelineStep(
        title: 'Delivery Partner Assigned',
        subtitle: readySubtitle,
        icon: Icons.delivery_dining,
        customIcon: _TimelineCustomIcon.scooter,
        completed: partnerAssigned || delivered,
      ),
      _TimelineStep(
        title: 'Picked Up by Rider',
        subtitle: readySubtitle,
        icon: Icons.check_rounded,
        completed: delivered,
      ),
      _TimelineStep(
        title: 'Order Delivered',
        subtitle: deliveredSubtitle,
        icon: Icons.home_outlined,
        completed: delivered,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A';
    final items = orderDetailData?.items ?? [];
    final order = orderDetailData?.order;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFF0E8),
                      Color(0xFFFFF8F4),
                      Color(0xFFFFFFFF),
                    ],
                    stops: [0, 0.16, 1],
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.paddingOf(context).top + 8),
                    const _OtcDetailsHeader(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: isLoading && orderDetailData == null
                          ? const Center(
                              child: CircularProgressIndicator(color: _orange),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              children: [
                                _OtcCustomerCard(
                                  initial: initial,
                                  name: name,
                                  phone: phone,
                                  requestId: requestId,
                                  requestMeta: requestMeta,
                                  selfPickup: selfPickup,
                                  accepted: accepted,
                                  preparing: preparing,
                                  ready: ready,
                                  delivered: delivered,
                                  cancelled: cancelled,
                                  address: order?.displayLocation,
                                  onChatTap: () => _openCustomerChat(
                                    context,
                                    customerName: (order?.customerName?.trim().isNotEmpty == true)
                                        ? order!.customerName!.trim()
                                        : (name.isNotEmpty ? name : 'Customer'),
                                    customerId: order?.userId,
                                  ),
                                ),
                                if (partnerAssigned) ...[
                                  const SizedBox(height: 18),
                                  const _DeliveryPartnerSection(),
                                ],
                                const SizedBox(height: 18),
                                Text(
                                  'ORDER ITEMS (${items.isNotEmpty ? items.length : (orderDetailData != null ? 0 : 2)})',
                                  style: GoogleFonts.inter(
                                    color: _section,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (items.isNotEmpty) ...[
                                  for (int i = 0; i < items.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 10),
                                    _OtcItemCard(
                                      name: items[i].displayName,
                                      price: items[i].totalPrice != null
                                          ? (items[i].totalPrice!.contains(
                                                  'MRU',
                                                )
                                                ? items[i].totalPrice!
                                                : '${items[i].totalPrice} MRU')
                                          : (items[i].unitPrice != null
                                                ? (items[i].unitPrice!.contains(
                                                        'MRU',
                                                      )
                                                      ? items[i].unitPrice!
                                                      : '${items[i].unitPrice} MRU')
                                                : '0.00 MRU'),
                                      image: items[i].displayImageUrl ?? '',
                                      quantity: items[i].quantity ?? 1,
                                    ),
                                  ],
                                ] else if (orderDetailData != null &&
                                    items.isEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'No items found',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF8E8E8E),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  const _OtcItemCard(
                                    name: 'Digital Thermometer',
                                    price: '50 MRU',
                                    image:
                                        'lib/pharmacy/Assets/images/digital_thermometer.jpg',
                                  ),
                                  const SizedBox(height: 10),
                                  const _OtcItemCard(
                                    name: 'Baby Diapers',
                                    price: '50 MRU',
                                    image:
                                        'lib/pharmacy/Assets/images/baby_diapers.jpg',
                                  ),
                                ],
                                const SizedBox(height: 18),
                                Text(
                                  'PAYMENT SUMMARY',
                                  style: GoogleFonts.inter(
                                    color: _section,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _OtcPaymentSummary(
                                  cashOnDelivery: cashOnDelivery,
                                  itemTotal: order?.subtotal,
                                  deliveryFee: order?.deliveryFee,
                                  tax: order?.tax,
                                  paymentOn: order?.placedAt,
                                  totalPaid: order?.total,
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  selfPickup ||
                                          accepted ||
                                          preparing ||
                                          ready ||
                                          delivered ||
                                          cancelled
                                      ? 'Order Timeline'
                                      : 'ORDER TIMELINE',
                                  style: GoogleFonts.inter(
                                    color:
                                        selfPickup ||
                                            accepted ||
                                            preparing ||
                                            ready ||
                                            delivered ||
                                            cancelled
                                        ? const Color(0xFF1A1A1A)
                                        : _section,
                                    fontWeight: FontWeight.w700,
                                    fontSize:
                                        selfPickup ||
                                            accepted ||
                                            preparing ||
                                            ready ||
                                            delivered ||
                                            cancelled
                                        ? 16
                                        : 12,
                                    letterSpacing:
                                        selfPickup ||
                                            accepted ||
                                            preparing ||
                                            ready ||
                                            delivered ||
                                            cancelled
                                        ? 0
                                        : 0.6,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _TimelineCard(steps: _buildTimelineSteps()),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            if (!ready && !delivered && !cancelled)
              _OtcDetailsActions(accepted: accepted, preparing: preparing),
          ],
        ),
      ),
    );
  }
}

class _OtcDetailsHeader extends StatelessWidget {
  const _OtcDetailsHeader();

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
              'Order Details',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.2,
                height: 1.2,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE0D0)),
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
                    color: _OtcOrderDetailsPage._orange,
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

class _OtcCustomerCard extends StatelessWidget {
  const _OtcCustomerCard({
    required this.initial,
    required this.name,
    required this.phone,
    required this.requestId,
    required this.requestMeta,
    required this.selfPickup,
    this.accepted = false,
    this.preparing = false,
    this.ready = false,
    this.delivered = false,
    this.cancelled = false,
    this.address,
    this.onChatTap,
  });

  final String initial;
  final String name;
  final String phone;
  final String requestId;
  final String requestMeta;
  final bool selfPickup;
  final bool accepted;
  final bool preparing;
  final bool ready;
  final bool delivered;
  final bool cancelled;
  final String? address;
  final VoidCallback? onChatTap;

  static const Color _accent = Color(0xFFFF5722);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _panel = Color(0xFFF6F7F8);
  static const Color _label = Color(0xFFB0B0B0);
  static const Color _meta = Color(0xFF8E8E8E);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5C22).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_search_rounded, color: _accent, size: 18),
              const SizedBox(width: 6),
              Text(
                'CUSTOMER',
                style: GoogleFonts.inter(
                  color: _accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.6,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      accepted || preparing || ready || delivered || cancelled
                      ? 10
                      : 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cancelled
                      ? const Color(0xFFEF4444)
                      : (delivered || ready || accepted
                            ? _OtcOrderDetailsPage._acceptedBadge
                            : preparing
                            ? _OtcOrderDetailsPage._orange
                            : _OtcOrderDetailsPage._badge),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cancelled
                      ? 'CANCELLED'
                      : (delivered
                            ? 'DELIVERED'
                            : ready
                            ? 'READY'
                            : preparing
                            ? 'PREPARING'
                            : accepted
                            ? 'ACCEPTED'
                            : 'NEW'),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize:
                        accepted || preparing || ready || delivered || cancelled
                        ? 10
                        : 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFE24B3B),
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
                        name,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: GoogleFonts.inter(
                          color: _meta,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onChatTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: CustomPaint(
                        painter: _ChatDotsIconPainter(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REQUEST ID',
                        style: GoogleFonts.inter(
                          color: _label,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: requestId,
                              style: GoogleFonts.inter(
                                color: _accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                            TextSpan(
                              text: '  •  $requestMeta',
                              style: GoogleFonts.inter(
                                color: _meta,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELIVERY TYPE',
                        style: GoogleFonts.inter(
                          color: _label,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (selfPickup)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '(',
                                style: GoogleFonts.inter(
                                  color: _blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Image.asset(
                                'lib/water/Assets/Images/selfpickup_icon.png',
                                width: 16,
                                height: 16,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Self Pickup',
                                style: GoogleFonts.inter(
                                  color: _blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                ')',
                                style: GoogleFonts.inter(
                                  color: _blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            Image.asset(
                              'lib/pharmacy/Assets/images/delivery_icon.png',
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Delivery',
                                style: GoogleFonts.inter(
                                  color: _accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  height: 1.1,
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
          if (!selfPickup) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: _accent, size: 18),
                const SizedBox(width: 6),
                Text(
                  'DELIVERY ADDRESS',
                  style: GoogleFonts.inter(
                    color: _accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF4EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.home_outlined,
                      color: _accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address != null && address!.trim().isNotEmpty
                              ? address!
                              : 'Delivery Address',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address != null && address!.trim().isNotEmpty
                              ? ''
                              : 'Near customer location',
                          style: GoogleFonts.inter(
                            color: _meta,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.2,
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

class _OtcItemCard extends StatelessWidget {
  const _OtcItemCard({
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  final String name;
  final String price;
  final String image;
  final int quantity;

  Widget _buildItemImage(String img) {
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return Image.network(
        img,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (img.isNotEmpty) {
      return Image.asset(
        img,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      color: const Color(0xFFF3F4F6),
      alignment: Alignment.center,
      child: const Icon(
        Icons.medication_outlined,
        color: Color(0xFF9CA3AF),
        size: 26,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildItemImage(image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: GoogleFonts.inter(
                    color: _OtcOrderDetailsPage._orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Qty: $quantity',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtcPaymentSummary extends StatelessWidget {
  const _OtcPaymentSummary({
    required this.cashOnDelivery,
    this.itemTotal,
    this.deliveryFee,
    this.tax,
    this.paymentOn,
    this.totalPaid,
  });

  final bool cashOnDelivery;
  final String? itemTotal;
  final String? deliveryFee;
  final String? tax;
  final String? paymentOn;
  final String? totalPaid;

  static const Color _muted = Color(0xFFD0D0D0);
  static const Color _orange = Color(0xFFFF5722);

  String _formatAmount(String? val) {
    if (val == null || val.trim().isEmpty) return '0.00 MRU';
    final s = val.trim();
    return s.contains('MRU') ? s : '$s MRU';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _OtcPayRow(label: 'Item total', value: _formatAmount(itemTotal)),
          const SizedBox(height: 12),
          _OtcPayRow(label: 'Delivery fee', value: _formatAmount(deliveryFee)),
          const SizedBox(height: 12),
          _OtcPayRow(label: 'Tax', value: _formatAmount(tax)),
          const SizedBox(height: 12),
          _OtcPayRow(
            label: 'Payment type',
            value: cashOnDelivery ? 'Cash on Delivery' : 'Online Payment',
            valueColor: _orange,
          ),
          if (paymentOn != null && paymentOn!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _OtcPayRow(label: 'Payment on', value: paymentOn!, valueSize: 12),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFF5C5C5C)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Total paid',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                _formatAmount(totalPaid),
                style: GoogleFonts.inter(
                  color: _orange,
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

class _OtcPayRow extends StatelessWidget {
  const _OtcPayRow({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
    this.valueSize = 14,
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
          style: GoogleFonts.inter(
            color: _OtcPaymentSummary._muted,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              color: valueColor,
              fontWeight: FontWeight.w600,
              fontSize: valueSize,
            ),
          ),
        ),
      ],
    );
  }
}

class _OtcDetailsActions extends StatelessWidget {
  const _OtcDetailsActions({this.accepted = false, this.preparing = false});

  final bool accepted;
  final bool preparing;

  static const Color _orange = Color(0xFFFF5722);

  @override
  Widget build(BuildContext context) {
    final prepare = SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          preparing
              ? 'Mark as Ready'
              : accepted
              ? 'Prepare Order'
              : 'Accept Order',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: accepted || preparing
          ? SizedBox(width: double.infinity, child: prepare)
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => showPharmacyRejectOrderSheet(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A1A1A),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Reject',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: prepare),
              ],
            ),
    );
  }
}
