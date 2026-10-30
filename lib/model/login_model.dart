class LoginModel {
  final bool? status;
  final LoginData? data;
  final LoginMessage? message;

  LoginModel({
    this.status,
    this.data,
    this.message,
  });

  factory LoginModel.fromJson(Map<String, dynamic>? json) {
    return LoginModel(
      status: json?['status']?.toString() == 'true',
      data: json?['data'] != null
          ? LoginData.fromJson(json?['data'])
          : null,
      message: json?['message'] != null
          ? LoginMessage.fromJson(json?['message'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status ?? false,
      'data': data?.toJson(),
      'message': message?.toJson(),
    };
  }
}

class LoginData {
  final LoginDetails? details;

  LoginData({this.details});

  factory LoginData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LoginData();
    if (json.containsKey('details') && json['details'] is Map<String, dynamic>) {
      return LoginData(
        details: LoginDetails.fromJson(json['details'] as Map<String, dynamic>),
      );
    }
    return LoginData(
      details: LoginDetails.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details?.toJson(),
    };
  }
}

class LoginDetails {
  final int? id;
  final String? name;
  final String? email;
  final String? username;
  final int? roleId;
  final int? status;
  final String? token;
  final int? vendorType;
  final int? vendorId;

  LoginDetails({
    this.id,
    this.name,
    this.email,
    this.username,
    this.roleId,
    this.status,
    this.token,
    this.vendorType,
    this.vendorId,
  });

  factory LoginDetails.fromJson(Map<String, dynamic>? json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return LoginDetails(
      id: parseInt(json?['id']),
      name: json?['name']?.toString() ?? '',
      email: json?['email']?.toString() ?? '',
      username: json?['username']?.toString() ?? '',
      roleId: parseInt(json?['role_id']),
      status: parseInt(json?['status']),
      token: json?['token']?.toString() ?? '',
      vendorType: parseInt(json?['vendor_type']),
      vendorId: parseInt(json?['vendor_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'name': name ?? '',
      'email': email ?? '',
      'username': username ?? '',
      'role_id': roleId ?? 0,
      'status': status ?? 0,
      'token': token ?? '',
      'vendor_type': vendorType ?? 0,
      'vendor_id': vendorId ?? 0,
    };
  }
}

class LoginMessage {
  final List<String>? messageEn;
  final List<String>? messageFr;
  final List<String>? messageAr;

  LoginMessage({
    this.messageEn,
    this.messageFr,
    this.messageAr,
  });

  factory LoginMessage.fromJson(Map<String, dynamic>? json) {
    return LoginMessage(
      messageEn: (json?['message_en'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .toList() ??
          [],
      messageFr: (json?['message_fr'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .toList() ??
          [],
      messageAr: (json?['message_ar'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_en': messageEn ?? [],
      'message_fr': messageFr ?? [],
      'message_ar': messageAr ?? [],
    };
  }
}