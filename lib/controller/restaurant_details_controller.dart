import 'package:flutter/cupertino.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/model/restaurant_details_model.dart';

import '../utils/utils.dart';
import '../model/restaurant_categories_model.dart';
import '../model/restaurant_items_model.dart';

class RestaurantDetailsController extends GetxController {
  // Categories variables
  List<CategoryData> categoriesList = [];
  bool isLoadingCategories = false;

  final FlutterLocalization localization = FlutterLocalization.instance;
  TextEditingController searchController = TextEditingController();

  int currentIndex = 0;
  int selectedcurrentIndex = 0;
  String categoryId = '';
  String restaurantId = '';
  List<MenuItem> restaurantItemsList = [];
  RestaurantItemsModel? data;
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
  int selectedPortion = 0;
  double selectedVariantPrice = 0; // Store the selected variant price
  int qty = 1;
  double totalPrice = 0;

  String vendorName = '';
  String vendorImage = '';
  String productType = '';
  String currentCartTotal = '';
  String currentCartItemsCount = '';
  RestaurantDetailsData? restaurantData;

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
    getRestaurantItems();
  }

  // Clear specific filters
  void clearOffersFilter() {
    offers = "";
    selectedOfferFilter = null;
    getRestaurantItems();
  }

  void clearVegFilter() {
    veg = "";
    getRestaurantItems();
  }

  void clearNonVegFilter() {
    nonVeg = "";
    getRestaurantItems();
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
    getRestaurantItems();
  }

  List<String> sortOptions = [
    "Relevance",
    "Delivery Time",
    "Cost: Low to High",
    "Cost: High to Low",
  ];

  getTotalPrice() {
    totalPrice = (selectedVariantPrice) * qty;
    update();
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.position.extentAfter < 300) {
      isLoadMoreRunning = true;
      update();

      await Future.delayed(const Duration(seconds: 1));
      // Mock: No more pages
      _hasNextPage = false;

      isLoadMoreRunning = false;
      update();
    }
  }

  Future<void> getRestaurantItems() async {
    try {
      isFirstLoadRunning = true;
      update();
      await Future.delayed(const Duration(seconds: 1));

      // Mock data setup
      restaurantItemsList = [];
      _hasNextPage = false;

      isFirstLoadRunning = false;
      update();
    } catch (e) {
      isFirstLoadRunning = false;
      update();
      debugPrint('Mock getRestaurantItems error: $e');
    }
  }

  Future<RestaurantItemsModel?> getRestaurantItemsApi(
    int limit,
    int page,
  ) async {
    return null; // Neutralized
  }

  // Fetch categories from API
  Future<void> fetchCategories(
    BuildContext? context,
    String restaurantId,
    String keyword,
  ) async {
    try {
      isLoadingCategories = true;
      update();
      await Future.delayed(const Duration(seconds: 1));

      // Mock categories setup
      categoriesList = [];

      isLoadingCategories = false;
      update();
    } catch (error) {
      isLoadingCategories = false;
      update();
      debugPrint("Fetch categories mock error: $error");
    }
  }

  // Fetch RestaurantDetails from API
  Future<void> fetchRestaurantDetails(
    BuildContext? context,
    String restaurantId,
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Mock details
      update();
    } catch (error) {
      debugPrint("Fetch restaurant details mock error: $error");
    }
  }

  Future<void> addToRestaurantCart(
    BuildContext context,
    String restaurantId,
    String productId,
    String quantity,
  ) async {
    try {
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        Get.back(); // close loading
        showToast(context, "Added to cart successfully (Mock)");
        Get.back(); // go back
        getCartCount(context);
      }
      update();
    } catch (error) {
      if (context.mounted) {
        Get.back();
      }
      debugPrint("cart add mock Error: $error");
    }
  }

  Future<void> replaceCart(BuildContext context, String type) async {
    try {
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        Get.back(); // close loading
        showToast(context, "Cart replaced successfully (Mock)");
        getCartCount(context);
        if (type == "replace") {
          getRestaurantItems();
        }
      }
      update();
    } catch (error) {
      if (context.mounted) {
        Get.back();
      }
      debugPrint("cart replace mock Error: $error");
    }
  }

  Future<void> getCartCount(BuildContext context) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Mock cart count setup
      vendorName = '';
      currentCartTotal = '0';
      currentCartItemsCount = '0';

      update();
    } catch (error) {
      debugPrint("cart count mock Error: $error");
    }
  }
}
