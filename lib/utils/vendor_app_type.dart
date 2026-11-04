import 'package:saimpex_vendor/generated/l10n.dart';

/// App service type selected on the login screen.
/// This is separate from API `vendor_type` (restaurant vs grocery).
enum VendorAppType {
  /// Current vendor app (grocery + restaurant share the same UI).
  groceryRestaurant,

  /// Water vendor experience.
  water,

  /// Pharmacy vendor experience.
  pharmacy,

  /// Home cleaning vendor experience.
  homeCleaning,
}

extension VendorAppTypeX on VendorAppType {
  /// Persisted value for SharedPreferences / local storage.
  String get storageValue {
    switch (this) {
      case VendorAppType.groceryRestaurant:
        return '1';
      case VendorAppType.water:
        return '2';
      case VendorAppType.pharmacy:
        return '3';
      case VendorAppType.homeCleaning:
        return '4';
    }
  }

  String get label {
    switch (this) {
      case VendorAppType.groceryRestaurant:
        return S.current.vendorTypeGroceryRestaurant;
      case VendorAppType.water:
        return S.current.vendorTypeWater;
      case VendorAppType.pharmacy:
        return S.current.vendorTypePharmacy;
      case VendorAppType.homeCleaning:
        return S.current.vendorTypeHomeCleaning;
    }
  }

  static VendorAppType fromStorage(String? value) {
    switch (value) {
      case '2':
        return VendorAppType.water;
      case '3':
        return VendorAppType.pharmacy;
      case '4':
        return VendorAppType.homeCleaning;
      case '1':
      default:
        return VendorAppType.groceryRestaurant;
    }
  }

  /// The app section for the vendor_type the login API returns, or null when
  /// the app has no section for it (courier, express). Laundry (7) and car
  /// wash (8) share the service section with home cleaning (task V14); the
  /// section reads the exact kind from the saved vendorType (ServiceKinds).
  static VendorAppType? fromVendorType(int? vendorType) {
    switch (vendorType) {
      case 1: // food
      case 2: // grocery
      case 11: // local store
        return VendorAppType.groceryRestaurant;
      case 3:
        return VendorAppType.pharmacy;
      case 4: // water
      case 10: // gas
        return VendorAppType.water;
      case 7: // laundry
      case 8: // car wash
      case 9: // home cleaning
        return VendorAppType.homeCleaning;
      default:
        return null;
    }
  }
}

/// Vendor types offered on the login screen, as the API numbers them. The
/// list only showed the app's four sections, so laundry, car wash, gas and
/// local store vendors could not find their type. The section still comes
/// from the server's vendor_type after login.
const List<int> loginVendorTypes = [1, 2, 11, 3, 4, 10, 7, 8, 9];

String vendorTypeName(int vendorType) => switch (vendorType) {
      1 => S.current.vendorTypeRestaurant,
      2 => S.current.vendorTypeGrocery,
      11 => S.current.vendorTypeLocalStore,
      3 => S.current.vendorTypePharmacy,
      4 => S.current.vendorTypeWater,
      10 => S.current.vendorTypeGas,
      7 => S.current.vendorTypeLaundry,
      8 => S.current.vendorTypeCarWash,
      9 => S.current.vendorTypeHomeCleaning,
      _ => S.current.vendorTypeGroceryRestaurant,
    };
