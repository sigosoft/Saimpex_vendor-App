// To parse this JSON data, do
//
//     final orderDetailsModel = orderDetailsModelFromJson(jsonString);

import 'dart:convert';

OrderDetailsModel orderDetailsModelFromJson(String str) =>
    OrderDetailsModel.fromJson(json.decode(str));

String orderDetailsModelToJson(OrderDetailsModel data) =>
    json.encode(data.toJson());

class OrderDetailsModel {
  final String? status;
  final Data? data;
  final Message? message;

  OrderDetailsModel({this.status, this.data, this.message});

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailsModel(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"] == null
            ? null
            : Message.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message?.toJson(),
  };
}

class Data {
  final int? id;
  final String? orderCode;
  final int? status;
  final DateTime? placedAt;
  final String? paymentType;
  final String? subtotal;
  final String? tax;
  final String? deliveryFee;
  final String? total;
  final int? userId;
  final String? location;
  final String? latitude;
  final String? longitude;
  final DateTime? createdAt;
  final dynamic customerNote;
  final String? userName;
  final dynamic userEmail;
  final dynamic userAddress;
  final String? userMobile;
  final String? deliveryBoyName;
  final String? deliveryBoyPhone;
  final String? countryCode;
  final String? deliveryBoyImage;
  final String? deliveryCountryCode;
  final DateTime? payedOn;
  final List<OrderItem>? orderItems;
  final List<BasketOrder>? basketOrders;
  final OrderDurations? orderDurations;
  final String? type;
  final dynamic deliveryType;
  final dynamic isSelfPickup;
  final List<StatusLog>? statusLogs;

  Data({
    this.id,
    this.orderCode,
    this.status,
    this.placedAt,
    this.paymentType,
    this.type,
    this.deliveryType,
    this.isSelfPickup,
    this.subtotal,
    this.tax,
    this.deliveryFee,
    this.total,
    this.userId,
    this.location,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.customerNote,
    this.userName,
    this.userEmail,
    this.userAddress,
    this.userMobile,
    this.deliveryBoyName,
    this.deliveryBoyPhone,
    this.countryCode,
    this.deliveryBoyImage,
    this.deliveryCountryCode,
    this.payedOn,
    this.orderItems,
    this.basketOrders,
    this.orderDurations,
    this.statusLogs,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: (json["id"] is int)
        ? json["id"]
        : int.tryParse(json["id"]?.toString() ?? ''),
    orderCode: json["order_code"],
    status: (json["status"] is int)
        ? json["status"]
        : int.tryParse(json["status"]?.toString() ?? ''),
    placedAt: json["placed_at"] == null
        ? null
        : DateTime.parse(json["placed_at"]),
    paymentType: json["payment_type"],
    type: (json["type"] ?? json["order_type"] ?? json["basket_type"])
        ?.toString(),
    deliveryType:
        json["delivery_type"] ?? json["deliveryType"] ?? json["fulfillment_type"],
    isSelfPickup: json["is_self_pickup"] ?? json["isSelfPickup"],
    subtotal: json["subtotal"],
    tax: json["tax"],
    deliveryFee: json["delivery_fee"],
    total: json["total"],
    userId: (json["user_id"] is int)
        ? json["user_id"]
        : int.tryParse(json["user_id"]?.toString() ?? ''),
    location: json["location"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    customerNote: json["customer_note"],
    userName: json["user_name"],
    userEmail: json["user_email"],
    userAddress: json["user_address"],
    userMobile: json["user_mobile"],
    deliveryBoyName: json["delivery_boy_name"],
    deliveryBoyPhone: json["delivery_boy_phone"],
    countryCode: json["country_code"],
    deliveryBoyImage: json["delivery_boy_image"],
    deliveryCountryCode: json["delivery_country_code"],
    payedOn: json["payed_on"] == null ? null : DateTime.parse(json["payed_on"]),
    orderItems: json["orderItems"] == null
        ? []
        : List<OrderItem>.from(
            json["orderItems"]!.map((x) => OrderItem.fromJson(x)),
          ),
    basketOrders: json["basket_orders"] == null
        ? []
        : List<BasketOrder>.from(
            json["basket_orders"]!.map((x) => BasketOrder.fromJson(x)),
          ),
    orderDurations: json["order_durations"] == null
        ? null
        : OrderDurations.fromJson(json["order_durations"]),
    statusLogs: json["status_logs"] == null
        ? []
        : List<StatusLog>.from(
            json["status_logs"]!.map((x) => StatusLog.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_code": orderCode,
    "status": status,
    "placed_at": placedAt?.toIso8601String(),
    "payment_type": paymentType,
    "type": type,
    "delivery_type": deliveryType,
    "is_self_pickup": isSelfPickup,
    "subtotal": subtotal,
    "tax": tax,
    "delivery_fee": deliveryFee,
    "total": total,
    "user_id": userId,
    "location": location,
    "latitude": latitude,
    "longitude": longitude,
    "created_at": createdAt?.toIso8601String(),
    "customer_note": customerNote,
    "user_name": userName,
    "user_email": userEmail,
    "user_address": userAddress,
    "user_mobile": userMobile,
    "delivery_boy_name": deliveryBoyName,
    "delivery_boy_phone": deliveryBoyPhone,
    "country_code": countryCode,
    "delivery_boy_image": deliveryBoyImage,
    "delivery_country_code": deliveryCountryCode,
    "payed_on": payedOn?.toIso8601String(),
    "orderItems": orderItems == null
        ? []
        : List<dynamic>.from(orderItems!.map((x) => x.toJson())),
    "basket_orders": basketOrders == null
        ? []
        : List<dynamic>.from(basketOrders!.map((x) => x.toJson())),
    "order_durations": orderDurations?.toJson(),
    "status_logs": statusLogs == null
        ? []
        : List<dynamic>.from(statusLogs!.map((x) => x.toJson())),
  };
}

class OrderDurations {
  final int? id;
  final int? orderId;
  final dynamic restaurantAcceptanceDuration;
  final dynamic preparationStartDuration;
  final dynamic preparationDuration;
  final dynamic deliveryPartnerToRestaurantDuration;
  final dynamic pickupWaitDuration;
  final dynamic restaurantToCustomerDuration;
  final dynamic totalDuration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderDurations({
    this.id,
    this.orderId,
    this.restaurantAcceptanceDuration,
    this.preparationStartDuration,
    this.preparationDuration,
    this.deliveryPartnerToRestaurantDuration,
    this.pickupWaitDuration,
    this.restaurantToCustomerDuration,
    this.totalDuration,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderDurations.fromJson(Map<String, dynamic> json) => OrderDurations(
    id: (json["id"] is int)
        ? json["id"]
        : int.tryParse(json["id"]?.toString() ?? ''),
    orderId: (json["order_id"] is int)
        ? json["order_id"]
        : int.tryParse(json["order_id"]?.toString() ?? ''),
    restaurantAcceptanceDuration: json["restaurant_acceptance_duration"],
    preparationStartDuration: json["preparation_start_duration"],
    preparationDuration: json["preparation_duration"],
    deliveryPartnerToRestaurantDuration:
        json["delivery_partner_to_restaurant_duration"],
    pickupWaitDuration: json["pickup_wait_duration"],
    restaurantToCustomerDuration: json["restaurant_to_customer_duration"],
    totalDuration: json["total_duration"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "restaurant_acceptance_duration": restaurantAcceptanceDuration,
    "preparation_start_duration": preparationStartDuration,
    "preparation_duration": preparationDuration,
    "delivery_partner_to_restaurant_duration":
        deliveryPartnerToRestaurantDuration,
    "pickup_wait_duration": pickupWaitDuration,
    "restaurant_to_customer_duration": restaurantToCustomerDuration,
    "total_duration": totalDuration,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class OrderItem {
  final OrderItemClass? orderItem;
  final String? unitPrice;
  final int? quantity;
  final String? price;
  final dynamic image;

  OrderItem({
    this.orderItem,
    this.unitPrice,
    this.quantity,
    this.price,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    orderItem: json["order_item"] == null
        ? null
        : OrderItemClass.fromJson(json["order_item"]),
    unitPrice: json["unit_price"],
    quantity: (json["quantity"] is int)
        ? json["quantity"]
        : int.tryParse(json["quantity"]?.toString() ?? ''),
    price: json["price"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "order_item": orderItem?.toJson(),
    "unit_price": unitPrice,
    "quantity": quantity,
    "price": price,
    "image": image,
  };
}

class OrderItemClass {
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;

  OrderItemClass({this.nameEn, this.nameAr, this.nameFr});

  factory OrderItemClass.fromJson(Map<String, dynamic> json) => OrderItemClass(
    nameEn: json["name_en"],
    nameAr: json["name_ar"],
    nameFr: json["name_fr"],
  );

  Map<String, dynamic> toJson() => {
    "name_en": nameEn,
    "name_ar": nameAr,
    "name_fr": nameFr,
  };
}

class StatusLog {
  final int? status;
  final String? text;
  final String? remark;
  final String? updatedAt;

  StatusLog({this.status, this.text, this.remark, this.updatedAt});

  factory StatusLog.fromJson(Map<String, dynamic> json) => StatusLog(
    status: (json["status"] is int)
        ? json["status"]
        : int.tryParse(json["status"]?.toString() ?? ''),
    text: json["text"],
    remark: json["remark"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "text": text,
    "remark": remark,
    "updated_at": updatedAt,
  };
}

class Message {
  final List<String>? messageEn;
  final List<String>? messageFr;
  final List<String>? messageAr;

  Message({this.messageEn, this.messageFr, this.messageAr});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    messageEn: json["message_en"] == null
        ? []
        : List<String>.from(json["message_en"]!.map((x) => x)),
    messageFr: json["message_fr"] == null
        ? []
        : List<String>.from(json["message_fr"]!.map((x) => x)),
    messageAr: json["message_ar"] == null
        ? []
        : List<String>.from(json["message_ar"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "message_en": messageEn == null
        ? []
        : List<dynamic>.from(messageEn!.map((x) => x)),
    "message_fr": messageFr == null
        ? []
        : List<dynamic>.from(messageFr!.map((x) => x)),
    "message_ar": messageAr == null
        ? []
        : List<dynamic>.from(messageAr!.map((x) => x)),
  };
}

class BasketOrder {
  final int? id;
  final int? basketId;
  final int? userId;
  final int? orderId;
  final String? purchaseDate;
  final String? location;
  final String? latitude;
  final String? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BasketDetail? basket;

  BasketOrder({
    this.id,
    this.basketId,
    this.userId,
    this.orderId,
    this.purchaseDate,
    this.location,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.basket,
  });

  factory BasketOrder.fromJson(Map<String, dynamic> json) => BasketOrder(
    id: (json["id"] is int)
        ? json["id"]
        : int.tryParse(json["id"]?.toString() ?? ''),
    basketId: (json["basket_id"] is int)
        ? json["basket_id"]
        : int.tryParse(json["basket_id"]?.toString() ?? ''),
    userId: (json["user_id"] is int)
        ? json["user_id"]
        : int.tryParse(json["user_id"]?.toString() ?? ''),
    orderId: (json["order_id"] is int)
        ? json["order_id"]
        : int.tryParse(json["order_id"]?.toString() ?? ''),
    purchaseDate: json["purchase_date"],
    location: json["location"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    basket:
        json["basket"] == null ? null : BasketDetail.fromJson(json["basket"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "basket_id": basketId,
    "user_id": userId,
    "order_id": orderId,
    "purchase_date": purchaseDate,
    "location": location,
    "latitude": latitude,
    "longitude": longitude,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "basket": basket?.toJson(),
  };
}

class BasketDetail {
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
  final List<BasketItem>? basketItems;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BasketDetail({
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
    this.basketItems,
    this.createdAt,
    this.updatedAt,
  });

  factory BasketDetail.fromJson(Map<String, dynamic> json) => BasketDetail(
    id: (json["id"] is int)
        ? json["id"]
        : int.tryParse(json["id"]?.toString() ?? ''),
    basketNameEn: json["basket_name_en"],
    basketNameAr: json["basket_name_ar"],
    basketNameFr: json["basket_name_fr"],
    basketType: (json["basket_type"] is int)
        ? json["basket_type"]
        : int.tryParse(json["basket_type"]?.toString() ?? ''),
    descriptionEn: json["description_en"],
    descriptionAr: json["description_ar"],
    descriptionFr: json["description_fr"],
    image: json["image"],
    quantity: (json["quantity"] is int)
        ? json["quantity"]
        : int.tryParse(json["quantity"]?.toString() ?? ''),
    status: (json["status"] is int)
        ? json["status"]
        : int.tryParse(json["status"]?.toString() ?? ''),
    vendorId: (json["vendor_id"] is int)
        ? json["vendor_id"]
        : int.tryParse(json["vendor_id"]?.toString() ?? ''),
    redeemPoints: (json["redeem_points"] is int)
        ? json["redeem_points"]
        : int.tryParse(json["redeem_points"]?.toString() ?? ''),
    price: json["price"],
    basketItems: json["basket_items"] == null
        ? []
        : List<BasketItem>.from(
            json["basket_items"]!.map((x) => BasketItem.fromJson(x)),
          ),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
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
    "basket_items": basketItems == null
        ? []
        : List<dynamic>.from(basketItems!.map((x) => x.toJson())),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class BasketItem {
  final int? id;
  final int? basketId;
  final int? restaurantMenuId;
  final int? groceryMenuId;
  final int? quantity;
  final BasketMenuItem? restaurantMenu;
  final BasketMenuItem? groceryMenu;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BasketItem({
    this.id,
    this.basketId,
    this.restaurantMenuId,
    this.groceryMenuId,
    this.quantity,
    this.restaurantMenu,
    this.groceryMenu,
    this.createdAt,
    this.updatedAt,
  });

  factory BasketItem.fromJson(Map<String, dynamic> json) => BasketItem(
    id: (json["id"] is int)
        ? json["id"]
        : int.tryParse(json["id"]?.toString() ?? ''),
    basketId: (json["basket_id"] is int)
        ? json["basket_id"]
        : int.tryParse(json["basket_id"]?.toString() ?? ''),
    restaurantMenuId: (json["restaurant_menu_id"] is int)
        ? json["restaurant_menu_id"]
        : int.tryParse(json["restaurant_menu_id"]?.toString() ?? ''),
    groceryMenuId: (json["grocery_menu_id"] is int)
        ? json["grocery_menu_id"]
        : int.tryParse(json["grocery_menu_id"]?.toString() ?? ''),
    quantity: (json["quantity"] is int)
        ? json["quantity"]
        : int.tryParse(json["quantity"]?.toString() ?? ''),
    restaurantMenu: json["restaurant_menu"] == null
        ? null
        : BasketMenuItem.fromJson(json["restaurant_menu"]),
    groceryMenu: json["grocery_menu"] == null
        ? null
        : BasketMenuItem.fromJson(json["grocery_menu"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "basket_id": basketId,
    "restaurant_menu_id": restaurantMenuId,
    "grocery_menu_id": groceryMenuId,
    "quantity": quantity,
    "restaurant_menu": restaurantMenu?.toJson(),
    "grocery_menu": groceryMenu?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class BasketMenuItem {
  final int? id;
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;
  final String? image;
  final int? isVeg;

  BasketMenuItem({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.image,
    this.isVeg,
  });

  factory BasketMenuItem.fromJson(Map<String, dynamic> json) => BasketMenuItem(
    id: (json["id"] is int)
        ? json["id"]
        : int.tryParse(json["id"]?.toString() ?? ''),
    nameEn: json["name_en"],
    nameAr: json["name_ar"],
    nameFr: json["name_fr"],
    image: json["image"],
    isVeg: (json["is_veg"] is int)
        ? json["is_veg"]
        : int.tryParse(json["is_veg"]?.toString() ?? ''),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name_en": nameEn,
    "name_ar": nameAr,
    "name_fr": nameFr,
    "image": image,
    "is_veg": isVeg,
  };
}
