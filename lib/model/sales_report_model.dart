// To parse this JSON data, do
//
//     final salesReportModel = salesReportModelFromJson(jsonString);

import 'dart:convert';

SalesReportModel salesReportModelFromJson(String str) => SalesReportModel.fromJson(json.decode(str));

String salesReportModelToJson(SalesReportModel data) => json.encode(data.toJson());

class SalesReportModel {
  final bool? status;
  final Data? data;
  final String? message;

  SalesReportModel({
    this.status,
    this.data,
    this.message,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) => SalesReportModel(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  final int? currentPage;
  final List<Datum>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final dynamic prevPageUrl;
  final int? to;
  final int? total;

  Data({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: json["links"] == null ? [] : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": links == null ? [] : List<dynamic>.from(links!.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Datum {
  final int? id;
  final String? orderCode;
  final int? userId;
  final int? vendorId;
  final int? deliveryBoyId;
  final int? orderType;
  final String? subtotal;
  final String? discount;
  final String? couponCode;
  final String? deliveryFee;
  final String? tax;
  final String? total;
  final int? paymentStatus;
  final String? paymentType;
  final dynamic paymentId;
  final dynamic notes;
  final String? location;
  final String? latitude;
  final String? longitude;
  final int? status;
  final DateTime? placedAt;
  final DateTime? deliveredAt;
  final dynamic cancelledAt;
  final dynamic cancelledBy;
  final dynamic cancelledUser;
  final String? distanceKm;
  final String? deliveryPerKmAmount;
  final String? deliveryPerOrderAmount;
  final String? deliveryFeeValue;
  final int? deliveryType;
  final String? deliveryNotes;
  final int? readStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserName? userName;
  final String? userDisplayName;
  final dynamic userEmail;
  final String? userMobile;
  final String? countryCode;
  final List<OrderEarning>? orderEarnings;

  Datum({
    this.id,
    this.orderCode,
    this.userId,
    this.vendorId,
    this.deliveryBoyId,
    this.orderType,
    this.subtotal,
    this.discount,
    this.couponCode,
    this.deliveryFee,
    this.tax,
    this.total,
    this.paymentStatus,
    this.paymentType,
    this.paymentId,
    this.notes,
    this.location,
    this.latitude,
    this.longitude,
    this.status,
    this.placedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancelledUser,
    this.distanceKm,
    this.deliveryPerKmAmount,
    this.deliveryPerOrderAmount,
    this.deliveryFeeValue,
    this.deliveryType,
    this.deliveryNotes,
    this.readStatus,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userDisplayName,
    this.userEmail,
    this.userMobile,
    this.countryCode,
    this.orderEarnings,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    orderCode: json["order_code"],
    userId: json["user_id"],
    vendorId: json["vendor_id"],
    deliveryBoyId: json["delivery_boy_id"],
    orderType: json["order_type"],
    subtotal: json["subtotal"],
    discount: json["discount"],
    couponCode: json["coupon_code"],
    deliveryFee: json["delivery_fee"],
    tax: json["tax"],
    total: json["total"],
    paymentStatus: json["payment_status"],
    paymentType: json["payment_type"],
    paymentId: json["payment_id"],
    notes: json["notes"],
    location: json["location"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    status: json["status"],
    placedAt: json["placed_at"] == null ? null : DateTime.parse(json["placed_at"]),
    deliveredAt: json["delivered_at"] == null ? null : DateTime.parse(json["delivered_at"]),
    cancelledAt: json["cancelled_at"],
    cancelledBy: json["cancelled_by"],
    cancelledUser: json["cancelled_user"],
    distanceKm: json["distance_km"],
    deliveryPerKmAmount: json["delivery_per_km_amount"],
    deliveryPerOrderAmount: json["delivery_per_order_amount"],
    deliveryFeeValue: json["delivery_fee_value"],
    deliveryType: json["delivery_type"],
    deliveryNotes: json["delivery_notes"],
    readStatus: json["read_status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    userName: json["user_name"] != null ? userNameValues.map[json["user_name"]] : null,
    userDisplayName: json["user_name"]?.toString(),
    userEmail: json["user_email"],
    userMobile: json["user_mobile"],
    countryCode: json["country_code"],
    orderEarnings: json["order_earnings"] == null ? [] : List<OrderEarning>.from(json["order_earnings"]!.map((x) => OrderEarning.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_code": orderCode,
    "user_id": userId,
    "vendor_id": vendorId,
    "delivery_boy_id": deliveryBoyId,
    "order_type": orderType,
    "subtotal": subtotal,
    "discount": discount,
    "coupon_code": couponCode,
    "delivery_fee": deliveryFee,
    "tax": tax,
    "total": total,
    "payment_status": paymentStatus,
    "payment_type": paymentType,
    "payment_id": paymentId,
    "notes": notes,
    "location": location,
    "latitude": latitude,
    "longitude": longitude,
    "status": status,
    "placed_at": placedAt?.toIso8601String(),
    "delivered_at": deliveredAt?.toIso8601String(),
    "cancelled_at": cancelledAt,
    "cancelled_by": cancelledBy,
    "cancelled_user": cancelledUser,
    "distance_km": distanceKm,
    "delivery_per_km_amount": deliveryPerKmAmount,
    "delivery_per_order_amount": deliveryPerOrderAmount,
    "delivery_fee_value": deliveryFeeValue,
    "delivery_type": deliveryType,
    "delivery_notes": deliveryNotes,
    "read_status": readStatus,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "user_name": userNameValues.reverse[userName],
    "user_email": userEmail,
    "user_mobile": userMobile,
    "country_code": countryCode,
    "order_earnings": orderEarnings == null ? [] : List<dynamic>.from(orderEarnings!.map((x) => x.toJson())),
  };
}

class OrderEarning {
  final int? id;
  final int? orderId;
  final int? vendorId;
  final String? orderAmount;
  final String? commissionAmount;
  final String? deliveryAmount;
  final String? taxAmount;
  final String? totalAmount;
  final int? addedBy;
  final int? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderEarning({
    this.id,
    this.orderId,
    this.vendorId,
    this.orderAmount,
    this.commissionAmount,
    this.deliveryAmount,
    this.taxAmount,
    this.totalAmount,
    this.addedBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderEarning.fromJson(Map<String, dynamic> json) => OrderEarning(
    id: json["id"],
    orderId: json["order_id"],
    vendorId: json["vendor_id"],
    orderAmount: json["order_amount"],
    commissionAmount: json["commission_amount"],
    deliveryAmount: json["delivery_amount"],
    taxAmount: json["tax_amount"],
    totalAmount: json["total_amount"],
    addedBy: json["added_by"],
    updatedBy: json["updated_by"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "vendor_id": vendorId,
    "order_amount": orderAmount,
    "commission_amount": commissionAmount,
    "delivery_amount": deliveryAmount,
    "tax_amount": taxAmount,
    "total_amount": totalAmount,
    "added_by": addedBy,
    "updated_by": updatedBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

enum UserName {
  SAJIN_JOHNSON,
  TESTER,
  TEST_ACCOUNT
}

final userNameValues = EnumValues({
  "Sajin Johnson": UserName.SAJIN_JOHNSON,
  "Tester": UserName.TESTER,
  "Test Account": UserName.TEST_ACCOUNT
});

class Link {
  final String? url;
  final String? label;
  final int? page;
  final bool? active;

  Link({
    this.url,
    this.label,
    this.page,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    page: json["page"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "page": page,
    "active": active,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
