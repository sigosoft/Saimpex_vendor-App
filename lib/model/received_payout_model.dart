// To parse this JSON data, do
//
//     final receivedPayoutModel = receivedPayoutModelFromJson(jsonString);

import 'dart:convert';

ReceivedPayoutModel receivedPayoutModelFromJson(String str) => ReceivedPayoutModel.fromJson(json.decode(str));

String receivedPayoutModelToJson(ReceivedPayoutModel data) => json.encode(data.toJson());

class ReceivedPayoutModel {
  final String? status;
  final Data? data;
  final Message? message;

  ReceivedPayoutModel({
    this.status,
    this.data,
    this.message,
  });

  factory ReceivedPayoutModel.fromJson(Map<String, dynamic> json) => ReceivedPayoutModel(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"] == null ? null : Message.fromJson(json["message"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message?.toJson(),
  };
}

class Data {
  final Vendor? vendor;
  final ReceivedPayouts? receivedPayouts;

  Data({
    this.vendor,
    this.receivedPayouts,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
    receivedPayouts: json["received_payouts"] == null ? null : ReceivedPayouts.fromJson(json["received_payouts"]),
  );

  Map<String, dynamic> toJson() => {
    "vendor": vendor?.toJson(),
    "received_payouts": receivedPayouts?.toJson(),
  };
}

class ReceivedPayouts {
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

  ReceivedPayouts({
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

  factory ReceivedPayouts.fromJson(Map<String, dynamic> json) => ReceivedPayouts(
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
  final int? vendorId;
  final String? amount;
  final String? balanceAmount;
  final DateTime? paidAt;

  Datum({
    this.id,
    this.vendorId,
    this.amount,
    this.balanceAmount,
    this.paidAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    vendorId: json["vendor_id"],
    amount: json["amount"],
    balanceAmount: json["balance_amount"],
    paidAt: json["paid_at"] == null ? null : DateTime.parse(json["paid_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_id": vendorId,
    "amount": amount,
    "balance_amount": balanceAmount,
    "paid_at": paidAt?.toIso8601String(),
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

class Vendor {
  final int? id;
  final String? name;
  final String? currentBalance;

  Vendor({
    this.id,
    this.name,
    this.currentBalance,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id: json["id"],
    name: json["name"],
    currentBalance: json["current_balance"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "current_balance": currentBalance,
  };
}

class Message {
  final List<String>? messageEn;
  final List<String>? messageFr;
  final List<String>? messageAr;

  Message({
    this.messageEn,
    this.messageFr,
    this.messageAr,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    messageEn: json["message_en"] == null ? [] : List<String>.from(json["message_en"]!.map((x) => x)),
    messageFr: json["message_fr"] == null ? [] : List<String>.from(json["message_fr"]!.map((x) => x)),
    messageAr: json["message_ar"] == null ? [] : List<String>.from(json["message_ar"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "message_en": messageEn == null ? [] : List<dynamic>.from(messageEn!.map((x) => x)),
    "message_fr": messageFr == null ? [] : List<dynamic>.from(messageFr!.map((x) => x)),
    "message_ar": messageAr == null ? [] : List<dynamic>.from(messageAr!.map((x) => x)),
  };
}
