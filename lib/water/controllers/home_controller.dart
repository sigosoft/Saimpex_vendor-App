import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/water/models/home_order.dart';

class WaterHomeController extends GetxController {
  final isStoreOpen = true.obs;
  final selectedTabIndex = 0.obs;
  final selectedFilterIndex = 0.obs;
  final bottomNavIndex = 0.obs;
  final searchController = TextEditingController();

  final filters = const ['New Orders', 'Accepted', 'Preparing', 'Ready'];

  final orders = <HomeOrder>[
    const HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
    ),
    const HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Self Pickup',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Cash on Delivery',
      isDelivery: false,
      isOnlinePayment: false,
    ),
    const HomeOrder(
      customerName: 'Ahmed',
      orderType: 'Delivery',
      orderId: '#22789007',
      timeAgo: '2 min ago',
      itemLabel: '1 Bottle (19L) • 80 MRU',
      paymentLabel: 'Online Payment',
      isDelivery: true,
      isOnlinePayment: true,
    ),
    const HomeOrder(
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
    ),
  ].obs;

  void toggleStore(bool value) => isStoreOpen.value = value;
  void selectTab(int index) => selectedTabIndex.value = index;
  void selectFilter(int index) => selectedFilterIndex.value = index;
  void changeBottomNav(int index) => bottomNavIndex.value = index;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
