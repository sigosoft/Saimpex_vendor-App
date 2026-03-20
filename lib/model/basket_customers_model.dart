// To parse this JSON data, do
//
//     final basketCustomersModel = basketCustomersModelFromJson(jsonString);

import 'dart:convert';

BasketCustomersModel basketCustomersModelFromJson(String str) => BasketCustomersModel.fromJson(json.decode(str));

String basketCustomersModelToJson(BasketCustomersModel data) => json.encode(data.toJson());

class BasketCustomersModel {
  final bool? status;
  final Data? data;
  final String? message;

  BasketCustomersModel({
    this.status,
    this.data,
    this.message,
  });

  factory BasketCustomersModel.fromJson(Map<String, dynamic> json) => BasketCustomersModel(
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
  final Basket? basket;
  final RedeemedCustomers? redeemedCustomers;

  Data({
    this.basket,
    this.redeemedCustomers,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    basket: json["basket"] == null ? null : Basket.fromJson(json["basket"]),
    redeemedCustomers: json["redeemed_customers"] == null ? null : RedeemedCustomers.fromJson(json["redeemed_customers"]),
  );

  Map<String, dynamic> toJson() => {
    "basket": basket?.toJson(),
    "redeemed_customers": redeemedCustomers?.toJson(),
  };
}

class Basket {
  final int? id;
  final String? basketNameEn;
  final String? basketNameAr;
  final String? basketNameFr;
  final int? basketType;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? descriptionFr;
  final String? image;
  final int? quantity;
  final int? status;
  final int? vendorId;
  final int? redeemPoints;
  final String? price;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Basket({
    this.id,
    this.basketNameEn,
    this.basketNameAr,
    this.basketNameFr,
    this.basketType,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionFr,
    this.image,
    this.quantity,
    this.status,
    this.vendorId,
    this.redeemPoints,
    this.price,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Basket.fromJson(Map<String, dynamic> json) => Basket(
    id: json["id"],
    basketNameEn: json["basket_name_en"],
    basketNameAr: json["basket_name_ar"],
    basketNameFr: json["basket_name_fr"],
    basketType: json["basket_type"],
    descriptionEn: json["description_en"],
    descriptionAr: json["description_ar"],
    descriptionFr: json["description_fr"],
    image: json["image"],
    quantity: json["quantity"],
    status: json["status"],
    vendorId: json["vendor_id"],
    redeemPoints: json["redeem_points"],
    price: json["price"],
    deletedAt: json["deleted_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "basket_name_en": basketNameEn,
    "basket_name_ar": basketNameAr,
    "basket_name_fr": basketNameFr,
    "basket_type": basketType,
    "description_en": descriptionEn,
    "description_ar": descriptionAr,
    "description_fr": descriptionFr,
    "image": image,
    "quantity": quantity,
    "status": status,
    "vendor_id": vendorId,
    "redeem_points": redeemPoints,
    "price": price,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class RedeemedCustomers {
  final int? currentPage;
  final List<Datum>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final dynamic nextPageUrl;
  final String? path;
  final int? perPage;
  final dynamic prevPageUrl;
  final int? to;
  final int? total;

  RedeemedCustomers({
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

  factory RedeemedCustomers.fromJson(Map<String, dynamic> json) => RedeemedCustomers(
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
  final int? basketId;
  final int? userId;
  final DateTime? purchaseDate;
  final String? location;
  final String? latitude;
  final String? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userName;
  final dynamic userEmail;
  final String? userMobile;
  final String? countryCode;
  final int? redeemPoints;
  final int? totalItems;

  Datum({
    this.id,
    this.basketId,
    this.userId,
    this.purchaseDate,
    this.location,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userEmail,
    this.userMobile,
    this.countryCode,
    this.redeemPoints,
    this.totalItems,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    basketId: json["basket_id"],
    userId: json["user_id"],
    purchaseDate: json["purchase_date"] == null ? null : DateTime.parse(json["purchase_date"]),
    location: json["location"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    userName: json["user_name"],
    userEmail: json["user_email"],
    userMobile: json["user_mobile"],
    countryCode: json["country_code"],
    redeemPoints: json["redeem_points"],
    totalItems: json["total_items"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "basket_id": basketId,
    "user_id": userId,
    "purchase_date": purchaseDate?.toIso8601String(),
    "location": location,
    "latitude": latitude,
    "longitude": longitude,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "user_name": userName,
    "user_email": userEmail,
    "user_mobile": userMobile,
    "country_code": countryCode,
    "redeem_points": redeemPoints,
    "total_items": totalItems,
  };
}

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
