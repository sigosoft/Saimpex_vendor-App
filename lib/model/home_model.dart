import 'OrderDetailsModel.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';

class HomeModel {
  final bool? status;
  final HomeData? data;
  final Message? message;

  HomeModel({this.status, this.data, this.message});

  factory HomeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return HomeModel();

    return HomeModel(
      status: json['status']?.toString() == "true",
      data: json['data'] != null ? HomeData.fromJson(json['data']) : null,
      message: json['message'] != null
          ? Message.fromJson(json['message'])
          : null,
    );
  }
}

class HomeData {
  final Membership? membership;
  final Summary? summary;
  final Orders? orders;
  final Vendor? vendor;
  final Map<String, dynamic>? screen;

  HomeData({
    this.membership,
    this.summary,
    this.orders,
    this.vendor,
    this.screen,
  });

  factory HomeData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return HomeData();

    return HomeData(
      membership: json['membership'] != null
          ? Membership.fromJson(json['membership'])
          : null,
      summary: json['summary'] != null
          ? Summary.fromJson(json['summary'])
          : null,
      orders: json['orders'] != null ? Orders.fromJson(json['orders']) : null,
      vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
      screen: json['screen'] is Map
          ? Map<String, dynamic>.from(json['screen'])
          : null,
    );
  }
}

class Membership {
  final String? nameEn;
  final String? nameFr;
  final String? nameAr;
  final int? expiresInDays;
  final String? subscriptionEndDate;

  Membership({
    this.nameEn,
    this.nameFr,
    this.nameAr,
    this.expiresInDays,
    this.subscriptionEndDate,
  });

  factory Membership.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Membership();

    return Membership(
      nameEn: json['name_en']?.toString(),
      nameFr: json['name_fr']?.toString(),
      nameAr: json['name_ar']?.toString(),
      expiresInDays: (json['expires_in_days'] is int)
          ? json['expires_in_days']
          : int.tryParse(json['expires_in_days']?.toString() ?? ''),
      subscriptionEndDate: json['subscription_end_date']?.toString(),
    );
  }
}

class Summary {
  final int? todayOrders;
  final int? totalOrders;
  final int? totalProducts;
  final int? pendingOrdersCount;
  final int? acceptedOrdersCount;
  final int? processedOrdersCount;
  final int? readyOrdersCount;
  final int? ongoingOrdersCount;
  final int? completedOrdersCount;
  final int? cancelledOrdersCount;

  Summary({
    this.todayOrders,
    this.totalOrders,
    this.totalProducts,
    this.pendingOrdersCount,
    this.acceptedOrdersCount,
    this.processedOrdersCount,
    this.readyOrdersCount,
    this.ongoingOrdersCount,
    this.completedOrdersCount,
    this.cancelledOrdersCount,
  });

  factory Summary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Summary();

    int? parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString());
      return null;
    }

    return Summary(
      todayOrders: parseInt(json['today_orders']),
      totalOrders: parseInt(json['total_orders']),
      totalProducts: parseInt(json['total_products']),
      pendingOrdersCount: parseInt(json['pending_orders_count']),
      acceptedOrdersCount: parseInt(json['accepted_orders_count']),
      processedOrdersCount: parseInt(json['processed_orders_count']),
      readyOrdersCount: parseInt(json['ready_orders_count']),
      ongoingOrdersCount: parseInt(json['ongoing_orders_count']),
      completedOrdersCount: parseInt(json['completed_orders_count']),
      cancelledOrdersCount: parseInt(json['cancelled_orders_count']),
    );
  }
}

class Orders {
  final int? currentPage;
  final List<OrderData>? data;
  final int? lastPage;
  final dynamic total;

  Orders({this.currentPage, this.data, this.lastPage, this.total});

  factory Orders.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Orders();

    return Orders(
      currentPage: (json['current_page'] is int)
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? ''),
      lastPage: (json['last_page'] is int)
          ? json['last_page']
          : int.tryParse(json['last_page']?.toString() ?? ''),
      total: json['total'],
      data: (json['data'] as List?)?.map((e) => OrderData.fromJson(e)).toList(),
    );
  }
}

class OrderData {
  final String? orderCode;
  final int? status;
  final String? placedAt;
  final int? id;
  final dynamic total;
  final String? userName;
  final String? userEmail;
  final String? userMobile;
  final int? orderItemsCount;
  final int? totalItems;
  final int? basketItemsCount;
  final String? placedAtFormatted;
  final String? deliveryBoyName;
  final String? cancelReason;
  final String? type;
  final dynamic deliveryType;
  final dynamic isSelfPickup;
  final List<BasketOrder>? basketOrders;
  final int? prescriptionId;
  final String? prescriptionImageUrl;
  final String? prescriptionFileName;
  final Map<String, dynamic>? rawJson;

  OrderData({
    this.orderCode,
    this.status,
    this.placedAt,
    this.id,
    this.prescriptionId,
    this.total,
    this.userName,
    this.userEmail,
    this.userMobile,
    this.orderItemsCount,
    this.totalItems,
    this.basketItemsCount,
    this.placedAtFormatted,
    this.deliveryBoyName,
    this.cancelReason,
    this.type,
    this.deliveryType,
    this.isSelfPickup,
    this.basketOrders,
    this.prescriptionImageUrl,
    this.prescriptionFileName,
    this.rawJson,
  });

  factory OrderData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OrderData();

    final typeStr =
        (json['type'] ?? json['order_type'] ?? json['basket_type'])
            ?.toString()
            .toLowerCase() ??
        '';
    final isBasket = typeStr.contains('basket');
    final basketOrders = (json['basket_orders'] as List?)
        ?.map((e) => BasketOrder.fromJson(e))
        .toList();

    return OrderData(
      orderCode: json['order_code']?.toString(),
      status: (json['status'] is int)
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
      placedAt: json['placed_at']?.toString(),
      id: (json['id'] is int)
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '') ??
              ((json['order_id'] is int)
                  ? json['order_id']
                  : int.tryParse(json['order_id']?.toString() ?? ''))),
      prescriptionId: (json['prescription_id'] is int)
          ? json['prescription_id']
          : (int.tryParse(json['prescription_id']?.toString() ?? '') ??
              ((json['id'] is int)
                  ? json['id']
                  : int.tryParse(json['id']?.toString() ?? ''))),
      total: json['total']?.toString(),
      userName: json['user_name']?.toString(),
      userEmail: json['user_email']?.toString(),
      userMobile: json['user_mobile']?.toString(),
      orderItemsCount: isBasket
          ? (basketOrders?.fold<int>(
                0,
                (sum, bo) =>
                    sum +
                    (bo.basket?.basketItems?.fold<int>(
                          0,
                          (s, i) => s + (i.quantity ?? 0),
                        ) ??
                        0),
              ) ??
              int.tryParse(json['total_items']?.toString() ?? '') ??
              int.tryParse(json['basket_items_count']?.toString() ?? '') ??
              int.tryParse(json['order_items_count']?.toString() ?? '') ??
              0)
          : (int.tryParse(json['order_items_count']?.toString() ?? '') ?? 0),
      totalItems: (json['total_items'] is int)
          ? json['total_items']
          : int.tryParse(json['total_items']?.toString() ?? ''),
      basketItemsCount: (json['basket_items_count'] is int)
          ? json['basket_items_count']
          : int.tryParse(json['basket_items_count']?.toString() ?? ''),
      placedAtFormatted: json['placed_at_formatted']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
      type: (json['type'] ?? json['order_type'] ?? json['basket_type'])
          ?.toString(),
      deliveryType:
          json['delivery_type'] ?? json['deliveryType'] ?? json['fulfillment_type'],
      isSelfPickup: json['is_self_pickup'] ?? json['isSelfPickup'],
      basketOrders: basketOrders,
      deliveryBoyName:
          (json['delivery_boy_name']?.toString() ??
                  json['delivery_boy']?['name']?.toString() ??
                  json['driver']?['name']?.toString() ??
                  json['driver_name']?.toString() ??
                  json['delivery_boy']?.toString())
              ?.trim(),
      prescriptionImageUrl: _resolveOrderPrescriptionUrl(json),
      prescriptionFileName: _resolveOrderPrescriptionFileName(json),
      rawJson: json,
    );
  }

  static String? _resolveOrderPrescriptionUrl(Map<String, dynamic> json) {
    String? raw;
    final p = json['prescription'] ?? json['prescriptions'];
    if (p is Map) {
      final f = p['file_url'] ??
          p['image_url'] ??
          p['image_path'] ??
          p['image'] ??
          p['prescription_image'] ??
          p['file_path'] ??
          p['file'] ??
          p['url'];
      if (f != null && f.toString().trim().isNotEmpty) {
        raw = f.toString().trim();
      }
    }
    if (raw == null) {
      final direct = json['image_path'] ??
          json['file_path'] ??
          json['image'] ??
          json['prescription_image'] ??
          json['image_url'] ??
          json['file_url'] ??
          json['prescription_file_url'] ??
          json['file'] ??
          json['url'];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        raw = direct.toString().trim();
      }
    }
    if (raw == null && json['images'] is List && (json['images'] as List).isNotEmpty) {
      for (final item in (json['images'] as List)) {
        if (item is String && item.trim().isNotEmpty) {
          raw = item.trim();
          break;
        } else if (item is Map) {
          final v = item['image_path'] ??
              item['url'] ??
              item['file_url'] ??
              item['image'] ??
              item['file_path'] ??
              item['file'];
          if (v != null && v.toString().trim().isNotEmpty) {
            raw = v.toString().trim();
            break;
          }
        }
      }
    }
    if (raw == null) return null;
    var str = raw.trim();
    if (str.isEmpty) return null;
    str = str.replaceAll(r'\', '/');
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    if (str.startsWith('//')) {
      return 'https:$str';
    }
    final base = ApiConfigs.IMAGE_URL.trim();
    final uri = Uri.tryParse(base);
    final origin = (uri != null && uri.hasScheme)
        ? '${uri.scheme}://${uri.host}'
        : 'https://dev.saimpexenterprise.com';
    if (str.startsWith('/storage/')) {
      return '$origin$str';
    }
    if (str.startsWith('storage/')) {
      return '$origin/$str';
    }
    if (str.startsWith('/')) {
      final cleanBase =
          base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      return '$cleanBase$str';
    }
    final cleanBase = base.endsWith('/') ? base : '$base/';
    return '$cleanBase$str';
  }

  static String? _resolveOrderPrescriptionFileName(Map<String, dynamic> json) {
    final directName = json['file_name'] ??
        json['filename'] ??
        json['original_file_name'] ??
        json['original_name'] ??
        json['client_name'];
    if (directName != null && directName.toString().trim().isNotEmpty) {
      return directName.toString().trim();
    }
    final p = json['prescription'] ?? json['prescriptions'];
    if (p is Map) {
      final f = p['file_name'] ??
          p['filename'] ??
          p['original_file_name'] ??
          p['original_name'] ??
          p['client_name'];
      if (f != null && f.toString().trim().isNotEmpty) {
        return f.toString().trim();
      }
    }
    final url = _resolveOrderPrescriptionUrl(json);
    if (url != null && url.isNotEmpty) {
      final name = url.split('?').first.split('/').last;
      if (name.isNotEmpty) return name;
    }
    if (p is Map) {
      final f = p['file'] ??
          p['image_path'] ??
          p['image'] ??
          p['file_path'] ??
          p['prescription_file'] ??
          p['attachment'];
      if (f != null && f.toString().isNotEmpty) {
        final s = f.toString();
        return s.contains('/') ? s.split('/').last : s;
      }
    }
    final direct = json['prescription_file'] ??
        json['file'] ??
        json['image_path'] ??
        json['file_path'] ??
        json['attachment'] ??
        json['image'] ??
        json['prescription_image'];
    if (direct != null && direct.toString().isNotEmpty) {
      final s = direct.toString();
      return s.contains('/') ? s.split('/').last : s;
    }
    return 'Prescription';
  }
}

class Vendor {
  final int? id;
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;
  final int? vendorType;
  final String? image;

  Vendor({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.vendorType,
    this.image,
  });

  factory Vendor.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Vendor();

    return Vendor(
      id: (json['id'] is int)
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      nameEn: json['name_en']?.toString(),
      nameAr: json['name_ar']?.toString(),
      nameFr: json['name_fr']?.toString(),
      vendorType: (json['vendor_type'] is int)
          ? json['vendor_type']
          : int.tryParse(json['vendor_type']?.toString() ?? ''),
      image: json['image']?.toString(),
    );
  }
}

class Message {
  final List<String>? messageEn;
  final List<String>? messageFr;
  final List<String>? messageAr;

  Message({this.messageEn, this.messageFr, this.messageAr});

  factory Message.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Message();

    return Message(
      messageEn: (json['message_en'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      messageFr: (json['message_fr'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      messageAr: (json['message_ar'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}
