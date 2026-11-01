import 'package:saimpex_vendor/utils/widgets/product_visibility.dart';

class GroceryMenuItemsModel {
  bool? status;
  GroceryMenuItemsData? data;
  String? message;

  GroceryMenuItemsModel({this.status, this.data, this.message});

  factory GroceryMenuItemsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GroceryMenuItemsModel();

    return GroceryMenuItemsModel(
      status: json['status'] == 'true' || json['status'] == true,
      data: json['data'] != null
          ? GroceryMenuItemsData.fromJson(json['data'] as Map<String, dynamic>?)
          : null,
      message: json['message']?.toString(),
    );
  }
}

class GroceryMenuItemsData {
  GroceryMenuItemsPagination? groceryMenuItems;
  String? limit;
  String? page;
  int? total;
  int? totalPages;

  GroceryMenuItemsData({
    this.groceryMenuItems,
    this.limit,
    this.page,
    this.total,
    this.totalPages,
  });

  factory GroceryMenuItemsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GroceryMenuItemsData();

    return GroceryMenuItemsData(
      groceryMenuItems: json['grocery_menu_items'] != null
          ? GroceryMenuItemsPagination.fromJson(
              json['grocery_menu_items'] as Map<String, dynamic>?,
            )
          : null,
      limit: json['limit']?.toString(),
      page: json['page']?.toString(),
      total: json['total'] as int?,
      totalPages: json['total_pages'] as int?,
    );
  }
}

class GroceryMenuItemsPagination {
  int? currentPage;
  List<GroceryMenuItem>? data;
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

  GroceryMenuItemsPagination({
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

  factory GroceryMenuItemsPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GroceryMenuItemsPagination();

    return GroceryMenuItemsPagination(
      currentPage: json['current_page'] as int? ?? 0,
      data:
          (json['data'] as List?)
              ?.map((e) => GroceryMenuItem.fromJson(e as Map<String, dynamic>?))
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

class GroceryMenuItem {
  int? menuItemId;
  String? price;
  String? attributeValue;
  int? id;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  String? descriptionEn;
  String? descriptionAr;
  String? descriptionFr;
  String? image;
  int? approvalStatus;
  String? variantNameEn;
  String? variantNameAr;
  String? variantNameFr;
  int? status;
  int? availableStatus;

  /// Hidden state (API doc §6.21): `is_hidden`, `hidden_until`, `hidden_forever`.
  ProductVisibilityState visibility;
  String? categoryNameEn;
  String? categoryNameAr;
  String? categoryNameFr;

  GroceryMenuItem({
    this.menuItemId,
    this.price,
    this.attributeValue,
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionFr,
    this.image,
    this.approvalStatus,
    this.variantNameEn,
    this.variantNameAr,
    this.variantNameFr,
    this.status,
    this.availableStatus,
    this.visibility = const ProductVisibilityState(),
    this.categoryNameEn,
    this.categoryNameAr,
    this.categoryNameFr,
  });

  factory GroceryMenuItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GroceryMenuItem();

    return GroceryMenuItem(
      menuItemId: json['menu_item_id'] as int? ?? 0,
      price: json['price']?.toString() ?? '0',
      attributeValue: json['attribute_value']?.toString() ?? '',
      id: json['id'] as int? ?? 0,
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameFr: json['name_fr']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      descriptionFr: json['description_fr']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      approvalStatus: json['approval_status'] as int? ?? 0,
      variantNameEn: json['variant_name_en']?.toString() ?? '',
      variantNameAr: json['variant_name_ar']?.toString() ?? '',
      variantNameFr: json['variant_name_fr']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      availableStatus: json['available_status'] as int? ?? 0,
      visibility: ProductVisibilityState.fromJson(json),
      categoryNameEn: json['category_name_en']?.toString() ?? '',
      categoryNameAr: json['category_name_ar']?.toString() ?? '',
      categoryNameFr: json['category_name_fr']?.toString() ?? '',
    );
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
