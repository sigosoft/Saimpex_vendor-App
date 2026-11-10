import 'dart:math' as math;
import 'package:saimpex_vendor/utils/vendor_words.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:saimpex_vendor/utils/payment_type.dart';
import 'package:saimpex_vendor/controller/preorders_controller.dart';
import 'package:saimpex_vendor/view/home/widgets/preorder_badge.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/utils/widgets/dotted_line_painter.dart';
// ignore: unused_import — success_dialog is used indirectly via utils
import 'package:saimpex_vendor/utils/widgets/success_dialog.dart';
import 'package:saimpex_vendor/view/shimmer_loading/shimmer_text_content.dart';
import 'package:saimpex_vendor/utils/printing/order_print_service.dart';

import '../../configs/ApiConfigs.dart';
import '../../controller/order_details_controller.dart';
import '../../generated/l10n.dart';
// ignore: unused_import
import '../../model/OrderDetailsModel.dart';
import '../../utils/widgets/custom_app_bar.dart';
import '../../utils/order_fulfillment.dart';
import '../../utils/utils.dart';
import '../../utils/widgets/no_data_widget.dart';
import '../../controller/chat_controller.dart';
import '../chat/ChatDetails.dart';
import 'widgets/customer_voice_note_widget.dart';
import 'widgets/order_fulfillment_badge.dart';
import 'widgets/vendor_reject_order_sheet.dart';
import 'substitution/order_substitutions.dart';

class VendorOrderDetails extends StatefulWidget {
  final String orderId;
  final String? orderType;

  const VendorOrderDetails({super.key, required this.orderId, this.orderType});

  @override
  State<VendorOrderDetails> createState() => _VendorOrderDetailsState();
}

class _VendorOrderDetailsState extends State<VendorOrderDetails> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  // Order details carry no scheduled_for; pre-orders come from GET preorders.
  final PreordersController _preorders =
      Get.isRegistered<PreordersController>()
          ? Get.find<PreordersController>()
          : Get.put(PreordersController());

  // Grocery substitution per line (§6.11, task V2); latest proposal per line.
  bool _isGrocery = false;
  Map<int, Substitution> _subs = {};

  Future<void> _loadSubstitutions() async {
    try {
      final r = await const SubstitutionApi().list(widget.orderId);
      if (mounted) setState(() => _subs = latestByLine(r.items));
    } catch (e) {
      debugPrint('substitutions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (_preorders.forOrder(widget.orderId) == null) {
      _preorders.fetch().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Widget _scheduledFor(DateTime time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: preorderTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 16, color: preorderColor),
          const SizedBox(width: 6),
          Text(
            '${S.of(context).scheduledForTime(formatPreorderTime(time))} · '
            '${preorderDueText(time)}',
            style: appFont('Rubik', 
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: preorderColor,
            ),
          ),
        ],
      ),
    );
  }

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
            _isGrocery = true;
            _loadSubstitutions();
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
                                              Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                spacing: 8,
                                                runSpacing: 4,
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
                                                    style: appFont('Rubik', 
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: colorPrimary,
                                                    ),
                                                  ),
                                                  OrderFulfillmentBadge(
                                                    deliveryType: controller
                                                        .orderData
                                                        ?.deliveryType,
                                                    isSelfPickup: controller
                                                        .orderData
                                                        ?.isSelfPickup,
                                                    isExpress: controller
                                                            .orderData
                                                            ?.isExpress ??
                                                        false,
                                                  ),
                                                ],
                                              ),
                                              if (_preorders.forOrder(
                                                    widget.orderId,
                                                  ) !=
                                                  null) ...[
                                                const SizedBox(height: 8),
                                                _scheduledFor(
                                                  _preorders
                                                      .forOrder(widget.orderId)!
                                                      .scheduledFor,
                                                ),
                                              ],
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
                                                    S.of(context).rsBasketOrder,
                                                    style: appFont('Rubik', 
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
                                                ? reachedVendorLabel()
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
                                            style: appFont('Rubik', 
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
                                            style: appFont('Rubik', 
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
                                        //     style: appFont('Rubik', 
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
                                          S.of(context).items.toUpperCase(),
                                          ((int n) => "$n ${n == 1 ? S.of(context).item : S.of(context).items}")((isBasketOrder
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
                                                            0)))
                                                  +
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
                                      style: appFont('Rubik', 
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
                                            style: appFont('Rubik', 
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
                                    // Figma: "Chat with Customer" under the
                                    // address, on every status.
                                    if (controller.orderData?.userId != null) ...[
                                      const SizedBox(height: 14),
                                      _chatWithCustomerButton(
                                        controller.orderData!.userId!,
                                        controller.orderData?.userName,
                                      ),
                                    ],
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
                              // Edit Items sits above the item list: at the end of the list it
                              // was right above the identical full-width "Accept & Print" in the
                              // bottom bar, and a tap there accepted the order (VA-14).
                              if (!isBasketOrder)
                                _editItemsButton(controller),
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
                                style: appFont('Rubik', 
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
                                    final names = item.orderItem;
                                    final tile = _itemTile(
                                      item.image?.toString() ?? '',
                                      langCode == "ar"
                                          ? (names?.nameAr ?? names?.nameEn ?? '')
                                          : langCode == "fr"
                                          ? (names?.nameFr ?? names?.nameEn ?? '')
                                          : (names?.nameEn ?? ''),
                                      double.tryParse(
                                            item.unitPrice?.toString() ?? '',
                                          ) ??
                                          0,
                                      item.quantity ?? 0,
                                      context,
                                    );
                                    final sub = _subs[item.orderItemId];
                                    if (sub == null) return tile;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        tile,
                                        SubstitutionSummary(
                                          key: ValueKey('sub-${sub.id}'),
                                          sub: sub,
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),

                              Builder(
                                builder: (context) {
                                  final audioUrl = controller
                                      .orderData
                                      ?.customerAudioNoteUrl;
                                  final textNote =
                                      controller.orderData?.customerTextNote;
                                  final bool hasAudio =
                                      audioUrl != null && audioUrl.isNotEmpty;
                                  final bool hasText =
                                      textNote != null && textNote.isNotEmpty;

                                  if (!hasAudio && !hasText) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 30),
                                      Text(
                                        S.of(context).customerNotes,
                                        style: appFont('Rubik', 
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (hasAudio)
                                        CustomerVoiceNoteWidget(
                                          audioUrl: audioUrl!,
                                        ),
                                      if (hasAudio && hasText)
                                        const SizedBox(height: 12),
                                      if (hasText)
                                        Container(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.95,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFBEB),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                                  textNote!,
                                                  style: const TextStyle(
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
                                    ],
                                  );
                                },
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
                                  style: appFont('Rubik', 
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
                                        paymentTypeLabel(
                                          controller.orderData!.paymentType,
                                        ),
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
                                              style: appFont('Rubik', 
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
                                              style: appFont('Rubik', 
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
                                  _logTime(controller.orderData!, 1, 0),
                                  isCompleted: true,
                                  isFirst: true,
                                ),
                                _timelineItem(
                                  S.of(context).orderAccepted,
                                  S.of(context).orderAccepted,
                                  controller.orderData!.status! >= 2
                                      ? _logTime(controller.orderData!, 2, 1)
                                      : "",
                                  isCompleted:
                                      controller.orderData!.status! >= 2
                                      ? true
                                      : false,
                                ),
                                _timelineItem(
                                  // Grocery said "Preparing Food" (V18).
                                  _isGrocery
                                      ? S.of(context).preparingOrder
                                      : S.of(context).preparingFood,
                                  S.of(context).orderPreparationStarted,
                                  controller.orderData!.status! >= 3
                                      ? _logTime(controller.orderData!, 3, 2)
                                      : "",
                                  isCompleted:
                                      controller.orderData!.status! >= 3,
                                  asset: "lib/assets/images/Preparing food.png",
                                ),
                                // Figma: a pickup order ends Ready for Pickup →
                                // Picked Up; a delivery order goes Delivery
                                // Partner Accepted → Reached Restaurant →
                                // Order Delivered (one list was shown for both).
                                if (OrderFulfillment.isSelfPickupFrom(
                                  deliveryType:
                                      controller.orderData?.deliveryType,
                                  isSelfPickup:
                                      controller.orderData?.isSelfPickup,
                                )) ...[
                                  _timelineItem(
                                    S.of(context).waterReadyForPickup,
                                    S.of(context).orderReady,
                                    controller.orderData!.status! >= 4
                                        ? _logTime(controller.orderData!, 4, 3)
                                        : "",
                                    isCompleted:
                                        controller.orderData!.status! >= 4,
                                    asset: "lib/assets/images/Delivery.png",
                                  ),
                                  _timelineItem(
                                    S.of(context).waterPickedUpByCustomer,
                                    S.of(context).orderPickedUp,
                                    controller.orderData!.status! >= 9
                                        ? _logTime(controller.orderData!, 9, 4)
                                        : "",
                                    isCompleted:
                                        controller.orderData!.status! >= 9,
                                    asset:
                                        "lib/assets/images/Order delivered.png",
                                    isLast: true,
                                  ),
                                ] else ...[
                                  _timelineItem(
                                    S.of(context).deliveryPartnerAccepted,
                                    S.of(context).deliveryPartnerAcceptedSub,
                                    controller.orderData!.status! >= 5
                                        ? _logTime(controller.orderData!, 5, 3)
                                        : "",
                                    isCompleted:
                                        controller.orderData!.status! >= 5,
                                    asset: "lib/assets/images/Delivery.png",
                                  ),
                                  _timelineItem(
                                    S.of(context).reachedRestaurantTitle,
                                    S.of(context).reachedRestaurantSub,
                                    controller.orderData!.status! >= 6
                                        ? _logTime(controller.orderData!, 6, 4)
                                        : "",
                                    isCompleted:
                                        controller.orderData!.status! >= 6,
                                    asset:
                                        "lib/assets/images/Reached Restaurant.png",
                                  ),
                                  _timelineItem(
                                    S.of(context).waterOrderDelivered,
                                    S.of(context).deliveryCompleted,
                                    controller.orderData!.status! >= 9
                                        ? _logTime(controller.orderData!, 9, 5)
                                        : "",
                                    asset:
                                        "lib/assets/images/Order delivered.png",
                                    isCompleted:
                                        controller.orderData!.status! >= 9,
                                    isLast: true,
                                  ),
                                ],
                              ],
                              if (controller.selectedOrderTabIndex == 1) ...[
                                _buildOrderDurationBreakdown(
                                  context,
                                  controller,
                                ),
                              ],

                              // Spacing for bottom buttons, plus the system
                              // navigation bar the buttons now sit above
                              // (Edit Items was hidden behind them, V18).
                              SizedBox(
                                height:
                                    (_hasBottomActions(controller) ? 220 : 24) +
                                    MediaQuery.of(context).padding.bottom,
                              ),
                            ],
                          ),
                        ),
                ),
                // Bottom Buttons
                // Only when there is an action (new, accepted, preparing, or
                // ready for self pickup); delivered / cancelled orders showed an
                // empty white bar.
                controller.orderData == null || !_hasBottomActions(controller)
                    ? Container()
                    : Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          // Edge-to-edge Android draws the body under the
                          // system navigation bar; keep the buttons above it.
                          padding: EdgeInsets.fromLTRB(
                            20,
                            20,
                            20,
                            math.max(
                              30,
                              16 + MediaQuery.of(context).padding.bottom,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: controller.orderData!.status.toString() == '1'
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 40,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                String vendorType =
                                                    await getSavedObject(
                                                      "vendorType",
                                                    ) ??
                                                    "0";
                                                final isRestaurant =
                                                    vendorType == "1";
                                                final selectedReason =
                                                    await showVendorRejectOrderSheet(
                                                      context,
                                                      isRestaurant:
                                                          isRestaurant,
                                                    );
                                                if (selectedReason != null &&
                                                    context.mounted) {
                                                  if (isRestaurant) {
                                                    controller
                                                        .cancelRestaurantOrder(
                                                          context,
                                                          widget.orderId,
                                                          reason:
                                                              selectedReason,
                                                        );
                                                  } else {
                                                    controller
                                                        .cancelGroceryOrder(
                                                          context,
                                                          widget.orderId,
                                                          reason:
                                                              selectedReason,
                                                        );
                                                  }
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
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                    ),
                                              ),
                                              child: Text(
                                                S.of(context).reject,
                                                style: appFont('Rubik', 
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: SizedBox(
                                            height: 40,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                String vendorType =
                                                    await getSavedObject(
                                                      "vendorType",
                                                    );
                                                // The bar already offers Accept & Print: accept at once, no
                                                // second Accept / Accept & Print / Cancel dialog (VA-04).
                                                    if (vendorType == "1") {
                                                      controller
                                                          .acceptRestaurantOrder(
                                                            context,
                                                            widget.orderId,
                                                          );
                                                    } else {
                                                      controller
                                                          .acceptGroceryOrder(
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
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                    ),
                                              ),
                                              child: Text(
                                                S.of(context).acceptOrder,
                                                style: appFont('Rubik', 
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          String vendorType =
                                              await getSavedObject(
                                                "vendorType",
                                              );
                                          if (vendorType == "1") {
                                            controller.acceptRestaurantOrder(
                                              context,
                                              widget.orderId,
                                              printAfter: true,
                                            );
                                          } else {
                                            controller.acceptGroceryOrder(
                                              context,
                                              widget.orderId,
                                              printAfter: true,
                                            );
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFFFF5216),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          S.of(context).acceptAndPrint,
                                          style: appFont('Rubik', 
                                            color: const Color(0xFFFF5216),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : controller.orderData!.status.toString() == '2'
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            try {
                                              await OrderPrintService()
                                                  .printOrder(
                                                    orderId: widget.orderId,
                                                    orderType: widget.orderType,
                                                  );
                                            } catch (e) {
                                              debugPrint("Print error: $e");
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFFFF5216),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            S.of(context).printOrder,
                                            style: appFont('Rubik', 
                                              color: const Color(0xFFFF5216),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            String vendorType =
                                                await getSavedObject(
                                                  "vendorType",
                                                );
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
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFFF5216,
                                            ),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            S.of(context).prepareOrder,
                                            style: appFont('Rubik', 
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : controller.orderData!.status.toString() == '3'
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 40,
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                try {
                                                  await OrderPrintService()
                                                      .printOrder(
                                                        orderId: widget.orderId,
                                                        orderType:
                                                            widget.orderType,
                                                      );
                                                } catch (e) {
                                                  debugPrint("Print error: $e");
                                                }
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Color(0xFFFF5216),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                S.of(context).printOrder,
                                                style: appFont('Rubik', 
                                                  color: const Color(
                                                    0xFFFF5216,
                                                  ),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: SizedBox(
                                            height: 40,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                String vendorType =
                                                    await getSavedObject(
                                                      "vendorType",
                                                    );
                                                if (vendorType == "1") {
                                                  controller
                                                      .markAsReadyRestaurantOrder(
                                                        context,
                                                        widget.orderId,
                                                      );
                                                } else {
                                                  controller
                                                      .markAsReadyGroceryOrder(
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
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                S.of(context).markAsReady,
                                                style: appFont('Rubik', 
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : controller.orderData!.status.toString() ==
                                        '4' &&
                                    OrderFulfillment.isSelfPickupFrom(
                                      deliveryType:
                                          controller.orderData?.deliveryType,
                                      isSelfPickup:
                                          controller.orderData?.isSelfPickup,
                                    )
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            try {
                                              await OrderPrintService()
                                                  .printOrder(
                                                    orderId: widget.orderId,
                                                    orderType: widget.orderType,
                                                  );
                                            } catch (e) {
                                              debugPrint("Print error: $e");
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFFFF5216),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            S.of(context).printOrder,
                                            style: appFont('Rubik', 
                                              color: const Color(0xFFFF5216),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            controller.markSelfPickupCompleted(
                                              context,
                                              widget.orderId,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFFF5216,
                                            ),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            S
                                                .of(context)
                                                .markSelfPickupCompleted,
                                            textAlign: TextAlign.center,
                                            style: appFont('Rubik', 
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Same statuses as the bottom bar's buttons below.
  bool _hasBottomActions(OrderDetailsController controller) {
    final status = controller.orderData?.status.toString();
    if (status == '1' || status == '2' || status == '3') return true;
    return status == '4' &&
        OrderFulfillment.isSelfPickupFrom(
          deliveryType: controller.orderData?.deliveryType,
          isSelfPickup: controller.orderData?.isSelfPickup,
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
          style: appFont('Rubik', 
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: appFont('Rubik', 
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

  /// "Edit Items" (Figma 9249:21918): grocery orders before Ready only;
  /// the server rejects substitutions from Ready (status 4) on.
  Widget _editItemsButton(OrderDetailsController controller) {
    final status = controller.orderData?.status ?? 0;
    final items = controller.orderData?.orderItems ?? const <OrderItem>[];
    if (!_isGrocery ||
        status < 1 ||
        status > 3 ||
        items.isEmpty ||
        items.any((i) => i.orderItemId == null)) {
      return const SizedBox.shrink();
    }
    final lines = _substitutionLines(items);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorPrimary,
          side: const BorderSide(color: colorPrimary),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.swap_horiz),
        label: Text(S.of(context).substitutionEditItems),
        onPressed: () async {
          await Get.to(
            () => EditItemsView(
              orderId: widget.orderId,
              lines: lines,
              // Fresh lines after the customer answers (a substitute
              // replaces the line, a removed item drops to 0).
              reloadLines: () async {
                await controller.getGroceryOrderDetails(
                  context,
                  widget.orderId,
                );
                return _substitutionLines(
                  controller.orderData?.orderItems ?? const <OrderItem>[],
                );
              },
              refreshSignals: FirebaseMessaging.onMessage,
            ),
          );
          if (!mounted) return;
          _loadSubstitutions();
          controller.getGroceryOrderDetails(context, widget.orderId);
        },
      ),
    );
  }

  List<SubstitutionLine> _substitutionLines(List<OrderItem> items) {
    final lang = localization.currentLocale?.languageCode ?? 'en';
    return [
      for (final i in items)
        if (i.orderItemId != null)
          SubstitutionLine(
            orderItemId: i.orderItemId!,
            productId: i.productId ?? 0,
            name:
                (lang == 'ar'
                    ? i.orderItem?.nameAr
                    : lang == 'fr'
                    ? i.orderItem?.nameFr
                    : i.orderItem?.nameEn) ??
                i.orderItem?.nameEn ??
                '',
            nameEn: i.orderItem?.nameEn ?? '',
            image: '${i.image ?? ''}',
            unitPrice: double.tryParse('${i.unitPrice}') ?? 0,
            quantity: i.quantity ?? 0,
          ),
    ];
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
                  style: appFont('Rubik', 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                if (showPrice) ...[
                  const SizedBox(height: 4),
                  Text(
                    "${price.toStringAsFixed(2)} MRU",
                    style: appFont('Rubik', 
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
              style: appFont('Rubik', 
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
          style: appFont('Rubik', 
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: const Color(0xFF4B5563),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: appFont('Rubik', 
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

  /// Time of the status log for [status]. Logs were read by position, which
  /// threw (blank grey screen, test day V-B1) when an order had fewer logs
  /// than its status implies; falls back to the position, then to "".
  // A raw server time (UTC, no offset) is shown in phone time and the app
  // language; text the server already formatted is shown as it is.
  String _logTime(Data order, int status, int index) {
    final logs = order.statusLogs ?? const <StatusLog>[];
    for (final log in logs) {
      if (log.status == status) return formatServerDateTime(log.updatedAt);
    }
    if (index < logs.length) return formatServerDateTime(logs[index].updatedAt);
    return '';
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
                        style: appFont('Rubik', 
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
                            style: appFont('Rubik', 
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
                    style: appFont('Rubik', 
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
                    style: appFont('Rubik', 
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
                Text(
                  item.value,
                  style: appFont('Rubik', 
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

  /// "+222 12345678" from the driver's country code and phone.
  String _dialNumber(String? countryCode, String phone) {
    final cc = (countryCode ?? '').trim();
    final p = phone.trim();
    if (cc.isEmpty || cc == 'null' || p.startsWith('+')) return p;
    return '${cc.startsWith('+') ? cc : '+$cc'} $p';
  }

  /// Opens the vendor's chat with this order's customer (lib/view/chat).
  /// The server keeps one conversation per vendor and customer
  /// (chat/sendMessage firstOrCreate), so an existing one is reopened.
  Widget _chatWithCustomerButton(int customerId, String? customerName) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () async {
          final chat = Get.isRegistered<ChatController>()
              ? Get.find<ChatController>()
              : Get.put(ChatController());
          if (chat.conversations.isEmpty) {
            await chat.getAllConversations(context, quiet: true);
          }
          final existing = chat.conversations.firstWhereOrNull(
            (c) => c.customerId == customerId || c.customer?.id == customerId,
          );
          final name = (customerName ?? '').trim();
          Get.to(
            () => ChatDetails(
              contactName: name.isNotEmpty && name != 'null'
                  ? name
                  : (existing?.customer?.name ?? S.of(context).unknown),
              conversationId: existing?.id ?? 0,
              customerId: customerId,
            ),
          );
        },
        icon: const Icon(
          Icons.chat_bubble_outline,
          size: 16,
          color: Colors.white,
        ),
        label: Text(
          S.of(context).waterChatWithCustomer,
          style: appFont('Rubik',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5216),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
                style: appFont('Rubik', 
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
                      style: appFont('Rubik', 
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.of(context).assignedDeliveryPartner,
                      style: appFont('Rubik', 
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Phone (tap to call) and, as in Figma, a WhatsApp button. Hidden
          // when the order detail sends no driver phone.
          if ((phone ?? '').trim().isNotEmpty && phone != 'null') ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => launchUrl(
                    Uri.parse("tel:${_dialNumber(countryCode, phone ?? "")}"),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: Color(0xFFFF5216),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _dialNumber(countryCode, phone ?? ""),
                        textDirection: TextDirection.ltr,
                        style: appFont('Rubik',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => launchUrl(
                    Uri.parse(
                      "https://wa.me/${_dialNumber(countryCode, phone ?? "").replaceAll(RegExp(r'[^0-9]'), '')}",
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
