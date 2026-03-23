import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../generated/l10n.dart';

class VendorSuccessDialog extends StatelessWidget {
  const VendorSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: size.width * 0.82,
        height: size.height * 0.19,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.grey, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            Image.asset(
              'lib/assets/images/Success vendor.png',
              width: 50,
              height: 50,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).orderAcceptedSuccessfully,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
