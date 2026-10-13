import 'package:intl/intl.dart';

class PharmacyPendingOrdersModel {
  final bool? status;
  final PharmacyPendingOrdersData? data;
  final String? message;

  PharmacyPendingOrdersModel({
    this.status,
    this.data,
    this.message,
  });

  factory PharmacyPendingOrdersModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PharmacyPendingOrdersModel();
    return PharmacyPendingOrdersModel(
      status: json['status'] == true || json['status']?.toString() == 'true',
      data: json['data'] != null
          ? PharmacyPendingOrdersData.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
      message: json['message']?.toString(),
    );
  }
}

class PharmacyPendingOrdersData {
  final int? currentPage;
  final List<PharmacyPendingOrderItem>? data;
  final int? lastPage;
  final dynamic total;

  PharmacyPendingOrdersData({
    this.currentPage,
    this.data,
    this.lastPage,
    this.total,
  });

  factory PharmacyPendingOrdersData.fromJson(Map<String, dynamic> json) {
    List<PharmacyPendingOrderItem> list = [];
    final orders = json['orders'];
    if (orders is Map && orders['data'] is List) {
      list = (orders['data'] as List)
          .map((e) => PharmacyPendingOrderItem.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } else if (json['data'] is List) {
      list = (json['data'] as List)
          .map((e) => PharmacyPendingOrderItem.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } else if (orders is List) {
      list = (orders as List)
          .map((e) => PharmacyPendingOrderItem.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    }

    final pageObj = orders is Map ? orders : json;

    return PharmacyPendingOrdersData(
      currentPage: pageObj['current_page'] is int
          ? pageObj['current_page']
          : int.tryParse(pageObj['current_page']?.toString() ?? ''),
      lastPage: pageObj['last_page'] is int
          ? pageObj['last_page']
          : int.tryParse(pageObj['last_page']?.toString() ?? ''),
      total: pageObj['total'],
      data: list,
    );
  }
}

class PharmacyPendingOrderItem {
  final int? orderId;
  final int? id;
  final String? orderCode;
  final int? status;
  final dynamic total;
  final String? type;
  final String? placedAt;
  final String? createdAt;
  final String? customerName;
  final String? userName;
  final String? phone;
  final dynamic isSelfPickup;
  final dynamic deliveryType;
  final dynamic paymentType;
  final String? deliveryBoyName;
  final int? itemsCount;
  final int? orderItemsCount;
  final List<dynamic>? items;
  final Map<String, dynamic>? rawJson;

  PharmacyPendingOrderItem({
    this.orderId,
    this.id,
    this.orderCode,
    this.status,
    this.total,
    this.type,
    this.placedAt,
    this.createdAt,
    this.customerName,
    this.userName,
    this.phone,
    this.isSelfPickup,
    this.deliveryType,
    this.paymentType,
    this.deliveryBoyName,
    this.itemsCount,
    this.orderItemsCount,
    this.items,
    this.rawJson,
  });

  factory PharmacyPendingOrderItem.fromJson(Map<String, dynamic> json) {
    return PharmacyPendingOrderItem(
      orderId: (json['order_id'] is int)
          ? json['order_id']
          : int.tryParse(json['order_id']?.toString() ?? '') ??
              ((json['id'] is int)
                  ? json['id']
                  : int.tryParse(json['id']?.toString() ?? '')),
      id: (json['id'] is int)
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      orderCode:
          json['order_code']?.toString() ?? json['order_number']?.toString(),
      status: (json['status'] is int)
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
      total: json['total']?.toString(),
      type: json['type']?.toString(),
      placedAt: json['placed_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      customerName: json['customer_name']?.toString() ??
          json['user_name']?.toString() ??
          json['user']?['name']?.toString(),
      userName:
          json['user_name']?.toString() ?? json['customer_name']?.toString(),
      phone: json['customer_phone']?.toString() ??
          json['customer_mobile']?.toString() ??
          json['user_mobile']?.toString() ??
          json['phone']?.toString() ??
          json['mobile']?.toString() ??
          json['user']?['mobile']?.toString() ??
          json['user']?['phone']?.toString(),
      isSelfPickup: json['is_self_pickup'] ?? json['isSelfPickup'],
      deliveryType: json['delivery_type'] ?? json['fulfillment_type'],
      paymentType: json['payment_type'] ??
          json['payment_method'] ??
          json['payment_mode'] ??
          json['paymentMethod'],
      deliveryBoyName: (json['delivery_boy_name'] ??
              json['delivery_boy']?['name'] ??
              json['driver']?['name'] ??
              json['driver_name'])
          ?.toString()
          ?.trim(),
      itemsCount: (json['items_count'] is int)
          ? json['items_count']
          : int.tryParse(json['items_count']?.toString() ?? '') ??
              int.tryParse(json['order_items_count']?.toString() ?? '') ??
              int.tryParse(json['total_items']?.toString() ?? '') ??
              (json['items'] is List
                  ? (json['items'] as List).length
                  : null) ??
              (json['order_items'] is List
                  ? (json['order_items'] as List).length
                  : null),
      orderItemsCount: (json['order_items_count'] is int)
          ? json['order_items_count']
          : int.tryParse(json['order_items_count']?.toString() ?? ''),
      items: json['items'] is List
          ? json['items']
          : (json['order_items'] is List ? json['order_items'] : null),
      rawJson: json,
    );
  }

  int? get resolvedId => orderId ?? id;

  String get displayCustomerName {
    final name = customerName ?? userName;
    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }
    return 'Customer';
  }

  String get displayOrderCode {
    if (orderCode != null && orderCode!.isNotEmpty) {
      return orderCode!.startsWith('#') ? orderCode! : '#$orderCode';
    }
    final numId = resolvedId;
    return numId != null ? '#$numId' : '';
  }

  String get displayTimeAgo {
    final timeStr = placedAt ?? createdAt;
    if (timeStr != null && timeStr.isNotEmpty) {
      return _formatRelativeTime(timeStr);
    }
    return '';
  }

  bool get isSelfPickupBool {
    return isSelfPickup == 1 ||
        isSelfPickup == true ||
        isSelfPickup?.toString() == '1' ||
        isSelfPickup?.toString().toLowerCase() == 'true' ||
        deliveryType?.toString().toLowerCase() == 'pickup';
  }

  bool get isCashOnDeliveryBool {
    final p = paymentType?.toString().toLowerCase() ?? '';
    return p.contains('cash') || p.contains('cod');
  }

  int get displayItemsCount {
    if (itemsCount != null && itemsCount! > 0) return itemsCount!;
    if (orderItemsCount != null && orderItemsCount! > 0) return orderItemsCount!;
    if (items != null && items!.isNotEmpty) return items!.length;
    return 0;
  }

  String get displayTotal {
    if (total == null) return '';
    final s = total.toString().trim();
    if (s.isEmpty) return '';
    if (s.contains('MRU')) return s;
    final numVal = num.tryParse(s);
    if (numVal != null) {
      return '${numVal.toStringAsFixed(2)} MRU';
    }
    return '$s MRU';
  }

  String get displayItemsSummary {
    final count = displayItemsCount;
    final tot = displayTotal;
    if (count > 0 && tot.isNotEmpty) {
      final itemLabel = count == 1 ? '1 Item' : '$count Items';
      return '$itemLabel • $tot';
    } else if (tot.isNotEmpty) {
      return tot;
    } else if (count > 0) {
      return count == 1 ? '1 Item' : '$count Items';
    }
    return '';
  }

  static String _formatRelativeTime(String timeStr) {
    try {
      DateTime dt = DateTime.tryParse(timeStr) ?? DateTime.now();
      if (timeStr.contains('-') && !timeStr.contains('T')) {
        try {
          dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timeStr);
        } catch (_) {}
      }
      dt = dt.toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('dd MMM, yyyy').format(dt);
    } catch (_) {
      return timeStr;
    }
  }
}
