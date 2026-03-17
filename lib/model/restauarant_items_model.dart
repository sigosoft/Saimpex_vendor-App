class RestaurantItemsModel {
  String? status;
  RestaurantItemsData? data;
  String? message;

  RestaurantItemsModel({
    this.status,
    this.data,
    this.message,
  });

  factory RestaurantItemsModel.fromJson(Map<String, dynamic> json) {
    return RestaurantItemsModel(
      status: json['status']?.toString(),
      data: json['data'] != null
          ? RestaurantItemsData.fromJson(json['data'])
          : null,
      message: json['message'] ?? '',
    );
  }
}

class RestaurantItemsData {
  MenuItemsPagination? restaurantMenuItems;
  String? limit;
  String? page;
  int? total;
  int? totalPages;

  RestaurantItemsData({
    this.restaurantMenuItems,
    this.limit,
    this.page,
    this.total,
    this.totalPages,
  });

  factory RestaurantItemsData.fromJson(Map<String, dynamic> json) {
    return RestaurantItemsData(
      restaurantMenuItems: json['restaurant_menu_items'] != null
          ? MenuItemsPagination.fromJson(json['restaurant_menu_items'])
          : null,
      limit: json['limit'] ?? '',
      page: json['page'] ?? '',
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}

class MenuItemsPagination {
  int? currentPage;
  List<MenuItem>? data;
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

  MenuItemsPagination({
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

  factory MenuItemsPagination.fromJson(Map<String, dynamic> json) {
    return MenuItemsPagination(
      currentPage: json['current_page'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => MenuItem.fromJson(e))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List?)
              ?.map((e) => PaginationLink.fromJson(e))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: int.tryParse(json['per_page']?.toString() ?? '0') ?? 0,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class MenuItem {
  int? id;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  String? descriptionEn;
  String? descriptionAr;
  String? descriptionFr;
  String? image;
  int? isVeg;
  String? price;
  String? discountPrice;
  String? attributeNameEn;
  String? attributeNameAr;
  String? attributeNameFr;
  int? itemStatus;
  int? availableStatus;
  List<Category>? categories;

  MenuItem({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionFr,
    this.image,
    this.isVeg,
    this.price,
    this.discountPrice,
    this.attributeNameEn,
    this.attributeNameAr,
    this.attributeNameFr,
    this.itemStatus,
    this.availableStatus,
    this.categories,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameFr: json['name_fr'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionFr: json['description_fr'] ?? '',
      image: json['image'] ?? '',
      isVeg: json['is_veg'] ?? 0,
      price: json['price'] ?? '',
      discountPrice: json['discount_price'] ?? '',
      attributeNameEn: json['attribute_name_en'] ?? '',
      attributeNameAr: json['attribute_name_ar'] ?? '',
      attributeNameFr: json['attribute_name_fr'] ?? '',
      itemStatus: json['item_status'] ?? 0,
      availableStatus: json['available_status'] ?? 0,
      categories: (json['categories'] as List?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Category {
  int? id;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  String? image;

  Category({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameFr: json['name_fr'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class PaginationLink {
  String? url;
  String? label;
  int? page;
  bool? active;

  PaginationLink({
    this.url,
    this.label,
    this.page,
    this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      page: json['page'],
      active: json['active'] ?? false,
    );
  }
}