class GroceryMenuDetailsModel {
  final bool? status;
  final GroceryMenuDetailsData? data;
  final String? message;

  GroceryMenuDetailsModel({
    this.status,
    this.data,
    this.message,
  });

  factory GroceryMenuDetailsModel.fromJson(Map<String, dynamic> json) {
    return GroceryMenuDetailsModel(
      status: json['status'] == "true",
      data: json['data'] != null
          ? GroceryMenuDetailsData.fromJson(json['data'])
          : null,
      message: json['message'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status == true ? "true" : "false",
      "data": data?.toJson(),
      "message": message ?? "",
    };
  }
}

class GroceryMenuDetailsData {
  final GroceryMenu? groceryMenu;
  final int? totalOrders;
  final int? totalRevenue;
  final int? averageRating;
  final int? totalRatingCount;
  final List<dynamic>? orderDetails;

  GroceryMenuDetailsData({
    this.groceryMenu,
    this.totalOrders,
    this.totalRevenue,
    this.averageRating,
    this.totalRatingCount,
    this.orderDetails,
  });

  factory GroceryMenuDetailsData.fromJson(Map<String, dynamic> json) {
    return GroceryMenuDetailsData(
      groceryMenu: json['grocery_menu'] != null
          ? GroceryMenu.fromJson(json['grocery_menu'])
          : null,
      totalOrders: json['total_orders'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      averageRating: json['average_rating'] ?? 0,
      totalRatingCount: json['total_rating_count'] ?? 0,
      orderDetails: json['order_details'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "grocery_menu": groceryMenu?.toJson(),
      "total_orders": totalOrders ?? 0,
      "total_revenue": totalRevenue ?? 0,
      "average_rating": averageRating ?? 0,
      "total_rating_count": totalRatingCount ?? 0,
      "order_details": orderDetails ?? [],
    };
  }
}

class GroceryMenu {
  final int? id;
  final String? categoryId;
  final String? subCategoryId;
  final int? groceryId;
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? descriptionFr;
  final dynamic unitTypeId;
  final String? image;
  final int? approvalStatus;
  final dynamic deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? categoryNameEn;
  final String? categoryNameAr;
  final String? categoryNameFr;
  final List<Category>? categories;
  final String? subCategoryNameEn;
  final String? subCategoryNameAr;
  final String? subCategoryNameFr;
  final List<dynamic>? subCategories;

  GroceryMenu({
    this.id,
    this.categoryId,
    this.subCategoryId,
    this.groceryId,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionFr,
    this.unitTypeId,
    this.image,
    this.approvalStatus,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.categoryNameEn,
    this.categoryNameAr,
    this.categoryNameFr,
    this.categories,
    this.subCategoryNameEn,
    this.subCategoryNameAr,
    this.subCategoryNameFr,
    this.subCategories,
  });

  factory GroceryMenu.fromJson(Map<String, dynamic> json) {
    return GroceryMenu(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? "",
      subCategoryId: json['sub_category_id'] ?? "",
      groceryId: json['grocery_id'] ?? 0,
      nameEn: json['name_en'] ?? "",
      nameAr: json['name_ar'] ?? "",
      nameFr: json['name_fr'] ?? "",
      descriptionEn: json['description_en'] ?? "",
      descriptionAr: json['description_ar'] ?? "",
      descriptionFr: json['description_fr'] ?? "",
      unitTypeId: json['unit_type_id'],
      image: json['image'] ?? "",
      approvalStatus: json['approval_status'] ?? 0,
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
      categoryNameEn: json['category_name_en'] ?? "",
      categoryNameAr: json['category_name_ar'] ?? "",
      categoryNameFr: json['category_name_fr'] ?? "",
      categories: json['categories'] != null
          ? List<Category>.from(
              json['categories'].map((x) => Category.fromJson(x)))
          : [],
      subCategoryNameEn: json['sub_category_name_en'] ?? "",
      subCategoryNameAr: json['sub_category_name_ar'] ?? "",
      subCategoryNameFr: json['sub_category_name_fr'] ?? "",
      subCategories: json['sub_categories'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id ?? 0,
      "category_id": categoryId ?? "",
      "sub_category_id": subCategoryId ?? "",
      "grocery_id": groceryId ?? 0,
      "name_en": nameEn ?? "",
      "name_ar": nameAr ?? "",
      "name_fr": nameFr ?? "",
      "description_en": descriptionEn ?? "",
      "description_ar": descriptionAr ?? "",
      "description_fr": descriptionFr ?? "",
      "unit_type_id": unitTypeId,
      "image": image ?? "",
      "approval_status": approvalStatus ?? 0,
      "deleted_at": deletedAt,
      "created_at": createdAt ?? "",
      "updated_at": updatedAt ?? "",
      "category_name_en": categoryNameEn ?? "",
      "category_name_ar": categoryNameAr ?? "",
      "category_name_fr": categoryNameFr ?? "",
      "categories": categories?.map((x) => x.toJson()).toList() ?? [],
      "sub_category_name_en": subCategoryNameEn ?? "",
      "sub_category_name_ar": subCategoryNameAr ?? "",
      "sub_category_name_fr": subCategoryNameFr ?? "",
      "sub_categories": subCategories ?? [],
    };
  }
}

class Category {
  final int? id;
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;
  final String? image;
  final int? status;
  final dynamic deletedAt;
  final String? createdAt;
  final String? updatedAt;

  Category({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.image,
    this.status,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      nameEn: json['name_en'] ?? "",
      nameAr: json['name_ar'] ?? "",
      nameFr: json['name_fr'] ?? "",
      image: json['image'] ?? "",
      status: json['status'] ?? 0,
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id ?? 0,
      "name_en": nameEn ?? "",
      "name_ar": nameAr ?? "",
      "name_fr": nameFr ?? "",
      "image": image ?? "",
      "status": status ?? 0,
      "deleted_at": deletedAt,
      "created_at": createdAt ?? "",
      "updated_at": updatedAt ?? "",
    };
  }
}