import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PharmacyHomeController extends GetxController {
  bool isStoreOpen = true;
  int selectedOrderType = 0;
  int selectedFilterIndex = 0;
  int bottomNavIndex = 0;
  final searchController = TextEditingController();

  final prescriptionFilters = const [
    'New Orders',
    'Under Review',
    'Review Completed',
    'Awaiting Payment',
    'To Prepare',
    'Preparing',
    'Ready',
    'Delivered',
  ];

  final otcFilters = const [
    'New Orders',
    'Preparing',
    'Ready',
  ];

  bool get isOtcTab => selectedOrderType == 1;

  List<String> get activeFilters =>
      isOtcTab ? otcFilters : prescriptionFilters;

  String get filterBadgeLabel {
    if (isOtcTab) {
      return selectedFilterIndex == 0 ? '02' : '';
    }
    return switch (selectedFilterIndex) {
      0 => '04',
      1 || 2 || 3 || 4 || 5 || 6 || 7 => '02',
      _ => '',
    };
  }

  void selectOrderType(int index) {
    selectedOrderType = index;
    selectedFilterIndex = 0;
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

  void onBottomNavSelect(int index) {
    if (index == bottomNavIndex) return;
    bottomNavIndex = index;
    if (index == 1) {
      selectedOrderType = 0;
      selectedFilterIndex = 0;
    }
    update();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
