import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-width primary CTA (orange) used at screen bottom in vendor flows.
class VendorOrangeFullWidthButton extends StatelessWidget {
  const VendorOrangeFullWidthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.heightFactor = 0.07,
  });

  final String label;
  final VoidCallback? onPressed;
  final double heightFactor;

  static const _orange = Color(0xFFFF5216);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * heightFactor;
    return SizedBox(
      width: double.infinity,
      height: h.clamp(52.0, 64.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          elevation: 2,
          shadowColor: _orange.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
