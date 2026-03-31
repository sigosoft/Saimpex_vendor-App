class SuccessModel {
  final String? status;
  final List<dynamic>? data;
  final Message? message;

  SuccessModel({this.status, this.data, this.message});

  factory SuccessModel.fromJson(Map<String, dynamic>? json) {
    return SuccessModel(
      status: json?['status']?.toString(),
      data: json?['data'] as List<dynamic>? ?? [],
      message: json?['message'] != null
          ? Message.fromJson(json?['message'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"status": status, "data": data ?? [], "message": message?.toJson()};
  }
}

class Message {
  final List<String>? messageEn;
  final List<String>? messageFr;
  final List<String>? messageAr;

  Message({this.messageEn, this.messageFr, this.messageAr});

  factory Message.fromJson(Map<String, dynamic>? json) {
    return Message(
      messageEn:
          (json?['message_en'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      messageFr:
          (json?['message_fr'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      messageAr:
          (json?['message_ar'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message_en": messageEn ?? [],
      "message_fr": messageFr ?? [],
      "message_ar": messageAr ?? [],
    };
  }
}
