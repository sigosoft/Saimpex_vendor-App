import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';

/// One upcoming pre-order from `GET vendorapp/preorders` (API §6.10).
class PreOrder {
  PreOrder({
    required this.orderId,
    required this.orderCode,
    required this.status,
    required this.total,
    required this.scheduledFor,
    required this.isSelfPickup,
    required this.driverRequested,
    required this.driverAssigned,
  });

  final String orderId;
  final String orderCode;
  final int status;
  final double total;
  final DateTime scheduledFor;
  final bool isSelfPickup;
  final bool driverRequested;
  final bool driverAssigned;

  static PreOrder? fromJson(Map json) {
    final scheduled = DateTime.tryParse(json['scheduled_for']?.toString() ?? '');
    final id = json['order_id']?.toString() ?? '';
    if (scheduled == null || id.isEmpty) return null;
    return PreOrder(
      orderId: id,
      orderCode: json['order_code']?.toString() ?? id,
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0,
      scheduledFor: scheduled.toLocal(),
      isSelfPickup: json['is_self_pickup']?.toString() == '1',
      driverRequested: json['driver_requested'] == true,
      driverAssigned: json['driver_assigned'] == true,
    );
  }
}

/// Upcoming pre-orders, soonest first. The home order list and order details
/// don't carry `is_preorder` / `scheduled_for`, so screens look orders up here.
class PreordersController extends GetxController {
  bool isLoading = false;
  List<PreOrder> preorders = [];
  Map<String, PreOrder> _byOrderId = {};

  PreOrder? forOrder(String? orderId) =>
      orderId == null ? null : _byOrderId[orderId];

  Future<void> fetch() async {
    isLoading = true;
    update();
    try {
      final response = await DioClient().get(
        ApiEndPoints.preorders,
        query: {"limit": 100},
      );
      final body = response.data;
      if (body is Map && body['status'].toString() == 'true') {
        final list = body['data']?['orders'];
        preorders = (list is List ? list : const [])
            .whereType<Map>()
            .map(PreOrder.fromJson)
            .whereType<PreOrder>()
            .toList()
          ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
        _byOrderId = {for (final p in preorders) p.orderId: p};
      }
    } catch (e) {
      debugPrint('Error fetching pre-orders: $e');
    }
    isLoading = false;
    update();
  }
}
