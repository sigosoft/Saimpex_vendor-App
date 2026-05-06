class ApiConfigs {
  // //  // This is the Test Server URL
  static String BASE_URL = "https://api.saimpexenterprise.com/api/vendorapp/";
  //"https://ourworks.co.in/saimpex-backend/public/api/vendorapp/";

  // // // // This is the Live Server URL
  //   static String BASE_URL = "";

  // This is the base Image URL
  static String IMAGE_URL = "https://api.saimpexenterprise.com/storage/";
  //"https://ourworks.co.in/saimpex-backend/public/storage/";

  /// Android package name for Play Store link
  static const String androidPackageName = "saimpex.vendor";

  /// iOS App Store ID (numeric). Replace with your app's ID from App Store Connect when published.
  static const String iosAppStoreId = "123456789";
}

class ApiEndPoints {
  static String login = "login";
  static String settings = "settings";
  static String vendorappSettings = "vendorappSettings";
  static String home = "home";

  static String restaurantOrderDetails = "restaurantOrderDetail";
  static String groceryOrderDetails = "groceryOrderDetail";
  static String profile = "profile";
  static String deliveryBoys = "deliveryBoys";
  static String logout = "logout";
  static String dashboard = "dashboard";
  static String deleteAccount = "deleteAccount";
  static String markLeave = "markLeave";
  static String unmarkLeave = "unmarkLeave";
  static String ratingsReviews = "ratingsReviews";
  static String groceryMenus = "groceryMenus";
  static String addGroceryMenu = "addGroceryMenu";
  static String groceryMenuItems = "groceryMenuItems";
  static String addGroceryMenuItem = "addGroceryMenuItem";
  static String restaurantMenus = "restaurantMenus";
  static String restaurantMenuItems = "restaurantMenuItems";

  static String acceptGroceryOrder = "acceptGroceryOrder";
  static String cancelGroceryOrder = "cancelGroceryOrder";
  static String prepareGroceryOrder = "prepareGroceryOrder";
  static String markAsReadyGroceryOrder = "markAsReadyGroceryOrder";
  static String acceptRestaurantOrder = "acceptRestaurantOrder";
  static String cancelRestaurantOrder = "cancelRestaurantOrder";
  static String prepareRestaurantOrder = "prepareRestaurantOrder";
  static String markAsReadyRestaurantOrder = "markAsReadyRestaurantOrder";
  static String getTermsandConditions = "getTermsandConditions";
  static String getPrivacyPolicy = "getPrivacyPolicy";
  static String getContact = "getContact";
  static String getAbout = "getAbout";
  static String allConversations = "chat/allConversations";
  static String getConversation = "chat/getConversation";
  static String sendMessage = "chat/sendMessage";
  static String customerSearch = "customers/search";
  static String totalUnreadMessagesCount = "chat/totalUnreadMessagesCount";
  static String markAsRead = "chat/markAsRead";
  static String getRestaurantCategories = "getRestaurantCategories";
  static String getRestaurantMenuDetails = "restaurantMenuDetails";
  static String addRestaurantMenu = "addRestaurantMenu";
  static String getRestaurantTags = "getRestaurantTags";
  static String getNotifications = "notifications";
  static String deleteRestaurantMenu = "deleteRestaurantMenu";
  static String updateRestaurantMenuEdit = "updateRestaurantMenu";
  static String addRestaurantMenuItem = "addRestaurantMenuItem";
  static String getRestaurantMenus = "getRestaurantMenus";
  static String getRestaurantAttributes = "getRestaurantAttributes";
  static String getRestaurantMenuItemDetails = "restaurantMenuItemDetail";
  static String deleteRestaurantMenuItem = "deleteRestaurantMenuItem";
  static String receivedPayouts = "receivedPayouts";
  static String resturantReport = "resturantReport";
  static String restaurantReportDownload = "restaurantReportDownload";
  static String importRestaurantMenuItems = "downloadRestaurantBulkTemplate";
  static String uploadRestaurantMenuBulkImport = "uploadRestaurantBulkMenu";
  static String updateRestaurantMenuItem = "updateRestaurantMenuItem";
  static String exportMenuItems = "exportMenuItems";
  static String uploadMenuItems = "importRestaurantMenuItems";
  static String restaurantMenuItemStockLogs = "restaurantMenuItemStockLogs";
  static String updateRestaurantMenuItemStock = "updateRestaurantItemStock";

  static String earningsSummary = "earnings/summary";
  static String earningsOrders = "earnings/orders";
  static String earningsPayoutHistory = "earnings/payoutHistory";
  static String earningsPayoutDetail = "earnings/payoutDetail";

  // grocery api endpoints

  static String getGroceryMenuDetails = "groceryMenuDetails";
  static String importGroceryMenuItems = "importGroceryMenuItems";
  static String uploadGroceryMenuBulkImport = "uploadGroceryBulkMenu";
  static String getGroceryCategories = "getGroceryCategories";
  static String getGroceryTags = "getGroceryTags";
  static String getGroceryMenus = "getAllGroceryMenus";
  static String getGroceryAttributes = "getGroceryAttributes";
  static String groceryReport = "groceryReport";
  static String groceryReportDownload = "groceryReportDownload";
  static String baskets = "baskets";
  static String basketDetail = "basketDetail";
  static String basketRedeemedCustomers = "basketRedeemedCustomers";
  static String deleteGroceryMenu = "deleteGroceryMenu";
  static String updateGroceryMenuEdit = "updateGroceryMenu";
  static String deleteGroceryMenuItem = "deleteGroceryMenuItem";
  static String getGroceryMenuItemDetails = "groceryMenuItemDetail";
  static String updateGroceryMenuItem = "updateGroceryMenuItem";
  static String uploadRestaurantImages = "uploadRestaurantMenuImages";
  static String uploadGroceryImages = "uploadGroceryMenuImages";
  static String uploadWorkingHours = "updateWorkingHours";
  static String updateItemStatus = "updateItemAvailabilityStatus";
  static String updateGroceryItemStatus = "updateGroceryItemAvailabilityStatus";
  static String groceryMenuItemStockLogs = "groceryMenuItemStockLogs";
  static String updateGrocerytItemStock = "updateGrocerytItemStock";
  static String updateAutoAcceptOrders = "updateAutoAcceptMode";
  static String updateBusyMode = "updateBusyMode";
  static String updateCouponStatus = "updateCouponStatus";
  static String coupons = "coupons";
  static String addCoupon = "addCoupon";
  static String updateCoupon = "updateCoupon";
  static String deleteCoupon = "deleteCoupon";
}
