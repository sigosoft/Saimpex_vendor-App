import 'package:get/get.dart';

class WaterEarningsController extends GetxController {
  static const filters = ['All', 'Available', 'Pending', 'Cancelled'];

  int tabIndex = 0;
  int filterIndex = 0;

  void selectTab(int index) {
    tabIndex = index;
    update();
  }

  void selectFilter(int index) {
    filterIndex = index;
    update();
  }
}
