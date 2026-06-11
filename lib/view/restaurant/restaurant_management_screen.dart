import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:flutter_localization/flutter_localization.dart';

class CategoryItem {
  final String id;
  String name;
  String date;
  String status; // 'ACTIVE' or 'BLOCKED'
  String? image;

  CategoryItem({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    this.image,
  });
}

class TagItem {
  final String id;
  String name;
  String date;
  String status; // 'ACTIVE' or 'BLOCKED'

  TagItem({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
  });
}

class RestaurantManagementScreen extends StatefulWidget {
  const RestaurantManagementScreen({super.key});

  @override
  State<RestaurantManagementScreen> createState() =>
      _RestaurantManagementScreenState();
}

class _RestaurantManagementScreenState
    extends State<RestaurantManagementScreen> {
  int _selectedTabIndex = 0; // 0 = Categories, 1 = Tags
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isLoadingCategories = false;
  bool _isLoadingTags = false;

  final List<CategoryItem> _categories = [];
  final List<TagItem> _tags = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchTags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter lists based on Search Query
  List<CategoryItem> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<TagItem> get _filteredTags {
    if (_searchQuery.isEmpty) return _tags;
    return _tags
        .where((t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _setToken() async {
    final token = await getSavedObject("token");
    DioClient().updateToken(token?.toString() ?? "");
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  List<dynamic> _extractDataList(dynamic raw) {
    final map = _asMap(raw);
    final data = map['data'];
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['data', 'tags', 'categories', 'menu_tags']) {
        final nested = data[key];
        if (nested is List) return nested;
        if (nested is Map && nested['data'] is List) {
          return nested['data'] as List;
        }
      }
    }
    return const [];
  }

  bool _isSuccess(dynamic raw) {
    final status = _asMap(raw)['status'];
    return status == true || status?.toString().toLowerCase() == 'true';
  }

  String _responseMessage(
    dynamic raw,
    String fallback, {
    int? statusCode,
    bool showStatusCode = false,
  }) {
    final message = _asMap(raw)['message'];
    String resolved = fallback;
    if (message is String && message.trim().isNotEmpty) {
      resolved = message;
    }
    if (message is Map) {
      for (final key in ['message_en', 'message_fr', 'message_ar']) {
        final value = message[key];
        if (value is List && value.isNotEmpty) {
          resolved = value.first.toString();
          break;
        }
        if (value is String && value.trim().isNotEmpty) {
          resolved = value;
          break;
        }
      }
    }
    if (showStatusCode && statusCode != null) {
      return '$resolved (Status code: $statusCode)';
    }
    return resolved;
  }

  String _nameFromJson(Map<String, dynamic> map) {
    final lang = FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
    String name = '';
    if (lang == 'fr') {
      name = (map['name_fr'] ?? map['name_en'] ?? map['name'] ?? map['title'] ?? map['tag_name'] ?? map['category_name'] ?? '').toString();
    } else if (lang == 'ar') {
      name = (map['name_ar'] ?? map['name_en'] ?? map['name'] ?? map['title'] ?? map['tag_name'] ?? map['category_name'] ?? '').toString();
    } else {
      name = (map['name_en'] ?? map['name'] ?? map['title'] ?? map['tag_name'] ?? map['category_name'] ?? '').toString();
    }

    if (lang == 'en') {
      final trimmedLower = name.trim().toLowerCase();
      if (trimmedLower == 'offre') {
        name = 'Offer';
      } else if (trimmedLower == 'offres') {
        name = 'Offers';
      } else if (trimmedLower == 'offre combo' || trimmedLower == 'combo offre') {
        name = 'Combo Offer';
      }
    }
    return name;
  }

  String _statusFromJson(Map<String, dynamic> map) {
    final raw = map['status'] ?? map['is_active'] ?? map['available_status'];
    final value = raw?.toString().trim().toLowerCase() ?? '';
    if (raw == true ||
        value == '1' ||
        value == 'active' ||
        value == 'true' ||
        value == 'available') {
      return 'ACTIVE';
    }
    return 'BLOCKED';
  }

  String _formatDateFromJson(Map<String, dynamic> map) {
    final raw = map['created_at'] ?? map['updated_at'] ?? map['date'];
    final parsed = DateTime.tryParse(raw?.toString() ?? '')?.toLocal();
    final dt = parsed ?? DateTime.now();
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final period = dt.hour >= 12 ? "PM" : "AM";
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    return "${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}, ${hour.toString().padLeft(2, '0')}:$min $period";
  }

  Future<dio.MultipartFile> _defaultCategoryImage() async {
    final data = await rootBundle.load('lib/assets/images/nodata.png');
    return dio.MultipartFile.fromBytes(
      data.buffer.asUint8List(),
      filename: 'category.png',
    );
  }

  CategoryItem _categoryFromJson(dynamic raw) {
    final map = _asMap(raw);
    return CategoryItem(
      id: (map['id'] ?? map['category_id'] ?? map['menu_category_id'] ?? '')
          .toString(),
      name: _nameFromJson(map),
      date: _formatDateFromJson(map),
      status: _statusFromJson(map),
      image: map['image']?.toString() ?? map['category_image']?.toString(),
    );
  }

  TagItem _tagFromJson(dynamic raw) {
    final map = _asMap(raw);
    return TagItem(
      id: (map['id'] ?? map['tag_id'] ?? map['menu_tag_id'] ?? '').toString(),
      name: _nameFromJson(map),
      date: _formatDateFromJson(map),
      status: _statusFromJson(map),
    );
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      await _setToken();
      final response = await DioClient().get(
        ApiEndPoints.menuCategories,
        query: {'limit': 100},
      );
      debugPrint("[FetchCategories] raw response data: ${response.data}");
      final items = _extractDataList(response.data)
          .map(_categoryFromJson)
          .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
          .toList();
      if (mounted) {
        setState(() {
          _categories
            ..clear()
            ..addAll(items);
        });
      }
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _fetchTags() async {
    setState(() => _isLoadingTags = true);
    try {
      await _setToken();
      final response = await DioClient().get(
        ApiEndPoints.menuTags,
        query: {'limit': 100},
      );
      debugPrint("[FetchTags] raw response data: ${response.data}");
      debugPrint(
        "[RestaurantManagement] raw menuTags response data: ${response.data}",
      );

      try {
        final compareResponse = await DioClient().get(
          ApiEndPoints.getRestaurantTags,
          query: {'limit': 100},
        );
        debugPrint(
          "[RestaurantManagement] raw getRestaurantTags response data: ${compareResponse.data}",
        );
      } catch (e) {
        debugPrint(
          "[RestaurantManagement] raw getRestaurantTags comparison failed: $e",
        );
      }

      final items = _extractDataList(response.data)
          .map(_tagFromJson)
          .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
          .toList();
      debugPrint(
        "[RestaurantManagement] menuTags parsedCount=${items.length} names=${items.map((e) => e.name).join(', ')}",
      );
      if (mounted) {
        setState(() {
          _tags
            ..clear()
            ..addAll(items);
        });
      }
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingTags = false);
    }
  }

  Future<void> _saveCategory(
    String name, {
    CategoryItem? item,
    XFile? pickedImage,
  }) async {
    try {
      showLoadingDialog(context);
      await _setToken();

      dio.MultipartFile? imageFile;
      dio.MultipartFile? categoryImageFile;
      if (pickedImage != null) {
        try {
          debugPrint("[RestaurantManagement] Enhancing image using imageEnhance endpoint...");
          final enhancedBytes = await DioClient().enhanceImageBytes(
            pickedImage.path,
            pickedImage.name,
          );
          if (enhancedBytes != null) {
            imageFile = dio.MultipartFile.fromBytes(
              enhancedBytes,
              filename: 'enhanced_${pickedImage.name}',
            );
            categoryImageFile = dio.MultipartFile.fromBytes(
              enhancedBytes,
              filename: 'enhanced_${pickedImage.name}',
            );
            debugPrint("[RestaurantManagement] Image enhanced successfully!");
          }
        } catch (e) {
          debugPrint("[RestaurantManagement] Image enhancement/compression failed: $e.");
          rethrow;
        }
      } else if (item == null) {
        imageFile = await _defaultCategoryImage();
        categoryImageFile = await _defaultCategoryImage();
      }

      final bodyMap = <String, dynamic>{
        'name_en': name,
        if (item != null) 'id': item.id,
      };

      if (imageFile != null) {
        bodyMap['image'] = imageFile;
      }
      if (categoryImageFile != null) {
        bodyMap['category_image'] = categoryImageFile;
      }

      final body = dio.FormData.fromMap(bodyMap);

      final response = await DioClient().post(
        item == null
            ? ApiEndPoints.addMenuCategory
            : ApiEndPoints.updateMenuCategory,
        body: body,
      );
      if (mounted) Get.back();
      final success = _isSuccess(response.data);
      if (mounted) {
        showToast(
          context,
          _responseMessage(
            response.data,
            success
                ? (item == null
                      ? 'Category added successfully'
                      : 'Category updated successfully')
                : 'Category action failed',
            statusCode: response.statusCode,
            showStatusCode: false,
          ),
        );
      }
      if (success) await _fetchCategories();
    } catch (error) {
      if (mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }

  Future<void> _saveTag(String name, {TagItem? item}) async {
    try {
      showLoadingDialog(context);
      await _setToken();
      final body = dio.FormData.fromMap({
        'name_en': name,
        if (item != null) 'id': item.id,
      });
      final response = await DioClient().post(
        item == null ? ApiEndPoints.addMenuTag : ApiEndPoints.updateMenuTag,
        body: body,
      );
      if (mounted) Get.back();
      final success = _isSuccess(response.data);
      if (mounted) {
        showToast(
          context,
          _responseMessage(
            response.data,
            success
                ? (item == null
                      ? 'Tag added successfully'
                      : 'Tag updated successfully')
                : 'Tag action failed',
            statusCode: response.statusCode,
            showStatusCode: false,
          ),
        );
      }
      if (success) await _fetchTags();
    } catch (error) {
      if (mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }

  Future<void> _deleteCategory(CategoryItem item) async {
    try {
      showLoadingDialog(context);
      await _setToken();
      final response = await DioClient().get(
        ApiEndPoints.deleteMenuCategory,
        query: {'id': item.id},
      );
      if (mounted) Get.back();
      final success = _isSuccess(response.data);
      if (mounted) {
        showToast(
          context,
          _responseMessage(
            response.data,
            success
                ? 'Category deleted successfully'
                : 'Category delete failed',
            statusCode: response.statusCode,
            showStatusCode: false,
          ),
        );
      }
      if (success) await _fetchCategories();
    } catch (error) {
      if (mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }

  Future<void> _deleteTag(TagItem item) async {
    try {
      showLoadingDialog(context);
      await _setToken();
      final response = await DioClient().get(
        ApiEndPoints.deleteMenuTag,
        query: {'id': item.id},
      );
      if (mounted) Get.back();
      final success = _isSuccess(response.data);
      if (mounted) {
        showToast(
          context,
          _responseMessage(
            response.data,
            success ? 'Tag deleted successfully' : 'Tag delete failed',
            statusCode: response.statusCode,
            showStatusCode: false,
          ),
        );
      }
      if (success) await _fetchTags();
    } catch (error) {
      if (mounted) {
        Get.back();
        showToast(context, error.toString());
      }
    }
  }

  Future<void> _updateCategoryStatus(CategoryItem item) async {
    final nextStatus = item.status == 'ACTIVE' ? 2 : 1;
    try {
      await _setToken();
      final response = await DioClient().get(
        ApiEndPoints.updateMenuCategoryStatus,
        query: {'id': item.id.toString(), 'status': nextStatus.toString()},
      );
      final success = _isSuccess(response.data);
      debugPrint(
        "[StatusUpdate] Category updating: id=${item.id}, name='${item.name}', nextStatus=$nextStatus, success=$success",
      );
      if (mounted) {
        showToast(
          context,
          _responseMessage(
            response.data,
            success ? 'Status updated successfully' : 'Status update failed',
            statusCode: response.statusCode,
            showStatusCode: false,
          ),
        );
      }
      if (success) await _fetchCategories();
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    }
  }

  Future<void> _updateTagStatus(TagItem item) async {
    final nextStatus = item.status == 'ACTIVE' ? 2 : 1;
    try {
      await _setToken();
      final response = await DioClient().get(
        ApiEndPoints.updateMenuTagStatus,
        query: {'id': item.id.toString(), 'status': nextStatus.toString()},
      );
      final success = _isSuccess(response.data);
      debugPrint(
        "[StatusUpdate] Tag updating: id=${item.id}, name='${item.name}', nextStatus=$nextStatus, success=$success",
      );
      if (mounted) {
        showToast(
          context,
          _responseMessage(
            response.data,
            success ? 'Status updated successfully' : 'Status update failed',
            statusCode: response.statusCode,
            showStatusCode: false,
          ),
        );
      }
      if (success) await _fetchTags();
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    }
  }

  Future<void> _pickAndCropCategoryImage(
    ImageSource source,
    void Function(void Function()) setDialogState,
    void Function(XFile) onImageCropped,
  ) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
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
        setDialogState(() {
          onImageCropped(XFile(cropped.path));
        });
      }
    } catch (e) {
      debugPrint("Error picking/cropping category image: $e");
    }
  }

  void _showCategoryImageSelector(
    BuildContext context,
    void Function(void Function()) setDialogState,
    void Function(XFile) onImageCropped,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "Select Image",
          style: GoogleFonts.rubik(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Choose image from gallery or camera",
          style: GoogleFonts.rubik(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _pickAndCropCategoryImage(
                ImageSource.gallery,
                setDialogState,
                onImageCropped,
              );
            },
            child: Text(
              "Gallery",
              style: GoogleFonts.rubik(color: colorPrimary, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _pickAndCropCategoryImage(
                ImageSource.camera,
                setDialogState,
                onImageCropped,
              );
            },
            child: Text(
              "Camera",
              style: GoogleFonts.rubik(color: colorPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to Add/Edit Category
  void _showCategoryDialog({CategoryItem? item}) {
    final nameCtrl = TextEditingController(text: item?.name ?? "");
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item == null ? "Add Category" : "Edit Category",
                            style: GoogleFonts.rubik(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        S.of(context).name,
                        style: GoogleFonts.rubik(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          hintText: S.of(context).enterCategoryNameHint,
                          hintStyle: GoogleFonts.rubik(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: colorPrimary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Image",
                        style: GoogleFonts.rubik(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          _showCategoryImageSelector(
                            context,
                            setDialogState,
                            (croppedFile) {
                              selectedImage = croppedFile;
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CustomPaint(
                            painter: DashedRectPainter(
                              color: Colors.blueGrey.withOpacity(0.3),
                              strokeWidth: 1.5,
                              gap: 6.0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(selectedImage!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    )
                                  : (item?.image != null &&
                                            item!.image!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: item.image!.startsWith('http')
                                                  ? item.image!
                                                  : '${ApiConfigs.IMAGE_URL}${item.image!}',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      _buildAddImagePlaceholder(),
                                            ),
                                          )
                                        : _buildAddImagePlaceholder()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: colorPrimary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.rubik(
                                  color: colorPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final text = nameCtrl.text.trim();
                                if (text.isEmpty) return;
                                Navigator.pop(context);
                                await _saveCategory(
                                  text,
                                  item: item,
                                  pickedImage: selectedImage,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Save",
                                style: GoogleFonts.rubik(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Dialog to Add/Edit Tag
  void _showTagDialog({TagItem? item}) {
    final nameCtrl = TextEditingController(text: item?.name ?? "");
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item == null ? "Add Tag" : "Edit Tag",
                        style: GoogleFonts.rubik(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context).name,
                    style: GoogleFonts.rubik(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: S.of(context).enterTagNameHint,
                      hintStyle: GoogleFonts.rubik(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: colorPrimary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: colorPrimary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.rubik(
                              color: colorPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final text = nameCtrl.text.trim();
                            if (text.isEmpty) return;
                            Navigator.pop(context);
                            await _saveTag(text, item: item);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: Text(
                            "Save",
                            style: GoogleFonts.rubik(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Confirm delete dialog for Category
  void _showDeleteCategoryDialog(CategoryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Delete Category",
            style: GoogleFonts.rubik(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete category \"${item.name}\"?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.rubik(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteCategory(item);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Delete",
                style: GoogleFonts.rubik(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Confirm delete dialog for Tag
  void _showDeleteTagDialog(TagItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Delete Tag",
            style: GoogleFonts.rubik(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete tag \"${item.name}\"?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.rubik(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTag(item);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Delete",
                style: GoogleFonts.rubik(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Restaurant Managment",
          style: GoogleFonts.rubik(
            color: const Color(0xFF333E63),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Background soft curves
          Positioned(
            top: -200,
            left: -100,
            right: -100,
            child: Container(
              height: 400,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2E2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              // Custom Tab Segmented Control
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = 0;
                              _searchController.clear();
                              _searchQuery = "";
                            });
                          },
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0
                                  ? colorPrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: Center(
                              child: Text(
                                "Categories",
                                style: GoogleFonts.rubik(
                                  color: _selectedTabIndex == 0
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: _selectedTabIndex == 0
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = 1;
                              _searchController.clear();
                              _searchQuery = "";
                            });
                          },
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1
                                  ? colorPrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: Center(
                              child: Text(
                                "Tags",
                                style: GoogleFonts.rubik(
                                  color: _selectedTabIndex == 1
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: _selectedTabIndex == 1
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Header Category/Tag and Add Button Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTabIndex == 0 ? "Categories" : "Tags",
                      style: GoogleFonts.rubik(
                        color: const Color(0xFF333E63),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        if (_selectedTabIndex == 0) {
                          _showCategoryDialog();
                        } else {
                          _showTagDialog();
                        }
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: colorPrimary,
                      ),
                      label: Text(
                        _selectedTabIndex == 0 ? "Add Category" : "Add Tag",
                        style: GoogleFonts.rubik(
                          color: colorPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFFFD4C6),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Search Input Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: _selectedTabIndex == 0
                          ? "Search Category"
                          : "Search Tag Name",
                      hintStyle: GoogleFonts.rubik(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: colorPrimary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Lists View
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _selectedTabIndex == 0
                      ? _buildCategoriesList()
                      : _buildTagsList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Categories Listing UI builder
  Widget _buildCategoriesList() {
    if (_isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(color: colorPrimary),
      );
    }
    final list = _filteredCategories;
    if (list.isEmpty) {
      return Center(
        child: Text(
          "No categories found",
          style: GoogleFonts.rubik(color: Colors.grey[500], fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (context, idx) {
        final item = list[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.image != null && item.image!.isNotEmpty
                    ? CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl: item.image!.startsWith('http')
                            ? item.image!
                            : '${ApiConfigs.IMAGE_URL}${item.image!}',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Image.asset(
                          'lib/assets/images/nodata.png',
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'lib/assets/images/nodata.png',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.rubik(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333E63),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.date,
                            style: GoogleFonts.rubik(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Status Capsule
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.status == "ACTIVE"
                                ? const Color(0xFFC5F4D3)
                                : const Color(0xffFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.status,
                            style: GoogleFonts.rubik(
                              color: item.status == "ACTIVE"
                                  ? const Color(0xFF008318)
                                  : const Color(0xffEF4444),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Custom Popup Menu popover
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          child: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                          color: const Color(0xFFECEFF1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          onSelected: (val) {
                            if (val == "edit") {
                              _showCategoryDialog(item: item);
                            } else if (val == "delete") {
                              _showDeleteCategoryDialog(item);
                            } else if (val == "status") {
                              _updateCategoryStatus(item);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "edit",
                              height: 40,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: Colors.grey[700],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Edit",
                                      style: GoogleFonts.rubik(
                                        color: Colors.grey[800],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey[500],
                                    size: 8,
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            PopupMenuItem(
                              value: "delete",
                              height: 40,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.grey[700],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Delete",
                                      style: GoogleFonts.rubik(
                                        color: Colors.grey[800],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey[500],
                                    size: 8,
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            PopupMenuItem(
                              value: "status",
                              height: 40,
                              child: Row(
                                children: [
                                  Icon(
                                    item.status == "ACTIVE"
                                        ? Icons.cancel_outlined
                                        : Icons.check_circle_outline,
                                    color: item.status == "ACTIVE"
                                        ? Colors.red[400]
                                        : Colors.green[600],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Update Status",
                                      style: GoogleFonts.rubik(
                                        color: Colors.grey[800],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Tags Listing UI builder
  Widget _buildTagsList() {
    if (_isLoadingTags) {
      return const Center(
        child: CircularProgressIndicator(color: colorPrimary),
      );
    }
    final list = _filteredTags;
    if (list.isEmpty) {
      return Center(
        child: Text(
          "No tags found",
          style: GoogleFonts.rubik(color: Colors.grey[500], fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (context, idx) {
        final item = list[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.rubik(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333E63),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.date,
                            style: GoogleFonts.rubik(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Status Capsule
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.status == "ACTIVE"
                                ? const Color(0xFFC5F4D3)
                                : const Color(0xffFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.status,
                            style: GoogleFonts.rubik(
                              color: item.status == "ACTIVE"
                                  ? const Color(0xFF008318)
                                  : const Color(0xffEF4444),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Custom Popup Menu popover
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          child: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                          color: const Color(0xFFECEFF1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          onSelected: (val) {
                            if (val == "edit") {
                              _showTagDialog(item: item);
                            } else if (val == "delete") {
                              _showDeleteTagDialog(item);
                            } else if (val == "status") {
                              _updateTagStatus(item);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "edit",
                              height: 40,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: Colors.grey[700],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Edit",
                                      style: GoogleFonts.rubik(
                                        color: Colors.grey[800],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey[500],
                                    size: 8,
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            PopupMenuItem(
                              value: "delete",
                              height: 40,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.grey[700],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Delete",
                                      style: GoogleFonts.rubik(
                                        color: Colors.grey[800],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey[500],
                                    size: 8,
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            PopupMenuItem(
                              value: "status",
                              height: 40,
                              child: Row(
                                children: [
                                  Icon(
                                    item.status == "ACTIVE"
                                        ? Icons.cancel_outlined
                                        : Icons.check_circle_outline,
                                    color: item.status == "ACTIVE"
                                        ? Colors.red[400]
                                        : Colors.green[600],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Update Status",
                                      style: GoogleFonts.rubik(
                                        color: Colors.grey[800],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD4C6)),
          ),
          child: const Icon(Icons.add, color: colorPrimary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          "Add Image",
          style: GoogleFonts.rubik(
            color: Colors.blueGrey.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(10),
        ),
      );

    final Path dashedPath = _dashPath(
      path,
      dashArray: CircularIntervalList<double>([gap, gap]),
    );

    canvas.drawPath(dashedPath, paint);
  }

  Path _dashPath(
    Path source, {
    required CircularIntervalList<double> dashArray,
  }) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray.next;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CircularIntervalList<T> {
  CircularIntervalList(this._vals);
  final List<T> _vals;
  int _idx = 0;
  T get next {
    if (_idx >= _vals.length) {
      _idx = 0;
    }
    return _vals[_idx++];
  }
}
