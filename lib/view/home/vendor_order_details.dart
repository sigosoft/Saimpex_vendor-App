import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/utils/widgets/dotted_line_painter.dart';
// ignore: unused_import — success_dialog is used indirectly via utils
import 'package:saimpex_vendor/utils/widgets/success_dialog.dart';
import 'package:saimpex_vendor/view/shimmer_loading/shimmer_text_content.dart';

import '../../configs/ApiConfigs.dart';
import '../../controller/order_details_controller.dart';
import '../../generated/l10n.dart';
// ignore: unused_import
import '../../model/OrderDetailsModel.dart';
import '../../utils/Widgets/custom_app_bar.dart';
import '../../utils/utils.dart';
import '../../utils/widgets/no_data_widget.dart';

class VendorOrderDetails extends StatefulWidget {
  final String orderId;
  final String? orderType;

  const VendorOrderDetails({super.key, required this.orderId, this.orderType});

  @override
  State<VendorOrderDetails> createState() => _VendorOrderDetailsState();
}

class _VendorOrderDetailsState extends State<VendorOrderDetails> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: localization.currentLocale!.languageCode.toString() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: GetBuilder<OrderDetailsController>(
        init: OrderDetailsController(),
        didChangeDependencies: (state) async {
          String vendorType = await getSavedObject("vendorType");
          if (vendorType == "1") {
            state.controller?.getRestaurantOrderDetails(
              state.context,
              widget.orderId,
            );
          } else {
            state.controller?.getGroceryOrderDetails(
              state.context,
              widget.orderId,
            );
          }
        },
        builder: (controller) {
          final bool isBasketOrder =
              widget.orderType?.trim().toLowerCase().contains("basket") ==
                  true ||
              controller.orderData?.type?.trim().toLowerCase().contains(
                    "basket",
                  ) ==
                  true ||
              (controller.orderData?.basketOrders?.isNotEmpty == true);

          if (!controller.isLoading && controller.orderData == null) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppBar(
                title: S.of(context).orderDetails,
                onTap: () {
                  Get.back();
                },
              ),
              body: Center(
                child: NoDataWidget(
                  context,
                  S.of(context).orderDetails,
                  S.of(context).orderDetailsNotFound,
                  "lib/assets/images/nodata.png",
                ),
              ),
            );
          }

          return CommonBackground(
            appBar: CustomAppBar(
              title: S.of(context).orderDetails,
              onTap: () => Get.back(),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: controller.isLoading && controller.orderData == null
                      ? ShimmerTextContent()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 14),
                              // Order Summary Card
                              Container(
                                width: MediaQuery.of(context).size.width * 0.95,
                                constraints: const BoxConstraints(
                                  minHeight: 220,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                S
                                                    .of(context)
                                                    .orderIdLabel(
                                                      controller
                                                          .orderData!
                                                          .orderCode
                                                          .toString(),
                                                    ),
                                                style: GoogleFonts.rubik(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorPrimary,
                                                ),
                                              ),
                                              if (widget.orderType
                                                          ?.trim()
                                                          .toLowerCase()
                                                          .contains("basket") ==
                                                      true ||
                                                  controller.orderData?.type
                                                          ?.trim()
                                                          .toLowerCase()
                                                          .contains("basket") ==
                                                      true) ...[
                                                const SizedBox(height: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFDFF3F4,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    "Basket order",
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                        0xFF37ADB5,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),

                                          // pending =1
                                          // accepted  =2
                                          // preparing =3
                                          // Ready=4
                                          // delivered = 9
                                          // cancelled = 10
                                          decoration: BoxDecoration(
                                            color:
                                                controller.orderData?.status
                                                        .toString() ==
                                                    '1'
                                                ? const Color(0xFFF59E0B)
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '2'
                                                ? const Color(0xFF22C55E)
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '3'
                                                ? const Color(0xFF60A5FA)
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '4'
                                                ? const Color(0xFF15803D)
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '10'
                                                ? const Color(0xFFEF4444)
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '9'
                                                ? const Color(0xFF0F552A)
                                                : const Color(0xFF22C55E),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            controller.orderData?.status
                                                        .toString() ==
                                                    '1'
                                                ? S.of(context).pending
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '2'
                                                ? S.of(context).accepted
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '3'
                                                ? S.of(context).preparing
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '4'
                                                ? S.of(context).ready
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '5'
                                                ? S.of(context).assigned
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '6'
                                                ? S
                                                      .of(context)
                                                      .reachedRestaurant
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '7'
                                                ? S.of(context).pickedUp
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '8'
                                                ? S.of(context).delivering
                                                : controller.orderData?.status
                                                          .toString() ==
                                                      '10'
                                                ? S.of(context).cancelled
                                                : S.of(context).delivered,
                                            style: GoogleFonts.rubik(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8), // Reduced gap
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            controller.orderData?.userName ??
                                                "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.rubik(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        // if (controller.orderData?.status
                                        //         .toString() ==
                                        //     '3')
                                        //   Text(
                                        //     formatDurationToMinutes(controller.orderData!.orderDurations?.preparationDuration?.toString()),
                                        //     style: GoogleFonts.rubik(
                                        //       fontSize: 10,
                                        //       color: const Color(0xFF64748B),
                                        //     ),
                                        //   ),
                                      ],
                                    ),
                                    const SizedBox(height: 14), // Gap 14px
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _infoCol(
                                          S.of(context).items,
                                          (isBasketOrder
                                                      ? (controller
                                                                .orderData!
                                                                .basketOrders
                                                                ?.fold<int>(
                                                                  0,
                                                                  (sum, bo) =>
                                                                      sum +
                                                                      (bo.basket?.basketItems?.fold<
                                                                            int
                                                                          >(
                                                                            0,
                                                                            (
                                                                              s,
                                                                              i,
                                                                            ) =>
                                                                                s +
                                                                                (i.quantity ??
                                                                                    0),
                                                                          ) ??
                                                                          0),
                                                                ) ??
                                                            0)
                                                      : (controller
                                                                .orderData!
                                                                .orderItems
                                                                ?.length ??
                                                            0))
                                                  .toString() +
                                              " " +
                                              S.of(context).items +
                                              (((double.tryParse(
                                                            controller
                                                                    .orderData
                                                                    ?.total ??
                                                                '0',
                                                          ) ??
                                                          0) <=
                                                      0)
                                                  ? ""
                                                  : (" • " +
                                                        "${controller.orderData?.total} " +
                                                        "MRU")),
                                          isPrice:
                                              ((double.tryParse(
                                                    controller
                                                            .orderData
                                                            ?.total ??
                                                        '0',
                                                  ) ??
                                                  0) >
                                              0),
                                        ),
                                        _infoCol(
                                          S.of(context).dateTime,
                                          formatOrderPlacedAt(
                                            controller.orderData?.placedAt,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14), // Gap 14px
                                    Text(
                                      S.of(context).deliveryAddress,
                                      style: GoogleFonts.rubik(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            controller.orderData!.location
                                                .toString(),
                                            style: GoogleFonts.rubik(
                                              fontSize: 11,
                                              color: const Color(0xFF4B5563),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        InkWell(
                                          onTap: () {
                                            _openInGoogleMaps(
                                              controller.orderData!.latitude
                                                  .toString(),
                                              controller.orderData!.longitude
                                                  .toString(),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: SizedBox(
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.3,
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.09,
                                              child: IgnorePointer(
                                                child: _deliveryMap(
                                                  controller
                                                      .orderData!
                                                      .latitude,
                                                  controller
                                                      .orderData!
                                                      .longitude,
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
                              controller.orderData!.deliveryBoyName
                                              .toString() ==
                                          "" ||
                                      controller.orderData!.deliveryBoyName
                                              .toString() ==
                                          "null"
                                  ? Container()
                                  : const SizedBox(height: 24),
                              controller.orderData!.deliveryBoyName
                                              .toString() ==
                                          "" ||
                                      controller.orderData!.deliveryBoyName
                                              .toString() ==
                                          "null"
                                  ? Container()
                                  : _driverDetails(
                                      context,
                                      controller.orderData!.deliveryBoyImage
                                          .toString(),
                                      controller.orderData!.deliveryBoyName
                                          .toString(),
                                      controller.orderData!.deliveryCountryCode
                                          .toString(),
                                      controller.orderData!.deliveryBoyPhone
                                          .toString(),
                                    ),
                              const SizedBox(height: 32),
                              Text(
                                S.of(context).orderItems +
                                    " " +
                                    "(" +
                                    (isBasketOrder
                                            ? (controller
                                                      .orderData!
                                                      .basketOrders
                                                      ?.fold<int>(
                                                        0,
                                                        (sum, bo) =>
                                                            sum +
                                                            (bo
                                                                    .basket
                                                                    ?.basketItems
                                                                    ?.fold<int>(
                                                                      0,
                                                                      (s, i) =>
                                                                          s +
                                                                          (i.quantity ??
                                                                              0),
                                                                    ) ??
                                                                0),
                                                      ) ??
                                                  0)
                                            : (controller
                                                      .orderData!
                                                      .orderItems
                                                      ?.length ??
                                                  0))
                                        .toString() +
                                    ")",
                                style: GoogleFonts.rubik(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Order Items List
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: isBasketOrder
                                    ? (controller.orderData!.basketOrders
                                              ?.expand(
                                                (bo) =>
                                                    bo.basket?.basketItems ??
                                                    [],
                                              )
                                              .length ??
                                          0)
                                    : (controller
                                              .orderData!
                                              .orderItems
                                              ?.length ??
                                          0),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  if (isBasketOrder) {
                                    final allItems =
                                        controller.orderData!.basketOrders
                                            ?.expand(
                                              (bo) =>
                                                  bo.basket?.basketItems ?? [],
                                            )
                                            .toList() ??
                                        [];
                                    if (index >= allItems.length) {
                                      return const SizedBox.shrink();
                                    }

                                    final basketItem = allItems[index];
                                    final langCode = localization
                                        .currentLocale!
                                        .languageCode
                                        .toString();

                                    final menu =
                                        basketItem.restaurantMenu ??
                                        basketItem.groceryMenu;
                                    final name = langCode == "ar"
                                        ? (menu?.nameAr ?? menu?.nameEn ?? '')
                                        : langCode == "fr"
                                        ? (menu?.nameFr ?? menu?.nameEn ?? '')
                                        : (menu?.nameEn ?? '');

                                    return _itemTile(
                                      menu?.image ?? '',
                                      name,
                                      0.0,
                                      basketItem.quantity ?? 0,
                                      context,
                                      showPrice: false,
                                    );
                                  } else {
                                    final item = controller
                                        .orderData!
                                        .orderItems![index];
                                    final langCode = localization
                                        .currentLocale!
                                        .languageCode
                                        .toString();
                                    return _itemTile(
                                      item.image.toString(),
                                      langCode == "ar"
                                          ? item.orderItem!.nameAr.toString()
                                          : langCode == "fr"
                                          ? item.orderItem!.nameFr.toString()
                                          : item.orderItem!.nameEn.toString(),
                                      double.parse(item.unitPrice.toString()),
                                      item.quantity!,
                                      context,
                                    );
                                  }
                                },
                              ),

                              controller.orderData!.customerNote.toString() ==
                                          "null" ||
                                      controller.orderData!.customerNote
                                              .toString() ==
                                          ""
                                  ? Container()
                                  : const SizedBox(height: 30),
                              controller.orderData!.customerNote.toString() ==
                                          "null" ||
                                      controller.orderData!.customerNote
                                              .toString() ==
                                          ""
                                  ? Container()
                                  : Text(
                                      S.of(context).customerNotes,
                                      style: GoogleFonts.rubik(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ),
                              controller.orderData!.customerNote.toString() ==
                                          "null" ||
                                      controller.orderData!.customerNote
                                              .toString() ==
                                          ""
                                  ? Container()
                                  : const SizedBox(height: 12),
                              controller.orderData!.customerNote.toString() ==
                                          "null" ||
                                      controller.orderData!.customerNote
                                              .toString() ==
                                          ""
                                  ? Container()
                                  : Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.95,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFBEB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFFEF3C7),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            "lib/assets/images/Customer note.png",
                                            height: 20,
                                            width: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              controller.orderData!.customerNote
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.normal,
                                                color: Color(0xFF92400E),
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              const SizedBox(height: 32),
                              if (widget.orderType
                                          ?.trim()
                                          .toLowerCase()
                                          .contains("basket") !=
                                      true &&
                                  controller.orderData?.type
                                          ?.trim()
                                          .toLowerCase()
                                          .contains("basket") !=
                                      true) ...[
                                Text(
                                  S.of(context).paymentSummary,
                                  style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Payment Summary Card
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.32,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      _summaryRow(
                                        S.of(context).subtotal,
                                        controller.orderData!.subtotal
                                                .toString() +
                                            " MRU",
                                      ),
                                      const SizedBox(height: 16),
                                      // Gap 16px as requested
                                      _summaryRow(
                                        S.of(context).deliveryFee,
                                        controller.orderData!.deliveryFee
                                                .toString() +
                                            " MRU",
                                      ),
                                      const SizedBox(height: 16),
                                      // Gap 16px
                                      _summaryRow(
                                        S.of(context).tax,
                                        controller.orderData!.tax.toString() +
                                            " MRU",
                                      ),
                                      const SizedBox(height: 16),
                                      // Gap 16px
                                      _summaryRow(
                                        S.of(context).paymentType,
                                        controller.orderData!.paymentType
                                                    .toString() ==
                                                "1"
                                            ? S.of(context).cashOnDelivery
                                            : S.of(context).onlinePayment,
                                        isGreen: true,
                                      ),
                                      const SizedBox(height: 8),
                                      _summaryRow(
                                        S.of(context).paymentOn,
                                        formatOrderPlacedAt(
                                          controller.orderData?.placedAt,
                                        ),
                                        isSmall: true,
                                      ),
                                      const SizedBox(height: 16),
                                      // Gap 16px
                                      CustomPaint(
                                        painter: DottedLinePainter(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        child: const SizedBox(
                                          width: double.infinity,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Gap 16px
                                      _summaryRow(
                                        S.of(context).totalAmount,
                                        controller.orderData!.total.toString() +
                                            " MRU",
                                        isTotal: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 32),
                              // Order Overview / Order Duration Breakdown tabs
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          controller.selectedOrderTabIndex = 0;
                                          controller.update();
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(0),
                                          decoration: BoxDecoration(
                                            color:
                                                controller
                                                        .selectedOrderTabIndex ==
                                                    0
                                                ? colorPrimary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              S.of(context).orderTimeline,
                                              style: GoogleFonts.rubik(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    controller
                                                            .selectedOrderTabIndex ==
                                                        0
                                                    ? Colors.white
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          controller.selectedOrderTabIndex = 1;
                                          controller.update();
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(0),
                                          decoration: BoxDecoration(
                                            color:
                                                controller
                                                        .selectedOrderTabIndex ==
                                                    1
                                                ? colorPrimary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              S
                                                  .of(context)
                                                  .orderDurationBreakdown,
                                              style: GoogleFonts.rubik(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    controller
                                                            .selectedOrderTabIndex ==
                                                        1
                                                    ? Colors.white
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // pending =1
                              // accepted  =2
                              // preparing =3
                              // Ready=4
                              // delivered = 9
                              // cancelled = 10
                              if (controller.selectedOrderTabIndex == 0) ...[
                                // Timeline items (Order Overview)
                                _timelineItem(
                                  S.of(context).orderPlaced,
                                  S.of(context).orderSuccessfullyPlacedBy +
                                      " " +
                                      controller.orderData!.userName.toString(),
                                  controller.orderData!.statusLogs![0].updatedAt
                                      .toString(),
                                  isCompleted: true,
                                  isFirst: true,
                                ),
                                _timelineItem(
                                  S.of(context).orderAccepted,
                                  S.of(context).orderAccepted,
                                  controller.orderData!.status! >= 2
                                      ? controller
                                            .orderData!
                                            .statusLogs![1]
                                            .updatedAt
                                            .toString()
                                      : "",
                                  isCompleted:
                                      controller.orderData!.status! >= 2
                                      ? true
                                      : false,
                                ),
                                _timelineItem(
                                  S.of(context).preparingFood,
                                  S.of(context).orderPreparationStarted,
                                  controller.orderData!.status! >= 3
                                      ? controller
                                            .orderData!
                                            .statusLogs![2]
                                            .updatedAt
                                            .toString()
                                      : "",
                                  isCompleted:
                                      controller.orderData!.status! >= 3,
                                  asset: "lib/assets/images/Preparing food.png",
                                ),
                                _timelineItem(
                                  S.of(context).ready,
                                  S.of(context).orderReady,
                                  controller.orderData!.status! >= 4
                                      ? controller
                                            .orderData!
                                            .statusLogs![3]
                                            .updatedAt
                                            .toString()
                                      : "",
                                  isCompleted:
                                      controller.orderData!.status! >= 4,
                                  asset: "lib/assets/images/Delivery.png",
                                ),
                                _timelineItem(
                                  S.of(context).pickedUp[0].toUpperCase() +
                                      S
                                          .of(context)
                                          .pickedUp
                                          .substring(1)
                                          .toLowerCase(),
                                  S.of(context).orderPickedUp,
                                  controller.orderData!.status! >= 7
                                      ? controller
                                            .orderData!
                                            .statusLogs![4]
                                            .updatedAt
                                            .toString()
                                      : "",
                                  isCompleted:
                                      controller.orderData!.status! >= 7,
                                  asset:
                                      "lib/assets/images/Reached Restaurant.png",
                                ),
                                _timelineItem(
                                  S.of(context).delivering[0].toUpperCase() +
                                      S
                                          .of(context)
                                          .delivering
                                          .substring(1)
                                          .toLowerCase(),
                                  S.of(context).deliveryStarted,
                                  controller.orderData!.status! >= 8
                                      ? controller
                                            .orderData!
                                            .statusLogs![5]
                                            .updatedAt
                                            .toString()
                                      : "",
                                  asset:
                                      "lib/assets/images/Order delivered.png",
                                  isCompleted:
                                      controller.orderData!.status! >= 8,
                                ),

                                _timelineItem(
                                  S.of(context).delivered,
                                  S.of(context).deliveryCompleted,
                                  controller.orderData!.status! >= 9
                                      ? controller
                                            .orderData!
                                            .statusLogs![6]
                                            .updatedAt
                                            .toString()
                                      : "",
                                  asset:
                                      "lib/assets/images/Order delivered.png",
                                  isCompleted:
                                      controller.orderData!.status! >= 9,
                                  isLast: true,
                                ),
                              ],
                              if (controller.selectedOrderTabIndex == 1) ...[
                                _buildOrderDurationBreakdown(
                                  context,
                                  controller,
                                ),
                              ],

                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                              ),
                              // Spacing for bottom buttons
                            ],
                          ),
                        ),
                ),
                // Bottom Buttons
                controller.orderData == null
                    ? Container()
                    : Positioned(
                        bottom: 30,
                        left: 20,
                        right: 20,
                        child: controller.orderData!.status.toString() == '1'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          String vendorType =
                                              await getSavedObject(
                                                "vendorType",
                                              );
                                          if (vendorType == "1") {
                                            controller.cancelRestaurantOrder(
                                              context,
                                              widget.orderId,
                                            );
                                          } else {
                                            controller.cancelGroceryOrder(
                                              context,
                                              widget.orderId,
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFF1F5F9,
                                          ),
                                          foregroundColor: const Color(
                                            0xFFEF4444,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                        child: Text(
                                          S.of(context).reject,
                                          style: GoogleFonts.rubik(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          String vendorType =
                                              await getSavedObject(
                                                "vendorType",
                                              );
                                          if (vendorType == "1") {
                                            controller.acceptRestaurantOrder(
                                              context,
                                              widget.orderId,
                                            );
                                          } else {
                                            controller.acceptGroceryOrder(
                                              context,
                                              widget.orderId,
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFF5216,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                        child: Text(
                                          S.of(context).acceptOrder,
                                          style: GoogleFonts.rubik(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : (controller.orderData!.status.toString() == '2' ||
                                  controller.orderData!.status.toString() ==
                                      '3')
                            ? SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    String vendorType = await getSavedObject(
                                      "vendorType",
                                    );

                                    if (controller.orderData!.status
                                            .toString() ==
                                        '3') {
                                      if (vendorType == "1") {
                                        controller.markAsReadyRestaurantOrder(
                                          context,
                                          widget.orderId,
                                        );
                                      } else {
                                        controller.markAsReadyGroceryOrder(
                                          context,
                                          widget.orderId,
                                        );
                                      }
                                    } else {
                                      if (vendorType == "1") {
                                        controller.prepareRestaurantOrder(
                                          context,
                                          widget.orderId,
                                        );
                                      } else {
                                        controller.prepareGroceryOrder(
                                          context,
                                          widget.orderId,
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF5216),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    controller.orderData!.status.toString() ==
                                            '3'
                                        ? S.of(context).markAsReady
                                        : S.of(context).prepareOrder,
                                    style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openInGoogleMaps(String? latitude, String? longitude) async {
    final lat = double.tryParse(latitude ?? '');
    final lng = double.tryParse(longitude ?? '');
    if (lat == null || lng == null) return;
    final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _deliveryMap(String? latitude, String? longitude) {
    final lat = double.tryParse(latitude ?? '');
    final lng = double.tryParse(longitude ?? '');
    if (lat == null || lng == null) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.map, size: 24, color: Colors.grey),
      );
    }
    final position = LatLng(lat, lng);
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: position, zoom: 14),
      markers: {
        Marker(markerId: const MarkerId('delivery'), position: position),
      },
      zoomControlsEnabled: false,
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      liteModeEnabled: true,
    );
  }

  Widget _infoCol(String label, String value, {bool isPrice = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: GoogleFonts.rubik(
              fontSize: 11,
              color: const Color(0xFF4B5563),
            ),
            children: isPrice
                ? [
                    TextSpan(text: value.split('•')[0] + " • "),
                    TextSpan(
                      text: value.split('•')[1],
                      style: const TextStyle(
                        color: colorPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                : [TextSpan(text: value)],
          ),
        ),
      ],
    );
  }

  Widget _itemTile(
    String image,
    String name,
    double price,
    int qty,
    BuildContext context, {
    bool showPrice = true,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ApiConfigs.IMAGE_URL + image, // Using generic food image
              width: 74,
              height: 74,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  Container(width: 74, height: 74, color: Colors.grey[100]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                if (showPrice) ...[
                  const SizedBox(height: 4),
                  Text(
                    "${price.toStringAsFixed(2)} MRU",
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              S.of(context).qty + ": " + "$qty",
              style: GoogleFonts.rubik(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isGreen = false,
    bool isTotal = false,
    bool isSmall = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: const Color(0xFF4B5563),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.rubik(
              fontSize: isTotal ? 14 : (isSmall ? 11 : 13),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isGreen
                  ? const Color(0xFF10B981)
                  : (isTotal
                        ? colorPrimary
                        : (isSmall
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF1F2937))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _timelineItem(
    String title,
    String subtitle,
    String time, {
    bool isCompleted = false,
    bool isFirst = false,
    bool isLast = false,
    String? asset,
    IconData? icon,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFFF5216)
                      : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : asset != null
                    ? Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Image.asset(
                          asset,
                          color: const Color(0xFF94A3B8),
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.circle,
                                color: Color(0xFF94A3B8),
                                size: 12,
                              ),
                        ),
                      )
                    : Icon(
                        icon ?? Icons.circle,
                        color: const Color(0xFF94A3B8),
                        size: 16,
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFE2E8F0)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      if (time.isNotEmpty)
                        Expanded(
                          child: Text(
                            time,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.rubik(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDurationBreakdown(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.durationBreakdownItems.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
        itemBuilder: (context, index) {
          final item = controller.durationBreakdownItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.rubik(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
                Text(
                  item.value,
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _driverDetails(
    BuildContext context,
    String? image,
    String? name,
    String? countryCode,
    String? phone,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                "lib/assets/images/Delivery.png",
                width: 18,
                height: 18,
                color: const Color(0xFFFF5216),
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context).driverDetails,
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  ApiConfigs.IMAGE_URL + image!,
                  // Placeholder for driver avatar
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name!,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.of(context).assignedDeliveryPartner,
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: Color(0xFFFF5216),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    countryCode! + " " + phone!,
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),

              InkWell(
                onTap: () {
                  launchUrl(Uri.parse("tel:" + countryCode + phone));
                },

                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
