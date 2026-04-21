import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saimpex_vendor/controller/home_controller.dart';
import 'package:saimpex_vendor/controller/vendor_home_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/model/home_model.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/utils/widgets/custom_search_box.dart';
import 'package:saimpex_vendor/utils/widgets/no_data_widget.dart';
import 'package:saimpex_vendor/view/home/orders_view_all.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_dashboard_button.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_home_top_bar.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_membership_card.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_order_list_item.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_orders_header.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_stats_section.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_status_tabs.dart';
import 'package:saimpex_vendor/controller/order_details_controller.dart';

import '../../Utils/Utils.dart';
import '../../configs/ApiConfigs.dart';
import '../../configs/Dioclient.dart';
import '../../model/settings_model.dart';
import '../settings/maintenance.dart';
import '../settings/need_an_update.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  final VendorHomeController vendorHomeController =
      const VendorHomeController();
  final HomeController homeController = Get.find<HomeController>();
  final OrderDetailsController detailsController = Get.put(
    OrderDetailsController(),
  );
  String selectedTab = "Pending";
  static const int _defaultLimit = 5;
  final Map<String, int> _tabCounts = {
    "Pending": 0,
    "Accepted": 0,
    "Preparing": 0,
    "Ready": 0,
    "On Going": 0,
    "Delivered": 0,
    "Cancelled": 0,
  };
  final List<String> tabs = [
    "Pending",
    "Accepted",
    "Preparing",
    "Ready",
    "On Going",
    "Delivered",
    "Cancelled",
  ];
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    if (homeController.targetOrderStatusTab != null) {
      selectedTab = homeController.targetOrderStatusTab!;
      homeController.targetOrderStatusTab = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final homeController = Get.put(HomeController());
      maintenance(context);
    });
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> maintenance(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String buildNumber = packageInfo.version;
      final response = await DioClient().get(ApiEndPoints.vendorappSettings);
      if (!mounted) return;
      SettingsModel model = SettingsModel.fromJson(response.data);
      debugPrint("settings model: ${response.data}");
      debugPrint("current version vendor: $buildNumber");
      if (model.status.toString() == "true") {
        if (Platform.isAndroid &&
            model.data?.settings?[0].maintenanceAndroidVendor.toString() ==
                "1") {
          Get.offAll(
            Maintenance(
              serverDownReason: model
                  .data
                  ?.settings?[0]
                  .maintenanceReasonAndroidVendor
                  .toString(),
            ),
          );
        } else if (Platform.isIOS &&
            model.data?.settings?[0].maintenanceIosVendor.toString() == "1") {
          Get.offAll(
            Maintenance(
              serverDownReason: model
                  .data
                  ?.settings?[0]
                  .maintenanceReasonIosVendor
                  .toString(),
            ),
          );
        } else if (Platform.isAndroid &&
            (model.data?.settings?[0].playStoreUpdateVendor.toString() == "1" &&
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
                      model.data?.settings?[0].appStoreVersionVendor
                              .toString() ??
                          "",
                    ) >
                    versionToCode(buildNumber.toString()))) {
          Get.offAll(() => NeedAnUpdate());
        } else {
          if (mounted) {
            _fetchOrders();
          }
        }
      } else {
        if (mounted) {
          _fetchOrders();
        }
      }
    } catch (error, stackTrace) {
      debugPrint("maintenance Error: $error");
      debugPrint("maintenance StackTrace: $stackTrace");
      if (mounted) {
        _fetchOrders();
      }
    }
  }

  int _statusValue(String tab) {
    switch (tab) {
      case "Pending":
        return 1;
      case "Accepted":
        return 2;
      case "Preparing":
        return 3;
      case "Ready":
        return 4;
      case "On Going":
        return 8;
      case "Delivered":
        return 9;
      case "Cancelled":
        return 10;
      default:
        return 1;
    }
  }

  String _statusLabel(int? status) {
    switch (status) {
      case 1:
        return S.current.pending;
      case 2:
        return S.current.accepted;
      case 3:
        return S.current.preparing;
      case 4:
        return S.current.ready;
      case 5:
        return S.current.assignedStatus;
      case 6:
        return S.of(context).reachedRestaurant;
      case 7:
        return S.of(context).pickedUp;
      case 8:
        return S.of(context).delivering;
      case 9:
        return S.current.delivered;
      case 10:
        return S.current.cancelled;
      default:
        return S.current.pending;
    }
  }

  Future<void> _fetchOrders({String? keyword}) async {
    await homeController.getProfile(context);
    if (!mounted) return;
    await homeController.fetchHome(
      context,
      orderStatus: _statusValue(selectedTab),
      keyword: keyword ?? homeController.searchController.text.trim(),
      limit: _defaultLimit,
    );
    if (!mounted) return;
    _refreshSelectedTabCount();
  }

  void _refreshSelectedTabCount() {
    if (!mounted) return;
    final totalCount =
        homeController.homeData?.data?.orders?.total ??
        homeController.homeData?.data?.orders?.data?.length ??
        0;
    setState(() {
      _tabCounts[selectedTab] = totalCount;
    });
  }

  void _handleAcceptOrder(String orderId) {
    final vendorType =
        homeController.homeData?.data?.vendor?.vendorType?.toString() ?? "0";
    if (vendorType == "1") {
      detailsController.acceptRestaurantOrder(context, orderId);
    } else {
      detailsController.acceptGroceryOrder(context, orderId);
    }
  }

  void _handleCancelOrder(String orderId) {
    final vendorType =
        homeController.homeData?.data?.vendor?.vendorType?.toString() ?? "0";
    if (vendorType == "1") {
      detailsController.cancelRestaurantOrder(context, orderId);
    } else {
      detailsController.cancelGroceryOrder(context, orderId);
    }
  }

  void _handleMarkAsReady(String orderId) {
    final vendorType =
        homeController.homeData?.data?.vendor?.vendorType?.toString() ?? "0";
    if (vendorType == "1") {
      detailsController.markAsReadyRestaurantOrder(context, orderId);
    } else {
      detailsController.markAsReadyGroceryOrder(context, orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final layout = vendorHomeController.getLayoutConfig(
      screenWidth: size.width,
      screenHeight: size.height,
      topPadding: mediaQuery.padding.top,
    );
    return GetBuilder<HomeController>(
      builder: (controller) {
        dynamic userName = controller.homeData?.data?.vendor?.nameEn;
        final membership = controller.homeData?.data?.membership;
        final summary = controller.homeData?.data?.summary;
        final List<OrderData> orders =
            controller.homeData?.data?.orders?.data ?? <OrderData>[];
        final membershipName = membership?.nameEn?.trim().isNotEmpty == true
            ? membership!.nameEn!.trim()
            : S.of(context).membership;
        final expiryText = S
            .of(context)
            .expiresInDays(membership?.expiresInDays?.toString() ?? "0");
        return CommonBackground(
          resizeToAvoidBottomInset: false,
          child: SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: layout.topOffset),
                VendorHomeTopBar(
                  horizontalPadding: layout.horizontalPadding,
                  userName: userName,
                ),
                const SizedBox(height: 28),
                VendorMembershipCard(
                  horizontalPadding: layout.horizontalPadding,
                  width: size.width,
                  height: layout.membershipCardHeight,
                  membershipName: membershipName,
                  expiryText: expiryText,
                  isWarning: (membership?.expiresInDays ?? 0) <= 10,
                ),
                const SizedBox(height: 24),
                VendorStatsSection(
                  horizontalPadding: layout.horizontalPadding,
                  todayOrders: (summary?.todayOrders ?? 0).toString(),
                  totalOrders: (summary?.totalOrders ?? 0).toString(),
                  totalProducts: (summary?.totalProducts ?? 0).toString(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _fetchOrders();
                    },
                    color: colorPrimary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          VendorDashboardButton(
                            horizontalPadding: layout.horizontalPadding,
                            width: size.width,
                            height: layout.dashboardButtonHeight,
                          ),
                          const SizedBox(height: 10),
                          VendorOrdersHeader(
                            horizontalPadding: layout.horizontalPadding,
                            onViewAllPressed: () {
                              Get.to(() => const OrdersViewAll());
                            },
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: layout.horizontalPadding,
                            ),
                            child: CustomSearchBox(
                              hintText: S.of(context).searchByIdName,
                              controller: controller.searchController,
                              onChanged: (value) async {
                                await controller.fetchHome(
                                  context,
                                  orderStatus: _statusValue(selectedTab),
                                  keyword: value.trim(),
                                  limit: _defaultLimit,
                                );
                                _refreshSelectedTabCount();
                              },
                              boxColor: Colors.white,
                              showSearchIcon: true,
                              width: layout.searchBoxWidth,
                              height: 44,
                            ),
                          ),
                          const SizedBox(height: 16),
                          VendorStatusTabs(
                            height: layout.tabsHeight,
                            leftPadding: layout.horizontalPadding,
                            tabWidth: layout.tabWidth,
                            tabs: tabs,
                            tabCounts: _tabCounts,
                            selectedTab: selectedTab,
                            onTabChanged: (tab) {
                              setState(() {
                                selectedTab = tab;
                              });
                              _fetchOrders();
                            },
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: layout.horizontalPadding,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF16A34A),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Auto-Accept Orders",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Orders will be accepted automatically",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.85,
                                    child: CupertinoSwitch(
                                      value: controller.isAutoAcceptOrders,
                                      onChanged: (value) async {
                                        // API mapping: 1 = auto accept ON, 2 = OFF
                                        final statusToSend = value ? 1 : 2;
                                        await controller.updateAutoAcceptOrders(
                                          context,
                                          statusToSend,
                                        );
                                        if (mounted) {
                                          await _fetchOrders();
                                        }
                                      },
                                      activeTrackColor: const Color(0xFF16A34A),
                                      thumbColor: Colors.white,
                                      trackColor: const Color(0xFFD1D5DB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          controller.isFirstLoadRunning
                              ? const AppLoader()
                              : orders.isEmpty
                              ? NoDataWidget(
                                  context,
                                  S.of(context).noOrdersFound,
                                  "",
                                  "lib/assets/images/nodata.png",
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 20,
                                  ),
                                  itemCount: orders.length > 5
                                      ? 5
                                      : orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    final price =
                                        double.tryParse(order.total ?? "0") ??
                                        0;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: VendorOrderListItem(
                                        horizontalPadding:
                                            layout.horizontalPadding,
                                        orderId: order.id?.toString() ?? "NA",
                                        orderCode: order.orderCode,
                                        customerName:
                                            order.userName ??
                                            S.of(context).unknown,
                                        itemsCount: order.orderItemsCount ?? 0,
                                        price: price,
                                        dateTime: order.placedAtFormatted ?? "",
                                        status: _statusLabel(order.status),
                                        deliveryBoyName: order.deliveryBoyName,
                                        cancelReason: order.cancelReason,
                                        type: order.type,
                                        onAccept: () => _handleAcceptOrder(
                                          order.id?.toString() ?? "",
                                        ),
                                        onReject: () => _handleCancelOrder(
                                          order.id?.toString() ?? "",
                                        ),
                                        onMarkAsReady: () => _handleMarkAsReady(
                                          order.id?.toString() ?? "",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
