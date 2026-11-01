import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';

import '../../resources/colors.dart';
import '../../generated/l10n.dart';

class RestaurantDetailsWidget extends StatelessWidget {
  final String restaurantName;
  final String rating;
  final String time;
  final String distance;
  final String offerText;
  final VoidCallback onChatNow;
  final bool isGrocery;

  const RestaurantDetailsWidget({
    super.key,
    required this.restaurantName,
    required this.rating,
    required this.time,
    required this.distance,
    required this.offerText,
    required this.onChatNow,
    this.isGrocery = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 15,
          right: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    restaurantName,
                    style: appFont('Rubik', 
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Rating box
                rating.toString() == "null" ||
                    rating.toString() == "" ||
                    rating.toString() == "0" ||
                    double.tryParse(
                      rating,
                    )?.toStringAsFixed(1) ==
                        "0.0"
                    ? Container()
                    :
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: yellow, size: 16),
                      const SizedBox(width: 3),
                      Text(
                        double.tryParse(rating)!.toStringAsFixed(1),
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

            const SizedBox(height: 10),

            Row(
              children: [
                isGrocery==true?Container():
                Icon(Icons.access_time, size: 16, color: colorPrimary),
                isGrocery==true?Container():
                const SizedBox(width: 4),
                isGrocery==true?Container():
                Text(
                  time == "0" || time == "" || time.toString() == "null"
                      ? "0 " + S.of(context).mins
                      : time + " " + S.of(context).mins,
                  style: appFont('Rubik', 
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                isGrocery==true?Container():
                const SizedBox(width: 10),
                isGrocery==true?Container():
                Container(width: 1, height: 15, color: Colors.grey),
                isGrocery==true?Container():
                const SizedBox(width: 10),
                Image.asset(
                  'lib/assets/images/location_outlined.png',
                  height: 15,
                  width: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  double.tryParse(distance)!.toStringAsFixed(2) +
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
            Row(
              children: [
                Image.asset(
                  'lib/assets/images/offer.png',
                  height: 18,
                  width: 18,
                ),
                const SizedBox(width: 4),
                offerText == "null" || offerText == ""
                    ? Container()
                    : Text(
                        S.of(context).upto +
                            " " +
                            offerText +
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

            const SizedBox(height: 10),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: onChatNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGrocery ? yellow : colorPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/home_cleaning/Assets/images/chat.png',
                      height: 20,
                      width: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      S.of(context).chatNow,
                      style: appFont('Rubik', 
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
