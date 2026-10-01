import 'package:get/get.dart';

class WaterInventoryDetailsController extends GetxController {
  bool returnableBottle = true;

  void setReturnableBottle(bool value) {
    returnableBottle = value;
    update();
  }
}
