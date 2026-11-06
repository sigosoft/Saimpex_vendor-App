import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:country_picker/country_picker.dart';
import 'package:saimpex_vendor/configs/secure_credentials.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/login_model.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';
import 'package:saimpex_vendor/utils/vendor_app_type.dart';
import '../utils/api_message.dart';
import '../utils/utils.dart';

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

  /// The vendor type picked on the login screen (API number, see
  /// loginVendorTypes); it sets the matching app section.
  int selectedVendorType = 1;

  void setSelectedVendorType(int? vendorType) {
    if (vendorType == null) return;
    selectedVendorType = vendorType;
    selectedAppType =
        VendorAppTypeX.fromVendorType(vendorType) ?? VendorAppType.groceryRestaurant;
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> Login(
    BuildContext context,
    String userName,
    String password,
  ) async {
    // No spaces in a username: a pasted or keyboard-added one ("grocery. 08")
    // made the login fail (K-B1 on the kitchen app).
    userName = userName.replaceAll(RegExp(r'\s'), '');
    // Empty fields: say what is missing instead of doing nothing (VA-02).
    if (userName.isEmpty) {
      showToast(context, S.of(context).loginEnterUsername);
      return;
    }
    if (password.isEmpty) {
      showToast(context, S.of(context).loginEnterPassword);
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
      debugPrint("==================================================");
      debugPrint("[LOGIN REQUEST] Selected Vendor Type: ${selectedAppType.label}");
      debugPrint("[LOGIN REQUEST] Username: $userName");
      debugPrint("==================================================");
      final response = await DioClient().post(
        ApiEndPoints.login,
        body: {"username": userName, "password": password,  "fcm": fcm_token,},
      );
      LoginModel loginModel = LoginModel.fromJson(response.data);
      Get.back();
      update();
      if (loginModel.status == true) {
        String authToken = loginModel.data?.details?.token ?? "";
        if (authToken.isEmpty && response.data is Map) {
          final d = response.data['data'];
          if (d is Map) {
            authToken = d['token']?.toString() ?? d['details']?['token']?.toString() ?? "";
          }
        }
        final apiVendorType = loginModel.data?.details?.vendorType;
        debugPrint("==================================================");
        debugPrint("[LOGIN SUCCESS] Selected Vendor Type: ${selectedAppType.label}");
        debugPrint("[LOGIN SUCCESS] API Vendor Type: $apiVendorType");
        debugPrint("[LOGIN SUCCESS] User ID: ${loginModel.data?.details?.id}");
        debugPrint("[LOGIN SUCCESS] Vendor ID: ${loginModel.data?.details?.vendorId}");
        debugPrint("==================================================");
        // Open the section for the vendor's real type, not the one picked on
        // the login screen; a mismatched pick opened the wrong vertical.
        final serverAppType = VendorAppTypeX.fromVendorType(apiVendorType);
        if (apiVendorType != null && serverAppType == null) {
          showToast(context, S.of(context).vendorTypeUseWebPanel);
          return;
        }
        if (serverAppType != null) selectedAppType = serverAppType;
        await savename("username", userName);
        await SecureCredentials.savePassword(password);
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
        // Server text in the app language only (VA-03).
        showToast(
          context,
          ApiMessage.local(response.data) ??
              S.of(context).loginSuccessful,
        );
        await VendorAppRouter.goToSelectedApp(type: selectedAppType);
      } else {
        // Server text in the app language only (VA-03).
        showToast(
          context,
          ApiMessage.local(response.data) ??
              S.of(context).loginFailed,
        );
      }
    } catch (error) {
      Get.back();
      debugPrint("Login Error: $error");
      // DioClient errors are already a message in the app language.
      showToast(
        context,
        error is String && error.isNotEmpty ? error : S.of(context).loginFailed,
      );
    }
  }
}
