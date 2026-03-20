import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/model/settings_model.dart';
import 'package:saimpex_vendor/view/login/login.dart';
import 'package:saimpex_vendor/view/settings/maintenance.dart';
import 'package:saimpex_vendor/view/settings/need_an_update.dart';

import '../Utils/utils.dart';
import '../model/home_model.dart';
// import 'grocery_controller.dart';
// import 'cart_controller.dart';
// import 'chat_controller.dart';
import 'package:saimpex_vendor/controller/chat_controller.dart';
import '../view/Home/Home.dart';
import 'profile_controller.dart';

class HomeController extends GetxController {
  int currentIndex = 0;
  int selectedcurrentIndex = 0;
  final FlutterLocalization localization = FlutterLocalization.instance;

  String selectedLocation = '';
  String userName = '';
  TextEditingController searchController = TextEditingController();

  HomeModel? homeData;
  bool _hasNextPage = true;
  bool isFirstLoadRunning = true;
  bool isLoadMoreRunning = false;
  ScrollController scrollController = ScrollController();

  String offers = "";
  String rating = "";
  String priceRange = "";
  String selectedSort = "";

  // Selected filters per row (one selection per row)
  String? selectedOfferFilter; // "Offers"
  String?
  selectedRatingFilter; // "Ratings 4.5+", "Ratings 4.0+", "Ratings 3.5+"
  String?
  selectedPriceRangeFilter; // "Under 200 MRU", "500 - 900 MRU", "Above 500 MRU"

  String veg = "";
  String nonVeg = "";
  bool badge = false;
  int unreadChatCount = 0;

  @override
  void onInit() {
    initAsync();
    super.onInit();
  }

  Future<void> initAsync() async {
    scrollController = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  final List<String> filterCategories = ['Filter', 'Non Veg', 'Veg', 'Offers'];

  Future<void> onTabTapped(int index, BuildContext context) async {
    selectedcurrentIndex = index;
    update();

    // Load corresponding API based on selected tab
    try {
      switch (index) {
        case 0: // Home tab
          await fetchHome(context, orderStatus: 0);
          break;
        case 1: // My Restaurant tab
          // Reload restaurant data if needed
          final ProfileController profileController =
              Get.find<ProfileController>();
          await profileController.getProfile(context);
          await profileController.getRatingsReviews(context);
          break;
        case 2: // Chat tab
          // Clear badge immediately when user navigates to chat
          unreadChatCount = 0;
          update();
          // Reload chat data if needed
          final ChatController chatController = Get.put(ChatController());
          await chatController.getAllConversations(context);
          // Refresh count after viewing
          fetchUnreadChatCount();
          break;
        case 3: // Settings tab
          // Reload settings/profile data if needed
          break;
      }
    } catch (e) {
      debugPrint("Error loading data for tab $index: $e");
    }
  }

  List<List<String>> filterOptions = [
    ["Offers"],
    ["Ratings 4.5+", "Ratings 4.0+", "Ratings 3.5+"],
    ["Under 200 MRU", "500 - 900 MRU", "Above 500 MRU"],
  ];

  void selectFilter(int rowIndex, String filterValue) {
    if (rowIndex == 0) {
      // Offers row
      if (selectedOfferFilter == filterValue) {
        // Deselect if already selected
        selectedOfferFilter = null;
        offers = "";
      } else {
        selectedOfferFilter = filterValue;
        offers = "1";
      }
    } else if (rowIndex == 1) {
      // Ratings row
      if (selectedRatingFilter == filterValue) {
        // Deselect if already selected
        selectedRatingFilter = null;
        rating = "";
      } else {
        selectedRatingFilter = filterValue;
        // Map rating string to API value
        if (filterValue == "Ratings 4.5+") {
          rating = "4.5";
        } else if (filterValue == "Ratings 4.0+") {
          rating = "4";
        } else if (filterValue == "Ratings 3.5+") {
          rating = "3.5";
        }
      }
    } else if (rowIndex == 2) {
      // Price range row
      if (selectedPriceRangeFilter == filterValue) {
        // Deselect if already selected
        selectedPriceRangeFilter = null;
        priceRange = "";
      } else {
        selectedPriceRangeFilter = filterValue;
        // Map price range string to API value
        if (filterValue == "Under 200 MRU") {
          priceRange = "under_200";
        } else if (filterValue == "500 - 900 MRU") {
          priceRange = "500_900";
        } else if (filterValue == "Above 500 MRU") {
          priceRange = "above_500";
        }
      }
    }
    update();
  }

  bool isFilterSelected(int rowIndex, String filterValue) {
    if (rowIndex == 0) {
      return selectedOfferFilter == filterValue;
    } else if (rowIndex == 1) {
      return selectedRatingFilter == filterValue;
    } else if (rowIndex == 2) {
      return selectedPriceRangeFilter == filterValue;
    }
    return false;
  }

  void clearAllFilters() {
    selectedOfferFilter = null;
    selectedRatingFilter = null;
    selectedPriceRangeFilter = null;
    offers = "";
    rating = "";
    priceRange = "";
    veg = "";
    nonVeg = "";
    selectedSort = "";
    getHome();
  }

  // Clear specific filters
  void clearOffersFilter() {
    offers = "";
    selectedOfferFilter = null;
    getHome();
  }

  void clearVegFilter() {
    veg = "";
    getHome();
  }

  void clearNonVegFilter() {
    nonVeg = "";
    getHome();
  }

  // Check if any bottom sheet filters are active (rating, priceRange, offers from bottom sheet)
  bool hasBottomSheetFilters() {
    return rating.isNotEmpty ||
        priceRange.isNotEmpty ||
        selectedOfferFilter != null;
  }

  // Select offers from horizontal list (should also select in bottom sheet)
  void selectOffersFromList() {
    offers = "1";
    selectedOfferFilter = "Offers";
    getHome();
  }

  List<String> sortOptions = [
    "Relevance",
    "Delivery Time",
    "Cost: Low to High",
    "Cost: High to Low",
  ];

  Future<void> fetchLocation() async {
    var token = await getSavedObject("token");
    dynamic count = await getSavedObject("noti_count");
    if (count != null) {
      if (count == "1") {
        badge = true;
      } else {
        badge = false;
      }
    } else {
      badge = false;
    }
    if (token.toString() == "null" || token.toString() == "") {
      userName = "Guest";
      var address = await getSavedObject("address");
      selectedLocation = address?.toString() ?? "";
    } else {
      var name = await getSavedObject("name");
      userName = name?.toString() ?? "";
      var address = await getSavedObject("address");
      selectedLocation = address?.toString() ?? "";
    }
    update();
  }

  Future<void> settings(BuildContext context) async {
    try {
      // Mock settings success
      await Future.delayed(const Duration(seconds: 1));
      getHome();
    } catch (error) {
      debugPrint("maintenance Mock Error: $error");
    }
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.position.extentAfter < 300) {
      isLoadMoreRunning = true;
      update();

      await Future.delayed(const Duration(seconds: 1));
      // Mock: No more pages in mock mode to keep it simple
      _hasNextPage = false;

      isLoadMoreRunning = false;
      update();
    }
  }

  Future<void> getHome() async {
    try {
      isFirstLoadRunning = true;
      update();

      await Future.delayed(const Duration(seconds: 1));

      debugPrint("Mock home data loaded");
    } catch (e) {
      debugPrint('Mock Home Error: $e');
    }
    isFirstLoadRunning = false;
    update();
  }

  Future<HomeModel?> getHomeApi(int limit, int page) async {
    return null; // Neutralized
  }

  Future<void> sendBarcode(BuildContext context, String barcode) async {
    try {
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Get.back();
        showToast(context, "Barcode scanned successfully (Mock)");
      }
    } catch (error) {
      debugPrint("Barcode Mock Error: $error");
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }

  Future<void> maintenance(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String buildNumber = packageInfo.version;
      final response = await DioClient().get(ApiEndPoints.vendorappSettings);
      SettingsModel model = SettingsModel.fromJson(response.data);
      debugPrint("settings model: ${response.data}");
      debugPrint("current version vendor: $buildNumber");
      if (model.status.toString() == "true") {
        if (Platform.isAndroid &&
            model.data?.settings?[0].maintenanceAndroidVendor.toString() ==
                "1") {
          Get.offAll(
            Maintenance(
              serverDownReason: model.data?.settings?[0]
                  .maintenanceReasonAndroidVendor
                  .toString(),
            ),
          );
        } else if (Platform.isIOS &&
            model.data?.settings?[0].maintenanceIosVendor.toString() == "1") {
          Get.offAll(
            Maintenance(
              serverDownReason: model.data?.settings?[0].maintenanceReasonIosVendor
                  .toString(),
            ),
          );
        } else if (Platform.isAndroid &&
            (model.data?.settings?[0].playStoreUpdateVendor.toString() ==
                    "1" &&
                versionToCode(
                      model.data?.settings?[0].playStoreVersionVendor
                              .toString() ??
                          "",
                    ) >
                    versionToCode(buildNumber.toString()))) {
          Get.offAll(() => NeedAnUpdate());
        } else if (Platform.isIOS &&
            (model.data?.settings?[0].appStoreUpdateVendor.toString() == "1" &&
                versionToCode(
                      model.data?.settings?[0].appStoreVersionVendor.toString() ??
                          "",
                    ) >
                    versionToCode(buildNumber.toString()))) {
          Get.offAll(() => NeedAnUpdate());
        } else {
          var loginStatus = await getSavedObject("loginStatus");
          var token = await getSavedObject("token");
          debugPrint("loginStatus: $loginStatus");
          debugPrint("token: $token");
          if (loginStatus != null && loginStatus == "true") {
            Get.offAll(() => const Home());
          } else {
            Get.offAll(() => LoginScreen());
          }
        }
      }else{
        var loginStatus = await getSavedObject("loginStatus");
        var token = await getSavedObject("token");
        debugPrint("loginStatus: $loginStatus");
        debugPrint("token: $token");
        if (loginStatus != null && loginStatus == "true") {
          Get.offAll(() => const Home());
        } else {
          Get.offAll(() => LoginScreen());
        }
      }
    } catch (error, stackTrace) {
      debugPrint("maintenance Error: $error");
      debugPrint("maintenance StackTrace: $stackTrace");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> fetchHome(
    BuildContext context, {
    required int orderStatus,
    String keyword = "",
    int limit = 5,
    int page = 1,
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) {
        isFirstLoadRunning = true;
        update();
      } else {
        isLoadMoreRunning = true;
        update();
      }
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }

      Map<String, dynamic> queryParams = {
        "order_status": orderStatus,
        "keyword": keyword,
        "limit": limit,
      };
      if (page > 1) {
        queryParams["page"] = page;
      }

      final response = await DioClient().get(
        ApiEndPoints.home,
        query: queryParams,
      );

      if (isLoadMore && homeData?.data != null) {
        HomeModel newHomeData = HomeModel.fromJson(
          response.data as Map<String, dynamic>?,
        );

        if (newHomeData.data?.orders?.data != null &&
            homeData!.data!.orders != null) {
          List<OrderData> existingOrders = List.from(
            homeData!.data!.orders!.data ?? [],
          );
          existingOrders.addAll(newHomeData.data!.orders!.data!);

          Orders updatedOrders = Orders(
            currentPage: newHomeData.data!.orders!.currentPage,
            lastPage: newHomeData.data!.orders!.lastPage,
            total: newHomeData.data!.orders!.total,
            data: existingOrders,
          );

          HomeData updatedData = HomeData(
            membership: homeData!.data!.membership,
            summary: homeData!.data!.summary,
            vendor: homeData!.data!.vendor,
            orders: updatedOrders,
          );

          homeData = HomeModel(
            status: homeData!.status,
            message: homeData!.message,
            data: updatedData,
          );
        }
      } else {
        homeData = HomeModel.fromJson(response.data as Map<String, dynamic>?);
      }
      debugPrint("home model: ${response.data}");
    } catch (error) {
      debugPrint("home Error: $error");
      fetchUnreadChatCount();
    } finally {
      if (!isLoadMore) {
        isFirstLoadRunning = false;
      } else {
        isLoadMoreRunning = false;
      }
      fetchUnreadChatCount();
      update();
    }
  }

  Future<void> fetchUnreadChatCount() async {
    try {
      var token = await getSavedObject("token");
      if (token == null || token.toString().isEmpty || token.toString() == "null") return;
      DioClient().updateToken(token);
      final response = await DioClient().get(ApiEndPoints.totalUnreadMessagesCount);
      if (response.data != null && response.data['status'] == true) {
        final count = response.data['data']?['total_unread_messages_count'];
        unreadChatCount = (count is int) ? count : int.tryParse(count?.toString() ?? '0') ?? 0;
        update();
      }
    } catch (e) {
      debugPrint("fetchUnreadChatCount error: $e");
    }
  }
}
