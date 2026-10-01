import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PharmacyChatController extends GetxController {
  final searchController = TextEditingController();
  String query = '';

  void onQueryChanged(String value) {
    query = value;
    update();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
