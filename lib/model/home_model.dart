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

  HomeData({this.membership, this.summary, this.orders, this.vendor});

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
      expiresInDays: json['expires_in_days'],
      subscriptionEndDate: json['subscription_end_date']?.toString(),
    );
  }
}

class Summary {
  final int? todayOrders;
  final int? totalOrders;
  final int? totalProducts;

  Summary({this.todayOrders, this.totalOrders, this.totalProducts});

  factory Summary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Summary();

    return Summary(
      todayOrders: json['today_orders'],
      totalOrders: json['total_orders'],
      totalProducts: json['total_products'],
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
      currentPage: json['current_page'],
      lastPage: json['last_page'],
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
  final String? placedAtFormatted;
  final String? deliveryBoyName;
  final String? cancelReason;
  final String? type;

  OrderData({
    this.orderCode,
    this.status,
    this.placedAt,
    this.id,
    this.total,
    this.userName,
    this.userEmail,
    this.userMobile,
    this.orderItemsCount,
    this.placedAtFormatted,
    this.deliveryBoyName,
    this.cancelReason,
    this.type,
  });

  factory OrderData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OrderData();

    return OrderData(
      orderCode: json['order_code']?.toString(),
      status: json['status'],
      placedAt: json['placed_at']?.toString(),
      id: json['id'],
      total: json['total']?.toString(),
      userName: json['user_name']?.toString(),
      userEmail: json['user_email']?.toString(),
      userMobile: json['user_mobile']?.toString(),
      orderItemsCount: json['order_items_count'],
      placedAtFormatted: json['placed_at_formatted']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
      type: (json['type'] ?? json['order_type'] ?? json['basket_type'])
          ?.toString(),
      deliveryBoyName:
          (json['delivery_boy_name']?.toString() ??
                  json['delivery_boy']?['name']?.toString() ??
                  json['driver']?['name']?.toString() ??
                  json['driver_name']?.toString() ??
                  json['delivery_boy']?.toString())
              ?.trim(),
    );
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
      id: json['id'],
      nameEn: json['name_en']?.toString(),
      nameAr: json['name_ar']?.toString(),
      nameFr: json['name_fr']?.toString(),
      vendorType: json['vendor_type'],
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
