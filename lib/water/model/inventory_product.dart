import 'package:saimpex_vendor/generated/l10n.dart';
import 'dart:convert';

enum InventoryStockStatus { inStock, lowStock, outOfStock }

class WaterInventorySummary {
  const WaterInventorySummary({
    this.available = 0,
    this.todayOrders = 0,
    this.lowStock = 0,
    this.outOfStock = 0,
    this.inStock = 0,
    this.lowStockItem,
  });

  final int available;
  final int todayOrders;
  final int lowStock;
  final int outOfStock;
  final int inStock;
  final dynamic lowStockItem;

  factory WaterInventorySummary.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return WaterInventorySummary(
      available: toInt(json['available']),
      todayOrders: toInt(json['today_orders']),
      lowStock: toInt(json['low_stock']),
      outOfStock: toInt(json['out_of_stock']),
      inStock: toInt(json['in_stock']),
      lowStockItem: json['low_stock_item'],
    );
  }
}

class InventoryProduct {
  const InventoryProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.bottles,
    required this.maxBottles,
    required this.status,
    this.rawId,
    this.menuId,
    this.image,
    this.images = const [],
    this.categoryName,
    this.size,
    this.barcode,
    this.description,
    this.stockLabel = '',
    this.returnable = false,
    this.availableStatus,
    this.lowStockAlert,
    this.rawJson,
  });

  final String id;
  final String name;
  final String price;
  final String originalPrice;
  final int bottles;
  final int maxBottles;
  final InventoryStockStatus status;
  final dynamic rawId;
  final dynamic menuId;
  final String? image;
  final List<String> images;
  final String? categoryName;
  final String? size;
  final String? barcode;
  final String? description;
  final String stockLabel;
  final bool returnable;
  final int? availableStatus;
  final int? lowStockAlert;
  final Map<String, dynamic>? rawJson;

  InventoryProduct copyWith({
    int? bottles,
    InventoryStockStatus? status,
    String? price,
    String? originalPrice,
    int? maxBottles,
    String? stockLabel,
  }) {
    return InventoryProduct(
      id: id,
      name: name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      bottles: bottles ?? this.bottles,
      maxBottles: maxBottles ?? this.maxBottles,
      status: status ?? this.status,
      rawId: rawId,
      menuId: menuId,
      image: image,
      images: images,
      categoryName: categoryName,
      size: size,
      barcode: barcode,
      description: description,
      stockLabel: stockLabel ?? this.stockLabel,
      returnable: returnable,
      availableStatus: availableStatus,
      lowStockAlert: lowStockAlert,
      rawJson: rawJson,
    );
  }

  factory InventoryProduct.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final idStr = rawId != null ? '# $rawId' : '';
    final nameStr =
        json['name']?.toString() ??
        json['menu_name_en']?.toString() ??
        json['menu_name']?.toString() ??
        '';

    final (priceStr, originalPriceStr) = _parsePrices(json);

    final stockInt = (json['stock'] is num)
        ? (json['stock'] as num).toInt()
        : int.tryParse(json['stock']?.toString() ?? '0') ?? 0;

    final lowAlert = (json['low_stock_alert'] is num)
        ? (json['low_stock_alert'] as num).toInt()
        : int.tryParse(json['low_stock_alert']?.toString() ?? '10') ?? 10;

    final availStatus = json['available_status'] is num
        ? (json['available_status'] as num).toInt()
        : int.tryParse(json['available_status']?.toString() ?? '1');

    final stockStatusStr = (json['stock_status']?.toString() ?? '')
        .toLowerCase()
        .trim();

    final InventoryStockStatus stockStatus;
    if (availStatus == 2 ||
        availStatus == 0 ||
        stockStatusStr == 'out of stock' ||
        stockInt == 0) {
      stockStatus = InventoryStockStatus.outOfStock;
    } else if (stockStatusStr == 'low stock' || stockInt <= lowAlert) {
      stockStatus = InventoryStockStatus.lowStock;
    } else {
      stockStatus = InventoryStockStatus.inStock;
    }

    final maxBottlesInt = stockInt > 0
        ? (stockInt < 100 ? 100 : (stockInt * 1.33).round())
        : 100;

    // Image resolution
    final List<String> allImages = [];
    void appendImg(dynamic val) {
      if (val == null) return;
      if (val is Map) {
        final img =
            val['image'] ??
            val['menu_image'] ??
            val['image_url'] ??
            val['url'] ??
            val['image_path'] ??
            val['path'] ??
            val['photo'] ??
            val['file'] ??
            val['item_image'];
        if (img != null &&
            img.toString().trim().isNotEmpty &&
            img.toString().trim() != 'null') {
          final s = img.toString().trim();
          if (!allImages.contains(s)) {
            allImages.add(s);
          }
        }
      } else if (val is String &&
          val.trim().isNotEmpty &&
          val.trim() != 'null') {
        final s = val.trim();
        if (!allImages.contains(s)) {
          allImages.add(s);
        }
      }
    }

    void parseImageCollection(dynamic col) {
      if (col == null) return;
      dynamic parsed = col;
      if (parsed is String) {
        final str = parsed.trim();
        if (str.startsWith('[') || str.startsWith('{')) {
          try {
            parsed = jsonDecode(str);
          } catch (_) {}
        } else if (str.isNotEmpty && str != 'null') {
          appendImg(str);
          return;
        }
      }
      if (parsed is List) {
        for (final it in parsed) {
          appendImg(it);
        }
      } else if (parsed is Map) {
        for (final it in parsed.values) {
          appendImg(it);
        }
      }
    }

    appendImg(json['menu_image']);
    appendImg(json['image']);
    parseImageCollection(json['images']);
    parseImageCollection(json['image_items']);
    parseImageCollection(json['menu_images']);
    parseImageCollection(json['water_menu_item_images']);
    parseImageCollection(json['product_images']);
    parseImageCollection(json['media']);
    parseImageCollection(json['gallery']);

    final rawImage = allImages.isNotEmpty
        ? allImages.first
        : json['menu_image']?.toString();

    return InventoryProduct(
      id: idStr,
      name: nameStr,
      price: priceStr,
      originalPrice: originalPriceStr,
      bottles: stockInt,
      maxBottles: maxBottlesInt,
      status: stockStatus,
      rawId: rawId,
      menuId: json['menu_id'],
      image: rawImage,
      images: allImages,
      categoryName:
          json['category_name']?.toString() ??
          (json['category'] is Map
              ? (json['category']['name_en'] ?? json['category']['name'])
                    ?.toString()
              : json['category']?.toString()),
      size:
          json['size_name']?.toString() ??
          json['attribute_value']?.toString() ??
          (json['size'] is Map
              ? (json['size']['name_en'] ??
                        json['size']['name'] ??
                        json['size']['value'])
                    ?.toString()
              : (json['attribute'] is Map
                    ? (json['attribute']['name_en'] ??
                              json['attribute']['name'] ??
                              json['attribute']['value'])
                          ?.toString()
                    : json['size']?.toString())),
      barcode: json['barcode']?.toString() ?? json['serial_number']?.toString(),
      description:
          json['description']?.toString() ?? json['description_en']?.toString(),
      stockLabel: json['stock_label']?.toString() ?? S.current.waterBottlesCount(stockInt.toString()),
      returnable:
          json['is_returnable'] == 1 ||
          json['is_returnable'] == '1' ||
          json['is_returnable'] == true ||
          json['returnable'] == true ||
          json['returnable'] == 1 ||
          json['returnable'] == '1',
      availableStatus: availStatus,
      lowStockAlert: lowAlert,
      rawJson: json,
    );
  }

  static (String, String) _parsePrices(Map<String, dynamic> json) {
    final rawSelling = json['selling_price'] ?? json['price'];
    final rawOffer = json['offer_price'] ?? json['discount_price'];
    final rawMrp = json['mrp_amount'] ?? json['mrp'];

    double? parseD(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final selling = parseD(rawSelling);
    final offer = parseD(rawOffer);
    final mrp = parseD(rawMrp);

    String fmt(double val) => '${val.toStringAsFixed(2)} MRU';

    if (offer != null && offer > 0 && selling != null && offer < selling) {
      return (fmt(offer), fmt(selling));
    }
    if (selling != null && mrp != null && selling < mrp) {
      return (fmt(selling), fmt(mrp));
    }
    if (selling != null) {
      return (fmt(selling), '');
    }
    if (mrp != null) {
      return (fmt(mrp), '');
    }
    return ('0.00 MRU', '');
  }
}
