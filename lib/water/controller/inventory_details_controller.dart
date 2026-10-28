import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/water/model/inventory_product.dart';

class WaterInventoryDetailsController extends GetxController {
  WaterInventoryDetailsController({InventoryProduct? initialProduct}) {
    if (initialProduct != null) {
      product = initialProduct;
      returnableBottle = initialProduct.returnable;
    }
  }

  late InventoryProduct product;
  bool isLoading = false;
  bool returnableBottle = true;
  Map<String, dynamic>? rawDetailData;
  Map<String, dynamic>? salesData;
  List<dynamic> stockLogs = [];

  void setReturnableBottle(bool value) {
    returnableBottle = value;
    update();
  }

  String get todayOrders {
    if (rawDetailData != null) {
      final v = rawDetailData!['today_orders'] ??
          rawDetailData!['today_orders_count'] ??
          rawDetailData!['orders_today'] ??
          rawDetailData!['item']?['today_orders'];
      if (v != null) return v.toString();
    }
    return '0';
  }

  Future<void> fetchWaterMenuItemDetail(dynamic itemId) async {
    if (itemId == null || itemId.toString().isEmpty) return;
    isLoading = true;
    update();

    try {
      final token = await getSavedObject('token');
      if (token != null &&
          token.toString().isNotEmpty &&
          token.toString() != 'null') {
        DioClient().updateToken(token.toString());
      }

      dynamic id = itemId;
      if (id is String) {
        final clean = id.replaceAll('#', '').trim();
        id = int.tryParse(clean) ?? clean;
      }

      final queryParams = <String, dynamic>{'item_id': id};

      debugPrint(
        '==================== GET WATER MENU ITEM DETAIL ====================',
      );
      debugPrint('Endpoint: ${ApiEndPoints.getWaterMenuItemDetail}');
      debugPrint('Query: $queryParams');

      final response = await DioClient().get(
        ApiEndPoints.getWaterMenuItemDetail,
        query: queryParams,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint(
        '====================================================================',
      );

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString() == 'true' ||
              dataMap['status'] == 1 ||
              dataMap['status'] == '1')) {
        final data = dataMap['data'];
        Map<String, dynamic>? itemMap;
        if (data is Map) {
          rawDetailData = Map<String, dynamic>.from(data);
          final rawItem = data['item'] ??
              data['water_menu_item'] ??
              data['menu_item'] ??
              data['menu_item_details'] ??
              data['item_details'] ??
              (data['name'] != null ||
                      data['price'] != null ||
                      data['id'] != null
                  ? data
                  : null);
          if (rawItem is Map) {
            itemMap = Map<String, dynamic>.from(rawItem);
            for (final key in ['images', 'image_items', 'menu_images']) {
              if (data[key] is List) {
                final existing = itemMap[key] is List
                    ? List.from(itemMap[key] as List)
                    : [];
                for (final el in (data[key] as List)) {
                  if (!existing.contains(el)) existing.add(el);
                }
                itemMap[key] = existing;
              }
            }
          }

          if (data['sales_performance'] is Map) {
            salesData = Map<String, dynamic>.from(data['sales_performance'] as Map);
          } else if (data['sales'] is Map) {
            salesData = Map<String, dynamic>.from(data['sales'] as Map);
          } else {
            salesData = null;
          }

          if (data['stock_logs'] is List) {
            stockLogs = data['stock_logs'] as List;
          } else if (data['stock_history'] is List) {
            stockLogs = data['stock_history'] as List;
          } else if (itemMap != null && itemMap['stock_logs'] is List) {
            stockLogs = itemMap['stock_logs'] as List;
          } else if (itemMap != null && itemMap['stock_history'] is List) {
            stockLogs = itemMap['stock_history'] as List;
          } else {
            stockLogs = [];
          }
        } else if (dataMap['item'] is Map) {
          itemMap = Map<String, dynamic>.from(dataMap['item'] as Map);
        }

        if (itemMap != null) {
          if (dataMap['images'] is List) {
            final existing = itemMap['images'] is List
                ? List.from(itemMap['images'] as List)
                : [];
            for (final el in (dataMap['images'] as List)) {
              if (!existing.contains(el)) existing.add(el);
            }
            itemMap['images'] = existing;
          }
          final incoming = InventoryProduct.fromJson(itemMap);
          product = _mergeProducts(product, incoming);
          returnableBottle = product.returnable;
        }
      }
    } catch (e) {
      debugPrint('Error fetching water menu item detail: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  InventoryProduct _mergeProducts(
    InventoryProduct base,
    InventoryProduct incoming,
  ) {
    final mergedImages = <String>[];
    for (final img in incoming.images) {
      if (!mergedImages.contains(img)) mergedImages.add(img);
    }
    for (final img in base.images) {
      if (!mergedImages.contains(img)) mergedImages.add(img);
    }

    return InventoryProduct(
      id: incoming.id.isNotEmpty ? incoming.id : base.id,
      name: incoming.name.isNotEmpty ? incoming.name : base.name,
      price: incoming.price.isNotEmpty ? incoming.price : base.price,
      originalPrice: incoming.originalPrice.isNotEmpty
          ? incoming.originalPrice
          : base.originalPrice,
      bottles: incoming.bottles != 0 ||
              incoming.status == InventoryStockStatus.outOfStock
          ? incoming.bottles
          : base.bottles,
      maxBottles:
          incoming.maxBottles > 0 ? incoming.maxBottles : base.maxBottles,
      status: incoming.status,
      rawId: incoming.rawId ?? base.rawId,
      menuId: incoming.menuId ?? base.menuId,
      image: incoming.image ?? base.image,
      images: mergedImages.isNotEmpty
          ? mergedImages
          : (incoming.images.isNotEmpty ? incoming.images : base.images),
      categoryName: incoming.categoryName ?? base.categoryName,
      size: incoming.size ?? base.size,
      barcode: incoming.barcode ?? base.barcode,
      description: incoming.description ?? base.description,
      stockLabel: incoming.stockLabel.isNotEmpty
          ? incoming.stockLabel
          : base.stockLabel,
      returnable: incoming.returnable,
      availableStatus: incoming.availableStatus ?? base.availableStatus,
      lowStockAlert: incoming.lowStockAlert ?? base.lowStockAlert,
      rawJson: incoming.rawJson ?? base.rawJson,
    );
  }

  Future<bool> updateWaterItemStock(
    dynamic itemId,
    int quantity, {
    BuildContext? context,
  }) async {
    bool dialogShown = false;
    try {
      if (context != null && context.mounted) {
        showLoadingDialog(context);
        dialogShown = true;
      }

      final token = await getSavedObject('token');
      if (token != null &&
          token.toString().isNotEmpty &&
          token.toString() != 'null') {
        DioClient().updateToken(token.toString());
      }

      dynamic id = itemId;
      if (id is String) {
        final clean = id.replaceAll('#', '').trim();
        id = int.tryParse(clean) ?? clean;
      }

      final formData = FormData.fromMap({
        'item_id': id,
        'stock': quantity.toString(),
        'quantity': quantity.toString(),
      });

      debugPrint(
        '==================== POST UPDATE WATER ITEM STOCK ====================',
      );
      debugPrint('Endpoint: ${ApiEndPoints.UpdateWaterItemStock}');
      debugPrint('item_id: $id, stock/quantity: $quantity');

      final response = await DioClient().post(
        ApiEndPoints.UpdateWaterItemStock,
        body: formData,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint(
        '======================================================================',
      );

      if (dialogShown) {
        if (context != null && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          Get.back();
        }
        dialogShown = false;
      }

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      final isSuccess = dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString().toLowerCase() == 'true' ||
              dataMap['status'] == 1 ||
              dataMap['status'] == '1');

      String message = isSuccess
          ? 'Stock updated successfully'
          : 'Failed to update stock';

      if (dataMap != null && dataMap['message'] != null) {
        final msgObj = dataMap['message'];
        if (msgObj is Map) {
          final en = msgObj['message_en'];
          if (en is List && en.isNotEmpty) {
            message = en.first.toString();
          } else if (en != null && en.toString().trim().isNotEmpty) {
            message = en.toString().trim();
          } else {
            final fr = msgObj['message_fr'];
            if (fr is List && fr.isNotEmpty) {
              message = fr.first.toString();
            } else if (fr != null && fr.toString().trim().isNotEmpty) {
              message = fr.toString().trim();
            }
          }
        } else if (msgObj is String && msgObj.trim().isNotEmpty) {
          message = msgObj.trim();
        }
      }

      if (context != null && context.mounted) {
        showToast(context, message);
      }

      if (isSuccess) {
        final lowAlert = product.lowStockAlert ?? 10;
        product = product.copyWith(
          bottles: quantity,
          status: quantity == 0
              ? InventoryStockStatus.outOfStock
              : quantity <= lowAlert
                  ? InventoryStockStatus.lowStock
                  : InventoryStockStatus.inStock,
        );
        update();

        await fetchWaterMenuItemDetail(itemId);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (dialogShown) {
        if (context != null && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          Get.back();
        }
        dialogShown = false;
      }
      debugPrint(
        '==================== UPDATE WATER ITEM STOCK ERROR ====================',
      );
      debugPrint('Error: $e');
      debugPrint(
        '=======================================================================',
      );
      if (context != null && context.mounted) {
        showToast(context, 'Error updating stock: $e');
      }
      return false;
    }
  }

  Future<bool> updateWaterMenuItemPrice(
    dynamic itemId,
    String price, {
    BuildContext? context,
  }) async {
    bool dialogShown = false;
    try {
      if (context != null && context.mounted) {
        showLoadingDialog(context);
        dialogShown = true;
      }

      final token = await getSavedObject('token');
      if (token != null &&
          token.toString().isNotEmpty &&
          token.toString() != 'null') {
        DioClient().updateToken(token.toString());
      }

      dynamic id = itemId;
      if (id is String) {
        final clean = id.replaceAll('#', '').trim();
        id = int.tryParse(clean) ?? clean;
      }

      final cleanPrice = price.trim();

      final queryParams = <String, dynamic>{
        'item_id': id,
        'price': cleanPrice,
      };

      final formData = FormData.fromMap({
        'item_id': id,
        'price': cleanPrice,
      });

      debugPrint(
        '==================== POST UPDATE WATER MENU ITEM ====================',
      );
      debugPrint('Endpoint: ${ApiEndPoints.UpdateWaterMenuItem}');
      debugPrint('Query: $queryParams');
      debugPrint('Body item_id: $id, price: $cleanPrice');

      final response = await DioClient().post(
        ApiEndPoints.UpdateWaterMenuItem,
        query: queryParams,
        body: formData,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint(
        '=====================================================================',
      );

      if (dialogShown) {
        if (context != null && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          Get.back();
        }
        dialogShown = false;
      }

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      final isSuccess = dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString().toLowerCase() == 'true' ||
              dataMap['status'] == 1 ||
              dataMap['status'] == '1');

      String message = isSuccess
          ? 'Price updated successfully'
          : 'Failed to update price';

      if (dataMap != null && dataMap['message'] != null) {
        final msgObj = dataMap['message'];
        if (msgObj is Map) {
          final en =
              msgObj['message_en'] ?? msgObj['price'] ?? msgObj['item_id'];
          if (en is List && en.isNotEmpty) {
            message = en.first.toString();
          } else if (en != null && en.toString().trim().isNotEmpty) {
            message = en.toString().trim();
          } else {
            final fr = msgObj['message_fr'];
            if (fr is List && fr.isNotEmpty) {
              message = fr.first.toString();
            } else if (fr != null && fr.toString().trim().isNotEmpty) {
              message = fr.toString().trim();
            }
          }
        } else if (msgObj is String && msgObj.trim().isNotEmpty) {
          message = msgObj.trim();
        }
      }

      if (context != null && context.mounted) {
        showToast(context, message);
      }

      if (isSuccess) {
        product = product.copyWith(price: cleanPrice);
        update();

        await fetchWaterMenuItemDetail(itemId);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (dialogShown) {
        if (context != null && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          Get.back();
        }
        dialogShown = false;
      }
      debugPrint(
        '==================== UPDATE WATER MENU ITEM ERROR ====================',
      );
      debugPrint('Error: $e');
      debugPrint(
        '======================================================================',
      );
      if (context != null && context.mounted) {
        showToast(context, 'Error updating price: $e');
      }
      return false;
    }
  }
}
