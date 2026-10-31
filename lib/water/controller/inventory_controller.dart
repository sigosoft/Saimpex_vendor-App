import 'package:saimpex_vendor/water/core/water_api.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/water/model/inventory_product.dart';

class WaterInventoryController extends GetxController {
  bool isLoading = false;
  int selectedFilter = 0;
  String selectedCategory = 'All Categories';
  List<String> categories = ['All Categories'];

  WaterInventorySummary summary = const WaterInventorySummary();
  List<InventoryProduct> allProducts = [];

  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Gas vendors share these screens; hide stock and subscriptions for them.
    WaterApi.loadIsGas().then((_) => update());
    searchController.addListener(_onSearchChanged);
    fetchWaterMenuItems();
  }

  void _onSearchChanged() {
    update();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  int get allCount => allProducts.length;

  int get inStockCount {
    if (summary.inStock > 0) return summary.inStock;
    return allProducts
        .where((p) => p.status == InventoryStockStatus.inStock)
        .length;
  }

  int get lowStockCount {
    if (summary.lowStock > 0) return summary.lowStock;
    return allProducts
        .where((p) => p.status == InventoryStockStatus.lowStock)
        .length;
  }

  List<InventoryProduct> get lowStockProducts {
    return allProducts
        .where((p) => p.status == InventoryStockStatus.lowStock)
        .toList();
  }

  List<InventoryProduct> get products {
    final query = searchController.text.trim().toLowerCase();
    return allProducts.where((p) {
      if (selectedFilter == 1 && p.status != InventoryStockStatus.inStock) {
        return false;
      }
      if (selectedFilter == 2 && p.status != InventoryStockStatus.lowStock) {
        return false;
      }

      if (selectedCategory != 'All Categories' &&
          p.categoryName != null &&
          p.categoryName!.trim().toLowerCase() !=
              selectedCategory.trim().toLowerCase()) {
        return false;
      }

      if (query.isNotEmpty) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final idMatch = p.id.toLowerCase().contains(query);
        final catMatch = (p.categoryName ?? '').toLowerCase().contains(query);
        if (!nameMatch && !idMatch && !catMatch) return false;
      }

      return true;
    }).toList();
  }

  Future<void> fetchWaterMenuItems({int limit = 50}) async {
    isLoading = true;
    update();

    try {
      final token = await getSavedObject('token');
      if (token != null &&
          token.toString().isNotEmpty &&
          token.toString() != 'null') {
        DioClient().updateToken(token.toString());
      }

      final queryParams = <String, dynamic>{'limit': limit};

      debugPrint(
        '==================== GET WATER MENU ITEMS ====================',
      );
      debugPrint('Endpoint: ${ApiEndPoints.getWaterMenuItems}');
      debugPrint('Query: $queryParams');

      final response = await DioClient().get(
        ApiEndPoints.getWaterMenuItems,
        query: queryParams,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint(
        '==============================================================',
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
              dataMap['status'].toString() == 'true')) {
        final data = dataMap['data'];
        if (data is Map) {
          final summaryMap = data['summary'];
          if (summaryMap is Map) {
            summary = WaterInventorySummary.fromJson(
              Map<String, dynamic>.from(summaryMap),
            );
          }

          final menuItemsObj = data['water_menu_items'];
          List<dynamic> itemsList = [];
          if (menuItemsObj is Map && menuItemsObj['data'] is List) {
            itemsList = menuItemsObj['data'] as List;
          } else if (menuItemsObj is List) {
            itemsList = menuItemsObj;
          }

          allProducts = itemsList
              .whereType<Map>()
              .map(
                (e) => InventoryProduct.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();

          final catSet = <String>{'All Categories'};
          for (final p in allProducts) {
            if (p.categoryName != null && p.categoryName!.trim().isNotEmpty) {
              catSet.add(p.categoryName!.trim());
            }
          }
          categories = catSet.toList();
        }
      }
    } catch (e) {
      debugPrint(
        '==================== GET WATER MENU ITEMS ERROR ====================',
      );
      debugPrint('Error: $e');
      debugPrint(
        '===================================================================',
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  void selectFilter(int index) {
    selectedFilter = index;
    update();
  }

  void selectCategory(String cat) {
    selectedCategory = cat;
    update();
  }

  Future<bool> updateItemStatus(
    dynamic menuItemId, {
    int availableStatus = 2,
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

      dynamic id = menuItemId;
      if (id is String) {
        final clean = id.replaceAll('#', '').trim();
        id = int.tryParse(clean) ?? clean;
      }

      final queryParams = <String, dynamic>{
        'menu_item_id': id,
        'available_status': availableStatus,
      };

      debugPrint(
        '==================== UPDATE ITEM STATUS ====================',
      );
      debugPrint('Endpoint: ${ApiEndPoints.updateItemStatus}');
      debugPrint('Query: $queryParams');

      final response = await DioClient().get(
        ApiEndPoints.updateItemStatus,
        query: queryParams,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('===========================================================');

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

      final isSuccess =
          dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString().toLowerCase() == 'true' ||
              dataMap['status'] == 1 ||
              dataMap['status'] == '1');

      String message = isSuccess
          ? (availableStatus == 1
                ? S.current.waterItemMarkedAvailable
                : S.current.waterItemMarkedOutOfStock)
          : S.current.waterFailedToUpdateItemStatus;

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
        final targetIdx = allProducts.indexWhere(
          (p) =>
              (p.rawId != null && p.rawId.toString() == id.toString()) ||
              (p.menuId != null && p.menuId.toString() == id.toString()) ||
              p.id.replaceAll('#', '').trim() == id.toString(),
        );
        if (targetIdx != -1) {
          final p = allProducts[targetIdx];
          allProducts[targetIdx] = availableStatus == 1
              ? p.copyWith(
                  bottles: p.bottles > 0 ? p.bottles : 50,
                  status: InventoryStockStatus.inStock,
                )
              : p.copyWith(bottles: 0, status: InventoryStockStatus.outOfStock);
          update();
        }

        await fetchWaterMenuItems();
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
        '==================== UPDATE ITEM STATUS ERROR ====================',
      );
      debugPrint('Error: $e');
      debugPrint(
        '================================================================',
      );
      if (context != null && context.mounted) {
        showToast(context, S.current.waterErrorUpdatingItemStatus(e.toString()));
      }
      return false;
    }
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

      final isSuccess =
          dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString().toLowerCase() == 'true' ||
              dataMap['status'] == 1 ||
              dataMap['status'] == '1');

      String message = isSuccess
          ? S.current.waterStockUpdatedSuccessfully
          : S.current.waterFailedToUpdateStock;

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
        final targetIdx = allProducts.indexWhere(
          (p) =>
              (p.rawId != null && p.rawId.toString() == id.toString()) ||
              (p.menuId != null && p.menuId.toString() == id.toString()) ||
              p.id.replaceAll('#', '').trim() == id.toString(),
        );
        if (targetIdx != -1) {
          final p = allProducts[targetIdx];
          final lowAlert = p.lowStockAlert ?? 10;
          allProducts[targetIdx] = p.copyWith(
            bottles: quantity,
            status: quantity == 0
                ? InventoryStockStatus.outOfStock
                : quantity <= lowAlert
                ? InventoryStockStatus.lowStock
                : InventoryStockStatus.inStock,
          );
          update();
        }

        await fetchWaterMenuItems();
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
        showToast(context, S.current.waterErrorUpdatingStock(e.toString()));
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
          ? S.current.waterPriceUpdatedSuccessfully
          : S.current.waterFailedToUpdatePrice;

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
        final targetIdx = allProducts.indexWhere(
          (p) =>
              (p.rawId != null && p.rawId.toString() == id.toString()) ||
              (p.menuId != null && p.menuId.toString() == id.toString()) ||
              p.id.replaceAll('#', '').trim() == id.toString(),
        );
        if (targetIdx != -1) {
          allProducts[targetIdx] = allProducts[targetIdx].copyWith(
            price: cleanPrice,
          );
          update();
        }

        await fetchWaterMenuItems();
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
        '=======================================================================',
      );
      if (context != null && context.mounted) {
        showToast(context, S.current.waterErrorUpdatingPrice(e.toString()));
      }
      return false;
    }
  }

  Future<bool> deleteWaterMenuItem(
    dynamic itemId, {
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

      final queryParams = <String, dynamic>{
        'item_id': id,
      };

      debugPrint(
        '==================== GET DELETE WATER MENU ITEM ====================',
      );
      debugPrint('Endpoint: ${ApiEndPoints.deleteWaterMenuItem}');
      debugPrint('Query: $queryParams');

      final response = await DioClient().get(
        ApiEndPoints.deleteWaterMenuItem,
        query: queryParams,
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
          ? S.current.waterProductDeletedSuccessfully
          : S.current.waterFailedToDeleteProduct;

      if (dataMap != null && dataMap['message'] != null) {
        final msgObj = dataMap['message'];
        if (msgObj is Map) {
          final en = msgObj['message_en'] ?? msgObj['item_id'];
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
        allProducts.removeWhere(
          (p) =>
              (p.rawId != null && p.rawId.toString() == id.toString()) ||
              (p.menuId != null && p.menuId.toString() == id.toString()) ||
              p.id.replaceAll('#', '').trim() == id.toString(),
        );
        update();

        await fetchWaterMenuItems();
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
        '==================== DELETE WATER MENU ITEM ERROR ====================',
      );
      debugPrint('Error: $e');
      debugPrint(
        '=======================================================================',
      );
      if (context != null && context.mounted) {
        showToast(context, S.current.waterErrorDeletingProduct(e.toString()));
      }
      return false;
    }
  }

  void markOutOfStock(int index) {
    final currentList = products;
    if (index >= 0 && index < currentList.length) {
      final product = currentList[index];
      final targetIdx = allProducts.indexWhere((p) => p.id == product.id);
      if (targetIdx != -1) {
        allProducts[targetIdx] = allProducts[targetIdx].copyWith(
          bottles: 0,
          status: InventoryStockStatus.outOfStock,
        );
        update();
      }
    }
  }

  void markAvailable(int index) {
    final currentList = products;
    if (index >= 0 && index < currentList.length) {
      final product = currentList[index];
      final targetIdx = allProducts.indexWhere((p) => p.id == product.id);
      if (targetIdx != -1) {
        final p = allProducts[targetIdx];
        allProducts[targetIdx] = p.copyWith(
          bottles: p.bottles > 0 ? p.bottles : 50,
          status: InventoryStockStatus.inStock,
        );
        update();
      }
    }
  }

  void updateQuantity(int index, int quantity) {
    final currentList = products;
    if (index >= 0 && index < currentList.length) {
      final product = currentList[index];
      final targetIdx = allProducts.indexWhere((p) => p.id == product.id);
      if (targetIdx != -1) {
        final p = allProducts[targetIdx];
        final lowAlert = p.lowStockAlert ?? 10;
        allProducts[targetIdx] = p.copyWith(
          bottles: quantity,
          status: quantity == 0
              ? InventoryStockStatus.outOfStock
              : quantity <= lowAlert
              ? InventoryStockStatus.lowStock
              : InventoryStockStatus.inStock,
        );
        update();
      }
    }
  }

  void removeAt(int index) {
    final currentList = products;
    if (index >= 0 && index < currentList.length) {
      final product = currentList[index];
      allProducts.removeWhere((p) => p.id == product.id);
      update();
    }
  }
}
