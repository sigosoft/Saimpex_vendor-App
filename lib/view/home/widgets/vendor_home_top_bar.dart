import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/view/notifications/notifications.dart';

import '../../../generated/l10n.dart';

class VendorHomeTopBar extends StatelessWidget {
  const VendorHomeTopBar({super.key, required this.horizontalPadding, required this.userName});

  final double horizontalPadding;
  final dynamic userName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('lib/assets/images/logo.png', height: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: userName.toString()=="null"?Container():Text(
                    S.of(context).welcomeTo+" "+userName.toString(),
                    style: appFont('Rubik', 
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const Notifications()),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Icon(
                Icons.notifications_none,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
