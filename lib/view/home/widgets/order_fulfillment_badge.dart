import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/order_fulfillment.dart';

/// Inline badge beside order id: orange delivery or blue self pickup.
class OrderFulfillmentBadge extends StatelessWidget {
  const OrderFulfillmentBadge({
    super.key,
    this.deliveryType,
    this.isSelfPickup,
  });

  final dynamic deliveryType;
  final dynamic isSelfPickup;

  @override
  Widget build(BuildContext context) {
    if (OrderFulfillment.isSelfPickupFrom(
      deliveryType: deliveryType,
      isSelfPickup: isSelfPickup,
    )) {
      return _Badge(
        icon: Icons.shopping_bag_outlined,
        label: S.of(context).selfPickup,
        color: const Color(0xFF2563EB),
      );
    }
    if (!OrderFulfillment.isDeliveryFrom(
      deliveryType: deliveryType,
      isSelfPickup: isSelfPickup,
    )) {
      return const SizedBox.shrink();
    }
    return _Badge(
      icon: Icons.delivery_dining,
      label: S.of(context).delivery,
      color: colorPrimary,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.rubik(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: color,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('(', style: textStyle),
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: textStyle),
        Text(' )', style: textStyle),
      ],
    );
  }
}
