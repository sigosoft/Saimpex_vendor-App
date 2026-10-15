import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' hide FormData;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/home_model.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_pending_orders_model.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_prescriptions_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';

class PharmacyHomeController extends GetxController {
  bool isStoreOpen = true;
  int selectedOrderType = 0;
  int selectedFilterIndex = 0;
  int bottomNavIndex = 0;
  int unreadChatCount = 0;
  final searchController = TextEditingController();

  HomeModel? homeData;
  bool isLoadingHome = false;
  List<OrderData> ordersList = [];
  Map<String, dynamic>? rawSummary;
  Map<String, dynamic>? rawVendor;
  Map<String, dynamic>? rawScreen;
  Map<String, dynamic>? rawPharmacy;
  Map<String, dynamic>? rawKpis;
  Map<String, dynamic>? rawAtAGlance;

  bool isLoadingPrescriptions = false;
  List<PrescriptionItem> prescriptionsList = [];
  bool isLoadingUnderReviewPrescriptions = false;
  List<PrescriptionItem> underReviewPrescriptionsList = [];
  bool isLoadingReviewedPrescriptions = false;
  List<PrescriptionItem> reviewedPrescriptionsList = [];
  bool isLoadingQuotedPrescriptions = false;
  List<PrescriptionItem> quotedPrescriptionsList = [];
  bool isReviewingPrescription = false;
  int? reviewingPrescriptionId;
  bool isMarkingPrescriptionReviewed = false;
  int? markingPrescriptionReviewedId;
  bool isRejectingPrescription = false;
  int? rejectingPrescriptionId;
  bool isSubmittingQuote = false;
  int? submittingQuotePrescriptionId;
  bool isLoadingPrescriptionToPrepareOrders = false;
  List<PharmacyPendingOrderItem> prescriptionToPrepareOrdersList = [];
  PharmacyPendingOrdersModel? prescriptionToPrepareOrdersData;
  bool isLoadingPrescriptionPreparingOrders = false;
  List<PharmacyPendingOrderItem> prescriptionPreparingOrdersList = [];
  PharmacyPendingOrdersModel? prescriptionPreparingOrdersData;
  bool isLoadingPrescriptionReadyOrders = false;
  List<PharmacyPendingOrderItem> prescriptionReadyOrdersList = [];
  PharmacyPendingOrdersModel? prescriptionReadyOrdersData;
  bool isLoadingPrescriptionDeliveredOrders = false;
  List<PharmacyPendingOrderItem> prescriptionDeliveredOrdersList = [];
  PharmacyPendingOrdersModel? prescriptionDeliveredOrdersData;

  bool isLoadingOtcOrders = false;
  List<PharmacyPendingOrderItem> otcOrdersList = [];
  PharmacyPendingOrdersModel? otcOrdersData;
  bool isAcceptingOrder = false;
  int? acceptingOrderId;
  bool isCancellingOrder = false;
  int? cancellingOrderId;

  bool isLoadingOtcAcceptedOrders = false;
  List<PharmacyPendingOrderItem> otcAcceptedOrdersList = [];
  PharmacyPendingOrdersModel? otcAcceptedOrdersData;
  bool isPreparingOrder = false;
  int? preparingOrderId;

  bool isLoadingOtcPreparingOrders = false;
  List<PharmacyPendingOrderItem> otcPreparingOrdersList = [];
  PharmacyPendingOrdersModel? otcPreparingOrdersData;
  bool isMarkingReadyOrder = false;
  int? markingReadyOrderId;

  bool isLoadingOtcReadyOrders = false;
  List<PharmacyPendingOrderItem> otcReadyOrdersList = [];
  PharmacyPendingOrdersModel? otcReadyOrdersData;

  bool isLoadingOtcDeliveredOrders = false;
  List<PharmacyPendingOrderItem> otcDeliveredOrdersList = [];
  PharmacyPendingOrdersModel? otcDeliveredOrdersData;

  bool isLoadingOtcCancelledOrders = false;
  List<PharmacyPendingOrderItem> otcCancelledOrdersList = [];
  PharmacyPendingOrdersModel? otcCancelledOrdersData;

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
    fetchPharmacyPrescriptions();
    fetchPharmacyPrescriptions(status: 'under_review');
    fetchPharmacyPrescriptions(status: 'reviewed');
    fetchPharmacyPrescriptions(status: 'quoted');
    fetchPharmacyOrders(tab: 'prescription', status: 2);
    fetchPharmacyOrders(tab: 'prescription', status: 3);
    fetchPharmacyOrders(tab: 'prescription', status: 4);
    fetchPharmacyOrders(tab: 'prescription', status: 9);
    fetchPharmacyOrders(status: 1);
    fetchPharmacyOrders(status: 2);
    fetchPharmacyOrders(status: 3);
    fetchPharmacyOrders(status: 4);
    fetchPharmacyOrders(status: 9);
    fetchPharmacyOrders(status: 10);
    fetchPharmacyHome();
    fetchUnreadChatCount();
  }

  bool get isOtcTab => selectedOrderType == 1;

  List<String> get activeFilters => isOtcTab ? otcFilters : prescriptionFilters;

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
    if (!isOtcTab && selectedFilterIndex == 0) {
      if (prescriptionsList.isNotEmpty) {
        return prescriptionsList.length < 10
            ? '0${prescriptionsList.length}'
            : '${prescriptionsList.length}';
      }
      return '';
    }
    if (!isOtcTab && selectedFilterIndex == 1) {
      if (underReviewPrescriptionsList.isNotEmpty) {
        return underReviewPrescriptionsList.length < 10
            ? '0${underReviewPrescriptionsList.length}'
            : '${underReviewPrescriptionsList.length}';
      }
      return '';
    }
    if (!isOtcTab && selectedFilterIndex == 2) {
      if (reviewedPrescriptionsList.isNotEmpty) {
        return reviewedPrescriptionsList.length < 10
            ? '0${reviewedPrescriptionsList.length}'
            : '${reviewedPrescriptionsList.length}';
      }
      return '';
    }
    if (!isOtcTab && selectedFilterIndex == 3) {
      if (quotedPrescriptionsList.isNotEmpty) {
        return quotedPrescriptionsList.length < 10
            ? '0${quotedPrescriptionsList.length}'
            : '${quotedPrescriptionsList.length}';
      }
      return '';
    }
    if (!isOtcTab && selectedFilterIndex == 4) {
      if (prescriptionToPrepareOrdersList.isNotEmpty) {
        return prescriptionToPrepareOrdersList.length < 10
            ? '0${prescriptionToPrepareOrdersList.length}'
            : '${prescriptionToPrepareOrdersList.length}';
      }
      return '';
    }
    if (!isOtcTab && selectedFilterIndex == 5) {
      if (prescriptionPreparingOrdersList.isNotEmpty) {
        return prescriptionPreparingOrdersList.length < 10
            ? '0${prescriptionPreparingOrdersList.length}'
            : '${prescriptionPreparingOrdersList.length}';
      }
      return '';
    }
    if (!isOtcTab && selectedFilterIndex == 6) {
      if (prescriptionReadyOrdersList.isNotEmpty) {
        return prescriptionReadyOrdersList.length < 10
            ? '0${prescriptionReadyOrdersList.length}'
            : '${prescriptionReadyOrdersList.length}';
      }
      return '';
    }
    if (!isOtcTab && selectedFilterIndex == 7) {
      if (prescriptionDeliveredOrdersList.isNotEmpty) {
        return prescriptionDeliveredOrdersList.length < 10
            ? '0${prescriptionDeliveredOrdersList.length}'
            : '${prescriptionDeliveredOrdersList.length}';
      }
      return '';
    }
    if (isOtcTab && selectedFilterIndex == 0) {
      if (otcOrdersList.isNotEmpty) {
        return otcOrdersList.length < 10
            ? '0${otcOrdersList.length}'
            : '${otcOrdersList.length}';
      }
      return '';
    }
    if (isOtcTab && selectedFilterIndex == 1) {
      if (otcAcceptedOrdersList.isNotEmpty) {
        return otcAcceptedOrdersList.length < 10
            ? '0${otcAcceptedOrdersList.length}'
            : '${otcAcceptedOrdersList.length}';
      }
      return '';
    }
    if (isOtcTab && selectedFilterIndex == 2) {
      if (otcPreparingOrdersList.isNotEmpty) {
        return otcPreparingOrdersList.length < 10
            ? '0${otcPreparingOrdersList.length}'
            : '${otcPreparingOrdersList.length}';
      }
      return '';
    }
    if (isOtcTab && selectedFilterIndex == 3) {
      if (otcReadyOrdersList.isNotEmpty) {
        return otcReadyOrdersList.length < 10
            ? '0${otcReadyOrdersList.length}'
            : '${otcReadyOrdersList.length}';
      }
      return '';
    }
    if (isOtcTab && selectedFilterIndex == 4) {
      if (otcDeliveredOrdersList.isNotEmpty) {
        return otcDeliveredOrdersList.length < 10
            ? '0${otcDeliveredOrdersList.length}'
            : '${otcDeliveredOrdersList.length}';
      }
      return '';
    }
    if (isOtcTab && selectedFilterIndex == 5) {
      if (otcCancelledOrdersList.isNotEmpty) {
        return otcCancelledOrdersList.length < 10
            ? '0${otcCancelledOrdersList.length}'
            : '${otcCancelledOrdersList.length}';
      }
      return '';
    }
    if (ordersList.isNotEmpty) {
      return ordersList.length < 10
          ? '0${ordersList.length}'
          : '${ordersList.length}';
    }
    return '';
  }

  String? get prescriptionBadge {
    if (!isOtcTab) {
      if (selectedFilterIndex == 0 && prescriptionsList.isNotEmpty) {
        return prescriptionsList.length.toString();
      }
      if (selectedFilterIndex == 1 && underReviewPrescriptionsList.isNotEmpty) {
        return underReviewPrescriptionsList.length.toString();
      }
      if (selectedFilterIndex == 2 && reviewedPrescriptionsList.isNotEmpty) {
        return reviewedPrescriptionsList.length.toString();
      }
      if (selectedFilterIndex == 3 && quotedPrescriptionsList.isNotEmpty) {
        return quotedPrescriptionsList.length.toString();
      }
      if (selectedFilterIndex == 4 &&
          prescriptionToPrepareOrdersList.isNotEmpty) {
        return prescriptionToPrepareOrdersList.length.toString();
      }
      if (selectedFilterIndex == 5 &&
          prescriptionPreparingOrdersList.isNotEmpty) {
        return prescriptionPreparingOrdersList.length.toString();
      }
      if (selectedFilterIndex == 6 &&
          prescriptionReadyOrdersList.isNotEmpty) {
        return prescriptionReadyOrdersList.length.toString();
      }
      if (selectedFilterIndex == 7 &&
          prescriptionDeliveredOrdersList.isNotEmpty) {
        return prescriptionDeliveredOrdersList.length.toString();
      }
      if (ordersList.isNotEmpty) {
        return ordersList.length.toString();
      }
    }
    return null;
  }

  String? get otcBadge {
    if (isOtcTab) {
      if (selectedFilterIndex == 0 && otcOrdersList.isNotEmpty) {
        return otcOrdersList.length.toString();
      }
      if (selectedFilterIndex == 1 && otcAcceptedOrdersList.isNotEmpty) {
        return otcAcceptedOrdersList.length.toString();
      }
      if (selectedFilterIndex == 2 && otcPreparingOrdersList.isNotEmpty) {
        return otcPreparingOrdersList.length.toString();
      }
      if (selectedFilterIndex == 3 && otcReadyOrdersList.isNotEmpty) {
        return otcReadyOrdersList.length.toString();
      }
      if (selectedFilterIndex == 4 && otcDeliveredOrdersList.isNotEmpty) {
        return otcDeliveredOrdersList.length.toString();
      }
      if (selectedFilterIndex == 5 && otcCancelledOrdersList.isNotEmpty) {
        return otcCancelledOrdersList.length.toString();
      }
      if (ordersList.isNotEmpty) {
        return ordersList.length.toString();
      }
    }
    return null;
  }

  String get newPrescriptionsCount {
    final v =
        rawPharmacy?['new_prescriptions'] ??
        rawKpis?['new_prescriptions'] ??
        rawSummary?['new_prescriptions'] ??
        rawScreen?['new_prescriptions'];
    if (v != null) return v.toString();
    if (prescriptionsList.isNotEmpty) {
      return prescriptionsList.length.toString();
    }
    return '0';
  }

  String get newOtcCount {
    final v =
        rawPharmacy?['new_otc'] ??
        rawAtAGlance?['new_otc'] ??
        rawKpis?['new_otc'] ??
        rawSummary?['new_otc'] ??
        rawSummary?['new_otc_orders'];
    if (v != null) return v.toString();
    if (otcOrdersList.isNotEmpty) {
      return otcOrdersList.length.toString();
    }
    return '0';
  }

  String get preparingCount {
    final v =
        rawPharmacy?['preparing'] ??
        rawKpis?['preparing'] ??
        rawSummary?['preparing_orders_count'] ??
        rawSummary?['preparing_orders'] ??
        rawSummary?['preparing'];
    if (v != null) return v.toString();
    if (otcPreparingOrdersList.isNotEmpty) {
      return otcPreparingOrdersList.length.toString();
    }
    return '0';
  }

  String get readyCount {
    final v =
        rawPharmacy?['ready'] ??
        rawKpis?['ready'] ??
        rawSummary?['ready_orders_count'] ??
        rawSummary?['ready_orders'] ??
        rawSummary?['ready'];
    if (v != null) return v.toString();
    if (otcReadyOrdersList.isNotEmpty) {
      return otcReadyOrdersList.length.toString();
    }
    return '0';
  }

  String get totalOrdersValue {
    final v =
        rawSummary?['total_orders'] ??
        homeData?.data?.summary?.totalOrders ??
        rawKpis?['orders'] ??
        rawAtAGlance?['orders'] ??
        rawSummary?['orders'];
    if (v != null) return v.toString();
    return ordersList.length.toString();
  }

  String get completedOrdersValue {
    final v =
        rawSummary?['completed_orders_count'] ??
        homeData?.data?.summary?.completedOrdersCount ??
        rawKpis?['completed'] ??
        rawAtAGlance?['completed'] ??
        rawSummary?['completed_orders'] ??
        rawSummary?['completed'];
    if (v != null) return v.toString();
    if (otcDeliveredOrdersList.isNotEmpty) {
      return otcDeliveredOrdersList.length.toString();
    }
    return '0';
  }

  String get revenueValue {
    final v =
        rawSummary?['revenue'] ??
        rawKpis?['revenue'] ??
        rawAtAGlance?['revenue'] ??
        rawPharmacy?['revenue'] ??
        rawScreen?['revenue'] ??
        rawSummary?['revenue_total'] ??
        rawSummary?['total_revenue'];
    if (v != null) return v.toString();
    return '0';
  }

  String _getPharmacyHomeUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.pharmacyHome.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    var url = '$base/$endpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
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
      final vendorType =
          (savedVendorType != null &&
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
          final screenMap = d['screen'];
          if (screenMap is Map) {
            rawScreen = Map<String, dynamic>.from(screenMap);
            final pharmacyMap = rawScreen!['pharmacy'];
            if (pharmacyMap is Map) {
              rawPharmacy = Map<String, dynamic>.from(pharmacyMap);
            }
            final kpisMap = rawScreen!['kpis'];
            if (kpisMap is Map) {
              rawKpis = Map<String, dynamic>.from(kpisMap);
            }
            final glanceMap = rawScreen!['at_a_glance'];
            if (glanceMap is Map) {
              rawAtAGlance = Map<String, dynamic>.from(glanceMap);
            }
            final welcomeMap = rawScreen!['welcome'];
            if (welcomeMap is Map && welcomeMap['is_open'] is bool) {
              isStoreOpen = welcomeMap['is_open'] as bool;
            }
          }
        }
        ordersList = homeData?.data?.orders?.data ?? [];
      } else {
        homeData = null;
        ordersList = [];
        rawSummary = null;
        rawVendor = null;
        rawScreen = null;
        rawPharmacy = null;
        rawKpis = null;
        rawAtAGlance = null;
      }
    } catch (e) {
      debugPrint(
        "==================== GET PHARMACY HOME ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "================================================================",
      );

      print(
        "==================== GET PHARMACY HOME ERROR ====================",
      );
      print("Error: $e");
      print("================================================================");

      homeData = null;
      ordersList = [];
      rawSummary = null;
      rawVendor = null;
      rawScreen = null;
      rawPharmacy = null;
      rawKpis = null;
      rawAtAGlance = null;
    } finally {
      isLoadingHome = false;
      update();
    }
  }

  String _getPharmacyPrescriptionsUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.pharmacyPrescriptions.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<void> fetchPharmacyPrescriptions({
    String? status,
    String? keyword,
  }) async {
    final isUnderReview = status == 'under_review';
    final isReviewed = status == 'reviewed';
    final isQuoted = status == 'quoted';
    if (isUnderReview) {
      isLoadingUnderReviewPrescriptions = true;
    } else if (isReviewed) {
      isLoadingReviewedPrescriptions = true;
    } else if (isQuoted) {
      isLoadingQuotedPrescriptions = true;
    } else {
      isLoadingPrescriptions = true;
    }
    update();
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        if (isUnderReview) {
          isLoadingUnderReviewPrescriptions = false;
        } else if (isReviewed) {
          isLoadingReviewedPrescriptions = false;
        } else if (isQuoted) {
          isLoadingQuotedPrescriptions = false;
        } else {
          isLoadingPrescriptions = false;
        }
        update();
        return;
      }

      final queryParams = <String, dynamic>{'limit': 10};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final searchKey = keyword ?? searchController.text.trim();
      if (searchKey.isNotEmpty) {
        queryParams['keyword'] = searchKey;
      }

      final url = _getPharmacyPrescriptionsUrl(queryParams);
      debugPrint(
        "==================== GET PHARMACY PRESCRIPTIONS ====================",
      );
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyPrescriptions}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print(
        "==================== GET PHARMACY PRESCRIPTIONS ====================",
      );
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyPrescriptions}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyPrescriptions,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "===================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "===================================================================",
      );

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

      List<PrescriptionItem> loaded = [];
      if (dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString() == 'true')) {
        final d = dataMap['data'];
        if (d is Map) {
          final prescriptionsObj = d['prescriptions'];
          if (prescriptionsObj is Map && prescriptionsObj['data'] is List) {
            loaded = (prescriptionsObj['data'] as List)
                .map(
                  (e) => PrescriptionItem.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList();
          } else if (d['data'] is List) {
            loaded = (d['data'] as List)
                .map(
                  (e) => PrescriptionItem.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList();
          } else if (d['prescriptions'] is List) {
            loaded = (d['prescriptions'] as List)
                .map(
                  (e) => PrescriptionItem.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList();
          }
        } else if (dataMap['prescriptions'] is List) {
          loaded = (dataMap['prescriptions'] as List)
              .map(
                (e) => PrescriptionItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        }
      }
      // Filter out rejected prescriptions so they do not show in pharmacy prescriptions lists and screens
      loaded = loaded.where((item) {
        final s = item.status?.trim().toLowerCase();
        return s != 'rejected' && s != 'reject';
      }).toList();

      if (isUnderReview) {
        underReviewPrescriptionsList = loaded;
      } else if (isReviewed) {
        reviewedPrescriptionsList = loaded;
      } else if (isQuoted) {
        quotedPrescriptionsList = loaded;
      } else {
        prescriptionsList = loaded;
      }
    } catch (e) {
      debugPrint(
        "==================== GET PHARMACY PRESCRIPTIONS ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "=========================================================================",
      );

      print(
        "==================== GET PHARMACY PRESCRIPTIONS ERROR ====================",
      );
      print("Error: $e");
      print(
        "=========================================================================",
      );
      if (isUnderReview) {
        underReviewPrescriptionsList = [];
      } else if (isReviewed) {
        reviewedPrescriptionsList = [];
      } else if (isQuoted) {
        quotedPrescriptionsList = [];
      } else {
        prescriptionsList = [];
      }
    } finally {
      if (isUnderReview) {
        isLoadingUnderReviewPrescriptions = false;
      } else if (isReviewed) {
        isLoadingReviewedPrescriptions = false;
      } else if (isQuoted) {
        isLoadingQuotedPrescriptions = false;
      } else {
        isLoadingPrescriptions = false;
      }
      update();
    }
  }

  String _getPharmacyOrdersUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.pharmacyOrders.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<void> fetchPharmacyOrders({
    int? status,
    String? keyword,
    String? tab,
  }) async {
    final effectiveTab = tab ?? (isOtcTab ? 'otc' : 'prescription');
    final isPrescription = effectiveTab == 'prescription';
    final orderStatus = status ??
        (isPrescription
            ? (selectedFilterIndex == 7
                ? 9
                : (selectedFilterIndex == 6
                    ? 4
                    : (selectedFilterIndex == 5 ? 3 : 2)))
            : (selectedFilterIndex == 5
                ? 10
                : (selectedFilterIndex == 4
                    ? 9
                    : (selectedFilterIndex == 3
                        ? 4
                        : (selectedFilterIndex == 2
                            ? 3
                            : (selectedFilterIndex == 1 ? 2 : 1))))));
    if (isPrescription) {
      if (orderStatus == 9) {
        isLoadingPrescriptionDeliveredOrders = true;
      } else if (orderStatus == 4) {
        isLoadingPrescriptionReadyOrders = true;
      } else if (orderStatus == 3) {
        isLoadingPrescriptionPreparingOrders = true;
      } else if (orderStatus == 2) {
        isLoadingPrescriptionToPrepareOrders = true;
      }
    } else {
      if (orderStatus == 10) {
        isLoadingOtcCancelledOrders = true;
      } else if (orderStatus == 9) {
        isLoadingOtcDeliveredOrders = true;
      } else if (orderStatus == 4) {
        isLoadingOtcReadyOrders = true;
      } else if (orderStatus == 3) {
        isLoadingOtcPreparingOrders = true;
      } else if (orderStatus == 2) {
        isLoadingOtcAcceptedOrders = true;
      } else {
        isLoadingOtcOrders = true;
      }
    }
    update();
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        if (isPrescription) {
          if (orderStatus == 9) {
            isLoadingPrescriptionDeliveredOrders = false;
          } else if (orderStatus == 4) {
            isLoadingPrescriptionReadyOrders = false;
          } else if (orderStatus == 3) {
            isLoadingPrescriptionPreparingOrders = false;
          } else if (orderStatus == 2) {
            isLoadingPrescriptionToPrepareOrders = false;
          }
        } else {
          if (orderStatus == 10) {
            isLoadingOtcCancelledOrders = false;
          } else if (orderStatus == 9) {
            isLoadingOtcDeliveredOrders = false;
          } else if (orderStatus == 4) {
            isLoadingOtcReadyOrders = false;
          } else if (orderStatus == 3) {
            isLoadingOtcPreparingOrders = false;
          } else if (orderStatus == 2) {
            isLoadingOtcAcceptedOrders = false;
          } else {
            isLoadingOtcOrders = false;
          }
        }
        update();
        return;
      }

      final searchKey = keyword ?? searchController.text.trim();
      final queryParams = <String, dynamic>{
        'limit': 10,
        'keyword': searchKey,
        'tab': effectiveTab,
        'status': orderStatus,
      };

      final url = _getPharmacyOrdersUrl(queryParams);
      debugPrint(
        "==================== GET PHARMACY ORDERS ====================",
      );
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyOrders}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print("==================== GET PHARMACY ORDERS ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyOrders}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyOrders,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "============================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("============================================================");

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

      List<PharmacyPendingOrderItem> loaded = [];
      if (dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString() == 'true')) {
        final parsedModel = PharmacyPendingOrdersModel.fromJson(dataMap);
        final d = dataMap['data'];
        if (d is Map) {
          final ordersObj = d['orders'];
          if (ordersObj is Map && ordersObj['data'] is List) {
            loaded = (ordersObj['data'] as List)
                .map(
                  (e) => PharmacyPendingOrderItem.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList();
          } else if (d['data'] is List) {
            loaded = (d['data'] as List)
                .map(
                  (e) => PharmacyPendingOrderItem.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList();
          } else if (d['orders'] is List) {
            loaded = (d['orders'] as List)
                .map(
                  (e) => PharmacyPendingOrderItem.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList();
          }
        } else if (dataMap['orders'] is List) {
          loaded = (dataMap['orders'] as List)
              .map(
                (e) => PharmacyPendingOrderItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        }

        if (isPrescription) {
          if (orderStatus == 9) {
            prescriptionDeliveredOrdersData = parsedModel;
            prescriptionDeliveredOrdersList = loaded;
          } else if (orderStatus == 4) {
            prescriptionReadyOrdersData = parsedModel;
            prescriptionReadyOrdersList = loaded;
          } else if (orderStatus == 3) {
            prescriptionPreparingOrdersData = parsedModel;
            prescriptionPreparingOrdersList = loaded;
          } else if (orderStatus == 2) {
            prescriptionToPrepareOrdersData = parsedModel;
            prescriptionToPrepareOrdersList = loaded;
          }
        } else {
          if (orderStatus == 10) {
            otcCancelledOrdersData = parsedModel;
            otcCancelledOrdersList = loaded;
          } else if (orderStatus == 9) {
            otcDeliveredOrdersData = parsedModel;
            otcDeliveredOrdersList = loaded;
          } else if (orderStatus == 4) {
            otcReadyOrdersData = parsedModel;
            otcReadyOrdersList = loaded;
          } else if (orderStatus == 3) {
            otcPreparingOrdersData = parsedModel;
            otcPreparingOrdersList = loaded;
          } else if (orderStatus == 2) {
            otcAcceptedOrdersData = parsedModel;
            otcAcceptedOrdersList = loaded;
          } else {
            otcOrdersData = parsedModel;
            otcOrdersList = loaded;
          }
        }
      } else {
        if (isPrescription) {
          if (orderStatus == 9) {
            prescriptionDeliveredOrdersData = null;
            prescriptionDeliveredOrdersList = [];
          } else if (orderStatus == 4) {
            prescriptionReadyOrdersData = null;
            prescriptionReadyOrdersList = [];
          } else if (orderStatus == 3) {
            prescriptionPreparingOrdersData = null;
            prescriptionPreparingOrdersList = [];
          } else if (orderStatus == 2) {
            prescriptionToPrepareOrdersData = null;
            prescriptionToPrepareOrdersList = [];
          }
        } else {
          if (orderStatus == 10) {
            otcCancelledOrdersData = null;
            otcCancelledOrdersList = [];
          } else if (orderStatus == 9) {
            otcDeliveredOrdersData = null;
            otcDeliveredOrdersList = [];
          } else if (orderStatus == 4) {
            otcReadyOrdersData = null;
            otcReadyOrdersList = [];
          } else if (orderStatus == 3) {
            otcPreparingOrdersData = null;
            otcPreparingOrdersList = [];
          } else if (orderStatus == 2) {
            otcAcceptedOrdersData = null;
            otcAcceptedOrdersList = [];
          } else {
            otcOrdersData = null;
            otcOrdersList = [];
          }
        }
      }
    } catch (e) {
      debugPrint(
        "==================== GET PHARMACY ORDERS ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "==================================================================",
      );

      print(
        "==================== GET PHARMACY ORDERS ERROR ====================",
      );
      print("Error: $e");
      print(
        "==================================================================",
      );
      if (isPrescription) {
        if (orderStatus == 9) {
          prescriptionDeliveredOrdersList = [];
          prescriptionDeliveredOrdersData = null;
        } else if (orderStatus == 4) {
          prescriptionReadyOrdersList = [];
          prescriptionReadyOrdersData = null;
        } else if (orderStatus == 3) {
          prescriptionPreparingOrdersList = [];
          prescriptionPreparingOrdersData = null;
        } else if (orderStatus == 2) {
          prescriptionToPrepareOrdersList = [];
          prescriptionToPrepareOrdersData = null;
        }
      } else {
        if (orderStatus == 10) {
          otcCancelledOrdersList = [];
          otcCancelledOrdersData = null;
        } else if (orderStatus == 9) {
          otcDeliveredOrdersList = [];
          otcDeliveredOrdersData = null;
        } else if (orderStatus == 4) {
          otcReadyOrdersList = [];
          otcReadyOrdersData = null;
        } else if (orderStatus == 3) {
          otcPreparingOrdersList = [];
          otcPreparingOrdersData = null;
        } else if (orderStatus == 2) {
          otcAcceptedOrdersList = [];
          otcAcceptedOrdersData = null;
        } else {
          otcOrdersList = [];
          otcOrdersData = null;
        }
      }
    } finally {
      if (isPrescription) {
        if (orderStatus == 9) {
          isLoadingPrescriptionDeliveredOrders = false;
        } else if (orderStatus == 4) {
          isLoadingPrescriptionReadyOrders = false;
        } else if (orderStatus == 3) {
          isLoadingPrescriptionPreparingOrders = false;
        } else if (orderStatus == 2) {
          isLoadingPrescriptionToPrepareOrders = false;
        }
      } else {
        if (orderStatus == 10) {
          isLoadingOtcCancelledOrders = false;
        } else if (orderStatus == 9) {
          isLoadingOtcDeliveredOrders = false;
        } else if (orderStatus == 4) {
          isLoadingOtcReadyOrders = false;
        } else if (orderStatus == 3) {
          isLoadingOtcPreparingOrders = false;
        } else if (orderStatus == 2) {
          isLoadingOtcAcceptedOrders = false;
        } else {
          isLoadingOtcOrders = false;
        }
      }
      update();
    }
  }

  String _getReviewPharmacyPrescriptionUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.reviewPharmacyPrescription
        .trim()
        .replaceFirst(RegExp(r'^/'), '');
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<bool> reviewPharmacyPrescription(
    dynamic prescriptionId, {
    BuildContext? context,
  }) async {
    if (prescriptionId == null) return false;
    final parsedId = (prescriptionId is int)
        ? prescriptionId
        : int.tryParse(prescriptionId.toString());
    if (parsedId == null) return false;

    isReviewingPrescription = true;
    reviewingPrescriptionId = parsedId;
    update();

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final formData = FormData.fromMap({'prescription_id': parsedId});

      final url = _getReviewPharmacyPrescriptionUrl();
      debugPrint(
        "==================== REVIEW PHARMACY PRESCRIPTION ====================",
      );
      debugPrint("API Call: POST $url");
      debugPrint("Endpoint: ${ApiEndPoints.reviewPharmacyPrescription}");
      debugPrint("Body: {'prescription_id': $parsedId}");

      print(
        "==================== REVIEW PHARMACY PRESCRIPTION ====================",
      );
      print("API Call: POST $url");
      print("Endpoint: ${ApiEndPoints.reviewPharmacyPrescription}");
      print("Body: {'prescription_id': $parsedId}");

      final response = await DioClient().post(
        ApiEndPoints.reviewPharmacyPrescription,
        body: formData,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "=====================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "=====================================================================",
      );

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

      final isSuccess = dataMap != null
          ? (dataMap['status'] == true ||
                dataMap['status'].toString() == 'true')
          : (response.statusCode == 200);

      String? message;
      if (dataMap != null && dataMap['message'] != null) {
        final m = dataMap['message'];
        if (m is Map) {
          message =
              m['message_en'] is List && (m['message_en'] as List).isNotEmpty
              ? m['message_en'].first.toString()
              : m['message_en']?.toString();
          if (message == null || message.isEmpty) {
            message = m.values.first?.toString();
          }
        } else if (m is List && m.isNotEmpty) {
          message = m.first.toString();
        } else {
          message = m.toString();
        }
      }
      message ??= (isSuccess
          ? 'Prescription marked for review successfully'
          : 'Failed to review prescription');

      if (context != null && context.mounted) {
        showToast(context, message);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (isSuccess) {
        await fetchPharmacyPrescriptions();
        await fetchPharmacyPrescriptions(status: 'under_review');
        await fetchPharmacyPrescriptions(status: 'reviewed');
        await fetchPharmacyHome();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        "==================== REVIEW PHARMACY PRESCRIPTION ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "===========================================================================",
      );

      print(
        "==================== REVIEW PHARMACY PRESCRIPTION ERROR ====================",
      );
      print("Error: $e");
      print(
        "===========================================================================",
      );

      final errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (context != null && context.mounted) {
        showToast(context, errorMsg);
      } else {
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return false;
    } finally {
      isReviewingPrescription = false;
      reviewingPrescriptionId = null;
      update();
    }
  }

  String _getMarkPharmacyPrescriptionReviewedUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.markPharmacyPrescriptionReviewed
        .trim()
        .replaceFirst(RegExp(r'^/'), '');
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<bool> markPharmacyPrescriptionReviewed(
    dynamic prescriptionId, {
    BuildContext? context,
  }) async {
    if (prescriptionId == null) return false;
    final parsedId = (prescriptionId is int)
        ? prescriptionId
        : int.tryParse(prescriptionId.toString());
    if (parsedId == null) return false;

    isMarkingPrescriptionReviewed = true;
    markingPrescriptionReviewedId = parsedId;
    update();

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final formData = FormData.fromMap({'prescription_id': parsedId});

      final url = _getMarkPharmacyPrescriptionReviewedUrl();
      debugPrint(
        "==================== MARK PHARMACY PRESCRIPTION REVIEWED ====================",
      );
      debugPrint("API Call: POST $url");
      debugPrint("Endpoint: ${ApiEndPoints.markPharmacyPrescriptionReviewed}");
      debugPrint("Body: {'prescription_id': $parsedId}");

      print(
        "==================== MARK PHARMACY PRESCRIPTION REVIEWED ====================",
      );
      print("API Call: POST $url");
      print("Endpoint: ${ApiEndPoints.markPharmacyPrescriptionReviewed}");
      print("Body: {'prescription_id': $parsedId}");

      final response = await DioClient().post(
        ApiEndPoints.markPharmacyPrescriptionReviewed,
        body: formData,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "============================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "============================================================================",
      );

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

      final isSuccess = dataMap != null
          ? (dataMap['status'] == true ||
                dataMap['status'].toString() == 'true')
          : (response.statusCode == 200);

      String? message;
      if (dataMap != null && dataMap['message'] != null) {
        final m = dataMap['message'];
        if (m is Map) {
          message =
              m['message_en'] is List && (m['message_en'] as List).isNotEmpty
              ? m['message_en'].first.toString()
              : m['message_en']?.toString();
          if (message == null || message.isEmpty) {
            message = m.values.first?.toString();
          }
        } else if (m is List && m.isNotEmpty) {
          message = m.first.toString();
        } else {
          message = m.toString();
        }
      }
      message ??= (isSuccess
          ? 'Prescription marked as reviewed successfully'
          : 'Failed to mark prescription as reviewed');

      if (context != null && context.mounted) {
        showToast(context, message);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (isSuccess) {
        await fetchPharmacyPrescriptions();
        await fetchPharmacyPrescriptions(status: 'under_review');
        await fetchPharmacyPrescriptions(status: 'reviewed');
        await fetchPharmacyOrders(tab: 'prescription', status: 2);
        await fetchPharmacyHome();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        "==================== MARK PHARMACY PRESCRIPTION REVIEWED ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "==================================================================================",
      );

      print(
        "==================== MARK PHARMACY PRESCRIPTION REVIEWED ERROR ====================",
      );
      print("Error: $e");
      print(
        "==================================================================================",
      );

      final errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (context != null && context.mounted) {
        showToast(context, errorMsg);
      } else {
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return false;
    } finally {
      isMarkingPrescriptionReviewed = false;
      markingPrescriptionReviewedId = null;
      update();
    }
  }

  String _getRejectPharmacyPrescriptionUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.rejectPharmacyPrescription
        .trim()
        .replaceFirst(RegExp(r'^/'), '');
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<bool> rejectPharmacyPrescription(
    dynamic prescriptionId, {
    BuildContext? context,
  }) async {
    if (prescriptionId == null) return false;
    final parsedId = (prescriptionId is int)
        ? prescriptionId
        : int.tryParse(prescriptionId.toString());
    if (parsedId == null) return false;

    isRejectingPrescription = true;
    rejectingPrescriptionId = parsedId;
    update();

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final formData = FormData.fromMap({'prescription_id': parsedId});

      final url = _getRejectPharmacyPrescriptionUrl();
      debugPrint(
        "==================== REJECT PHARMACY PRESCRIPTION ====================",
      );
      debugPrint("API Call: POST $url");
      debugPrint("Endpoint: ${ApiEndPoints.rejectPharmacyPrescription}");
      debugPrint("Body: {'prescription_id': $parsedId}");

      print(
        "==================== REJECT PHARMACY PRESCRIPTION ====================",
      );
      print("API Call: POST $url");
      print("Endpoint: ${ApiEndPoints.rejectPharmacyPrescription}");
      print("Body: {'prescription_id': $parsedId}");

      final response = await DioClient().post(
        ApiEndPoints.rejectPharmacyPrescription,
        body: formData,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "=====================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "=====================================================================",
      );

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

      final isSuccess = dataMap != null
          ? (dataMap['status'] == true ||
                dataMap['status'].toString() == 'true')
          : (response.statusCode == 200);

      String? message;
      if (dataMap != null && dataMap['message'] != null) {
        final m = dataMap['message'];
        if (m is Map) {
          message =
              m['message_en'] is List && (m['message_en'] as List).isNotEmpty
              ? m['message_en'].first.toString()
              : m['message_en']?.toString();
          if (message == null || message.isEmpty) {
            message = m.values.first?.toString();
          }
        } else if (m is List && m.isNotEmpty) {
          message = m.first.toString();
        } else {
          message = m.toString();
        }
      }
      message ??= (isSuccess
          ? 'Prescription rejected successfully'
          : 'Failed to reject prescription');

      if (context != null && context.mounted) {
        showToast(context, message);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (isSuccess) {
        prescriptionsList.removeWhere(
          (item) => (item.prescriptionId ?? item.id) == parsedId,
        );
        underReviewPrescriptionsList.removeWhere(
          (item) => (item.prescriptionId ?? item.id) == parsedId,
        );
        reviewedPrescriptionsList.removeWhere(
          (item) => (item.prescriptionId ?? item.id) == parsedId,
        );
        update();

        await fetchPharmacyPrescriptions();
        await fetchPharmacyPrescriptions(status: 'under_review');
        await fetchPharmacyPrescriptions(status: 'reviewed');
        await fetchPharmacyHome();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        "==================== REJECT PHARMACY PRESCRIPTION ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "===========================================================================",
      );

      print(
        "==================== REJECT PHARMACY PRESCRIPTION ERROR ====================",
      );
      print("Error: $e");
      print(
        "===========================================================================",
      );

      final errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (context != null && context.mounted) {
        showToast(context, errorMsg);
      } else {
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return false;
    } finally {
      isRejectingPrescription = false;
      rejectingPrescriptionId = null;
      update();
    }
  }

  String _getSubmitPharmacyPrescriptionQuoteUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.submitPharmacyPrescriptionQuote
        .trim()
        .replaceFirst(RegExp(r'^/'), '');
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<bool> submitPharmacyPrescriptionQuote({
    required dynamic prescriptionId,
    required dynamic quoteAmount,
    required dynamic items,
    required String quoteExpiresAt,
    BuildContext? context,
  }) async {
    if (prescriptionId == null) return false;
    final parsedId = (prescriptionId is int)
        ? prescriptionId
        : int.tryParse(prescriptionId.toString());
    if (parsedId == null) return false;

    isSubmittingQuote = true;
    submittingQuotePrescriptionId = parsedId;
    update();

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final itemsStr = items is String ? items : jsonEncode(items);

      final formData = FormData.fromMap({
        'prescription_id': parsedId,
        'quote_amount': quoteAmount,
        'items': itemsStr,
        'quote_expires_at': quoteExpiresAt,
      });

      final url = _getSubmitPharmacyPrescriptionQuoteUrl();
      debugPrint(
        "==================== SUBMIT PHARMACY PRESCRIPTION QUOTE ====================",
      );
      debugPrint("API Call: POST $url");
      debugPrint("Endpoint: ${ApiEndPoints.submitPharmacyPrescriptionQuote}");
      debugPrint(
        "Body: {'prescription_id': $parsedId, 'quote_amount': $quoteAmount, 'items': $itemsStr, 'quote_expires_at': $quoteExpiresAt}",
      );

      print(
        "==================== SUBMIT PHARMACY PRESCRIPTION QUOTE ====================",
      );
      print("API Call: POST $url");
      print("Endpoint: ${ApiEndPoints.submitPharmacyPrescriptionQuote}");
      print(
        "Body: {'prescription_id': $parsedId, 'quote_amount': $quoteAmount, 'items': $itemsStr, 'quote_expires_at': $quoteExpiresAt}",
      );

      final response = await DioClient().post(
        ApiEndPoints.submitPharmacyPrescriptionQuote,
        body: formData,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "============================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "============================================================================",
      );

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

      final isSuccess = dataMap != null
          ? (dataMap['status'] == true ||
                dataMap['status'].toString() == 'true')
          : (response.statusCode == 200);

      String? message;
      if (dataMap != null && dataMap['message'] != null) {
        final m = dataMap['message'];
        if (m is Map) {
          message =
              m['message_en'] is List && (m['message_en'] as List).isNotEmpty
              ? m['message_en'].first.toString()
              : m['message_en']?.toString();
          if (message == null || message.isEmpty) {
            message = m.values.first?.toString();
          }
        } else if (m is List && m.isNotEmpty) {
          message = m.first.toString();
        } else {
          message = m.toString();
        }
      }
      message ??= (isSuccess
          ? 'Quotation created successfully'
          : 'Failed to create quotation');

      if (context != null && context.mounted) {
        showToast(context, message);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (isSuccess) {
        await fetchPharmacyPrescriptions();
        await fetchPharmacyPrescriptions(status: 'under_review');
        await fetchPharmacyPrescriptions(status: 'reviewed');
        await fetchPharmacyPrescriptions(status: 'quoted');
        await fetchPharmacyOrders(tab: 'prescription', status: 2);
        await fetchPharmacyHome();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        "==================== SUBMIT PHARMACY PRESCRIPTION QUOTE ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "==================================================================================",
      );

      print(
        "==================== SUBMIT PHARMACY PRESCRIPTION QUOTE ERROR ====================",
      );
      print("Error: $e");
      print(
        "==================================================================================",
      );

      final errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (context != null && context.mounted) {
        showToast(context, errorMsg);
      } else {
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return false;
    } finally {
      isSubmittingQuote = false;
      submittingQuotePrescriptionId = null;
      update();
    }
  }

  String _getAcceptPharmacyOrderUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.acceptPharmacyOrder.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<bool> acceptPharmacyOrder(
    dynamic orderId, {
    BuildContext? context,
  }) async {
    if (orderId == null) return false;
    final parsedId = (orderId is int)
        ? orderId
        : int.tryParse(orderId.toString());
    if (parsedId == null) return false;

    isAcceptingOrder = true;
    acceptingOrderId = parsedId;
    update();

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final queryParams = <String, dynamic>{'order_id': parsedId};

      final url = _getAcceptPharmacyOrderUrl(queryParams);
      debugPrint(
        "==================== ACCEPT PHARMACY ORDER ====================",
      );
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.acceptPharmacyOrder}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print("==================== ACCEPT PHARMACY ORDER ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.acceptPharmacyOrder}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.acceptPharmacyOrder,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "==============================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("==============================================================");

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

      final isSuccess = dataMap != null
          ? (dataMap['status'] == true ||
                dataMap['status'].toString() == 'true')
          : (response.statusCode == 200);

      final message =
          dataMap?['message']?.toString() ??
          (isSuccess
              ? 'Order accepted successfully'
              : 'Failed to accept order');

      if (context != null && context.mounted) {
        showToast(context, message);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (isSuccess) {
        await fetchPharmacyOrders(status: 1);
        await fetchPharmacyOrders(status: 2);
        await fetchPharmacyHome();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        "==================== ACCEPT PHARMACY ORDER ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "====================================================================",
      );
      print(
        "==================== ACCEPT PHARMACY ORDER ERROR ====================",
      );
      print("Error: $e");
      print(
        "====================================================================",
      );

      final errorMsg = e.toString();
      if (context != null && context.mounted) {
        showToast(context, errorMsg);
      } else {
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return false;
    } finally {
      isAcceptingOrder = false;
      acceptingOrderId = null;
      update();
    }
  }

  String _getCancelPharmacyOrderUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.cancelPharmacyOrder.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<bool> cancelPharmacyOrder(
    dynamic orderId, {
    bool isPrescription = false,
    dynamic prescriptionId,
    BuildContext? context,
  }) async {
    final targetId = prescriptionId ?? orderId;
    if (targetId == null) return false;
    final parsedId = (targetId is int)
        ? targetId
        : int.tryParse(targetId.toString());
    if (parsedId == null) return false;

    isCancellingOrder = true;
    cancellingOrderId = parsedId;
    update();

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final queryParams = <String, dynamic>{
        if (isPrescription || prescriptionId != null)
          'prescription_id': parsedId
        else
          'order_id': parsedId,
      };

      final url = _getCancelPharmacyOrderUrl(queryParams);
      debugPrint(
        "==================== CANCEL PHARMACY ORDER ====================",
      );
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.cancelPharmacyOrder}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print("==================== CANCEL PHARMACY ORDER ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.cancelPharmacyOrder}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.cancelPharmacyOrder,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "==============================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("==============================================================");

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

      final isSuccess = dataMap != null
          ? (dataMap['status'] == true ||
                dataMap['status'].toString() == 'true')
          : (response.statusCode == 200);

      String? message;
      if (dataMap != null && dataMap['message'] != null) {
        final m = dataMap['message'];
        if (m is Map) {
          message =
              m['message_en'] is List && (m['message_en'] as List).isNotEmpty
              ? m['message_en'].first.toString()
              : m['message_en']?.toString();
          if (message == null || message.isEmpty) {
            message = m.values.first?.toString();
          }
        } else if (m is List && m.isNotEmpty) {
          message = m.first.toString();
        } else {
          message = m.toString();
        }
      }
      message ??= (isSuccess
          ? (isPrescription || prescriptionId != null
                ? 'Prescription cancelled successfully'
                : 'Order cancelled successfully')
          : (isPrescription || prescriptionId != null
                ? 'Failed to cancel prescription'
                : 'Failed to cancel order'));

      if (context != null && context.mounted) {
        showToast(context, message);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (isSuccess) {
        if (isPrescription || prescriptionId != null) {
          await fetchPharmacyPrescriptions();
          await fetchPharmacyPrescriptions(status: 'under_review');
          await fetchPharmacyPrescriptions(status: 'reviewed');
        } else {
          await fetchPharmacyOrders(status: 1);
          await fetchPharmacyOrders(status: 10);
        }
        await fetchPharmacyHome();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        "==================== CANCEL PHARMACY ORDER ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "====================================================================",
      );
      print(
        "==================== CANCEL PHARMACY ORDER ERROR ====================",
      );
      print("Error: $e");
      print(
        "====================================================================",
      );

      final errorMsg = e.toString();
      if (context != null && context.mounted) {
        showToast(context, errorMsg);
      } else {
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return false;
    } finally {
      isCancellingOrder = false;
      cancellingOrderId = null;
      update();
    }
  }

  String _getPreparePharmacyOrderUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.preparePharmacyOrder.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<bool> preparePharmacyOrder(
    dynamic orderId, {
    BuildContext? context,
  }) async {
    if (orderId == null) return false;
    final parsedId = (orderId is int)
        ? orderId
        : int.tryParse(orderId.toString());
    if (parsedId == null) return false;

    isPreparingOrder = true;
    preparingOrderId = parsedId;
    update();

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final queryParams = <String, dynamic>{'order_id': parsedId};

      final url = _getPreparePharmacyOrderUrl(queryParams);
      debugPrint(
        "==================== PREPARE PHARMACY ORDER ====================",
      );
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.preparePharmacyOrder}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print("==================== PREPARE PHARMACY ORDER ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.preparePharmacyOrder}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.preparePharmacyOrder,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "==============================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("==============================================================");

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

      final isSuccess = dataMap != null
          ? (dataMap['status'] == true ||
                dataMap['status'].toString() == 'true')
          : (response.statusCode == 200);

      final message =
          dataMap?['message']?.toString() ??
          (isSuccess ? 'Order preparation started' : 'Failed to prepare order');

      if (context != null && context.mounted) {
        showToast(context, message);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (isSuccess) {
        await fetchPharmacyOrders(status: 2);
        await fetchPharmacyOrders(status: 3);
        await fetchPharmacyHome();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        "==================== PREPARE PHARMACY ORDER ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "====================================================================",
      );
      print(
        "==================== PREPARE PHARMACY ORDER ERROR ====================",
      );
      print("Error: $e");
      print(
        "====================================================================",
      );

      final errorMsg = e.toString();
      if (context != null && context.mounted) {
        showToast(context, errorMsg);
      } else {
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return false;
    } finally {
      isPreparingOrder = false;
      preparingOrderId = null;
      update();
    }
  }

  String _getMarkAsReadyPharmacyOrderUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.markAsReadyPharmacyOrder.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<bool> markAsReadyPharmacyOrder(
    dynamic orderId, {
    BuildContext? context,
  }) async {
    if (orderId == null) return false;
    final parsedId = (orderId is int)
        ? orderId
        : int.tryParse(orderId.toString());
    if (parsedId == null) return false;

    isMarkingReadyOrder = true;
    markingReadyOrderId = parsedId;
    update();

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final queryParams = <String, dynamic>{'order_id': parsedId};

      final url = _getMarkAsReadyPharmacyOrderUrl(queryParams);
      debugPrint(
        "==================== MARK AS READY PHARMACY ORDER ====================",
      );
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.markAsReadyPharmacyOrder}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print(
        "==================== MARK AS READY PHARMACY ORDER ====================",
      );
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.markAsReadyPharmacyOrder}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.markAsReadyPharmacyOrder,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "==============================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("==============================================================");

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

      final isSuccess = dataMap != null
          ? (dataMap['status'] == true ||
                dataMap['status'].toString() == 'true')
          : (response.statusCode == 200);

      final message =
          dataMap?['message']?.toString() ??
          (isSuccess
              ? 'Order marked as ready'
              : 'Failed to mark order as ready');

      if (context != null && context.mounted) {
        showToast(context, message);
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (isSuccess) {
        await fetchPharmacyOrders(status: 3);
        await fetchPharmacyOrders(status: 4);
        await fetchPharmacyHome();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        "==================== MARK AS READY PHARMACY ORDER ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "====================================================================",
      );
      print(
        "==================== MARK AS READY PHARMACY ORDER ERROR ====================",
      );
      print("Error: $e");
      print(
        "====================================================================",
      );

      final errorMsg = e.toString();
      if (context != null && context.mounted) {
        showToast(context, errorMsg);
      } else {
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return false;
    } finally {
      isMarkingReadyOrder = false;
      markingReadyOrderId = null;
      update();
    }
  }

  void selectOrderType(int index) {
    selectedOrderType = index;
    selectedFilterIndex = 0;
    update();
    if (!isOtcTab && selectedFilterIndex == 0) {
      fetchPharmacyPrescriptions();
      fetchPharmacyHome();
    } else if (isOtcTab && selectedFilterIndex == 0) {
      fetchPharmacyOrders(status: 1);
      fetchPharmacyHome();
    } else {
      fetchPharmacyHome();
    }
  }

  void selectFilter(int index) {
    selectedFilterIndex = index;
    update();
    if (!isOtcTab && selectedFilterIndex == 0) {
      fetchPharmacyPrescriptions();
      fetchPharmacyHome();
    } else if (!isOtcTab && selectedFilterIndex == 1) {
      fetchPharmacyPrescriptions(status: 'under_review');
      fetchPharmacyHome();
    } else if (!isOtcTab && selectedFilterIndex == 2) {
      fetchPharmacyPrescriptions(status: 'reviewed');
      fetchPharmacyHome();
    } else if (!isOtcTab && selectedFilterIndex == 3) {
      fetchPharmacyPrescriptions(status: 'quoted');
      fetchPharmacyHome();
    } else if (!isOtcTab && selectedFilterIndex == 4) {
      fetchPharmacyOrders(tab: 'prescription', status: 2);
      fetchPharmacyHome();
    } else if (!isOtcTab && selectedFilterIndex == 5) {
      fetchPharmacyOrders(tab: 'prescription', status: 3);
      fetchPharmacyHome();
    } else if (!isOtcTab && selectedFilterIndex == 6) {
      fetchPharmacyOrders(tab: 'prescription', status: 4);
      fetchPharmacyHome();
    } else if (!isOtcTab && selectedFilterIndex == 7) {
      fetchPharmacyOrders(tab: 'prescription', status: 9);
      fetchPharmacyHome();
    } else if (isOtcTab && selectedFilterIndex == 0) {
      fetchPharmacyOrders(status: 1);
      fetchPharmacyHome();
    } else if (isOtcTab && selectedFilterIndex == 1) {
      fetchPharmacyOrders(status: 2);
      fetchPharmacyHome();
    } else if (isOtcTab && selectedFilterIndex == 2) {
      fetchPharmacyOrders(status: 3);
      fetchPharmacyHome();
    } else if (isOtcTab && selectedFilterIndex == 3) {
      fetchPharmacyOrders(status: 4);
      fetchPharmacyHome();
    } else if (isOtcTab && selectedFilterIndex == 4) {
      fetchPharmacyOrders(status: 9);
      fetchPharmacyHome();
    } else if (isOtcTab && selectedFilterIndex == 5) {
      fetchPharmacyOrders(status: 10);
      fetchPharmacyHome();
    } else {
      fetchPharmacyHome();
    }
  }

  void showReviewCompleted() {
    bottomNavIndex = 0;
    selectedOrderType = 0;
    selectedFilterIndex = 2;
    update();
    fetchPharmacyPrescriptions(status: 'reviewed');
    fetchPharmacyHome();
  }

  void toggleStore(bool value) {
    isStoreOpen = value;
    update();
  }

  Future<void> fetchUnreadChatCount() async {
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isEmpty || token == "null") return;
      DioClient().updateToken(token);

      String base = ApiConfigs.BASE_URL.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      final cleanEndpoint = ApiEndPoints.totalUnreadMessagesCount.replaceFirst(
        RegExp(r'^/'),
        '',
      );
      final fullUrl = "$base/$cleanEndpoint";

      final headers = <String, dynamic>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      debugPrint(
        "==================== GET VENDOR CHAT TOTAL UNREAD MESSAGES COUNT ====================",
      );
      debugPrint("API Call: GET $fullUrl");
      debugPrint("Header: $headers");

      print(
        "==================== GET VENDOR CHAT TOTAL UNREAD MESSAGES COUNT ====================",
      );
      print("API Call: GET $fullUrl");
      print("Header: $headers");

      final response = await DioClient().get(
        ApiEndPoints.totalUnreadMessagesCount,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "====================================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "====================================================================================",
      );

      if (response.data != null &&
          response.data is Map &&
          response.data['status'] == true) {
        final count = response.data['data']?['total_unread_messages_count'];
        unreadChatCount = (count is int)
            ? count
            : int.tryParse(count?.toString() ?? '0') ?? 0;
        update();
      }
    } catch (e) {
      debugPrint("fetchUnreadChatCount error: $e");
    }
  }

  void onBottomNavSelect(int index) {
    if (index == bottomNavIndex) return;
    bottomNavIndex = index;
    fetchUnreadChatCount();
    if (index == 0 || index == 1) {
      selectedOrderType = 0;
      selectedFilterIndex = 0;
      fetchPharmacyPrescriptions();
      fetchPharmacyPrescriptions(status: 'under_review');
      fetchPharmacyPrescriptions(status: 'reviewed');
      fetchPharmacyPrescriptions(status: 'quoted');
      fetchPharmacyOrders(tab: 'prescription', status: 2);
      fetchPharmacyOrders(tab: 'prescription', status: 3);
      fetchPharmacyOrders(tab: 'prescription', status: 4);
      fetchPharmacyOrders(tab: 'prescription', status: 9);
      fetchPharmacyOrders(status: 1);
      fetchPharmacyOrders(status: 2);
      fetchPharmacyOrders(status: 3);
      fetchPharmacyOrders(status: 4);
      fetchPharmacyOrders(status: 9);
      fetchPharmacyOrders(status: 10);
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
