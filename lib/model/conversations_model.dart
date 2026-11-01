
class ConversationsModel {
  bool? status;
  Data? data;
  String? message;

  ConversationsModel({this.status, this.data, this.message});

  ConversationsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  List<Conversation>? conversations;

  Data({this.conversations});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['conversations'] != null) {
      conversations = <Conversation>[];
      json['conversations'].forEach((v) {
        conversations!.add(Conversation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (conversations != null) {
      data['conversations'] = conversations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Conversation {
  int? id;
  int? customerId;
  int? vendorId;
  int? orderId;
  String? status;
  String? lastMessageAt;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  int? unreadCount;
  LastMessage? lastMessage;
  Customer? customer;
  List<LastMessage>? messages;
  String? image;

  /// API doc §6.43 (V18): booking the chat is about ("Booking #…"), and
  /// the customer's Online status (active in the last 2 minutes).
  String? orderCode;
  bool customerIsOnline = false;
  String? customerLastSeenAt;

  Conversation(
      {this.id,
      this.customerId,
      this.vendorId,
      this.orderId,
      this.status,
      this.lastMessageAt,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.unreadCount,
      this.lastMessage,
      this.customer,
      this.messages,
      this.image});

  Conversation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    vendorId = json['vendor_id'];
    orderId = json['order_id'];
    status = json['status'];
    lastMessageAt = json['last_message_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    unreadCount = json['unread_count'];
    orderCode = json['order_code']?.toString();
    customerIsOnline = json['customer_is_online'] == true || json['customer_is_online']?.toString() == '1';
    customerLastSeenAt = json['customer_last_seen_at']?.toString();
    image = json['image']?.toString() ??
        (json['customer'] is Map ? json['customer']['image']?.toString() : null);
    lastMessage = json['last_message'] != null
        ? LastMessage.fromJson(json['last_message'])
        : null;
    customer = json['customer'] != null
        ? Customer.fromJson(json['customer'])
        : null;
    if (json['messages'] != null) {
      messages = <LastMessage>[];
      json['messages'].forEach((v) {
        messages!.add(LastMessage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['vendor_id'] = vendorId;
    data['order_id'] = orderId;
    data['status'] = status;
    data['last_message_at'] = lastMessageAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['unread_count'] = unreadCount;
    if (lastMessage != null) {
      data['last_message'] = lastMessage!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LastMessage {
  int? id;
  int? conversationId;
  String? senderType;
  int? senderId;
  String? message;
  String? messageType;
  String? attachmentUrl;
  bool? isRead;
  String? readAt;
  String? createdAt;
  String? updatedAt;

  LastMessage(
      {this.id,
      this.conversationId,
      this.senderType,
      this.senderId,
      this.message,
      this.messageType,
      this.attachmentUrl,
      this.isRead,
      this.readAt,
      this.createdAt,
      this.updatedAt});

  LastMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderType = json['sender_type'];
    senderId = json['sender_id'];
    message = json['message'];
    messageType = json['message_type'];
    attachmentUrl = json['attachment_url'];
    isRead = json['is_read'];
    readAt = json['read_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['sender_type'] = senderType;
    data['sender_id'] = senderId;
    data['message'] = message;
    data['message_type'] = messageType;
    data['attachment_url'] = attachmentUrl;
    data['is_read'] = isRead;
    data['read_at'] = readAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Customer {
  int? id;
  String? name;
  String? mobile;
  String? image;
  int? countryCodeId;
  CountryCode? countryCode;

  Customer(
      {this.id,
      this.name,
      this.mobile,
      this.image,
      this.countryCodeId,
      this.countryCode});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
    image = json['image'];
    countryCodeId = json['country_code_id'];
    countryCode = json['country_code'] != null
        ? CountryCode.fromJson(json['country_code'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['mobile'] = mobile;
    data['image'] = image;
    data['country_code_id'] = countryCodeId;
    if (countryCode != null) {
      data['country_code'] = countryCode!.toJson();
    }
    return data;
  }
}

class CountryCode {
  int? id;
  String? countryCode;

  CountryCode({this.id, this.countryCode});

  CountryCode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryCode = json['country_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['country_code'] = countryCode;
    return data;
  }
}
