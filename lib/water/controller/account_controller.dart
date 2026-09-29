import 'package:get/get.dart';

class WaterAccountController extends GetxController {
  static const languages = ['English', 'French', 'Arabic'];

  int languageIndex = 0;
  bool notificationsEnabled = true;

  void selectLanguage(int index) {
    languageIndex = index;
    update();
  }

  void setNotifications(bool value) {
    notificationsEnabled = value;
    update();
  }
}
