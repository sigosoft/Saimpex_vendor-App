// To parse this JSON data, do
//
//     final basketModel = basketModelFromJson(jsonString);

import 'dart:convert';

BasketModel basketModelFromJson(String str) => BasketModel.fromJson(json.decode(str));

String basketModelToJson(BasketModel data) => json.encode(data.toJson());

class BasketModel {
  final String? status;
  final Data? data;
  final String? message;

  BasketModel({
    this.status,
    this.data,
    this.message,
  });

  factory BasketModel.fromJson(Map<String, dynamic> json) => BasketModel(
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
  final dynamic nextPageUrl;
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
  final String? vendorName;
  final int? basketItemsCount;

  Datum({
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
    this.vendorName,
    this.basketItemsCount,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
    vendorName: json["vendor_name"],
    basketItemsCount: json["basket_items_count"],
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
    "vendor_name": vendorName,
    "basket_items_count": basketItemsCount,
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
