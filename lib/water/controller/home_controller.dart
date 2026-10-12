import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/water/model/home_order.dart';

class WaterHomeController extends GetxController {
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

  void selectOrderType(int index) {
    selectedTabIndex = index;
    selectedFilterIndex = 0;
    update();
  }

  void onBottomNavSelect(int index) {
    if (index == bottomNavIndex) return;
    bottomNavIndex = index;
    update();
  }

  void selectFilter(int index) {
    selectedFilterIndex = index;
    update();
  }

  void toggleStore(bool value) {
    isStoreOpen = value;
    update();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
