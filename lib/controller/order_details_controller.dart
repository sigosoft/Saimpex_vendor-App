import 'package:flutter/cupertino.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
              label: S.current.durationAcceptanceTime,
              value: formatDurationToMinutes(
                d?.restaurantAcceptanceDuration?.toString(),
              ),
            ),
            (
              label: S.current.durationPreparation,
              value: formatDurationToMinutes(
                d?.preparationDuration?.toString(),
              ),
            ),
            (
              label: S.current.durationPartnerToRestaurant,
              value: formatDurationToMinutes(
                d?.deliveryPartnerToRestaurantDuration?.toString(),
              ),
            ),
            (
              label: S.current.durationPickupWait,
              value: formatDurationToMinutes(d?.pickupWaitDuration?.toString()),
            ),
            (
              label: S.current.durationToCustomer,
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
        await clearPrefsKeepLanguage(prefs);
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
              label: S.current.durationAcceptanceTime,
              value: formatDurationToMinutes(
                d?.restaurantAcceptanceDuration?.toString(),
              ),
            ),
            (
              label: S.current.durationPreparation,
              value: formatDurationToMinutes(
                d?.preparationDuration?.toString(),
              ),
            ),
            (
              label: S.current.durationPartnerToRestaurant,
              value: formatDurationToMinutes(
                d?.deliveryPartnerToRestaurantDuration?.toString(),
              ),
            ),
            (
              label: S.current.durationPickupWait,
              value: formatDurationToMinutes(d?.pickupWaitDuration?.toString()),
            ),
            (
              label: S.current.durationToCustomer,
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
        await clearPrefsKeepLanguage(prefs);
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

  /// Accept is instant on screen (test day V-B5): the server takes 8–20 s to
  /// answer, so the card leaves the list and the screen closes straight away,
  /// and the request runs behind. If the server refuses, the card comes back
  /// and the home list reloads. Printing still waits for the server.
  Future<bool> _acceptOrder(
    BuildContext context,
    String orderid,
    String endpoint,
    String orderType,
    bool printAfter,
  ) async {
    HomeController? homeCtrl;
    int removedAt = -1;
    dynamic removed;
    try {
      homeCtrl = Get.find<HomeController>();
      final list = homeCtrl.homeData?.data?.orders?.data;
      removedAt = list?.indexWhere((e) => e.id.toString() == orderid) ?? -1;
      if (removedAt >= 0) {
        removed = list!.removeAt(removedAt);
        homeCtrl.update();
      }
    } catch (_) {}
    if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
      Get.until((route) => route.isFirst);
    }

    String? failure;
    try {
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        endpoint,
        query: {"order_id": orderid},
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        // Figma success popup; the toast did not show on Android 16 (VA-04).
        showSuccessDialog(S.current.orderAcceptedSuccessfully);
        // Home re-reads the list and every tab badge: after Accept on the
        // order details screen, "Pending 01" stayed (phone check 7 Nov,
        // ORD-001549). The home card's Accept reloads on its own.
        homeCtrl?.triggerFullRefresh();
        if (printAfter) {
          OrderPrintService()
              .printOrder(orderId: orderid, orderType: orderType)
              .catchError((e) => debugPrint("Print error: $e"));
        }
        return true;
      }
      failure = S.current.somethingWentWrong;
    } catch (error, stackTrace) {
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error $orderType: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await clearPrefsKeepLanguage(prefs);
        _toast(S.current.youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
        return false;
      }
      failure = error.toString();
    }

    // Refused: put the card back where it was, then reload the real list.
    try {
      final list = homeCtrl?.homeData?.data?.orders?.data;
      if (removed != null &&
          list != null &&
          !list.any((e) => e.id.toString() == orderid)) {
        list.insert(removedAt.clamp(0, list.length), removed);
      }
      homeCtrl?.update();
      homeCtrl?.triggerFullRefresh();
    } catch (_) {}
    _toast(failure);
    return false;
  }

  void _toast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF000000),
      textColor: const Color(0xFFFFFFFF),
    );
  }

  /// Returns true when the server accepted the order.
  Future<bool> acceptRestaurantOrder(
    BuildContext context,
    String orderid, {
    bool printAfter = false,
  }) => _acceptOrder(
    context,
    orderid,
    ApiEndPoints.acceptRestaurantOrder,
    "restaurant",
    printAfter,
  );

  /// Returns true when the server accepted the order.
  Future<bool> acceptGroceryOrder(
    BuildContext context,
    String orderid, {
    bool printAfter = false,
  }) => _acceptOrder(
    context,
    orderid,
    ApiEndPoints.acceptGroceryOrder,
    "grocery",
    printAfter,
  );

  Future<void> cancelRestaurantOrder(
    BuildContext context,
    String orderid, {
    String? reason,
  }) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.cancelRestaurantOrder,
        query: {
          "order_id": orderid,
          // The reject reason was picked but never sent; the server keeps it
          // and shows it to the customer (VendorRejection `reason`).
          if (reason != null && reason.trim().isNotEmpty)
            "reason": reason.trim(),
        },
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showToast(context, S.current.waterOrderCancelledSuccessfully);
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
          // Reload from the server so the lists show what was really saved
          // (VA-05: an order looked Ready but stayed Preparing).
          homeCtrl.triggerFullRefresh();
        } catch (_) {}
      } else {
        // The server refused: close the loader and say so (it stayed open
        // with no message).
        Get.back();
        showToast(context, S.current.somethingWentWrong);
        try {
          Get.find<HomeController>().triggerFullRefresh();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await clearPrefsKeepLanguage(prefs);
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> cancelGroceryOrder(
    BuildContext context,
    String orderid, {
    String? reason,
  }) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.cancelGroceryOrder,
        query: {
          "order_id": orderid,
          if (reason != null && reason.trim().isNotEmpty)
            "reason": reason.trim(),
        },
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showToast(context, S.current.waterOrderCancelledSuccessfully);
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
          // Reload from the server so the lists show what was really saved
          // (VA-05: an order looked Ready but stayed Preparing).
          homeCtrl.triggerFullRefresh();
        } catch (_) {}
      } else {
        // The server refused: close the loader and say so (it stayed open
        // with no message).
        Get.back();
        showToast(context, S.current.somethingWentWrong);
        try {
          Get.find<HomeController>().triggerFullRefresh();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await clearPrefsKeepLanguage(prefs);
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
        showSuccessDialog(S.current.orderMarkedReadySuccessfully);
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
          // Reload from the server so the lists show what was really saved
          // (VA-05: an order looked Ready but stayed Preparing).
          homeCtrl.triggerFullRefresh();
        } catch (_) {}
      } else {
        // The server refused: close the loader and say so (it stayed open
        // with no message).
        Get.back();
        showToast(context, S.current.somethingWentWrong);
        try {
          Get.find<HomeController>().triggerFullRefresh();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await clearPrefsKeepLanguage(prefs);
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(() => const LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> markSelfPickupCompleted(
    BuildContext context,
    String orderId,
  ) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.markSelfPickupCompleted,
        query: {"order_id": orderId},
      );
      order.OrderStatusModel orderStatusModel = order.OrderStatusModel.fromJson(
        response.data,
      );
      if (orderStatusModel.status.toString() == "true") {
        Get.back();
        if (Get.currentRoute != '/' && Get.previousRoute.isNotEmpty) {
          Get.until((route) => route.isFirst);
        }
        showSuccessDialog(S.current.orderMarkedPickedUpSuccessfully);
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderId,
          );
          homeCtrl.update();
          // Reload from the server so the lists show what was really saved
          // (VA-05: an order looked Ready but stayed Preparing).
          homeCtrl.triggerFullRefresh();
        } catch (_) {}
      } else {
        // The server refused: close the loader and say so (it stayed open
        // with no message).
        Get.back();
        showToast(context, S.current.somethingWentWrong);
        try {
          Get.find<HomeController>().triggerFullRefresh();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("markSelfPickupCompleted Error: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await clearPrefsKeepLanguage(prefs);
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
        showSuccessDialog(S.current.orderMarkedReadySuccessfully);
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
          // Reload from the server so the lists show what was really saved
          // (VA-05: an order looked Ready but stayed Preparing).
          homeCtrl.triggerFullRefresh();
        } catch (_) {}
      } else {
        // The server refused: close the loader and say so (it stayed open
        // with no message).
        Get.back();
        showToast(context, S.current.somethingWentWrong);
        try {
          Get.find<HomeController>().triggerFullRefresh();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await clearPrefsKeepLanguage(prefs);
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
        showSuccessDialog(S.current.orderPreparationStartedSuccessfully);
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
          // Reload from the server so the lists show what was really saved
          // (VA-05: an order looked Ready but stayed Preparing).
          homeCtrl.triggerFullRefresh();
        } catch (_) {}
      } else {
        // The server refused: close the loader and say so (it stayed open
        // with no message).
        Get.back();
        showToast(context, S.current.somethingWentWrong);
        try {
          Get.find<HomeController>().triggerFullRefresh();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await clearPrefsKeepLanguage(prefs);
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
        showSuccessDialog(S.current.orderPreparationStartedSuccessfully);
        try {
          final homeCtrl = Get.find<HomeController>();
          homeCtrl.homeData?.data?.orders?.data?.removeWhere(
            (element) => element.id.toString() == orderid,
          );
          homeCtrl.update();
          // Reload from the server so the lists show what was really saved
          // (VA-05: an order looked Ready but stayed Preparing).
          homeCtrl.triggerFullRefresh();
        } catch (_) {}
      } else {
        // The server refused: close the loader and say so (it stayed open
        // with no message).
        Get.back();
        showToast(context, S.current.somethingWentWrong);
        try {
          Get.find<HomeController>().triggerFullRefresh();
        } catch (_) {}
      }
    } catch (error, stackTrace) {
      Get.back();
      debugPrint("stackTrace: $stackTrace");
      debugPrint("accept order Error restaurant: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await clearPrefsKeepLanguage(prefs);
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }
}
