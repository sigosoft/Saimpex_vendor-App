import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/view/home/vendor_order_details.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_order_card.dart';

class VendorOrderListItem extends StatelessWidget {
  const VendorOrderListItem({
    super.key,
    required this.horizontalPadding,
    required this.orderId,
    this.orderCode,
    required this.customerName,
    required this.itemsCount,
    required this.price,
    required this.dateTime,
    required this.status,
    required this.onAccept,
    required this.onReject,
    this.onMarkAsReady,
    this.onPrint,
    this.deliveryBoyName,
    this.cancelReason,
    this.type,
    this.deliveryType,
    this.isSelfPickup,
    this.onMarkSelfPickupCompleted,
  });

  final double horizontalPadding;
  final String orderId;
  final String? orderCode;
  final String customerName;
  final int itemsCount;
  final double price;
  final String dateTime;
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback? onMarkAsReady;
  final VoidCallback? onPrint;
  final String? deliveryBoyName;
  final String? cancelReason;
  final String? type;
  final dynamic deliveryType;
  final dynamic isSelfPickup;
  final VoidCallback? onMarkSelfPickupCompleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: VendorOrderCard(
        orderId: orderId,
        orderCode: orderCode,
        customerName: customerName,
        itemsCount: itemsCount,
        price: price,
        dateTime: dateTime,
        status: status,
        onReject: onReject,
        onAccept: onAccept,
        onMarkAsReady: onMarkAsReady,
        onPrint: onPrint,
        deliveryBoyName: deliveryBoyName,
        cancelReason: cancelReason,
        type: type,
        deliveryType: deliveryType,
        isSelfPickup: isSelfPickup,
        onMarkSelfPickupCompleted: onMarkSelfPickupCompleted,
        onTap: () {
          if (status.toLowerCase() != 'cancelled') {
            Get.to(
              () => VendorOrderDetails(
                orderId: orderId.toString(),
                orderType: type,
              ),
            );
          }
        },
      ),
    );
  }
}
