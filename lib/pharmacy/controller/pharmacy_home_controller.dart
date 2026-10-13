import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
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
  final searchController = TextEditingController();

  HomeModel? homeData;
  bool isLoadingHome = false;
  List<OrderData> ordersList = [];
  Map<String, dynamic>? rawSummary;
  Map<String, dynamic>? rawVendor;

  bool isLoadingPrescriptions = false;
  List<PrescriptionItem> prescriptionsList = [];

  bool isLoadingOtcOrders = false;
  List<PharmacyPendingOrderItem> otcOrdersList = [];
  PharmacyPendingOrdersModel? otcOrdersData;

  bool isLoadingOtcAcceptedOrders = false;
  List<PharmacyPendingOrderItem> otcAcceptedOrdersList = [];
  PharmacyPendingOrdersModel? otcAcceptedOrdersData;

  bool isLoadingOtcPreparingOrders = false;
  List<PharmacyPendingOrderItem> otcPreparingOrdersList = [];
  PharmacyPendingOrdersModel? otcPreparingOrdersData;

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
    fetchPharmacyOrders(status: 1);
    fetchPharmacyOrders(status: 2);
    fetchPharmacyOrders(status: 3);
    fetchPharmacyOrders(status: 4);
    fetchPharmacyOrders(status: 9);
    fetchPharmacyOrders(status: 10);
    fetchPharmacyHome();
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
    if (prescriptionsList.isNotEmpty) {
      return prescriptionsList.length.toString();
    }
    if (rawSummary != null) {
      final v =
          rawSummary!['new_prescriptions'] ??
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
    if (otcOrdersList.isNotEmpty) {
      return otcOrdersList.length.toString();
    }
    if (rawSummary != null) {
      final v =
          rawSummary!['new_otc_orders'] ??
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
    if (otcPreparingOrdersList.isNotEmpty) {
      return otcPreparingOrdersList.length.toString();
    }
    if (rawSummary != null) {
      final v = rawSummary!['preparing_orders'] ?? rawSummary!['preparing'];
      if (v != null) return v.toString();
    }
    return '0';
  }

  String get readyCount {
    if (otcReadyOrdersList.isNotEmpty) {
      return otcReadyOrdersList.length.toString();
    }
    if (rawSummary != null) {
      final v = rawSummary!['ready_orders'] ?? rawSummary!['ready'];
      if (v != null) return v.toString();
    }
    return '0';
  }

  String get totalOrdersValue {
    if (rawSummary != null) {
      final v =
          rawSummary!['today_orders'] ??
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
    if (otcDeliveredOrdersList.isNotEmpty) {
      return otcDeliveredOrdersList.length.toString();
    }
    if (rawSummary != null) {
      final v =
          rawSummary!['completed_orders'] ??
          rawSummary!['completed'] ??
          rawSummary!['delivered_orders'];
      if (v != null) return v.toString();
    }
    return '0';
  }

  String get revenueValue {
    if (rawSummary != null) {
      final v =
          rawSummary!['revenue_total'] ??
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
        }
        ordersList = homeData?.data?.orders?.data ?? [];
      } else {
        homeData = null;
        ordersList = [];
        rawSummary = null;
        rawVendor = null;
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

  Future<void> fetchPharmacyPrescriptions({String? keyword}) async {
    isLoadingPrescriptions = true;
    update();
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        isLoadingPrescriptions = false;
        update();
        return;
      }

      final queryParams = <String, dynamic>{'limit': 10};

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
      prescriptionsList = loaded;
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
      prescriptionsList = [];
    } finally {
      isLoadingPrescriptions = false;
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

  Future<void> fetchPharmacyOrders({int? status, String? keyword}) async {
    final orderStatus =
        status ??
        (selectedFilterIndex == 5
            ? 10
            : (selectedFilterIndex == 4
                  ? 9
                  : (selectedFilterIndex == 3
                        ? 4
                        : (selectedFilterIndex == 2
                              ? 3
                              : (selectedFilterIndex == 1 ? 2 : 1)))));
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
    update();
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
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
        update();
        return;
      }

      final searchKey = keyword ?? searchController.text.trim();
      final queryParams = <String, dynamic>{
        'limit': 10,
        'keyword': searchKey,
        'tab': 'otc',
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
    } finally {
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
      fetchPharmacyPrescriptions();
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
