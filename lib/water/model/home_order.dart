import 'package:saimpex_vendor/model/home_model.dart';

enum HomeOrderStatus {
  newOrder,
  accepted,
  preparing,
  ready,
  delivered,
  cancelled,
}

enum SubscriptionOrderStatus { newOrder, active, paused, cancelled }

class HomeOrder {
  final String customerName;
  final String orderType;
  final String orderId;
  final String timeAgo;
  final String itemLabel;
  final String paymentLabel;
  final bool isDelivery;
  final bool isOnlinePayment;
  final bool isScheduled;
  final String? scheduleDate;
  final String? scheduleTime;
  final String? deliveryPartnerName;
  final HomeOrderStatus status;

  const HomeOrder({
    required this.customerName,
    required this.orderType,
    required this.orderId,
    required this.timeAgo,
    required this.itemLabel,
    required this.paymentLabel,
    required this.isDelivery,
    required this.isOnlinePayment,
    this.isScheduled = false,
    this.scheduleDate,
    this.scheduleTime,
    this.deliveryPartnerName,
    this.status = HomeOrderStatus.newOrder,
  });

  factory HomeOrder.fromOrderData(OrderData order) {
    final raw = order.rawJson ?? {};
    final isPickup = order.isSelfPickup == 1 ||
        order.isSelfPickup == true ||
        order.isSelfPickup == '1' ||
        order.deliveryType == 2 ||
        order.deliveryType == '2' ||
        order.deliveryType?.toString().toLowerCase().contains('pickup') == true ||
        raw['is_self_pickup'] == 1 ||
        raw['is_self_pickup'] == true ||
        raw['is_self_pickup'] == '1';
    final isDelivery = !isPickup;

    final customerName = (order.userName?.trim().isNotEmpty == true)
        ? order.userName!.trim()
        : (raw['user']?['name']?.toString().trim().isNotEmpty == true
            ? raw['user']['name'].toString().trim()
            : 'Customer');

    final orderId = (order.orderCode?.trim().isNotEmpty == true)
        ? order.orderCode!.trim()
        : (order.id != null ? '#${order.id}' : '');

    final timeAgo = (order.placedAtFormatted?.trim().isNotEmpty == true)
        ? order.placedAtFormatted!.trim()
        : (order.placedAt?.trim() ?? '');

    final paymentMethod = (raw['payment_type'] ?? raw['payment_method'])
            ?.toString()
            .toLowerCase() ??
        '';
    final isCod = paymentMethod.contains('cash') ||
        paymentMethod.contains('cod') ||
        paymentMethod == '1';
    final isOnlinePayment = !isCod;
    final paymentLabel = isOnlinePayment ? 'Online Payment' : 'Cash on Delivery';

    final total = order.total?.toString() ?? raw['total']?.toString() ?? '0';
    String itemLabel = '';
    final orderItems = raw['order_items'];
    if (orderItems is List && orderItems.isNotEmpty) {
      final first = orderItems.first;
      if (first is Map) {
        final itemName = first['name'] ??
            first['product_name'] ??
            first['item_name'] ??
            'Bottle';
        final qty = first['quantity'] ?? first['qty'] ?? 1;
        itemLabel = '$qty $itemName • $total MRU';
      }
    }
    if (itemLabel.isEmpty) {
      final count = order.totalItems ?? order.orderItemsCount ?? 1;
      itemLabel = '$count ${count == 1 ? "Item" : "Items"} • $total MRU';
    }

    final isScheduled = raw['is_scheduled'] == 1 ||
        raw['is_scheduled'] == true ||
        raw['is_scheduled'] == '1';
    final scheduleDate = raw['schedule_date']?.toString();
    final scheduleTime = raw['schedule_time']?.toString();
    final deliveryPartner = order.deliveryBoyName;

    HomeOrderStatus status = HomeOrderStatus.newOrder;
    switch (order.status) {
      case 1:
        status = HomeOrderStatus.newOrder;
        break;
      case 2:
        status = HomeOrderStatus.accepted;
        break;
      case 3:
        status = HomeOrderStatus.preparing;
        break;
      case 4:
        status = HomeOrderStatus.ready;
        break;
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
        status = HomeOrderStatus.delivered;
        break;
      case 10:
        status = HomeOrderStatus.cancelled;
        break;
      default:
        status = HomeOrderStatus.newOrder;
    }

    return HomeOrder(
      customerName: customerName,
      orderType: isDelivery ? 'Delivery' : 'Self Pickup',
      orderId: orderId,
      timeAgo: timeAgo,
      itemLabel: itemLabel,
      paymentLabel: paymentLabel,
      isDelivery: isDelivery,
      isOnlinePayment: isOnlinePayment,
      isScheduled: isScheduled,
      scheduleDate: scheduleDate,
      scheduleTime: scheduleTime,
      deliveryPartnerName: deliveryPartner,
      status: status,
    );
  }
}

class SubscriptionOrder {
  final String customerName;
  final String productLabel;
  final String orderId;
  final String timeAgo;
  final bool isDelivery;
  final String planName;
  final String planRange;
  final String timeSlot;
  final String estimatedValue;
  final String? nextDelivery;
  final String? pausedOn;
  final String? pauseReason;
  final bool pausedByVendor;
  final SubscriptionOrderStatus status;

  const SubscriptionOrder({
    required this.customerName,
    required this.productLabel,
    required this.orderId,
    required this.timeAgo,
    required this.isDelivery,
    required this.planName,
    required this.planRange,
    required this.timeSlot,
    required this.estimatedValue,
    this.nextDelivery,
    this.pausedOn,
    this.pauseReason,
    this.pausedByVendor = false,
    this.status = SubscriptionOrderStatus.newOrder,
  });

  factory SubscriptionOrder.fromJson(Map<String, dynamic> json) {
    final customerName = json['customer_name']?.toString() ??
        json['user_name']?.toString() ??
        json['user']?['name']?.toString() ??
        'Customer';

    final productLabel = json['product_label']?.toString() ??
        json['product_name']?.toString() ??
        json['item_name']?.toString() ??
        'Drinking Water 19L';

    final orderId = json['order_code']?.toString() ??
        (json['id'] != null ? '#${json['id']}' : '');

    final timeAgo = json['time_ago']?.toString() ??
        json['placed_at_formatted']?.toString() ??
        json['placed_at']?.toString() ??
        '';

    final isDelivery = json['is_delivery'] == true ||
        json['is_delivery'] == 1 ||
        json['delivery_type'] == 1 ||
        json['is_self_pickup'] != 1;

    final planName = json['plan_name']?.toString() ??
        json['plan']?.toString() ??
        'Daily';

    final planRange = json['plan_range']?.toString() ??
        (json['start_date'] != null && json['end_date'] != null
            ? 'Start ${json['start_date']} - End ${json['end_date']}'
            : '');

    final timeSlot = json['time_slot']?.toString() ??
        json['delivery_slot']?.toString() ??
        '';

    final total = json['total']?.toString() ??
        json['estimated_value']?.toString() ??
        '';
    final estimatedValue = total.isNotEmpty
        ? (total.contains('MRU') ? total : '$total MRU')
        : '0 MRU';

    final nextDelivery = json['next_delivery']?.toString();
    final pausedOn = json['paused_on']?.toString();
    final pauseReason = json['pause_reason']?.toString();
    final pausedByVendor = json['paused_by_vendor'] == true ||
        json['paused_by_vendor'] == 1;

    SubscriptionOrderStatus status = SubscriptionOrderStatus.newOrder;
    final s = json['status'];
    if (s == 1 || s == '1' || s == 'new' || s == 'newOrder') {
      status = SubscriptionOrderStatus.newOrder;
    } else if (s == 2 || s == '2' || s == 'active') {
      status = SubscriptionOrderStatus.active;
    } else if (s == 3 || s == '3' || s == 'paused') {
      status = SubscriptionOrderStatus.paused;
    } else if (s == 4 || s == '4' || s == 10 || s == 'cancelled') {
      status = SubscriptionOrderStatus.cancelled;
    }

    return SubscriptionOrder(
      customerName: customerName,
      productLabel: productLabel,
      orderId: orderId,
      timeAgo: timeAgo,
      isDelivery: isDelivery,
      planName: planName,
      planRange: planRange,
      timeSlot: timeSlot,
      estimatedValue: estimatedValue,
      nextDelivery: nextDelivery,
      pausedOn: pausedOn,
      pauseReason: pauseReason,
      pausedByVendor: pausedByVendor,
      status: status,
    );
  }
}
