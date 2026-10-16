class RestaurantAllCategoriesModel {
  String? status;
  List<RestaurantCategoryData>? data;
  String? message;

  RestaurantAllCategoriesModel({
    this.status,
    this.data,
    this.message,
  });

  RestaurantAllCategoriesModel.fromJson(Map<String, dynamic>? json) {
    status = json?['status']?.toString();
    message = json?['message']?.toString();

    final rawData = json?['data'];
    List<dynamic>? list;
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      for (final key in ['data', 'categories', 'menu_categories']) {
        if (rawData[key] is List) {
          list = rawData[key];
          break;
        } else if (rawData[key] is Map && rawData[key]['data'] is List) {
          list = rawData[key]['data'];
          break;
        }
      }
    }

    if (list != null) {
      data = <RestaurantCategoryData>[];
      for (final v in list) {
        if (v is Map) {
          data?.add(
            RestaurantCategoryData.fromJson(Map<String, dynamic>.from(v)),
          );
        }
      }
    } else {
      data = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};

    dataMap['status'] = status;
    dataMap['message'] = message;

    if (data != null) {
      dataMap['data'] = data?.map((v) => v.toJson()).toList();
    } else {
      dataMap['data'] = [];
    }

    return dataMap;
  }
}

class RestaurantCategoryData {
  int? id;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  String? image;

  RestaurantCategoryData({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.image,
  });

  String get displayName {
    if (nameEn != null && nameEn!.trim().isNotEmpty) return nameEn!.trim();
    if (nameFr != null && nameFr!.trim().isNotEmpty) return nameFr!.trim();
    if (nameAr != null && nameAr!.trim().isNotEmpty) return nameAr!.trim();
    return '';
  }

  RestaurantCategoryData.fromJson(Map<String, dynamic>? json) {
    final rawId =
        json?['id'] ?? json?['category_id'] ?? json?['menu_category_id'];
    id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? "0");
    final name = (json?['name_en'] ??
            json?['name'] ??
            json?['category_name'] ??
            json?['title'] ??
            '')
        .toString();
    nameEn = name;
    nameAr = (json?['name_ar'] ?? json?['name'] ?? name).toString();
    nameFr = (json?['name_fr'] ?? json?['name'] ?? name).toString();
    image = json?['image']?.toString() ??
        json?['category_image']?.toString() ??
        "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};

    dataMap['id'] = id;
    dataMap['name_en'] = nameEn;
    dataMap['name_ar'] = nameAr;
    dataMap['name_fr'] = nameFr;
    dataMap['image'] = image;

    return dataMap;
  }
}