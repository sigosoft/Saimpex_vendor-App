import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/models/home_order.dart';
import 'package:saimpex_vendor/water/views/account/account_view.dart';
import 'package:saimpex_vendor/water/views/chat/chat_view.dart';
import 'package:saimpex_vendor/water/views/chat/messages_list_view.dart';
import 'package:saimpex_vendor/water/views/home/pause_subscription_sheet.dart';
import 'package:saimpex_vendor/water/views/home/reject_order_sheet.dart';
import 'package:saimpex_vendor/water/views/inventory/inventory_view.dart';
import 'package:saimpex_vendor/water/views/notifications/notifications_view.dart';
import 'package:saimpex_vendor/water/views/order_details/order_details_view.dart';
import 'package:saimpex_vendor/water/views/subscription_calendar/subscription_calendar_view.dart';
import 'package:saimpex_vendor/water/views/subscription_details/subscription_details_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isStoreOpen = true;
  int selectedTabIndex = 0;
  int selectedFilterIndex = 0;
  int bottomNavIndex = 0;
  final searchController = TextEditingController();

  final filters = const [
    'New Orders',
    'Accepted',
    'Preparing',
    'Ready',
    'Delivered',
    'Cancelled',
  ];

  final subscriptionFilters = const [
    'New Orders',
    'Active',
    'Paused',
    'Cancelled',
  ];

  final orders = const <HomeOrder>[
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
      status: HomeOrderStatus.newOrder,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Self Pickup',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Cash on Delivery',
      isDelivery: false,
      isOnlinePayment: false,
      status: HomeOrderStatus.newOrder,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
      status: HomeOrderStatus.newOrder,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
      isScheduled: true,
      scheduleDate: '15 Aug 2026',
      scheduleTime: '6:00 - 7:00 PM',
      status: HomeOrderStatus.newOrder,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) - 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
      status: HomeOrderStatus.accepted,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Self Pickup',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) - 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: false,
      isOnlinePayment: true,
      status: HomeOrderStatus.accepted,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) - 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
      status: HomeOrderStatus.preparing,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Self Pickup',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) - 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: false,
      isOnlinePayment: true,
      status: HomeOrderStatus.preparing,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) - 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
      status: HomeOrderStatus.ready,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) - 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
      deliveryPartnerName: 'Mohamed Abdallahi',
      status: HomeOrderStatus.ready,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Self Pickup',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) - 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: false,
      isOnlinePayment: true,
      status: HomeOrderStatus.ready,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
      status: HomeOrderStatus.delivered,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Self Pickup',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: false,
      isOnlinePayment: true,
      status: HomeOrderStatus.delivered,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789008',
      timeAgo: '1 hr ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
      status: HomeOrderStatus.cancelled,
    ),
    HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Self Pickup',
      orderId: '#22789009',
      timeAgo: '3 hr ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Cash on Delivery',
      isDelivery: false,
      isOnlinePayment: false,
      status: HomeOrderStatus.cancelled,
    ),
  ];

  final subscriptionOrders = const <SubscriptionOrder>[
    SubscriptionOrder(
      customerName: 'Mariem Mint Sidi',
      productLabel: 'Drinking Water 19L • x1',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      isDelivery: true,
      planName: 'Daily',
      planRange: 'Start Jul-22-2026 - End Aug-22-2026',
      timeSlot: '8-10 AM',
      estimatedValue: '5,000 MRU',
      nextDelivery: 'Tomorrow',
      status: SubscriptionOrderStatus.newOrder,
    ),
    SubscriptionOrder(
      customerName: 'Mariem Mint Sidi',
      productLabel: 'Drinking Water 19L • x1',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      isDelivery: false,
      planName: 'Daily',
      planRange: 'Start Jul-22-2026 - End Aug-22-2026',
      timeSlot: '8-10 AM',
      estimatedValue: '5,000 MRU',
      nextDelivery: 'Tomorrow',
      status: SubscriptionOrderStatus.newOrder,
    ),
    SubscriptionOrder(
      customerName: 'Mariem Mint Sidi',
      productLabel: 'Drinking Water 19L • x1',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      isDelivery: true,
      planName: 'Daily',
      planRange: 'Start Jul-22-2026 - End Aug-22-2026',
      timeSlot: '8-10 AM',
      estimatedValue: '5,000 MRU',
      nextDelivery: 'Tomorrow',
      status: SubscriptionOrderStatus.active,
    ),
    SubscriptionOrder(
      customerName: 'Mariem Mint Sidi',
      productLabel: 'Drinking Water 19L ×1',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      isDelivery: true,
      planName: 'Daily',
      planRange: 'Start Jul-22-2026 - End Aug-22-2026',
      timeSlot: '8-10 AM',
      estimatedValue: '5,000 MRU',
      pausedOn: 'Jul-24-2026 - 10:30 AM',
      pauseReason: 'Paused by Customer',
      pausedByVendor: false,
      status: SubscriptionOrderStatus.paused,
    ),
    SubscriptionOrder(
      customerName: 'Mariem Mint Sidi',
      productLabel: 'Drinking Water 19L ×1',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      isDelivery: true,
      planName: 'Daily',
      planRange: 'Start Jul-22-2026 - End Aug-22-2026',
      timeSlot: '8-10 AM',
      estimatedValue: '5,000 MRU',
      pausedOn: 'Jul-24-2026 • 10:30 AM',
      pauseReason: 'Out of Stock',
      pausedByVendor: true,
      status: SubscriptionOrderStatus.paused,
    ),
    SubscriptionOrder(
      customerName: 'Mariem Mint Sidi',
      productLabel: 'Drinking Water 19L ×1',
      orderId: '#22789010',
      timeAgo: '1 day ago',
      isDelivery: true,
      planName: 'Daily',
      planRange: 'Start Jul-01-2026 - End Jul-31-2026',
      timeSlot: '8-10 AM',
      estimatedValue: '5,000 MRU',
      status: SubscriptionOrderStatus.cancelled,
    ),
  ];

  bool get isSubscriptionTab => selectedTabIndex == 1;

  List<String> get activeFilters =>
      isSubscriptionTab ? subscriptionFilters : filters;

  List<HomeOrder> get filteredOrders {
    final index = selectedFilterIndex.clamp(0, filters.length - 1);
    final status = switch (index) {
      0 => HomeOrderStatus.newOrder,
      1 => HomeOrderStatus.accepted,
      2 => HomeOrderStatus.preparing,
      3 => HomeOrderStatus.ready,
      4 => HomeOrderStatus.delivered,
      5 => HomeOrderStatus.cancelled,
      _ => HomeOrderStatus.newOrder,
    };
    return orders.where((o) => o.status == status).toList();
  }

  List<SubscriptionOrder> get filteredSubscriptionOrders {
    final index =
        selectedFilterIndex.clamp(0, subscriptionFilters.length - 1);
    final status = switch (index) {
      0 => SubscriptionOrderStatus.newOrder,
      1 => SubscriptionOrderStatus.active,
      2 => SubscriptionOrderStatus.paused,
      3 => SubscriptionOrderStatus.cancelled,
      _ => SubscriptionOrderStatus.newOrder,
    };
    return subscriptionOrders.where((o) => o.status == status).toList();
  }

  void _selectOrderType(int index) {
    setState(() {
      selectedTabIndex = index;
      selectedFilterIndex = 0;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onBottomNavSelect(int index) {
    if (index == bottomNavIndex) return;
    setState(() {
      bottomNavIndex = index;
      if (index == 1) {
        // Orders screen is one-time orders only (matches design).
        selectedTabIndex = 0;
        selectedFilterIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundBottom,
        body: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                reverseDuration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (child, animation) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  );
                  final slide = Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved);
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: slide,
                      child: child,
                    ),
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(bottomNavIndex),
                  child: switch (bottomNavIndex) {
                    0 => _buildHomeTab(context),
                    1 => _buildOrdersTab(context),
                    2 => const MessagesListView(embedded: true),
                    3 => const InventoryView(embedded: true),
                    _ => const AccountView(embedded: true),
                  },
                ),
              ),
            ),
            _BottomNav(
              selectedIndex: bottomNavIndex,
              onSelect: _onBottomNavSelect,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: AppColors.languageChip,
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          child: const _Header(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StoreStatusCard(
                isOpen: isStoreOpen,
                onToggle: (v) => setState(() => isStoreOpen = v),
              ),
              const SizedBox(height: 12),
              const _MetricsGrid(),
              const SizedBox(height: 16),
              const _TotalsRow(),
              const SizedBox(height: 18),
              _OrdersHeader(
                onSeeAll: () => _onBottomNavSelect(1),
              ),
              const SizedBox(height: 12),
              if (isSubscriptionTab || selectedFilterIndex == 0) ...[
                _OrderTypeTabs(
                  selectedIndex: selectedTabIndex,
                  onSelect: _selectOrderType,
                ),
                const SizedBox(height: 14),
              ],
              _SearchBlock(
                controller: searchController,
                showSubscriptionCalendar:
                    !isSubscriptionTab && selectedFilterIndex == 0,
              ),
              const SizedBox(height: 12),
              _StatusFilters(
                filters: activeFilters,
                selectedIndex:
                    selectedFilterIndex.clamp(0, activeFilters.length - 1),
                onSelect: (i) => setState(() => selectedFilterIndex = i),
                badgeLabel: _filterBadgeLabel,
              ),
              const SizedBox(height: 12),
              if (isSubscriptionTab)
                if (filteredSubscriptionOrders.isEmpty)
                  const _EmptyOrders(message: 'No subscription orders here')
                else
                  for (final order
                      in filteredSubscriptionOrders.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubscriptionOrderCard(order: order),
                    )
              else if (filteredOrders.isEmpty)
                const _EmptyOrders(message: 'No orders here')
              else
                for (final order in filteredOrders.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OrderCard(order: order),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  String get _filterBadgeLabel {
    final count = isSubscriptionTab
        ? filteredSubscriptionOrders.length
        : filteredOrders.length;
    return count.toString().padLeft(2, '0');
  }

  Widget _buildOrdersTab(BuildContext context) {
    final list = filteredOrders;
    final filterIndex =
        selectedFilterIndex.clamp(0, filters.length - 1);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundTop,
            AppColors.backgroundMid,
            Color(0xFFF7F7F7),
          ],
          stops: [0, 0.18, 1],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Orders',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => _onBottomNavSelect(0),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.orangeChipBorder,
                          ),
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
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _StatusFilters(
              filters: filters,
              selectedIndex: filterIndex,
              onSelect: (i) => setState(() => selectedFilterIndex = i),
              badgeLabel: list.length.toString().padLeft(2, '0'),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: list.isEmpty
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: _EmptyOrders(message: 'No orders here'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _OrderCard(order: list[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 36,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try another status filter above',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textHint,
              fontWeight: FontWeight.w400,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            AppAssets.homeTopIcon,
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            cacheWidth: 84,
            errorBuilder: (_, _, _) => Container(
              width: 42,
              height: 42,
              color: AppColors.primaryOrange,
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Welcome to Saimpex Vendor!',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsView(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.paymentDivider,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreStatusCard extends StatelessWidget {
  const _StoreStatusCard({required this.isOpen, required this.onToggle});

  final bool isOpen;
  final ValueChanged<bool> onToggle;

  static const Color _iconGreen = AppColors.iconGreen;
  static const Color _iconBg = AppColors.iconGreenBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              AppAssets.shopOpenIcon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.storefront_outlined,
                color: _iconGreen,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  isOpen
                      ? const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Open',
                              style: TextStyle(
                                color: _iconGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                            TextSpan(
                              text: ' • ',
                              style: TextStyle(
                                color: _iconGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Accepting orders',
                              style: TextStyle(
                                color: _iconGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        )
                      : TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Closed',
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                            TextSpan(
                              text: ' • Not accepting',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Today: 08:00 - 22:00',
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onToggle(!isOpen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isOpen
                    ? const Color(0xFFFF6B00)
                    : const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: isOpen ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
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
                label: 'New Orders',
                badgeGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF8A3D),
                    Color(0xFFFF5722),
                  ],
                ),
                countColor: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: '2',
                label: 'Subscription Orders',
                badgeColor: Color(0xFFB2DFDB),
                countColor: Color(0xFF00695C),
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
                label: 'Preparing',
                badgeColor: Color(0xFFFFB300),
                countColor: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: '2',
                label: 'Ready',
                badgeColor: Color(0xFF43A047),
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
    this.badgeColor,
    this.badgeGradient,
  });

  final String count;
  final String label;
  final Color countColor;
  final Color? badgeColor;
  final Gradient? badgeGradient;

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
              color: badgeGradient == null ? badgeColor : null,
              gradient: badgeGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: TextStyle(
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
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
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

  static const Color _labelColor = AppColors.homeLabel;
  static const Color _valueColor = AppColors.homeValue;
  static const Color _dividerColor = AppColors.homeDivider;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _TotalItem(
              title: 'ORDERS',
              value: '15',
            ),
          ),
          _Line(),
          Expanded(
            child: _TotalItem(
              title: 'COMPLETED',
              value: '2',
            ),
          ),
          _Line(),
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

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: _TotalsRow._dividerColor,
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
              const Icon(
                Icons.trending_up,
                size: 14,
                color: Color(0xFF43A047),
              ),
              const SizedBox(width: 3),
            ],
            Text(
              title,
              style: const TextStyle(
                color: _TotalsRow._labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: _TotalsRow._valueColor,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  suffix!,
                  style: const TextStyle(
                    color: _TotalsRow._labelColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ORDERS',
          style: TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.4,
          ),
        ),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              'See All',
              style: TextStyle(
                color: Color(0xFFFF5722),
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderTypeTabs extends StatelessWidget {
  const _OrderTypeTabs({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF5722),
            Color(0xFFFF8F3D),
            Color(0xFFFFC04D),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Seg(
              label: 'One-Time Orders',
              selected: selectedIndex == 0,
              badge: '1',
              onTap: () => onSelect(0),
            ),
          ),
          Expanded(
            child: _Seg(
              label: 'Subscription Orders',
              selected: selectedIndex == 1,
              badge: '1',
              onTap: () => onSelect(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? const Color(0xFF1A1A1A) : Colors.white,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (badge != null && selected)
            Positioned(
              right: 2,
              top: -3,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBlock extends StatelessWidget {
  const _SearchBlock({
    required this.controller,
    this.showSubscriptionCalendar = true,
  });

  final TextEditingController controller;
  final bool showSubscriptionCalendar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showSubscriptionCalendar)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SubscriptionCalendarView(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.calendarPurple),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 14, color: AppColors.calendarPurple),
                  SizedBox(width: 4),
                  Text(
                    'Subscription Calendar',
                    style: TextStyle(
                      color: AppColors.calendarPurple,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: 'Search by ID, name',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF8E9AAF),
                size: 22,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFE6E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFD0D5E0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({
    required this.filters,
    required this.selectedIndex,
    required this.onSelect,
    this.badgeLabel = '02',
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 4, right: 16),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          final showBadge = selected && index == 0;

          return GestureDetector(
            onTap: () => onSelect(index),
            behavior: HitTestBehavior.opaque,
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
                            colors: [
                              Color(0xFFFF5722),
                              Color(0xFFFF9800),
                              Color(0xFFFFB300),
                            ],
                          )
                        : null,
                    color: selected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: selected
                        ? null
                        : Border.all(color: const Color(0xFFE0E0E0)),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF5722)
                                  .withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF333333),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                if (showBadge)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFB300),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          color: Color(0xFFFF9800),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final HomeOrder order;

  // Matched to design screenshot
  static const Color _orange = AppColors.primaryOrange;
  static const Color _selfPickupBlue = AppColors.selfPickupBlue;
  static const Color _nameColor = AppColors.textDark;
  static const Color _metaGray = AppColors.textSecondary;
  static const Color _avatarBg = AppColors.avatarPinkAlt;
  static const Color _avatarLetter = AppColors.avatarText;
  static const Color _newBadge = AppColors.newBadge;
  static const Color _acceptedBadge = AppColors.activeGreen;
  static const Color _preparingBadge = AppColors.preparingOrange;
  static const Color _readyBadge = AppColors.activeGreen;
  static const Color _chipBg = AppColors.orangeChipBg;
  static const Color _chipBorder = AppColors.orangeChipBorder;
  static const Color _rejectBorder = AppColors.fieldBorder;
  static const Color _scheduledBg = AppColors.scheduledBg;
  static const Color _scheduledBlue = AppColors.scheduledBlue;
  static const Color _partnerBg = AppColors.partnerBg;
  static const Color _partnerPurple = AppColors.partnerPurple;

  (String, Color) get _statusBadge {
    return switch (order.status) {
      HomeOrderStatus.newOrder => ('NEW', _newBadge),
      HomeOrderStatus.accepted => ('ACCEPTED', _acceptedBadge),
      HomeOrderStatus.preparing => ('PREPARING', _preparingBadge),
      HomeOrderStatus.ready => ('READY', _readyBadge),
      HomeOrderStatus.delivered => ('DELIVERED', _readyBadge),
      HomeOrderStatus.cancelled => ('CANCELLED', AppColors.cancelledGray),
    };
  }

  String? get _primaryActionLabel {
    return switch (order.status) {
      HomeOrderStatus.accepted => 'Prepare Order',
      HomeOrderStatus.preparing => 'Mark as Ready',
      HomeOrderStatus.ready when !order.isDelivery => 'Mark as Picked Up',
      _ => null,
    };
  }

  bool get _isNewOrder => order.status == HomeOrderStatus.newOrder;
  bool get _isReady => order.status == HomeOrderStatus.ready;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OrderDetailsView(order: order),
          ),
        );
      },
      child: Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                backgroundColor: _avatarBg,
                child: Text(
                  order.customerName[0].toUpperCase(),
                  style: const TextStyle(
                    color: _avatarLetter,
                    fontWeight: FontWeight.w700,
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
                      order.customerName,
                      style: const TextStyle(
                        color: _nameColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _OrderTypeBadge(isDelivery: order.isDelivery),
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: _metaGray.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                              fontSize: 12.5,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            order.orderId,
                            style: const TextStyle(
                              color: _metaGray,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: _metaGray.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                              fontSize: 12.5,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            order.timeAgo,
                            style: const TextStyle(
                              color: _metaGray,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (_) {
                  final (label, color) = _statusBadge;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        height: 1.1,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (order.deliveryPartnerName != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _partnerBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.delivery_dining_outlined,
                    size: 16,
                    color: _partnerPurple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Assigned Delivery Partner ',
                            style: TextStyle(
                              color: _partnerPurple,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: '[${order.deliveryPartnerName}]',
                            style: const TextStyle(
                              color: _partnerPurple,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (!_isReady) ...[
                  _OrderChip(
                    icon: Icons.inventory_2_outlined,
                    label: order.itemLabel,
                  ),
                  const SizedBox(width: 8),
                ],
                _OrderChip(
                  icon: order.isOnlinePayment
                      ? Icons.payments_outlined
                      : Icons.handshake_outlined,
                  label: order.paymentLabel,
                ),
              ],
            ),
          ),
          if (order.isScheduled) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _scheduledBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: _scheduledBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'SCHEDULED',
                    style: TextStyle(
                      color: _scheduledBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: _scheduledBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.scheduleDate ?? '',
                    style: const TextStyle(
                      color: _scheduledBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: _scheduledBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.scheduleTime ?? '',
                    style: const TextStyle(
                      color: _scheduledBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_primaryActionLabel != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _orange.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _primaryActionLabel!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ] else if (_isNewOrder) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => showRejectOrderSheet(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _nameColor,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: _rejectBorder, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
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
                    height: 46,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _orange.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
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
                            fontSize: 14,
                          ),
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

class _OrderTypeBadge extends StatelessWidget {
  const _OrderTypeBadge({required this.isDelivery});

  final bool isDelivery;

  static const _metaStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 11.5,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    final color = isDelivery
        ? _OrderCard._orange
        : _OrderCard._selfPickupBlue;
    final label = isDelivery ? 'Delivery' : 'Self Pickup';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isDelivery) ...[
          Text('(', style: _metaStyle.copyWith(color: color)),
          const SizedBox(width: 2),
        ],
        _NeonAssetIcon(
          asset: isDelivery ? AppAssets.deliveryIcon : AppAssets.selfPickupIcon,
          size: 13,
          fallback: isDelivery
              ? Icons.delivery_dining_rounded
              : Icons.shopping_bag_outlined,
          fallbackColor: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          softWrap: false,
          style: _metaStyle.copyWith(color: color),
        ),
        if (!isDelivery) ...[
          const SizedBox(width: 2),
          Text(')', style: _metaStyle.copyWith(color: color)),
        ],
      ],
    );
  }
}

class _NeonAssetIcon extends StatelessWidget {
  const _NeonAssetIcon({
    required this.asset,
    required this.size,
    required this.fallback,
    required this.fallbackColor,
  });

  final String asset;
  final double size;
  final IconData fallback;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    // Keep neon line color; make solid black background transparent.
    // Equal RGB weights so orange delivery and blue self-pickup both show.
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        1, 1, 1, 0, 0,
      ]),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Icon(
          fallback,
          size: size,
          color: fallbackColor,
        ),
      ),
    );
  }
}

class _OrderChip extends StatelessWidget {
  const _OrderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _OrderCard._chipBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _OrderCard._chipBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: _OrderCard._orange),
          const SizedBox(width: 6),
          Text(
            label,
            softWrap: false,
            maxLines: 1,
            style: const TextStyle(
              color: _OrderCard._orange,
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionOrderCard extends StatelessWidget {
  const _SubscriptionOrderCard({required this.order});

  final SubscriptionOrder order;

  static const Color _orange = AppColors.primaryOrange;
  static const Color _selfPickupBlue = AppColors.selfPickupBlue;
  static const Color _nameColor = AppColors.textDark;
  static const Color _metaGray = AppColors.textSecondary;
  static const Color _avatarBg = AppColors.avatarPinkAlt;
  static const Color _avatarLetter = AppColors.avatarText;
  static const Color _newBadge = AppColors.newBadge;
  static const Color _activeBadge = AppColors.activeGreen;
  static const Color _planBg = AppColors.planPurpleAlt;
  static const Color _planPurple = AppColors.planPurple;
  static const Color _pausedAmber = AppColors.pausedAmberAlt;
  static const Color _rejectBorder = AppColors.fieldBorder;

  bool get _isActive => order.status == SubscriptionOrderStatus.active;
  bool get _isPaused => order.status == SubscriptionOrderStatus.paused;

  (String, Color) get _statusBadge {
    return switch (order.status) {
      SubscriptionOrderStatus.newOrder => ('NEW', _newBadge),
      SubscriptionOrderStatus.active => ('ACTIVE', _activeBadge),
      SubscriptionOrderStatus.paused => ('PAUSED', _orange),
      SubscriptionOrderStatus.cancelled => ('CANCELLED', AppColors.cancelledGray),
    };
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = order.isDelivery ? _orange : _selfPickupBlue;
    final (badgeLabel, badgeColor) = _statusBadge;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SubscriptionDetailsView(order: order),
          ),
        );
      },
      child: Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
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
                backgroundColor: _avatarBg,
                child: Text(
                  order.customerName[0].toUpperCase(),
                  style: const TextStyle(
                    color: _avatarLetter,
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
                      order.customerName,
                      style: const TextStyle(
                        color: _nameColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.productLabel,
                      style: const TextStyle(
                        color: _metaGray,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (!order.isDelivery) ...[
                          Text(
                            '(',
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
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
                            width: 13,
                            height: 13,
                            errorBuilder: (_, _, _) => Icon(
                              order.isDelivery
                                  ? Icons.delivery_dining
                                  : Icons.shopping_bag_outlined,
                              size: 13,
                              color: typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.isDelivery ? 'Delivery' : 'Self Pickup',
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.5,
                          ),
                        ),
                        if (!order.isDelivery) ...[
                          const SizedBox(width: 2),
                          Text(
                            ')',
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.orderId} • ${order.timeAgo}',
                      style: const TextStyle(
                        color: _metaGray,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isActive) ...[
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Next Delivery : ',
                          style: TextStyle(
                            color: _metaGray,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: order.nextDelivery ?? '',
                          style: const TextStyle(
                            color: _nameColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 14,
                  color: _planPurple,
                ),
                const SizedBox(width: 4),
                Text(
                  '${order.planName} • ${order.timeSlot}',
                  style: const TextStyle(
                    color: _planPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () =>
                          ChatView.open(context, customerName: order.customerName),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _orange,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: _orange, width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Chat With Customer',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _orange.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => showPauseSubscriptionSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pause, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Pause',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (_isPaused) ...[
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: _metaGray,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Paused on: ${order.pausedOn ?? ''}',
                    style: const TextStyle(
                      color: _metaGray,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const _OutlinedPauseIcon(
                  color: _pausedAmber,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.pauseReason ?? '',
                    style: const TextStyle(
                      color: _pausedAmber,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (order.pausedByVendor)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => ChatView.open(
                          context,
                          customerName: order.customerName,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _orange,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: _orange, width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Chat With Customer',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _orange.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, size: 20),
                              SizedBox(width: 4),
                              Text(
                                'Resume',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () =>
                      ChatView.open(context, customerName: order.customerName),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _orange,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: _orange, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Chat With Customer',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Plan :',
                  style: TextStyle(
                    color: _metaGray,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: _planBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 14,
                          color: _planPurple,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: order.planName,
                                  style: const TextStyle(
                                    color: _planPurple,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: ' - ${order.planRange}',
                                  style: TextStyle(
                                    color: _planPurple.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Time Slot :',
                  style: TextStyle(
                    color: _metaGray,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  order.timeSlot,
                  style: const TextStyle(
                    color: _nameColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  'Est. value :',
                  style: TextStyle(
                    color: _metaGray,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  order.estimatedValue,
                  style: const TextStyle(
                    color: _nameColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => showRejectOrderSheet(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _nameColor,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: _rejectBorder, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
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
                    height: 46,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _orange.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
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
                            fontSize: 14,
                          ),
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

class _OutlinedPauseIcon extends StatelessWidget {
  const _OutlinedPauseIcon({
    required this.color,
    this.size = 14,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final barWidth = size * 0.28;
    final gap = size * 0.18;

    Widget bar() {
      return Container(
        width: barWidth,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E8),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: color, width: 1.4),
        ),
      );
    }

    return SizedBox(
      width: barWidth * 2 + gap,
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          bar(),
          SizedBox(width: gap),
          bar(),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Orders', 'Chat', 'Inventory', 'Account'];
    const assetIcons = <String?>[
      null, // Home keeps Material icon
      AppAssets.ordersIcon,
      AppAssets.chatIcon,
      AppAssets.inventoryIcon,
      AppAssets.accountIcon,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(5, (index) {
              final selected = selectedIndex == index;
              final asset = assetIcons[index];
              return Expanded(
                child: InkWell(
                  onTap: () => onSelect(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: selected
                            ? Container(
                                key: const ValueKey('selected'),
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: _NavIcon(
                                  asset: asset,
                                  fallback: Icons.home_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey('idle'),
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: _NavIcon(
                                    asset: asset,
                                    fallback: Icons.home_rounded,
                                    color: AppColors.navInactive,
                                    size: asset == null ? 28 : 24,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? AppColors.primaryOrange
                              : AppColors.navInactive,
                        ),
                        child: Text(
                          labels[index],
                          textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.asset,
    required this.fallback,
    required this.color,
    required this.size,
  });

  final String? asset;
  final IconData fallback;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (asset == null) {
      return Icon(fallback, color: color, size: size);
    }

    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(
        asset!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(fallback, color: color, size: size),
      ),
    );
  }
}
