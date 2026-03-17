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
import 'package:saimpex_vendor/model/restaurant_menu_details_model.dart' hide RestaurantMenu;
import 'package:saimpex_vendor/model/restaurant_menus_model.dart';
import 'package:saimpex_vendor/model/restaurant_menu_items_model.dart';
import 'package:saimpex_vendor/view/Login/login.dart';

import '../Utils/Utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';

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

  @override
  void onInit() {
    getAppVersion();
    scrollController.addListener(_loadMore);
    super.onInit();
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

  List<RestaurantCategoryData> restaurantCategories = [];
  bool isRestaurantCategoriesLoading = false;
  int? selectedRestaurantCategoryId;

  List<RestaurantCategory> get restaurantCategoriesForDropdown =>
      restaurantCategories
          .map((d) => RestaurantCategory(id: d.id, name: d.nameEn ?? ''))
          .toList();

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
      if (token != null) {
        DioClient().updateToken(token);
      }
      final response = await DioClient().get(
        ApiEndPoints.restaurantMenus,
        query: {
          "limit": _limit,
          "page": _page,
          if (_currentMenuKeyword.isNotEmpty) "keyword": _currentMenuKeyword,
          if (selectedRestaurantCategoryId != null)
            "category_id": selectedRestaurantCategoryId,
        },
      );
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
        }

        if (fetchedMenus.length < _limit) {
          _hasNextPage = false;
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
    int status = 1,
  }) async {
    try {
      isGroceryMenuItemsLoading = true;
      update();

      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      }

      final response = await DioClient().get(
        ApiEndPoints.groceryMenuItems,
        query: {"limit": limit, "page": page, "status": status},
      );

      final model = GroceryMenuItemsModel.fromJson(response.data);
      if (model.status == true) {
        groceryMenuItems = model.data?.groceryMenuItems?.data ?? [];
      }
    } catch (error) {
      debugPrint("fetchGroceryMenuItems Error: $error");
    } finally {
      isGroceryMenuItemsLoading = false;
      update();
    }
  }

  Future<void> fetchRestaurantMenuItems({int limit = 10, int page = 1}) async {
    try {
      isRestaurantMenuItemsLoading = true;
      update();

      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      }

      final response = await DioClient().get(
        ApiEndPoints.restaurantMenuItems,
        query: {"limit": limit, "page": page},
      );

      final model = RestaurantMenuItemsModel.fromJson(response.data);
      if (model.status == true) {
        restaurantMenuItems = model.data?.restaurantMenuItems?.data ?? [];
      }
    } catch (error) {
      debugPrint("fetchRestaurantMenuItems Error: $error");
    } finally {
      isRestaurantMenuItemsLoading = false;
      update();
    }
  }

  Future<void> addGroceryMenu(
    BuildContext context, {
    required List<String> categoryIds,
    required String nameEn,
    required String descriptionEn,
    required List<String> tags,
    required String serialNumber,
    required String quantityAllowed,
    required List<Map<String, dynamic>> attributes,
    required String imagePath,
  }) async {
    try {
      showLoadingDialog(context);

      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      }

      Map<String, dynamic> formDataMap = {
        "name_en": nameEn,
        "description_en": descriptionEn,
        "serial_number": serialNumber,
        "quantity_allowed": quantityAllowed,
        "image": await dio.MultipartFile.fromFile(imagePath),
      };

      for (int i = 0; i < attributes.length; i++) {
        attributes[i].forEach((key, value) {
          formDataMap["attributes[$i][$key]"] = value.toString();
        });
      }

      dio.FormData formData = dio.FormData.fromMap(formDataMap);

      for (var id in categoryIds) {
        formData.fields.add(MapEntry("category_id[]", id));
      }

      for (var tag in tags) {
        formData.fields.add(MapEntry("tags[]", tag));
      }

      final response = await DioClient().post(
        ApiEndPoints.addGroceryMenu,
        body: formData,
      );

      if (context.mounted) {
        Get.back(); // close dialog
      }

      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          showToast(context, "Grocery menu added successfully");
          Get.back(); // go back to menu list
          fetchGroceryMenus(); // refresh list
        }
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ?? "Failed to add menu",
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
      if (token != null) {
        DioClient().updateToken(token);
      }

      dio.FormData formData = dio.FormData.fromMap({
        "menu_id": menuId,
        "attribute_value": attributeValue,
        "grocery_attribute_id": groceryAttributeId,
        "price": price,
        "discount_price": discountPrice,
        "quantity_allowed": quantityAllowed,
        "serial_number": serialNumber,
      });

      final response = await DioClient().post(
        ApiEndPoints.addGroceryMenuItem,
        body: formData,
      );

      if (context.mounted) {
        Get.back(); // close loading dialog
      }

      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          showToast(context, "Grocery item added successfully");
          Get.back(); // go back to items list
          fetchGroceryMenuItems(); // refresh list
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
        Get.back(); // close dialog
      }

      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          String successMessage = "Leave marked successfully";
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

  Future<void> sendOtp(
    BuildContext context,
    String countryCode,
    String mobile,
  ) async {
    try {
      otpController.clear();
      await Future.delayed(const Duration(seconds: 1));
      showToast(context, "OTP sent successfully (Mock)");
      isOtpSent = true;
      update();
    } catch (error) {
      debugPrint("Otp Mock Error: $error");
      isOtpSent = false;
      update();
    }
  }

  Future<void> verifyOtp(
    BuildContext context,
    String countryCode,
    String mobile,
    String otp,
  ) async {
    try {
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Get.back(); // Close loading dialog
        showToast(context, "OTP Verified successfully (Mock)");
        await postEditProfile(
          context,
          nameController.text,
          countryCode,
          phoneController.text,
        );
        isOtpVerified = true;
        Navigator.of(context).pop();
      }
      update();
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("verify otp Mock Error: $error");
      isOtpVerified = false;
    }
  }

  Future<void> postEditProfile(
    BuildContext context,
    String name,
    String countryCode,
    String mobile,
  ) async {
    try {
      // showLoadingDialog(context); // Already showing or not needed for mock
      await Future.delayed(const Duration(seconds: 1));
      showToast(context, "Profile updated successfully (Mock)");
      isOtpSent = true;
      imageSource = null;
      update();
    } catch (error) {
      debugPrint("postEditProfile Mock Error: $error");
      isOtpSent = false;
      update();
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
    try {
      isRestaurantCategoriesLoading = true;
      update();

      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(
        ApiEndPoints.getRestaurantCategories,
      );
      final restaurantCategoriesModel = RestaurantAllCategoriesModel.fromJson(
        response.data,
      );
      if (restaurantCategoriesModel.status == 'true') {
        restaurantCategories = restaurantCategoriesModel.data ?? [];
      }
    } catch (error) {
      debugPrint("getAllCategories Error: $error");
    } finally {
      isRestaurantCategoriesLoading = false;
      update();
    }
  }

  void setSelectedRestaurantCategoryId(int? id) {
    selectedRestaurantCategoryId = id;
    update();
  }

  Future<void> getRestaurantMenuDetails({int? restaurantMenuId}) async {
    try {
      isRestaurantMenuDetailsLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(
        ApiEndPoints.getRestaurantMenuDetails,
        query: restaurantMenuId != null
            ? {'restaurant_menu_id': restaurantMenuId}
            : null,
      );
      final restaurantMenuDetailsModel = RestaurantMenuDetailsModel.fromJson(response.data);
      if (restaurantMenuDetailsModel.status) {
        this.restaurantMenuDetails = restaurantMenuDetailsModel.data;
      }
    } catch (error) {
      debugPrint("getRestaurantMenuDetails Error: $error");
    } finally {
      isRestaurantMenuDetailsLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
    }
  }

  
}

class RestaurantCategory {
  int? id;
  String? name;
  RestaurantCategory({this.id, this.name});
}
