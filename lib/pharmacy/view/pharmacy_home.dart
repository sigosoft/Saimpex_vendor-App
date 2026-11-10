import 'package:saimpex_vendor/utils/payment_type.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/model/home_model.dart';
import 'package:saimpex_vendor/pharmacy/controller/pharmacy_home_controller.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_pending_orders_model.dart';
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
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_membership_card.dart';

/// Membership name in the app language from GET home `membership`, or null
/// when the vendor has no membership (the card is then hidden).
String? _membershipName(BuildContext context, Membership? m) {
  if (m == null) return null;
  final lang = Localizations.localeOf(context).languageCode;
  final en = m.nameEn?.trim() ?? '';
  final fr = m.nameFr?.trim() ?? '';
  final ar = m.nameAr?.trim() ?? '';
  final name = switch (lang) {
    'ar' => ar.isNotEmpty ? ar : (en.isNotEmpty ? en : fr),
    'fr' => fr.isNotEmpty ? fr : (en.isNotEmpty ? en : ar),
    _ => en.isNotEmpty ? en : (fr.isNotEmpty ? fr : ar),
  };
  return name.isEmpty ? null : name;
}

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
      builder: (_) => Directionality(
        textDirection: LocalizationService().getTextDirection(),
        child: Theme(
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
                    unreadChatCount: controller.unreadChatCount,
                  ),
                ],
              ),
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
          } else if (!controller.isOtcTab &&
              controller.selectedFilterIndex == 1) {
            await controller.fetchPharmacyPrescriptions(status: 'under_review');
          } else if (!controller.isOtcTab &&
              controller.selectedFilterIndex == 2) {
            await controller.fetchPharmacyPrescriptions(status: 'reviewed');
          } else if (!controller.isOtcTab &&
              controller.selectedFilterIndex == 3) {
            await controller.fetchPharmacyPrescriptions(status: 'quoted');
          } else if (!controller.isOtcTab &&
              controller.selectedFilterIndex == 4) {
            await controller.fetchPharmacyOrders(
              tab: 'prescription',
              status: 2,
            );
          } else if (!controller.isOtcTab &&
              controller.selectedFilterIndex == 5) {
            await controller.fetchPharmacyOrders(
              tab: 'prescription',
              status: 3,
            );
          } else if (!controller.isOtcTab &&
              controller.selectedFilterIndex == 6) {
            await controller.fetchPharmacyOrders(
              tab: 'prescription',
              status: 4,
            );
          } else if (!controller.isOtcTab &&
              controller.selectedFilterIndex == 7) {
            await controller.fetchPharmacyOrders(
              tab: 'prescription',
              status: 9,
            );
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
                  // Figma (pharmacy check, 6 Nov): membership with its
                  // expiry chip, from GET home `membership` (hidden when
                  // the vendor has none).
                  if (_membershipName(
                        context,
                        controller.homeData?.data?.membership,
                      ) !=
                      null) ...[
                    VendorMembershipCard(
                      horizontalPadding: 0,
                      width: double.infinity,
                      height: 56,
                      membershipName: _membershipName(
                        context,
                        controller.homeData?.data?.membership,
                      )!,
                      // No chip until the membership arrives.
                      expiryText:
                          controller.homeData?.data?.membership?.expiresInDays ==
                                  null
                              ? ''
                              : S.of(context).expiresInDays(
                                  '${controller.homeData!.data!.membership!.expiresInDays}',
                                ),
                      isWarning:
                          (controller
                                  .homeData
                                  ?.data
                                  ?.membership
                                  ?.expiresInDays ??
                              0) <=
                          10,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _StoreStatusCard(
                    isOpen: controller.isStoreOpen,
                    onToggle: controller.toggleStore,
                    timings: controller.storeTimings,
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
                      } else if (!controller.isOtcTab &&
                          controller.selectedFilterIndex == 1) {
                        controller.fetchPharmacyPrescriptions(
                          status: 'under_review',
                          keyword: val,
                        );
                      } else if (!controller.isOtcTab &&
                          controller.selectedFilterIndex == 2) {
                        controller.fetchPharmacyPrescriptions(
                          status: 'reviewed',
                          keyword: val,
                        );
                      } else if (!controller.isOtcTab &&
                          controller.selectedFilterIndex == 3) {
                        controller.fetchPharmacyPrescriptions(
                          status: 'quoted',
                          keyword: val,
                        );
                      } else if (!controller.isOtcTab &&
                          controller.selectedFilterIndex == 4) {
                        controller.fetchPharmacyOrders(
                          tab: 'prescription',
                          status: 2,
                          keyword: val,
                        );
                      } else if (!controller.isOtcTab &&
                          controller.selectedFilterIndex == 5) {
                        controller.fetchPharmacyOrders(
                          tab: 'prescription',
                          status: 3,
                          keyword: val,
                        );
                      } else if (!controller.isOtcTab &&
                          controller.selectedFilterIndex == 6) {
                        controller.fetchPharmacyOrders(
                          tab: 'prescription',
                          status: 4,
                          keyword: val,
                        );
                      } else if (!controller.isOtcTab &&
                          controller.selectedFilterIndex == 7) {
                        controller.fetchPharmacyOrders(
                          tab: 'prescription',
                          status: 9,
                          keyword: val,
                        );
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
                  Text(
                    LocalizationService.tr('Orders'),
                    style: const TextStyle(
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
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 1) {
                  controller.fetchPharmacyPrescriptions(
                    status: 'under_review',
                    keyword: val,
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 2) {
                  controller.fetchPharmacyPrescriptions(
                    status: 'reviewed',
                    keyword: val,
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 3) {
                  controller.fetchPharmacyPrescriptions(
                    status: 'quoted',
                    keyword: val,
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 4) {
                  controller.fetchPharmacyOrders(
                    tab: 'prescription',
                    status: 2,
                    keyword: val,
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 5) {
                  controller.fetchPharmacyOrders(
                    tab: 'prescription',
                    status: 3,
                    keyword: val,
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 6) {
                  controller.fetchPharmacyOrders(
                    tab: 'prescription',
                    status: 4,
                    keyword: val,
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 7) {
                  controller.fetchPharmacyOrders(
                    tab: 'prescription',
                    status: 9,
                    keyword: val,
                  );
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
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 1) {
                  await controller.fetchPharmacyPrescriptions(
                    status: 'under_review',
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 2) {
                  await controller.fetchPharmacyPrescriptions(
                    status: 'reviewed',
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 3) {
                  await controller.fetchPharmacyPrescriptions(status: 'quoted');
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 4) {
                  await controller.fetchPharmacyOrders(
                    tab: 'prescription',
                    status: 2,
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 5) {
                  await controller.fetchPharmacyOrders(
                    tab: 'prescription',
                    status: 3,
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 6) {
                  await controller.fetchPharmacyOrders(
                    tab: 'prescription',
                    status: 4,
                  );
                } else if (!controller.isOtcTab &&
                    controller.selectedFilterIndex == 7) {
                  await controller.fetchPharmacyOrders(
                    tab: 'prescription',
                    status: 9,
                  );
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
        final rawPrescriptionId = item.prescriptionId ?? item.id;
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
            prescriptionId: rawPrescriptionId,
            isReviewingAction:
                controller.isReviewingPrescription &&
                controller.reviewingPrescriptionId == rawPrescriptionId,
            onReviewPrescription: rawPrescriptionId != null
                ? () => controller.reviewPharmacyPrescription(
                    rawPrescriptionId,
                    context: context,
                  )
                : null,
            isRejectingAction:
                controller.isRejectingPrescription &&
                controller.rejectingPrescriptionId == rawPrescriptionId,
            onReject: rawPrescriptionId != null
                ? () => _rejectWithReason(
                    context,
                    (reason) => controller.rejectPharmacyPrescription(
                      rawPrescriptionId,
                      context: context,
                      note: reason,
                    ),
                  )
                : null,
          ),
        );
      }
      return widgets;
    }

    final isPrescriptionUnderReview =
        !controller.isOtcTab && controller.selectedFilterIndex == 1;

    if (isPrescriptionUnderReview) {
      if (controller.isLoadingUnderReviewPrescriptions) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.underReviewPrescriptionsList.isEmpty) {
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
      for (int i = 0; i < controller.underReviewPrescriptionsList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final item = controller.underReviewPrescriptionsList[i];
        final rawPrescriptionId = item.prescriptionId ?? item.id;
        widgets.add(
          _PrescriptionOrderCard(
            customerName: item.displayCustomerName,
            orderCode: item.displayOrderCode,
            timeAgo: item.displayTimeAgo,
            isSelfPickup: item.isSelfPickupBool,
            status: PharmacyPrescriptionCardStatus.underReview,
            notesType: item.notesType,
            prescriptionFileName: item.displayFileName,
            prescriptionImageUrl: item.displayImageUrl,
            specialNotes: item.note,
            phone: item.displayPhone,
            prescriptionId: rawPrescriptionId,
            isMarkingReviewedAction:
                controller.isMarkingPrescriptionReviewed &&
                controller.markingPrescriptionReviewedId == rawPrescriptionId,
            onMarkAsReviewed: rawPrescriptionId != null
                ? () => controller.markPharmacyPrescriptionReviewed(
                    rawPrescriptionId,
                    context: context,
                  )
                : null,
            isRejectingAction:
                controller.isRejectingPrescription &&
                controller.rejectingPrescriptionId == rawPrescriptionId,
            onReject: rawPrescriptionId != null
                ? () => _rejectWithReason(
                    context,
                    (reason) => controller.rejectPharmacyPrescription(
                      rawPrescriptionId,
                      context: context,
                      note: reason,
                    ),
                  )
                : null,
          ),
        );
      }
      return widgets;
    }

    final isPrescriptionReviewed =
        !controller.isOtcTab && controller.selectedFilterIndex == 2;

    if (isPrescriptionReviewed) {
      if (controller.isLoadingReviewedPrescriptions) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.reviewedPrescriptionsList.isEmpty) {
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
      for (int i = 0; i < controller.reviewedPrescriptionsList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final item = controller.reviewedPrescriptionsList[i];
        final rawPrescriptionId = item.prescriptionId ?? item.id;
        widgets.add(
          _PrescriptionOrderCard(
            customerName: item.displayCustomerName,
            orderCode: item.displayOrderCode,
            timeAgo: item.displayTimeAgo,
            isSelfPickup: item.isSelfPickupBool,
            status: PharmacyPrescriptionCardStatus.reviewCompleted,
            notesType: item.notesType,
            prescriptionFileName: item.displayFileName,
            prescriptionImageUrl: item.displayImageUrl,
            specialNotes: item.note,
            phone: item.displayPhone,
            prescriptionId: rawPrescriptionId,
            isRejectingAction:
                controller.isRejectingPrescription &&
                controller.rejectingPrescriptionId == rawPrescriptionId,
            onReject: rawPrescriptionId != null
                ? () => _rejectWithReason(
                    context,
                    (reason) => controller.rejectPharmacyPrescription(
                      rawPrescriptionId,
                      context: context,
                      note: reason,
                    ),
                  )
                : null,
          ),
        );
      }
      return widgets;
    }

    final isPrescriptionQuoted =
        !controller.isOtcTab && controller.selectedFilterIndex == 3;

    if (isPrescriptionQuoted) {
      if (controller.isLoadingQuotedPrescriptions) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.quotedPrescriptionsList.isEmpty) {
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
      for (int i = 0; i < controller.quotedPrescriptionsList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final item = controller.quotedPrescriptionsList[i];
        final rawPrescriptionId = item.prescriptionId ?? item.id;
        widgets.add(
          _AwaitingPaymentCard(
            customerName: item.displayCustomerName,
            orderCode: item.displayOrderCode,
            timeAgo: item.displayTimeAgo,
            quotationAmount: item.displayQuotationAmount,
            prescriptionId: rawPrescriptionId,
            phone: item.displayPhone,
            prescriptionFileName: item.displayFileName,
            prescriptionImageUrl: item.displayImageUrl,
            quotedDateFormatted: item.displayQuotedDate,
            expiresText: item.displayExpiresText,
          ),
        );
      }
      return widgets;
    }

    final isPrescriptionToPrepare =
        !controller.isOtcTab && controller.selectedFilterIndex == 4;

    if (isPrescriptionToPrepare) {
      if (controller.isLoadingPrescriptionToPrepareOrders) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.prescriptionToPrepareOrdersList.isEmpty) {
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
      for (
        int i = 0;
        i < controller.prescriptionToPrepareOrdersList.length;
        i++
      ) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        widgets.add(_prescriptionOrderCard(
          context,
          controller,
          controller.prescriptionToPrepareOrdersList[i],
        ));
      }
      return widgets;
    }

    final isPrescriptionPreparing =
        !controller.isOtcTab && controller.selectedFilterIndex == 5;

    if (isPrescriptionPreparing) {
      if (controller.isLoadingPrescriptionPreparingOrders) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.prescriptionPreparingOrdersList.isEmpty) {
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
      for (
        int i = 0;
        i < controller.prescriptionPreparingOrdersList.length;
        i++
      ) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        widgets.add(_prescriptionOrderCard(
          context,
          controller,
          controller.prescriptionPreparingOrdersList[i],
        ));
      }
      return widgets;
    }

    final isPrescriptionReady =
        !controller.isOtcTab && controller.selectedFilterIndex == 6;

    if (isPrescriptionReady) {
      if (controller.isLoadingPrescriptionReadyOrders) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.prescriptionReadyOrdersList.isEmpty) {
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
      for (int i = 0; i < controller.prescriptionReadyOrdersList.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final item = controller.prescriptionReadyOrdersList[i];
        final rawId = item.resolvedId;
        widgets.add(
          _ReadyCard(
            customerName: item.displayCustomerName,
            orderCode: item.displayOrderCode,
            timeAgo: item.displayTimeAgo,
            isSelfPickup: item.isSelfPickupBool,
            partnerName: item.deliveryBoyName,
            orderId: rawId,
            prescriptionId: item.prescriptionId,
            phone: item.phone,
            prescriptionFileName: item.prescriptionFileName,
            prescriptionImageUrl: item.prescriptionImageUrl,
            isCashOnDelivery: item.isCashOnDeliveryBool,
            paymentType: item.paymentType,
          ),
        );
      }
      return widgets;
    }

    final isPrescriptionDelivered =
        !controller.isOtcTab && controller.selectedFilterIndex == 7;

    if (isPrescriptionDelivered) {
      if (controller.isLoadingPrescriptionDeliveredOrders) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
          ),
        ];
      }

      if (controller.prescriptionDeliveredOrdersList.isEmpty) {
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
      for (
        int i = 0;
        i < controller.prescriptionDeliveredOrdersList.length;
        i++
      ) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        final item = controller.prescriptionDeliveredOrdersList[i];
        final rawId = item.resolvedId;
        widgets.add(
          _DeliveredCard(
            customerName: item.displayCustomerName,
            orderCode: item.displayOrderCode,
            timeAgo: item.displayTimeAgo,
            isSelfPickup: item.isSelfPickupBool,
            orderId: rawId,
            prescriptionId: item.prescriptionId,
            phone: item.phone,
            prescriptionFileName: item.prescriptionFileName,
            prescriptionImageUrl: item.prescriptionImageUrl,
            isCashOnDelivery: item.isCashOnDeliveryBool,
            paymentType: item.paymentType,
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
            express: order.isExpressBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            paymentType: order.paymentType,
            accepted: false,
            preparing: false,
            ready: false,
            delivered: false,
            partnerName: order.deliveryBoyName,
            itemsSummary: _otcItemsSummary(context, order.displayItemsCount, order.displayTotal),
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
                ? () => _rejectWithReason(
                    context,
                    (reason) => controller.cancelPharmacyOrder(
                      rawId,
                      context: context,
                      reason: reason,
                    ),
                  )
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
            express: order.isExpressBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            paymentType: order.paymentType,
            accepted: true,
            preparing: false,
            ready: false,
            delivered: false,
            partnerName: order.deliveryBoyName,
            itemsSummary: _otcItemsSummary(context, order.displayItemsCount, order.displayTotal),
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
            express: order.isExpressBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            paymentType: order.paymentType,
            accepted: false,
            preparing: true,
            ready: false,
            delivered: false,
            partnerName: order.deliveryBoyName,
            itemsSummary: _otcItemsSummary(context, order.displayItemsCount, order.displayTotal),
            phone: order.phone,
            orderRawId: rawId,
            isMarkingReadyAction:
                controller.isMarkingReadyOrder &&
                controller.markingReadyOrderId == rawId,
            onMarkAsReady: rawId != null
                ? () => controller.markAsReadyPharmacyOrder(
                    rawId,
                    context: context,
                  )
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
            express: order.isExpressBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            paymentType: order.paymentType,
            accepted: false,
            preparing: false,
            ready: true,
            delivered: false,
            partnerName: order.deliveryBoyName,
            itemsSummary: _otcItemsSummary(context, order.displayItemsCount, order.displayTotal),
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
            express: order.isExpressBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            paymentType: order.paymentType,
            accepted: false,
            preparing: false,
            ready: false,
            delivered: true,
            partnerName: order.deliveryBoyName,
            itemsSummary: _otcItemsSummary(context, order.displayItemsCount, order.displayTotal),
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
            express: order.isExpressBool,
            cashOnDelivery: order.isCashOnDeliveryBool,
            paymentType: order.paymentType,
            accepted: false,
            preparing: false,
            ready: false,
            delivered: false,
            cancelled: true,
            partnerName: order.deliveryBoyName,
            itemsSummary: _otcItemsSummary(context, order.displayItemsCount, order.displayTotal),
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
          : S.of(context).quoteCustomer;
      // Phone time from the raw placed_at; placed_at_formatted is UTC text.
      final fromRaw = formatServerPlacedAt(order.placedAt);
      final timeAgo = fromRaw.isNotEmpty
          ? fromRaw
          : (order.placedAtFormatted ?? order.placedAt ?? '');
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

        final itemCount = (order.orderItemsCount ?? 0) > 0
            ? order.orderItemsCount!
            : (order.totalItems ?? 0);
        final totalStr = order.total?.toString().trim() ?? '';
        final dynamicItemsSummary = _otcItemsSummary(
          context,
          itemCount,
          totalStr.isEmpty || totalStr.contains('MRU') ? totalStr : '$totalStr MRU',
        );

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
                ? () => _rejectWithReason(
                    context,
                    (reason) => controller.cancelPharmacyOrder(
                      rawId,
                      context: context,
                      reason: reason,
                    ),
                  )
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
                ? () => controller.markAsReadyPharmacyOrder(
                    rawId,
                    context: context,
                  )
                : null,
          ),
        );
      } else {
        if (filter == 1) {
          final rawPrescriptionId = order.id;
          widgets.add(
            _PrescriptionOrderCard(
              customerName: customerName,
              orderCode: orderCode,
              timeAgo: timeAgo,
              isSelfPickup: isSelfPickup,
              status: PharmacyPrescriptionCardStatus.underReview,
              notesType: PharmacyOrderNotesType.none,
              prescriptionFileName: order.prescriptionFileName,
              prescriptionImageUrl: order.prescriptionImageUrl,
              prescriptionId: rawPrescriptionId,
              phone: order.userMobile,
              isMarkingReviewedAction:
                  controller.isMarkingPrescriptionReviewed &&
                  controller.markingPrescriptionReviewedId == rawPrescriptionId,
              onMarkAsReviewed: rawPrescriptionId != null
                  ? () => controller.markPharmacyPrescriptionReviewed(
                      rawPrescriptionId,
                      context: context,
                    )
                  : null,
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
              prescriptionFileName: order.prescriptionFileName,
              prescriptionImageUrl: order.prescriptionImageUrl,
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
              prescriptionFileName: order.prescriptionFileName,
              prescriptionImageUrl: order.prescriptionImageUrl,
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
              prescriptionFileName: order.prescriptionFileName,
              prescriptionImageUrl: order.prescriptionImageUrl,
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
              prescriptionFileName: order.prescriptionFileName,
              prescriptionImageUrl: order.prescriptionImageUrl,
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
              prescriptionFileName: order.prescriptionFileName,
              prescriptionImageUrl: order.prescriptionImageUrl,
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
              prescriptionFileName: order.prescriptionFileName,
              prescriptionImageUrl: order.prescriptionImageUrl,
              prescriptionId: order.id,
              phone: order.userMobile,
            ),
          );
        } else {
          final rawPrescriptionId = order.id;
          widgets.add(
            _PrescriptionOrderCard(
              customerName: customerName,
              orderCode: orderCode,
              timeAgo: timeAgo,
              isSelfPickup: isSelfPickup,
              status: PharmacyPrescriptionCardStatus.newOrder,
              notesType: PharmacyOrderNotesType.none,
              prescriptionFileName: order.prescriptionFileName,
              prescriptionImageUrl: order.prescriptionImageUrl,
              prescriptionId: rawPrescriptionId,
              phone: order.userMobile,
              isReviewingAction:
                  controller.isReviewingPrescription &&
                  controller.reviewingPrescriptionId == rawPrescriptionId,
              onReviewPrescription: rawPrescriptionId != null
                  ? () => controller.reviewPharmacyPrescription(
                      rawPrescriptionId,
                      context: context,
                    )
                  : null,
              isRejectingAction:
                  controller.isCancellingOrder &&
                  controller.cancellingOrderId == rawPrescriptionId,
              onReject: rawPrescriptionId != null
                  ? () => _rejectWithReason(
                      context,
                      (reason) => controller.cancelPharmacyOrder(
                        rawPrescriptionId,
                        isPrescription: true,
                        context: context,
                        reason: reason,
                      ),
                    )
                  : null,
            ),
          );
        }
      }
    }

    return widgets;
  }
}

/// Opens the Reject sheet, then sends the picked reason. Closing the sheet
/// without a choice sends nothing. (The home cards used to reject at once
/// with no reason.)
Future<void> _rejectWithReason(
  BuildContext context,
  Future<bool> Function(String reason) send,
) async {
  final reason = await showPharmacyRejectOrderSheet(context);
  if (reason == null || reason.trim().isEmpty) return;
  await send(reason);
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PharmacyHomeController>(
      builder: (controller) {
        final shopName = controller.shopName;
        final welcomeText = shopName.isNotEmpty
            ? '${S.of(context).welcomeTo} $shopName'
            : S.of(context).welcomeToSaimpexVendor;

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
            Expanded(
              child: Text(
                welcomeText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
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
      },
    );
  }
}

class _StoreStatusCard extends StatelessWidget {
  const _StoreStatusCard({required this.isOpen, required this.onToggle, this.timings});

  final bool isOpen;

  /// Today's hours from the server; it always read "Today: 08:00 - 22:00".
  final String? timings;
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
                  isOpen
                      ? LocalizationService.tr('Open • Accepting orders')
                      : LocalizationService.tr('Closed • Not accepting'),
                  style: TextStyle(
                    color: isOpen ? AppColors.iconGreen : AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                if ((timings ?? '').isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  timings!,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ],
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
                    ? const Color(0xFFFF5216)
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
                label: LocalizationService.tr('New prescriptions'),
                badgeGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF8A3D), Color(0xFFFF5216)],
                ),
                countColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: newOtcOrders,
                label: LocalizationService.tr('New OTC orders'),
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
                label: LocalizationService.tr('Preparing'),
                badgeColor: const Color(0xFFFFB300),
                countColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: ready,
                label: LocalizationService.tr('Ready'),
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
            child: _TotalItem(
              title: LocalizationService.tr('ORDERS'),
              value: orders,
            ),
          ),
          const _VDivider(),
          Expanded(
            child: _TotalItem(
              title: LocalizationService.tr('COMPLETED'),
              value: completed,
            ),
          ),
          const _VDivider(),
          Expanded(
            child: _TotalItem(
              title: LocalizationService.tr('REVENUE'),
              value: revenue,
              suffix: 'MRU',
              // No trend in the API: the arrow was always up and green.
              showTrend: false,
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
        Text(
          LocalizationService.tr('ORDERS'),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            LocalizationService.tr('See All'),
            style: const TextStyle(
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
          colors: [Color(0xFFFF5216), Color(0xFFFF8F3D), Color(0xFFFFC04D)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeTab(
              label: LocalizationService.tr('Prescription'),
              selected: selectedIndex == 0,
              badge: selectedIndex == 0 ? prescriptionBadge : null,
              onTap: () => onSelect(0),
            ),
          ),
          Expanded(
            child: _TypeTab(
              label: LocalizationService.tr('OTC'),
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
          // Figma: the selected type sits on a white pill.
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
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
              decoration: InputDecoration(
                hintText: S.of(context).searchByIdName,
                hintStyle: const TextStyle(
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
                      LocalizationService.tr(widget.filters[index]),
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

/// Back from a card's details / quotation screen: the status may have changed
/// there (reviewed, quote sent, accepted...), so reload the visible list. It
/// kept showing the old state (test day V18).
/// A paid prescription order in To Prepare / Preparing: the OTC order card,
/// whose Accept, Start Preparing and Ready buttons call the order API. The
/// prescription cards only opened a details screen whose button did
/// nothing, and a new paid order (status 1) was in no tab (V-B11).
Widget _prescriptionOrderCard(
  BuildContext context,
  PharmacyHomeController controller,
  PharmacyPendingOrderItem order,
) {
  final rawId = order.resolvedId;
  final status = order.status ?? 2;
  return _OtcNewOrderCard(
    customerName: order.displayCustomerName,
    orderId: order.displayOrderCode,
    timeAgo: order.displayTimeAgo,
    selfPickup: order.isSelfPickupBool,
    cashOnDelivery: order.isCashOnDeliveryBool,
    paymentType: order.paymentType,
    accepted: status == 2,
    preparing: status == 3,
    ready: false,
    delivered: false,
    partnerName: order.deliveryBoyName,
    itemsSummary: _otcItemsSummary(context, order.displayItemsCount, order.displayTotal),
    phone: order.phone,
    orderRawId: rawId,
    isAccepting: controller.isAcceptingOrder && controller.acceptingOrderId == rawId,
    onAccept: rawId == null || status != 1
        ? null
        : () => controller.acceptPharmacyOrder(rawId, context: context),
    isRejecting: controller.isCancellingOrder && controller.cancellingOrderId == rawId,
    onReject: rawId == null || status != 1
        ? null
        : () => _rejectWithReason(
                    context,
                    (reason) => controller.cancelPharmacyOrder(
                      rawId,
                      context: context,
                      reason: reason,
                    ),
                  ),
    isPreparingAction: controller.isPreparingOrder && controller.preparingOrderId == rawId,
    onPrepare: rawId == null || status != 2
        ? null
        : () => controller.preparePharmacyOrder(rawId, context: context),
    isMarkingReadyAction: controller.isMarkingReadyOrder && controller.markingReadyOrderId == rawId,
    onMarkAsReady: rawId == null || status != 3
        ? null
        : () => controller.markAsReadyPharmacyOrder(rawId, context: context),
  );
}

void _refreshListOnReturn(Object? _) {
  if (Get.isRegistered<PharmacyHomeController>()) {
    Get.find<PharmacyHomeController>().refreshVisibleList();
  }
}

class _PrescriptionOrderCard extends StatelessWidget {
  const _PrescriptionOrderCard({
    this.customerName = '',
    this.orderCode = '',
    this.timeAgo = '',
    this.notesType = PharmacyOrderNotesType.none,
    this.isSelfPickup = false,
    this.status = PharmacyPrescriptionCardStatus.newOrder,
    this.prescriptionFileName,
    this.prescriptionImageUrl,
    this.specialNotes,
    this.phone,
    this.prescriptionId,
    this.onReviewPrescription,
    this.isReviewingAction = false,
    this.onMarkAsReviewed,
    this.isMarkingReviewedAction = false,
    this.onReject,
    this.isRejectingAction = false,
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
  final VoidCallback? onReviewPrescription;
  final bool isReviewingAction;
  final VoidCallback? onMarkAsReviewed;
  final bool isMarkingReviewedAction;
  final VoidCallback? onReject;
  final bool isRejectingAction;

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
      PharmacyPrescriptionCardStatus.underReview => S.of(context).pharmacyHomeBadgeReviewing,
      PharmacyPrescriptionCardStatus.reviewCompleted => S.of(context).pharmacyHomeBadgeReviewCompleted,
      PharmacyPrescriptionCardStatus.newOrder => S.of(context).pharmacyHomeBadgeNew,
    };
    final badgeColor = switch (status) {
      PharmacyPrescriptionCardStatus.underReview => _reviewingBadge,
      PharmacyPrescriptionCardStatus.reviewCompleted => _completedBadge,
      PharmacyPrescriptionCardStatus.newOrder => _newBadge,
    };
    final primaryLabel = switch (status) {
      PharmacyPrescriptionCardStatus.underReview => S.of(context).pharmacyHomeMarkAsReviewed,
      PharmacyPrescriptionCardStatus.reviewCompleted => S.of(context).quoteCreateTitle,
      PharmacyPrescriptionCardStatus.newOrder => S.of(context).pharmacyHomeReviewPrescription,
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
      ).then(_refreshListOnReturn);
    }

    void openQuotation() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PharmacyCreateQuotationScreen(
            customerName: customerName,
            phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
            requestId: orderCode,
            requestMeta: timeAgo,
            imageUrl: prescriptionImageUrl,
            prescriptionId: prescriptionId,
          ),
        ),
      ).then(_refreshListOnReturn);
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
                      customerName.trim().isNotEmpty
                          ? customerName.trim().substring(0, 1).toUpperCase()
                          : (orderCode.trim().isNotEmpty ? '#' : 'C'),
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
                                customerName.trim().isNotEmpty
                                    ? customerName.trim()
                                    : (orderCode.trim().isNotEmpty
                                          ? S.of(context).pharmacyHomeOrderCode(orderCode)
                                          : S.of(context).quoteCustomer),
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
                                    prescriptionFileName!.trim().isNotEmpty)
                                ? prescriptionFileName!.trim()
                                : (orderCode.trim().isNotEmpty
                                      ? S.of(context).pharmacyHomePrescriptionCode(orderCode)
                                      : S.of(context).pharmacyHomePrescription),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  S.of(context).pharmacyHomeViewFullPrescription,
                                  style: const TextStyle(
                                    color: _linkOrange,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
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
                        onPressed:
                            (isRejectingAction ||
                                isReviewingAction ||
                                isMarkingReviewedAction ||
                                onReject == null)
                            ? null
                            : onReject,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _nameColor,
                          disabledForegroundColor: _nameColor.withValues(
                            alpha: 0.5,
                          ),
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
                        child: isRejectingAction
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _nameColor,
                                ),
                              )
                            : Text(
                                S.of(context).reject,
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
                          onPressed:
                              (isReviewingAction || isMarkingReviewedAction)
                              ? null
                              : (_isReviewCompleted
                                    ? openQuotation
                                    : (_isUnderReview &&
                                          onMarkAsReviewed != null)
                                    ? onMarkAsReviewed
                                    : (status ==
                                              PharmacyPrescriptionCardStatus
                                                  .newOrder &&
                                          onReviewPrescription != null)
                                    ? onReviewPrescription
                                    : openDetails),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white70,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: (isReviewingAction || isMarkingReviewedAction)
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
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

  static String? resolveUrl(String? raw) {
    if (raw == null) return null;
    var str = raw.trim();
    if (str.isEmpty) return null;
    str = str.replaceAll(r'\', '/');
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    if (str.startsWith('//')) {
      return 'https:$str';
    }
    final base = ApiConfigs.IMAGE_URL.trim();
    final uri = Uri.tryParse(base);
    final origin = (uri != null && uri.hasScheme)
        ? '${uri.scheme}://${uri.host}'
        : ''; // only the configured server, never a hard-coded host
    if (str.startsWith('/storage/')) {
      return '$origin$str';
    }
    if (str.startsWith('storage/')) {
      return '$origin/$str';
    }
    if (str.startsWith('/')) {
      final cleanBase = base.endsWith('/')
          ? base.substring(0, base.length - 1)
          : base;
      return '$cleanBase$str';
    }
    final cleanBase = base.endsWith('/') ? base : '$base/';
    return '$cleanBase$str';
  }

  @override
  Widget build(BuildContext context) {
    final validUrl = resolveUrl(imageUrl);
    return SizedBox(
      width: 64,
      height: 68,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (validUrl != null && validUrl.isNotEmpty)
              ? Image.network(
                  validUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.description_outlined,
                    color: Color(0xFF9CA3AF),
                    size: 26,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ToPrepareCard extends StatelessWidget {
  const _ToPrepareCard({
    this.scheduled = false,
    this.customerName = '',
    this.orderCode = '',
    this.timeAgo = '',
    this.isSelfPickup = false,
    this.prescriptionId,
    this.phone,
    this.prescriptionFileName,
    this.prescriptionImageUrl,
    this.isCashOnDelivery = false,
    this.paymentType,
    this.scheduledDate,
    this.scheduledTime,
  });

  final bool scheduled;
  final String customerName;
  final String orderCode;
  final String timeAgo;
  final bool isSelfPickup;
  final int? prescriptionId;
  final String? phone;
  final String? prescriptionFileName;
  final String? prescriptionImageUrl;
  final bool isCashOnDelivery;
  final dynamic paymentType;
  final String? scheduledDate;
  final String? scheduledTime;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFE24B3B);
  static const Color _name = Color(0xFF1A1A1A);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _orange = Color(0xFFFF5216);
  static const Color _muted = Color(0xFF6B7280);

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyOrderDetailsScreen(
          customerName: customerName.isNotEmpty ? customerName : S.of(context).quoteCustomer,
          phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
          requestId: orderCode,
          requestMeta: timeAgo,
          notesType: PharmacyOrderNotesType.none,
          isToPrepare: true,
          isSelfPickup: isSelfPickup,
          prescriptionId: prescriptionId,
          orderId: prescriptionId,
          orderRawId: prescriptionId,
          prescriptionImageUrl: prescriptionImageUrl,
        ),
      ),
    ).then(_refreshListOnReturn);
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
                          : 'C',
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
                        customerName.isNotEmpty ? customerName : S.of(context).quoteCustomer,
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
                    child: Text(
                      S.of(context).pharmacyHomeBadgeToPrepare,
                      style: const TextStyle(
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
                            text: isSelfPickup ? S.of(context).selfPickup : S.of(context).delivery,
                            style: const TextStyle(
                              color: _orange,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text:
                                [
                                  if (orderCode.isNotEmpty) orderCode,
                                  if (timeAgo.isNotEmpty) timeAgo,
                                ].isNotEmpty
                                ? '  • ${[if (orderCode.isNotEmpty) orderCode, if (timeAgo.isNotEmpty) timeAgo].join(' • ')}'
                                : '',
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
                Row(
                  children: [
                    const _ScheduledPill(),
                    const Spacer(),
                    if (scheduledDate != null && scheduledDate!.isNotEmpty) ...[
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: _blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        scheduledDate!,
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (scheduledTime != null && scheduledTime!.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: _blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        scheduledTime!,
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                )
              // Order lists don't send payment_type: no chip rather than a
              // guessed "Online payment" on cash orders.
              else if (paymentTypeCode(paymentType) != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFE4D4)),
                    color: const Color.fromARGB(255, 254, 246, 238),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image: AssetImage(
                          isCashOnDelivery
                              ? 'lib/pharmacy/Assets/images/cashondelivery.png'
                              : 'lib/pharmacy/Assets/images/online_payment.png',
                        ),
                        width: isCashOnDelivery ? 18 : 16,
                        height: isCashOnDelivery ? 18 : 16,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        paymentTypeLabel(paymentType, cashFallback: isCashOnDelivery),
                        style: const TextStyle(
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
                    _PrescriptionThumb(imageUrl: prescriptionImageUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (prescriptionFileName != null &&
                                    prescriptionFileName!.trim().isNotEmpty)
                                ? prescriptionFileName!.trim()
                                : (orderCode.trim().isNotEmpty
                                      ? S.of(context).pharmacyHomePrescriptionCode(orderCode)
                                      : S.of(context).pharmacyHomePrescription),
                            style: const TextStyle(
                              color: _name,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _openDetails(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  S.of(context).pharmacyHomeViewFullPrescription,
                                  style: const TextStyle(
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
                  child: Text(
                    S.of(context).pharmacyHomeStartPreparing,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
    this.customerName = '',
    this.orderCode = '',
    this.timeAgo = '',
    this.isSelfPickup = false,
    this.prescriptionId,
    this.phone,
    this.prescriptionFileName,
    this.prescriptionImageUrl,
    this.isCashOnDelivery = false,
    this.paymentType,
  });

  final String customerName;
  final String orderCode;
  final String timeAgo;
  final bool isSelfPickup;
  final int? prescriptionId;
  final String? phone;
  final String? prescriptionFileName;
  final String? prescriptionImageUrl;
  final bool isCashOnDelivery;
  final dynamic paymentType;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFE24B3B);
  static const Color _name = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFFF5216);
  static const Color _meta = Color(0xFF6B7280);

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyOrderDetailsScreen(
          customerName: customerName.isNotEmpty ? customerName : S.of(context).quoteCustomer,
          phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
          requestId: orderCode,
          requestMeta: timeAgo,
          notesType: PharmacyOrderNotesType.none,
          isPreparing: true,
          isSelfPickup: isSelfPickup,
          prescriptionId: prescriptionId,
          orderId: prescriptionId,
          orderRawId: prescriptionId,
          prescriptionImageUrl: prescriptionImageUrl,
        ),
      ),
    ).then(_refreshListOnReturn);
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
                          : 'C',
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
                                customerName.isNotEmpty
                                    ? customerName
                                    : S.of(context).quoteCustomer,
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
                              child: Text(
                                S.of(context).preparing.toUpperCase(),
                                style: const TextStyle(
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
                                          ? S.of(context).selfPickup
                                          : S.of(context).delivery,
                                      style: const TextStyle(
                                        color: _orange,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        height: 1,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          [
                                            if (orderCode.isNotEmpty) orderCode,
                                            if (timeAgo.isNotEmpty) timeAgo,
                                          ].isNotEmpty
                                          ? '  • ${[if (orderCode.isNotEmpty) orderCode, if (timeAgo.isNotEmpty) timeAgo].join(' • ')}'
                                          : '',
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
                child: Row(
                  children: [
                    _PrescriptionThumb(imageUrl: prescriptionImageUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (prescriptionFileName != null &&
                                    prescriptionFileName!.trim().isNotEmpty)
                                ? prescriptionFileName!.trim()
                                : (orderCode.trim().isNotEmpty
                                      ? S.of(context).pharmacyHomePrescriptionCode(orderCode)
                                      : S.of(context).pharmacyHomePrescription),
                            style: const TextStyle(
                              color: _name,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _openDetails(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  S.of(context).pharmacyHomeViewFullPrescription,
                                  style: const TextStyle(
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (paymentTypeCode(paymentType) != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4EA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image(
                      image: AssetImage(
                        isCashOnDelivery
                            ? 'lib/pharmacy/Assets/images/cashondelivery.png'
                            : 'lib/pharmacy/Assets/images/online_payment.png',
                      ),
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      paymentTypeLabel(paymentType, cashFallback: isCashOnDelivery),
                      style: const TextStyle(
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
                  child: Text(
                    S.of(context).waterReadyForDispatch,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
    this.customerName = '',
    this.orderCode = '',
    this.timeAgo = '',
    this.partnerName,
    this.isSelfPickup = false,
    this.prescriptionId,
    this.orderId,
    this.phone,
    this.prescriptionFileName,
    this.prescriptionImageUrl,
    this.isCashOnDelivery = false,
    this.paymentType,
  });

  final String customerName;
  final String orderCode;
  final String timeAgo;
  final String? partnerName;
  final bool isSelfPickup;
  final int? prescriptionId;

  /// The paid order (`order_id`); the details load it and its prescription.
  final int? orderId;
  final String? phone;
  final String? prescriptionFileName;
  final String? prescriptionImageUrl;
  final bool isCashOnDelivery;
  final dynamic paymentType;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFE24B3B);
  static const Color _name = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFFF5216);
  static const Color _meta = Color(0xFF6B7280);
  static const Color _ready = Color(0xFF22C55E);
  static const Color _partner = Color(0xFF7C3AED);
  static const Color _partnerBg = Color(0xFFF3E8FF);

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyOrderDetailsScreen(
          customerName: customerName.isNotEmpty ? customerName : S.of(context).quoteCustomer,
          phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
          requestId: orderCode,
          requestMeta: timeAgo,
          notesType: PharmacyOrderNotesType.none,
          isReady: true,
          isSelfPickup: isSelfPickup,
          isOtcPartnerAssigned: partnerName != null && partnerName!.isNotEmpty,
          prescriptionId: prescriptionId,
          orderId: orderId ?? prescriptionId,
          orderRawId: orderId ?? prescriptionId,
          prescriptionImageUrl: prescriptionImageUrl,
        ),
      ),
    ).then(_refreshListOnReturn);
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
                        : 'C',
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
                              customerName.isNotEmpty
                                  ? customerName
                                  : S.of(context).quoteCustomer,
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
                            child: Text(
                              S.of(context).ready.toUpperCase(),
                              style: const TextStyle(
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
                                        ? S.of(context).selfPickup
                                        : S.of(context).delivery,
                                    style: const TextStyle(
                                      color: _orange,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        [
                                          if (orderCode.isNotEmpty) orderCode,
                                          if (timeAgo.isNotEmpty) timeAgo,
                                        ].isNotEmpty
                                        ? '  • ${[if (orderCode.isNotEmpty) orderCode, if (timeAgo.isNotEmpty) timeAgo].join(' • ')}'
                                        : '',
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
              child: Row(
                children: [
                  _PrescriptionThumb(imageUrl: prescriptionImageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (prescriptionFileName != null &&
                                  prescriptionFileName!.trim().isNotEmpty)
                              ? prescriptionFileName!.trim()
                              : (orderCode.trim().isNotEmpty
                                    ? S.of(context).pharmacyHomePrescriptionCode(orderCode)
                                    : S.of(context).pharmacyHomePrescription),
                          style: const TextStyle(
                            color: _name,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _openDetails(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                S.of(context).pharmacyHomeViewFullPrescription,
                                style: const TextStyle(
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
                                Text(
                                  S.of(context).assignedDeliveryPartner,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 96, 96, 96),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  partnerName != null && partnerName!.isNotEmpty
                                      ? '($partnerName)'
                                      : '(${S.of(context).pharmacyHomeNotAssigned})',
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
                if (paymentTypeCode(paymentType) != null) ...[
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF4EA),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image(
                          image: AssetImage(
                            isCashOnDelivery
                                ? 'lib/pharmacy/Assets/images/cashondelivery.png'
                                : 'lib/pharmacy/Assets/images/online_payment.png',
                          ),
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          paymentTypeLabel(paymentType, cashFallback: isCashOnDelivery),
                          style: const TextStyle(
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
    this.orderId,
    this.phone,
    this.prescriptionFileName,
    this.prescriptionImageUrl,
    this.isCashOnDelivery = false,
    this.paymentType,
  });

  final String customerName;
  final String orderCode;
  final String timeAgo;
  final bool isSelfPickup;
  final int? prescriptionId;

  /// The paid order (`order_id`); the details load it and its prescription.
  final int? orderId;
  final String? phone;
  final String? prescriptionFileName;
  final String? prescriptionImageUrl;
  final bool isCashOnDelivery;
  final dynamic paymentType;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFE24B3B);
  static const Color _name = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFFF5216);
  static const Color _meta = Color(0xFF6B7280);
  static const Color _delivered = Color(0xFF22C55E);

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyOrderDetailsScreen(
          customerName: customerName.isNotEmpty ? customerName : S.of(context).quoteCustomer,
          phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
          requestId: orderCode,
          requestMeta: timeAgo,
          notesType: PharmacyOrderNotesType.none,
          isDelivered: true,
          isSelfPickup: isSelfPickup,
          prescriptionId: prescriptionId,
          orderId: orderId ?? prescriptionId,
          orderRawId: orderId ?? prescriptionId,
          prescriptionImageUrl: prescriptionImageUrl,
        ),
      ),
    ).then(_refreshListOnReturn);
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
                        : 'C',
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
                              customerName.isNotEmpty
                                  ? customerName
                                  : S.of(context).quoteCustomer,
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
                            child: Text(
                              S.of(context).delivered.toUpperCase(),
                              style: const TextStyle(
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
                                        ? S.of(context).selfPickup
                                        : S.of(context).delivery,
                                    style: const TextStyle(
                                      color: _orange,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        [
                                          if (orderCode.isNotEmpty) orderCode,
                                          if (timeAgo.isNotEmpty) timeAgo,
                                        ].isNotEmpty
                                        ? '  • ${[if (orderCode.isNotEmpty) orderCode, if (timeAgo.isNotEmpty) timeAgo].join(' • ')}'
                                        : '',
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
              child: Row(
                children: [
                  _PrescriptionThumb(imageUrl: prescriptionImageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (prescriptionFileName != null &&
                                  prescriptionFileName!.trim().isNotEmpty)
                              ? prescriptionFileName!.trim()
                              : (orderCode.trim().isNotEmpty
                                    ? S.of(context).pharmacyHomePrescriptionCode(orderCode)
                                    : S.of(context).pharmacyHomePrescription),
                          style: const TextStyle(
                            color: _name,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _openDetails(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                S.of(context).pharmacyHomeViewFullPrescription,
                                style: const TextStyle(
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Only a payment type the server sent: a missing one was shown
            // as "Online payment", also for wallet orders (VA-22).
            if (paymentTypeCode(paymentType) != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4EA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: AssetImage(
                      isCashOnDelivery
                          ? 'lib/pharmacy/Assets/images/cashondelivery.png'
                          : 'lib/pharmacy/Assets/images/online_payment.png',
                    ),
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    paymentTypeLabel(paymentType, cashFallback: isCashOnDelivery),
                    style: const TextStyle(
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 13,
            color: Color(0xFF3B82F6),
          ),
          const SizedBox(width: 4),
          Text(
            S.of(context).scheduled,
            style: const TextStyle(
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
    this.orderId,
    this.phone,
    this.prescriptionFileName,
    this.prescriptionImageUrl,
    this.quotedDateFormatted,
    this.expiresText,
  });

  final String customerName;
  final String orderCode;
  final String timeAgo;
  final String? quotationAmount;
  final int? prescriptionId;

  /// The paid order (`order_id`); the details load it and its prescription.
  final int? orderId;
  final String? phone;
  final String? prescriptionFileName;
  final String? prescriptionImageUrl;
  final String? quotedDateFormatted;
  final String? expiresText;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFE24B3B);
  static const Color _nameColor = Color(0xFF1A1A1A);
  static const Color _metaColor = Color(0xFF6B7280);
  static const Color _badge = Color(0xFFF5C400);
  static const Color _orange = Color(0xFFFF5216);
  static const Color _label = Color(0xFFA3A3A3);

  @override
  Widget build(BuildContext context) {
    void openPrescription() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PharmacyOrderDetailsScreen(
            customerName: customerName.isNotEmpty ? customerName : S.of(context).quoteCustomer,
            phone: (phone != null && phone!.isNotEmpty) ? phone! : '',
            requestId: orderCode,
            requestMeta: timeAgo,
            notesType: PharmacyOrderNotesType.none,
            isAwaitingPayment: true,
            prescriptionId: prescriptionId,
            orderId: prescriptionId,
            orderRawId: prescriptionId,
            prescriptionImageUrl: prescriptionImageUrl,
          ),
        ),
      ).then(_refreshListOnReturn);
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
                          : 'C',
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
                                customerName.isNotEmpty
                                    ? customerName
                                    : S.of(context).quoteCustomer,
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
                              child: Text(
                                S.of(context).pharmacyHomeBadgeAwaitingPayment,
                                style: const TextStyle(
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
                            [
                                  if (orderCode.isNotEmpty) orderCode,
                                  if (timeAgo.isNotEmpty) timeAgo,
                                ].isNotEmpty
                                ? [
                                    if (orderCode.isNotEmpty) orderCode,
                                    if (timeAgo.isNotEmpty) timeAgo,
                                  ].join(' • ')
                                : '',
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
                    _PrescriptionThumb(imageUrl: prescriptionImageUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (prescriptionFileName != null &&
                                    prescriptionFileName!.trim().isNotEmpty)
                                ? prescriptionFileName!.trim()
                                : (orderCode.trim().isNotEmpty
                                      ? S.of(context).pharmacyHomePrescriptionCode(orderCode)
                                      : S.of(context).pharmacyHomePrescription),
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
                            onTap: openPrescription,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  S.of(context).pharmacyHomeViewFullPrescription,
                                  style: const TextStyle(
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
                        Text(
                          S.of(context).pharmacyHomeQuotationLabel,
                          style: const TextStyle(
                            color: _label,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (quotationAmount != null &&
                                  quotationAmount!.isNotEmpty)
                              ? (quotationAmount!.contains('MRU')
                                    ? quotationAmount!
                                    : '$quotationAmount MRU')
                              : '0 MRU',
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
                        S.of(context).status.toUpperCase(),
                        style: const TextStyle(
                          color: _label,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              color: _badge,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(width: 8, height: 8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            S.of(context).pharmacyHomeAwaitingPayment,
                            style: const TextStyle(
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    (quotedDateFormatted != null &&
                            quotedDateFormatted!.isNotEmpty)
                        ? quotedDateFormatted!
                        : (timeAgo.isNotEmpty ? timeAgo : ''),
                    style: const TextStyle(
                      color: Color(0xFF3A3A3A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  if (expiresText != null && expiresText!.isNotEmpty) ...[
                    const Spacer(),
                    const Image(
                      image: AssetImage(
                        'lib/pharmacy/Assets/images/hourglass.png',
                      ),
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      expiresText!,
                      style: const TextStyle(
                        color: _orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
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
    this.express = false,
    this.cashOnDelivery = false,
    this.paymentType,
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

  /// Express delivery order (`is_express`): Figma shows an Express tag.
  final bool express;
  final bool cashOnDelivery;
  final dynamic paymentType;

  /// The payment pill needs a real `payment_type` (or a known cash order).
  bool get _hasPaymentType =>
      paymentTypeCode(paymentType) != null || cashOnDelivery;
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
  static const Color _orange = Color(0xFFFF5216);
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
              customerName: customerName.isNotEmpty ? customerName : S.of(context).quoteCustomer,
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
        ).then(_refreshListOnReturn);
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
                                  ? S.of(context).cancelled.toUpperCase()
                                  : (delivered
                                        ? S.of(context).delivered.toUpperCase()
                                        : ready
                                        ? S.of(context).ready.toUpperCase()
                                        : preparing
                                        ? S.of(context).preparing.toUpperCase()
                                        : accepted
                                        ? S.of(context).accepted.toUpperCase()
                                        : S.of(context).pharmacyHomeBadgeNew),
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
                            Text(
                              S.of(context).selfPickup,
                              style: const TextStyle(
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
                            Text(
                              S.of(context).delivery,
                              style: const TextStyle(
                                color: _orange,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                            if (express) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.bolt_rounded,
                                      size: 12,
                                      color: _orange,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      S.of(context).processingExpress,
                                      style: const TextStyle(
                                        color: _orange,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
              // No sample slot ("15 Aug 2026", "6:00 - 7:00 PM"): the list
              // carries no scheduled date or time, so only the pill shows.
              const Row(
                children: [
                  _ScheduledPill(),
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
                                Text(
                                  S.of(context).assignedDeliveryPartner,
                                  maxLines: 1,
                                  style: const TextStyle(
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
                    // Only a payment type the server sent (VA-22).
                    if (_hasPaymentType)
                    _OtcInfoPill(
                      icon: Image.asset(
                        cashOnDelivery
                            ? 'lib/pharmacy/Assets/images/cashondelivery.png'
                            : 'lib/pharmacy/Assets/images/online_payment.png',
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                      ),
                      label: paymentTypeLabel(paymentType, cashFallback: cashOnDelivery),
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
                    if (_hasPaymentType)
                    _OtcInfoPill(
                      icon: Image.asset(
                        cashOnDelivery
                            ? 'lib/pharmacy/Assets/images/cashondelivery.png'
                            : 'lib/pharmacy/Assets/images/online_payment.png',
                        width: cashOnDelivery ? 18 : 16,
                        height: cashOnDelivery ? 18 : 16,
                        fit: BoxFit.contain,
                      ),
                      label: paymentTypeLabel(paymentType, cashFallback: cashOnDelivery),
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
                      child:
                          (preparing ? isMarkingReadyAction : isPreparingAction)
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              preparing ? S.of(context).markAsReady : S.of(context).prepareOrder,
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
                              : Text(
                                  S.of(context).reject,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: const TextStyle(
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
                                : Text(
                                    S.of(context).acceptOrder,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: const TextStyle(
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

  static const Color _orange = Color(0xFFFF5216);

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

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.selectedIndex,
    required this.onSelect,
    this.unreadChatCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final int unreadChatCount;

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
                      Stack(
                        clipBehavior: Clip.none,
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
                          if (index == 2 && unreadChatCount > 0)
                            Positioned(
                              top: -2,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  unreadChatCount > 99
                                      ? '99+'
                                      : unreadChatCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        LocalizationService.tr(labels[index]),
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

/// "3 Items • 305.00 MRU" in the app language (Figma OTC card pill).
String? _otcItemsSummary(BuildContext context, int count, String total) {
  final s = S.of(context);
  final items = count <= 0
      ? ''
      : (count == 1 ? s.pharmacyHomeOneItem : s.pharmacyHomeItemCount('$count'));
  final parts = [items, total.trim()].where((p) => p.isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join(' • ');
}
