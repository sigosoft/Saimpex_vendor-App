class TagsModel {
  String? status;
  List<TagData>? data;
  String? message;

  TagsModel({
    this.status,
    this.data,
    this.message,
  });

  factory TagsModel.fromJson(Map<String, dynamic> json) {
    return TagsModel(
      status: json['status']?.toString(),
      data: (json['data'] as List?)
              ?.map((e) => TagData.fromJson(e))
              .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class TagData {
  int? id;
  String? nameEn;
  String? nameAr;
  String? nameFr;

  TagData({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
  });

  factory TagData.fromJson(Map<String, dynamic> json) {
    return TagData(
      id: json['id'] ?? 0,
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameFr: json['name_fr'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'name_fr': nameFr,
    };
  }
}