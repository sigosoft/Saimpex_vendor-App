import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/home_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';

class PharmacyHomeController extends GetxController {
  bool isStoreOpen = true;
  int selectedOrderType = 0;
  int selectedFilterIndex = 0;
  int bottomNavIndex = 0;
  final searchController = TextEditingController();

  HomeModel? homeData;
  bool isLoadingHome = false;
  List<OrderData> ordersList = [];
  Map<String, dynamic>? rawSummary;
  Map<String, dynamic>? rawVendor;

  final prescriptionFilters = const [
    'New Orders',
    'Under Review',
    'Review Completed',
    'Awaiting Payment',
    'To Prepare',
    'Preparing',
    'Ready',
    'Delivered',
  ];

  final otcFilters = const [
    'New Orders',
    'Accepted',
    'Preparing',
    'Ready',
    'Delivered',
    'Cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchPharmacyHome();
  }

  bool get isOtcTab => selectedOrderType == 1;

  List<String> get activeFilters =>
      isOtcTab ? otcFilters : prescriptionFilters;

  int get currentOrderStatus {
    if (isOtcTab) {
      switch (selectedFilterIndex) {
        case 0:
          return 1; // New Orders
        case 1:
          return 2; // Accepted
        case 2:
          return 3; // Preparing
        case 3:
          return 4; // Ready
        case 4:
          return 9; // Delivered
        case 5:
          return 10; // Cancelled
        default:
          return 1;
      }
    } else {
      switch (selectedFilterIndex) {
        case 0:
          return 1; // New Orders
        case 1:
          return 2; // Under Review
        case 2:
          return 3; // Review Completed
        case 3:
          return 4; // Awaiting Payment
        case 4:
          return 5; // To Prepare
        case 5:
          return 6; // Preparing
        case 6:
          return 7; // Ready
        case 7:
          return 8; // Delivered
        default:
          return 1;
      }
    }
  }

  String get filterBadgeLabel {
    if (ordersList.isNotEmpty) {
      return ordersList.length < 10
          ? '0${ordersList.length}'
          : '${ordersList.length}';
    }
    return '';
  }

  String? get prescriptionBadge => !isOtcTab && ordersList.isNotEmpty
      ? ordersList.length.toString()
      : null;

  String? get otcBadge => isOtcTab && ordersList.isNotEmpty
      ? ordersList.length.toString()
      : null;

  String get newPrescriptionsCount {
    if (rawSummary != null) {
      final v = rawSummary!['new_prescriptions'] ??
          rawSummary!['prescriptions'] ??
          rawSummary!['new_orders'];
      if (v != null) return v.toString();
    }
    if (!isOtcTab && selectedFilterIndex == 0) {
      return ordersList.length.toString();
    }
    return (homeData?.data?.summary?.todayOrders ?? 0).toString();
  }

  String get newOtcCount {
    if (rawSummary != null) {
      final v = rawSummary!['new_otc_orders'] ??
          rawSummary!['otc_orders'] ??
          rawSummary!['otc'];
      if (v != null) return v.toString();
    }
    if (isOtcTab && selectedFilterIndex == 0) {
      return ordersList.length.toString();
    }
    return '0';
  }

  String get preparingCount {
    if (rawSummary != null) {
      final v = rawSummary!['preparing_orders'] ?? rawSummary!['preparing'];
      if (v != null) return v.toString();
    }
    return '0';
  }

  String get readyCount {
    if (rawSummary != null) {
      final v = rawSummary!['ready_orders'] ?? rawSummary!['ready'];
      if (v != null) return v.toString();
    }
    return '0';
  }

  String get totalOrdersValue {
    if (rawSummary != null) {
      final v = rawSummary!['today_orders'] ??
          rawSummary!['total_orders'] ??
          rawSummary!['orders'];
      if (v != null) return v.toString();
    }
    return (homeData?.data?.summary?.todayOrders ??
            homeData?.data?.summary?.totalOrders ??
            ordersList.length)
        .toString();
  }

  String get completedOrdersValue {
    if (rawSummary != null) {
      final v = rawSummary!['completed_orders'] ??
          rawSummary!['completed'] ??
          rawSummary!['delivered_orders'];
      if (v != null) return v.toString();
    }
    return '0';
  }

  String get revenueValue {
    if (rawSummary != null) {
      final v = rawSummary!['revenue_total'] ??
          rawSummary!['revenue'] ??
          rawSummary!['total_revenue'] ??
          rawSummary!['today_revenue'];
      if (v != null) return v.toString();
    }
    return '0';
  }

  String _getPharmacyHomeUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint =
        ApiEndPoints.pharmacyHome.trim().replaceFirst(RegExp(r'^/'), '');
    var url = '$base/$endpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}')
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<void> fetchPharmacyHome({String? keyword}) async {
    isLoadingHome = true;
    update();
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        isLoadingHome = false;
        update();
        return;
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorType = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "3");

      final queryParams = <String, dynamic>{
        'vendor_type': vendorType,
        'order_status': currentOrderStatus,
        'limit': 10,
      };

      final searchKey = keyword ?? searchController.text.trim();
      if (searchKey.isNotEmpty) {
        queryParams['keyword'] = searchKey;
      }

      final url = _getPharmacyHomeUrl(queryParams);
      debugPrint("==================== GET PHARMACY HOME ====================");
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyHome}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print("==================== GET PHARMACY HOME ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyHome}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyHome,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("==========================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("==========================================================");

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString() == 'true')) {
        homeData = HomeModel.fromJson(dataMap);
        final d = dataMap['data'];
        if (d is Map) {
          final summaryMap = d['summary'];
          if (summaryMap is Map) {
            rawSummary = Map<String, dynamic>.from(summaryMap);
          }
          final vendorMap = d['vendor'];
          if (vendorMap is Map) {
            rawVendor = Map<String, dynamic>.from(vendorMap);
          }
        }
        ordersList = homeData?.data?.orders?.data ?? [];
      } else {
        homeData = null;
        ordersList = [];
        rawSummary = null;
        rawVendor = null;
      }
    } catch (e) {
      debugPrint("==================== GET PHARMACY HOME ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("================================================================");

      print("==================== GET PHARMACY HOME ERROR ====================");
      print("Error: $e");
      print("================================================================");

      homeData = null;
      ordersList = [];
      rawSummary = null;
      rawVendor = null;
    } finally {
      isLoadingHome = false;
      update();
    }
  }

  void selectOrderType(int index) {
    selectedOrderType = index;
    selectedFilterIndex = 0;
    update();
    fetchPharmacyHome();
  }

  void selectFilter(int index) {
    selectedFilterIndex = index;
    update();
    fetchPharmacyHome();
  }

  void showReviewCompleted() {
    bottomNavIndex = 0;
    selectedOrderType = 0;
    selectedFilterIndex = 2;
    update();
    fetchPharmacyHome();
  }

  void toggleStore(bool value) {
    isStoreOpen = value;
    update();
  }

  void onBottomNavSelect(int index) {
    if (index == bottomNavIndex) return;
    bottomNavIndex = index;
    if (index == 0 || index == 1) {
      selectedOrderType = 0;
      selectedFilterIndex = 0;
      fetchPharmacyHome();
    }
    update();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
