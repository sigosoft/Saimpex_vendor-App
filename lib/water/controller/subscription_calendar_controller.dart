import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/generated/l10n.dart';

class WaterSubscriptionCalendarController extends GetxController {
  final searchController = TextEditingController();
  int selectedDayIndex = 2;
  int selectedFilterIndex = 0;

  // Labels are index-based (selectedFilterIndex); localised at read time.
  List<String> get filters => [
        S.current.all,
        S.current.waterMorning,
        S.current.waterAfternoon,
        S.current.waterEvening,
        S.current.activeLabel,
      ];

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
