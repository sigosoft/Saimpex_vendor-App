// To parse this JSON data, do
//
//     final basketDetailsModel = basketDetailsModelFromJson(jsonString);

import 'dart:convert';

BasketDetailsModel basketDetailsModelFromJson(String str) => BasketDetailsModel.fromJson(json.decode(str));

String basketDetailsModelToJson(BasketDetailsModel data) => json.encode(data.toJson());

class BasketDetailsModel {
  final bool? status;
  final Data? data;
  final String? message;

  BasketDetailsModel({
    this.status,
    this.data,
    this.message,
  });

  factory BasketDetailsModel.fromJson(Map<String, dynamic> json) => BasketDetailsModel(
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
  final int? id;
  final String? basketNameEn;
  final String? basketNameAr;
  final String? basketNameFr;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? descriptionFr;
  final String? image;
  final int? basketType;
  final int? quantity;
  final int? status;
  final int? redeemPoints;
  final String? price;
  final int? vendorId;
  final String? vendorName;
  final String? vendorNameAr;
  final String? vendorNameFr;
  final String? vendorAddress;
  final String? vendorLatitude;
  final String? vendorLongitude;
  final int? basketItemsCount;
  final int? basketOrdersCount;
  final List<BasketItem>? basketItems;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Data({
    this.id,
    this.basketNameEn,
    this.basketNameAr,
    this.basketNameFr,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionFr,
    this.image,
    this.basketType,
    this.quantity,
    this.status,
    this.redeemPoints,
    this.price,
    this.vendorId,
    this.vendorName,
    this.vendorNameAr,
    this.vendorNameFr,
    this.vendorAddress,
    this.vendorLatitude,
    this.vendorLongitude,
    this.basketItemsCount,
    this.basketOrdersCount,
    this.basketItems,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    basketNameEn: json["basket_name_en"],
    basketNameAr: json["basket_name_ar"],
    basketNameFr: json["basket_name_fr"],
    descriptionEn: json["description_en"],
    descriptionAr: json["description_ar"],
    descriptionFr: json["description_fr"],
    image: json["image"],
    basketType: json["basket_type"],
    quantity: json["quantity"],
    status: json["status"],
    redeemPoints: json["redeem_points"],
    price: json["price"],
    vendorId: json["vendor_id"],
    vendorName: json["vendor_name"],
    vendorNameAr: json["vendor_name_ar"],
    vendorNameFr: json["vendor_name_fr"],
    vendorAddress: json["vendor_address"],
    vendorLatitude: json["vendor_latitude"],
    vendorLongitude: json["vendor_longitude"],
    basketItemsCount: json["basket_items_count"],
    basketOrdersCount: json["basket_orders_count"],
    basketItems: json["basket_items"] == null ? [] : List<BasketItem>.from(json["basket_items"]!.map((x) => BasketItem.fromJson(x))),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "basket_name_en": basketNameEn,
    "basket_name_ar": basketNameAr,
    "basket_name_fr": basketNameFr,
    "description_en": descriptionEn,
    "description_ar": descriptionAr,
    "description_fr": descriptionFr,
    "image": image,
    "basket_type": basketType,
    "quantity": quantity,
    "status": status,
    "redeem_points": redeemPoints,
    "price": price,
    "vendor_id": vendorId,
    "vendor_name": vendorName,
    "vendor_name_ar": vendorNameAr,
    "vendor_name_fr": vendorNameFr,
    "vendor_address": vendorAddress,
    "vendor_latitude": vendorLatitude,
    "vendor_longitude": vendorLongitude,
    "basket_items_count": basketItemsCount,
    "basket_orders_count": basketOrdersCount,
    "basket_items": basketItems == null ? [] : List<dynamic>.from(basketItems!.map((x) => x.toJson())),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class BasketItem {
  final int? id;
  final int? quantity;
  final int? menuId;
  final String? menuNameEn;
  final String? menuNameAr;
  final String? menuNameFr;
  final String? menuImage;
  final dynamic menuDescriptionEn;
  final dynamic menuDescriptionAr;
  final dynamic menuDescriptionFr;

  BasketItem({
    this.id,
    this.quantity,
    this.menuId,
    this.menuNameEn,
    this.menuNameAr,
    this.menuNameFr,
    this.menuImage,
    this.menuDescriptionEn,
    this.menuDescriptionAr,
    this.menuDescriptionFr,
  });

  factory BasketItem.fromJson(Map<String, dynamic> json) => BasketItem(
    id: json["id"],
    quantity: json["quantity"],
    menuId: json["menu_id"],
    menuNameEn: json["menu_name_en"],
    menuNameAr: json["menu_name_ar"],
    menuNameFr: json["menu_name_fr"],
    menuImage: json["menu_image"],
    menuDescriptionEn: json["menu_description_en"],
    menuDescriptionAr: json["menu_description_ar"],
    menuDescriptionFr: json["menu_description_fr"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "menu_id": menuId,
    "menu_name_en": menuNameEn,
    "menu_name_ar": menuNameAr,
    "menu_name_fr": menuNameFr,
    "menu_image": menuImage,
    "menu_description_en": menuDescriptionEn,
    "menu_description_ar": menuDescriptionAr,
    "menu_description_fr": menuDescriptionFr,
  };
}
