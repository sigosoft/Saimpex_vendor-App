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
        return 'Grocery / Restaurant';
      case VendorAppType.water:
        return 'Water';
      case VendorAppType.pharmacy:
        return 'Pharmacy';
      case VendorAppType.homeCleaning:
        return 'Home Cleaning';
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
}
