import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/model/attributes_model.dart';
import 'package:saimpex_vendor/model/grocery_all_categories_model.dart';
import 'package:saimpex_vendor/model/grocery_menu_details_model.dart';
import 'package:saimpex_vendor/model/grocery_tag_model.dart';
import 'package:saimpex_vendor/model/restaurant_category_model.dart';
import 'package:saimpex_vendor/model/restaurant_menu_details_model.dart';
import 'package:saimpex_vendor/model/tag_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class MenuController extends GetxController {
  final TextEditingController nameEnCtrl = TextEditingController();
  final TextEditingController nameArCtrl = TextEditingController();
  final TextEditingController nameFrCtrl = TextEditingController();
  final TextEditingController descEnCtrl = TextEditingController();
  final TextEditingController descArCtrl = TextEditingController();
  final TextEditingController descFrCtrl = TextEditingController();
  final TextEditingController prepTimeCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController discountPriceCtrl = TextEditingController();

  /// Max quantity allowed for the menu (API: `quantity_allowed`).
  final TextEditingController quantityAllowedCtrl = TextEditingController();
  final List<String> selectedCategoryIds = [];
  String? selectedIsVeg;
  final List<String> selectedTagIds = [];

  /// Attribute id for menu attributes row (restaurant vs grocery key differs in API).
  String? selectedAttributeId;
  static const List<String> vegOptions = ['Yes', 'No'];
  String selectedEditCategoryName = '';
  String selectedEditTagName = '';
  int? currentEditMenuId;
  String? selectedEditCategoryId;
  String? selectedEditTagId;
  final List<String> selectedEditCategoryIds = [];
  final List<String> selectedEditTagIds = [];
  bool hasPopulatedEditForm = false;
  bool isRestaurantCategoriesLoading = false;
  List<RestaurantCategoryData> restaurantCategories = [];
  bool isRestaurantTagsLoading = false;
  List<TagData> restaurantTags = [];
  bool isMenuAttributesLoading = false;
  List<AttributeData> menuAttributes = [];

  final List<XFile> uploadedImages = [];

  /// Image URLs from API (existing menu images) for edit screen.
  List<String> existingMenuImageUrls = [];

  RestaurantMenuDetailsData? restaurantMenuDetails;
  bool isRestaurantMenuDetailsLoading = false;

  bool _isUploadingItemTemplate = false;

  @override
  void onInit() {
    super.onInit();
    debugPrint("MenuController initialized");
    getAllCategories();
    getAllTags();
    getAllAttributes();
  }

  List<String> get selectedCategoryDisplayNames {
    if (selectedCategoryIds.isEmpty) return const [];
    final set = selectedCategoryIds.toSet();
    return restaurantCategories
        .where((c) => c.id != null && set.contains(c.id.toString()))
        .map((c) => c.nameEn ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  String? get selectedCategoryDisplayText {
    final names = selectedCategoryDisplayNames;
    if (names.isEmpty) return null;
    return names.join(', ');
  }

  void toggleCategoryById(String id) {
    if (id.trim().isEmpty) return;
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id);
    }
    update();
  }

  List<String> get categoryDisplayNames => restaurantCategories
      .map((c) => c.nameEn ?? '')
      .where((s) => s.isNotEmpty)
      .toList();

  /// Display name for edit category dropdown (from API list).
  String get selectedEditCategoryDisplayName {
    if (selectedEditCategoryId != null && selectedEditCategoryId!.isNotEmpty) {
      final match = restaurantCategories
          .where((c) => c.id.toString() == selectedEditCategoryId)
          .toList();
      if (match.isNotEmpty && match.first.nameEn != null) {
        return match.first.nameEn!;
      }
    }
    final names = categoryDisplayNames;
    if (selectedEditCategoryName.isNotEmpty &&
        names.contains(selectedEditCategoryName)) {
      return selectedEditCategoryName;
    }
    return names.isNotEmpty ? names.first : '';
  }

  List<String> get selectedEditCategoryDisplayNames {
    if (selectedEditCategoryIds.isEmpty) return const [];
    final set = selectedEditCategoryIds.toSet();
    return restaurantCategories
        .where((c) => c.id != null && set.contains(c.id.toString()))
        .map((c) => c.nameEn ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  String? get selectedEditCategoryDisplayText {
    final names = selectedEditCategoryDisplayNames;
    if (names.isEmpty) return null;
    return names.join(', ');
  }

  void toggleEditCategoryById(String id) {
    if (id.trim().isEmpty) return;
    if (selectedEditCategoryIds.contains(id)) {
      selectedEditCategoryIds.remove(id);
    } else {
      selectedEditCategoryIds.add(id);
    }
    // Keep single-edit field in sync for legacy code paths.
    selectedEditCategoryId = selectedEditCategoryIds.isNotEmpty
        ? selectedEditCategoryIds.first
        : null;
    update();
  }

  void setSelectedEditCategoryByName(String? name) {
    if (name == null || name.isEmpty) {
      selectedEditCategoryId = null;
      selectedEditCategoryName = '';
      selectedEditCategoryIds.clear();
      update();
      return;
    }
    final match = restaurantCategories
        .where((c) => (c.nameEn ?? '') == name)
        .toList();
    selectedEditCategoryName = name;
    selectedEditCategoryId = match.isEmpty ? null : match.first.id?.toString();
    selectedEditCategoryIds
      ..clear()
      ..addAll(
        selectedEditCategoryId == null ? const [] : [selectedEditCategoryId!],
      );
    update();
  }

  List<String> get selectedTagDisplayNames {
    if (selectedTagIds.isEmpty) return const [];
    final set = selectedTagIds.toSet();
    return restaurantTags
        .where((t) => t.id != null && set.contains(t.id.toString()))
        .map((t) => t.nameEn ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  String? get selectedTagDisplayText {
    final names = selectedTagDisplayNames;
    if (names.isEmpty) return null;
    return names.join(', ');
  }

  void toggleTagById(String id) {
    if (id.trim().isEmpty) return;
    if (selectedTagIds.contains(id)) {
      selectedTagIds.remove(id);
    } else {
      selectedTagIds.add(id);
    }
    update();
  }

  List<String> get tagDisplayNames => restaurantTags
      .map((t) => t.nameEn ?? '')
      .where((s) => s.isNotEmpty)
      .toList();

  List<String> get attributeDisplayNames => menuAttributes
      .map((a) => a.nameEn ?? '')
      .where((s) => s.isNotEmpty)
      .toList();

  String? get selectedAttributeDisplayName {
    if (selectedAttributeId == null || selectedAttributeId!.isEmpty) {
      return null;
    }
    final match = menuAttributes
        .where((a) => a.id.toString() == selectedAttributeId)
        .toList();
    return match.isEmpty ? null : (match.first.nameEn ?? '');
  }

  void setSelectedAttributeByName(String? name) {
    if (name == null || name.isEmpty) {
      selectedAttributeId = null;
      update();
      return;
    }
    final match = menuAttributes
        .where((a) => (a.nameEn ?? '') == name)
        .toList();
    selectedAttributeId = match.isEmpty ? null : match.first.id?.toString();
    update();
  }

  /// Display name for edit tag dropdown (from API list).
  String get selectedEditTagDisplayName {
    if (selectedEditTagId != null && selectedEditTagId!.isNotEmpty) {
      final match = restaurantTags
          .where((t) => t.id.toString() == selectedEditTagId)
          .toList();
      if (match.isNotEmpty && match.first.nameEn != null) {
        return match.first.nameEn!;
      }
    }
    final names = tagDisplayNames;
    if (selectedEditTagName.isNotEmpty && names.contains(selectedEditTagName)) {
      return selectedEditTagName;
    }
    return names.isNotEmpty ? names.first : '';
  }

  List<String> get selectedEditTagDisplayNames {
    if (selectedEditTagIds.isEmpty) return const [];
    final set = selectedEditTagIds.toSet();
    return restaurantTags
        .where((t) => t.id != null && set.contains(t.id.toString()))
        .map((t) => t.nameEn ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  String? get selectedEditTagDisplayText {
    final names = selectedEditTagDisplayNames;
    if (names.isEmpty) return null;
    return names.join(', ');
  }

  void toggleEditTagById(String id) {
    if (id.trim().isEmpty) return;
    if (selectedEditTagIds.contains(id)) {
      selectedEditTagIds.remove(id);
    } else {
      selectedEditTagIds.add(id);
    }
    // Keep single-edit field in sync for legacy code paths.
    selectedEditTagId = selectedEditTagIds.isNotEmpty
        ? selectedEditTagIds.first
        : null;
    update();
  }

  void setSelectedEditTagByName(String? name) {
    if (name == null || name.isEmpty) {
      selectedEditTagId = null;
      selectedEditTagName = '';
      selectedEditTagIds.clear();
      update();
      return;
    }
    final match = restaurantTags
        .where((t) => (t.nameEn ?? '') == name)
        .toList();
    selectedEditTagName = name;
    selectedEditTagId = match.isEmpty ? null : match.first.id?.toString();
    selectedEditTagIds
      ..clear()
      ..addAll(selectedEditTagId == null ? const [] : [selectedEditTagId!]);
    update();
  }

  Future<String> _prepareJpegImage(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      return sourcePath;
    }

    final targetPath = sourcePath.replaceFirst(
      RegExp(r'\.[^\.]+$'),
      '_compressed.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      format: CompressFormat.jpeg,
      quality: 80,
    );

    return result?.path ?? sourcePath;
  }

  Future<String?> _downloadImageToTempFile(String imageUrl) async {
    if (imageUrl.isEmpty) return null;
    try {
      final response = await DioClient().dio.get<List<int>>(
        imageUrl,
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/edit_menu_${DateTime.now().millisecondsSinceEpoch}.tmp',
      );
      await tempFile.writeAsBytes(bytes);
      return tempFile.path;
    } catch (e) {
      debugPrint("_downloadImageToTempFile error: $e");
      return null;
    }
  }

  @override
  void onClose() {
    nameEnCtrl.dispose();
    nameArCtrl.dispose();
    nameFrCtrl.dispose();
    descEnCtrl.dispose();
    descArCtrl.dispose();
    descFrCtrl.dispose();
    prepTimeCtrl.dispose();
    priceCtrl.dispose();
    discountPriceCtrl.dispose();
    quantityAllowedCtrl.dispose();
    super.onClose();
  }

  void setSelectedIsVeg(String? value) {
    if (value != null) {
      selectedIsVeg = value;
      update();
    }
  }

  Future<void> loadEditMenu(String itemId) async {
    final menuId = int.tryParse(itemId);
    if (menuId == null) return;
    hasPopulatedEditForm = false;
    update();
    await getRestaurantMenuDetails(restaurantMenuId: menuId);
  }

  void _populateEditFormFromDetails(RestaurantMenu menu) {
    nameEnCtrl.text = menu.nameEn;
    nameArCtrl.text = menu.nameAr;
    nameFrCtrl.text = menu.nameFr;
    descEnCtrl.text = menu.descriptionEn;
    descArCtrl.text = menu.descriptionAr;
    descFrCtrl.text = menu.descriptionFr;
    selectedIsVeg = menu.isVeg == 1 ? 'Yes' : 'No';
    selectedEditCategoryId = menu.categoryId.isNotEmpty
        ? menu.categoryId
        : null;
    selectedEditCategoryIds
      ..clear()
      ..addAll(
        menu.categories.isNotEmpty
            ? menu.categories.map((c) => c.id.toString()).toList()
            : (selectedEditCategoryId != null &&
                  selectedEditCategoryId!.isNotEmpty)
            ? [selectedEditCategoryId!]
            : const [],
      );
    final names = categoryDisplayNames;
    selectedEditCategoryName =
        menu.categoryNameEn.isNotEmpty && names.contains(menu.categoryNameEn)
        ? menu.categoryNameEn
        : (names.isNotEmpty ? names.first : '');
    final tagNames = tagDisplayNames;
    selectedEditTagName = tagNames.isNotEmpty ? tagNames.first : '';
    selectedEditTagId = restaurantTags.isNotEmpty
        ? restaurantTags.first.id?.toString()
        : null;
    selectedEditTagIds
      ..clear()
      ..addAll(selectedEditTagId == null ? const [] : [selectedEditTagId!]);
    currentEditMenuId = menu.id;
    selectedEditCategoryId = menu.categoryId.isNotEmpty
        ? menu.categoryId
        : null;
    existingMenuImageUrls = menu.image.isNotEmpty
        ? [
            menu.image.startsWith('http')
                ? menu.image
                : '${ApiConfigs.IMAGE_URL}${menu.image}',
          ]
        : [];
    hasPopulatedEditForm = true;
    update();
  }

  void removeEditImageAt(int index) {
    if (index < existingMenuImageUrls.length) {
      existingMenuImageUrls.removeAt(index);
    } else {
      final localIndex = index - existingMenuImageUrls.length;
      if (localIndex >= 0 && localIndex < uploadedImages.length) {
        uploadedImages.removeAt(localIndex);
      }
    }
    update();
  }

  void resetEditForm() {
    nameEnCtrl.clear();
    nameArCtrl.clear();
    nameFrCtrl.clear();
    descEnCtrl.clear();
    descArCtrl.clear();
    descFrCtrl.clear();
    prepTimeCtrl.text = '20 Min';
    priceCtrl.text = '20 MRU';
    discountPriceCtrl.text = '10 MRU';
    quantityAllowedCtrl.text = '10';
    selectedEditCategoryName = categoryDisplayNames.isNotEmpty
        ? categoryDisplayNames.first
        : '';
    selectedEditCategoryId = restaurantCategories.isNotEmpty
        ? restaurantCategories.first.id?.toString()
        : null;
    selectedEditCategoryIds
      ..clear()
      ..addAll(
        selectedEditCategoryId == null ? const [] : [selectedEditCategoryId!],
      );
    selectedIsVeg = 'No';
    selectedEditTagName = tagDisplayNames.isNotEmpty
        ? tagDisplayNames.first
        : '';
    selectedEditTagId = restaurantTags.isNotEmpty
        ? restaurantTags.first.id?.toString()
        : null;
    selectedEditTagIds
      ..clear()
      ..addAll(selectedEditTagId == null ? const [] : [selectedEditTagId!]);
    existingMenuImageUrls = [];
    uploadedImages.clear();
    update();
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      uploadedImages.addAll(picked);
      update();
    }
  }

  Future<void> pickFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      uploadedImages.add(photo);
      update();
    }
  }

  void removeImageAt(int index) {
    if (index >= 0 && index < uploadedImages.length) {
      uploadedImages.removeAt(index);
      update();
    }
  }

  void resetForm() {
    nameEnCtrl.clear();
    descEnCtrl.clear();
    prepTimeCtrl.clear();
    priceCtrl.clear();
    discountPriceCtrl.clear();
    quantityAllowedCtrl.clear();
    selectedCategoryIds.clear();
    selectedIsVeg = null;
    selectedTagIds.clear();
    selectedAttributeId = null;
    uploadedImages.clear();
    update();
  }

  String? addMenuValidation() {
    if (nameEnCtrl.text.trim().isEmpty) {
      return "Please enter item name";
    }
    if (selectedCategoryIds.isEmpty) {
      return "Please select at least one category";
    }
    if (selectedIsVeg == null || selectedIsVeg!.trim().isEmpty) {
      return "Please select veg type";
    }
    if (descEnCtrl.text.trim().isEmpty) {
      return "Please enter description";
    }
    if (selectedTagIds.isEmpty) {
      return "Please select at least one tag";
    }
    if (attributeDisplayNames.isNotEmpty &&
        (selectedAttributeId == null || selectedAttributeId!.trim().isEmpty)) {
      return "Please select attribute";
    }
    if (prepTimeCtrl.text.trim().isEmpty) {
      return "Please enter preparation time";
    }
    if (priceCtrl.text.trim().isEmpty) {
      return "Please enter price";
    }
    if (discountPriceCtrl.text.trim().isEmpty) {
      return "Please enter discount price";
    }
    if (quantityAllowedCtrl.text.trim().isEmpty) {
      return "Please enter maximum allowed quantity";
    }
    if (uploadedImages.isEmpty) {
      return "Please upload at least one image";
    }
    return null;
  }

  Future<void> addMenu(BuildContext context) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      await getSavedObject("vendorType");
      final attributeId =
          (selectedAttributeId != null &&
              selectedAttributeId!.trim().isNotEmpty)
          ? selectedAttributeId!.trim()
          : '2';
      final formDataMap = <String, dynamic>{
        "name_en": nameEnCtrl.text,
        "description_en": descEnCtrl.text,
        "is_veg": selectedIsVeg == 'Yes' ? '1' : '2',
        "quantity_allowed": quantityAllowedCtrl.text,
      };
      if (vendorType == "1") {
        formDataMap["attributes[0][price]"] = priceCtrl.text;
        formDataMap["attributes[0][discount_price]"] = discountPriceCtrl.text;
        formDataMap["attributes[0][preparation_time]"] = prepTimeCtrl.text;
        formDataMap["attributes[0][restaurant_attribute_id]"] = attributeId;
      } else {
        formDataMap["attributes[0][attribute_value]"] = prepTimeCtrl.text;
        formDataMap["attributes[0][retail_price]"] = priceCtrl.text;
        formDataMap["attributes[0][selling_price]"] = discountPriceCtrl.text;
        formDataMap["attributes[0][grocery_attribute_id]"] = attributeId;
      }
      if (uploadedImages.isNotEmpty) {
        final mainImagePath = await _prepareJpegImage(
          uploadedImages.first.path,
        );
        formDataMap["image"] = await dio.MultipartFile.fromFile(
          mainImagePath,
          filename: mainImagePath.split(RegExp(r'[/\\]')).last,
        );
      }
      final formData = dio.FormData.fromMap(formDataMap);
      for (final id in selectedCategoryIds) {
        final trimmed = id.trim();
        if (trimmed.isNotEmpty) {
          formData.fields.add(MapEntry("category_id[]", trimmed));
        }
      }
      for (final id in selectedTagIds) {
        final trimmed = id.trim();
        if (trimmed.isNotEmpty) {
          formData.fields.add(MapEntry("tags[]", trimmed));
        }
      }
      for (int i = 1; i < uploadedImages.length; i++) {
        final jpgPath = await _prepareJpegImage(uploadedImages[i].path);
        final baseName = jpgPath.split(RegExp(r'[/\\]')).last;
        final jpgFilename =
            baseName.endsWith('.jpg') || baseName.endsWith('.jpeg')
            ? baseName
            : '${baseName.split('.').first}.jpg';
        formData.files.add(
          MapEntry(
            "image[]",
            await dio.MultipartFile.fromFile(jpgPath, filename: jpgFilename),
          ),
        );
      }
      final response = await DioClient().post(
        vendorType == "1"
            ? ApiEndPoints.addRestaurantMenu
            : ApiEndPoints.addGroceryMenu,
        body: formData,
      );
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (Get.isRegistered<ProfileController>()) {
          await Get.find<ProfileController>().fetchRestaurantMenus();
        }
        if (context.mounted) {
          Get.back();
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

  void showImageAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Select Image"),
        content: const Text("Choose image from gallery or camera"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await pickAndCropImage(context, ImageSource.gallery);
            },
            child: const Text("Gallery"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await pickAndCropImage(context, ImageSource.camera);
            },
            child: const Text("Camera"),
          ),
        ],
      ),
    );
  }

  Future<void> pickAndCropImage(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
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
      if (cropped != null) {
        uploadedImages.add(XFile(cropped.path));
        update();
      }
    } catch (e) {
      debugPrint("pickAndCropImage error: $e");
    }
  }

  Future<void> getAllCategories({int? categoryId}) async {
    debugPrint(
      "[MenuController] getAllCategories:start prevCount=${restaurantCategories.length} selectedCategoryIds=${selectedCategoryIds.length} selectedEditCategoryId=$selectedEditCategoryId",
    );
    // Clear stale category state before loading for current vendor type.
    restaurantCategories = [];
    selectedCategoryIds.clear();
    selectedEditCategoryId = null;
    selectedEditCategoryName = '';
    isRestaurantCategoriesLoading = true;
    update();
    try {
      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      final endpoint = vendorType == "1"
          ? ApiEndPoints.getRestaurantCategories
          : ApiEndPoints.getGroceryCategories;
      debugPrint(
        "[MenuController] getAllCategories:request vendorType=$vendorType endpoint=$endpoint hasToken=${(token?.toString().isNotEmpty ?? false)}",
      );
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(endpoint);
      final rawData = response.data is Map<String, dynamic>
          ? response.data['data']
          : null;
      final rawDataCount = rawData is List ? rawData.length : -1;
      debugPrint(
        "[MenuController] getAllCategories:response status=${response.data is Map<String, dynamic> ? response.data['status'] : null} message=${response.data is Map<String, dynamic> ? response.data['message'] : null} rawDataCount=$rawDataCount",
      );
      if (vendorType == "1") {
        final restaurantCategoriesModel = RestaurantAllCategoriesModel.fromJson(
          response.data,
        );
        if (restaurantCategoriesModel.status?.toLowerCase() == 'true') {
          restaurantCategories = restaurantCategoriesModel.data ?? [];
          debugPrint(
            "[MenuController] getAllCategories:restaurant parseSuccess=true",
          );
        } else {
          debugPrint(
            "[MenuController] getAllCategories:restaurant parseSuccess=false modelStatus=${restaurantCategoriesModel.status}",
          );
        }
        debugPrint(
          "[MenuController] getAllCategories:restaurant mappedCount=${restaurantCategories.length}",
        );
      } else {
        final groceryCategoriesModel = GroceryAllCategoriesModel.fromJson(
          response.data,
        );
        if (groceryCategoriesModel.status == true) {
          restaurantCategories = (groceryCategoriesModel.data ?? [])
              .map(
                (c) => RestaurantCategoryData.fromJson({
                  "id": c.id ?? 0,
                  "name_en": c.nameEn ?? "",
                  "name_ar": c.nameAr ?? "",
                  "name_fr": c.nameFr ?? "",
                  "image": c.image ?? "",
                }),
              )
              .toList();
          debugPrint(
            "[MenuController] getAllCategories:grocery parseSuccess=true sourceCount=${groceryCategoriesModel.data?.length ?? 0}",
          );
        } else {
          debugPrint(
            "[MenuController] getAllCategories:grocery parseSuccess=false modelStatus=${groceryCategoriesModel.status}",
          );
        }
        debugPrint(
          "[MenuController] getAllCategories:grocery mappedCount=${restaurantCategories.length}",
        );
      }
    } catch (error) {
      debugPrint("[MenuController] getAllCategories:error $error");
    } finally {
      isRestaurantCategoriesLoading = false;
      debugPrint(
        "[MenuController] getAllCategories:done finalCount=${restaurantCategories.length} loading=$isRestaurantCategoriesLoading",
      );
      update();
    }
  }

  Future<void> getAllTags({int? categoryId}) async {
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
      final raw = response.data;
      final map = raw is Map<String, dynamic>
          ? raw
          : Map<String, dynamic>.from(raw as Map);
      if (vendorType == "1") {
        final tagsModel = TagsModel.fromJson(map);
        if (tagsModel.status == 'true') {
          restaurantTags = tagsModel.data ?? [];
        }
      } else {
        final groceryTagsModel = GroceryTagsModel.fromJson(map);
        if (groceryTagsModel.status == true) {
          restaurantTags = (groceryTagsModel.data ?? [])
              .map(
                (g) => TagData(
                  id: g.id,
                  nameEn: g.nameEn ?? '',
                  nameAr: g.nameAr ?? '',
                  nameFr: g.nameFr ?? '',
                ),
              )
              .toList();
        }
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
      isMenuAttributesLoading = true;
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
      final raw = response.data;
      final map = raw is Map<String, dynamic>
          ? raw
          : Map<String, dynamic>.from(raw as Map);
      final attributesModel = AttributesModel.fromJson(map);
      if (attributesModel.status == true) {
        menuAttributes = attributesModel.data ?? [];
      }
    } catch (error, stackTrace) {
      debugPrint("getAllAttributes Error: $error");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isMenuAttributesLoading = false;
      update();
    }
  }

  Future<void> deleteMenu(
    BuildContext context, {
    required String restaurantMenuId,
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
        vendorType == "1" ? "restaurant_menu_id" : "grocery_menu_id":
            restaurantMenuId,
      };

      final response = await DioClient().post(
        vendorType == "1"
            ? ApiEndPoints.deleteRestaurantMenu
            : ApiEndPoints.deleteGroceryMenu,

        body: formDataMap,
      );
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          profileController.removeRestaurantMenuById(restaurantMenuId);
          await profileController.fetchRestaurantMenus();
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

  Future<void> getRestaurantMenuDetails({int? restaurantMenuId}) async {
    if (restaurantMenuId == null) return;
    try {
      isRestaurantMenuDetailsLoading = true;
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
            ? ApiEndPoints.getRestaurantMenuDetails
            : ApiEndPoints.getGroceryMenuDetails,
        query: vendorType == "1"
            ? {'restaurant_menu_id': restaurantMenuId}
            : {'grocery_menu_id': restaurantMenuId},
      );
      if (vendorType == "1") {
        final restaurantMenuDetailsModel = RestaurantMenuDetailsModel.fromJson(
          response.data is Map<String, dynamic>
              ? response.data
              : Map<String, dynamic>.from(response.data),
        );
        if (restaurantMenuDetailsModel.status) {
          restaurantMenuDetails = restaurantMenuDetailsModel.data;
          final menu = restaurantMenuDetails?.restaurantMenu;
          if (menu != null) {
            _populateEditFormFromDetails(menu);
          }
        }
      } else {
        final groceryMenuDetailsModel = GroceryMenuDetailsModel.fromJson(
          response.data is Map<String, dynamic>
              ? response.data
              : Map<String, dynamic>.from(response.data),
        );

        if (groceryMenuDetailsModel.status == true &&
            groceryMenuDetailsModel.data != null &&
            groceryMenuDetailsModel.data!.groceryMenu != null) {
          final groceryMenu = groceryMenuDetailsModel.data!.groceryMenu!;

          final categoriesJson = (groceryMenu.categories ?? [])
              .map(
                (c) => {
                  "id": c.id ?? 0,
                  "name_en": c.nameEn ?? "",
                  "name_ar": c.nameAr ?? "",
                  "name_fr": c.nameFr ?? "",
                  "image": c.image ?? "",
                  "status": c.status ?? 0,
                  "deleted_at": c.deletedAt?.toString(),
                  "created_at": c.createdAt ?? "",
                  "updated_at": c.updatedAt ?? "",
                },
              )
              .toList();
          final converted = {
            "status": true,
            "message": groceryMenuDetailsModel.message ?? "",
            "data": {
              "restaurant_menu": {
                "id": groceryMenu.id ?? 0,
                "category_id": groceryMenu.categoryId ?? "",
                "restaurant_id": 0,
                "name_en": groceryMenu.nameEn ?? "",
                "name_ar": groceryMenu.nameAr ?? "",
                "name_fr": groceryMenu.nameFr ?? "",
                "description_en": groceryMenu.descriptionEn ?? "",
                "description_ar": groceryMenu.descriptionAr ?? "",
                "description_fr": groceryMenu.descriptionFr ?? "",
                "image": groceryMenu.image ?? "",
                "is_veg": 0,
                "approval_status": groceryMenu.approvalStatus ?? 0,
                "deleted_at": groceryMenu.deletedAt?.toString(),
                "created_at": groceryMenu.createdAt ?? "",
                "updated_at": groceryMenu.updatedAt ?? "",
                "category_name_en": groceryMenu.categoryNameEn ?? "",
                "category_name_ar": groceryMenu.categoryNameAr ?? "",
                "category_name_fr": groceryMenu.categoryNameFr ?? "",
                "categories": categoriesJson,
              },
              "total_orders": groceryMenuDetailsModel.data!.totalOrders ?? 0,
              "total_revenue": groceryMenuDetailsModel.data!.totalRevenue ?? 0,
              "average_rating":
                  groceryMenuDetailsModel.data!.averageRating ?? 0,
              "total_rating_count":
                  groceryMenuDetailsModel.data!.totalRatingCount ?? 0,
              "order_details": groceryMenuDetailsModel.data!.orderDetails ?? [],
            },
          };

          final restaurantMenuDetailsModel =
              RestaurantMenuDetailsModel.fromJson(converted);
          if (restaurantMenuDetailsModel.status) {
            restaurantMenuDetails = restaurantMenuDetailsModel.data;
            final menu = restaurantMenuDetails?.restaurantMenu;
            if (menu != null) {
              _populateEditFormFromDetails(menu);
            }
          }
        }
      }
    } catch (error) {
      debugPrint("getRestaurantMenuDetails Error: $error");
    } finally {
      isRestaurantMenuDetailsLoading = false;
      update();
    }
  }

  Future<void> updateEditedMenu(BuildContext context) async {
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
        "restaurant_menu_id": currentEditMenuId ?? 0,
        "name_en": nameEnCtrl.text,
        "description_en": descEnCtrl.text,
        "is_veg": selectedIsVeg == 'Yes' ? '1' : '2',
        "attributes[0][price]": priceCtrl.text,
        "attributes[0][discount_price]": discountPriceCtrl.text,
        "attributes[0][preparation_time]": prepTimeCtrl.text,
        "attributes[0][quantity_allowed]": quantityAllowedCtrl.text.trim(),
      };
      if (kDebugMode) {
        for (final e in formDataMap.entries) {
          final v = e.value;
          debugPrint(
            "formDataMap[${e.key}]: ${v is dio.MultipartFile ? '[MultipartFile: ${v.filename}]' : v}",
          );
        }
      }
      final List<MapEntry<String, String>> imagePaths = [];
      for (final url in existingMenuImageUrls) {
        final tempPath = await _downloadImageToTempFile(url);
        if (tempPath != null) {
          try {
            final jpgPath = await _prepareJpegImage(tempPath);
            final baseName = jpgPath.split(RegExp(r'[/\\]')).last;
            final jpgFilename =
                baseName.endsWith('.jpg') || baseName.endsWith('.jpeg')
                ? baseName
                : 'existing_${imagePaths.length}.jpg';
            imagePaths.add(MapEntry(jpgPath, jpgFilename));
          } finally {
            try {
              await File(tempPath).delete();
            } catch (_) {}
          }
        }
      }
      for (int i = 0; i < uploadedImages.length; i++) {
        final jpgPath = await _prepareJpegImage(uploadedImages[i].path);
        final baseName = jpgPath.split(RegExp(r'[/\\]')).last;
        final jpgFilename =
            baseName.endsWith('.jpg') || baseName.endsWith('.jpeg')
            ? baseName
            : '${baseName.split('.').first}.jpg';
        imagePaths.add(MapEntry(jpgPath, jpgFilename));
      }
      if (imagePaths.isNotEmpty) {
        final first = imagePaths.first;
        formDataMap["image"] = await dio.MultipartFile.fromFile(
          first.key,
          filename: first.value,
        );
      }
      final formData = dio.FormData.fromMap(formDataMap);
      final List<String> categoryIdsToSend = selectedEditCategoryIds.isNotEmpty
          ? selectedEditCategoryIds
          : (() {
              String? categoryId = selectedEditCategoryId;
              if (categoryId == null || categoryId.isEmpty) {
                final match = restaurantCategories
                    .where((c) => (c.nameEn ?? '') == selectedEditCategoryName)
                    .toList();
                if (match.isNotEmpty && match.first.id != null) {
                  categoryId = match.first.id.toString();
                }
              }
              if (categoryId == null || categoryId.isEmpty) return <String>[];
              final normalized =
                  RegExp(r'\d+').firstMatch(categoryId)?.group(0) ?? '';
              return normalized.isNotEmpty ? <String>[normalized] : <String>[];
            })();
      for (final id in categoryIdsToSend) {
        final normalized = RegExp(r'\d+').firstMatch(id)?.group(0) ?? '';
        if (normalized.isNotEmpty) {
          formData.fields.add(MapEntry("category_id[]", normalized));
        }
      }

      final List<String> tagIdsToSend = selectedEditTagIds.isNotEmpty
          ? selectedEditTagIds
          : (selectedEditTagId != null && selectedEditTagId!.trim().isNotEmpty)
          ? <String>[selectedEditTagId!.trim()]
          : <String>[];
      for (final id in tagIdsToSend) {
        final normalized = RegExp(r'\d+').firstMatch(id)?.group(0) ?? '';
        if (normalized.isNotEmpty) {
          formData.fields.add(MapEntry("tags[]", normalized));
        }
      }
      for (int i = 1; i < imagePaths.length; i++) {
        final e = imagePaths[i];
        formData.files.add(
          MapEntry(
            "image[]",
            await dio.MultipartFile.fromFile(e.key, filename: e.value),
          ),
        );
      }
      if (kDebugMode) {
        debugPrint("FormData (updateEditedMenu):");
        for (final e in formData.fields) {
          debugPrint("  field ${e.key}: ${e.value}");
        }
        for (final e in formData.files) {
          debugPrint("  file ${e.key}: ${e.value.filename}");
        }
      }
      final response = await DioClient().post(
        vendorType == "1"
            ? ApiEndPoints.updateRestaurantMenuEdit
            : ApiEndPoints.updateGroceryMenuEdit,
        body: formData,
      );
      if (context.mounted) {
        Get.back();
      }
      if (response.data['status'] == 'true' ||
          response.data['status'] == true) {
        if (Get.isRegistered<ProfileController>()) {
          await Get.find<ProfileController>().fetchRestaurantMenus();
        }
        if (context.mounted) {
          Get.back();
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

  void downloadItemTemplate(BuildContext context) async {
    debugPrint("downloadItemTemplate:start");
    try {
      final token = await getSavedObject("token");
      final vendorType =
          (await getSavedObject("vendorType"))?.toString() ?? "1";

      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().dio.get<List<int>>(
        ApiEndPoints.exportMenuItems,
        queryParameters: {"vendor_type": vendorType},
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
          headers: {
            'Accept':
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, '
                'application/vnd.ms-excel, application/octet-stream, */*',
          },
          validateStatus: (code) => code != null && code < 600,
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        if (context.mounted) showToast(context, 'Empty template response');
        return;
      }
      final contentType =
          response.headers.value('content-type')?.toLowerCase() ?? '';
      final looksLikeZipXlsx =
          bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B;
      final maybeJsonBody =
          !looksLikeZipXlsx &&
          (contentType.contains('json') ||
              (bytes.isNotEmpty && bytes[0] == 0x7B));
      if (maybeJsonBody) {
        final asText = utf8.decode(bytes, allowMalformed: true);
        final trimmed = asText.trimLeft();
        if (contentType.contains('json') || trimmed.startsWith('{')) {
          try {
            final map = jsonDecode(asText);
            if (map is Map) {
              final msg =
                  map['message']?.toString() ??
                  map['error']?.toString() ??
                  'Could not download template';
              if (context.mounted) showToast(context, msg);
            }
          } catch (_) {
            if (context.mounted) {
              showToast(context, 'Unexpected response (not Excel file)');
            }
          }
          return;
        }
      }
      if (response.statusCode != null && response.statusCode! >= 400) {
        if (context.mounted) {
          final msg = maybeJsonBody
              ? utf8.decode(bytes, allowMalformed: true).trim()
              : '';
          showToast(
            context,
            msg.isNotEmpty ? msg : 'Download failed (${response.statusCode})',
          );
        }
        return;
      }
      final fileName =
          'menu_items_bulk_template_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      Directory? targetDir;
      if (Platform.isAndroid) {
        final downloads = Directory('/storage/emulated/0/Download');
        if (!await downloads.exists()) {
          await downloads.create(recursive: true);
        }
        if (await downloads.exists()) targetDir = downloads;
      } else if (Platform.isIOS) {
        targetDir = await getApplicationDocumentsDirectory();
      }
      targetDir ??= await getApplicationDocumentsDirectory();
      final internalDir = await getApplicationDocumentsDirectory();
      final internalFile = File('${internalDir.path}/$fileName');
      File file = File('${targetDir.path}/$fileName');
      try {
        await file.writeAsBytes(bytes, flush: true);
      } catch (_) {
        final fallbackDir = await getApplicationDocumentsDirectory();
        file = File('${fallbackDir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);
      }
      await internalFile.writeAsBytes(bytes, flush: true);
      final exists = await file.exists();
      final fileSize = exists ? await file.length() : 0;
      if (!exists || fileSize == 0) {
        final internalExists = await internalFile.exists();
        final internalSize = internalExists ? await internalFile.length() : 0;
        if (!internalExists || internalSize == 0) {
          if (context.mounted) showToast(context, 'Downloaded file is empty.');
          return;
        }
      }
      if (context.mounted) {
        showToast(context, 'Saved: ${internalFile.path}');
      }
      try {
        final result = await OpenFilex.open(internalFile.path);
        debugPrint(
          "OpenFilex result: type=${result.type} message=${result.message}",
        );
      } catch (e) {
        debugPrint('OpenFilex open error: $e');
        if (context.mounted) showToast(context, e.toString());
      }
      return;
    } catch (error) {
      debugPrint('downloadItemTemplate Error: $error');
      if (context.mounted) {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> uploadItemTemplate(BuildContext context) async {
    if (_isUploadingItemTemplate) return;
    _isUploadingItemTemplate = true;

    try {
      showLoadingDialog(context);

      final token = await getSavedObject("token");
      final vendorType =
          (await getSavedObject("vendorType"))?.toString() ?? "1";

      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['xlsx'],
        withReadStream: false,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final picked = result.files.single;
      final path = picked.path;
      if (path == null || path.isEmpty) {
        showToast(context, "Could not access the selected file");
        return;
      }

      final fileName = picked.name;

      final multipartFile = await dio.MultipartFile.fromFile(
        path,
        filename: fileName,
      );

      // Backend expects this exact multipart key.
      final formData = dio.FormData.fromMap({"excel_file": multipartFile});
      final response = await DioClient().dio.post(
        ApiEndPoints.uploadMenuItems,
        data: formData,
        queryParameters: {"vendor_type": vendorType},
        options: dio.Options(contentType: "multipart/form-data"),
      );

      final raw = response.data;
      if (raw is! Map) {
        showToast(context, "Invalid server response");
        return;
      }

      final map = Map<String, dynamic>.from(raw);
      final ok = map['status']?.toString() == 'true' || map['status'] == true;
      String resolveMessage(dynamic message, String fallback) {
        if (message == null) return fallback;
        if (message is String && message.trim().isNotEmpty) return message;
        if (message is Map) {
          final m = Map<String, dynamic>.from(message);
          final lang = Get.locale?.languageCode ?? 'en';
          final key = lang == 'ar'
              ? 'message_ar'
              : lang == 'fr'
              ? 'message_fr'
              : 'message_en';
          final localized = m[key];
          if (localized is List && localized.isNotEmpty) {
            return localized.first.toString();
          }
          final en = m['message_en'];
          if (en is List && en.isNotEmpty) return en.first.toString();
          for (final v in m.values) {
            if (v is List && v.isNotEmpty) return v.first.toString();
            if (v is String && v.trim().isNotEmpty) return v;
          }
        }
        return fallback;
      }

      if (ok) {
        if (Get.isRegistered<ProfileController>()) {
          await Get.find<ProfileController>().fetchRestaurantMenus();
        }
        final msg = resolveMessage(map['message'], 'Upload successful');
        showToast(context, msg);
        debugPrint("uploadItemTemplate: $msg");
      } else {
        showToast(context, resolveMessage(map['message'], 'Upload failed'));
      }
    } catch (error) {
      debugPrint("uploadItemTemplate Error: $error");
      showToast(context, error.toString());
    } finally {
      // Close the loading dialog.
      if (context.mounted) {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) nav.pop();
      }
      _isUploadingItemTemplate = false;
      update();
    }
  }
}
