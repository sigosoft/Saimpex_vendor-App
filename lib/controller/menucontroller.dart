import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/restaurant_category_model.dart';
import 'package:saimpex_vendor/model/tag_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class MenuController extends GetxController {
  // Form controllers and state previously in AddMenuScreen
  final TextEditingController nameEnCtrl = TextEditingController();
  final TextEditingController descEnCtrl = TextEditingController();
  final TextEditingController prepTimeCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController discountPriceCtrl = TextEditingController();

  String? selectedCategory;
  String selectedIsVeg = 'No';
  String? selectedTag;
  bool isRestaurantCategoriesLoading = false;
  List<RestaurantCategoryData> restaurantCategories = [];
  bool isRestaurantTagsLoading = false;
  List<TagData> restaurantTags = [];

  final List<XFile> uploadedImages = [];

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

  @override
  void onClose() {
    nameEnCtrl.dispose();
    descEnCtrl.dispose();
    prepTimeCtrl.dispose();
    priceCtrl.dispose();
    discountPriceCtrl.dispose();
    super.onClose();
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
        final extraPath = await _prepareJpegImage(uploadedImages[i].path);
        formData.files.add(
          MapEntry(
            "image[]",
            await dio.MultipartFile.fromFile(
              extraPath,
              filename: extraPath.split(RegExp(r'[/\\]')).last,
            ),
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
}
