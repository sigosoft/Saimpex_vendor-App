import 'package:flutter/cupertino.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/model/OrderStatusModel.dart' as order;
import 'package:saimpex_vendor/controller/home_controller.dart';
import 'package:saimpex_vendor/utils/printing/order_print_service.dart';

import '../configs/ApiConfigs.dart';
import '../configs/Dioclient.dart';
import '../generated/l10n.dart';
import '../model/OrderDetailsModel.dart';
import '../utils/utils.dart';
import '../utils/widgets/success_dialog.dart';
import '../view/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailsController extends GetxController {
  final FlutterLocalization localization = FlutterLocalization.instance;
  bool isLoading = false;
  Data? orderData;

  /// 0 = Order Overview (timeline), 1 = Order Duration Breakdown
  int selectedOrderTabIndex = 0;
  List<({String label, String value})> durationBreakdownItems = [];

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getRestaurantOrderDetails(
    BuildContext context,
    String order_id,
  ) async {
    try {
      print(order_id);
      isLoading = true;
      update();
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.restaurantOrderDetails,
        query: {"order_id": order_id},
      );

      if (response.data?['status'].toString() == "true") {
        final orderDetailsModel = OrderDetailsModel.fromJson(response.data);
        if (orderDetailsModel.status.toString() == "true") {
          orderData = orderDetailsModel.data;
          final d = orderData!.orderDurations;
          durationBreakdownItems = [
            (
              label: 'Restaurant acceptance time',
              value: formatDurationToMinutes(
                d?.restaurantAcceptanceDuration?.toString(),
              ),
            ),
            (
              label: 'Prepare food Duration',
              value: formatDurationToMinutes(
                d?.preparationDuration?.toString(),
              ),
            ),
            (
              label: 'Delivery/Pickup to Restaurant',
              value: formatDurationToMinutes(
                d?.deliveryPartnerToRestaurantDuration?.toString(),
              ),
            ),
            (
              label: 'Pickup/Wait Duration',
              value: formatDurationToMinutes(d?.pickupWaitDuration?.toString()),
            ),
            (
              label: 'Restaurant to Customer Duration',
              value: formatDurationToMinutes(
                d?.restaurantToCustomerDuration?.toString(),
              ),
            ),
          ];
        }
      }
    } catch (error, stackTrace) {
      debugPrint("stackTrace: $stackTrace");
      debugPrint("getOrderDetails Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getGroceryOrderDetails(
    BuildContext context,
    String order_id,
  ) async {
    try {
      isLoading = true;
      update();
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.groceryOrderDetails,
        query: {"order_id": order_id},
      );
      if (response.data?['status'].toString() == "true") {
        final orderDetailsModel = OrderDetailsModel.fromJson(response.data);
        if (orderDetailsModel.status.toString() == "true") {
          orderData = orderDetailsModel.data;
          final d = orderData!.orderDurations;
          durationBreakdownItems = [
            (
              label: 'Restaurant acceptance time',
              value: formatDurationToMinutes(
                d?.restaurantAcceptanceDuration?.toString(),
              ),
            ),
            (
              label: 'Prepare food Duration',
              value: formatDurationToMinutes(
                d?.preparationDuration?.toString(),
              ),
            ),
            (
              label: 'Delivery/Pickup to Restaurant',
              value: formatDurationToMinutes(
                d?.deliveryPartnerToRestaurantDuration?.toString(),
              ),
            ),
            (
              label: 'Pickup/Wait Duration',
              value: formatDurationToMinutes(d?.pickupWaitDuration?.toString()),
            ),
            (
              label: 'Restaurant to Customer Duration',
              value: formatDurationToMinutes(
                d?.restaurantToCustomerDuration?.toString(),
              ),
            ),
          ];
        }
      }
    } catch (error, stackTrace) {
      debugPrint("stackTrace: $stackTrace");
      debugPrint("getOrderDetails Error grocery: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> acceptRestaurantOrder(
    BuildContext context,
    String orderid, {
    bool printAfter = false,
  }) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.acceptRestaurantOrder,
        query: {"order_id": orderid},
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        if (printAfter) {
          try {
            await OrderPrintService().printOrder(
              orderId: orderid,
              orderType: "restaurant",
            );
          } catch (e) {
            debugPrint("Print error: $e");
          }
        }
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showSuccessDialog(orderStatusModel.message.toString());
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> acceptGroceryOrder(
    BuildContext context,
    String orderid, {
    bool printAfter = false,
  }) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.acceptGroceryOrder,
        query: {"order_id": orderid},
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        if (printAfter) {
          try {
            await OrderPrintService().printOrder(
              orderId: orderid,
              orderType: "grocery",
            );
          } catch (e) {
            debugPrint("Print error: $e");
          }
        }
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showSuccessDialog(orderStatusModel.message.toString());
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error grocery: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> cancelRestaurantOrder(
    BuildContext context,
    String orderid,
  ) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.cancelRestaurantOrder,
        query: {"order_id": orderid},
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showToast(context, orderStatusModel.message.toString());
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> cancelGroceryOrder(BuildContext context, String orderid) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.cancelGroceryOrder,
        query: {"order_id": orderid},
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showToast(context, orderStatusModel.message.toString());
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> markAsReadyRestaurantOrder(
    BuildContext context,
    String orderid,
  ) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.markAsReadyRestaurantOrder,
        query: {"order_id": orderid},
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showSuccessDialog(orderStatusModel.message.toString());
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> markAsReadyGroceryOrder(
    BuildContext context,
    String orderid,
  ) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.markAsReadyGroceryOrder,
        query: {"order_id": orderid},
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showSuccessDialog(orderStatusModel.message.toString());
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> prepareRestaurantOrder(
    BuildContext context,
    String orderid,
  ) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.prepareRestaurantOrder,
        query: {"order_id": orderid},
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showToast(context, orderStatusModel.message.toString());
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> prepareGroceryOrder(BuildContext context, String orderid) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.prepareGroceryOrder,
        query: {"order_id": orderid},
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showToast(context, orderStatusModel.message.toString());
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }
}
