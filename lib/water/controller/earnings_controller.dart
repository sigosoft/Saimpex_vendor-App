import 'package:get/get.dart';
import 'package:saimpex_vendor/generated/l10n.dart';

class WaterEarningsController extends GetxController {
  static List<String> get filters => [
        S.current.all,
        S.current.available,
        S.current.pending,
        S.current.cancelled,
      ];

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
