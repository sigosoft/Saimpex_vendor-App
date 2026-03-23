import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/model/attributes_model.dart';
import 'package:saimpex_vendor/model/menu_listing_model.dart';
import 'package:saimpex_vendor/model/restaurant_menu_items_model.dart';
import 'package:saimpex_vendor/model/restaurant_items_detail_model.dart';
import 'package:saimpex_vendor/model/tag_model.dart';
import 'package:saimpex_vendor/Utils/Utils.dart';

class ItemController extends GetxController {
  final String? editRestaurantMenuItemId;
  ItemController({this.editRestaurantMenuItemId});
  final TextEditingController prepTimeCtrl = TextEditingController();
  final TextEditingController serialNumberCtrl = TextEditingController();
  final TextEditingController maxQuantityCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController discountPriceCtrl = TextEditingController();
  String? selectedType;
  String? selectedTag;
  String? selectedAttribute;
  int? selectedMenuId;
  int? selectedRestaurantAttributeId;
  int? selectedRestaurantTagId;

  String formatPreparationTimeToHi(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return '';

    if (value.contains(':')) {
      final parts = value.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0].trim());
        final minute = int.tryParse(parts[1].trim());
        if (hour != null && minute != null) {
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        }
      }
      return value;
    }
    final totalMinutes = int.tryParse(value);
    if (totalMinutes == null) return value;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  List<String> get typeDisplayNames =>
      menuList.map((e) => e.nameEn).where((s) => s.isNotEmpty).toList();

  List<String> get tagDisplayNames => restaurantTags
      .map((e) => e.nameEn ?? '')
      .where((s) => s.isNotEmpty)
      .toList();

  List<String> get attributeDisplayNames => restaurantAttributes
      .map((e) => e.nameEn ?? '')
      .where((s) => s.isNotEmpty)
      .toList();

  bool isMenuListLoading = false;
  List<MenuItem> menuList = [];

  bool isRestaurantTagsLoading = false;
  List<TagData> restaurantTags = [];

  bool isRestaurantAttributesLoading = false;
  List<AttributeData> restaurantAttributes = [];

  @override
  void onInit() {
    super.onInit();
    getAllMenus();
    getAllTags();
    getAllAttributes();
    if (editRestaurantMenuItemId != null) {
      _prefillEditValues(editRestaurantMenuItemId!);
    }
    debugPrint("ItemController initialized");
  }

  Future<void> _prefillEditValues(String restaurantMenuItemId) async {
    try {
      serialNumberCtrl.text = restaurantMenuItemId;
      final profileController = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController(), permanent: false);
      if (profileController.restaurantMenuItems.isEmpty) {
        await profileController.fetchRestaurantMenuItems();
      }
      final match = profileController.restaurantMenuItems.firstWhere(
        (e) =>
            e.id?.toString() == restaurantMenuItemId ||
            e.restaurantMenuItemId?.toString() == restaurantMenuItemId,
        orElse: () => RestaurantMenuItemData(),
      );
      if (match.price != null && match.price!.isNotEmpty) {
        priceCtrl.text = match.price!;
      }
      if (match.discountPrice != null && match.discountPrice!.isNotEmpty) {
        discountPriceCtrl.text = match.discountPrice!;
      }
      final categoryId = match.categoryId?.toString();
      if (categoryId != null && categoryId.isNotEmpty && menuList.isNotEmpty) {
        final menuMatch = menuList
            .where((m) => m.categoryId.contains(categoryId))
            .toList();
        if (menuMatch.isNotEmpty) {
          setSelectedType(menuMatch.first.nameEn);
        }
      }
      update();
    } catch (_) {}
  }

  Future<void> updateItem(
    BuildContext context, {
    required String restaurantMenuItemId,
  }) async {
    await deleteItem(context, restaurantMenuItemId: restaurantMenuItemId);
    await addItem(
      context,
      menuId: selectedMenuId?.toString() ?? '',
      menuItemId: serialNumberCtrl.text.trim(),
      restaurantAttributeId: selectedRestaurantAttributeId?.toString() ?? '',
    );
  }

  @override
  void onClose() {
    prepTimeCtrl.dispose();
    serialNumberCtrl.dispose();
    maxQuantityCtrl.dispose();
    priceCtrl.dispose();
    discountPriceCtrl.dispose();
    super.onClose();
  }

  void setSelectedType(String? value) {
    selectedType = value;
    final match = menuList.where((m) => m.nameEn == value);
    selectedMenuId = match.isEmpty ? null : match.first.id;
    update();
  }

  void setSelectedTag(String? value) {
    selectedTag = value;
    final match = restaurantTags.where((t) => t.nameEn == value);
    selectedRestaurantTagId = match.isEmpty ? null : match.first.id;
    update();
  }

  void setSelectedAttribute(String? value) {
    selectedAttribute = value;
    final match = restaurantAttributes.where((a) => a.nameEn == value);
    selectedRestaurantAttributeId = match.isEmpty ? null : match.first.id;
    update();
  }

  void reset() {
    prepTimeCtrl.clear();
    serialNumberCtrl.clear();
    maxQuantityCtrl.clear();
    priceCtrl.clear();
    discountPriceCtrl.clear();
    selectedType = null;
    selectedMenuId = null;
    selectedTag = null;
    selectedAttribute = null;
    selectedRestaurantAttributeId = null;
    selectedRestaurantTagId = null;
    update();
  }

  void onSubmit(BuildContext context) {
    if (selectedAttribute == null) {
      showToast(context, "Please select attribute");
      return;
    }
    if (priceCtrl.text.isEmpty) {
      showToast(context, "Please enter price");
      return;
    }
    final profileController = Get.find<ProfileController>();
    profileController.addGroceryMenuItem(
      context,
      menuId: "1",
      attributeValue: "2",
      groceryAttributeId: "5",
      price: priceCtrl.text,
      discountPrice: discountPriceCtrl.text.isNotEmpty
          ? discountPriceCtrl.text
          : priceCtrl.text,
      quantityAllowed: maxQuantityCtrl.text.isNotEmpty
          ? maxQuantityCtrl.text
          : "10",
      serialNumber: serialNumberCtrl.text.isNotEmpty
          ? serialNumberCtrl.text
          : "SN-${DateTime.now().millisecondsSinceEpoch}",
    );
  }

  bool addItemValidation(
    BuildContext context, {
    required String? menuId,
    required String? menuItemId,
    required String? restaurantAttributeId,
  }) {
    if (menuId == null || menuId.trim().isEmpty) {
      showToast(context, "Menu id is required");
      return false;
    } else if (menuItemId == null || menuItemId.trim().isEmpty) {
      showToast(context, "Menu item id is required");
      return false;
    } else if (restaurantAttributeId == null ||
        restaurantAttributeId.trim().isEmpty) {
      showToast(context, "Restaurant attribute id is required");
      return false;
    } else if (priceCtrl.text.trim().isEmpty) {
      showToast(context, "Please enter price");
      return false;
    } else if (discountPriceCtrl.text.trim().isEmpty) {
      showToast(context, "Please enter discount price");
      return false;
    } else if (prepTimeCtrl.text.trim().isEmpty) {
      showToast(context, "Please enter preparation time");
      return false;
    } else if (serialNumberCtrl.text.trim().isEmpty) {
      showToast(context, "Please enter serial number");
      return false;
    } else if (selectedRestaurantTagId == null) {
      showToast(context, "Please select tag");
      return false;
    }
    return true;
  }

  Future<void> addItem(
    BuildContext context, {
    required String menuId,
    required String menuItemId,
    required String restaurantAttributeId,
  }) async {
    final isValid = addItemValidation(
      context,
      menuId: menuId,
      menuItemId: menuItemId,
      restaurantAttributeId: restaurantAttributeId,
    );
    if (!isValid) return;
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final vendorType = (await getSavedObject("vendorType"))?.toString() ?? '';
      final formDataMap = <String, dynamic>{
        "menu_id": menuId,
        "menu_item_id": menuItemId,
        "restaurant_attribute_id": restaurantAttributeId,
        "price": priceCtrl.text.trim(),
        "discount_price": discountPriceCtrl.text.trim(),
        "preparation_time": formatPreparationTimeToHi(prepTimeCtrl.text),
        "serial_number": serialNumberCtrl.text.trim(),
        "quantity_allowed": maxQuantityCtrl.text.trim(),
      };

      final formData = dio.FormData.fromMap(formDataMap);
      formData.fields.add(
        MapEntry("tags[0]", selectedRestaurantTagId.toString()),
      );
      printFormData(formData);
      final response = await DioClient().post(
        vendorType == "1"
            ? ApiEndPoints.addRestaurantMenuItem
            : ApiEndPoints.addGroceryMenuItem,
        body: formData,
      );
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          String successMessage = "Leave marked successfully";
          if (response.data['message'] != null) {
            var msgMap = response.data['message'];
            if (msgMap is Map &&
                msgMap.containsKey('message_en') &&
                msgMap['message_en'] is List &&
                msgMap['message_en'].isNotEmpty) {
              successMessage = msgMap['message_en'][0];
            }
          }
          showToast(context, successMessage);
          final profileController = Get.find<ProfileController>();
          await profileController.fetchRestaurantMenuItems();
          if (context.mounted) {
            Get.back();
          }
        }
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ?? "Failed to mark leave",
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
        debugPrint("addItem Error: $error");
      }
    }
  }

  Future<void> getAllMenus() async {
    try {
      isMenuListLoading = true;
      update();

      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final vendorType = (await getSavedObject("vendorType"))?.toString() ?? '';
      final response = await DioClient().get(
        vendorType == "1"
            ? ApiEndPoints.getRestaurantMenus
            : ApiEndPoints.getGroceryMenus,
      );
      final model = MenuListingModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );
      if (model.status) {
        menuList = model.data;
      }

      // If we already loaded an item for editing, resolve `selectedMenuId`
      // once the menus list becomes available.
      if (selectedType != null &&
          selectedType!.isNotEmpty &&
          menuList.isNotEmpty) {
        final match = menuList.where((m) => m.nameEn == selectedType).toList();
        if (match.isNotEmpty) {
          selectedMenuId = match.first.id;
        }
      }
    } catch (error) {
      debugPrint("getAllMenus Error: $error");
    } finally {
      isMenuListLoading = false;
      update();
    }
  }

  Future<void> getAllTags() async {
    try {
      isRestaurantTagsLoading = true;
      update();

      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(
        vendorType == "1"
            ? ApiEndPoints.getRestaurantTags
            : ApiEndPoints.getGroceryTags,
      );
      final tagsModel = TagsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (tagsModel.status == 'true') {
        restaurantTags = tagsModel.data ?? [];
      }
    } catch (error) {
      debugPrint("getAllTags Error: $error");
    } finally {
      isRestaurantTagsLoading = false;
      update();
    }
  }

  Future<void> getAllAttributes() async {
    try {
      isRestaurantAttributesLoading = true;
      update();

      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(
        vendorType == "1"
            ? ApiEndPoints.getRestaurantAttributes
            : ApiEndPoints.getGroceryAttributes,
      );
      final attributesModel = AttributesModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );
      if (attributesModel.status == true) {
        restaurantAttributes = attributesModel.data ?? [];
      }
    } catch (error, stackTrace) {
      debugPrint("getAllAttributes Error: $error");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isRestaurantAttributesLoading = false;
      update();
    }
  }

  Future<void> deleteItem(
    BuildContext context, {
    required String restaurantMenuItemId,
  }) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final formDataMap = <String, dynamic>{
        "menu_item_id": restaurantMenuItemId,
      };

      final response = await DioClient().get(
        vendorType == "1"
            ? ApiEndPoints.deleteRestaurantMenuItem
            : ApiEndPoints.deleteGroceryMenuItem,
        query: formDataMap,
      );
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          await profileController.fetchRestaurantMenuItems();
        }
        if (context.mounted) {
          String successMessage = "Leave marked successfully";
          if (response.data['message'] != null) {
            var msgMap = response.data['message'];
            if (msgMap is Map &&
                msgMap.containsKey('message_en') &&
                msgMap['message_en'] is List &&
                msgMap['message_en'].isNotEmpty) {
              successMessage = msgMap['message_en'][0];
            }
          }
          showToast(context, successMessage);
        }
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ?? "Failed to mark leave",
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }

  Future<void> getRestaurantMenuItemDetails(String itemId) async {
    try {
      debugPrint("getRestaurantMenuItemDetails itemId: $itemId");
      isRestaurantAttributesLoading = true;
      update();
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(
        vendorType == "1"
            ? ApiEndPoints.getRestaurantMenuItemDetails
            : ApiEndPoints.getGroceryMenuItemDetails,
        query: {"item_id": itemId},
      );
      final raw = response.data;
      debugPrint("getRestaurantMenuItemDetails raw: $raw");
      if (raw is! Map) return;
      final model = RestaurantItemsDetailsModel.fromJson(
        raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw),
      );

      final details = model.data?.menuItemDetails;
      if (details == null) return;
      serialNumberCtrl.text =
          details.serialNumber?.toString() ?? serialNumberCtrl.text;
      prepTimeCtrl.text =
          details.preparationTime?.toString() ?? prepTimeCtrl.text;
      maxQuantityCtrl.text =
          details.quantityAllowed?.toString() ?? maxQuantityCtrl.text;
      priceCtrl.text = details.price?.toString() ?? priceCtrl.text;
      discountPriceCtrl.text =
          details.discountPrice?.toString() ?? discountPriceCtrl.text;

      // Menu id (used by update API as `menu_id`)
      if (details.menuId != null) {
        selectedMenuId = details.menuId;
      }

      // Item type dropdown value (if available)
      final menuName = details.restaurantMenu?.nameEn;
      if (menuName != null && menuName.isNotEmpty) {
        // Keep the dropdown label.
        selectedType = menuName;
        // If menus are already loaded, also resolve the correct `menu_id`.
        if (menuList.isNotEmpty) {
          setSelectedType(menuName);
        }
      }

      // Attribute id + name
      if (details.restaurantAttributeId != null) {
        selectedRestaurantAttributeId = details.restaurantAttributeId;
      }
      final attrName = details.attribute?.nameEn;
      if (attrName != null && attrName.isNotEmpty) {
        selectedAttribute = attrName;
      }

      // Tag id + name
      final tags = model.data?.menuItemTags ?? [];
      if (tags.isNotEmpty) {
        final first = tags.first;
        if (first.restaurantTagId != null) {
          selectedRestaurantTagId = first.restaurantTagId;
        }
        if (first.nameEn != null && first.nameEn!.isNotEmpty) {
          selectedTag = first.nameEn;
        }
      }
      update();
    } catch (error, stackTrace) {
      debugPrint("getRestaurantMenuItemDetails Error: $error");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isRestaurantAttributesLoading = false;
      update();
    }
  }

  Future<void> updateItemAfterEdit(
    BuildContext context, {
    required String menuId,
    required String menuItemId,
    required String restaurantAttributeId,
  }) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final formDataMap = <String, dynamic>{
        "menu_item_id": menuItemId,
        vendorType == "1" ? "restaurant_attribute_id" : "grocery_attribute_id":
            restaurantAttributeId,
        "price": priceCtrl.text.trim(),
        "discount_price": discountPriceCtrl.text.trim(),
        "preparation_time": formatPreparationTimeToHi(prepTimeCtrl.text),
        "serial_number": serialNumberCtrl.text.trim(),
        "quantity_allowed": maxQuantityCtrl.text.trim(),
      };
      debugPrint("formDataMap (updateItemAfterEdit):");
      for (final e in formDataMap.entries) {
        debugPrint("  ${e.key}: ${e.value}");
      }
      final formData = dio.FormData.fromMap(formDataMap);
      formData.fields.add(
        MapEntry("tags[0]", selectedRestaurantTagId.toString()),
      );
      printFormData(formData);
      final response = await DioClient().post(
        vendorType == "1"
            ? ApiEndPoints.updateRestaurantMenuItem
            : ApiEndPoints.updateGroceryMenuItem,

        body: formData,
      );
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          String successMessage = "Leave marked successfully";
          if (response.data['message'] != null) {
            var msgMap = response.data['message'];
            if (msgMap is Map &&
                msgMap.containsKey('message_en') &&
                msgMap['message_en'] is List &&
                msgMap['message_en'].isNotEmpty) {
              successMessage = msgMap['message_en'][0];
            }
          }
          showToast(context, successMessage);
          final profileController = Get.find<ProfileController>();
          await profileController.fetchRestaurantMenuItems();
          if (context.mounted) {
            Get.back();
          }
        }
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ?? "Failed to mark leave",
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
        debugPrint("addItem Error: $error");
      }
    }
  }
}
