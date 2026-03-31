class RestaurantItemStockLogModel {
  final String? status;
  final StockData? data;
  final String? message;

  RestaurantItemStockLogModel({
    this.status,
    this.data,
    this.message,
  });

  factory RestaurantItemStockLogModel.fromJson(Map<String, dynamic>? json) {
    return RestaurantItemStockLogModel(
      status: json?['status']?.toString(),
      data: json?['data'] != null
          ? StockData.fromJson(json?['data'])
          : null,
      message: json?['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "data": data?.toJson(),
      "message": message,
    };
  }
}

class StockData {
  final StockLogs? stockLogs;
  final Product? product;

  StockData({
    this.stockLogs,
    this.product,
  });

  factory StockData.fromJson(Map<String, dynamic>? json) {
    return StockData(
      stockLogs: json?['stock_logs'] != null
          ? StockLogs.fromJson(json?['stock_logs'])
          : null,
      product: json?['product'] != null
          ? Product.fromJson(json?['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "stock_logs": stockLogs?.toJson(),
      "product": product?.toJson(),
    };
  }
}

class StockLogs {
  final int? currentPage;
  final List<StockLogItem>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<PaginationLink>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  StockLogs({
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

  factory StockLogs.fromJson(Map<String, dynamic>? json) {
    return StockLogs(
      currentPage: json?['current_page'],
      data: (json?['data'] as List?)
              ?.map((e) => StockLogItem.fromJson(e))
              .toList() ??
          [],
      firstPageUrl: json?['first_page_url']?.toString(),
      from: json?['from'],
      lastPage: json?['last_page'],
      lastPageUrl: json?['last_page_url']?.toString(),
      links: (json?['links'] as List?)
              ?.map((e) => PaginationLink.fromJson(e))
              .toList() ??
          [],
      nextPageUrl: json?['next_page_url']?.toString(),
      path: json?['path']?.toString(),
      perPage: json?['per_page'],
      prevPageUrl: json?['prev_page_url']?.toString(),
      to: json?['to'],
      total: json?['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "current_page": currentPage,
      "data": data?.map((e) => e.toJson()).toList() ?? [],
      "first_page_url": firstPageUrl,
      "from": from,
      "last_page": lastPage,
      "last_page_url": lastPageUrl,
      "links": links?.map((e) => e.toJson()).toList() ?? [],
      "next_page_url": nextPageUrl,
      "path": path,
      "per_page": perPage,
      "prev_page_url": prevPageUrl,
      "to": to,
      "total": total,
    };
  }
}

class StockLogItem {
  final int? id;
  final int? restaurantMenuItemId;
  final int? quantity;
  final int? currentStock;
  final int? movementType;
  final int? orderId;
  final String? reason;
  final int? addedBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? addedByName;

  StockLogItem({
    this.id,
    this.restaurantMenuItemId,
    this.quantity,
    this.currentStock,
    this.movementType,
    this.orderId,
    this.reason,
    this.addedBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.addedByName,
  });

  factory StockLogItem.fromJson(Map<String, dynamic>? json) {
    return StockLogItem(
      id: json?['id'],
      restaurantMenuItemId: json?['restaurant_menu_item_id'],
      quantity: json?['quantity'],
      currentStock: json?['current_stock'],
      movementType: json?['movement_type'],
      orderId: json?['order_id'],
      reason: json?['reason']?.toString(),
      addedBy: json?['added_by'],
      updatedBy: json?['updated_by'],
      createdAt: json?['created_at']?.toString(),
      updatedAt: json?['updated_at']?.toString(),
      addedByName: json?['added_by_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "restaurant_menu_item_id": restaurantMenuItemId,
      "quantity": quantity,
      "current_stock": currentStock,
      "movement_type": movementType,
      "order_id": orderId,
      "reason": reason,
      "added_by": addedBy,
      "updated_by": updatedBy,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "added_by_name": addedByName,
    };
  }
}

class PaginationLink {
  final String? url;
  final String? label;
  final int? page;
  final bool? active;

  PaginationLink({
    this.url,
    this.label,
    this.page,
    this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic>? json) {
    return PaginationLink(
      url: json?['url']?.toString(),
      label: json?['label']?.toString(),
      page: json?['page'],
      active: json?['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "label": label,
      "page": page,
      "active": active,
    };
  }
}

class Product {
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;

  Product({
    this.nameEn,
    this.nameAr,
    this.nameFr,
  });

  factory Product.fromJson(Map<String, dynamic>? json) {
    return Product(
      nameEn: json?['name_en']?.toString(),
      nameAr: json?['name_ar']?.toString(),
      nameFr: json?['name_fr']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name_en": nameEn,
      "name_ar": nameAr,
      "name_fr": nameFr,
    };
  }
}