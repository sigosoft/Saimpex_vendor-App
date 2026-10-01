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
}
