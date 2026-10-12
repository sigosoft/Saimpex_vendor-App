import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/delivery_boys_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class DeliveryBoysController extends GetxController {
  bool isLoading = false;
  List<DeliveryBoy> deliveryBoysList = [];
  List<DeliveryBoy> filteredList = [];

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getDeliveryBoys({bool isPharmacy = false}) async {
    try {
      isLoading = true;
      update();

      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }

      final endpoint = isPharmacy
          ? ApiEndPoints.pharmacyDeliveryBoys
          : ApiEndPoints.deliveryBoys;

      final response = await DioClient().get(
        endpoint,
        query: {"limit": 10},
      );

      DeliveryBoysModel model = DeliveryBoysModel.fromJson(response.data);
      if (model.status == true && model.data?.deliveryStaffs?.data != null) {
        deliveryBoysList = model.data!.deliveryStaffs!.data!;
        filteredList = deliveryBoysList;
      }
    } catch (error) {
      debugPrint("getDeliveryBoys Error: $error");
    } finally {
      isLoading = false;
      update();
    }
  }

  void filterBoys(String query) {
    if (query.isEmpty) {
      filteredList = deliveryBoysList;
    } else {
      filteredList = deliveryBoysList.where((boy) {
        final nameMatches =
            boy.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final phoneMatches = boy.mobile?.contains(query) ?? false;
        return nameMatches || phoneMatches;
      }).toList();
    }
    update();
  }
}
