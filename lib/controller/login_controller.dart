import 'package:country_picker/country_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/login_model.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';
import 'package:saimpex_vendor/utils/vendor_app_type.dart';
import '../Utils/Utils.dart';
import '../view/otp/otp.dart';

class LoginController extends GetxController {
  final FlutterLocalization localization = FlutterLocalization.instance;
  Country selectedCountry = Country.parse('MR');
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  VendorAppType selectedAppType = VendorAppType.groceryRestaurant;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  void setSelectedAppType(VendorAppType? type) {
    if (type == null) return;
    selectedAppType = type;
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> sendOtp(
    BuildContext context,
    String countryCode,
    String mobile,
    String route,
  ) async {
    try {
      showLoadingDialog(context);
      if (context.mounted) {
        Get.back();
      }
      update();
      if (route == "login") {
        if (context.mounted) {
          Get.to(Otp(country_code: countryCode, mobile: mobile));
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("Login Error: $error");
    }
  }

  Future<void> Login(
    BuildContext context,
    String userName,
    String password,
  ) async {
    // Water and Home Cleaning are UI-design only for now: skip API validation.
    // Grocery, Restaurant, and Pharmacy use the authenticated login flow.
    if (selectedAppType == VendorAppType.water ||
        selectedAppType == VendorAppType.homeCleaning) {
      await savename(VendorAppRouter.storageKey, selectedAppType.storageValue);
      await savename("loginStatus", "true");
      await VendorAppRouter.goToSelectedApp(type: selectedAppType);
      return;
    }

    try {
      showLoadingDialog(context);
      String? fcm_token;
      try {
        fcm_token = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        // Retry after few seconds
        await Future.delayed(Duration(seconds: 2));
      }
      final response = await DioClient().post(
        ApiEndPoints.login,
        body: {"username": userName, "password": password,  "fcm": fcm_token,},
      );
      LoginModel loginModel = LoginModel.fromJson(response.data);
      Get.back();
      update();
      if (loginModel.status == true) {
        final authToken = loginModel.data?.details?.token ?? "";
        await savename("username", userName);
        await savename("password", password);
        await savename("token", authToken);
        if (authToken.isNotEmpty) {
          DioClient().updateToken(authToken);
        }
        await savename("loginStatus", loginModel.status?.toString() ?? "false");
        await savename("name", loginModel.data?.details?.name ?? "");
        await savename("roleId", loginModel.data?.details?.roleId ?? 0);
        await savename("vendorType", loginModel.data?.details?.vendorType.toString() ?? "0");
        await savename("vendorId", loginModel.data?.details?.vendorId ?? 0);
        await savename("userId", loginModel.data?.details?.id ?? 0);
        await savename(
          VendorAppRouter.storageKey,
          selectedAppType.storageValue,
        );
        final languageCode = localization.currentLocale?.languageCode;
        final message = loginModel.message;
        final toastMessage = languageCode == "fr"
            ? (message?.messageFr?.isNotEmpty == true
                  ? message!.messageFr!.first
                  : null)
            : languageCode == "ar"
            ? (message?.messageAr?.isNotEmpty == true
                  ? message!.messageAr!.first
                  : null)
            : (message?.messageEn?.isNotEmpty == true
                  ? message!.messageEn!.first
                  : null);

        showToast(context, toastMessage ?? "Login successful");
        await VendorAppRouter.goToSelectedApp(type: selectedAppType);
      }
    } catch (error) {
      Get.back();
      print("Login Error: $error");
      showToast(context, error.toString());
    }
  }
}
