class GroceryMenuItemsModel {
  bool? status;
  GroceryMenuItemsData? data;
  Message? message;

  GroceryMenuItemsModel({
    this.status,
    this.data,
    this.message,
  });

  factory GroceryMenuItemsModel.fromJson(Map<String, dynamic> json) {
    return GroceryMenuItemsModel(
      status: json['status'] == "true",
      data: json['data'] != null
          ? GroceryMenuItemsData.fromJson(json['data'])
          : null,
      message: json['message'] != null
          ? Message.fromJson(json['message'])
          : null,
    );
  }
}

class GroceryMenuItemsData {
  GroceryMenuItems? groceryMenuItems;
  int? total;

  GroceryMenuItemsData({
    this.groceryMenuItems,
    this.total,
  });

  factory GroceryMenuItemsData.fromJson(Map<String, dynamic> json) {
    return GroceryMenuItemsData(
      groceryMenuItems: json['grocery_menu_items'] != null
          ? GroceryMenuItems.fromJson(json['grocery_menu_items'])
          : null,
      total: json['total'] ?? 0,
    );
  }
}

class GroceryMenuItems {
  int? currentPage;
  List<GroceryItem>? items;

  GroceryMenuItems({
    this.currentPage,
    this.items,
  });

  factory GroceryMenuItems.fromJson(Map<String, dynamic> json) {
    return GroceryMenuItems(
      currentPage: json['current_page'] ?? 0,
      items: (json['data'] as List?)
              ?.map((e) => GroceryItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class GroceryItem {
  int? menuItemId;
  String? price;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  String? image;
  String? variantNameEn;
  int? status;
  int? availableStatus;
  List<Category>? categories;

  GroceryItem({
    this.menuItemId,
    this.price,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.image,
    this.variantNameEn,
    this.status,
    this.availableStatus,
    this.categories,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      menuItemId: json['menu_item_id'] ?? 0,
      price: json['price'] ?? "",
      nameEn: json['name_en'] ?? "",
      nameAr: json['name_ar'] ?? "",
      nameFr: json['name_fr'] ?? "",
      image: json['image'] ?? "",
      variantNameEn: json['variant_name_en'] ?? "",
      status: json['status'] ?? 0,
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
      nameEn: json['name_en'] ?? "",
      nameAr: json['name_ar'] ?? "",
      nameFr: json['name_fr'] ?? "",
      image: json['image'] ?? "",
    );
  }
}

class Message {
  List<String>? messageEn;
  List<String>? messageFr;
  List<String>? messageAr;

  Message({
    this.messageEn,
    this.messageFr,
    this.messageAr,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageEn: (json['message_en'] as List?)?.cast<String>() ?? [],
      messageFr: (json['message_fr'] as List?)?.cast<String>() ?? [],
      messageAr: (json['message_ar'] as List?)?.cast<String>() ?? [],
    );
  }
}