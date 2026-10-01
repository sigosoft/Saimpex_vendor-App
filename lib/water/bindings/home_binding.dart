import 'package:get/get.dart';
import 'package:saimpex_vendor/water/controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WaterHomeController>()) {
      Get.put<WaterHomeController>(WaterHomeController(), permanent: true);
    }
  }
}
