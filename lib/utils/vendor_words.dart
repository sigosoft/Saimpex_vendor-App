import 'package:get/get.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// Grocery and local store vendors share the restaurant screens; these
/// labels said "Restaurant" for them too.
bool get isStoreVendor => isStoreVendorType(
      Get.isRegistered<ProfileController>() ? Get.find<ProfileController>().vendorType : null,
    );

String reachedVendorLabel() => isStoreVendor ? S.current.reachedStore : S.current.reachedRestaurant;

String vendorStatusTitle() => isStoreVendor ? S.current.storeStatus : S.current.restaurantStatus;

String vendorCommissionLabel() => isStoreVendor ? S.current.storeCommission : S.current.restaurantCommission;
