import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
import 'package:saimpex_vendor/model/restaurant_category_model.dart';
import 'package:saimpex_vendor/model/rating_review_model.dart';
import 'package:saimpex_vendor/model/grocery_menus_model.dart';
import 'package:saimpex_vendor/model/grocery_menu_items_model.dart';
import 'package:saimpex_vendor/model/grocery_menu_details_model.dart'
    hide GroceryMenu;
import 'package:saimpex_vendor/model/grocery_all_categories_model.dart';
import 'package:saimpex_vendor/model/restaurant_menu_details_model.dart'
    hide RestaurantMenu;
import 'package:saimpex_vendor/model/restaurant_menus_model.dart';
import 'package:saimpex_vendor/model/restaurant_menu_items_model.dart';
import 'package:saimpex_vendor/view/login/login.dart';

import '../utils/utils.dart';
import '../utils/widgets/import_errors_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ProfileController extends GetxController {
  final FlutterLocalization localization = FlutterLocalization.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String countryCode = '';
  bool isNameEditable = false;
  bool isPhoneEditable = false;
  String profilePicture = '';
  final ImagePicker imagePicker = ImagePicker();
  XFile? imageSource;
  bool isOtpSent = false;
  bool isOtpVerified = false;
  Country selectedCountry = Country.parse('MR');
  bool isProfileLoading = false;
  bool notificationEnabled = true;
  String version = '';
  String vendorType = '0'; // 1 = Restaurant, 2 = Grocery

  @override
  void onInit() {
    getAppVersion();
    getVendorType();
    scrollController.addListener(_loadMore);
    super.onInit();
  }

  Future<void> getVendorType() async {
    final type = await getSavedObject("vendorType");
    vendorType = type?.toString() ?? '0';
    update();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    update();
  }

  ProfileData? profileData;
  double points = 0.0;
  double redeemableAmount = 0.0;

  bool isLoadMoreLeaveLoading = false;
  int currentLeavePage = 1;
  bool hasMoreLeaveHistory = true;

  List<LeaveData> upcomingLeaves = [];
  List<LeaveData> leaveHistory = [];
  List<WorkingHour> workingHours = [];

  RatingReviewData? ratingReviewData;
  bool isRatingReviewLoading = false;
  bool isLoadMoreRatingLoading = false;
  int currentRatingPage = 1;
  bool hasMoreReviews = true;

  List<GroceryMenu> groceryMenus = [];
  bool isGroceryMenusLoading = false;

  List<RestaurantMenu> restaurantMenus = [];
  RestaurantMenuDetailsData? restaurantMenuDetails;
  bool isRestaurantMenuDetailsLoading = false;
  bool isRestaurantMenusLoading = false;
  int _page = 0;
  int _limit = 10;
  bool _hasNextPage = true;
  bool _canLoadMoreMenus = false;
  String _currentMenuKeyword = '';
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  ScrollController scrollController = ScrollController();

  List<GroceryMenuItem> groceryMenuItems = [];
  bool isGroceryMenuItemsLoading = false;

  List<RestaurantMenuItemData> restaurantMenuItems = [];
  bool isRestaurantMenuItemsLoading = false;

  /// True while downloading the restaurant bulk-import XML template from API.
  bool isRestaurantBulkTemplateDownloading = false;

  List<RestaurantCategoryData> restaurantCategories = [];
  bool isRestaurantCategoriesLoading = false;
  int? selectedRestaurantCategoryId;

  List<RestaurantCategory> get restaurantCategoriesForDropdown =>
      restaurantCategories
          .map((d) => RestaurantCategory(id: d.id, name: d.nameEn ?? ''))
          .toList();

  void setSelectedRestaurantCategoryId(int? id) {
    selectedRestaurantCategoryId = id;
    update();
  }

  Future<void> getRatingsReviews(
    BuildContext context, {
    String? vendorType,
    int limit = 10,
    int page = 1,
    bool isLoadMore = false,
  }) async {
    try {
      if (isLoadMore) {
        isLoadMoreRatingLoading = true;
      } else {
        isRatingReviewLoading = true;
        currentRatingPage = 1;
        hasMoreReviews = true;
      }
      update();

      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }

      var savedVendorType = await getSavedObject("vendorType");
      var finalVendorType = vendorType ?? savedVendorType?.toString() ?? "1";

      final response = await DioClient().get(
        ApiEndPoints.ratingsReviews,
        query: {"limit": limit, "vendor_type": finalVendorType, "page": page},
      );

      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        final ratingReviewModel = RatingReviewModel.fromJson(response.data);
        if (isLoadMore) {
          if (ratingReviewModel.data?.reviews != null) {
            final newReviews = ratingReviewModel.data!.reviews!;
            if (newReviews.isEmpty) {
              hasMoreReviews = false;
            } else {
              ratingReviewData = RatingReviewData(
                rating: ratingReviewModel.data!.rating,
                totalReviews: ratingReviewModel.data!.totalReviews,
                reviews: [...(ratingReviewData?.reviews ?? []), ...newReviews],
              );
              currentRatingPage = page;
            }
          } else {
            hasMoreReviews = false;
          }
        } else {
          ratingReviewData = ratingReviewModel.data;
          if (ratingReviewData?.reviews == null ||
              ratingReviewData!.reviews!.length < limit) {
            hasMoreReviews = false;
          }
        }
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ??
                "Failed to fetch ratings and reviews",
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        showToast(context, error.toString());
      }
    } finally {
      isRatingReviewLoading = false;
      isLoadMoreRatingLoading = false;
      update();
    }
  }

  Future<void> fetchGroceryMenus({
    int limit = 10,
    int page = 1,
    int? categoryId,
  }) async {
    try {
      isGroceryMenusLoading = true;
      update();

      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }

      final response = await DioClient().get(
        ApiEndPoints.groceryMenus,
        query: {
          "limit": limit,
          "page": page,
          if (categoryId != null) "category_id": categoryId,
        },
      );

      final groceryMenusModel = GroceryMenusModel.fromJson(response.data);
      if (groceryMenusModel.status == true) {
        groceryMenus = groceryMenusModel.data?.groceryMenus?.data ?? [];
      }
    } catch (error) {
      debugPrint("fetchGroceryMenus Error: $error");
    } finally {
      isGroceryMenusLoading = false;
      update();
    }
  }

  /// Clears stale grocery menus before entering restaurant-only menu flow.
  void clearGroceryMenusForRestaurantFlow() {
    debugPrint(
      "[ProfileController] clearing grocery menus for restaurant flow: before=${groceryMenus.length}",
    );
    groceryMenus = [];
    isGroceryMenusLoading = false;
    debugPrint(
      "[ProfileController] clearing grocery menus for restaurant flow: after=${groceryMenus.length}",
    );
    update();
  }

  void removeRestaurantMenuById(String restaurantMenuId) {
    restaurantMenus.removeWhere((m) => m.id?.toString() == restaurantMenuId);
    update();
  }

  Future<void> fetchRestaurantMenus({
    bool isLoadMore = false,
    String keyword = '',
  }) async {
    if (isLoadMore) {
      if (!_canLoadMoreMenus ||
          !_hasNextPage ||
          isFirstLoadRunning ||
          isLoadMoreRunning) {
        return;
      }
      isLoadMoreRunning = true;
      _page += _limit;
    } else {
      _currentMenuKeyword = keyword.trim();
      _canLoadMoreMenus = true;
      _page = 0;
      _limit = 10;
      _hasNextPage = true;
      isFirstLoadRunning = true;
      isRestaurantMenusLoading = true;
      restaurantMenus = [];
    }
    update();
    try {
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      }
      int? matchedCategoryId = selectedRestaurantCategoryId;
      String apiKeyword = _currentMenuKeyword;

      if (apiKeyword.isNotEmpty && matchedCategoryId == null) {
        final lq = apiKeyword.toLowerCase();
        for (var cat in restaurantCategories) {
          if ((cat.nameEn ?? '').toLowerCase().contains(lq) ||
              (cat.nameAr ?? '').toLowerCase().contains(lq) ||
              (cat.nameFr ?? '').toLowerCase().contains(lq)) {
            matchedCategoryId = cat.id;
            apiKeyword = '';
            break;
          }
        }
      }

      final response = await DioClient().get(
        vendorType == "1"
            ? ApiEndPoints.restaurantMenus
            : ApiEndPoints.groceryMenus,
        query: {
          "limit": _limit,
          "page": _page,
          if (apiKeyword.isNotEmpty) "keyword": apiKeyword,
          if (matchedCategoryId != null) "category_id": matchedCategoryId,
        },
      );

      if (vendorType == "1") {
        final model = RestaurantMenusModel.fromJson(response.data);
        if (model.status == true) {
          final fetchedMenus = model.data ?? [];
          if (isLoadMore) {
            if (fetchedMenus.isNotEmpty) {
              restaurantMenus.addAll(fetchedMenus);
            } else {
              _hasNextPage = false;
            }
          } else {
            restaurantMenus = fetchedMenus;
            groceryMenus = [];
          }

          if (fetchedMenus.length < _limit) {
            _hasNextPage = false;
          }
        }
      } else {
        final model = GroceryMenusModel.fromJson(response.data);
        if (model.status == true) {
          final fetchedMenus = model.data?.groceryMenus?.data ?? [];
          if (isLoadMore) {
            if (fetchedMenus.isNotEmpty) {
              groceryMenus.addAll(fetchedMenus);
            } else {
              _hasNextPage = false;
            }
          } else {
            groceryMenus = fetchedMenus;
            restaurantMenus = [];
          }

          if (fetchedMenus.length < _limit) {
            _hasNextPage = false;
          }
        }
      }
    } catch (error) {
      if (isLoadMore) {
        _page = (_page - _limit).clamp(0, 1 << 31);
      }
      debugPrint("fetchRestaurantMenus Error: $error");
    } finally {
      if (isLoadMore) {
        isLoadMoreRunning = false;
      } else {
        isRestaurantMenusLoading = false;
        isFirstLoadRunning = false;
      }
      update();
    }
  }

  void _loadMore() async {
    if (_canLoadMoreMenus &&
        _hasNextPage &&
        !isFirstLoadRunning &&
        !isLoadMoreRunning &&
        scrollController.hasClients &&
        scrollController.position.extentAfter < 300) {
      await fetchRestaurantMenus(
        isLoadMore: true,
        keyword: _currentMenuKeyword,
      );
    }
  }

  Future<void> fetchGroceryMenuItems({
    int limit = 10,
    int page = 1,
    int? status,
    int? categoryId,
    String keyword = '',
  }) async {
    try {
      isGroceryMenuItemsLoading = true;
      update();

      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      }

      int? matchedCategoryId = categoryId;
      String apiKeyword = keyword.trim();

      if (apiKeyword.isNotEmpty && matchedCategoryId == null) {
        final lq = apiKeyword.toLowerCase();
        for (var cat in restaurantCategories) {
          if ((cat.nameEn ?? '').toLowerCase().contains(lq) ||
              (cat.nameAr ?? '').toLowerCase().contains(lq) ||
              (cat.nameFr ?? '').toLowerCase().contains(lq)) {
            matchedCategoryId = cat.id;
            apiKeyword = '';
            break;
          }
        }
      }

      final Map<String, dynamic> queryParams = vendorType == "1"
          ? {
              "page": page,
              "per_page": limit,
              if (status != null) "available_status": status,
              if (matchedCategoryId != null) "category_id": matchedCategoryId,
              if (apiKeyword.isNotEmpty) "keyword": apiKeyword,
            }
          : {
              "limit": limit,
              "page": page,
              if (matchedCategoryId != null) "category_id": matchedCategoryId,
              if (apiKeyword.isNotEmpty) "keyword": apiKeyword,
            };

      final response = await DioClient().get(
        vendorType == "1"
            ? ApiEndPoints.restaurantCatalogItems
            : ApiEndPoints.groceryMenuItems,
        query: queryParams,
      );

      if (vendorType == "1") {
        final model = RestaurantMenuItemsModel.fromJson(response.data);
        if (model.status == true) {
          restaurantMenuItems = model.data?.restaurantMenuItems?.data ?? [];
          if (restaurantMenuItems.isNotEmpty) {
            debugPrint(
              "availabilityStatus: ${restaurantMenuItems.first.availableStatus.toString()}",
            );
          }
        }
      } else {
        final model = GroceryMenuItemsModel.fromJson(response.data);
        if (model.status == true) {
          final items = model.data?.groceryMenuItems?.data ?? [];
          groceryMenuItems = items;

          // Also populate restaurantMenuItems so that other controllers/views can find the items
          restaurantMenuItems = items
              .map(
                (g) => RestaurantMenuItemData(
                  id: g.id,
                  nameEn: g.nameEn,
                  nameAr: g.nameAr,
                  nameFr: g.nameFr,
                  descriptionEn: g.descriptionEn,
                  descriptionAr: g.descriptionAr,
                  descriptionFr: g.descriptionFr,
                  image: g.image,
                  price: g.price,
                  discountPrice: g.price, // Fallback if grocery doesn't have it
                  restaurantMenuItemId: g.menuItemId,
                  categoryId:
                      0, // Not easily available here but often unused for pre-fill match
                  categoryNameEn: g.categoryNameEn,
                  categoryNameAr: g.categoryNameAr,
                  categoryNameFr: g.categoryNameFr,
                  availableStatus: g.availableStatus,
                ),
              )
              .toList();
        }
      }
    } catch (error) {
      debugPrint("fetchGroceryMenuItems Error: $error");
    } finally {
      isGroceryMenuItemsLoading = false;
      update();
    }
  }

  void updateRestaurantItemAvailability(int itemId, int newStatus) {
    bool changed = false;
    for (var item in restaurantMenuItems) {
      if (item.id == itemId || item.restaurantMenuItemId == itemId) {
        item.availableStatus = newStatus;
        changed = true;
      }
    }
    for (var item in groceryMenuItems) {
      if (item.id == itemId || item.menuItemId == itemId) {
        item.availableStatus = newStatus;
        changed = true;
      }
    }
    if (changed) {
      update();
    }
  }

  Future<void> addGroceryMenuItem(
    BuildContext context, {
    required String menuId,
    required String attributeValue,
    required String groceryAttributeId,
    required String price,
    required String discountPrice,
    required String quantityAllowed,
    required String serialNumber,
  }) async {
    try {
      showLoadingDialog(context);

      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      }
      final dio.FormData formData = vendorType == "1"
          ? dio.FormData.fromMap({
              "menu_id": menuId,
              "attribute_value": attributeValue,
              "grocery_attribute_id": groceryAttributeId,
              "price": price,
              "discount_price": discountPrice,
              "quantity_allowed": quantityAllowed,
              "serial_number": serialNumber,
            })
          : dio.FormData.fromMap({
              "menu_id": menuId,
              "attribute_value": attributeValue,
              "serial_number": serialNumber,
              "quantity_allowed": quantityAllowed,
              "attributes[0][grocery_attribute_id]": groceryAttributeId,
              "attributes[0][attribute_value]": attributeValue,
              "attributes[0][retail_price]": price,
              "attributes[0][selling_price]": discountPrice,
            });
      final formattedFields = formData.fields
          .map((e) => "${e.key}: ${e.value}")
          .join("\n");
      final formattedFiles = formData.files
          .map((e) => "${e.key}: ${e.value.filename ?? 'file'}")
          .join("\n");
      debugPrint(
        "[ProfileController] addGroceryMenuItem formData\n"
        "vendorType=$vendorType\n"
        "fields:\n$formattedFields"
        "${formattedFiles.isNotEmpty ? "\nfiles:\n$formattedFiles" : ""}",
      );

      final response = await DioClient().post(
        vendorType == "1"
            ? ApiEndPoints.addRestaurantMenuItem
            : ApiEndPoints.addGroceryMenuItem,
        body: formData,
      );
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          showToast(context, "Grocery item added successfully");
          Get.back();
          fetchGroceryMenuItems();
        }
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ?? "Failed to add item",
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().post(ApiEndPoints.logout);
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ??
                "You are logged out successfully.",
          );
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await savename("@isFirstLaunch", "true");
        Get.offAll(const LoginScreen());
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ?? "Logout failed.",
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }

  Future<void> markLeave(
    BuildContext context,
    String fromDate,
    String toDate,
    String reason,
  ) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      var vendorType = await getSavedObject("vendorType");
      var formData = {
        "vendor_type": vendorType ?? "1",
        "from_date": fromDate,
        "to_date": toDate,
        if (reason.isNotEmpty) "reason": reason,
      };
      final response = await DioClient().post(
        ApiEndPoints.markLeave,
        body: formData,
      );
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          String successMessage = "Busy status updated successfully";
          final msg = response.data['message'];
          if (msg is String && msg.trim().isNotEmpty) {
            successMessage = msg.trim();
          } else if (msg is Map &&
              msg.containsKey('message_en') &&
              msg['message_en'] is List &&
              (msg['message_en'] as List).isNotEmpty) {
            successMessage = (msg['message_en'] as List).first.toString();
          }
          showToast(context, successMessage);
        }
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ??
                "Failed to update busy status",
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }

  Future<void> unmarkLeave(BuildContext context, String leave_id) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      var vendorType = await getSavedObject("vendorType");
      var formData = {"vendor_type": vendorType ?? "1", "leave_id": leave_id};
      final response = await DioClient().post(
        ApiEndPoints.unmarkLeave,
        body: formData,
      );
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          String successMessage = "Leave unmarked successfully";
          if (response.data['message'] != null) {
            var msgMap = response.data['message'];
            if (msgMap is Map &&
                msgMap.containsKey('message_en') &&
                msgMap['message_en'] is List &&
                msgMap['message_en'].isNotEmpty) {
              successMessage = msgMap['message_en'][0];
            }
          }
          showToast(context, successMessage);
          getProfile(context);
        }
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ?? "Failed to unmark leave",
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }

  Future<void> getProfile(
    BuildContext context, {
    int page = 1,
    int limit = 10,
    bool isLoadMore = false,
  }) async {
    try {
      if (isLoadMore) {
        isLoadMoreLeaveLoading = true;
      } else {
        isProfileLoading = true;
        currentLeavePage = 1;
        hasMoreLeaveHistory = true;
      }
      update();
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      var vendorType = await getSavedObject("vendorType");
      final response = await DioClient().get(
        ApiEndPoints.profile,
        query: {"vendor_type": vendorType ?? "1", "limit": limit, "page": page},
      );
      ProfileModel profileModel = ProfileModel.fromJson(response.data);
      if (profileModel.status == true) {
        if (isLoadMore) {
          if (profileModel.leaveHistory != null) {
            final newLeaves = profileModel.leaveHistory!;
            if (newLeaves.isEmpty) {
              hasMoreLeaveHistory = false;
            } else {
              leaveHistory.addAll(newLeaves);
              currentLeavePage = page;
              if (newLeaves.length < limit) {
                hasMoreLeaveHistory = false;
              }
            }
          } else {
            hasMoreLeaveHistory = false;
          }
        } else {
          profileData = profileModel.data;
          upcomingLeaves = profileModel.upcomingLeaves ?? [];
          leaveHistory = profileModel.leaveHistory ?? [];
          workingHours = profileModel.workingHours ?? [];
          nameController.text = profileData?.name ?? "";
          phoneController.text = profileData?.mobile ?? "";
          countryCode = profileData?.countryCode ?? "";
          profilePicture = profileData?.image ?? "";
          if (leaveHistory.length < limit) {
            hasMoreLeaveHistory = false;
          }
        }
      }
    } catch (error) {
      debugPrint("getProfile Error: $error");
    } finally {
      isProfileLoading = false;
      isLoadMoreLeaveLoading = false;
      update();
    }
  }

  Future<void> onGalleryTapped() async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        imageSource = pickedFile;
        profilePicture = pickedFile.path;
        update();
      }
    } catch (e) {
      debugPrint("Error picking image from gallery: $e");
    }
  }

  Future<void> onCameraTapped() async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        imageSource = pickedFile;
        profilePicture = pickedFile.path;
        update();
      }
    } catch (e) {
      debugPrint("Error picking image from camera: $e");
    }
  }

  /// The server's message in the app language, or [fallback].
  String _serverMessage(dynamic data, String fallback) {
    final message = data is Map ? data['message'] : null;
    if (message is! Map) return fallback;
    final lang = localization.currentLocale?.languageCode ?? 'en';
    final list = message['message_$lang'] ?? message['message_en'];
    if (list is List && list.isNotEmpty) return list.first.toString();
    return fallback;
  }

  bool _isSuccess(dynamic data) =>
      data is Map && (data['status'] == true || data['status'] == 'true');

  Future<void> _useSavedToken() async {
    final token = await getSavedObject("token");
    DioClient().updateToken(token?.toString() ?? "");
  }

  /// Sends a WhatsApp code to the new number (vendorapp/profile/sendOtp).
  Future<void> sendOtp(
    BuildContext context,
    String countryCode,
    String mobile,
  ) async {
    otpController.clear();
    isOtpSent = false;
    try {
      showLoadingDialog(context);
      await _useSavedToken();
      final response = await DioClient().post(
        ApiEndPoints.profileSendOtp,
        body: {"country_code": countryCode, "mobile": mobile},
      );
      if (context.mounted) Get.back();
      isOtpSent = _isSuccess(response.data);
      if (context.mounted) {
        showToast(
          context,
          _serverMessage(
            response.data,
            isOtpSent ? "Verification code sent" : "Could not send the code",
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("sendOtp error: $error");
    }
    update();
  }

  /// Saves the new number with its code, plus any name/photo change.
  Future<void> verifyOtp(
    BuildContext context,
    String countryCode,
    String mobile,
    String otp,
  ) async {
    if (otp.trim().length != 6) {
      showToast(context, "Enter the 6-digit code");
      return;
    }
    isOtpVerified = await _saveProfile(
      context,
      name: nameController.text.trim(),
      countryCode: countryCode,
      mobile: mobile,
      otp: otp.trim(),
    );
    if (isOtpVerified && context.mounted) {
      // Close the OTP dialog.
      Navigator.of(context).pop();
    }
    update();
  }

  /// Saves a name or photo change that doesn't touch the phone number.
  Future<void> postEditProfile(
    BuildContext context,
    String name,
    String countryCode,
    String mobile,
  ) async {
    await _saveProfile(context, name: name);
  }

  Future<bool> _saveProfile(
    BuildContext context, {
    required String name,
    String? countryCode,
    String? mobile,
    String? otp,
  }) async {
    try {
      showLoadingDialog(context);
      await _useSavedToken();
      final form = dio.FormData.fromMap({
        if (name.isNotEmpty) "name": name,
        if (mobile != null) "country_code": countryCode,
        "mobile": ?mobile,
        "otp": ?otp,
      });
      if (imageSource != null) {
        final path = imageSource!.path;
        form.files.add(
          MapEntry(
            "image",
            await dio.MultipartFile.fromFile(
              path,
              filename: path.split(RegExp(r'[/\\]')).last,
            ),
          ),
        );
      }
      final response = await DioClient().post(
        ApiEndPoints.profileUpdate,
        body: form,
      );
      if (context.mounted) Get.back();
      final ok = _isSuccess(response.data);
      if (context.mounted) {
        showToast(
          context,
          _serverMessage(
            response.data,
            ok ? "Profile updated" : "Could not update the profile",
          ),
        );
      }
      if (ok) {
        imageSource = null;
        if (context.mounted) await getProfile(context);
      }
      update();
      return ok;
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("saveProfile error: $error");
      update();
      return false;
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      }
      final response = await DioClient().get(ApiEndPoints.deleteAccount);
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        final languageCode = localization.currentLocale?.languageCode;
        final messageObj = response.data['message'];
        String? toastMessage;
        if (messageObj is Map) {
          final list = languageCode == 'fr'
              ? messageObj['message_fr']
              : languageCode == 'ar'
              ? messageObj['message_ar']
              : messageObj['message_en'];
          if (list is List && list.isNotEmpty) {
            toastMessage = list.first.toString();
          }
        }
        if (context.mounted) {
          showToast(context, toastMessage ?? "Account deleted successfully");
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await savename("@isFirstLaunch", "true");
        Get.offAll(LoginScreen());
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ?? "Delete account failed.",
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("deleteAccount Error: $error");
    }
  }

  Future<void> getMyPoints(BuildContext context) async {
    try {
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Get.back();
      }
      points = 100.0;
      redeemableAmount = 10.0;
      update();
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("getMyPoints Mock Error: $error");
    }
  }

  Future<void> getNotificationStatus(BuildContext context) async {
    try {
      notificationEnabled = true;
      update();
    } catch (error) {
      debugPrint("getNotificationStatus Mock Error: $error");
    }
  }

  Future<void> updateNotificationStatus(BuildContext context) async {
    try {
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Get.back();
        showToast(context, "Notification status updated successfully (Mock)");
      }
      update();
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("updateNotificationStatus Mock Error: $error");
    }
  }

  Future<void> getAllCategories({int? categoryId}) async {
    debugPrint(
      "[ProfileController] getAllCategories:start prevCount=${restaurantCategories.length} selectedCategoryId=$selectedRestaurantCategoryId",
    );
    isRestaurantCategoriesLoading = true;
    restaurantCategories = [];
    selectedRestaurantCategoryId = null;
    update();
    try {
      var token = await getSavedObject("token");
      final rawVendorType = (await getSavedObject("vendorType"))?.toString();
      final currentVendorType =
          (rawVendorType != null && rawVendorType.isNotEmpty)
              ? rawVendorType
              : vendorType;
      final isGrocery = currentVendorType == "2";
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }

      if (!isGrocery) {
        try {
          final response = await DioClient().get(
            ApiEndPoints.menuCategories,
            query: {'limit': 100},
          );
          if (response.data is Map<String, dynamic>) {
            final model = RestaurantAllCategoriesModel.fromJson(response.data);
            if (model.data != null && model.data!.isNotEmpty) {
              restaurantCategories = model.data!;
              debugPrint(
                "[ProfileController] menuCategories success count=${restaurantCategories.length}",
              );
            }
          }
        } catch (e) {
          debugPrint("[ProfileController] menuCategories error: $e");
        }

        if (restaurantCategories.isEmpty) {
          try {
            final response = await DioClient().get(
              ApiEndPoints.getRestaurantCategories,
              query: {'limit': 100},
            );
            if (response.data is Map<String, dynamic>) {
              final model = RestaurantAllCategoriesModel.fromJson(response.data);
              if (model.data != null && model.data!.isNotEmpty) {
                restaurantCategories = model.data!;
                debugPrint(
                  "[ProfileController] getRestaurantCategories success count=${restaurantCategories.length}",
                );
              }
            }
          } catch (e) {
            debugPrint("[ProfileController] getRestaurantCategories error: $e");
          }
        }
      } else {
        final response = await DioClient().get(
          ApiEndPoints.getGroceryCategories,
          query: {'limit': 100},
        );
        final groceryCategoriesModel = GroceryAllCategoriesModel.fromJson(
          response.data,
        );
        if (groceryCategoriesModel.status == true) {
          restaurantCategories = (groceryCategoriesModel.data ?? [])
              .map(
                (c) => RestaurantCategoryData.fromJson({
                  "id": c.id ?? 0,
                  "name_en": c.nameEn ?? "",
                  "name_ar": c.nameAr ?? "",
                  "name_fr": c.nameFr ?? "",
                  "image": c.image ?? "",
                }),
              )
              .toList();
        }
      }
    } catch (error) {
      debugPrint("[ProfileController] getAllCategories:error $error");
    } finally {
      isRestaurantCategoriesLoading = false;
      debugPrint(
        "[ProfileController] getAllCategories:done finalCount=${restaurantCategories.length} loading=$isRestaurantCategoriesLoading",
      );
      update();
    }
  }

  Future<void> getRestaurantMenuDetails({int? restaurantMenuId}) async {
    try {
      isRestaurantMenuDetailsLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(
        vendorType == "1"
            ? ApiEndPoints.getRestaurantMenuDetails
            : ApiEndPoints.getGroceryMenuDetails,
        query: vendorType == "1"
            ? restaurantMenuId != null
                  ? {'restaurant_menu_id': restaurantMenuId}
                  : null
            : {'grocery_menu_id': restaurantMenuId ?? 0},
      );
      if (vendorType == "1") {
        final restaurantMenuDetailsModel = RestaurantMenuDetailsModel.fromJson(
          response.data,
        );
        if (restaurantMenuDetailsModel.status) {
          restaurantMenuDetails = restaurantMenuDetailsModel.data;
        }
      } else {
        final groceryMenuDetailsModel = GroceryMenuDetailsModel.fromJson(
          response.data,
        );

        if (groceryMenuDetailsModel.status == true &&
            groceryMenuDetailsModel.data != null &&
            groceryMenuDetailsModel.data!.groceryMenu != null) {
          final groceryMenu = groceryMenuDetailsModel.data!.groceryMenu!;

          final categoriesJson = (groceryMenu.categories ?? [])
              .map(
                (c) => {
                  "id": c.id ?? 0,
                  "name_en": c.nameEn ?? "",
                  "name_ar": c.nameAr ?? "",
                  "name_fr": c.nameFr ?? "",
                  "image": c.image ?? "",
                  "status": c.status ?? 0,
                  "deleted_at": c.deletedAt?.toString(),
                  "created_at": c.createdAt ?? "",
                  "updated_at": c.updatedAt ?? "",
                },
              )
              .toList();
          // Extract raw data first to avoid ?[] inside map literals (causes parser errors)
          final rawDataPc = (response.data is Map<String, dynamic>)
              ? response.data as Map<String, dynamic>
              : <String, dynamic>{};
          final rawGroceryMenuPc = (rawDataPc['data'] is Map)
              ? (rawDataPc['data'] as Map)['grocery_menu']
              : null;
          final rawGroceryMenuMapPc = rawGroceryMenuPc is Map
              ? Map<String, dynamic>.from(rawGroceryMenuPc)
              : <String, dynamic>{};

          final rawMenuItemDetailsPc = (rawDataPc['data'] is Map)
              ? (rawDataPc['data'] as Map)['menu_item_details']
              : null;
          final rawMenuItemDetailsMapPc = rawMenuItemDetailsPc is Map
              ? Map<String, dynamic>.from(rawMenuItemDetailsPc)
              : <String, dynamic>{};

          final converted = {
            "status": true,
            "message": groceryMenuDetailsModel.message ?? "",
            "data": {
              "restaurant_menu": {
                "id": groceryMenu.id ?? 0,
                "category_id": groceryMenu.categoryId ?? "",
                "restaurant_id": 0,
                "name_en": groceryMenu.nameEn ?? "",
                "name_ar": groceryMenu.nameAr ?? "",
                "name_fr": groceryMenu.nameFr ?? "",
                "description_en": groceryMenu.descriptionEn ?? "",
                "description_ar": groceryMenu.descriptionAr ?? "",
                "description_fr": groceryMenu.descriptionFr ?? "",
                "image": groceryMenu.image ?? "",
                "is_veg": groceryMenu.isVeg ?? 0,
                "approval_status": groceryMenu.approvalStatus ?? 0,
                "deleted_at": groceryMenu.deletedAt?.toString(),
                "created_at": groceryMenu.createdAt ?? "",
                "updated_at": groceryMenu.updatedAt ?? "",
                "category_name_en": groceryMenu.categoryNameEn ?? "",
                "category_name_ar": groceryMenu.categoryNameAr ?? "",
                "category_name_fr": groceryMenu.categoryNameFr ?? "",
                "categories": categoriesJson,
                "attributes": rawGroceryMenuMapPc['attributes'] ?? [],
                "price":
                    (rawMenuItemDetailsMapPc['price'] ??
                            rawGroceryMenuMapPc['retail_price'])
                        ?.toString(),
                "discount_price":
                    (rawMenuItemDetailsMapPc['discount_price'] ??
                            rawGroceryMenuMapPc['selling_price'])
                        ?.toString(),
                "preparation_time":
                    (rawMenuItemDetailsMapPc['preparation_time'] ??
                            rawMenuItemDetailsMapPc['prep_time'] ??
                            rawGroceryMenuMapPc['preparation_time'] ??
                            rawGroceryMenuMapPc['prep_time'])
                        ?.toString(),
                "quantity_allowed":
                    rawMenuItemDetailsMapPc['quantity_allowed'] ??
                    rawGroceryMenuMapPc['quantity_allowed'],
              },
              "total_orders": groceryMenuDetailsModel.data!.totalOrders ?? 0,
              "total_revenue": groceryMenuDetailsModel.data!.totalRevenue ?? 0,
              "average_rating":
                  groceryMenuDetailsModel.data!.averageRating ?? 0,
              "total_rating_count":
                  groceryMenuDetailsModel.data!.totalRatingCount ?? 0,
              "order_details": groceryMenuDetailsModel.data!.orderDetails ?? [],
            },
          };

          final restaurantMenuDetailsModel =
              RestaurantMenuDetailsModel.fromJson(converted);
          if (restaurantMenuDetailsModel.status) {
            restaurantMenuDetails = restaurantMenuDetailsModel.data;
          }
        }
      }
    } catch (error) {
      debugPrint("getRestaurantMenuDetails Error: $error");
    } finally {
      isRestaurantMenuDetailsLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
    }
  }

  Future<void> downloadRestaurantCatalogTemplate(BuildContext context) async {
    debugPrint("downloadRestaurantCatalogTemplate:start");
    try {
      isRestaurantBulkTemplateDownloading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => update());

      final token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }

      final response = await DioClient().dio.get<List<int>>(
        ApiEndPoints.downloadRestaurantCatalogTemplate,
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
          headers: {
            'Accept':
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, '
                'application/vnd.ms-excel, application/octet-stream, */*',
          },
          validateStatus: (code) => code != null && code < 600,
        ),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        if (context.mounted) {
          showToast(context, 'Empty template response');
        }
        return;
      }
      final contentType =
          response.headers.value('content-type')?.toLowerCase() ?? '';
      final looksLikeZipXlsx =
          bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B;
      final maybeJsonBody =
          !looksLikeZipXlsx &&
          (contentType.contains('json') ||
              (bytes.isNotEmpty && bytes[0] == 0x7B));
      if (maybeJsonBody) {
        final asText = utf8.decode(bytes, allowMalformed: true);
        final trimmed = asText.trimLeft();
        if (contentType.contains('json') || trimmed.startsWith('{')) {
          try {
            final map = jsonDecode(asText);
            if (map is Map) {
              final msg =
                  map['message']?.toString() ??
                  map['error']?.toString() ??
                  'Could not download template';
              if (context.mounted) showToast(context, msg);
            }
          } catch (_) {
            if (context.mounted) {
              showToast(context, 'Unexpected response (not Excel file)');
            }
          }
          return;
        }
      }
      if (response.statusCode != null && response.statusCode! >= 400) {
        if (context.mounted) {
          final msg = maybeJsonBody
              ? utf8.decode(bytes, allowMalformed: true).trim()
              : '';
          showToast(
            context,
            msg.isNotEmpty ? msg : 'Download failed (${response.statusCode})',
          );
        }
        return;
      }
      final fileName =
          'restaurant_catalog_template_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      Directory? targetDir;
      if (Platform.isAndroid) {
        final downloads = Directory('/storage/emulated/0/Download');
        if (!await downloads.exists()) {
          await downloads.create(recursive: true);
        }
        if (await downloads.exists()) targetDir = downloads;
      } else if (Platform.isIOS) {
        targetDir = await getApplicationDocumentsDirectory();
      }
      targetDir ??= await getApplicationDocumentsDirectory();

      File file = File('${targetDir.path}/$fileName');
      try {
        await file.writeAsBytes(bytes, flush: true);
      } catch (_) {
        final fallbackDir = await getApplicationDocumentsDirectory();
        file = File('${fallbackDir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);
      }

      if (context.mounted) {
        showToast(context, 'Saved: ${file.path}');
        await OpenFilex.open(file.path);
      }
    } catch (error) {
      debugPrint('downloadRestaurantCatalogTemplate Error: $error');
      if (context.mounted) {
        showToast(context, error.toString());
      }
    } finally {
      isRestaurantBulkTemplateDownloading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
    }
  }

  Future<void> importRestaurantMenuItems(BuildContext context) async {
    return downloadRestaurantCatalogTemplate(context);
  }

  /// Rows the last catalog import rejected (shown after the loader closes).
  List<String> pendingImportErrors = const [];

  Future<bool> importRestaurantCatalogItems(
    BuildContext context,
    String filePath,
    int categoryId,
  ) async {
    var success = false;
    try {
      showLoadingDialog(context);
      isRestaurantMenuDetailsLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final multipartFile = await dio.MultipartFile.fromFile(filePath);
      final formData = dio.FormData.fromMap({
        "category_id": categoryId,
        "file": multipartFile,
      });
      debugPrint("FormData (importRestaurantCatalogItems):");
      for (final e in formData.fields) {
        debugPrint("  field ${e.key}: ${e.value}");
      }
      for (final e in formData.files) {
        debugPrint("  file ${e.key}: ${e.value.filename}");
      }
      // Read 422 bodies too: they list the rows to fix (`data.errors`).
      final response = await DioClient().dio.post(
        ApiEndPoints.importRestaurantCatalogItems,
        data: formData,
        options: dio.Options(
          contentType: dio.Headers.multipartFormDataContentType,
          validateStatus: (code) => code != null && code < 500,
        ),
      );
      final raw = response.data;
      if (raw is! Map) {
        if (context.mounted) {
          showToast(context, 'Invalid server response');
        }
      } else {
        final map = Map<String, dynamic>.from(raw);
        final ok = map['status']?.toString() == 'true' || map['status'] == true;
        if (ok) {
          if (map['data'] is List) {
            try {
              final list = (map['data'] as List)
                  .map((e) => RestaurantMenuItemData.fromJson(
                      e as Map<String, dynamic>?))
                  .whereType<RestaurantMenuItemData>()
                  .toList();
              if (list.isNotEmpty) {
                restaurantMenuItems = list;
              }
            } catch (_) {}
          }
          try {
            final restaurantMenuDetailsModel =
                RestaurantMenuDetailsModel.fromJson(map);
            if (restaurantMenuDetailsModel.data != null) {
              restaurantMenuDetails = restaurantMenuDetailsModel.data;
            }
          } catch (_) {}
          await fetchRestaurantMenus(keyword: '');
          await fetchGroceryMenuItems(categoryId: categoryId);
          if (context.mounted) {
            final msg = _bulkImportSuccessMessage(map);
            showToast(context, msg);
          }
          success = true;
        } else if (context.mounted) {
          final data = map['data'];
          final rowErrors = data is Map && data['errors'] is List
              ? (data['errors'] as List).map((e) => e.toString()).toList()
              : const <String>[];
          if (rowErrors.isNotEmpty) {
            pendingImportErrors = rowErrors;
          } else {
            showToast(
              context,
              _extractErrorMessage(map['message']),
            );
          }
        }
      }
    } catch (error) {
      debugPrint('importRestaurantCatalogItems Error: $error');
      if (context.mounted) {
        showToast(context, error.toString());
      }
    } finally {
      if (context.mounted) {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) nav.pop();
      }
      isRestaurantMenuDetailsLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
    }
    if (pendingImportErrors.isNotEmpty && context.mounted) {
      final rows = pendingImportErrors;
      pendingImportErrors = const [];
      await showImportErrorsDialog(context, rows);
    }
    return success;
  }

  Future<bool> uploadmenuBulkImport(
    BuildContext context,
    String filePath,
    int categoryId,
  ) =>
      importRestaurantCatalogItems(context, filePath, categoryId);

  String _extractErrorMessage(dynamic message) {
    if (message is Map) {
      final errors = <String>[];
      for (final entry in message.entries) {
        final val = entry.value;
        if (val is List && val.isNotEmpty) {
          errors.add(val.first.toString());
        } else if (val != null) {
          errors.add(val.toString());
        }
      }
      if (errors.isNotEmpty) return errors.join("\n");
    }
    if (message is String && message.isNotEmpty) return message;
    return 'Bulk upload failed';
  }

  String _bulkImportSuccessMessage(Map<String, dynamic> map) {
    final msg = map['message'];
    if (msg is Map) {
      for (final key in ['message_en', 'message', 'success']) {
        final v = msg[key];
        if (v is List && v.isNotEmpty) return v.first.toString();
        if (v is String && v.isNotEmpty) return v;
      }
    }
    if (msg is String && msg.isNotEmpty) return msg;
    return 'Bulk menu uploaded successfully';
  }

  Future<void> uploadImages(BuildContext context) async {
    try {
      isRestaurantCategoriesLoading = true;
      update();
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (bottomSheetContext) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Gallery'),
                  onTap: () =>
                      Navigator.pop(bottomSheetContext, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Camera'),
                  onTap: () =>
                      Navigator.pop(bottomSheetContext, ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );
      if (source == null) {
        return;
      }
      final XFile? pickedFile = await imagePicker.pickImage(source: source);
      if (pickedFile == null) {
        return;
      }
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final filename = pickedFile.path.split(RegExp(r'[/\\]')).last;
      dio.MultipartFile? uploadFile;
      try {
        debugPrint("[ProfileController] Enhancing image using imageEnhance endpoint...");
        final enhancedBytes = await DioClient().enhanceImageBytes(pickedFile.path, filename);
        if (enhancedBytes != null) {
          uploadFile = dio.MultipartFile.fromBytes(
            enhancedBytes,
            filename: 'enhanced_$filename',
          );
          debugPrint("[ProfileController] Image enhanced successfully!");
        }
      } catch (e) {
        debugPrint("[ProfileController] Image enhancement failed: $e.");
        rethrow;
      }

      final formData = dio.FormData.fromMap({
        "file": uploadFile,
      });
      final response = await DioClient().post(
        vendorType == "1"
            ? ApiEndPoints.uploadRestaurantImages
            : ApiEndPoints.uploadGroceryImages,
        body: formData,
      );
      if (context.mounted) {
        if (response.data['status'] == 'true' ||
            response.data['status'] == true) {
          showToast(
            context,
            response.data['message']?.toString() ??
                'Image uploaded successfully',
          );
        } else {
          showToast(
            context,
            response.data['message']?.toString() ?? 'Image upload failed',
          );
        }
      }
    } catch (error) {
      debugPrint("uploadImages Error: $error");
      if (context.mounted) {
        showToast(context, error.toString());
      }
    } finally {
      isRestaurantCategoriesLoading = false;
      update();
    }
  }

  Future<void> uploadWorkingHours(BuildContext context) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final vendorTypeInt = int.tryParse(vendorType?.toString() ?? '') ?? 1;
      String normalizeTime(String? raw) {
        if (raw == null) return '';
        final v = raw.trim();
        if (v.isEmpty) return '';
        if (v.length >= 5 && v[2] == ':') return v.substring(0, 5);
        return v;
      }

      WorkingHour? findHourForDay(int dayId) {
        final byDayOfWeek = workingHours.cast<WorkingHour?>().firstWhere(
          (h) => h?.dayOfWeek == dayId,
          orElse: () => null,
        );
        if (byDayOfWeek != null) return byDayOfWeek;
        final aliases = [
          ['mon', 'monday'],
          ['tue', 'tuesday'],
          ['wed', 'wednesday'],
          ['thu', 'thursday'],
          ['fri', 'friday'],
          ['sat', 'saturday'],
          ['sun', 'sunday'],
        ];
        final idx = dayId - 1;
        if (idx < 0 || idx >= 7) return null;
        final dayAliases = aliases[idx];
        final byName = workingHours.cast<WorkingHour?>().firstWhere((h) {
          final raw = h?.day?.toLowerCase().trim() ?? '';
          if (raw.isEmpty) return false;
          return dayAliases.any((a) => raw == a || raw.contains(a));
        }, orElse: () => null);
        return byName;
      }

      final daysPayload = List.generate(7, (i) {
        final dayId = i + 1;
        final h = findHourForDay(dayId);
        if (h == null) {
          return {"day_id": dayId, "is_24h": 1, "hours": <dynamic>[]};
        }
        final isOpen24 = h.isOpen24h == 1;
        if (isOpen24) {
          return {"day_id": dayId, "is_24h": 1, "hours": <dynamic>[]};
        }
        final slots = (h.timeSlots != null && h.timeSlots!.isNotEmpty)
            ? h.timeSlots!
            : null;
        final hoursPayload = <Map<String, String>>[];
        if (slots != null) {
          for (final s in slots) {
            final open = normalizeTime(s.openTime);
            final close = normalizeTime(s.closeTime);
            if (open.isEmpty || close.isEmpty) continue;
            hoursPayload.add({"open_time": open, "close_time": close});
          }
        } else {
          final open = normalizeTime(h.openingTime);
          final close = normalizeTime(h.closingTime);
          if (open.isNotEmpty && close.isNotEmpty) {
            hoursPayload.add({"open_time": open, "close_time": close});
          }
        }
        return {"day_id": dayId, "is_24h": 2, "hours": hoursPayload};
      });

      final payload = {
        "vendor_type": vendorTypeInt == 0 ? 1 : vendorTypeInt,
        "days": daysPayload,
      };

      final formData = dio.FormData.fromMap(payload);
      final response = await DioClient().post(
        ApiEndPoints.uploadWorkingHours,
        body: formData,
      );
      if (context.mounted) {
        Get.back();
        if (response.data['status'] == 'true' ||
            response.data['status'] == true) {
          final languageCode = localization.currentLocale?.languageCode;
          final messageObj = response.data['message'];
          String toastMessage = 'Working hours updated successfully';
          if (messageObj is Map) {
            final key = languageCode == 'fr'
                ? 'message_fr'
                : languageCode == 'ar'
                ? 'message_ar'
                : 'message_en';
            final raw = messageObj[key];
            if (raw is List && raw.isNotEmpty) {
              toastMessage = raw.first.toString();
            } else if (raw != null) {
              toastMessage = raw.toString();
            }
          } else if (messageObj != null) {
            toastMessage = messageObj.toString();
          }
          showToast(context, toastMessage);
          debugPrint("Working hours updated successfully: $toastMessage");
          getProfile(context);
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("getMyPoints Mock Error: $error");
    }
  }

  Future<void> updateBusyStatus(BuildContext context, int status) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      var formData = {"is_busy": status};
      final response = await DioClient().post(
        ApiEndPoints.updateBusyMode,
        body: formData,
      );
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          String successMessage = "Busy status updated successfully";
          if (response.data['message'] != null) {
            var msgMap = response.data['message'];
            if (msgMap is Map &&
                msgMap.containsKey('message_en') &&
                msgMap['message_en'] is List &&
                msgMap['message_en'].isNotEmpty) {
              successMessage = msgMap['message_en'][0];
            }
          }
          showToast(context, successMessage);
        }
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ?? "Failed to mark leave",
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }
}

class RestaurantCategory {
  int? id;
  String? name;
  RestaurantCategory({this.id, this.name});
}
