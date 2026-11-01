import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';

class VendorOrdersHeader extends StatelessWidget {
  const VendorOrdersHeader({
    super.key,
    required this.horizontalPadding,
    required this.onViewAllPressed,
  });

  final double horizontalPadding;
  final VoidCallback onViewAllPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).ordersHeader,
            style: appFont('Rubik', 
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          TextButton(
            onPressed: onViewAllPressed,
            child: Text(
              S.of(context).viewAll,
              style: appFont('Rubik', 
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF5216),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
