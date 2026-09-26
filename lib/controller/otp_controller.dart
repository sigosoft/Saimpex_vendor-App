import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import '../Utils/Utils.dart';
import '../utils/vendor_app_router.dart';
import '../utils/vendor_app_type.dart';

import 'login_controller.dart';

class OtpController extends GetxController {
  LoginController loginController = Get.put(LoginController());
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  final FlutterLocalization localization = FlutterLocalization.instance;
  final TextEditingController pinController = TextEditingController();

  // OTP and timer variables
  String otp = '';
  var remainingSeconds = 30.obs;
  Timer? _timer;
  var canResend = false.obs;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    remainingSeconds.value = 30;
    canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        canResend.value = true;
      }
      update();
    });
  }

  void resendOtp(BuildContext context, String countryCode, String mobile) {
    loginController.sendOtp(context, countryCode, mobile, "otp");
    otp = '';
    startTimer();
    update();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> verifyOtp(
    BuildContext context,
    String countryCode,
    String mobile,
  ) async {
    try {
      showLoadingDialog(context);
      if (context.mounted) {
        Get.back();
      }
      update();
      await savename("loginStatus", "true");
      await savename("token", "mock_token");
      await savename("name", "Mock User");
      await savename(
        VendorAppRouter.storageKey,
        loginController.selectedAppType.storageValue,
      );
      await VendorAppRouter.goToSelectedApp(
        type: loginController.selectedAppType,
      );
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("verify otp Error: $error");
    }
  }

  Future<void> saveName(BuildContext context) async {
    try {
      showLoadingDialog(context);
      if (context.mounted) {
        Get.back();
      }
      update();
      await savename("name", nameController.text.toString());
      await VendorAppRouter.goToSelectedApp(
        type: loginController.selectedAppType,
      );
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("save name Error: $error");
    }
  }
}
