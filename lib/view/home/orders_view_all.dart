import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/controller/home_controller.dart';
import 'package:saimpex_vendor/controller/vendor_home_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/model/home_model.dart';
import 'package:saimpex_vendor/utils/printing/order_print_service.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/utils/widgets/custom_search_box.dart';
import 'package:saimpex_vendor/utils/widgets/no_data_widget.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_order_list_item.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_status_tabs.dart';
import 'package:saimpex_vendor/controller/order_details_controller.dart';
import 'package:saimpex_vendor/utils/widgets/accept_order_dialog.dart';

import '../../utils/Widgets/custom_app_bar.dart';
import '../../utils/utils.dart';

class OrdersViewAll extends StatefulWidget {
  const OrdersViewAll({super.key});

  @override
  State<OrdersViewAll> createState() => _OrdersViewAllState();
}

class _OrdersViewAllState extends State<OrdersViewAll> {
  final VendorHomeController vendorHomeController =
      const VendorHomeController();
  final HomeController homeController = Get.find<HomeController>();
  final OrderDetailsController detailsController = Get.put(
    OrderDetailsController(),
  );
  String selectedTab = "Pending";
  static const int _defaultLimit = 15;
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

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadMore = false;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_hasNextPage &&
        !homeController.isFirstLoadRunning &&
        !_isLoadMore &&
        _scrollController.position.extentAfter < 200) {
      if (mounted) {
        setState(() {
          _isLoadMore = true;
        });
      }
      _currentPage++;
      await homeController.fetchHome(
        context,
        orderStatus: _statusValue(selectedTab),
        keyword: homeController.searchController.text.trim(),
        limit: _defaultLimit,
        page: _currentPage,
        isLoadMore: true,
      );

      final currentOrders = homeController.homeData?.data?.orders;
      if (currentOrders != null) {
        if ((currentOrders.currentPage ?? 1) >= (currentOrders.lastPage ?? 1)) {
          _hasNextPage = false;
        }
      }

      if (mounted) {
        setState(() {
          _isLoadMore = false;
        });
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
    // Switch away from Pending tab if auto-accept is enabled
    if (homeController.isAutoAcceptOrders && selectedTab == "Pending") {
      setState(() {
        selectedTab = "Accepted";
      });
    }

    _currentPage = 1;
    _hasNextPage = true;
    await homeController.fetchHome(
      context,
      orderStatus: _statusValue(selectedTab),
      keyword: keyword ?? homeController.searchController.text.trim(),
      limit: _defaultLimit,
    );
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
    showAcceptOrderDialog(
      context: context,
      onAccept: () {
        final vendorType =
            homeController.homeData?.data?.vendor?.vendorType?.toString() ??
            "0";
        if (vendorType == "1") {
          detailsController.acceptRestaurantOrder(context, orderId);
        } else {
          detailsController.acceptGroceryOrder(context, orderId);
        }
      },
      onAcceptAndPrint: () {
        final vendorType =
            homeController.homeData?.data?.vendor?.vendorType?.toString() ??
            "0";
        if (vendorType == "1") {
          detailsController.acceptRestaurantOrder(context, orderId);
        } else {
          detailsController.acceptGroceryOrder(context, orderId);
        }
      },
    );
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

  Future<void> _handlePrintOrder(String orderId, String? orderType) async {
    try {
      final payload = await OrderPrintService().printOrder(
        orderId: orderId,
        orderType: orderType,
      );
      debugPrint('ESC/POS bytes generated: ${payload.bytes80mm.length}');
      if (!mounted) return;
      showToast(context, 'Printed successfully');
      debugPrint(payload.preview);
    } catch (error) {
      if (!mounted) return;
      showToast(context, error.toString());
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
          appBar: CustomAppBar(
            title: S.of(context).orders,
            onTap: () => Get.back(),
          ),
          child: SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
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
                  tabs: controller.isAutoAcceptOrders
                      ? tabs.where((t) => t != "Pending").toList()
                      : tabs,
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
                Expanded(
                  child: controller.isFirstLoadRunning
                      ? const AppLoader()
                      : orders.isEmpty
                      ? NoDataWidget(
                          context,
                          S.of(context).noOrdersFound,
                          "",
                          "lib/assets/images/nodata.png",
                          imgHeight: MediaQuery.of(context).size.height * 0.25,
                          imgWidth: MediaQuery.of(context).size.width * 0.6,
                          fontSize: 18,
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 20,
                                ),
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  final price =
                                      double.tryParse(order.total ?? "0") ?? 0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
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
                                      onPrint: () => _handlePrintOrder(
                                        order.id?.toString() ?? "",
                                        order.type,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (_isLoadMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: AppLoader(size: 40),
                              ),
                          ],
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
