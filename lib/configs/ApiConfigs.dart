class ApiConfigs {
  // //  // This is the Test Server URL
  static String BASE_URL =
      "https://ourworks.co.in/saimpex-backend/public/api/vendorapp/";

  // // // // This is the Live Server URL
  //   static String BASE_URL = "";

  // This is the base Image URL
  static String IMAGE_URL =
      "https://ourworks.co.in/saimpex-backend/public/storage/";
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
}
