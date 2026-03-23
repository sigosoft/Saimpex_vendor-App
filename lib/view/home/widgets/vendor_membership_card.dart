import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../generated/l10n.dart';

class VendorMembershipCard extends StatelessWidget {
  const VendorMembershipCard({
    super.key,
    required this.horizontalPadding,
    required this.width,
    required this.height,
    required this.membershipName,
    required this.expiryText,
    this.isWarning = true,
  });

  final double horizontalPadding;
  final double width;
  final double height;
  final String membershipName;
  final String expiryText;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset('lib/assets/images/Silver.png', width: 30, height: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                membershipName.toLowerCase().contains("member")
                    ? membershipName
                    : "$membershipName"+" "+S.of(context).member,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isWarning
                    ? const Color(0xFFFFE5E5)
                    : const Color(0xFFE5FFE5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                expiryText,
                style: GoogleFonts.rubik(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isWarning ? Colors.red : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
