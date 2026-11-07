import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/order_fulfillment.dart';
import 'package:saimpex_vendor/view/home/widgets/order_fulfillment_badge.dart';
import 'package:saimpex_vendor/view/home/widgets/preorder_badge.dart';

class VendorOrderCard extends StatelessWidget {
  final String orderId;
  final String? orderCode;
  final String customerName;
  final int itemsCount;
  final double price;
  final String dateTime;
  final String status;
  final VoidCallback onReject;
  final VoidCallback onAccept;
  final VoidCallback? onMarkAsReady;
  final VoidCallback? onPrint;
  final VoidCallback? onTap;
  final String? deliveryBoyName;
  final String? cancelReason;
  final String? type;
  final dynamic deliveryType;
  final dynamic isSelfPickup;
  /// Delivery time when this order is a pre-order.
  final DateTime? scheduledFor;
  final VoidCallback? onMarkSelfPickupCompleted;

  const VendorOrderCard({
    super.key,
    required this.orderId,
    this.orderCode,
    required this.customerName,
    required this.itemsCount,
    required this.price,
    required this.dateTime,
    required this.status,
    required this.onReject,
    required this.onAccept,
    this.onMarkAsReady,
    this.onPrint,
    this.onTap,
    this.deliveryBoyName,
    this.cancelReason,
    this.type,
    this.deliveryType,
    this.isSelfPickup,
    this.scheduledFor,
    this.onMarkSelfPickupCompleted,
  });

  bool get _isSelfPickup => OrderFulfillment.isSelfPickupFrom(
        deliveryType: deliveryType,
        isSelfPickup: isSelfPickup,
      );

  /// Order status code (1 pending … 10 cancelled) from [status]. The
  /// callers pass the label in the app language, so the colour and the
  /// buttons compared it with English words and broke in French and Arabic.
  /// Both the translated label and the English word are recognised.
  bool get _hasDriverName {
    final n = deliveryBoyName?.trim() ?? '';
    return n.isNotEmpty && n != 'null';
  }

  int get _code {
    final s = status.trim().toLowerCase();
    bool isAny(String translated, List<String> english) =>
        s == translated.trim().toLowerCase() || english.contains(s);
    if (isAny(S.current.pending, ['pending'])) return 1;
    if (isAny(S.current.accepted, ['accepted'])) return 2;
    if (isAny(S.current.preparing, ['preparing'])) return 3;
    if (isAny(S.current.ready, ['ready'])) return 4;
    if (isAny(S.current.assignedStatus, ['assigned'])) return 5;
    if (isAny(S.current.reachedRestaurant, ['reached restaurant'])) return 6;
    if (isAny(S.current.pickedUp, ['picked up'])) return 7;
    if (isAny(S.current.delivering, ['delivering'])) return 8;
    if (isAny(S.current.delivered, ['delivered'])) return 9;
    if (isAny(S.current.cancelled, ['cancelled'])) return 10;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.25,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            S.of(context).orderIdLabel(orderCode ?? orderId),
                            style: appFont('Rubik', 
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorPrimary,
                            ),
                          ),
                          OrderFulfillmentBadge(
                            deliveryType: deliveryType,
                            isSelfPickup: isSelfPickup,
                          ),
                          if (scheduledFor != null)
                            PreorderBadge(scheduledFor: scheduledFor!),
                        ],
                      ),
                      if (type?.trim().toLowerCase().contains("basket") ==
                          true) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF3F4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Basket order",
                            style: appFont('Rubik', 
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF37ADB5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _code == 1
                        ? const Color(0xFFF59E0B)
                        : _code == 2
                        ? const Color(0xFF22C55E)
                        : _code == 3
                        ? const Color(0xFF60A5FA)
                        : _code == 4
                        ? const Color(0xFF22C55E)
                        : _code == 5 ||
                              _code == 6 ||
                              _code == 7 ||
                              _code == 8
                        ? const Color(0xFF22C55E)
                        : _code == 9
                        ? const Color(0xFF15803D)
                        : _code == 10
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFFFB800),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: appFont('Rubik', 
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            // if (_code == 3)
            //   Align(
            //     alignment: Alignment.centerRight,
            //     child: Padding(
            //       padding: const EdgeInsets.only(top: 4.0),
            //       child: Text(
            //         "00:05:00 min",
            //         style: appFont('Rubik', 
            //           fontSize: 10,
            //           color: const Color(0xFF64748B),
            //         ),
            //       ),
            //     ),
            //   ),
            const SizedBox(height: 4), // Reduced gap
            Text(
              customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appFont('Rubik', 
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 7), // Gap 7px
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).items.toUpperCase(),
                        style: appFont('Rubik', 
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: appFont('Rubik', 
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          children: [
                            TextSpan(
                              text:
                                  "$itemsCount ${S.of(context).items}" +
                                  (price > 0 ||
                                          type?.trim().toLowerCase().contains(
                                                "basket",
                                              ) ==
                                              true
                                      ? " • "
                                      : ""),
                            ),
                            if (price > 0 ||
                                type?.trim().toLowerCase().contains("basket") ==
                                    true)
                              TextSpan(
                                text:
                                    type?.trim().toLowerCase().contains(
                                          "basket",
                                        ) ==
                                        true
                                    ? "0.00 MRU"
                                    : "${price.toStringAsFixed(2)} MRU",
                                style: const TextStyle(
                                  color: Color(0xFFFF5216),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        S.of(context).dateTime,
                        style: appFont('Rubik', 
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateTime,
                        textAlign: TextAlign.right,
                        style: appFont('Rubik', 
                          fontSize: 10,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!_isSelfPickup &&
                (_code == 4 ||
                    _code == 9 ||
                    _code == 5 ||
                    _code == 6 ||
                    _code == 7 ||
                    _code == 8 ||
                    status == S.of(context).ready ||
                    status == S.of(context).delivered ||
                    status == S.of(context).assignedStatus)) ...[
              const SizedBox(height: 12),
              Text(
                S.of(context).driver.toUpperCase(),
                style: appFont('Rubik', 
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: appFont('Rubik', fontSize: 11),
                  children: [
                    TextSpan(
                      // A ready order (4) has no driver yet unless the API
                      // sends a name; "Assigned" with no name was shown
                      // (phone check 7 Nov, ORD-001546). From status 5 on a
                      // driver is assigned.
                      text: _code == 4 && !_hasDriverName
                          ? S.of(context).waitingForDeliveryPartner
                          : "${S.of(context).assignedStatus} ",
                      style: const TextStyle(
                        color: Color(0xFFFF5216),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text:
                          (deliveryBoyName == "" ||
                              deliveryBoyName == "null" ||
                              deliveryBoyName == null)
                          ? ""
                          : "($deliveryBoyName)",
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (_code == 10) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    S.of(context).cancelledOnLabel(dateTime),
                    style: appFont('Rubik', 
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (cancelReason != null && cancelReason!.trim().isNotEmpty) ...[
                Text(
                  S.of(context).reasonColonLabel(cancelReason!),
                  style: appFont('Rubik', 
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            if (_code == 1)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        S.of(context).reject,
                        style: appFont('Rubik', fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5216),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        S.of(context).acceptOrder,
                        style: appFont('Rubik', fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              )
            else if (_code == 3)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFF5216)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            S.of(context).viewDetails,
                            style: appFont('Rubik', 
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFF5216),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onMarkAsReady,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5216),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            S.of(context).markAsReady,
                            style: appFont('Rubik', 
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: onPrint ?? () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF5216)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        S.of(context).printOrder,
                        style: appFont('Rubik', 
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF5216),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else if (_code == 10)
              const SizedBox.shrink()
            else if (_isSelfPickup &&
                _code == 4 &&
                onMarkSelfPickupCompleted != null)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFF5216)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            S.of(context).viewDetails,
                            style: appFont('Rubik', 
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFF5216),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onMarkSelfPickupCompleted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5216),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            S.of(context).markSelfPickupCompleted,
                            textAlign: TextAlign.center,
                            style: appFont('Rubik', 
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: onPrint ?? () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF5216)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        S.of(context).printOrder,
                        style: appFont('Rubik', 
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF5216),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else if (_code == 2)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF5216)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        S.of(context).viewDetails,
                        style: appFont('Rubik', 
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF5216),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPrint ?? () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5216),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        S.of(context).printOrder,
                        style: appFont('Rubik', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF5216)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        S.of(context).viewDetails,
                        style: appFont('Rubik', 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF5216),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _code == 10
                      ? Container()
                      : SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: OutlinedButton(
                            onPressed: onPrint ?? () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFF5216)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              S.of(context).printOrder,
                              style: appFont('Rubik', 
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF5216),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
