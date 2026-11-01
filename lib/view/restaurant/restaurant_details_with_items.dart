import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/utils/utils.dart';
// import 'package:saimpex_vendor/utils/widgets/delete_cart_dialog.dart';
import 'package:saimpex_vendor/view/login/login.dart';
import 'package:saimpex_vendor/view/login/widgets/login_to_continue_alert_dialogue.dart';
import '../../controller/restaurant_details_controller.dart';
import '../../generated/l10n.dart';
import '../../resources/colors.dart';
// import '../../utils/widgets/food_product_item.dart';
import '../../utils/widgets/no_data_widget.dart';
import '../../utils/widgets/restaurant_details_widget.dart';
import '../../utils/widgets/restaurant_items_filter_bottom_sheet.dart';
import 'package:saimpex_vendor/utils/widgets/custom_search_box.dart';
import '../shimmer_loading/shimmer_food_product_item.dart';
import '../../utils/widgets/app_loader.dart';

class RestaurantDetailsWithItems extends StatefulWidget {
  const RestaurantDetailsWithItems({
    super.key,
    required this.restaurantId,
    // required this.name,
    // required this.rating,
    // required this.preparationTime,
    // required this.distance,
    // required this.offer,
    required this.categoryId,
    this.barcodeScannedName,
    this.barcodeScannedRestaurantId,
  });

  final String restaurantId;
  final String? barcodeScannedName;
  final String? barcodeScannedRestaurantId;

  // final String name;
  // final String rating;
  // final String preparationTime;
  // final String distance;
  // final String offer;
  final String categoryId;

  @override
  State<RestaurantDetailsWithItems> createState() =>
      _RestaurantDetailsWithItemsState();
}

class _RestaurantDetailsWithItemsState extends State<RestaurantDetailsWithItems>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;

    return Directionality(
      textDirection: localization.currentLocale!.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,

        body: GetBuilder<RestaurantDetailsController>(
          init: RestaurantDetailsController(),
          didChangeDependencies: (state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (widget.barcodeScannedName != null &&
                  widget.barcodeScannedRestaurantId != null) {
                state.controller!.searchController.text =
                    widget.barcodeScannedName!;
                state.controller!.restaurantId =
                    widget.barcodeScannedRestaurantId!;
                state.controller!.categoryId = widget.categoryId;
                state.controller!.getRestaurantItems();
                state.controller!.fetchRestaurantDetails(
                  context,
                  widget.restaurantId,
                );
                state.controller!.getCartCount(context);
              } else {
                state.controller!.restaurantId = widget.restaurantId;
                state.controller!.categoryId = widget.categoryId;
                state.controller!.fetchRestaurantDetails(
                  context,
                  widget.restaurantId,
                );
                state.controller!.getRestaurantItems();
                state.controller!.getCartCount(context);
              }
            });
          },
          builder: (controller) {
            // Check if cart has items and animate bottom bar accordingly
            bool hasCartItems =
                controller.currentCartItemsCount != "0" &&
                controller.currentCartItemsCount.isNotEmpty;

            if (hasCartItems) {
              // Show animation when cart has items
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_animationController.status != AnimationStatus.completed) {
                  _animationController.forward();
                }
              });
            } else {
              // Hide animation when cart is empty
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_animationController.status != AnimationStatus.dismissed) {
                  _animationController.reverse();
                }
              });
            }
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("lib/assets/images/resbg.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                _buildContent(
                  context,
                  widget.restaurantId,
                  widget.categoryId,
                  hasCartItems,
                  controller,
                ),
                if (hasCartItems)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildCartBottomBar(controller, context),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildContent(
  BuildContext context,
  String restaurantId,
  String categoryId,
  bool hasCartItems,
  RestaurantDetailsController controller,
) {
  final FlutterLocalization localization = FlutterLocalization.instance;
  final langCode = localization.currentLocale?.languageCode ?? 'en';

  // Get localized item name
  String name = "";
  if (controller.restaurantData != null) {
    name = langCode == 'en'
        ? controller.restaurantData!.nameEn ?? ''
        : langCode == 'ar'
        ? controller.restaurantData!.nameAr ??
              controller.restaurantData!.nameEn ??
              ''
        : controller.restaurantData!.nameFr ??
              controller.restaurantData!.nameEn ??
              '';
  }

  return GetBuilder<RestaurantDetailsController>(
    init: RestaurantDetailsController(),
    builder: (controller) {
      return SafeArea(
        child: controller.restaurantData == null
            ? Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Center(child: AppLoader(size: 40)),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: _buildShimmerGrid(),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RestaurantDetailsWidget(
                      restaurantName: name,
                      rating: controller.restaurantData!.rating.toString(),
                      time: controller.restaurantData!.preparationTime
                          .toString(),
                      distance: controller.restaurantData!.distanceKm
                          .toString(),
                      offerText: controller.restaurantData!.offerPercentage
                          .toString(),
                      onChatNow: () async {
                        var token = await getSavedObject("token");
                        if (token.toString() == "null" ||
                            token.toString() == "") {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black54,
                            builder: (context) => Dialog(
                              insetPadding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.25,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: LoginToContinueAlertDialogue(
                                onCancel: () {
                                  Navigator.pop(context);
                                },
                                onDelete: () {
                                  Navigator.pop(context);
                                  Get.offAll(LoginScreen());
                                },
                              ),
                            ),
                          );
                        } else {
                          // Get.to(
                          //   ChatDetails(vendorId: int.parse(restaurantId)),
                          // );
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: CustomSearchBox(
                          controller: controller.searchController,
                          onChanged: (value) {
                            controller.searchController.text = value;
                            controller.getRestaurantItems();
                          },
                          hintText: S
                              .of(context)
                              .findSomethingFromThisRestaurant,
                          boxColor: Colors.white,
                          width: MediaQuery.of(context).size.width * 0.75,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      height: 45,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.filterCategories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 5),
                        itemBuilder: (context, index) {
                          // Check if filter button should have red border (any bottom sheet filter selected)
                          bool isFilterButtonSelected =
                              index == 0 && controller.hasBottomSheetFilters();

                          // Check if veg is selected (index 2)
                          bool isVegSelected =
                              index == 2 && controller.veg.isNotEmpty;

                          // Check if non_veg is selected (index 1)
                          bool isNonVegSelected =
                              index == 1 && controller.nonVeg.isNotEmpty;

                          // Check if offers is selected (index 3)
                          bool isOffersSelected =
                              index == 3 && controller.offers.isNotEmpty;

                          // Determine if this card should have red border
                          bool hasRedBorder =
                              isFilterButtonSelected ||
                              isVegSelected ||
                              isNonVegSelected ||
                              isOffersSelected;

                          // Determine if close icon should be shown (not for filter button)
                          bool showCloseIcon =
                              (isVegSelected ||
                              isNonVegSelected ||
                              isOffersSelected);

                          return InkWell(
                            onTap: () {
                              if (index == 0) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor:
                                      Colors.transparent, // IMPORTANT
                                  builder: (context) {
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24),
                                            ),
                                          ),
                                          padding: const EdgeInsets.only(
                                            top: 40,
                                          ),
                                          child:
                                              const RestaurantItemsFilterBottomSheet(),
                                        ),

                                        Positioned(
                                          top: -50,
                                          right:
                                              MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  2 -
                                              20,
                                          child: GestureDetector(
                                            onTap: () => Get.back(),
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.65,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.15),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else if (index == 1) {
                                controller.nonVeg = "1";
                                controller.getRestaurantItems();
                              } else if (index == 2) {
                                controller.veg = "1";
                                controller.getRestaurantItems();
                              } else {
                                controller.selectOffersFromList();
                              }
                            },
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  // Red border when selected
                                  border: hasRedBorder
                                      ? Border.all(color: Colors.red, width: 1)
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    index == 0
                                        ? Image.asset(
                                            'lib/assets/images/filter.png',
                                          )
                                        : index == 1
                                        ? Image.asset(
                                            'lib/assets/images/red_dot.png',
                                          )
                                        : index == 2
                                        ? Image.asset(
                                            'lib/assets/images/green_dot.png',
                                          )
                                        : Container(),
                                    const SizedBox(width: 6),

                                    Text(
                                      controller.filterCategories[index],
                                      style: appFont('Rubik', 
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    // Close icon for veg, non_veg, offers (not for filter)
                                    if (showCloseIcon) const SizedBox(width: 6),
                                    if (showCloseIcon)
                                      GestureDetector(
                                        onTap: () {
                                          if (index == 1) {
                                            // Clear non_veg
                                            controller.clearNonVegFilter();
                                          } else if (index == 2) {
                                            // Clear veg
                                            controller.clearVegFilter();
                                          } else if (index == 3) {
                                            // Clear offers
                                            controller.clearOffersFilter();
                                          }
                                        },
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).allItemsFromThisRestaurant,
                      style: appFont('Rubik', 
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),
                    controller.isFirstLoadRunning
                        ? Expanded(child: _buildShimmerGrid())
                        : Expanded(
                            child: controller.restaurantItemsList.length == 0
                                ? NoDataWidget(
                                    context,
                                    S.of(context).noItemsFound,
                                    S
                                        .of(context)
                                        .currentlyNoItemsFoundPleaseTryLater,
                                    "lib/assets/images/nodata.png",
                                  )
                                : Column(
                                    children: [
                                      Expanded(
                                        child: GridView.builder(
                                          controller:
                                              controller.scrollController,
                                          shrinkWrap: true,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          padding: EdgeInsets.only(
                                            bottom: hasCartItems ? 90 : 0,
                                          ),
                                          itemCount: controller
                                              .restaurantItemsList
                                              .length,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                mainAxisSpacing: 3,
                                                crossAxisSpacing: 3,
                                                childAspectRatio: 0.68,
                                              ),
                                          itemBuilder: (context, index) {
                                            // final item = controller
                                            //     .restaurantItemsList[index];
                                            // return FoodProductItem(
                                            //   item: item,
                                            //   cartItems: controller
                                            //       .data!
                                            //       .data!
                                            //       .cartItems,
                                            // );
                                            return const SizedBox();
                                          },
                                        ),
                                      ),
                                      if (controller.isLoadMoreRunning == true)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 10,
                                            bottom: hasCartItems ? 100 : 10,
                                          ),
                                          child: const Center(
                                            child: AppLoader(size: 40),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                    // controller.cartItems.isEmpty
                    //     ? SizedBox()
                    //     : const SizedBox(height: 65),
                  ],
                ),
              ),
      );
    },
  );
}

Widget _buildCartBottomBar(
  RestaurantDetailsController controller,
  BuildContext context,
) {
  // Check if cart has items using API data
  if (controller.currentCartItemsCount == "0" ||
      controller.currentCartItemsCount.isEmpty) {
    return const SizedBox.shrink();
  }
  final FlutterLocalization localization = FlutterLocalization.instance;
  final langCode = localization.currentLocale?.languageCode ?? 'en';
  String name = "";
  if (controller.restaurantData != null) {
    name = langCode == 'en'
        ? controller.restaurantData!.nameEn ?? ''
        : langCode == 'ar'
        ? controller.restaurantData!.nameAr ??
              controller.restaurantData!.nameEn ??
              ''
        : controller.restaurantData!.nameFr ??
              controller.restaurantData!.nameEn ??
              '';
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(22),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: Row(
      children: [
        // RESTAURANT IMAGE
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: CachedNetworkImage(
            imageUrl: controller.vendorImage.toString(),
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.height * 0.05,
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
              "lib/assets/images/logo.png",
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.height * 0.05,
              fit: BoxFit.cover,
            ),
            errorWidget: (context, url, error) => Image.asset(
              "lib/assets/images/logo.png",
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.height * 0.05,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(width: 10),

        // RESTAURANT NAME (from API)
        Expanded(
          flex: 3,
          child: Text(
            controller.vendorName.isNotEmpty ? controller.vendorName : name,
            style: appFont('Rubik', fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        Expanded(
          flex: 5,
          child: Row(
            children: [
              InkWell(
                // onTap: () {
                //   // Navigate to cart or checkout
                //   // Get.to(FoodCart(route: "restaurant"))!.then((value) {
                //   //   // Refresh cart count
                //   //   controller.getCartCount(context);
                //   // }
                //   // );
                // },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${controller.currentCartItemsCount} ${S.of(context).item} | ${controller.currentCartTotal} MRU",
                        style: appFont('Rubik', 
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        S.of(context).checkout,
                        style: appFont('Rubik', 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Handle cart deletion/clear
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    // builder: (_) => DeleteCartDialog(route: "restaurant"),
                    builder: (_) => const SizedBox.shrink(),
                  );
                },
                child: Image.asset(
                  'lib/assets/images/delete_cart.png',
                  height: MediaQuery.of(context).size.height * 0.03,
                  width: MediaQuery.of(context).size.height * 0.03,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildShimmerGrid() {
  return GridView.builder(
    shrinkWrap: true,
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: 8,
    // Show 8 shimmer items
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.8,
    ),
    itemBuilder: (context, index) {
      return ShimmerFoodProductItem();
    },
  );
}
