import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart' as dio;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/model/attributes_model.dart';
import 'package:saimpex_vendor/model/menu_listing_model.dart';
import 'package:saimpex_vendor/model/restaurant_menu_items_model.dart';
import 'package:saimpex_vendor/model/restaurant_items_detail_model.dart';
import 'package:saimpex_vendor/model/tag_model.dart';
import 'package:saimpex_vendor/model/success_model.dart';
import 'package:saimpex_vendor/Utils/Utils.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/restaurant_menu_item_stock_logs_model.dart';

class CatalogExtraItem {
  /// Server id when editing an existing extra; null for a new one.
  final int? id;
  final String name;
  final num additionalPrice;
  final int availableStatus;
  final String? imagePath;

  CatalogExtraItem({
    this.id,
    required this.name,
    required this.additionalPrice,
    this.availableStatus = 1,
    this.imagePath,
  });
}

/// A size/portion of a restaurant catalog item; each has its own price.
class CatalogVariant {
  /// Server id (restaurant_menu_items.id) when editing; null for a new variant.
  final int? id;
  final String name;
  final num price;
  final String selectionRequirement;
  final String? imagePath;

  CatalogVariant({
    this.id,
    required this.name,
    required this.price,
    this.selectionRequirement = 'optional',
    this.imagePath,
  });
}

class CatalogOption {
  /// Server id when editing; keeps the id stable so carts that picked it stay valid.
  final int? id;
  final String name;
  final num additionalPrice;
  final int availableStatus;
  final String? imagePath;

  CatalogOption({
    this.id,
    required this.name,
    required this.additionalPrice,
    this.availableStatus = 1,
    this.imagePath,
  });
}

/// A group of choices on a catalog item (e.g. "Choose your sauce").
class CatalogOptionGroup {
  /// Server id when editing; null for a new group.
  final int? id;
  final String name;
  final String selectionRequirement;
  final int? minSelections;
  final int? maxSelections;
  final List<CatalogOption> options;

  CatalogOptionGroup({
    this.id,
    required this.name,
    required this.options,
    this.selectionRequirement = 'optional',
    this.minSelections,
    this.maxSelections,
  });
}

class ItemController extends GetxController {
  final String? editRestaurantMenuItemId;
  ItemController({this.editRestaurantMenuItemId});
  final TextEditingController prepTimeCtrl = TextEditingController();
  final TextEditingController serialNumberCtrl = TextEditingController();
  final TextEditingController maxQuantityCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController discountPriceCtrl = TextEditingController();
  String? selectedType;
  final List<int> selectedRestaurantTagIds = [];
  String? selectedAttribute;
  int? selectedMenuId;
  int? selectedRestaurantAttributeId;
  int? selectedRestaurantTagId;
  RestaurantMenu? currentMenuData;

  // ── Image pick + crop ──────────────────────────────────────────────────────
  XFile? pickedImageFile;

  Future<void> pickAndCropImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (sc) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFFFF5216),
                  ),
                  title: const Text('Camera'),
                  onTap: () => Navigator.of(sc).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFFFF5216),
                  ),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.of(sc).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      );
      if (source == null) return;

      final picked = await picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFFFF5216),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFFFF5216),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image', minimumAspectRatio: 1.0),
        ],
      );
      if (cropped == null) return;

      showImageUploadLoadingDialog(context);
      try {
        final path = cropped.path;
        final baseName = path.split(RegExp(r'[/\\]')).last;
        final jpgFilename =
            baseName.endsWith('.jpg') ||
                baseName.endsWith('.jpeg') ||
                baseName.endsWith('.png')
            ? baseName
            : '${baseName.split('.').first}.jpg';

        debugPrint(
          "[ItemController] Enhancing image immediately after crop...",
        );
        final enhancedBytes = await DioClient().enhanceImageBytes(
          path,
          jpgFilename,
        );
        if (enhancedBytes != null) {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File(
            '${tempDir.path}/enhanced_${DateTime.now().millisecondsSinceEpoch}_$jpgFilename',
          );
          await tempFile.writeAsBytes(enhancedBytes);
          pickedImageFile = XFile(tempFile.path);
          debugPrint(
            "[ItemController] Image enhanced and saved to: ${tempFile.path}",
          );
        } else {
          pickedImageFile = XFile(cropped.path);
        }
      } catch (e) {
        debugPrint(
          "[ItemController] Immediate image enhancement failed: $e. Fallback to cropped path.",
        );
        pickedImageFile = XFile(cropped.path);
      } finally {
        if (context.mounted) {
          Get.back();
        }
      }
      update();
    } catch (e) {
      debugPrint('pickAndCropImage error: $e');
    }
  }
  // ──────────────────────────────────────────────────────────────────────────

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
      menuList.map((e) => e.nameEn).where((s) => s.isNotEmpty).toSet().toList();

  List<String> get tagDisplayNames => restaurantTags
      .map((e) => e.nameEn ?? '')
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();

  List<String> get attributeDisplayNames => restaurantAttributes
      .map((e) => e.nameEn ?? '')
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();

  bool isMenuListLoading = false;
  List<MenuItem> menuList = [];

  bool isRestaurantTagsLoading = false;
  List<TagData> restaurantTags = [];

  bool isRestaurantAttributesLoading = false;
  List<AttributeData> restaurantAttributes = [];

  bool isStockLogsLoading = false;
  RestaurantItemStockLogModel? menuItemStockLogModel;
  List<StockLogItem> menuItemStockLogs = [];

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
        await profileController.fetchGroceryMenuItems();
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
    // Legacy single-select API used by some screens; keep it working.
    final match = restaurantTags.where((t) => t.nameEn == value);
    selectedRestaurantTagId = match.isEmpty ? null : match.first.id;
    selectedRestaurantTagIds
      ..clear()
      ..addAll(
        selectedRestaurantTagId == null ? const [] : [selectedRestaurantTagId!],
      );
    update();
  }

  List<String> get selectedTagDisplayNames {
    if (selectedRestaurantTagIds.isEmpty) return const [];
    final set = selectedRestaurantTagIds.toSet();
    return restaurantTags
        .where((t) => t.id != null && set.contains(t.id!))
        .map((t) => t.nameEn ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  String? get selectedTagDisplayText {
    final names = selectedTagDisplayNames;
    if (names.isEmpty) return null;
    return names.join(', ');
  }

  void toggleTagById(int id) {
    if (id <= 0) return;
    if (selectedRestaurantTagIds.contains(id)) {
      selectedRestaurantTagIds.remove(id);
    } else {
      selectedRestaurantTagIds.add(id);
    }
    selectedRestaurantTagId = selectedRestaurantTagIds.isNotEmpty
        ? selectedRestaurantTagIds.first
        : null;
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
    selectedRestaurantTagIds.clear();
    selectedAttribute = null;
    selectedRestaurantAttributeId = null;
    selectedRestaurantTagId = null;
    pickedImageFile = null;
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
    String? itemName,
    bool isRestaurantCatalog = false,
    List<CatalogVariant> variants = const [],
    List<CatalogOptionGroup> optionGroups = const [],
  }) {
    if (isRestaurantCatalog) {
      for (final group in optionGroups) {
        final min = group.minSelections;
        final max = group.maxSelections;
        if (min != null && max != null && min > max) {
          showToast(
            context,
            "Minimum selections can't be more than maximum in ${group.name}",
          );
          return false;
        }
        if (max != null && max > group.options.length) {
          showToast(
            context,
            "${group.name} allows $max selections but has ${group.options.length} options",
          );
          return false;
        }
      }
      final name = (itemName != null && itemName.trim().isNotEmpty)
          ? itemName.trim()
          : (menuItemId != null && menuItemId.trim().isNotEmpty
              ? menuItemId.trim()
              : serialNumberCtrl.text.trim());
      if (name.isEmpty) {
        showToast(context, "Please enter item name");
        return false;
      }
      final catId = (menuId != null && menuId.trim().isNotEmpty)
          ? menuId.trim()
          : (selectedMenuId != null ? selectedMenuId.toString() : '');
      if (catId.isEmpty) {
        showToast(context, "Please select category");
        return false;
      }
      // With variants each variant carries its own price instead.
      if (variants.isEmpty && priceCtrl.text.trim().isEmpty) {
        showToast(context, "Please enter price");
        return false;
      }
      return true;
    }

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
    } else if (Get.find<ProfileController>().vendorType != '2' &&
        prepTimeCtrl.text.trim().isEmpty) {
      showToast(context, "Please enter preparation time");
      return false;
    } else if (serialNumberCtrl.text.trim().isEmpty) {
      showToast(context, "Please enter serial number");
      return false;
    } else if (selectedRestaurantTagIds.isEmpty) {
      showToast(context, "Please select at least one tag");
      return false;
    }
    return true;
  }

  Future<void> addItem(
    BuildContext context, {
    required String menuId,
    required String menuItemId,
    required String restaurantAttributeId,
    String? itemName,
    String? description,
    String? isVeg,
    String? extraSelectionRequirement,
    String? extraMaxSelections,
    List<CatalogExtraItem>? catalogExtras,
    String? variantGroupName,
    List<CatalogVariant> variants = const [],
    List<CatalogOptionGroup> optionGroups = const [],
  }) async {
    final vendorType = (await getSavedObject("vendorType"))?.toString() ?? '';
    final isRestaurant = vendorType == "1";

    final isValid = addItemValidation(
      context,
      menuId: menuId,
      menuItemId: menuItemId,
      restaurantAttributeId: restaurantAttributeId,
      itemName: itemName,
      isRestaurantCatalog: isRestaurant,
      variants: variants,
      optionGroups: optionGroups,
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

      dio.FormData formData;

      if (isRestaurant) {
        // Restaurant catalog item flow: POST addRestaurantCatalogItem
        final catId = int.tryParse(menuId.trim()) ?? selectedMenuId;
        final categoryIdsStr = catId != null
            ? jsonEncode([catId])
            : (menuId.trim().isNotEmpty ? "[$menuId]" : "[]");

        final finalName = (itemName != null && itemName.trim().isNotEmpty)
            ? itemName.trim()
            : (menuItemId.trim().isNotEmpty
                ? menuItemId.trim()
                : serialNumberCtrl.text.trim());

        final hasVariants = variants.isNotEmpty;
        final formDataMap = <String, dynamic>{
          "name_en": finalName,
          "category_ids": categoryIdsStr,
          "has_variants": hasVariants ? '1' : '0',
          if (!hasVariants) "price": priceCtrl.text.trim(),
          if (!hasVariants && discountPriceCtrl.text.trim().isNotEmpty)
            "discount_price": discountPriceCtrl.text.trim(),
          if (description != null && description.trim().isNotEmpty)
            "description_en": description.trim(),
          if (isVeg != null)
            "is_veg": isVeg == 'Yes' ? '1' : '0',
          if (prepTimeCtrl.text.trim().isNotEmpty)
            "preparation_time": formatPreparationTimeToHi(prepTimeCtrl.text),
          // The catalog API reads serial_no; serial_number was ignored.
          if (serialNumberCtrl.text.trim().isNotEmpty)
            "serial_no": serialNumberCtrl.text.trim(),
          if (hasVariants && (variantGroupName ?? '').trim().isNotEmpty)
            "variant_group_name": variantGroupName!.trim(),
          if (hasVariants)
            "variants": jsonEncode([
              for (final v in variants)
                {
                  "name": v.name,
                  "price": v.price,
                  "selection_requirement": v.selectionRequirement,
                },
            ]),
          if (optionGroups.isNotEmpty)
            "option_groups": jsonEncode([
              for (final g in optionGroups)
                {
                  "name": g.name,
                  "selection_requirement": g.selectionRequirement,
                  "min_selections": ?g.minSelections,
                  "max_selections": ?g.maxSelections,
                  "options": [
                    for (final o in g.options)
                      {
                        "name": o.name,
                        "additional_price": o.additionalPrice,
                        "available_status": 1,
                      },
                  ],
                },
            ]),
        };

        formData = dio.FormData.fromMap(formDataMap);

        Future<dio.MultipartFile> upload(String path) =>
            dio.MultipartFile.fromFile(
              path,
              filename: path.split(RegExp(r'[/\\]')).last,
            );
        for (int i = 0; i < variants.length; i++) {
          final path = variants[i].imagePath?.trim() ?? '';
          if (hasVariants && path.isNotEmpty) {
            formData.files.add(MapEntry("variant_images[$i]", await upload(path)));
          }
        }
        for (int g = 0; g < optionGroups.length; g++) {
          final options = optionGroups[g].options;
          for (int o = 0; o < options.length; o++) {
            final path = options[o].imagePath?.trim() ?? '';
            if (path.isNotEmpty) {
              formData.files.add(
                MapEntry("option_images[$g][$o]", await upload(path)),
              );
            }
          }
        }

        // Tags
        final tagIds = selectedRestaurantTagIds.isNotEmpty
            ? selectedRestaurantTagIds
            : (selectedRestaurantTagId != null
                ? [selectedRestaurantTagId!]
                : const <int>[]);
        for (int i = 0; i < tagIds.length; i++) {
          formData.fields.add(MapEntry("tags[$i]", tagIds[i].toString()));
        }

        // Extras (handling both "optional" and "required" conditions)
        final validExtras = (catalogExtras ?? [])
            .where((e) => e.name.trim().isNotEmpty)
            .toList();

        if (validExtras.isNotEmpty) {
          final reqLower =
              (extraSelectionRequirement?.trim().toLowerCase() == 'required')
                  ? 'required'
                  : 'optional';
          final parsedMax = int.tryParse(extraMaxSelections?.trim() ?? '');
          final maxSel = parsedMax ??
              (reqLower == 'required' ? 1 : validExtras.length);

          final extrasMap = <String, dynamic>{
            "selection_requirement": reqLower,
            "max_selections": maxSel,
            "items": validExtras
                .map((e) => {
                      "name": e.name.trim(),
                      "additional_price": e.additionalPrice,
                      "available_status": e.availableStatus,
                    })
                .toList(),
          };

          formData.fields.add(MapEntry("extras", jsonEncode(extrasMap)));

          for (int i = 0; i < validExtras.length; i++) {
            final extraItem = validExtras[i];
            if (extraItem.imagePath != null &&
                extraItem.imagePath!.trim().isNotEmpty) {
              final path = extraItem.imagePath!.trim();
              final baseName = path.split(RegExp(r'[/\\]')).last;
              formData.files.add(
                MapEntry(
                  "extra_images[$i]",
                  await dio.MultipartFile.fromFile(path, filename: baseName),
                ),
              );
            }
          }
        }

        // Main item image. The catalog API reads an `images` list; a single
        // `image` field was ignored, so items saved without a photo.
        if (pickedImageFile != null) {
          final path = pickedImageFile!.path;
          final baseName = path.split(RegExp(r'[/\\]')).last;
          formData.files.add(
            MapEntry(
              'images[]',
              await dio.MultipartFile.fromFile(path, filename: baseName),
            ),
          );
        }
      } else {
        // Grocery menu item flow (existing unchanged behavior)
        String finalAttrId = restaurantAttributeId;
        if (finalAttrId.isEmpty &&
            selectedAttribute != null &&
            restaurantAttributes.isNotEmpty) {
          final match = restaurantAttributes.where(
            (a) => a.nameEn == selectedAttribute,
          );
          if (match.isNotEmpty) {
            finalAttrId = match.first.id?.toString() ?? '';
          }
        }

        final formDataMap = <String, dynamic>{
          "menu_id": menuId,
          "menu_item_id": menuItemId,
          "grocery_attribute_id": finalAttrId,
          "attribute_value": selectedAttribute ?? "",
          "price": priceCtrl.text.trim(),
          "discount_price": discountPriceCtrl.text.trim(),
          "preparation_time": formatPreparationTimeToHi(prepTimeCtrl.text),
          "serial_number": serialNumberCtrl.text.trim(),
          "quantity_allowed": maxQuantityCtrl.text.trim(),
        };

        formData = dio.FormData.fromMap(formDataMap);

        final tagIds = selectedRestaurantTagIds.isNotEmpty
            ? selectedRestaurantTagIds
            : (selectedRestaurantTagId != null
                ? [selectedRestaurantTagId!]
                : const <int>[]);
        for (int i = 0; i < tagIds.length; i++) {
          formData.fields.add(MapEntry("tags[$i]", tagIds[i].toString()));
        }
        if (pickedImageFile != null) {
          final path = pickedImageFile!.path;
          final baseName = path.split(RegExp(r'[/\\]')).last;
          formData.files.add(
            MapEntry(
              'image',
              await dio.MultipartFile.fromFile(path, filename: baseName),
            ),
          );
        }
      }

      printFormData(formData);

      dynamic response;
      if (isRestaurant) {
        try {
          response = await DioClient().post(
            ApiEndPoints.addRestaurantCatalogItem,
            body: formData,
          );
        } on dio.DioException catch (dioErr) {
          if (dioErr.response?.statusCode == 404) {
            debugPrint(
              "404 on ${ApiEndPoints.addRestaurantCatalogItem}, trying vendor/${ApiEndPoints.addRestaurantCatalogItem}",
            );
            response = await DioClient().post(
              "vendor/${ApiEndPoints.addRestaurantCatalogItem}",
              body: formData,
            );
          } else {
            rethrow;
          }
        }
      } else {
        response = await DioClient().post(
          ApiEndPoints.addGroceryMenuItem,
          body: formData,
        );
      }

      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (context.mounted) {
          String successMessage = "Item added successfully";
          if (response.data['message'] != null) {
            var msgMap = response.data['message'];
            if (msgMap is Map &&
                msgMap.containsKey('message_en') &&
                msgMap['message_en'] is List &&
                msgMap['message_en'].isNotEmpty) {
              successMessage = msgMap['message_en'][0];
            } else if (response.data['message'] is String) {
              successMessage = response.data['message'];
            }
          }
          showToast(context, successMessage);
          if (Get.isRegistered<ProfileController>()) {
            final profileController = Get.find<ProfileController>();
            await profileController.fetchGroceryMenuItems();
          }
          if (context.mounted) {
            Get.back();
          }
        }
      } else {
        if (context.mounted) {
          showToast(
            context,
            response.data['message']?.toString() ?? "Failed to add item",
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
      if (vendorType == "1") {
        // Restaurant catalog items take restaurant_categories ids in
        // category_ids; getRestaurantMenus now lists the items themselves.
        final response =
            await DioClient().get(ApiEndPoints.getRestaurantCategories);
        final body = response.data;
        if (body is Map && body['status'].toString() == 'true' && body['data'] is List) {
          menuList = (body['data'] as List)
              .whereType<Map>()
              .map((c) => MenuItem(
                    id: int.tryParse(c['id'].toString()) ?? 0,
                    nameEn: c['name_en']?.toString() ?? '',
                    nameAr: c['name_ar']?.toString() ?? '',
                    nameFr: c['name_fr']?.toString() ?? '',
                    categoryId: [c['id'].toString()],
                    image: c['image']?.toString() ?? '',
                  ))
              .toList();
        }
      } else {
        final response = await DioClient().get(ApiEndPoints.getGroceryMenus);
        final model = MenuListingModel.fromJson(
          response.data is Map<String, dynamic>
              ? response.data
              : Map<String, dynamic>.from(response.data as Map),
        );
        if (model.status) {
          menuList = model.data;
        }
      }
      // The item may have loaded first: show the name of its category.
      if ((selectedType == null || selectedType!.isEmpty) &&
          selectedMenuId != null) {
        final match = menuList.where((m) => m.id == selectedMenuId).toList();
        if (match.isNotEmpty) {
          selectedType = match.first.nameEn;
        }
      }
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
          await profileController.fetchGroceryMenuItems();
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
      currentMenuData = details.restaurantMenu;
      serialNumberCtrl.text =
          details.serialNumber?.toString() ?? serialNumberCtrl.text;
      prepTimeCtrl.text =
          details.preparationTime?.toString() ?? prepTimeCtrl.text;
      maxQuantityCtrl.text =
          details.quantityAllowed?.toString() ?? maxQuantityCtrl.text;
      priceCtrl.text = details.price?.toString() ?? priceCtrl.text;
      discountPriceCtrl.text =
          details.discountPrice?.toString() ?? discountPriceCtrl.text;
      if (details.menuId != null) {
        selectedMenuId = details.menuId;
      }

      debugPrint("details.availabilityStatus: ${details.availableStatus}");
      final menuName = details.restaurantMenu?.nameEn;
      if (menuName != null && menuName.isNotEmpty) {
        selectedType = menuName;
        if (menuList.isNotEmpty) {
          setSelectedType(menuName);
        }
      }
      if (details.restaurantAttributeId != null) {
        selectedRestaurantAttributeId = details.restaurantAttributeId;
      } else if (details.attribute?.id != null) {
        selectedRestaurantAttributeId = details.attribute?.id;
      }
      final attrName = details.attribute?.nameEn;
      if (attrName != null && attrName.isNotEmpty) {
        selectedAttribute = attrName;
      }
      final tags = model.data?.menuItemTags ?? [];
      if (tags.isNotEmpty) {
        final ids = tags
            .map((t) => t.restaurantTagId)
            .whereType<int>()
            .where((id) => id > 0)
            .toSet()
            .toList();
        selectedRestaurantTagIds
          ..clear()
          ..addAll(ids);
        selectedRestaurantTagId = selectedRestaurantTagIds.isNotEmpty
            ? selectedRestaurantTagIds.first
            : null;
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

  // ── Restaurant catalog edit (V1) ──────────────────────────────────────────
  // Restaurant items are catalog items: the edit screen loads them from
  // restaurantCatalogItemDetail (variants, option groups and extras with ids)
  // and saves with updateRestaurantCatalogItem, the same body as add + item_id.

  /// True when the item being edited is a restaurant catalog item.
  bool isCatalogEdit = false;

  /// Raw `data` of restaurantCatalogItemDetail for the item being edited.
  Map<String, dynamic>? catalogItemDetail;

  /// Gallery images already on the item: [{id, image_url}].
  List<Map<String, dynamic>> catalogImages = [];

  /// Gallery image ids the vendor removed in this edit.
  final List<int> removedCatalogImageIds = [];

  /// Loads the item for the edit screen: catalog detail for restaurants,
  /// the legacy menu-item detail for grocery.
  Future<void> loadItemForEdit(String itemId) async {
    final vendorType = (await getSavedObject("vendorType"))?.toString() ?? '';
    isCatalogEdit = vendorType == "1";
    if (isCatalogEdit) {
      await getRestaurantCatalogItemForEdit(itemId);
    } else {
      await getRestaurantMenuItemDetails(itemId);
    }
  }

  Future<void> getRestaurantCatalogItemForEdit(String itemId) async {
    try {
      isRestaurantAttributesLoading = true;
      update();
      final token = await getSavedObject("token");
      DioClient().updateToken(token ?? "");

      final response = await DioClient().get(
        ApiEndPoints.restaurantCatalogItemDetailAlt,
        query: {"item_id": itemId},
      );
      final raw = response.data;
      if (raw is! Map || raw['data'] is! Map) return;
      final data = Map<String, dynamic>.from(raw['data'] as Map);
      catalogItemDetail = data;

      String text(dynamic v) => v == null ? '' : v.toString();

      priceCtrl.text = text(data['price']);
      discountPriceCtrl.text = text(data['discount_price']);
      prepTimeCtrl.text = text(data['preparation_time']);
      serialNumberCtrl.text = text(data['serial_no']);

      final categoryIds = (data['category_ids'] as List? ?? const [])
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
      if (categoryIds.isNotEmpty) {
        selectedMenuId = categoryIds.first;
        final menuMatch = menuList
            .where((m) => m.categoryId.contains(categoryIds.first.toString()))
            .toList();
        if (menuMatch.isNotEmpty) {
          selectedType = menuMatch.first.nameEn;
        }
      }

      final tagIds = (data['tags'] as List? ?? const [])
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
      selectedRestaurantTagIds
        ..clear()
        ..addAll(tagIds);
      selectedRestaurantTagId = tagIds.isNotEmpty ? tagIds.first : null;

      catalogImages = (data['images'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      removedCatalogImageIds.clear();
    } catch (error, stackTrace) {
      debugPrint("getRestaurantCatalogItemForEdit Error: $error");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isRestaurantAttributesLoading = false;
      update();
    }
  }

  /// Main image to show on the edit screen: first gallery image still kept.
  String? get catalogImageUrl {
    for (final image in catalogImages) {
      final id = int.tryParse(image['id'].toString());
      if (id != null && removedCatalogImageIds.contains(id)) continue;
      final url = image['image_url']?.toString();
      if (url != null && url.isNotEmpty) return url;
    }
    final fallback = catalogItemDetail?['image_url']?.toString();
    return (fallback != null && fallback.isNotEmpty) ? fallback : null;
  }

  /// Saves a restaurant catalog item. Items sent with an `id` are updated in
  /// place; options and extras left out are hidden by the server, not deleted.
  Future<void> updateCatalogItem(
    BuildContext context, {
    required String itemId,
    required String menuId,
    String? itemName,
    String? description,
    String? isVeg,
    String? extraSelectionRequirement,
    String? extraMaxSelections,
    List<CatalogExtraItem>? catalogExtras,
    String? variantGroupName,
    List<CatalogVariant> variants = const [],
    List<CatalogOptionGroup> optionGroups = const [],
  }) async {
    final isValid = addItemValidation(
      context,
      menuId: menuId,
      menuItemId: itemId,
      restaurantAttributeId: '',
      itemName: itemName,
      isRestaurantCatalog: true,
      variants: variants,
      optionGroups: optionGroups,
    );
    if (!isValid) return;

    try {
      showLoadingDialog(context);
      final token = await getSavedObject("token");
      DioClient().updateToken(token ?? "");

      final catId = int.tryParse(menuId.trim()) ?? selectedMenuId;
      final hasVariants = variants.isNotEmpty;

      // The screen shows one photo. A newly picked photo replaces the one shown
      // (the first gallery image); other gallery images set on the web panel stay.
      final removeImageIds = [...removedCatalogImageIds];
      if (pickedImageFile != null) {
        for (final image in catalogImages) {
          final id = int.tryParse(image['id'].toString());
          if (id != null && !removeImageIds.contains(id)) {
            removeImageIds.add(id);
            break;
          }
        }
      }

      final name = (itemName ?? '').trim().isNotEmpty
          ? itemName!.trim()
          : (catalogItemDetail?['name_en']?.toString() ?? '');

      final formDataMap = <String, dynamic>{
        "item_id": itemId,
        "name_en": name,
        "category_ids": jsonEncode(catId != null ? [catId] : []),
        "has_variants": hasVariants ? '1' : '0',
        if (!hasVariants) "price": priceCtrl.text.trim(),
        if (!hasVariants) "discount_price": discountPriceCtrl.text.trim(),
        "description_en": (description ?? '').trim(),
        if (isVeg != null) "is_veg": isVeg == 'Yes' ? '1' : '0',
        if (prepTimeCtrl.text.trim().isNotEmpty)
          "preparation_time": formatPreparationTimeToHi(prepTimeCtrl.text),
        if (serialNumberCtrl.text.trim().isNotEmpty)
          "serial_no": serialNumberCtrl.text.trim(),
        if (hasVariants && (variantGroupName ?? '').trim().isNotEmpty)
          "variant_group_name": variantGroupName!.trim(),
        "variants": jsonEncode([
          for (final v in variants)
            {
              "id": ?v.id,
              "name": v.name,
              "price": v.price,
              "selection_requirement": v.selectionRequirement,
            },
        ]),
        // Always sent on edit: an empty list removes all option groups.
        "option_groups": jsonEncode([
          for (final g in optionGroups)
            {
              "id": ?g.id,
              "name": g.name,
              "selection_requirement": g.selectionRequirement,
              "min_selections": ?g.minSelections,
              "max_selections": ?g.maxSelections,
              "options": [
                for (final o in g.options)
                  {
                    "id": ?o.id,
                    "name": o.name,
                    "additional_price": o.additionalPrice,
                    "available_status": o.availableStatus,
                  },
              ],
            },
        ]),
        "remove_image_ids": jsonEncode(removeImageIds),
      };

      final formData = dio.FormData.fromMap(formDataMap);

      Future<dio.MultipartFile> upload(String path) => dio.MultipartFile.fromFile(
            path,
            filename: path.split(RegExp(r'[/\\]')).last,
          );
      for (int i = 0; i < variants.length; i++) {
        final path = variants[i].imagePath?.trim() ?? '';
        if (hasVariants && path.isNotEmpty) {
          formData.files.add(MapEntry("variant_images[$i]", await upload(path)));
        }
      }
      for (int g = 0; g < optionGroups.length; g++) {
        final options = optionGroups[g].options;
        for (int o = 0; o < options.length; o++) {
          final path = options[o].imagePath?.trim() ?? '';
          if (path.isNotEmpty) {
            formData.files.add(MapEntry("option_images[$g][$o]", await upload(path)));
          }
        }
      }

      final tagIds = selectedRestaurantTagIds.isNotEmpty
          ? selectedRestaurantTagIds
          : (selectedRestaurantTagId != null
              ? [selectedRestaurantTagId!]
              : const <int>[]);
      for (int i = 0; i < tagIds.length; i++) {
        formData.fields.add(MapEntry("tags[$i]", tagIds[i].toString()));
      }

      // Extras: always sent on edit so removed extras are hidden on the server.
      final validExtras =
          (catalogExtras ?? []).where((e) => e.name.trim().isNotEmpty).toList();
      final reqLower =
          (extraSelectionRequirement?.trim().toLowerCase() == 'required')
              ? 'required'
              : 'optional';
      final parsedMax = int.tryParse(extraMaxSelections?.trim() ?? '');
      formData.fields.add(MapEntry(
        "extras",
        jsonEncode({
          "selection_requirement": reqLower,
          "max_selections": ?parsedMax,
          "items": [
            for (final e in validExtras)
              {
                "id": ?e.id,
                "name": e.name.trim(),
                "additional_price": e.additionalPrice,
                "available_status": e.availableStatus,
              },
          ],
        }),
      ));
      for (int i = 0; i < validExtras.length; i++) {
        final path = validExtras[i].imagePath?.trim() ?? '';
        if (path.isNotEmpty) {
          formData.files.add(MapEntry("extra_images[$i]", await upload(path)));
        }
      }

      // A newly picked main image is added to the gallery (images[]).
      if (pickedImageFile != null) {
        formData.files.add(MapEntry('images[]', await upload(pickedImageFile!.path)));
      }

      printFormData(formData);
      final response = await DioClient().post(
        ApiEndPoints.updateRestaurantCatalogItem,
        body: formData,
      );

      if (context.mounted) Get.back();
      final ok = response.data['status'] == 'true' || response.data['status'] == true;
      if (!context.mounted) return;
      if (ok) {
        showToast(context, _serverMessage(response.data, S.current.itemUpdatedSuccessfully));
        if (Get.isRegistered<ProfileController>()) {
          await Get.find<ProfileController>().fetchGroceryMenuItems();
        }
        if (context.mounted) Get.back();
      } else {
        showToast(context, _serverMessage(response.data, S.current.failedToUpdateItem));
      }
    } on dio.DioException catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, _serverMessage(error.response?.data, S.current.failedToUpdateItem));
      }
      debugPrint("updateCatalogItem Error: $error");
    } catch (error) {
      if (context.mounted) {
        Get.back();
        showToast(context, error.toString());
      }
      debugPrint("updateCatalogItem Error: $error");
    }
  }

  /// First readable message from the API envelope ({message: {message_en: [...]}} or
  /// validation errors {field_en: [...]}), else the fallback.
  String _serverMessage(dynamic body, String fallback) {
    if (body is! Map) return fallback;
    final message = body['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is Map) {
      final lang = Get.locale?.languageCode ?? 'en';
      for (final key in ['message_$lang', 'message_en']) {
        final v = message[key];
        if (v is List && v.isNotEmpty) return v.first.toString();
        if (v is String && v.isNotEmpty) return v;
      }
      for (final v in message.values) {
        if (v is List && v.isNotEmpty) return v.first.toString();
        if (v is String && v.isNotEmpty) return v;
      }
    }
    return fallback;
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
      String finalAttrId = restaurantAttributeId;
      if (finalAttrId.isEmpty &&
          selectedAttribute != null &&
          restaurantAttributes.isNotEmpty) {
        final match = restaurantAttributes.where(
          (a) => a.nameEn == selectedAttribute,
        );
        if (match.isNotEmpty) {
          finalAttrId = match.first.id?.toString() ?? '';
        }
      }

      final formDataMap = <String, dynamic>{
        "menu_id": menuId,
        "menu_item_id": menuItemId,
        vendorType == "1" ? "restaurant_attribute_id" : "grocery_attribute_id":
            finalAttrId,
        "attribute_value": selectedAttribute ?? "",
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
      final tagIds = selectedRestaurantTagIds.isNotEmpty
          ? selectedRestaurantTagIds
          : (selectedRestaurantTagId != null
                ? [selectedRestaurantTagId!]
                : const <int>[]);
      for (int i = 0; i < tagIds.length; i++) {
        formData.fields.add(MapEntry("tags[$i]", tagIds[i].toString()));
      }
      if (pickedImageFile != null) {
        final path = pickedImageFile!.path;
        final baseName = path.split(RegExp(r'[/\\]')).last;
        formData.files.add(
          MapEntry(
            'image',
            await dio.MultipartFile.fromFile(path, filename: baseName),
          ),
        );
      }
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

          if (currentMenuData != null) {
            try {
              final isRestaurant = vendorType == "1";
              final formDataMap = <String, dynamic>{
                isRestaurant ? "restaurant_menu_id" : "grocery_menu_id":
                    currentMenuData!.id ?? 0,
                "name_en": currentMenuData!.nameEn,
                "name_ar": currentMenuData!.nameAr,
                "name_fr": currentMenuData!.nameFr,
                "description_en": currentMenuData!.descriptionEn,
                "description_ar": currentMenuData!.descriptionAr,
                "description_fr": currentMenuData!.descriptionFr,
                "is_veg": currentMenuData!.isVeg.toString(),
                "quantity_allowed":
                    currentMenuData!.quantityAllowed?.toString() ?? "10",
                "preparation_time": prepTimeCtrl.text.trim(),
              };

              final formData = dio.FormData.fromMap(formDataMap);
              final cats = currentMenuData!.categories;
              for (int i = 0; i < cats.length; i++) {
                formData.fields.add(
                  MapEntry("categories[$i]", cats[i].id.toString()),
                );
              }

              debugPrint(
                "[ItemController] Syncing with Menu: id=${currentMenuData!.id} prepTime=${prepTimeCtrl.text.trim()}",
              );
              await DioClient().post(
                isRestaurant
                    ? ApiEndPoints.updateRestaurantMenuEdit
                    : ApiEndPoints.updateGroceryMenuEdit,
                body: formData,
              );
            } catch (e) {
              debugPrint("[ItemController] Menu sync failed: $e");
            }
          }

          final profileController = Get.find<ProfileController>();
          await profileController.fetchGroceryMenuItems();
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
        debugPrint("updateItemAfterEdit Error: $error");
      }
    }
  }

  Future<bool> updateItemStatus(
    int itemId,
    int status, {
    bool showSuccessToast = false,
  }) async {
    try {
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final isRestaurant = vendorType == "1";
      final endpoint = isRestaurant
          ? ApiEndPoints.updateRestaurantCatalogItemStatus
          : ApiEndPoints.updateGroceryItemStatus;
      final queryParams = isRestaurant
          ? {"item_id": itemId, "available_status": status}
          : {"menu_item_id": itemId, "available_status": status};

      dynamic response;
      try {
        response = await DioClient().get(endpoint, query: queryParams);
      } on dio.DioException catch (dioErr) {
        if (isRestaurant && dioErr.response?.statusCode == 404) {
          debugPrint(
            'updateRestaurantCatalogItemStatus 404, retrying with ${ApiEndPoints.updateRestaurantCatalogItemStatusAlt}',
          );
          try {
            response = await DioClient().get(
              ApiEndPoints.updateRestaurantCatalogItemStatusAlt,
              query: queryParams,
            );
          } on dio.DioException catch (altErr) {
            if (altErr.response?.statusCode == 404) {
              debugPrint(
                'updateRestaurantCatalogItemStatus alt 404, trying legacy updateItemStatus',
              );
              response = await DioClient().get(
                ApiEndPoints.updateItemStatus,
                query: {"menu_item_id": itemId, "available_status": status},
              );
            } else {
              rethrow;
            }
          }
        } else if (dioErr.response?.statusCode == 405) {
          response = await DioClient().post(endpoint, body: queryParams);
        } else {
          rethrow;
        }
      }
      debugPrint("updateItemStatus response: $response");

      final raw = response?.data;
      final rawMap = raw is Map<String, dynamic>
          ? raw
          : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});

      final isSuccess =
          rawMap['status'] == true ||
          rawMap['status']?.toString().toLowerCase() == 'true' ||
          rawMap['status']?.toString() == '1';

      String? toastFromMessage;
      final msgVal = rawMap['message'];
      if (msgVal is String && msgVal.trim().isNotEmpty) {
        toastFromMessage = msgVal.trim();
      } else if (msgVal is Map) {
        try {
          final successModel = SuccessModel.fromJson(rawMap);
          String? firstNonEmptyString(List<String>? values) {
            if (values == null) return null;
            final nonEmpty = values
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList();
            return nonEmpty.isNotEmpty ? nonEmpty.first : null;
          }

          toastFromMessage =
              firstNonEmptyString(successModel.message?.messageEn) ??
              firstNonEmptyString(successModel.message?.messageFr) ??
              firstNonEmptyString(successModel.message?.messageAr);
        } catch (_) {}
      }

      final resolvedToastMessage =
          toastFromMessage != null && toastFromMessage.isNotEmpty
          ? toastFromMessage
          : (isSuccess
                ? 'Item status updated successfully'
                : 'Failed to update item status');

      debugPrint('updateItemStatus toast: $resolvedToastMessage');

      if (!isSuccess || showSuccessToast) {
        final ctx = Get.overlayContext ?? Get.context;
        if (ctx != null) {
          try {
            showToast(ctx, resolvedToastMessage);
          } catch (e) {
            debugPrint(
              'showToast failed (overlay missing). Falling back. err=$e',
            );
            Fluttertoast.showToast(
              msg: resolvedToastMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 14.0,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: resolvedToastMessage,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
      }
      return isSuccess;
    } catch (error) {
      debugPrint("updateItemStatus Error: $error");
      return false;
    } finally {
      update();
    }
  }

  Future<void> getMenuItemStockLogs(
    String menuItemId,
    int page,
    int limit,
  ) async {
    try {
      isStockLogsLoading = true;
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
            ? ApiEndPoints.restaurantMenuItemStockLogs
            : ApiEndPoints.groceryMenuItemStockLogs,
        query: {"menu_item_id": menuItemId, "page": page, "limit": limit},
      );
      debugPrint("getMenuItemStockLogs response: $response");
      final model = RestaurantItemStockLogModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );
      menuItemStockLogModel = model;
      menuItemStockLogs = model.data?.stockLogs?.data ?? [];
    } catch (error, stackTrace) {
      debugPrint("getMenuItemStockLogs Error: $error");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isStockLogsLoading = false;
      update();
    }
  }

  Future<void> updateMenuItemStock(
    BuildContext context,
    String menuItemId,
    int quantity,
    String movementType,
  ) async {
    try {
      isStockLogsLoading = true;
      update();
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().post(
        vendorType == "1"
            ? ApiEndPoints.updateRestaurantMenuItemStock
            : ApiEndPoints.updateGrocerytItemStock,
        body: {
          "menu_item_id": menuItemId,
          "quantity": quantity,
          "movement_type": movementType,
        },
      );
      debugPrint("updateMenuItemStock response: $response");
      final successModel = SuccessModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      String? firstNonEmptyString(List<String>? values) {
        if (values == null) return null;
        final nonEmpty = values
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        return nonEmpty.isNotEmpty ? nonEmpty.first : null;
      }

      final toastMessage =
          firstNonEmptyString(successModel.message?.messageEn) ??
          firstNonEmptyString(successModel.message?.messageFr) ??
          firstNonEmptyString(successModel.message?.messageAr) ??
          (successModel.status == 'true'
              ? 'Stock updated successfully'
              : 'Failed to update stock');

      final ctx = Get.overlayContext ?? Get.context;
      if (ctx != null) {
        try {
          showToast(ctx, toastMessage);
        } catch (_) {
          Fluttertoast.showToast(
            msg: toastMessage,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: toastMessage,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (error, stackTrace) {
      debugPrint("getMenuItemStockLogs Error: $error");
      debugPrintStack(stackTrace: stackTrace);
      showToast(context, error.toString());
    } finally {
      isStockLogsLoading = false;
      update();
    }
  }
}
