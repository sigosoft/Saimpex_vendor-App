class AttributesModel {
  final bool? status;
  final List<AttributeData>? data;
  final String? message;

  AttributesModel({
    this.status,
    this.data,
    this.message,
  });

  factory AttributesModel.fromJson(Map<String, dynamic>? json) {
    return AttributesModel(
      status: json?['status'] == "true",
      data: (json?['data'] as List?)
              ?.map((e) => AttributeData.fromJson(e))
              .toList() ??
          [],
      message: json?['message'] ?? "",
    );
  }
}

class AttributeData {
  final int? id;
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;

  AttributeData({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
  });

  factory AttributeData.fromJson(Map<String, dynamic>? json) {
    return AttributeData(
      id: json?['id'] ?? 0,
      nameEn: json?['name_en'] ?? "",
      nameAr: json?['name_ar'] ?? "",
      nameFr: json?['name_fr'] ?? "",
    );
  }
}