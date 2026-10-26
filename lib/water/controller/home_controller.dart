import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/chat_controller.dart';
import 'package:saimpex_vendor/model/home_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/water/controller/account_controller.dart';
import 'package:saimpex_vendor/water/model/home_order.dart';

class WaterHomeController extends GetxController {
  bool isStoreOpen = true;
  int selectedTabIndex = 0;
  int selectedFilterIndex = 0;
  int bottomNavIndex = 0;
  bool isLoading = false;
  final searchController = TextEditingController();

  HomeModel? homeData;
  Map<String, dynamic>? rawSummary;
  Map<String, dynamic>? rawVendor;
  Map<String, dynamic>? rawScreen;

  final filters = const [
    'New Orders',
    'Accepted',
    'Preparing',
    'Ready',
    'Delivered',
    'Cancelled',
  ];

  final subscriptionFilters = const [
    'New Orders',
    'Active',
    'Paused',
    'Cancelled',
  ];

  List<HomeOrder> orders = [];
  List<SubscriptionOrder> subscriptionOrders = [];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    fetchHome();
  }

  void _onSearchChanged() {
    update();
  }

  String get newOrdersCount {
    final v =
        rawSummary?['pending_orders_count'] ??
        rawSummary?['new_orders'] ??
        rawSummary?['pending_orders'];
    if (v != null) return v.toString();
    final count = orders
        .where((o) => o.status == HomeOrderStatus.newOrder)
        .length;
    return count.toString();
  }

  String get subscriptionOrdersCount {
    final v =
        rawSummary?['subscription_orders_count'] ??
        rawSummary?['subscriptions'] ??
        rawSummary?['subscription_orders'];
    if (v != null) return v.toString();
    return subscriptionOrders.length.toString();
  }

  String get preparingOrdersCount {
    final v =
        rawSummary?['processed_orders_count'] ??
        rawSummary?['preparing_orders_count'] ??
        rawSummary?['preparing'];
    if (v != null) return v.toString();
    final count = orders
        .where((o) => o.status == HomeOrderStatus.preparing)
        .length;
    return count.toString();
  }

  String get readyOrdersCount {
    final v =
        rawSummary?['ready_orders_count'] ??
        rawSummary?['ready_orders'] ??
        rawSummary?['ready'];
    if (v != null) return v.toString();
    final count = orders.where((o) => o.status == HomeOrderStatus.ready).length;
    return count.toString();
  }

  String get totalOrdersValue {
    final v =
        rawSummary?['total_orders'] ??
        rawSummary?['today_orders'] ??
        homeData?.data?.summary?.totalOrders ??
        homeData?.data?.summary?.todayOrders;
    if (v != null) return v.toString();
    return orders.length.toString();
  }

  String get completedOrdersValue {
    final v =
        rawSummary?['completed_orders_count'] ??
        rawSummary?['completed_orders'] ??
        homeData?.data?.summary?.completedOrdersCount;
    if (v != null) return v.toString();
    final count = orders
        .where((o) => o.status == HomeOrderStatus.delivered)
        .length;
    return count.toString();
  }

  String get revenueValue {
    final v =
        rawSummary?['revenue'] ??
        rawSummary?['revenue_total'] ??
        rawSummary?['total_revenue'] ??
        rawScreen?['revenue'];
    if (v != null) return v.toString();
    return '0';
  }

  String get storeTimings {
    final welcome = rawScreen?['welcome'];
    if (welcome is Map) {
      final timings = welcome['timings']?.toString().trim();
      if (timings != null && timings.isNotEmpty && timings != 'null') {
        return timings;
      }
      final open = welcome['opening_time']?.toString().trim();
      final close = welcome['closing_time']?.toString().trim();
      if (open != null &&
          open.isNotEmpty &&
          close != null &&
          close.isNotEmpty) {
        return 'Today: $open - $close';
      }
    }
    return 'Today: 08:00 - 22:00';
  }

  String get shopName {
    final vendorName =
        homeData?.data?.vendor?.nameEn ??
        rawVendor?['name_en']?.toString() ??
        rawVendor?['name']?.toString() ??
        rawScreen?['welcome']?['name']?.toString() ??
        rawScreen?['welcome']?['shop_name']?.toString();
    if (vendorName != null &&
        vendorName.trim().isNotEmpty &&
        vendorName != 'null') {
      return vendorName.trim();
    }
    return '';
  }

  String get welcomeText {
    if (shopName.isNotEmpty) {
      return 'Welcome to $shopName!';
    }
    return 'Welcome to Saimpex Vendor!';
  }

  Future<void> fetchHome({
    String? keyword,
    int limit = 20,
    dynamic orderStatus = '1',
  }) async {
    try {
      isLoading = true;
      update();

      final token = await getSavedObject('token');
      if (token != null &&
          token.toString().isNotEmpty &&
          token.toString() != 'null') {
        DioClient().updateToken(token.toString());
      }

      final queryParams = <String, dynamic>{
        'limit': limit,
        'order_status': orderStatus ?? 'all',
      };
      final searchKey = keyword ?? searchController.text.trim();
      if (searchKey.isNotEmpty) {
        queryParams['keyword'] = searchKey;
      }

      debugPrint('==================== GET WATER HOME ====================');
      debugPrint('Endpoint: ${ApiEndPoints.home}');
      debugPrint('Query: $queryParams');

      final response = await DioClient().get(
        ApiEndPoints.home,
        query: queryParams,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('========================================================');

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
            final welcomeMap = rawScreen!['welcome'];
            if (welcomeMap is Map && welcomeMap['is_open'] is bool) {
              isStoreOpen = welcomeMap['is_open'] as bool;
            }
          }

          // Parse subscription orders from API if returned separately
          final subList = d['subscription_orders'] ?? d['subscriptions'];
          if (subList is List) {
            subscriptionOrders = subList
                .whereType<Map>()
                .map(
                  (e) =>
                      SubscriptionOrder.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList();
          } else {
            subscriptionOrders = [];
          }
        }

        final rawOrders = homeData?.data?.orders?.data ?? [];
        final List<HomeOrder> loadedOrders = [];
        for (final o in rawOrders) {
          final type = (o.type ?? o.rawJson?['order_type'] ?? '')
              .toString()
              .toLowerCase();
          final isSub =
              type.contains('sub') ||
              o.rawJson?['is_subscription'] == 1 ||
              o.rawJson?['is_subscription'] == true ||
              o.rawJson?['is_subscription'] == '1';
          if (isSub) {
            if (o.rawJson != null) {
              subscriptionOrders.add(SubscriptionOrder.fromJson(o.rawJson!));
            }
          } else {
            loadedOrders.add(HomeOrder.fromOrderData(o));
          }
        }
        orders = loadedOrders;
      } else {
        homeData = null;
        rawSummary = null;
        rawVendor = null;
        rawScreen = null;
        orders = [];
        subscriptionOrders = [];
      }
    } catch (e) {
      debugPrint(
        '==================== GET WATER HOME ERROR ====================',
      );
      debugPrint('Error: $e');
      debugPrint(
        '==============================================================',
      );
      homeData = null;
      rawSummary = null;
      rawVendor = null;
      rawScreen = null;
      orders = [];
      subscriptionOrders = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  bool get isSubscriptionTab => selectedTabIndex == 1;

  List<String> get activeFilters =>
      isSubscriptionTab ? subscriptionFilters : filters;

  List<HomeOrder> get filteredOrders {
    final index = selectedFilterIndex.clamp(0, filters.length - 1);
    final status = switch (index) {
      0 => HomeOrderStatus.newOrder,
      1 => HomeOrderStatus.accepted,
      2 => HomeOrderStatus.preparing,
      3 => HomeOrderStatus.ready,
      4 => HomeOrderStatus.delivered,
      5 => HomeOrderStatus.cancelled,
      _ => HomeOrderStatus.newOrder,
    };
    var list = orders.where((o) => o.status == status).toList();
    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where(
            (o) =>
                o.customerName.toLowerCase().contains(query) ||
                o.orderId.toLowerCase().contains(query) ||
                o.itemLabel.toLowerCase().contains(query),
          )
          .toList();
    }
    return list;
  }

  List<SubscriptionOrder> get filteredSubscriptionOrders {
    final index = selectedFilterIndex.clamp(0, subscriptionFilters.length - 1);
    final status = switch (index) {
      0 => SubscriptionOrderStatus.newOrder,
      1 => SubscriptionOrderStatus.active,
      2 => SubscriptionOrderStatus.paused,
      3 => SubscriptionOrderStatus.cancelled,
      _ => SubscriptionOrderStatus.newOrder,
    };
    var list = subscriptionOrders.where((o) => o.status == status).toList();
    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where(
            (o) =>
                o.customerName.toLowerCase().contains(query) ||
                o.orderId.toLowerCase().contains(query) ||
                o.productLabel.toLowerCase().contains(query),
          )
          .toList();
    }
    return list;
  }

  void selectOrderType(int index) {
    selectedTabIndex = index;
    selectedFilterIndex = 0;
    update();
  }

  void onBottomNavSelect(int index) {
    if (index == bottomNavIndex) {
      if (index == 2) {
        final chatController = Get.isRegistered<ChatController>()
            ? Get.find<ChatController>()
            : Get.put(ChatController());
        final ctx = Get.context;
        if (ctx != null) {
          chatController.getAllConversations(ctx);
        }
      } else if (index == 4) {
        if (Get.isRegistered<WaterAccountController>()) {
          Get.find<WaterAccountController>().fetchProfile();
        }
      }
      return;
    }
    bottomNavIndex = index;
    if (index == 2) {
      final chatController = Get.isRegistered<ChatController>()
          ? Get.find<ChatController>()
          : Get.put(ChatController());
      final ctx = Get.context;
      if (ctx != null) {
        chatController.getAllConversations(ctx);
      }
    } else if (index == 4) {
      if (Get.isRegistered<WaterAccountController>()) {
        Get.find<WaterAccountController>().fetchProfile();
      }
    }
    update();
  }

  void selectFilter(int index) {
    selectedFilterIndex = index;
    update();
  }

  void toggleStore(bool value) {
    isStoreOpen = value;
    update();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}
