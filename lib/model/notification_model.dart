// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
  final String? status;
  final Data? data;
  final String? message;

  NotificationModel({
    this.status,
    this.data,
    this.message,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
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
  final TitleEn? titleEn;
  final TitleAr? titleAr;
  final TitleFr? titleFr;
  final String? contentEn;
  final String? contentAr;
  final String? contentFr;
  final int? type;
  final int? sendTo;
  final int? userId;
  final int? orderId;
  final DateTime? date;
  final String? time;
  final int? addedBy;
  final dynamic updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Datum({
    this.id,
    this.titleEn,
    this.titleAr,
    this.titleFr,
    this.contentEn,
    this.contentAr,
    this.contentFr,
    this.type,
    this.sendTo,
    this.userId,
    this.orderId,
    this.date,
    this.time,
    this.addedBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    titleEn: titleEnValues.map[json["title_en"]],
    titleAr: titleArValues.map[json["title_ar"]],
    titleFr: titleFrValues.map[json["title_fr"]],
    contentEn: json["content_en"],
    contentAr: json["content_ar"],
    contentFr: json["content_fr"],
    type: json["type"],
    sendTo: json["send_to"],
    userId: json["user_id"],
    orderId: json["order_id"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    time: json["time"],
    addedBy: json["added_by"],
    updatedBy: json["updated_by"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title_en": titleEnValues.reverse[titleEn],
    "title_ar": titleArValues.reverse[titleAr],
    "title_fr": titleFrValues.reverse[titleFr],
    "content_en": contentEn,
    "content_ar": contentAr,
    "content_fr": contentFr,
    "type": type,
    "send_to": sendTo,
    "user_id": userId,
    "order_id": orderId,
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "time": time,
    "added_by": addedBy,
    "updated_by": updatedBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

enum TitleAr {
  EMPTY
}

final titleArValues = EnumValues({
  "نظام جديد!": TitleAr.EMPTY
});

enum TitleEn {
  A_NEW_ORDER
}

final titleEnValues = EnumValues({
  "A new order!": TitleEn.A_NEW_ORDER
});

enum TitleFr {
  UN_NOUVEL_ORDRE
}

final titleFrValues = EnumValues({
  "Un nouvel ordre !": TitleFr.UN_NOUVEL_ORDRE
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
