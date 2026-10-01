import 'package:get/get.dart';

class WaterBusinessSettingsController extends GetxController {
  bool storeOpen = true;
  bool acceptingOrders = true;
  bool storeBusy = false;

  void setStoreOpen(bool value) {
    storeOpen = value;
    update();
  }

  void setAcceptingOrders(bool value) {
    acceptingOrders = value;
    update();
  }

  void setStoreBusy(bool value) {
    storeBusy = value;
    update();
  }
}
