import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/model/home_model.dart';
import 'package:saimpex_vendor/pharmacy/controller/pharmacy_home_controller.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_order.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_prescriptions_model.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_account_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_chat_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_inventory_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_notifications_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/order_details_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/reject_order_sheet.dart';
import 'package:saimpex_vendor/utils/widgets/no_data_widget.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

class PharmacyHome extends StatefulWidget {
  const PharmacyHome({super.key});

  @override
  State<PharmacyHome> createState() => _PharmacyHomeState();
}

class _PharmacyHomeState extends State<PharmacyHome> {
  late final PharmacyHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PharmacyHomeController());
  }

  @override
  void dispose() {
    Get.delete<PharmacyHomeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PharmacyHomeController>(
      builder: (_) => Theme(
        data: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.backgroundTop,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryOrange,
            surface: AppColors.card,
          ),
        ),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: controller.bottomNavIndex == 2
                ? Colors.white
                : const Color(0xFFF7F7F7),
            body: Column(
              children: [
                Expanded(
                  child: switch (controller.bottomNavIndex) {
                    0 => _buildHomeTab(context),
                    1 => _buildOrdersTab(context),
                    2 => PharmacyMessagesTab(
                      onBack: () => controller.onBottomNavSelect(0),
                    ),
                    3 => PharmacyInventoryTab(
                      onBack: () => controller.onBottomNavSelect(0),
                    ),
                    _ => PharmacyAccountScreen(
                      onBack: () => controller.onBottomNavSelect(0),
                    ),
                  },
                ),
                _BottomNav(
                  selectedIndex: controller.bottomNavIndex,
                  onSelect: controller.onBottomNavSelect,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF0E8), Color(0xFFFFF8F4), Color(0xFFF7F7F7)],
          stops: [0, 0.22, 1],
        ),
      ),
      child: RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () async {
          if (!controller.isOtcTab && controller.selectedFilterIndex == 0) {
            await controller.fetchPharmacyPrescriptions();
          } else if (controller.isOtcTab &&
              controller.selectedFilterIndex == 0) {
            await controller.fetchPharmacyOrders(status: 1);
          } else if (controller.isOtcTab &&
              controller.selectedFilterIndex == 1) {
            await controller.fetchPharmacyOrders(status: 2);
          } else if (controller.isOtcTab &&
              controller.selectedFilterIndex == 2) {
            await controller.fetchPharmacyOrders(status: 3);
          } else if (controller.isOtcTab &&
              controller.selectedFilterIndex == 3) {
            await controller.fetchPharmacyOrders(status: 4);
          } else if (controller.isOtcTab &&
              controller.selectedFilterIndex == 4) {
            await controller.fetchPharmacyOrders(status: 9);
          } else if (controller.isOtcTab &&
              controller.selectedFilterIndex == 5) {
            await controller.fetchPharmacyOrders(status: 10);
          }
          await controller.fetchPharmacyHome();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 8,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: const _Header(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StoreStatusCard(
                    isOpen: controller.isStoreOpen,
                    onToggle: controller.toggleStore,
                  ),
                  const SizedBox(height: 12),
                  _MetricsGrid(
                    newPrescriptions: controller.newPrescriptionsCount,
                    newOtcOrders: controller.newOtcCount,
                    preparing: controller.preparingCount,
                    ready: controller.readyCount,
                  ),
                  const SizedBox(height: 16),
                  _TotalsRow(
                    orders: controller.totalOrdersValue,
                    completed: controller.completedOrdersValue,
                    revenue: controller.revenueValue,
                  ),
                  const SizedBox(height: 18),
                  _OrdersHeader(
                    onSeeAll: () => controller.onBottomNavSelect(1),
                  ),
                  const SizedBox(height: 12),
                  if (controller.isOtcTab ||
                      controller.selectedFilterIndex == 0 ||
                      controller.selectedFilterIndex == 3 ||
                      controller.selectedFilterIndex == 4 ||
                      controller.selectedFilterIndex == 5 ||
                      controller.selectedFilterIndex == 6 ||
                      controller.selectedFilterIndex == 7) ...[
                    _OrderTypeTabs(
                      selectedIndex: controller.selectedOrderType,
                      onSelect: controller.selectOrderType,
                      prescriptionBadge: controller.prescriptionBadge,
                      otcBadge: controller.otcBadge,
                    ),
                    const SizedBox(height: 14),
                  ],
                  _SearchField(
                    controller: controller.searchController,
                    onSubmitted: (val) async {
                      if (!controller.isOtcTab &&
                          controller.selectedFilterIndex == 0) {
                        controller.fetchPharmacyPrescriptions(keyword: val);
                      } else if (controller.isOtcTab &&
                          controller.selectedFilterIndex == 0) {
                        controller.fetchPharmacyOrders(status: 1, keyword: val);
                      } else if (controller.isOtcTab &&
                          controller.selectedFilterIndex == 1) {
                        controller.fetchPharmacyOrders(status: 2, keyword: val);
                      } else if (controller.isOtcTab &&
                          controller.selectedFilterIndex == 2) {
                        controller.fetchPharmacyOrders(status: 3, keyword: val);
                      } else if (controller.isOtcTab &&
                          controller.selectedFilterIndex == 3) {
                        controller.fetchPharmacyOrders(status: 4, keyword: val);
                      } else if (controller.isOtcTab &&
                          controller.selectedFilterIndex == 4) {
                        controller.fetchPharmacyOrders(status: 9, keyword: val);
                      } else if (controller.isOtcTab &&
                          controller.selectedFilterIndex == 5) {
                        controller.fetchPharmacyOrders(
                          status: 10,
                          keyword: val,
                        );
                      }
                      controller.fetchPharmacyHome(keyword: val);
                    },
                  ),
                  const SizedBox(height: 12),
                  _StatusFilters(
                    filters: controller.activeFilters,
                    selectedIndex: controller.selectedFilterIndex.clamp(
                      0,
                      controller.activeFilters.length - 1,
                    ),
                    onSelect: controller.selectFilter,
                    badgeLabel: controller.filterBadgeLabel,
                  ),
                  const SizedBox(height: 12),
                  ..._buildHomeOrderCards(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHomeOrderCards(BuildContext context) {
    return _buildDynamicOrderCards(context);
  }

  Widget _buildOrdersTab(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF0E8), Color(0xFFFFF8F4), Color(0xFFF7F7F7)],
          stops: [0, 0.18, 1],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Orders',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => controller.onBottomNavSelect(0),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE0D0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.primaryOrange,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _OrderTypeTabs(
              selectedIndex: controller.selectedOrderType,
              onSelect: controller.selectOrderType,
              prescriptionBadge: controller.prescriptionBadge,
              otcBadge: controller.otcBadge,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SearchField(
              controller: controller.searchController,
              onSubmitted: (val) async {
                if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 0) {
                  controller.fetchPharmacyPrescriptions(keyword: val);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 0) {
                  controller.fetchPharmacyOrders(status: 1, keyword: val);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 1) {
                  controller.fetchPharmacyOrders(status: 2, keyword: val);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 2) {
                  controller.fetchPharmacyOrders(status: 3, keyword: val);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 3) {
                  controller.fetchPharmacyOrders(status: 4, keyword: val);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 4) {
                  controller.fetchPharmacyOrders(status: 9, keyword: val);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 5) {
                  controller.fetchPharmacyOrders(status: 10, keyword: val);
                }
                controller.fetchPharmacyHome(keyword: val);
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryOrange,
              onRefresh: () async {
                if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 0) {
                  await controller.fetchPharmacyPrescriptions();
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 0) {
                  await controller.fetchPharmacyOrders(status: 1);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 1) {
                  await controller.fetchPharmacyOrders(status: 2);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 2) {
                  await controller.fetchPharmacyOrders(status: 3);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 3) {
                  await controller.fetchPharmacyOrders(status: 4);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 4) {
                  await controller.fetchPharmacyOrders(status: 9);
                } else if (controller.isOtcTab &&
                    controller.selectedFilterIndex == 5) {
                  await controller.fetchPharmacyOrders(status: 10);
                }
                await controller.fetchPharmacyHome();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                children: [
                  _StatusFilters(
                    filters: controller.activeFilters,
                    selectedIndex: controller.selectedFilterIndex.clamp(
                      0,
                      controller.activeFilters.length - 1,
                    ),
                    onSelect: controller.selectFilter,
                    badgeLabel: controller.filterBadgeLabel,
                  ),
                  const SizedBox(height: 12),
                  ..._buildOrdersTabCards(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrdersTabCards(BuildContext context) {
    return _buildDynamicOrderCards(context);
  }

  List<Widget> _buildDynamicOrderCards(BuildContext context) {
    final isPrescriptionNew =
        !controller.isOtcTab && controller.selectedFilterIndex == 0;

    if (isPrescriptionNew) {
      if (controller.isLoadingPrescriptions) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.prescriptionsList.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: NoDataWidget(
              context,
              S.of(context).noOrdersFound,
              "",
              "lib/assets/images/nodata.png",
            ),
          ),
        ];
      }

      final widgets = <Widget>[];
      for (int i = 0; i < controller.prescriptionsList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final item = controller.prescriptionsList[i];
        widgets.add(
          _PrescriptionOrderCard(
            customerName: item.displayCustomerName,
            orderCode: item.displayOrderCode,
            timeAgo: item.displayTimeAgo,
            isSelfPickup: item.isSelfPickupBool,
            status: PharmacyPrescriptionCardStatus.newOrder,
            notesType: item.notesType,
            prescriptionFileName: item.displayFileName,
            prescriptionImageUrl: item.displayImageUrl,
            specialNotes: item.note,
            phone: item.displayPhone,
            prescriptionId: item.prescriptionId ?? item.id,
          ),
        );
      }
      return widgets;
    }

    final isOtcNew = controller.isOtcTab && controller.selectedFilterIndex == 0;

    if (isOtcNew) {
      if (controller.isLoadingOtcOrders) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.otcOrdersList.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: NoDataWidget(
              context,
              S.of(context).noOrdersFound,
              "",
              "lib/assets/images/nodata.png",
            ),
          ),
        ];
      }

      final widgets = <Widget>[];
      for (int i = 0; i < controller.otcOrdersList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final order = controller.otcOrdersList[i];
        final rawId = order.resolvedId;
        widgets.add(
          _OtcNewOrderCard(
            customerName: order.displayCustomerName,
            orderId: order.displayOrderCode,
            timeAgo: order.displayTimeAgo,
            selfPickup: order.isSelfPickupBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            accepted: false,
            preparing: false,
            ready: false,
            delivered: false,
            partnerName: order.deliveryBoyName,
            itemsSummary: order.displayItemsSummary,
            phone: order.phone,
            orderRawId: rawId,
            isAccepting:
                controller.isAcceptingOrder &&
                controller.acceptingOrderId == rawId,
            onAccept: rawId != null
                ? () => controller.acceptPharmacyOrder(rawId, context: context)
                : null,
            isRejecting:
                controller.isCancellingOrder &&
                controller.cancellingOrderId == rawId,
            onReject: rawId != null
                ? () => controller.cancelPharmacyOrder(rawId, context: context)
                : null,
          ),
        );
      }
      return widgets;
    }

    final isOtcAccepted =
        controller.isOtcTab && controller.selectedFilterIndex == 1;

    if (isOtcAccepted) {
      if (controller.isLoadingOtcAcceptedOrders) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.otcAcceptedOrdersList.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: NoDataWidget(
              context,
              S.of(context).noOrdersFound,
              "",
              "lib/assets/images/nodata.png",
            ),
          ),
        ];
      }

      final widgets = <Widget>[];
      for (int i = 0; i < controller.otcAcceptedOrdersList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final order = controller.otcAcceptedOrdersList[i];
        final rawId = order.resolvedId;
        widgets.add(
          _OtcNewOrderCard(
            customerName: order.displayCustomerName,
            orderId: order.displayOrderCode,
            timeAgo: order.displayTimeAgo,
            selfPickup: order.isSelfPickupBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            accepted: true,
            preparing: false,
            ready: false,
            delivered: false,
            partnerName: order.deliveryBoyName,
            itemsSummary: order.displayItemsSummary,
            phone: order.phone,
            orderRawId: rawId,
            isPreparingAction:
                controller.isPreparingOrder &&
                controller.preparingOrderId == rawId,
            onPrepare: rawId != null
                ? () => controller.preparePharmacyOrder(rawId, context: context)
                : null,
          ),
        );
      }
      return widgets;
    }

    final isOtcPreparing =
        controller.isOtcTab && controller.selectedFilterIndex == 2;

    if (isOtcPreparing) {
      if (controller.isLoadingOtcPreparingOrders) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.otcPreparingOrdersList.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: NoDataWidget(
              context,
              S.of(context).noOrdersFound,
              "",
              "lib/assets/images/nodata.png",
            ),
          ),
        ];
      }

      final widgets = <Widget>[];
      for (int i = 0; i < controller.otcPreparingOrdersList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final order = controller.otcPreparingOrdersList[i];
        final rawId = order.resolvedId;
        widgets.add(
          _OtcNewOrderCard(
            customerName: order.displayCustomerName,
            orderId: order.displayOrderCode,
            timeAgo: order.displayTimeAgo,
            selfPickup: order.isSelfPickupBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            accepted: false,
            preparing: true,
            ready: false,
            delivered: false,
            partnerName: order.deliveryBoyName,
            itemsSummary: order.displayItemsSummary,
            phone: order.phone,
            orderRawId: rawId,
            isMarkingReadyAction: controller.isMarkingReadyOrder &&
                controller.markingReadyOrderId == rawId,
            onMarkAsReady: rawId != null
                ? () => controller.markAsReadyPharmacyOrder(rawId,
                    context: context)
                : null,
          ),
        );
      }
      return widgets;
    }

    final isOtcReady =
        controller.isOtcTab && controller.selectedFilterIndex == 3;

    if (isOtcReady) {
      if (controller.isLoadingOtcReadyOrders) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.otcReadyOrdersList.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: NoDataWidget(
              context,
              S.of(context).noOrdersFound,
              "",
              "lib/assets/images/nodata.png",
            ),
          ),
        ];
      }

      final widgets = <Widget>[];
      for (int i = 0; i < controller.otcReadyOrdersList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final order = controller.otcReadyOrdersList[i];
        widgets.add(
          _OtcNewOrderCard(
            customerName: order.displayCustomerName,
            orderId: order.displayOrderCode,
            timeAgo: order.displayTimeAgo,
            selfPickup: order.isSelfPickupBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            accepted: false,
            preparing: false,
            ready: true,
            delivered: false,
            partnerName: order.deliveryBoyName,
            itemsSummary: order.displayItemsSummary,
            phone: order.phone,
            orderRawId: order.resolvedId,
          ),
        );
      }
      return widgets;
    }

    final isOtcDelivered =
        controller.isOtcTab && controller.selectedFilterIndex == 4;

    if (isOtcDelivered) {
      if (controller.isLoadingOtcDeliveredOrders) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.otcDeliveredOrdersList.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: NoDataWidget(
              context,
              S.of(context).noOrdersFound,
              "",
              "lib/assets/images/nodata.png",
            ),
          ),
        ];
      }

      final widgets = <Widget>[];
      for (int i = 0; i < controller.otcDeliveredOrdersList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final order = controller.otcDeliveredOrdersList[i];
        widgets.add(
          _OtcNewOrderCard(
            customerName: order.displayCustomerName,
            orderId: order.displayOrderCode,
            timeAgo: order.displayTimeAgo,
            selfPickup: order.isSelfPickupBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            accepted: false,
            preparing: false,
            ready: false,
            delivered: true,
            partnerName: order.deliveryBoyName,
            itemsSummary: order.displayItemsSummary,
            phone: order.phone,
            orderRawId: order.resolvedId,
          ),
        );
      }
      return widgets;
    }

    final isOtcCancelled =
        controller.isOtcTab && controller.selectedFilterIndex == 5;

    if (isOtcCancelled) {
      if (controller.isLoadingOtcCancelledOrders) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.otcCancelledOrdersList.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: NoDataWidget(
              context,
              S.of(context).noOrdersFound,
              "",
              "lib/assets/images/nodata.png",
            ),
          ),
        ];
      }

      final widgets = <Widget>[];
      for (int i = 0; i < controller.otcCancelledOrdersList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final order = controller.otcCancelledOrdersList[i];
        widgets.add(
          _OtcNewOrderCard(
            customerName: order.displayCustomerName,
            orderId: order.displayOrderCode,
            timeAgo: order.displayTimeAgo,
            selfPickup: order.isSelfPickupBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            accepted: false,
            preparing: false,
            ready: false,
            delivered: false,
            cancelled: true,
            partnerName: order.deliveryBoyName,
            itemsSummary: order.displayItemsSummary,
            phone: order.phone,
            orderRawId: order.resolvedId,
          ),
        );
      }
      return widgets;
    }

    if (controller.isLoadingHome) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          ),
        ),
      ];
    }

    if (controller.ordersList.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: NoDataWidget(
            context,
            S.of(context).noOrdersFound,
            "",
            "lib/assets/images/nodata.png",
          ),
        ),
      ];
    }

    final filter = controller.selectedFilterIndex.clamp(
      0,
      controller.activeFilters.length - 1,
    );
    final isOtc = controller.isOtcTab;
    final widgets = <Widget>[];

    for (int i = 0; i < controller.ordersList.length; i++) {
      if (i > 0) {
        widgets.add(const SizedBox(height: 12));
      }
      final order = controller.ordersList[i];
      final orderCode = order.orderCode?.isNotEmpty == true
          ? (order.orderCode!.startsWith('#')
                ? order.orderCode!
                : '#${order.orderCode}')
          : '#${order.id ?? ''}';
      final customerName = order.userName?.isNotEmpty == true
          ? order.userName!
          : 'Customer';
      final timeAgo = order.placedAtFormatted?.isNotEmpty == true
          ? order.placedAtFormatted!
          : (order.placedAt ?? '');
      final isSelfPickup =
          order.isSelfPickup == 1 ||
          order.isSelfPickup == true ||
          order.isSelfPickup?.toString() == '1' ||
          order.isSelfPickup?.toString().toLowerCase() == 'true';
      final partnerName = order.deliveryBoyName;

      if (isOtc) {
        final isAccepted = filter == 1 || order.status == 2;
        final isPreparing = filter == 2 || order.status == 3;
        final isReady = filter == 3 || order.status == 4;
        final isDelivered = filter == 4 || order.status == 9;

        final itemCount = order.orderItemsCount ?? order.totalItems ?? 0;
        final totalStr = order.total?.toString().trim() ?? '';
        final dynamicItemsSummary = itemCount > 0 && totalStr.isNotEmpty
            ? '$itemCount ${itemCount == 1 ? 'Item' : 'Items'} • ${totalStr.contains('MRU') ? totalStr : '$totalStr MRU'}'
            : (totalStr.isNotEmpty
                  ? (totalStr.contains('MRU') ? totalStr : '$totalStr MRU')
                  : (itemCount > 0
                        ? '$itemCount ${itemCount == 1 ? 'Item' : 'Items'}'
                        : null));

        final rawId = order.id;
        widgets.add(
          _OtcNewOrderCard(
            customerName: customerName,
            orderId: orderCode,
            timeAgo: timeAgo,
            selfPickup: isSelfPickup,
            accepted: isAccepted,
            preparing: isPreparing,
            ready: isReady,
            delivered: isDelivered,
            partnerName: partnerName,
            itemsSummary: dynamicItemsSummary,
            phone: order.userMobile,
            orderRawId: rawId,
            isAccepting:
                controller.isAcceptingOrder &&
                controller.acceptingOrderId == rawId,
            onAccept:
                (!isAccepted &&
                    !isPreparing &&
                    !isReady &&
                    !isDelivered &&
                    rawId != null)
                ? () => controller.acceptPharmacyOrder(rawId, context: context)
                : null,
            isRejecting:
                controller.isCancellingOrder &&
                controller.cancellingOrderId == rawId,
            onReject:
                (!isAccepted &&
                    !isPreparing &&
                    !isReady &&
                    !isDelivered &&
                    rawId != null)
                ? () => controller.cancelPharmacyOrder(rawId, context: context)
                : null,
            isPreparingAction:
                controller.isPreparingOrder &&
                controller.preparingOrderId == rawId,
            onPrepare: (isAccepted && rawId != null)
                ? () => controller.preparePharmacyOrder(rawId, context: context)
                : null,
            isMarkingReadyAction:
                controller.isMarkingReadyOrder &&
                controller.markingReadyOrderId == rawId,
            onMarkAsReady: (isPreparing && rawId != null)
                ? () => controller.markAsReadyPharmacyOrder(rawId,
                    context: context)
                : null,
          ),
        );
      } else {
        if (filter == 1) {
          widgets.add(
            _PrescriptionOrderCard(
              customerName: customerName,
              orderCode: orderCode,
              timeAgo: timeAgo,
              isSelfPickup: isSelfPickup,
              status: PharmacyPrescriptionCardStatus.underReview,
              notesType: PharmacyOrderNotesType.none,
              prescriptionId: order.id,
              phone: order.userMobile,
            ),
          );
        } else if (filter == 2) {
          widgets.add(
            _PrescriptionOrderCard(
              customerName: customerName,
              orderCode: orderCode,
              timeAgo: timeAgo,
              isSelfPickup: isSelfPickup,
              status: PharmacyPrescriptionCardStatus.reviewCompleted,
              notesType: PharmacyOrderNotesType.none,
              prescriptionId: order.id,
              phone: order.userMobile,
            ),
          );
        } else if (filter == 3) {
          widgets.add(
            _AwaitingPaymentCard(
              customerName: customerName,
              orderCode: orderCode,
              timeAgo: timeAgo,
              quotationAmount: order.total?.toString(),
              prescriptionId: order.id,
              phone: order.userMobile,
            ),
          );
        } else if (filter == 4) {
          widgets.add(
            _ToPrepareCard(
              customerName: customerName,
              orderCode: orderCode,
              timeAgo: timeAgo,
              isSelfPickup: isSelfPickup,
              prescriptionId: order.id,
              phone: order.userMobile,
            ),
          );
        } else if (filter == 5) {
          widgets.add(
            _PreparingCard(
              customerName: customerName,
              orderCode: orderCode,
              timeAgo: timeAgo,
              isSelfPickup: isSelfPickup,
              prescriptionId: order.id,
              phone: order.userMobile,
            ),
          );
        } else if (filter == 6) {
          widgets.add(
            _ReadyCard(
              customerName: customerName,
              orderCode: orderCode,
              timeAgo: timeAgo,
              isSelfPickup: isSelfPickup,
              partnerName: partnerName,
              prescriptionId: order.id,
              phone: order.userMobile,
            ),
          );
        } else if (filter == 7) {
          widgets.add(
            _DeliveredCard(
              customerName: customerName,
              orderCode: orderCode,
              timeAgo: timeAgo,
              isSelfPickup: isSelfPickup,
              prescriptionId: order.id,
              phone: order.userMobile,
            ),
          );
        } else {
          widgets.add(
            _PrescriptionOrderCard(
              customerName: customerName,
              orderCode: orderCode,
              timeAgo: timeAgo,
              isSelfPickup: isSelfPickup,
              status: PharmacyPrescriptionCardStatus.newOrder,
              notesType: PharmacyOrderNotesType.none,
              prescriptionId: order.id,
              phone: order.userMobile,
            ),
          );
        }
      }
    }

    return widgets;
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            AppAssets.homeTopIcon,
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_pharmacy_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Welcome to Saimpex Vendor!',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PharmacyNotificationsScreen(),
              ),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.paymentDivider,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreStatusCard extends StatelessWidget {
  const _StoreStatusCard({required this.isOpen, required this.onToggle});

  final bool isOpen;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.iconGreenBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              AppAssets.shopOpenIcon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.storefront_outlined,
                color: AppColors.iconGreen,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Open • Accepting orders' : 'Closed • Not accepting',
                  style: TextStyle(
                    color: isOpen ? AppColors.iconGreen : AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Today: 08:00 - 22:00',
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onToggle(!isOpen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isOpen
                    ? const Color(0xFFFF6B00)
                    : const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: isOpen ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    this.newPrescriptions = '0',
    this.newOtcOrders = '0',
    this.preparing = '0',
    this.ready = '0',
  });

  final String newPrescriptions;
  final String newOtcOrders;
  final String preparing;
  final String ready;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                count: newPrescriptions,
                label: 'New prescriptions',
                badgeGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF8A3D), Color(0xFFFF5722)],
                ),
                countColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: newOtcOrders,
                label: 'New OTC orders',
                badgeColor: const Color(0xFFB2DFDB),
                countColor: const Color(0xFF00695C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                count: preparing,
                label: 'Preparing',
                badgeColor: const Color(0xFFFFB300),
                countColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: ready,
                label: 'Ready',
                badgeColor: const Color(0xFF43A047),
                countColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.count,
    required this.label,
    required this.countColor,
    this.badgeColor,
    this.badgeGradient,
  });

  final String count;
  final String label;
  final Color countColor;
  final Color? badgeColor;
  final Gradient? badgeGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeGradient == null ? badgeColor : null,
              gradient: badgeGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: TextStyle(
                color: countColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    this.orders = '0',
    this.completed = '0',
    this.revenue = '0',
  });

  final String orders;
  final String completed;
  final String revenue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _TotalItem(title: 'ORDERS', value: orders),
          ),
          const _VDivider(),
          Expanded(
            child: _TotalItem(title: 'COMPLETED', value: completed),
          ),
          const _VDivider(),
          Expanded(
            child: _TotalItem(
              title: 'REVENUE',
              value: revenue,
              suffix: 'MRU',
              showTrend: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: AppColors.homeDivider);
  }
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({
    required this.title,
    required this.value,
    this.suffix,
    this.showTrend = false,
  });

  final String title;
  final String value;
  final String? suffix;
  final bool showTrend;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTrend) ...[
              const Icon(
                Icons.trending_up_rounded,
                size: 13,
                color: Color(0xFF2EAD5B),
              ),
              const SizedBox(width: 3),
            ],
            Text(
              title,
              style: const TextStyle(
                color: AppColors.homeLabel,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: AppColors.homeValue,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              if (suffix != null)
                TextSpan(
                  text: ' $suffix',
                  style: const TextStyle(
                    color: AppColors.homeValue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'ORDERS',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'See All',
            style: TextStyle(
              color: AppColors.primaryOrange,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderTypeTabs extends StatelessWidget {
  const _OrderTypeTabs({
    required this.selectedIndex,
    required this.onSelect,
    this.prescriptionBadge,
    this.otcBadge,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String? prescriptionBadge;
  final String? otcBadge;

  static const _labels = ['Prescription', 'OTC'];

  @override
  Widget build(BuildContext context) {
    final badges = [prescriptionBadge, otcBadge];
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFF5722), Color(0xFFFF8F3D), Color(0xFFFFC04D)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeTab(
              label: 'Prescription',
              selected: selectedIndex == 0,
              badge: selectedIndex == 0 ? prescriptionBadge : null,
              onTap: () => onSelect(0),
            ),
          ),
          Expanded(
            child: _TypeTab(
              label: 'OTC',
              selected: selectedIndex == 1,
              badge: selectedIndex == 1 ? otcBadge : null,
              onTap: () => onSelect(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOutCubic,
              style: TextStyle(
                color: selected ? const Color(0xFF1A1A1A) : Colors.white,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (badge != null && selected)
            Positioned(
              right: 2,
              top: -3,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF9E9E9E), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search by ID, name',
                hintStyle: TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: AppColors.textDark, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatefulWidget {
  const _StatusFilters({
    required this.filters,
    required this.selectedIndex,
    required this.onSelect,
    required this.badgeLabel,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String badgeLabel;

  @override
  State<_StatusFilters> createState() => _StatusFiltersState();
}

class _StatusFiltersState extends State<_StatusFilters> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();
  final Map<int, GlobalKey> _itemKeys = {};

  GlobalKey _keyFor(int index) => _itemKeys.putIfAbsent(index, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    _revealSelected();
  }

  @override
  void didUpdateWidget(covariant _StatusFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _revealSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _revealSelected() {
    if (widget.selectedIndex < 2) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final itemContext = _keyFor(widget.selectedIndex).currentContext;
      final viewportContext = _viewportKey.currentContext;
      if (itemContext == null || viewportContext == null) return;
      final itemBox = itemContext.findRenderObject() as RenderBox?;
      final viewportBox = viewportContext.findRenderObject() as RenderBox?;
      if (itemBox == null || viewportBox == null || !itemBox.hasSize) return;
      final dx = itemBox.localToGlobal(Offset.zero, ancestor: viewportBox).dx;
      final target = (_scrollController.offset + dx - 108).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Extra height so the floating "02" badge is not clipped.
    return SizedBox(
      key: _viewportKey,
      height: 46,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 6, right: 6),
        itemCount: widget.filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == widget.selectedIndex;
          final showBadge = selected && widget.badgeLabel.isNotEmpty;

          return KeyedSubtree(
            key: _keyFor(index),
            child: GestureDetector(
              onTap: () => widget.onSelect(index),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: selected
                          ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFFFF5421), Color(0xFFFFB800)],
                            )
                          : null,
                      color: selected ? null : Colors.white,
                      border: selected
                          ? null
                          : Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Text(
                      widget.filters[index],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF757575),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (showBadge)
                    Positioned(
                      // Top-right corner of the pill, slightly overlapping outside.
                      top: -6,
                      right: -4,
                      child: Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.badgeLabel,
                          style: const TextStyle(
                            color: Color(0xFFFF8A00),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

enum PharmacyPrescriptionCardStatus { newOrder, underReview, reviewCompleted }

class _PrescriptionOrderCard extends StatelessWidget {
  const _PrescriptionOrderCard({
    this.customerName = 'Ahmed',
    this.orderCode = '#22789007',
    this.timeAgo = '2 min ago',
    this.notesType = PharmacyOrderNotesType.none,
    this.isSelfPickup = false,
    this.status = PharmacyPrescriptionCardStatus.newOrder,
    this.prescriptionFileName,
    this.prescriptionImageUrl,
    this.specialNotes,
    this.phone,
    this.prescriptionId,
  });

  final String customerName;
  final String orderCode;
  final String timeAgo;
  final PharmacyOrderNotesType notesType;
  final bool isSelfPickup;
  final PharmacyPrescriptionCardStatus status;
  final String? prescriptionFileName;
  final String? prescriptionImageUrl;
  final String? specialNotes;
  final String? phone;
  final int? prescriptionId;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFC62828);
  static const Color _nameColor = Color(0xFF111827);
  static const Color _metaColor = Color(0xFF6B7280);
  static const Color _newBadge = Color(0xFFF99D1C);
  static const Color _reviewingBadge = Color(0xFF8E6CE0);
  static const Color _completedBadge = Color(0xFF22C55E);
  static const Color _attachBg = Color(0xFFFAF9F7);
  static const Color _attachBorder = Color(0xFFEAEAEA);
  static const Color _linkOrange = Color(0xFFFF6B2B);
  static const Color _rejectBorder = Color(0xFFE0E0E0);

  bool get _isUnderReview =>
      status == PharmacyPrescriptionCardStatus.underReview;

  bool get _isReviewCompleted =>
      status == PharmacyPrescriptionCardStatus.reviewCompleted;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = switch (status) {
      PharmacyPrescriptionCardStatus.underReview => 'REVIEWING',
      PharmacyPrescriptionCardStatus.reviewCompleted => 'REVIEW COMPLETED',
      PharmacyPrescriptionCardStatus.newOrder => 'NEW',
    };
    final badgeColor = switch (status) {
      PharmacyPrescriptionCardStatus.underReview => _reviewingBadge,
      PharmacyPrescriptionCardStatus.reviewCompleted => _completedBadge,
      PharmacyPrescriptionCardStatus.newOrder => _newBadge,
    };
    final primaryLabel = switch (status) {
      PharmacyPrescriptionCardStatus.underReview => 'Mark as Reviewed',
      PharmacyPrescriptionCardStatus.reviewCompleted => 'Create Quotation',
      PharmacyPrescriptionCardStatus.newOrder => 'Review Prescription',
    };

    void openDetails() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PharmacyOrderDetailsScreen(
            customerName: customerName,
            phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
            requestId: orderCode,
            requestMeta: timeAgo,
            notesType: notesType,
            specialNotes: specialNotes ?? '',
            isSelfPickup: isSelfPickup,
            isUnderReview: _isUnderReview,
            isReviewCompleted: _isReviewCompleted,
            prescriptionId: prescriptionId,
            orderId: prescriptionId,
            orderRawId: prescriptionId,
            prescriptionImageUrl: prescriptionImageUrl,
          ),
        ),
      );
    }

    void openQuotation() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PharmacyCreateQuotationScreen(
            customerName: customerName,
            imageUrl: prescriptionImageUrl,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openDetails,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF0F0F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _avatarBg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      customerName.isNotEmpty
                          ? customerName.substring(0, 1).toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: _avatarText,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customerName,
                                style: const TextStyle(
                                  color: _nameColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _isReviewCompleted ? 8 : 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                badgeLabel,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _isReviewCompleted ? 9 : 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: _isReviewCompleted ? 0.2 : 0.4,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            timeAgo.isNotEmpty
                                ? '$orderCode • $timeAgo'
                                : orderCode,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              color: _metaColor,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _attachBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _attachBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _PrescriptionThumb(imageUrl: prescriptionImageUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (prescriptionFileName != null &&
                                    prescriptionFileName!.isNotEmpty)
                                ? prescriptionFileName!
                                : 'Prescription.jpg',
                            style: const TextStyle(
                              color: _nameColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: openDetails,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Full Prescription',
                                  style: TextStyle(
                                    color: _linkOrange,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 14,
                                  color: _linkOrange,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => showPharmacyRejectOrderSheet(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _nameColor,
                          side: const BorderSide(
                            color: _rejectBorder,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Reject',
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _linkOrange,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _linkOrange.withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isReviewCompleted
                              ? openQuotation
                              : openDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            primaryLabel,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrescriptionThumb extends StatelessWidget {
  const _PrescriptionThumb({this.imageUrl});

  final String? imageUrl;
  static const _asset = 'lib/pharmacy/Assets/images/prescription_home.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 68,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: (imageUrl != null && imageUrl!.startsWith('http'))
            ? Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Image.asset(_asset, fit: BoxFit.contain),
              )
            : Image.asset(_asset, fit: BoxFit.contain),
      ),
    );
  }
}

class _ToPrepareCard extends StatelessWidget {
  const _ToPrepareCard({
    this.scheduled = false,
    this.customerName = 'Ahmed',
    this.orderCode = '#22789007',
    this.timeAgo = '2 min ago',
    this.isSelfPickup = false,
    this.prescriptionId,
    this.phone,
  });

  final bool scheduled;
  final String customerName;
  final String orderCode;
  final String timeAgo;
  final bool isSelfPickup;
  final int? prescriptionId;
  final String? phone;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFE24B3B);
  static const Color _name = Color(0xFF1A1A1A);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _orange = Color(0xFFFF5722);
  static const Color _muted = Color(0xFF6B7280);

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyOrderDetailsScreen(
          customerName: customerName,
          phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
          requestId: orderCode,
          requestMeta: timeAgo,
          notesType: PharmacyOrderNotesType.none,
          isToPrepare: true,
          isSelfPickup: isSelfPickup,
          prescriptionId: prescriptionId,
          orderId: prescriptionId,
          orderRawId: prescriptionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _avatarBg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      customerName.isNotEmpty
                          ? customerName.substring(0, 1).toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: _avatarText,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        customerName,
                        style: const TextStyle(
                          color: _name,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TO PREPARE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage(
                        isSelfPickup
                            ? 'lib/water/Assets/Images/selfpickup_icon.png'
                            : 'lib/pharmacy/Assets/images/delivery_icon.png',
                      ),
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: isSelfPickup ? 'Self Pickup' : 'Delivery',
                            style: const TextStyle(
                              color: _orange,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: timeAgo.isNotEmpty
                                ? '  • $orderCode • $timeAgo'
                                : '  • $orderCode',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (scheduled)
                const Row(
                  children: [
                    _ScheduledPill(),
                    Spacer(),
                    Icon(Icons.calendar_today_outlined, size: 14, color: _blue),
                    SizedBox(width: 4),
                    Text(
                      '15 Aug 2026',
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.access_time_rounded, size: 15, color: _blue),
                    SizedBox(width: 4),
                    Text(
                      '6:00 - 7:00 PM',
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFE4D4)),
                    color: const Color.fromARGB(255, 254, 246, 238),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image: AssetImage(
                          'lib/pharmacy/Assets/images/online_payment.png',
                        ),
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Online Payment',
                        style: TextStyle(
                          color: _orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const _PrescriptionThumb(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prescription_Jun25.jpg',
                            style: TextStyle(
                              color: _name,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Full Prescription',
                                style: TextStyle(
                                  color: _orange,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.open_in_new_rounded,
                                size: 14,
                                color: _orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _openDetails(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Start Preparing',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreparingCard extends StatelessWidget {
  const _PreparingCard({
    this.customerName = 'Ahmed',
    this.orderCode = '#22789007',
    this.timeAgo = '2 min ago',
    this.isSelfPickup = false,
    this.prescriptionId,
    this.phone,
  });

  final String customerName;
  final String orderCode;
  final String timeAgo;
  final bool isSelfPickup;
  final int? prescriptionId;
  final String? phone;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFE24B3B);
  static const Color _name = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFFF5722);
  static const Color _meta = Color(0xFF6B7280);

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyOrderDetailsScreen(
          customerName: customerName,
          phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
          requestId: orderCode,
          requestMeta: timeAgo,
          notesType: PharmacyOrderNotesType.none,
          isPreparing: true,
          isSelfPickup: isSelfPickup,
          prescriptionId: prescriptionId,
          orderId: prescriptionId,
          orderRawId: prescriptionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _avatarBg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      customerName.isNotEmpty
                          ? customerName.substring(0, 1).toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: _avatarText,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customerName,
                                style: const TextStyle(
                                  color: _name,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'PREPARING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(
                              image: AssetImage(
                                isSelfPickup
                                    ? 'lib/water/Assets/Images/selfpickup_icon.png'
                                    : 'lib/pharmacy/Assets/images/delivery_icon.png',
                              ),
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: isSelfPickup
                                          ? 'Self Pickup'
                                          : 'Delivery',
                                      style: const TextStyle(
                                        color: _orange,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        height: 1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: timeAgo.isNotEmpty
                                          ? '  • $orderCode • $timeAgo'
                                          : '  • $orderCode',
                                      style: const TextStyle(
                                        color: _meta,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    _PrescriptionThumb(),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prescription_Jun25.jpg',
                            style: TextStyle(
                              color: _name,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Full Prescription',
                                style: TextStyle(
                                  color: _orange,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 14,
                                color: _orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4EA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image(
                      image: AssetImage(
                        'lib/pharmacy/Assets/images/online_payment.png',
                      ),
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Online Payment',
                      style: TextStyle(
                        color: _orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _openDetails(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Ready for Dispatch',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadyCard extends StatelessWidget {
  const _ReadyCard({
    this.customerName = 'Ahmed',
    this.orderCode = '#22789007',
    this.timeAgo = '2 min ago',
    this.partnerName,
    this.isSelfPickup = false,
    this.prescriptionId,
    this.phone,
  });

  final String customerName;
  final String orderCode;
  final String timeAgo;
  final String? partnerName;
  final bool isSelfPickup;
  final int? prescriptionId;
  final String? phone;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFE24B3B);
  static const Color _name = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFFF5722);
  static const Color _meta = Color(0xFF6B7280);
  static const Color _ready = Color(0xFF22C55E);
  static const Color _partner = Color(0xFF7C3AED);
  static const Color _partnerBg = Color(0xFFF3E8FF);

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyOrderDetailsScreen(
          customerName: customerName,
          phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
          requestId: orderCode,
          requestMeta: timeAgo,
          notesType: PharmacyOrderNotesType.none,
          isReady: true,
          isSelfPickup: isSelfPickup,
          isOtcPartnerAssigned: partnerName != null,
          prescriptionId: prescriptionId,
          orderId: prescriptionId,
          orderRawId: prescriptionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetails(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _avatarBg,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    customerName.isNotEmpty
                        ? customerName.substring(0, 1).toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: _avatarText,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customerName,
                              style: const TextStyle(
                                color: _name,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _ready,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'READY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(
                              image: AssetImage(
                                isSelfPickup
                                    ? 'lib/water/Assets/Images/selfpickup_icon.png'
                                    : 'lib/pharmacy/Assets/images/delivery_icon.png',
                              ),
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: isSelfPickup
                                        ? 'Self Pickup'
                                        : 'Delivery',
                                    style: const TextStyle(
                                      color: _orange,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: timeAgo.isNotEmpty
                                        ? '  • $orderCode • $timeAgo'
                                        : '  • $orderCode',
                                    style: const TextStyle(
                                      color: _meta,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F6F4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  _PrescriptionThumb(),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prescription_Jun25.jpg',
                          style: TextStyle(
                            color: _name,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Full Prescription',
                              style: TextStyle(
                                color: _orange,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 14,
                              color: _orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: _partnerBg,
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Image(
                              image: AssetImage(
                                'lib/pharmacy/Assets/images/scooter.png',
                              ),
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Assigned Delivery Partner',
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 96, 96, 96),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '(${partnerName ?? 'Abdallah Ould Ahmed'})',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: _partner,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF4EA),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 8, 12, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image(
                          image: AssetImage(
                            'lib/pharmacy/Assets/images/online_payment.png',
                          ),
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Online Payment',
                          style: TextStyle(
                            color: _orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveredCard extends StatelessWidget {
  const _DeliveredCard({
    this.customerName = '',
    this.orderCode = '',
    this.timeAgo = '',
    this.isSelfPickup = false,
    this.prescriptionId,
    this.phone,
  });

  final String customerName;
  final String orderCode;
  final String timeAgo;
  final bool isSelfPickup;
  final int? prescriptionId;
  final String? phone;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFE24B3B);
  static const Color _name = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFFF5722);
  static const Color _meta = Color(0xFF6B7280);
  static const Color _delivered = Color(0xFF22C55E);

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyOrderDetailsScreen(
          customerName: customerName,
          phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
          requestId: orderCode,
          requestMeta: timeAgo,
          notesType: PharmacyOrderNotesType.none,
          isDelivered: true,
          isSelfPickup: isSelfPickup,
          prescriptionId: prescriptionId,
          orderId: prescriptionId,
          orderRawId: prescriptionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetails(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _avatarBg,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    customerName.isNotEmpty
                        ? customerName.substring(0, 1).toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: _avatarText,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customerName,
                              style: const TextStyle(
                                color: _name,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _delivered,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'DELIVERED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(
                              image: AssetImage(
                                isSelfPickup
                                    ? 'lib/water/Assets/Images/selfpickup_icon.png'
                                    : 'lib/pharmacy/Assets/images/delivery_icon.png',
                              ),
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: isSelfPickup
                                        ? 'Self Pickup'
                                        : 'Delivery',
                                    style: const TextStyle(
                                      color: _orange,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: timeAgo.isNotEmpty
                                        ? '  • $orderCode • $timeAgo'
                                        : '  • $orderCode',
                                    style: const TextStyle(
                                      color: _meta,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F6F4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  _PrescriptionThumb(),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prescription_Jun25.jpg',
                          style: TextStyle(
                            color: _name,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Full Prescription',
                              style: TextStyle(
                                color: _orange,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 14,
                              color: _orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4EA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: AssetImage(
                      'lib/pharmacy/Assets/images/online_payment.png',
                    ),
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Online Payment',
                    style: TextStyle(
                      color: _orange,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduledPill extends StatelessWidget {
  const _ScheduledPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 13,
            color: Color(0xFF3B82F6),
          ),
          SizedBox(width: 4),
          Text(
            'SCHEDULED',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AwaitingPaymentCard extends StatelessWidget {
  const _AwaitingPaymentCard({
    this.customerName = '',
    this.orderCode = '',
    this.timeAgo = '',
    this.quotationAmount,
    this.prescriptionId,
    this.phone,
  });

  final String customerName;
  final String orderCode;
  final String timeAgo;
  final String? quotationAmount;
  final int? prescriptionId;
  final String? phone;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFE24B3B);
  static const Color _nameColor = Color(0xFF1A1A1A);
  static const Color _metaColor = Color(0xFF6B7280);
  static const Color _badge = Color(0xFFF5C400);
  static const Color _orange = Color(0xFFFF5722);
  static const Color _label = Color(0xFFA3A3A3);

  @override
  Widget build(BuildContext context) {
    void openPrescription() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PharmacyOrderDetailsScreen(
            customerName: customerName,
            phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
            requestId: orderCode,
            requestMeta: timeAgo,
            notesType: PharmacyOrderNotesType.none,
            isAwaitingPayment: true,
            prescriptionId: prescriptionId,
            orderId: prescriptionId,
            orderRawId: prescriptionId,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openPrescription,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _avatarBg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      customerName.isNotEmpty
                          ? customerName.substring(0, 1).toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: _avatarText,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customerName,
                                style: const TextStyle(
                                  color: _nameColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _badge,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'AWAITING PAYMENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            timeAgo.isNotEmpty
                                ? '$orderCode • $timeAgo'
                                : orderCode,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              color: _metaColor,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const _PrescriptionThumb(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prescription_Jun25.jpg',
                            style: TextStyle(
                              color: _nameColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: openPrescription,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Full Prescription',
                                  style: TextStyle(
                                    color: _orange,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 14,
                                  color: _orange,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QUOTATION',
                          style: TextStyle(
                            color: _label,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${quotationAmount ?? '0'} MRU',
                          style: const TextStyle(
                            color: _nameColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'STATUS',
                        style: TextStyle(
                          color: _label,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: _badge,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(width: 8, height: 8),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Awaiting Payment',
                            style: TextStyle(
                              color: Color(0xFF3A3A3A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '22 Oct 2025  ·  10:42 AM',
                    style: TextStyle(
                      color: Color(0xFF3A3A3A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  Spacer(),
                  Image(
                    image: AssetImage(
                      'lib/pharmacy/Assets/images/hourglass.png',
                    ),
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Expires in 18 min',
                    style: TextStyle(
                      color: _orange,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtcNewOrderCard extends StatelessWidget {
  const _OtcNewOrderCard({
    this.customerName = '',
    this.orderId = '',
    this.timeAgo = '',
    this.selfPickup = false,
    this.cashOnDelivery = false,
    this.scheduled = false,
    this.accepted = false,
    this.preparing = false,
    this.ready = false,
    this.delivered = false,
    this.cancelled = false,
    this.partnerName,
    this.itemsSummary,
    this.phone,
    this.orderRawId,
    this.onAccept,
    this.isAccepting = false,
    this.onReject,
    this.isRejecting = false,
    this.onPrepare,
    this.isPreparingAction = false,
    this.onMarkAsReady,
    this.isMarkingReadyAction = false,
  });

  final String customerName;
  final String orderId;
  final String timeAgo;
  final bool selfPickup;
  final bool cashOnDelivery;
  final bool scheduled;
  final bool accepted;
  final bool preparing;
  final bool ready;
  final bool delivered;
  final bool cancelled;
  final String? partnerName;
  final String? itemsSummary;
  final String? phone;
  final int? orderRawId;
  final VoidCallback? onAccept;
  final bool isAccepting;
  final VoidCallback? onReject;
  final bool isRejecting;
  final VoidCallback? onPrepare;
  final bool isPreparingAction;
  final VoidCallback? onMarkAsReady;
  final bool isMarkingReadyAction;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFC62828);
  static const Color _name = Color(0xFF111827);
  static const Color _meta = Color(0xFF6B7280);
  static const Color _orange = Color(0xFFFF5722);
  static const Color _newBadge = Color(0xFFF99D1C);
  static const Color _acceptedBadge = Color(0xFF22C55E);
  static const Color _rejectBorder = Color(0xFFE0E0E0);
  static const Color _blue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final initial = customerName.isNotEmpty
        ? customerName.substring(0, 1).toUpperCase()
        : 'C';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PharmacyOrderDetailsScreen(
              customerName: customerName.isNotEmpty ? customerName : 'Customer',
              phone: phone ?? '',
              requestId: orderId,
              isOtc: true,
              isSelfPickup: selfPickup,
              cashOnDelivery: cashOnDelivery,
              isOtcAccepted: accepted,
              isOtcPreparing: preparing,
              isOtcReady: ready,
              isOtcPartnerAssigned: partnerName != null,
              isOtcDelivered: delivered,
              isOtcCancelled: cancelled,
              orderId: orderRawId,
              orderRawId: orderRawId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _avatarBg,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: _avatarText,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customerName,
                              style: const TextStyle(
                                color: _name,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  accepted ||
                                      preparing ||
                                      ready ||
                                      delivered ||
                                      cancelled
                                  ? 8
                                  : 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: cancelled
                                  ? const Color(0xFFEF4444)
                                  : (ready || delivered
                                        ? const Color(0xFF22C55E)
                                        : preparing
                                        ? _orange
                                        : accepted
                                        ? _acceptedBadge
                                        : _newBadge),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cancelled
                                  ? 'CANCELLED'
                                  : (delivered
                                        ? 'DELIVERED'
                                        : ready
                                        ? 'READY'
                                        : preparing
                                        ? 'PREPARING'
                                        : accepted
                                        ? 'ACCEPTED'
                                        : 'NEW'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    accepted ||
                                        preparing ||
                                        ready ||
                                        delivered ||
                                        cancelled
                                    ? 10
                                    : 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (selfPickup) ...[
                            const Text(
                              '(',
                              style: TextStyle(
                                color: _blue,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Image.asset(
                              'lib/water/Assets/Images/selfpickup_icon.png',
                              width: 15,
                              height: 15,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Self Pickup',
                              style: TextStyle(
                                color: _blue,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              ')',
                              style: TextStyle(
                                color: _blue,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1,
                              ),
                            ),
                          ] else ...[
                            Image.asset(
                              'lib/pharmacy/Assets/images/delivery_icon.png',
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Delivery',
                              style: TextStyle(
                                color: _orange,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                          ],
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              selfPickup || ready || delivered || cancelled
                                  ? '•  $orderId  •  $timeAgo'
                                  : '$orderId  •  $timeAgo',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _meta,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (scheduled)
              const Row(
                children: [
                  _ScheduledPill(),
                  SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: _blue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '15 Aug 2026',
                            style: TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: _blue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '6:00 - 7:00 PM',
                            style: TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else if (ready)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (partnerName != null) ...[
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3EEFF),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'lib/pharmacy/Assets/images/scooter.png',
                              width: 22,
                              height: 22,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Assigned Delivery Partner',
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Color(0xFF5F6274),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '($partnerName)',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Color(0xFF6829FF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (itemsSummary != null &&
                        itemsSummary!.trim().isNotEmpty) ...[
                      _OtcInfoPill(
                        icon: const Icon(
                          Icons.inventory_2_outlined,
                          size: 15,
                          color: _orange,
                        ),
                        label: itemsSummary!,
                      ),
                      const SizedBox(width: 8),
                    ],
                    _OtcInfoPill(
                      icon: Image.asset(
                        cashOnDelivery
                            ? 'lib/pharmacy/Assets/images/cashondelivery.png'
                            : 'lib/pharmacy/Assets/images/online_payment.png',
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                      ),
                      label: cashOnDelivery
                          ? 'Cash on Delivery'
                          : 'Online Payment',
                    ),
                  ],
                ),
              )
            else
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (itemsSummary != null &&
                        itemsSummary!.trim().isNotEmpty) ...[
                      _OtcInfoPill(
                        icon: const Icon(
                          Icons.inventory_2_outlined,
                          size: 15,
                          color: _orange,
                        ),
                        label: itemsSummary!,
                      ),
                      const SizedBox(width: 8),
                    ],
                    _OtcInfoPill(
                      icon: Image.asset(
                        cashOnDelivery
                            ? 'lib/pharmacy/Assets/images/cashondelivery.png'
                            : 'lib/pharmacy/Assets/images/online_payment.png',
                        width: cashOnDelivery ? 18 : 16,
                        height: cashOnDelivery ? 18 : 16,
                        fit: BoxFit.contain,
                      ),
                      label: cashOnDelivery
                          ? 'Cash on Delivery'
                          : 'Online Payment',
                    ),
                  ],
                ),
              ),
            if (!ready && !delivered && !cancelled) ...[
              const SizedBox(height: 16),
              if (accepted || preparing)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _orange,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _orange.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: preparing
                          ? (isMarkingReadyAction
                              ? null
                              : () {
                                  if (onMarkAsReady != null) {
                                    onMarkAsReady!();
                                  }
                                })
                          : (isPreparingAction
                              ? null
                              : () {
                                  if (onPrepare != null) {
                                    onPrepare!();
                                  }
                                }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: (preparing ? isMarkingReadyAction : isPreparingAction)
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              preparing ? 'Mark as Ready' : 'Prepare Order',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: (isRejecting || isAccepting)
                              ? null
                              : () {
                                  if (onReject != null) {
                                    onReject!();
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _name,
                            side: const BorderSide(color: _rejectBorder),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isRejecting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _name,
                                  ),
                                )
                              : const Text(
                                  'Reject',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 46,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _orange,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _orange.withValues(alpha: 0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isAccepting
                                ? null
                                : () {
                                    if (onAccept != null) {
                                      onAccept!();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isAccepting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Accept Order',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OtcInfoPill extends StatelessWidget {
  const _OtcInfoPill({required this.icon, required this.label});

  final Widget icon;
  final String label;

  static const Color _orange = Color(0xFFFF5722);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE4D4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _orange,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtcOrderCard extends StatelessWidget {
  const _OtcOrderCard({
    required this.customerName,
    required this.orderId,
    required this.timeAgo,
    required this.items,
  });

  final String customerName;
  final String orderId;
  final String timeAgo;
  final String items;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFC62828);
  static const Color _nameColor = Color(0xFF111827);
  static const Color _metaColor = Color(0xFF6B7280);
  static const Color _newBadge = Color(0xFFF99D1C);
  static const Color _linkOrange = Color(0xFFFF6B2B);
  static const Color _rejectBorder = Color(0xFFE0E0E0);
  static const Color _itemBg = Color(0xFFFAF9F7);
  static const Color _itemBorder = Color(0xFFEAEAEA);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  customerName.isNotEmpty
                      ? customerName.substring(0, 1).toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: _avatarText,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        color: _nameColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$orderId  •  $timeAgo',
                      style: const TextStyle(
                        color: _metaColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _newBadge,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _itemBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _itemBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medication_outlined,
                    color: Color(0xFF00695C),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    items,
                    style: const TextStyle(
                      color: _nameColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => showPharmacyRejectOrderSheet(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _nameColor,
                      side: const BorderSide(color: _rejectBorder, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      'Reject',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _linkOrange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _linkOrange.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Accept Order',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Orders', 'Chat', 'Inventory', 'Account'];
    const assetIcons = <String?>[
      null,
      AppAssets.ordersIcon,
      AppAssets.chatIcon,
      AppAssets.inventoryIcon,
      AppAssets.accountIcon,
    ];
    const fallbacks = <IconData>[
      Icons.home_rounded,
      Icons.receipt_long_rounded,
      Icons.chat_bubble_outline_rounded,
      Icons.shopping_cart_outlined,
      Icons.person_outline_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(5, (index) {
              final selected = selectedIndex == index;
              final asset = assetIcons[index];
              return Expanded(
                child: InkWell(
                  onTap: () => onSelect(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: selected
                            ? Container(
                                key: const ValueKey('selected'),
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: _NavIcon(
                                  asset: asset,
                                  fallback: fallbacks[index],
                                  color: Colors.white,
                                  size: 24,
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey('idle'),
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: _NavIcon(
                                    asset: asset,
                                    fallback: fallbacks[index],
                                    color: AppColors.navInactive,
                                    size: asset == null ? 28 : 24,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primaryOrange
                              : AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.asset,
    required this.fallback,
    required this.color,
    required this.size,
  });

  final String? asset;
  final IconData fallback;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (asset == null) {
      return Icon(fallback, color: color, size: size);
    }
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(
        asset!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(fallback, color: color, size: size),
      ),
    );
  }
}
