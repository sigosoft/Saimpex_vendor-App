import 'package:get/get.dart';

class PharmacyOrderDetailsController extends GetxController {
  double rotationTurns = 0;

  void rotatePrescription() {
    rotationTurns += 0.25;
    update();
  }
}
