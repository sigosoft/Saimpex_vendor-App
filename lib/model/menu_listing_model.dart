import 'dart:convert';

class MenuListingModel {
  final bool status;
  final List<MenuItem> data;
  final String message;

  MenuListingModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory MenuListingModel.fromJson(Map<String, dynamic>? json) {
    return MenuListingModel(
      status: json?['status']?.toString().toLowerCase() == 'true',
      data: (json?['data'] as List?)
              ?.map((e) => MenuItem.fromJson(e))
              .toList() ??
          [],
      message: json?['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "data": data.map((e) => e.toJson()).toList(),
      "message": message,
    };
  }
}

class MenuItem {
  final int id;
  final String nameEn;
  final String nameAr;
  final String nameFr;
  final List<String> categoryId;
  final String image;

  MenuItem({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameFr,
    required this.categoryId,
    required this.image,
  });

  factory MenuItem.fromJson(Map<String, dynamic>? json) {
    List<String> categories = [];

    try {
      if (json?['category_id'] != null) {
        categories = List<String>.from(jsonDecode(json?['category_id']));
      }
    } catch (_) {}

    return MenuItem(
      id: json?['id'] ?? 0,
      nameEn: json?['name_en'] ?? '',
      nameAr: json?['name_ar'] ?? '',
      nameFr: json?['name_fr'] ?? '',
      categoryId: categories,
      image: json?['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name_en": nameEn,
      "name_ar": nameAr,
      "name_fr": nameFr,
      "category_id": jsonEncode(categoryId),
      "image": image,
    };
  }
}