import 'dart:convert';
import '../configs/ApiConfigs.dart';
import '../utils/widgets/product_visibility.dart';

class RestaurantMenuItemsModel {
  bool? status;
  RestaurantMenuItemsData? data;
  String? message;

  RestaurantMenuItemsModel({this.status, this.data, this.message});

  factory RestaurantMenuItemsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantMenuItemsModel();

    return RestaurantMenuItemsModel(
      status: json['status'] == 'true' ||
          json['status'] == true ||
          json['status']?.toString().toLowerCase() == 'true',
      data: json['data'] != null
          ? RestaurantMenuItemsData.fromJson(
              json['data'] as Map<String, dynamic>?,
            )
          : null,
      message: json['message']?.toString(),
    );
  }
}

class RestaurantMenuItemsData {
  RestaurantMenuItemsPagination? restaurantMenuItems;
  String? limit;
  String? page;
  int? total;
  int? totalPages;

  RestaurantMenuItemsData({
    this.restaurantMenuItems,
    this.limit,
    this.page,
    this.total,
    this.totalPages,
  });

  factory RestaurantMenuItemsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantMenuItemsData();

    if (json['items'] is List) {
      final list = (json['items'] as List)
          .map(
            (e) => RestaurantMenuItemData.fromJson(e as Map<String, dynamic>?),
          )
          .toList();
      final pagination = json['pagination'] is Map
          ? json['pagination'] as Map<String, dynamic>
          : null;
      return RestaurantMenuItemsData(
        restaurantMenuItems: RestaurantMenuItemsPagination(
          currentPage: pagination?['current_page'] as int? ?? 1,
          lastPage: pagination?['last_page'] as int? ?? 1,
          perPage: pagination?['per_page'] as int? ?? 10,
          total: pagination?['total'] as int? ?? list.length,
          data: list,
        ),
      );
    }

    return RestaurantMenuItemsData(
      restaurantMenuItems: json['restaurant_menu_items'] != null
          ? RestaurantMenuItemsPagination.fromJson(
              json['restaurant_menu_items'] as Map<String, dynamic>?,
            )
          : null,
      limit: json['limit']?.toString(),
      page: json['page']?.toString(),
      total: json['total'] as int?,
      totalPages: json['total_pages'] as int?,
    );
  }
}

class RestaurantMenuItemsPagination {
  int? currentPage;
  List<RestaurantMenuItemData>? data;
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

  RestaurantMenuItemsPagination({
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

  factory RestaurantMenuItemsPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantMenuItemsPagination();

    return RestaurantMenuItemsPagination(
      currentPage: json['current_page'] as int? ?? 0,
      data:
          (json['data'] as List?)
              ?.map(
                (e) =>
                    RestaurantMenuItemData.fromJson(e as Map<String, dynamic>?),
              )
              .toList() ??
          [],
      firstPageUrl: json['first_page_url']?.toString() ?? '',
      from: json['from'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 0,
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
      to: json['to'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}

class RestaurantMenuItemData {
  int? id;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  String? descriptionEn;
  String? descriptionAr;
  String? descriptionFr;
  String? image;
  String? price;
  String? discountPrice;
  int? restaurantMenuItemId;
  int? categoryId;
  String? categoryNameEn;
  String? categoryNameAr;
  String? categoryNameFr;
  int? availableStatus;
  String? preparationTime;

  /// Hide / unhide state (§6.21, #132): `is_hidden`, `hidden_until`, `hidden_forever`.
  ProductVisibilityState visibility;

  RestaurantMenuItemData({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionFr,
    this.image,
    this.price,
    this.discountPrice,
    this.restaurantMenuItemId,
    this.categoryId,
    this.categoryNameEn,
    this.categoryNameAr,
    this.categoryNameFr,
    this.availableStatus,
    this.preparationTime,
    this.visibility = const ProductVisibilityState(),
  });

  factory RestaurantMenuItemData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantMenuItemData();

    String? catNameEn;
    String? catNameAr;
    String? catNameFr;
    int? catId;

    if (json['categories'] is List && (json['categories'] as List).isNotEmpty) {
      final firstCat = (json['categories'] as List).first;
      if (firstCat is Map) {
        catId = int.tryParse(firstCat['id']?.toString() ?? '');
        catNameEn = firstCat['name_en']?.toString();
        catNameAr = firstCat['name_ar']?.toString();
        catNameFr = firstCat['name_fr']?.toString();
      }
    }

    String rawImg = (json['image_url'] ?? json['image'])?.toString() ?? '';
    if (rawImg.contains('localhost/storage/')) {
      rawImg = rawImg
          .replaceFirst('http://localhost/storage/', ApiConfigs.IMAGE_URL)
          .replaceFirst('https://localhost/storage/', ApiConfigs.IMAGE_URL);
    }

    return RestaurantMenuItemData(
      id: json['id'] as int? ?? int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameFr: json['name_fr']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      descriptionFr: json['description_fr']?.toString() ?? '',
      image: rawImg,
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString() ??
          json['price']?.toString() ??
          '0',
      restaurantMenuItemId:
          (json['restaurant_menu_item_id'] ?? json['id']) as int? ??
              int.tryParse(
                (json['restaurant_menu_item_id'] ?? json['id'])?.toString() ??
                    '',
              ) ??
              0,
      categoryId: catId ?? _parseCategoryIdToInt(json['category_id']),
      categoryNameEn: catNameEn ?? json['category_name_en']?.toString() ?? '',
      categoryNameAr: catNameAr ?? json['category_name_ar']?.toString() ?? '',
      categoryNameFr: catNameFr ?? json['category_name_fr']?.toString() ?? '',
      availableStatus: json['available_status'] is int
          ? json['available_status'] as int
          : int.tryParse(json['available_status']?.toString() ?? '0'),
      visibility: ProductVisibilityState.fromJson(json),
      preparationTime:
          json['preparation_time']?.toString() ?? json['prep_time']?.toString(),
    );
  }
  static int? _parseCategoryIdToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is List) {
      if (value.isNotEmpty) return int.tryParse(value.first.toString());
      return null;
    }
    String s = value.toString();
    if (s.startsWith('[') && s.endsWith(']')) {
      try {
        final List<dynamic> list = List.from(jsonDecode(s));
        if (list.isNotEmpty) return int.tryParse(list.first.toString());
      } catch (_) {}
    }
    return int.tryParse(s);
  }
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
          ? json['page']
          : int.tryParse(json['page']?.toString() ?? ''),
      active: json['active'] as bool? ?? false,
    );
  }
}
