import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';

import 'package:saimpex_vendor/controller/restaurant_details_controller.dart';
import '../../generated/l10n.dart';
import '../../model/restaurant_items_model.dart';
import '../../resources/colors.dart';

class ItemCustomizationBottomSheet extends StatelessWidget {
  const ItemCustomizationBottomSheet({
    super.key,
    required this.data,
    required this.productName,
    required this.image,
  });

  final List<ItemVariant>? data;
  final String productName;
  final String image;

  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;

    return Directionality(
      textDirection: localization.currentLocale!.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: GetBuilder<RestaurantDetailsController>(
        init: RestaurantDetailsController(),
        didChangeDependencies: (state) {
          // Initialize selectedVariantPrice if data exists and not yet initialized
          if (data != null &&
              data!.isNotEmpty &&
              state.controller!.selectedVariantPrice == 0 &&
              state.controller!.selectedPortion == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final variant = data![0];
              String priceStr = _getEffectivePrice(variant);
              double price = double.tryParse(priceStr) ?? 0;
              if (price > 0) {
                state.controller!.selectedVariantPrice = price;
                state.controller!.getTotalPrice();
              }
            });
          }
        },
        builder: (controller) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            // child: CachedNetworkImage(
                            //   imageUrl: image.toString(),
                            //   height: 45,
                            //   width: 45,
                            //   fit: BoxFit.cover,
                            //   errorWidget: (context, url, error) => Image.asset(
                            //     'lib/assets/images/logo.png',
                            //     fit: BoxFit.contain,
                            //   ),
                            // ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            productName.toString(),
                            style: appFont('Rubik', 
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Divider(height: 1, thickness: 2, color: boxColor),
                    const SizedBox(height: 15),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).quantity,
                              style: appFont('Rubik', 
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Card(
                              elevation: 1,
                              color: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              margin: EdgeInsets.zero,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: data != null && data!.isNotEmpty
                                    ? ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: data!.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 15),
                                        itemBuilder: (context, index) {
                                          final variant = data![index];
                                          final localization =
                                              FlutterLocalization.instance;

                                          // Get localized variant name
                                          String variantName =
                                              variant.variantNameEn ?? "";
                                          if (localization
                                                  .currentLocale!
                                                  .languageCode ==
                                              "ar") {
                                            variantName =
                                                variant.variantNameAr ??
                                                variant.variantNameEn ??
                                                "";
                                          } else if (localization
                                                  .currentLocale!
                                                  .languageCode ==
                                              "fr") {
                                            variantName =
                                                variant.variantNameFr ??
                                                variant.variantNameEn ??
                                                "";
                                          }

                                          String priceStr = _getEffectivePrice(
                                            variant,
                                          );
                                          double price =
                                              double.tryParse(priceStr) ?? 0;

                                          return _portionTile(
                                            label: variantName,
                                            price: "$priceStr MRU",
                                            selected:
                                                controller.selectedPortion ==
                                                index,
                                            onTap: () {
                                              controller.selectedPortion =
                                                  index;
                                              controller.selectedVariantPrice =
                                                  price;
                                              controller.getTotalPrice();
                                            },
                                          );
                                        },
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Quantity Stepper
                          Card(
                            elevation: 3,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (controller.qty > 1) {
                                        controller.qty--;
                                        controller.getTotalPrice();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.remove,
                                      color: colorPrimary,
                                    ),
                                  ),
                                  Text(
                                    controller.qty.toString(),
                                    style: appFont('Rubik', 
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: colorPrimary,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      controller.qty++;
                                      controller.getTotalPrice();
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: colorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Add Item Button
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                controller.addToRestaurantCart(
                                  context,
                                  controller.restaurantId.toString(),
                                  data![controller.selectedPortion].itemId
                                      .toString(),
                                  controller.qty.toString(),
                                );
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colorPrimary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    "${S.of(context).addItem} | ${controller.totalPrice} MRU",
                                    style: appFont('Rubik', 
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper method to get effective price: discountPrice if available and valid, otherwise price
  String _getEffectivePrice(ItemVariant variant) {
    // Use discountPrice if it exists, is not empty, and is not "0"
    if (variant.discountPrice != null &&
        variant.discountPrice!.isNotEmpty &&
        variant.discountPrice != "0") {
      return variant.discountPrice!;
    }
    // Otherwise use regular price
    return variant.price ?? "0";
  }

  Widget _portionTile({
    required String label,
    required String price,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: appFont('Rubik', fontSize: 14, fontWeight: FontWeight.w400),
          ),
          Row(
            children: [
              Text(
                price,
                style: appFont('Rubik', 
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colorPrimary : Colors.grey,
                    width: 1.5,
                  ),
                  color: selected ? colorPrimary : Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
