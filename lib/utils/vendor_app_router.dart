import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/pharmacy/pharmacy_home.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_type.dart';
import 'package:saimpex_vendor/view/home/home.dart';
import 'package:saimpex_vendor/water/bindings/home_binding.dart';
import 'package:saimpex_vendor/water/water_app_shell.dart';

class VendorAppRouter {
  static const String storageKey = 'selectedAppType';

  static Widget screenFor(VendorAppType type) {
    switch (type) {
      case VendorAppType.groceryRestaurant:
        return const Home();
      case VendorAppType.water:
        return const WaterAppShell();
      case VendorAppType.pharmacy:
        return const PharmacyHome();
    }
  }

  /// Navigate after login / splash based on the selected app type.
  static Future<void> goToSelectedApp({VendorAppType? type}) async {
    final resolved = type ??
        VendorAppTypeX.fromStorage(
          (await getSavedObject(storageKey))?.toString(),
        );

    if (resolved == VendorAppType.water) {
      HomeBinding().dependencies();
    }

    Get.offAll(() => screenFor(resolved));
  }
}
