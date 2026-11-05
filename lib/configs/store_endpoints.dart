/// Local store vendors (vendor_type 11, `app_section` local_store) use the
/// grocery screens, but must call the `localStore*` endpoints: the grocery
/// ones only return grocery orders and products (backend API doc §6.23, V12).
/// The local store endpoints name their keys `local_store_menu…` /
/// `local_store_tag…` where grocery has `grocery_menu…` / `grocery_tag…`
/// (backend `LocalStoreController` / `LocalStoreMenuController`); see
/// [toLocalStoreKey] and [toGroceryKeys]. Without that, local store My Store
/// showed no products (5 Nov retest).
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
    'downloadGroceryBulkTemplate': 'downloadLocalStoreBulkTemplate',
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

  /// True when [path] is a grocery endpoint that [forVendorType] swaps.
  static bool isSwapped(String path, String? vendorType) =>
      forVendorType(path, vendorType) != path;

  static const _keyPairs = [
    ('grocery_menu', 'local_store_menu'),
    ('grocery_tag', 'local_store_tag'),
  ];

  /// Request key for the local store endpoint (grocery_menu_id →
  /// local_store_menu_id); other keys are unchanged.
  static String toLocalStoreKey(String key) {
    for (final (g, l) in _keyPairs) {
      if (key.startsWith(g)) return l + key.substring(g.length);
    }
    return key;
  }

  static String _toGroceryKey(String key) {
    for (final (g, l) in _keyPairs) {
      if (key.startsWith(l)) return g + key.substring(l.length);
    }
    return key;
  }

  /// A local store response with its keys renamed to the grocery ones the
  /// screens read (local_store_menus → grocery_menus), at every level.
  /// Keeps the JSON types (Map<String, dynamic>): the models cast to it,
  /// and a Map<dynamic, dynamic> made them fail, so the list came back empty.
  static dynamic toGroceryKeys(dynamic data) {
    if (data is Map) {
      return <String, dynamic>{
        for (final e in data.entries) _toGroceryKey('${e.key}'): toGroceryKeys(e.value),
      };
    }
    if (data is List) return data.map(toGroceryKeys).toList();
    return data;
  }
}
