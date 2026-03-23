class GroceryAllCategoriesModel {
  final bool? status;
  final List<CategoryData>? data;
  final String? message;

  GroceryAllCategoriesModel({
    this.status,
    this.data,
    this.message,
  });

  factory GroceryAllCategoriesModel.fromJson(Map<String, dynamic> json) {
    return GroceryAllCategoriesModel(
      status: json['status'] == "true" ? true : false,
      data: json['data'] != null
          ? List<CategoryData>.from(
              json['data'].map((x) => CategoryData.fromJson(x)))
          : [],
      message: json['message'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status == true ? "true" : "false",
      "data": data != null
          ? data!.map((x) => x.toJson()).toList()
          : [],
      "message": message ?? "",
    };
  }
}

class CategoryData {
  final int? id;
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;
  final String? image;

  CategoryData({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.image,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'] ?? 0,
      nameEn: json['name_en'] ?? "",
      nameAr: json['name_ar'] ?? "",
      nameFr: json['name_fr'] ?? "",
      image: json['image'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id ?? 0,
      "name_en": nameEn ?? "",
      "name_ar": nameAr ?? "",
      "name_fr": nameFr ?? "",
      "image": image ?? "",
    };
  }
}