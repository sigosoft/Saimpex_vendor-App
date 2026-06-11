import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
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

      pickedImageFile = XFile(cropped.path);
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
        final jpgFilename =
            baseName.endsWith('.jpg') ||
                baseName.endsWith('.jpeg') ||
                baseName.endsWith('.png')
            ? baseName
            : '${baseName.split('.').first}.jpg';

        dio.MultipartFile? uploadFile;
        try {
          debugPrint(
            "[ItemController] Enhancing image using imageEnhance endpoint...",
          );
          final enhancedBytes = await DioClient().enhanceImageBytes(
            path,
            jpgFilename,
          );
          if (enhancedBytes != null) {
            uploadFile = dio.MultipartFile.fromBytes(
              enhancedBytes,
              filename: 'enhanced_$jpgFilename',
            );
            debugPrint("[ItemController] Image enhanced successfully!");
          }
        } catch (e) {
          debugPrint("[ItemController] Image enhancement failed: $e.");
          rethrow;
        }

        formData.files.add(MapEntry('image', uploadFile!));
      }
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
        final jpgFilename =
            baseName.endsWith('.jpg') ||
                baseName.endsWith('.jpeg') ||
                baseName.endsWith('.png')
            ? baseName
            : '${baseName.split('.').first}.jpg';

        dio.MultipartFile? uploadFile;
        try {
          debugPrint(
            "[ItemController] Enhancing image using imageEnhance endpoint...",
          );
          final enhancedBytes = await DioClient().enhanceImageBytes(
            path,
            jpgFilename,
          );
          if (enhancedBytes != null) {
            uploadFile = dio.MultipartFile.fromBytes(
              enhancedBytes,
              filename: 'enhanced_$jpgFilename',
            );
            debugPrint("[ItemController] Image enhanced successfully!");
          }
        } catch (e) {
          debugPrint("[ItemController] Image enhancement failed: $e.");
          rethrow;
        }

        formData.files.add(MapEntry('image', uploadFile!));
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

  Future<void> updateItemStatus(int itemId, int status) async {
    try {
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(
        vendorType == "1"
            ? ApiEndPoints.updateItemStatus
            : ApiEndPoints.updateGroceryItemStatus,
        query: {"menu_item_id": itemId, "available_status": status},
      );
      debugPrint("updateItemStatus response: $response");
      final successModel = SuccessModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      String? firstNonEmptyString(List<String>? values) {
        if (values == null) return null;
        final nonEmpty = values
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
        return nonEmpty.isNotEmpty ? nonEmpty.first : null;
      }

      final toastFromMessage =
          firstNonEmptyString(successModel.message?.messageEn) ??
          firstNonEmptyString(successModel.message?.messageFr) ??
          firstNonEmptyString(successModel.message?.messageAr) ??
          '';

      final resolvedToastMessage = toastFromMessage.isNotEmpty
          ? toastFromMessage
          : (successModel.status == 'true'
                ? 'Item status updated successfully'
                : 'Failed to update item status');

      debugPrint('updateItemStatus toast: $resolvedToastMessage');

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
    } catch (error) {
      debugPrint("updateItemStatus Error: $error");
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
