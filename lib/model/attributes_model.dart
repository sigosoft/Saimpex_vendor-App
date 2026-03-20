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
    final statusVal = json?['status'];
    return AttributesModel(
      status: statusVal == true ||
          statusVal?.toString().toLowerCase() == "true" ||
          statusVal?.toString() == "1",
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
    final idVal = json?['id'];
    final nameEnVal = json?['name_en'];
    final nameArVal = json?['name_ar'];
    final nameFrVal = json?['name_fr'];

    final parsedId = idVal is int
        ? idVal
        : int.tryParse(idVal?.toString() ?? '');

    return AttributeData(
      id: parsedId,
      nameEn: nameEnVal?.toString() ?? "",
      nameAr: nameArVal?.toString() ?? "",
      nameFr: nameFrVal?.toString() ?? "",
    );
  }
}