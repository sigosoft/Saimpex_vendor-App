// ignore_for_file: unnecessary_overrides
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
// import 'package:saimpex_vendor/model/grocery_orders_model.dart';
// import 'package:saimpex_vendor/model/order_details_model.dart';
import 'package:saimpex_vendor/model/restaurant_orders_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class OrdersController extends GetxController {
  final FlutterLocalization localization = FlutterLocalization.instance;
  List<RestaurantOrderItem>? restaurantOrders;
  dynamic orderDetails;
  List<dynamic>? groceryOrders;
  bool isLoading = false;
  bool _hasNextPage = true;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  final ScrollController scrollController = ScrollController();
  bool _hasNextPageGrocery = true;
  bool isFirstLoadRunningGrocery = false;
  bool isLoadMoreRunningGrocery = false;
  final ScrollController scrollControllerGrocery = ScrollController();
  bool isLoadingFoodOrderDetails = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_loadMore);
    scrollControllerGrocery.addListener(_loadMoreGrocery);
  }

  @override
  void onClose() {
    scrollController.removeListener(_loadMore);
    scrollController.dispose();
    scrollControllerGrocery.removeListener(_loadMoreGrocery);
    scrollControllerGrocery.dispose();
    super.onClose();
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.hasClients &&
        scrollController.position.extentAfter < 300) {
      isLoadMoreRunning = true;
      update();

      await Future.delayed(const Duration(seconds: 1));
      // Mock: No more pages
      _hasNextPage = false;

      isLoadMoreRunning = false;
      update();
    }
  }

  Future<void> getRestaurantOrders(BuildContext context) async {
    try {
      isFirstLoadRunning = true;
      update();
      await Future.delayed(const Duration(seconds: 1));

      // Mock data setup
      restaurantOrders = [];
      _hasNextPage = false;

      isFirstLoadRunning = false;
      update();
    } catch (error) {
      isFirstLoadRunning = false;
      update();
      debugPrint("getRestaurantOrders Mock Error: $error");
    }
  }

  void _loadMoreGrocery() async {
    if (_hasNextPageGrocery == true &&
        isFirstLoadRunningGrocery == false &&
        isLoadMoreRunningGrocery == false &&
        scrollControllerGrocery.hasClients &&
        scrollControllerGrocery.position.extentAfter < 300) {
      isLoadMoreRunningGrocery = true;
      update();

      await Future.delayed(const Duration(seconds: 1));
      // Mock: No more pages
      _hasNextPageGrocery = false;

      isLoadMoreRunningGrocery = false;
      update();
    }
  }

  Future<void> getGroceryOrders(BuildContext context) async {
    try {
      isFirstLoadRunningGrocery = true;
      update();
      await Future.delayed(const Duration(seconds: 1));

      // Mock data setup
      groceryOrders = [];
      _hasNextPageGrocery = false;

      isFirstLoadRunningGrocery = false;
      update();
    } catch (error) {
      isFirstLoadRunningGrocery = false;
      update();
      debugPrint("getGroceryOrders Mock Error: $error");
    }
  }

  Future<void> getFoodOrderDetails(BuildContext context, int orderId) async {
    try {
      isLoadingFoodOrderDetails = true;
      update();
      await Future.delayed(const Duration(seconds: 1));

      // Mock details can be set here if needed

      isLoadingFoodOrderDetails = false;
      update();
    } catch (error) {
      isLoadingFoodOrderDetails = false;
      update();
      debugPrint("getFoodOrderDetails Mock Error: $error");
    }
  }

  Future<void> cancelOrder(BuildContext context, int orderId) async {
    try {
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Get.back(); // close loading
        showToast(context, "Order cancelled successfully (Mock)");
        Get.back(); // go back
        getRestaurantOrders(context);
        getGroceryOrders(context);
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
      }
      debugPrint("cancelOrder Mock Error: $error");
    }
  }
}
