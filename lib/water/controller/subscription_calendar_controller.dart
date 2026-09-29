import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class WaterSubscriptionCalendarController extends GetxController {
  final searchController = TextEditingController();
  int selectedDayIndex = 2;
  int selectedFilterIndex = 0;

  final filters = const ['All', 'Morning', 'Afternoon', 'Evening', 'Active'];

  void selectDay(int index) {
    selectedDayIndex = index;
    update();
  }

  void selectFilter(int index) {
    selectedFilterIndex = index;
    update();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
