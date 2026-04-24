class RestaurantItemsModel {
  bool? status;
  RestaurantItemsData? data;
  Message? message;

  RestaurantItemsModel({this.status, this.data, this.message});

  factory RestaurantItemsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantItemsModel();

    return RestaurantItemsModel(
      status: json['status'] as bool? ?? false,
      data: RestaurantItemsData.fromJson(
          json['data'] as Map<String, dynamic>?),
      message:
      Message.fromJson(json['message'] as Map<String, dynamic>?),
    );
  }
}
class RestaurantItemsData {
  CartInfo? cartItems;
  MenuPagination? menus;

  RestaurantItemsData({this.cartItems, this.menus});

  factory RestaurantItemsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantItemsData();

    return RestaurantItemsData(
      cartItems: json['cart_items'] is Map<String, dynamic>
          ? CartInfo.fromJson(json['cart_items'])
          : null,
      menus: MenuPagination.fromJson(
          json['menus'] as Map<String, dynamic>?),
    );
  }
}
class CartInfo {
  int? cartId;
  int? vendorId;
  String? vendorName;
  int? cartType;

  CartInfo({this.cartId, this.vendorId, this.vendorName, this.cartType});

  factory CartInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CartInfo();

    return CartInfo(
      cartId: json['cart_id'] as int? ?? 0,
      vendorId: json['vendor_id'] as int? ?? 0,
      vendorName: json['vendor_name']?.toString() ?? '',
      cartType: json['cart_type'] as int? ?? 0,
    );
  }
}
class MenuPagination {
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

  MenuPagination({
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

  factory MenuPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MenuPagination();

    return MenuPagination(
      currentPage: json['current_page'] as int? ?? 0,
      data: (json['data'] as List?)
          ?.map((e) =>
          MenuItem.fromJson(e as Map<String, dynamic>?))
          .toList() ??
          [],
      firstPageUrl: json['first_page_url']?.toString() ?? '',
      from: json['from'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 0,
      lastPageUrl: json['last_page_url']?.toString() ?? '',
      links: (json['links'] as List?)
          ?.map((e) =>
          PaginationLink.fromJson(e as Map<String, dynamic>?))
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
class MenuItem {
  int? menuId;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  int? categoryId;
  String? image;
  int? isVeg;
  int? restaurantId;
  String? restaurantName;
  String? price;
  String? discountPrice;
  String? offerPercentage;
  String? rating;
  int? ratingCount;
  bool? hasStock;
  AvailabilityTiming? availabilityTiming;
  List<ItemVariant>? items;
  int? productType;

  MenuItem({
    this.menuId,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.categoryId,
    this.image,
    this.isVeg,
    this.restaurantId,
    this.restaurantName,
    this.price,
    this.discountPrice,
    this.offerPercentage,
    this.rating,
    this.ratingCount,
    this.hasStock,
    this.availabilityTiming,
    this.items,
    this.productType,
  });

  factory MenuItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MenuItem();

    return MenuItem(
      menuId: json['menu_id'] as int? ?? 0,
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameFr: json['name_fr']?.toString() ?? '',
      categoryId: json['category_id'] as int? ?? 0,
      image: json['image']?.toString() ?? '',
      isVeg: json['is_veg'] is int
          ? json['is_veg'] as int
          : int.tryParse(json['is_veg']?.toString() ?? '') ?? 0,
      restaurantId: json['restaurant_id'] as int? ?? 0,
      restaurantName: json['restaurant_name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString() ?? '0',
      offerPercentage: json['offer_percentage']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '0',
      ratingCount: json['rating_count'] as int? ?? 0,
      hasStock: json['has_stock'] as bool? ?? false,
      availabilityTiming: AvailabilityTiming.fromJson(
          json['availability_timing'] as Map<String, dynamic>?),
      items: (json['items'] as List?)
          ?.map((e) =>
          ItemVariant.fromJson(e as Map<String, dynamic>?))
          .toList() ??
          [],
      productType: json['product_type'] as int? ?? 0,
    );
  }
}
class AvailabilityTiming {
  bool? isOpen24h;
  List<Timing>? timings;

  AvailabilityTiming({this.isOpen24h, this.timings});

  factory AvailabilityTiming.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AvailabilityTiming();

    return AvailabilityTiming(
      isOpen24h: json['is_open_24h'] as bool? ?? false,
      timings: (json['timings'] as List?)
          ?.map((e) =>
          Timing.fromJson(e as Map<String, dynamic>?))
          .toList() ??
          [],
    );
  }
}

class Timing {
  String? openTime;
  String? closeTime;

  Timing({this.openTime, this.closeTime});

  factory Timing.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Timing();

    return Timing(
      openTime: json['open_time']?.toString() ?? '',
      closeTime: json['close_time']?.toString() ?? '',
    );
  }
}
class ItemVariant {
  int? itemId;
  int? menuId;
  String? price;
  String? discountPrice;
  int? stock;
  String? preparationTime;
  int? restaurantAttributeId;
  String? variantNameEn;
  String? variantNameAr;
  String? variantNameFr;
  String? attributeValue;
  int? availableStatus;

  ItemVariant({
    this.itemId,
    this.menuId,
    this.price,
    this.discountPrice,
    this.stock,
    this.preparationTime,
    this.restaurantAttributeId,
    this.variantNameEn,
    this.variantNameAr,
    this.variantNameFr,
    this.attributeValue,
    this.availableStatus,
  });

  factory ItemVariant.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ItemVariant();

    return ItemVariant(
      itemId: json['item_id'] as int? ?? 0,
      menuId: json['menu_id'] as int? ?? 0,
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString() ?? '0',
      stock: json['stock'] as int? ?? 0,
      preparationTime: json['preparation_time']?.toString() ?? '',
      restaurantAttributeId:
      json['restaurant_attribute_id'] as int? ?? 0,
      variantNameEn: json['variant_name_en']?.toString() ?? '',
      variantNameAr: json['variant_name_ar']?.toString() ?? '',
      variantNameFr: json['variant_name_fr']?.toString() ?? '',
      attributeValue: json['attribute_value']?.toString() ?? '',
      availableStatus: json['available_status'] as int? ?? 0,
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
      page: json['page'] as int? ?? 0,
      active: json['active'] as bool? ?? false,
    );
  }
}

class Message {
  List<String>? messageEn;
  List<String>? messageFr;
  List<String>? messageAr;

  Message({this.messageEn, this.messageFr, this.messageAr});

  factory Message.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Message();

    return Message(
      messageEn: (json['message_en'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      messageFr: (json['message_fr'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      messageAr: (json['message_ar'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}
