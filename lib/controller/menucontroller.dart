import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/model/restaurant_category_model.dart';
import 'package:saimpex_vendor/model/restaurant_menu_details_model.dart';
import 'package:saimpex_vendor/model/tag_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class MenuController extends GetxController {
  // Form controllers and state previously in AddMenuScreen
  final TextEditingController nameEnCtrl = TextEditingController();
  final TextEditingController nameArCtrl = TextEditingController();
  final TextEditingController nameFrCtrl = TextEditingController();
  final TextEditingController descEnCtrl = TextEditingController();
  final TextEditingController descArCtrl = TextEditingController();
  final TextEditingController descFrCtrl = TextEditingController();
  final TextEditingController prepTimeCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController discountPriceCtrl = TextEditingController();

  String? selectedCategory;
  String selectedIsVeg = 'No';
  String? selectedTag;

  // Edit screen: dropdowns (category and tags from API)
  static const List<String> vegOptions = ['Yes', 'No'];
  String selectedEditCategoryName = '';
  String selectedEditTagName = '';

  /// Menu id being edited (for update API).
  int? currentEditMenuId;

  /// Category id for edit form (from API or resolved from name).
  String? selectedEditCategoryId;

  /// Tag id for edit form (from API or resolved from name).
  String? selectedEditTagId;
  bool hasPopulatedEditForm = false;
  bool isRestaurantCategoriesLoading = false;
  List<RestaurantCategoryData> restaurantCategories = [];
  bool isRestaurantTagsLoading = false;
  List<TagData> restaurantTags = [];

  final List<XFile> uploadedImages = [];

  /// Image URLs from API (existing menu images) for edit screen.
  List<String> existingMenuImageUrls = [];

  RestaurantMenuDetailsData? restaurantMenuDetails;
  bool isRestaurantMenuDetailsLoading = false;

  @override
  void onInit() {
    super.onInit();
    debugPrint("MenuController initialized");
    getAllCategories();
    getAllTags();
  }

  String? get selectedCategoryDisplayName {
    if (selectedCategory == null || selectedCategory!.isEmpty) return null;
    final match = restaurantCategories
        .where((c) => c.id.toString() == selectedCategory)
        .toList();
    return match.isEmpty ? null : (match.first.nameEn ?? '');
  }

  void setSelectedCategoryByName(String? name) {
    if (name == null || name.isEmpty) {
      selectedCategory = null;
      return;
    }
    final match = restaurantCategories
        .where((c) => (c.nameEn ?? '') == name)
        .toList();
    selectedCategory = match.isEmpty ? null : match.first.id?.toString();
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

  void setSelectedEditCategoryByName(String? name) {
    if (name == null || name.isEmpty) {
      selectedEditCategoryId = null;
      selectedEditCategoryName = '';
      update();
      return;
    }
    final match = restaurantCategories
        .where((c) => (c.nameEn ?? '') == name)
        .toList();
    selectedEditCategoryName = name;
    selectedEditCategoryId = match.isEmpty ? null : match.first.id?.toString();
    update();
  }

  String? get selectedTagDisplayName {
    if (selectedTag == null || selectedTag!.isEmpty) return null;
    final match = restaurantTags
        .where((t) => t.id.toString() == selectedTag)
        .toList();
    return match.isEmpty ? null : (match.first.nameEn ?? '');
  }

  void setSelectedTagByName(String? name) {
    if (name == null || name.isEmpty) {
      selectedTag = null;
      return;
    }
    final match = restaurantTags
        .where((t) => (t.nameEn ?? '') == name)
        .toList();
    selectedTag = match.isEmpty ? null : match.first.id?.toString();
  }

  List<String> get tagDisplayNames => restaurantTags
      .map((t) => t.nameEn ?? '')
      .where((s) => s.isNotEmpty)
      .toList();

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

  void setSelectedEditTagByName(String? name) {
    if (name == null || name.isEmpty) {
      selectedEditTagId = null;
      selectedEditTagName = '';
      update();
      return;
    }
    final match = restaurantTags
        .where((t) => (t.nameEn ?? '') == name)
        .toList();
    selectedEditTagName = name;
    selectedEditTagId = match.isEmpty ? null : match.first.id?.toString();
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

  /// Downloads image from [imageUrl] to a temp file and returns the local path.
  /// Caller should delete the temp file when done, or pass to _prepareJpegImage.
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
    selectedEditCategoryName = categoryDisplayNames.isNotEmpty
        ? categoryDisplayNames.first
        : '';
    selectedEditCategoryId = restaurantCategories.isNotEmpty
        ? restaurantCategories.first.id?.toString()
        : null;
    selectedIsVeg = 'No';
    selectedEditTagName = tagDisplayNames.isNotEmpty
        ? tagDisplayNames.first
        : '';
    selectedEditTagId = restaurantTags.isNotEmpty
        ? restaurantTags.first.id?.toString()
        : null;
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
    selectedCategory = null;
    selectedIsVeg = 'No';
    selectedTag = null;
    uploadedImages.clear();
    update();
  }

  String? addMenuValidation() {
    if (nameEnCtrl.text.trim().isEmpty) {
      return "Please enter item name";
    }
    if (selectedCategory == null || selectedCategory!.trim().isEmpty) {
      return "Please select category";
    }
    if (descEnCtrl.text.trim().isEmpty) {
      return "Please enter description";
    }
    if (selectedTag == null || selectedTag!.trim().isEmpty) {
      return "Please select a tag";
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
    if (uploadedImages.isEmpty) {
      return "Please upload at least one image";
    }
    return null;
  }

  Future<void> addMenu(BuildContext context) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      await getSavedObject("vendorType");
      final formDataMap = <String, dynamic>{
        "name_en": nameEnCtrl.text,
        "description_en": descEnCtrl.text,
        "is_veg": selectedIsVeg == 'Yes' ? '1' : '2',
        "quantity_allowed": "10",
        "attributes[0][restaurant_attribute_id]": "2",
        "attributes[0][price]": priceCtrl.text,
        "attributes[0][discount_price]": discountPriceCtrl.text,
        "attributes[0][preparation_time]": prepTimeCtrl.text,
      };

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
      if (selectedCategory != null && selectedCategory!.isNotEmpty) {
        formData.fields.add(MapEntry("category_id[]", selectedCategory!));
      }
      if (selectedTag != null && selectedTag!.isNotEmpty) {
        formData.fields.add(MapEntry("tags[]", selectedTag!));
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
        ApiEndPoints.addRestaurantMenu,
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
              await pickImages();
            },
            child: const Text("Gallery"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await pickFromCamera();
            },
            child: const Text("Camera"),
          ),
        ],
      ),
    );
  }

  Future<void> getAllCategories({int? categoryId}) async {
    try {
      isRestaurantCategoriesLoading = true;
      update();

      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(
        ApiEndPoints.getRestaurantCategories,
      );
      final restaurantCategoriesModel = RestaurantAllCategoriesModel.fromJson(
        response.data,
      );
      if (restaurantCategoriesModel.status == 'true') {
        restaurantCategories = restaurantCategoriesModel.data ?? [];
      }
    } catch (error) {
      debugPrint("getAllCategories Error: $error");
    } finally {
      isRestaurantCategoriesLoading = false;
      update();
    }
  }

  Future<void> getAllTags({int? categoryId}) async {
    try {
      isRestaurantTagsLoading = true;
      update();

      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(ApiEndPoints.getRestaurantTags);
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

  Future<void> deleteMenu(
    BuildContext context, {
    required String restaurantMenuId,
  }) async {
    try {
      showLoadingDialog(context);
      var token = await getSavedObject("token");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      await getSavedObject("vendorType");
      final formDataMap = <String, dynamic>{
        "restaurant_menu_id": restaurantMenuId,
      };

      final response = await DioClient().post(
        ApiEndPoints.deleteRestaurantMenu,
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
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      final response = await DioClient().get(
        ApiEndPoints.getRestaurantMenuDetails,
        query: {'restaurant_menu_id': restaurantMenuId},
      );
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
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }
      await getSavedObject("vendorType");
      final formDataMap = <String, dynamic>{
        "restaurant_menu_id": currentEditMenuId ?? 0,
        "name_en": nameEnCtrl.text,
        "description_en": descEnCtrl.text,
        "is_veg": selectedIsVeg == 'Yes' ? '1' : '2',
        "attributes[0][price]": priceCtrl.text,
        "attributes[0][discount_price]": discountPriceCtrl.text,
        "attributes[0][preparation_time]": prepTimeCtrl.text,
        "attributes[0][quantity_allowed]": "10",
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
      String? categoryId = selectedEditCategoryId;
      if (categoryId == null || categoryId.isEmpty) {
        final match = restaurantCategories
            .where((c) => (c.nameEn ?? '') == selectedEditCategoryName)
            .toList();
        if (match.isNotEmpty && match.first.id != null) {
          categoryId = match.first.id.toString();
        }
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        final normalized =
            RegExp(r'\d+').firstMatch(categoryId)?.group(0) ?? '';
        if (normalized.isNotEmpty) {
          formData.fields.add(MapEntry("category_id", normalized));
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
        ApiEndPoints.updateRestaurantMenuEdit,
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
}
