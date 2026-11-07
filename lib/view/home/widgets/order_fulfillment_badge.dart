import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/order_fulfillment.dart';

/// True for an express order: `is_express` (1 / true, backend #175) or the
/// raw order `type` "express" (order lists).
bool isExpressOrder(dynamic isExpress, dynamic type) {
  final v = isExpress?.toString().trim().toLowerCase();
  if (v == '1' || v == 'true') return true;
  return type?.toString().trim().toLowerCase() == 'express';
}

/// Inline badge beside order id: orange delivery or blue self pickup, then
/// the Figma "Express" tag for an express order.
class OrderFulfillmentBadge extends StatelessWidget {
  const OrderFulfillmentBadge({
    super.key,
    this.deliveryType,
    this.isSelfPickup,
    this.isExpress = false,
  });

  final dynamic deliveryType;
  final dynamic isSelfPickup;
  final bool isExpress;

  @override
  Widget build(BuildContext context) {
    final badge = _fulfillment(context);
    if (!isExpress) return badge;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            S.of(context).processingExpress,
            style: appFont('Rubik',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fulfillment(BuildContext context) {
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
    final textStyle = appFont('Rubik', 
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
