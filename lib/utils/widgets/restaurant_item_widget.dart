import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:saimpex_vendor/resources/colors.dart';
// import 'package:saimpex_vendor/view/grocery/grocery_store_detail_page.dart';
// import '../../config/api_configs.dart';
import '../../generated/l10n.dart';
import '../../view/restaurant/restaurant_details.dart';
import '../utils.dart';

class RestaurantItemWidget extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String isOpen;
  final String openingTime;
  final bool isGrocery;
  final String rating;
  final String? preparationTime;
  final String distance;
  final String? offer;

  RestaurantItemWidget({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.isOpen,
    required this.openingTime,
    this.isGrocery = false,
    required this.rating,
    required this.preparationTime,
    required this.distance,
    required this.offer,
  });

  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: localization.currentLocale!.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: InkWell(
        onTap: () {
          if (isGrocery == true) {
            if (isOpen == "0") {
              openingTime.toString() == "null" || openingTime.toString() == ""
                  ? showToast(context, S.of(context).currentlyClosed)
                  : showToast(
                      context,
                      S.of(context).currentlyClosedOpens +
                          " " +
                          convertToAmPm(openingTime),
                    );
            } else {
              // Get.to(StoreDetailPage(groceryId: id));
            }
          } else {
            if (isOpen == "0") {
              openingTime.toString() == "null" || openingTime.toString() == ""
                  ? showToast(context, S.of(context).currentlyClosed)
                  : showToast(
                      context,
                      S.of(context).currentlyClosedOpens +
                          " " +
                          convertToAmPm(openingTime),
                    );
            } else {
              Get.to(
                RestaurantDetailsScreen(
                  restaurantId: id,
                  name: name,
                  rating: rating,
                  preparationTime: preparationTime ?? "0",
                  distance: distance,
                  offer: offer!,
                ),
              );
            }
          }
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Stack(
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                child: Container(
                  //margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      // IMAGE
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          // imageUrl: ApiConfigs.IMAGE_URL + imageUrl,
                          imageUrl: imageUrl,
                          height: MediaQuery.of(context).size.height * 0.2,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (context, url, error) => Image.asset(
                            'lib/assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // DETAILS
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NAME + RATING
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: appFont('Rubik', 
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                rating.toString() == "null" ||
                                        rating.toString() == "" ||
                                        rating.toString() == "0" ||
                                        double.tryParse(
                                              rating,
                                            )?.toStringAsFixed(1) ==
                                            "0.0"
                                    ? Container()
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: green,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: yellow,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              double.tryParse(
                                                    rating,
                                                  )?.toStringAsFixed(1) ??
                                                  "0.00",
                                              style: appFont('Rubik', 
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // TIME + DISTANCE
                            Row(
                              children: [
                                isGrocery
                                    ? Container()
                                    : Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: colorPrimary,
                                      ),
                                isGrocery
                                    ? Container()
                                    : const SizedBox(width: 4),
                                isGrocery
                                    ? Container()
                                    : preparationTime.toString() == "null" ||
                                          preparationTime.toString() == ""
                                    ? Text(
                                        "0 " + S.of(context).mins,
                                        style: appFont('Rubik', 
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      )
                                    : Text(
                                        preparationTime! +
                                            " " +
                                            S.of(context).mins,
                                        style: appFont('Rubik', 
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                isGrocery
                                    ? Container()
                                    : const SizedBox(width: 10),
                                isGrocery
                                    ? Container()
                                    : Container(
                                        width: 1,
                                        height: 15,
                                        color: Colors.grey,
                                      ),
                                isGrocery
                                    ? Container()
                                    : const SizedBox(width: 10),
                                Image.asset(
                                  'lib/assets/images/location_outlined.png',
                                  height: 15,
                                  width: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  double.tryParse(
                                        distance,
                                      )!.toStringAsFixed(2) +
                                      " " +
                                      S.of(context).km,
                                  style: appFont('Rubik', 
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // OFFER
                            offer.toString() == "null" || offer.toString() == ""
                                ? Container()
                                : Row(
                                    children: [
                                      Image.asset(
                                        'lib/assets/images/offer.png',
                                        height: 18,
                                        width: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        S.of(context).upto +
                                            " " +
                                            offer! +
                                            "% " +
                                            S.of(context).off,
                                        style: appFont('Rubik', 
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              isOpen.toString() == "0"
                  ? Positioned.fill(
                      child: Container(
                        margin: EdgeInsets.all(3),
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(top: 70),
                          child: Text(
                            openingTime.toString() == "null" ||
                                    openingTime.toString() == ""
                                ? S.of(context).currentlyClosed
                                : S.of(context).currentlyClosedOpens +
                                      " " +
                                      convertToAmPm(openingTime),
                            style: appFont('Rubik', 
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
