import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/utils.dart';

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
    return (map['name_en'] ??
            map['name'] ??
            map['title'] ??
            map['tag_name'] ??
            map['category_name'] ??
            '')
        .toString();
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
        ApiEndPoints.getRestaurantCategories,
        query: {'limit': 100},
      );
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
      if (pickedImage != null) {
        imageFile = await dio.MultipartFile.fromFile(
          pickedImage.path,
          filename: pickedImage.name,
        );
      } else if (item == null) {
        imageFile = await _defaultCategoryImage();
      }

      final bodyMap = <String, dynamic>{
        'name_en': name,
        if (item != null) 'id': item.id,
      };

      if (imageFile != null) {
        bodyMap['image'] = imageFile;
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
            showStatusCode: success,
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
            showStatusCode: success,
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
            showStatusCode: success,
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
            showStatusCode: success,
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
      if (mounted) {
        showToast(
          context,
          _responseMessage(
            response.data,
            success ? 'Status updated successfully' : 'Status update failed',
            statusCode: response.statusCode,
            showStatusCode: success,
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
      if (mounted) {
        showToast(
          context,
          _responseMessage(
            response.data,
            success ? 'Status updated successfully' : 'Status update failed',
            statusCode: response.statusCode,
            showStatusCode: success,
          ),
        );
      }
      if (success) await _fetchTags();
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    }
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
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                item == null ? "Add Category" : "Edit Category",
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333E63),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try {
                          final picker = ImagePicker();
                          final XFile? pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            setDialogState(() {
                              selectedImage = pickedFile;
                            });
                          }
                        } catch (e) {
                          debugPrint("Error picking image: $e");
                        }
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.file(
                                  File(selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (item?.image != null && item!.image!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: CachedNetworkImage(
                                        imageUrl: item.image!,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                              Icons.add_a_photo_outlined,
                                              color: colorPrimary,
                                              size: 32,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.add_a_photo_outlined,
                                      color: colorPrimary,
                                      size: 32,
                                    )),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: "Enter category name",
                        hintStyle: GoogleFonts.rubik(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: colorPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
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
                  ),
                  child: Text(
                    "Save",
                    style: GoogleFonts.rubik(color: Colors.white),
                  ),
                ),
              ],
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
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            item == null ? "Add Tag" : "Edit Tag",
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333E63),
            ),
          ),
          content: TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              hintText: "Enter tag name",
              hintStyle: GoogleFonts.rubik(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: colorPrimary),
              ),
            ),
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
              ),
              child: Text(
                "Save",
                style: GoogleFonts.rubik(color: Colors.white),
              ),
            ),
          ],
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
                    color: const Color(0xFFFFE0D8),
                    borderRadius: BorderRadius.circular(35),
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
                        imageUrl: item.image!,
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
                    const SizedBox(height: 6),
                    Text(
                      item.date,
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
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
              const SizedBox(width: 8),
              // Custom Popup Menu popover
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
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
                    const SizedBox(height: 6),
                    Text(
                      item.date,
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
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
              const SizedBox(width: 8),
              // Custom Popup Menu popover
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
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
        );
      },
    );
  }
}
