class RestaurantItemsDetailsModel {
  final bool? status;
  final MenuItemData? data;
  final String? message;

  RestaurantItemsDetailsModel({this.status, this.data, this.message});

  factory RestaurantItemsDetailsModel.fromJson(Map<String, dynamic>? json) {
    return RestaurantItemsDetailsModel(
      status:
          json?['status'] == true ||
          json?['status']?.toString().toLowerCase() == "true" ||
          json?['status']?.toString() == "1",
      data: json?['data'] != null ? MenuItemData.fromJson(json?['data']) : null,
      // Backend sometimes returns `message` as a localized map.
      // Ensure we never crash on a non-String message payload.
      message: json?['message']?.toString(),
    );
  }
}

int? _toNullableInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

String? _toNullableString(dynamic v) {
  if (v == null) return null;
  return v.toString();
}

class MenuItemData {
  final MenuItemDetails? menuItemDetails;
  final List<MenuItemTag>? menuItemTags;

  MenuItemData({this.menuItemDetails, this.menuItemTags});

  factory MenuItemData.fromJson(Map<String, dynamic>? json) {
    return MenuItemData(
      menuItemDetails: json?['menu_item_details'] != null
          ? MenuItemDetails.fromJson(json?['menu_item_details'])
          : null,
      menuItemTags:
          ((json?['menu_item_tags'] ?? json?['grocery_item_tags']) as List?)
              ?.map((e) => MenuItemTag.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MenuItemDetails {
  final int? id;
  final int? menuId;
  final int? restaurantId;
  final String? preparationTime;
  final String? serialNumber;
  final int? restaurantAttributeId;
  final dynamic attributeValue;
  final String? price;
  final String? discountPrice;
  final int? stock;
  final int? quantityAllowed;
  final int? rating;
  final int? availableStatus;
  final int? status;
  final int? approvalStatus;
  final String? createdAt;
  final String? updatedAt;
  final String? totalOrders;
  final int? totalPriceAfterCommission;
  final dynamic avgRating;
  final dynamic totalRatings;
  final dynamic lastOrderDate;

  final List<WorkingHour>? workingHours;
  final RestaurantMenu? restaurantMenu;
  final Attribute? attribute;

  MenuItemDetails({
    this.id,
    this.menuId,
    this.restaurantId,
    this.preparationTime,
    this.serialNumber,
    this.restaurantAttributeId,
    this.attributeValue,
    this.price,
    this.discountPrice,
    this.stock,
    this.quantityAllowed,
    this.rating,
    this.availableStatus,
    this.status,
    this.approvalStatus,
    this.createdAt,
    this.updatedAt,
    this.totalOrders,
    this.totalPriceAfterCommission,
    this.avgRating,
    this.totalRatings,
    this.lastOrderDate,
    this.workingHours,
    this.restaurantMenu,
    this.attribute,
  });

  factory MenuItemDetails.fromJson(Map<String, dynamic>? json) {
    return MenuItemDetails(
      id: json?['id'],
      menuId: _toNullableInt(json?['menu_id']),
      restaurantId: _toNullableInt(json?['restaurant_id']),
      preparationTime: _toNullableString(
        json?['preparation_time'] ?? json?['prep_time'],
      ),
      serialNumber: _toNullableString(json?['serial_number']),
      restaurantAttributeId: _toNullableInt(
        json?['restaurant_attribute_id'] ??
            json?['grocery_attribute_id'] ??
            json?['attribute_id'],
      ),
      attributeValue: json?['attribute_value'],
      price: _toNullableString(json?['price']),
      discountPrice: _toNullableString(json?['discount_price']),
      stock: _toNullableInt(json?['stock']),
      quantityAllowed: _toNullableInt(json?['quantity_allowed']),
      rating: json?['rating'],
      availableStatus: _toNullableInt(json?['available_status']),
      status: json?['status'],
      approvalStatus: json?['approval_status'],
      createdAt: _toNullableString(json?['created_at']),
      updatedAt: _toNullableString(json?['updated_at']),
      totalOrders: _toNullableString(json?['total_orders']),
      totalPriceAfterCommission: json?['total_price_after_commission'],
      avgRating: json?['avg_rating'],
      totalRatings: json?['total_ratings'],
      lastOrderDate: _toNullableString(json?['last_order_date']),
      workingHours:
          (json?['working_hours'] as List?)
              ?.map((e) => WorkingHour.fromJson(e))
              .toList() ??
          [],
      // Restaurant endpoint returns `restaurant_menu`, grocery endpoint returns `grocery_menu`.
      // We map both into the same `restaurantMenu` field so the UI can render details.
      restaurantMenu: (() {
        final dynamic menuJson =
            json?['restaurant_menu'] ?? json?['grocery_menu'];
        if (menuJson == null) return null;
        if (menuJson is Map<String, dynamic>) {
          return RestaurantMenu.fromJson(menuJson);
        }
        if (menuJson is Map) {
          return RestaurantMenu.fromJson(Map<String, dynamic>.from(menuJson));
        }
        return null;
      })(),
      attribute: json?['attribute'] != null
          ? Attribute.fromJson(json?['attribute'])
          : null,
    );
  }
}

class WorkingHour {
  final int? id;
  final int? restaurantMenuItemId;
  final int? dayOfWeek;
  final int? byRestaurant;
  final int? isOpen24h;
  final int? status;
  final List<TimeSlot>? timeSlots;

  WorkingHour({
    this.id,
    this.restaurantMenuItemId,
    this.dayOfWeek,
    this.byRestaurant,
    this.isOpen24h,
    this.status,
    this.timeSlots,
  });

  factory WorkingHour.fromJson(Map<String, dynamic>? json) {
    return WorkingHour(
      id: _toNullableInt(json?['id']),
      restaurantMenuItemId: _toNullableInt(json?['restaurant_menu_item_id']),
      dayOfWeek: _toNullableInt(json?['day_of_week']),
      byRestaurant: _toNullableInt(json?['by_restaurant']),
      isOpen24h: _toNullableInt(json?['is_open_24h']),
      status: _toNullableInt(json?['status']),
      timeSlots:
          (json?['time_slots'] as List?)
              ?.map((e) => TimeSlot.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TimeSlot {
  final int? id;
  final int? itemWorkingHourId;
  final String? openTime;
  final String? closeTime;

  TimeSlot({this.id, this.itemWorkingHourId, this.openTime, this.closeTime});

  factory TimeSlot.fromJson(Map<String, dynamic>? json) {
    return TimeSlot(
      id: _toNullableInt(json?['id']),
      itemWorkingHourId: _toNullableInt(json?['item_working_hour_id']),
      openTime: _toNullableString(json?['open_time']),
      closeTime: _toNullableString(json?['close_time']),
    );
  }
}

class RestaurantMenu {
  final int? id;
  final String? nameEn;
  final String? categoryNameEn;
  final String? descriptionEn;
  final String? categoryNameAr;
  final String? categoryNameFr;
  final String? image;
  final int? isVeg;

  RestaurantMenu({
    this.id,
    this.nameEn,
    this.categoryNameEn,
    this.descriptionEn,
    this.categoryNameAr,
    this.categoryNameFr,
    this.image,
    this.isVeg,
  });

  factory RestaurantMenu.fromJson(Map<String, dynamic>? json) {
    final categoryJson = json?['category'];
    final categoryNameEnFallback = categoryJson is Map
        ? categoryJson['name_en']
        : null;
    final categoryNameArFallback = categoryJson is Map
        ? categoryJson['name_ar']
        : null;
    final categoryNameFrFallback = categoryJson is Map
        ? categoryJson['name_fr']
        : null;

    return RestaurantMenu(
      id: _toNullableInt(json?['id']),
      nameEn: _toNullableString(json?['name_en']),
      categoryNameEn: _toNullableString(
        json?['category_name_en'] ?? categoryNameEnFallback,
      ),
      descriptionEn: _toNullableString(json?['description_en']),
      categoryNameAr: _toNullableString(
        json?['category_name_ar'] ?? categoryNameArFallback,
      ),
      categoryNameFr: _toNullableString(
        json?['category_name_fr'] ?? categoryNameFrFallback,
      ),
      image: _toNullableString(json?['image']),
      isVeg: _toNullableInt(json?['is_veg']),
    );
  }
}

class Attribute {
  final int? id;
  final String? nameEn;

  Attribute({this.id, this.nameEn});

  factory Attribute.fromJson(Map<String, dynamic>? json) {
    return Attribute(
      id: _toNullableInt(json?['id']),
      nameEn: _toNullableString(json?['name_en']),
    );
  }
}

class MenuItemTag {
  final int? id;
  final int? restaurantMenuItemId;
  final int? restaurantTagId;
  final String? nameEn;

  MenuItemTag({
    this.id,
    this.restaurantMenuItemId,
    this.restaurantTagId,
    this.nameEn,
  });

  factory MenuItemTag.fromJson(Map<String, dynamic>? json) {
    return MenuItemTag(
      id: _toNullableInt(json?['id']),
      restaurantMenuItemId: _toNullableInt(json?['restaurant_menu_item_id']),
      restaurantTagId: _toNullableInt(
        json?['restaurant_tag_id'] ?? json?['grocery_tag_id'],
      ),
      nameEn: _toNullableString(json?['name_en']),
    );
  }
}
