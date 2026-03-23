class GroceryMenusModel {
  final bool? status;
  final GroceryMenusData? data;
  final String? message;

  GroceryMenusModel({
    this.status,
    this.data,
    this.message,
  });

  factory GroceryMenusModel.fromJson(Map<String, dynamic>? json) {
    return GroceryMenusModel(
      status: json?['status'] == "true",
      data: json?['data'] != null
          ? GroceryMenusData.fromJson(json?['data'])
          : null,
      message: json?['message'] ?? "",
    );
  }
}

class GroceryMenusData {
  final GroceryMenus? groceryMenus;
  final String? limit;
  final String? page;
  final int? total;
  final int? totalPages;

  GroceryMenusData({
    this.groceryMenus,
    this.limit,
    this.page,
    this.total,
    this.totalPages,
  });

  factory GroceryMenusData.fromJson(Map<String, dynamic>? json) {
    return GroceryMenusData(
      groceryMenus: json?['grocery_menus'] != null
          ? GroceryMenus.fromJson(json?['grocery_menus'])
          : null,
      limit: json?['limit']?.toString(),
      page: json?['page']?.toString(),
      total: json?['total'],
      totalPages: json?['total_pages'],
    );
  }
}

class GroceryMenus {
  final int? currentPage;
  final List<GroceryMenuItem>? data;
  final String? firstPageUrl;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Links>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  GroceryMenus({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory GroceryMenus.fromJson(Map<String, dynamic>? json) {
    return GroceryMenus(
      currentPage: json?['current_page'],
      data: (json?['data'] as List?)
              ?.map((e) => GroceryMenuItem.fromJson(e))
              .toList() ??
          [],
      firstPageUrl: json?['first_page_url'],
      lastPage: json?['last_page'],
      lastPageUrl: json?['last_page_url'],
      links: (json?['links'] as List?)
              ?.map((e) => Links.fromJson(e))
              .toList() ??
          [],
      nextPageUrl: json?['next_page_url'],
      path: json?['path'],
      perPage: json?['per_page'],
      prevPageUrl: json?['prev_page_url'],
      to: json?['to'],
      total: json?['total'],
    );
  }
}

class GroceryMenuItem {
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
  final int? unitTypeId;
  final String? image;
  final int? approvalStatus;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? categoryNameEn;
  final String? categoryNameAr;
  final String? categoryNameFr;
  final List<Category>? categories;
  final String? subCategoryNameEn;
  final String? subCategoryNameAr;
  final String? subCategoryNameFr;
  final List<Category>? subCategories;

  GroceryMenuItem({
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

  factory GroceryMenuItem.fromJson(Map<String, dynamic>? json) {
    return GroceryMenuItem(
      id: json?['id'],
      categoryId: json?['category_id'],
      subCategoryId: json?['sub_category_id'],
      groceryId: json?['grocery_id'],
      nameEn: json?['name_en'],
      nameAr: json?['name_ar'],
      nameFr: json?['name_fr'],
      descriptionEn: json?['description_en'],
      descriptionAr: json?['description_ar'],
      descriptionFr: json?['description_fr'],
      unitTypeId: json?['unit_type_id'],
      image: json?['image'],
      approvalStatus: json?['approval_status'],
      deletedAt: json?['deleted_at'],
      createdAt: json?['created_at'],
      updatedAt: json?['updated_at'],
      categoryNameEn: json?['category_name_en'],
      categoryNameAr: json?['category_name_ar'],
      categoryNameFr: json?['category_name_fr'],
      categories: (json?['categories'] as List?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
      subCategoryNameEn: json?['sub_category_name_en'] ?? "",
      subCategoryNameAr: json?['sub_category_name_ar'] ?? "",
      subCategoryNameFr: json?['sub_category_name_fr'] ?? "",
      subCategories: (json?['sub_categories'] as List?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Category {
  final int? id;
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;
  final String? image;
  final int? status;
  final String? deletedAt;
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

  factory Category.fromJson(Map<String, dynamic>? json) {
    return Category(
      id: json?['id'],
      nameEn: json?['name_en'],
      nameAr: json?['name_ar'],
      nameFr: json?['name_fr'],
      image: json?['image'],
      status: json?['status'],
      deletedAt: json?['deleted_at'],
      createdAt: json?['created_at'],
      updatedAt: json?['updated_at'],
    );
  }
}

class Links {
  final String? url;
  final String? label;
  final int? page;
  final bool? active;

  Links({
    this.url,
    this.label,
    this.page,
    this.active,
  });

  factory Links.fromJson(Map<String, dynamic>? json) {
    return Links(
      url: json?['url'],
      label: json?['label'],
      page: json?['page'],
      active: json?['active'],
    );
  }
}