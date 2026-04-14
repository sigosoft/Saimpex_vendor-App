import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import '../utils/utils.dart';

class CouponController extends GetxController {
  bool isLoading = false;
  List<dynamic> couponsList = [];

  Future<void> fetchCoupons() async {
    try {
      isLoading = true;
      update();

      var token = await getSavedObject("token");
      DioClient().updateToken(token ?? "");

      final String fullUrl =
          "${ApiConfigs.BASE_URL}${ApiEndPoints.coupons}?limit=10";

      // Console log request details
      debugPrint("--- [COUPONS API REQUEST] ---");
      debugPrint("URL: $fullUrl");
      debugPrint("Headers: ${DioClient().dio.options.headers}");

      final response = await DioClient().get(
        ApiEndPoints.coupons,
        query: {"limit": "10"},
      );

      // Console log response details
      debugPrint("--- [COUPONS API RESPONSE] ---");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Headers: ${response.headers}");
      debugPrint("Data: ${response.data}");

      if (response.data['status'] == true ||
          response.data['status'].toString() == 'true') {
        couponsList = response.data['data']?['coupons']?['data'] ?? [];
      }
    } catch (error) {
      debugPrint("fetchCoupons Error: $error");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> addCoupon({
    required BuildContext context,
    required String name,
    required String code,
    required int type,
    required String discountValue,
    required String count,
    required String validUpto,
  }) async {
    try {
      showLoadingDialog(context);

      var token = await getSavedObject("token");
      DioClient().updateToken(token ?? "");

      final Map<String, dynamic> body = {
        "name": name,
        "code": code,
        "type": type,
        "discount_value": discountValue,
        "count": count,
        "valid_upto": validUpto,
      };

      // Console log request
      debugPrint("--- [ADD COUPON API REQUEST] ---");
      debugPrint("URL: ${ApiConfigs.BASE_URL}${ApiEndPoints.addCoupon}");
      debugPrint("Body: $body");

      final response = await DioClient().post(
        ApiEndPoints.addCoupon,
        body: body,
      );

      // Console log response
      debugPrint("--- [ADD COUPON API RESPONSE] ---");
      debugPrint("Data: ${response.data}");

      // Close the loading dialog
      Get.back();

      final resData = response.data;
      final bool isSuccess =
          resData['status'].toString() == 'true' || resData['status'] == true;
      final String toastMessage =
          resData['message']?.toString() ??
          (isSuccess ? "Coupon added successfully" : "Failed to add coupon");

      _showResponseToast(toastMessage);

      if (isSuccess) {
        fetchCoupons(); // Refresh the list
        Get.back(); // Return to Coupons list screen
      }
    } catch (error) {
      Get.back();
      _showResponseToast(error.toString());
      debugPrint("addCoupon Error: $error");
    }
  }

  Future<void> updateCoupon({
    required BuildContext context,
    required int couponId,
    required String name,
    required String code,
    required int type,
    required String discountValue,
    required String count,
    required String validUpto,
  }) async {
    try {
      showLoadingDialog(context);

      var token = await getSavedObject("token");
      DioClient().updateToken(token ?? "");

      final Map<String, dynamic> body = {
        "coupon_id": couponId,
        "name": name,
        "code": code,
        "type": type,
        "discount_value": discountValue,
        "count": count,
        "valid_upto": validUpto,
      };

      // Console log request
      debugPrint("--- [UPDATE COUPON API REQUEST] ---");
      debugPrint("URL: ${ApiConfigs.BASE_URL}${ApiEndPoints.updateCoupon}");
      debugPrint("Body: $body");

      final response = await DioClient().post(
        ApiEndPoints.updateCoupon,
        body: body,
      );

      // Console log response
      debugPrint("--- [UPDATE COUPON API RESPONSE] ---");
      debugPrint("Data: ${response.data}");

      // Close the loading dialog
      Get.back();

      final resData = response.data;
      final bool isSuccess =
          resData['status'].toString() == 'true' || resData['status'] == true;
      final String toastMessage =
          resData['message']?.toString() ??
          (isSuccess
              ? "Coupon updated successfully"
              : "Failed to update coupon");

      _showResponseToast(toastMessage);

      if (isSuccess) {
        fetchCoupons(); // Refresh the list
        Get.back(); // Return to Coupons list screen
      }
    } catch (error) {
      Get.back();
      _showResponseToast(error.toString());
      debugPrint("updateCoupon Error: $error");
    }
  }

  Future<void> deleteCoupon({
    required BuildContext context,
    required int couponId,
  }) async {
    try {
      showLoadingDialog(context);

      var token = await getSavedObject("token");
      DioClient().updateToken(token ?? "");

      final Map<String, dynamic> body = {"coupon_id": couponId};

      // Console log request
      debugPrint("--- [DELETE COUPON API REQUEST] ---");
      debugPrint("URL: ${ApiConfigs.BASE_URL}${ApiEndPoints.deleteCoupon}");
      debugPrint("Body: $body");

      final response = await DioClient().post(
        ApiEndPoints.deleteCoupon,
        body: body,
      );

      // Console log response
      debugPrint("--- [DELETE COUPON API RESPONSE] ---");
      debugPrint("Data: ${response.data}");

      // Close the loading dialog
      Get.back();

      final resData = response.data;
      final bool isSuccess =
          resData['status'].toString() == 'true' || resData['status'] == true;
      final String toastMessage =
          resData['message']?.toString() ??
          (isSuccess
              ? "Coupon deleted successfully"
              : "Failed to delete coupon");

      _showResponseToast(toastMessage);

      if (isSuccess) {
        fetchCoupons(); // Refresh the list
      }
    } catch (error) {
      Get.back();
      _showResponseToast(error.toString());
      debugPrint("deleteCoupon Error: $error");
    }
  }

  Future<void> updateCouponStatus(
    BuildContext context,
    int couponId,
    int status,
  ) async {
    try {
      showLoadingDialog(context);

      var token = await getSavedObject("token");
      DioClient().updateToken(token ?? "");

      // Use the provided parameters in the query
      final response = await DioClient()
          .get(
            ApiEndPoints.updateCouponStatus,
            query: {
              "coupon_id": couponId.toString(),
              "status": status.toString(),
            },
          )
          .timeout(const Duration(seconds: 10));

      // Close the loading dialog
      Get.back();

      final resData = response.data;
      final bool isSuccess =
          resData['status'].toString() == 'true' || resData['status'] == true;
      final String toastMessage =
          resData['message']?.toString() ??
          (isSuccess ? "Status updated successfully" : "Operation failed");

      _showResponseToast(toastMessage);

      if (isSuccess) {
        fetchCoupons(); // Refresh the list
      }
    } catch (error) {
      Get.back();
      _showResponseToast(error.toString());
      debugPrint("updateCouponStatus Error: $error");
    } finally {
      update();
    }
  }

  void _showResponseToast(String message) {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx != null) {
      try {
        showToast(ctx, message);
      } catch (e) {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }
}
