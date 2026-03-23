import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/view/home/dashboard.dart';

import '../../../generated/l10n.dart';

class VendorDashboardButton extends StatelessWidget {
  const VendorDashboardButton({
    super.key,
    required this.horizontalPadding,
    required this.width,
    required this.height,
  });

  final double horizontalPadding;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: () {
            Get.to(() => const Dashboard());
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFFF5216)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            S.of(context).goToDashboard,
            style: GoogleFonts.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF5216),
            ),
          ),
        ),
      ),
    );
  }
}
