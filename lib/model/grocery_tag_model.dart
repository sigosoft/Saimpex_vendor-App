class GroceryTagsModel {
  final bool? status;
  final List<GroceryTag>? data;
  final String? message;

  GroceryTagsModel({
    this.status,
    this.data,
    this.message,
  });

  factory GroceryTagsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GroceryTagsModel();

    return GroceryTagsModel(
      status: json['status']?.toString() == 'true',
      data: (json['data'] as List?)
          ?.map((e) => GroceryTag.fromJson(e))
          .toList(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status?.toString(),
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class GroceryTag {
  final int? id;
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;

  GroceryTag({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
  });

  factory GroceryTag.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GroceryTag();

    return GroceryTag(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      nameEn: json['name_en']?.toString(),
      nameAr: json['name_ar']?.toString(),
      nameFr: json['name_fr']?.toString(),
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