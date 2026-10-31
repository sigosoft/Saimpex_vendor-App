/// Local store vendors (vendor_type 11, `app_section` local_store) use the
/// grocery screens, but must call the `localStore*` endpoints: the grocery
/// ones only return grocery orders and products (backend API doc §6.23, V12).
/// Request parameters and response keys are the same.
class StoreEndpoints {
  static const String localStoreVendorType = '11';

  /// Grocery endpoint → local store twin. Every target exists in
  /// `routes/vendorapp.php` on `integration/v2`.
  static const Map<String, String> groceryToLocalStore = {
    'acceptGroceryOrder': 'acceptLocalStoreOrder',
    'addGroceryMenu': 'addLocalStoreMenu',
    'addGroceryMenuItem': 'addLocalStoreMenuItem',
    'cancelGroceryOrder': 'cancelLocalStoreOrder',
    'deleteGroceryMenu': 'deleteLocalStoreMenu',
    'deleteGroceryMenuItem': 'deleteLocalStoreMenuItem',
    'getAllGroceryMenus': 'getAllLocalStoreMenus',
    'getGroceryAttributes': 'getLocalStoreAttributes',
    'getGroceryCategories': 'getLocalStoreCategories',
    'getGroceryTags': 'getLocalStoreTags',
    'groceryMenuDetails': 'localStoreMenuDetails',
    'groceryMenuItemDetail': 'localStoreMenuItemDetail',
    'groceryMenuItemStockLogs': 'localStoreMenuItemStockLogs',
    'groceryMenuItems': 'localStoreMenuItems',
    'groceryMenus': 'localStoreMenus',
    'groceryOrderDetail': 'localStoreOrderDetail',
    'groceryReport': 'localStoreReport',
    'groceryReportDownload': 'localStoreReportDownload',
    'importGroceryMenuItems': 'importLocalStoreMenuItems',
    'markAsReadyGroceryOrder': 'markAsReadyLocalStoreOrder',
    'prepareGroceryOrder': 'prepareLocalStoreOrder',
    'updateGroceryItemAvailabilityStatus':
        'updateLocalStoreItemAvailabilityStatus',
    'updateGroceryMenu': 'updateLocalStoreMenu',
    'updateGroceryMenuItem': 'updateLocalStoreMenuItem',
    'updateGrocerytItemStock': 'updateLocalStoretItemStock',
    'uploadGroceryBulkMenu': 'uploadLocalStoreBulkMenu',
    'uploadGroceryMenuImages': 'uploadLocalStoreMenuImages',
  };

  /// [path] with its last segment swapped for the local store twin when
  /// [vendorType] is 11; otherwise unchanged. Works on bare endpoint names
  /// and on full URLs, and keeps any query string.
  static String forVendorType(String path, String? vendorType) {
    if (vendorType?.trim() != localStoreVendorType) return path;
    final q = path.indexOf('?');
    final base = q < 0 ? path : path.substring(0, q);
    final query = q < 0 ? '' : path.substring(q);
    final slash = base.lastIndexOf('/');
    final last = base.substring(slash + 1);
    final twin = groceryToLocalStore[last];
    if (twin == null) return path;
    return '${base.substring(0, slash + 1)}$twin$query';
  }
}
