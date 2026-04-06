import 'dart:convert';

class RestaurantMenusModel {
  bool? status;
  List<RestaurantMenu>? data;
  RestaurantMenusData? payload;
  String? message;

  RestaurantMenusModel({this.status, this.data, this.payload, this.message});

  factory RestaurantMenusModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantMenusModel();

    final rawData = json['data'];
    RestaurantMenusData? parsedPayload;
    List<RestaurantMenu> parsedMenus = [];

    if (rawData is Map<String, dynamic>) {
      parsedPayload = RestaurantMenusData.fromJson(rawData);
      parsedMenus = parsedPayload.restaurantMenus?.data ?? [];
    } else if (rawData is List) {
      parsedMenus =
          rawData
              .map((e) => RestaurantMenu.fromJson(e as Map<String, dynamic>?))
              .toList();
    }

    return RestaurantMenusModel(
      status: json['status'] == 'true' || json['status'] == true,
      data: parsedMenus,
      payload: parsedPayload,
      message: json['message']?.toString(),
    );
  }
}

class RestaurantMenusData {
  RestaurantMenusPagination? restaurantMenus;
  String? limit;
  String? page;
  int? total;
  int? totalPages;

  RestaurantMenusData({
    this.restaurantMenus,
    this.limit,
    this.page,
    this.total,
    this.totalPages,
  });

  factory RestaurantMenusData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantMenusData();

    return RestaurantMenusData(
      restaurantMenus: json['restaurant_menus'] != null
          ? RestaurantMenusPagination.fromJson(
              json['restaurant_menus'] as Map<String, dynamic>?,
            )
          : null,
      limit: json['limit']?.toString(),
      page: json['page']?.toString(),
      total: _toInt(json['total']),
      totalPages: _toInt(json['total_pages']),
    );
  }

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}

class RestaurantMenusPagination {
  int? currentPage;
  List<RestaurantMenu>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<PaginationLink>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  RestaurantMenusPagination({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
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

  factory RestaurantMenusPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantMenusPagination();

    return RestaurantMenusPagination(
      currentPage: _toInt(json['current_page']),
      data:
          (json['data'] as List?)
              ?.map((e) => RestaurantMenu.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url']?.toString() ?? '',
      from: _toInt(json['from']),
      lastPage: _toInt(json['last_page']),
      lastPageUrl: json['last_page_url']?.toString() ?? '',
      links:
          (json['links'] as List?)
              ?.map((e) => PaginationLink.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      perPage: _toInt(json['per_page']),
      prevPageUrl: json['prev_page_url']?.toString() ?? '',
      to: _toInt(json['to']),
      total: _toInt(json['total']),
    );
  }

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}

class RestaurantMenu {
  int? id;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  String? categoryId;
  int? restaurantId;
  String? descriptionEn;
  String? descriptionAr;
  String? descriptionFr;
  String? image;
  int? isVeg;
  int? approvalStatus;
  String? createdAt;
  String? updatedAt;
  String? categoryNameEn;
  String? categoryNameAr;
  String? categoryNameFr;
  List<CategoryData>? categories;

  RestaurantMenu({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.categoryId,
    this.restaurantId,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionFr,
    this.image,
    this.isVeg,
    this.approvalStatus,
    this.createdAt,
    this.updatedAt,
    this.categoryNameEn,
    this.categoryNameAr,
    this.categoryNameFr,
    this.categories,
  });

  factory RestaurantMenu.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantMenu();

    return RestaurantMenu(
      id: _toInt(json['id']),
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameFr: json['name_fr']?.toString() ?? '',
      categoryId: _parseCategoryId(json['category_id']),
      restaurantId: _toNullableInt(json['restaurant_id']),
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      descriptionFr: json['description_fr']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      isVeg: _toInt(json['is_veg']),
      approvalStatus: _toInt(json['approval_status']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      categoryNameEn: json['category_name_en']?.toString() ?? '',
      categoryNameAr: json['category_name_ar']?.toString() ?? '',
      categoryNameFr: json['category_name_fr']?.toString() ?? '',
      categories:
          (json['categories'] as List?)
              ?.map((e) => CategoryData.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
    );
  }

  static String _parseCategoryId(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      if (value.isNotEmpty) return value.first.toString();
      return '';
    }
    String s = value.toString();
    if (s.startsWith('[') && s.endsWith(']')) {
      try {
        final List<dynamic> list = List.from(jsonDecode(s));
        if (list.isNotEmpty) return list.first.toString();
      } catch (_) {}
    }
    return s;
  }

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class CategoryData {
  int? id;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;

  CategoryData({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CategoryData();

    return CategoryData(
      id: _toInt(json['id']),
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameFr: json['name_fr']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      status: _toInt(json['status']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}

class PaginationLink {
  String? url;
  String? label;
  int? page;
  bool? active;

  PaginationLink({this.url, this.label, this.page, this.active});

  factory PaginationLink.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PaginationLink();

    return PaginationLink(
      url: json['url']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      page: json['page'] is int
          ? json['page'] as int
          : int.tryParse(json['page']?.toString() ?? ''),
      active: json['active'] as bool? ?? false,
    );
  }
}
