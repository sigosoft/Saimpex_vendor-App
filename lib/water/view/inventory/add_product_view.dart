import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  static Future<bool?> open(BuildContext context) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const AddProductView()),
    );
  }

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellingPriceController = TextEditingController(text: '0.00');
  final _offerPriceController = TextEditingController(text: '0.00');
  final _stockController = TextEditingController(text: '0');
  final _lowStockController = TextEditingController(text: '10');

  String _category = 'Mineral Water';
  String _bottleSize = '10L';
  bool _returnableBottle = false;

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  static const _categories = ['Mineral Water', 'Drinking Water', 'Sparkling'];
  static const _sizes = ['5L', '10L', '19L'];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _sellingPriceController.dispose();
    _offerPriceController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _nameController.clear();
      _brandController.clear();
      _barcodeController.clear();
      _descriptionController.clear();
      _sellingPriceController.text = '0.00';
      _offerPriceController.text = '0.00';
      _stockController.text = '0';
      _lowStockController.text = '10';
      _category = 'Mineral Water';
      _bottleSize = '10L';
      _returnableBottle = false;
      _selectedImages.clear();
    });
  }

  Future<void> _pickImages() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBE4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primaryOrange,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Camera',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: const Text(
                  'Take a photo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBE4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primaryOrange,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: const Text(
                  'Pick one or more images from gallery',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      if (source == ImageSource.gallery) {
        final List<XFile> pickedList = await _picker.pickMultiImage(
          imageQuality: 85,
        );
        if (pickedList.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(pickedList);
          });
        }
      } else {
        final XFile? picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (picked != null) {
          setState(() {
            _selectedImages.add(picked);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showToast(context, 'Please enter product name');
      return;
    }

    final price = _sellingPriceController.text.trim();
    if (price.isEmpty || price == '0.00' || price == '0') {
      showToast(context, 'Please enter selling price');
      return;
    }

    final stock = _stockController.text.trim();
    if (stock.isEmpty) {
      showToast(context, 'Please enter available stock');
      return;
    }

    if (_selectedImages.isEmpty) {
      showToast(context, 'Please select at least one product image');
      return;
    }

    showLoadingDialog(context);

    try {
      final token = await getSavedObject('token');
      if (token != null &&
          token.toString().isNotEmpty &&
          token.toString() != 'null') {
        DioClient().updateToken(token.toString());
      }

      final Map<String, dynamic> formMap = {
        'menu_id': '',
        'name': name,
        'price': price,
        'stock': stock,
      };

      if (_sellingPriceController.text.trim().isNotEmpty) {
        formMap['mrp'] = _sellingPriceController.text.trim();
      }
      if (_offerPriceController.text.trim().isNotEmpty &&
          _offerPriceController.text.trim() != '0.00' &&
          _offerPriceController.text.trim() != '0') {
        formMap['discount_price'] = _offerPriceController.text.trim();
        formMap['offer_price'] = _offerPriceController.text.trim();
      }
      if (_lowStockController.text.trim().isNotEmpty) {
        formMap['low_stock_alert'] = _lowStockController.text.trim();
      }
      if (_barcodeController.text.trim().isNotEmpty) {
        formMap['barcode'] = _barcodeController.text.trim();
        formMap['serial_number'] = _barcodeController.text.trim();
      }
      if (_descriptionController.text.trim().isNotEmpty) {
        formMap['description'] = _descriptionController.text.trim();
        formMap['description_en'] = _descriptionController.text.trim();
      }
      if (_brandController.text.trim().isNotEmpty) {
        formMap['brand'] = _brandController.text.trim();
      }
      formMap['category'] = _category;
      formMap['size'] = _bottleSize;
      formMap['attribute_value'] = _bottleSize;
      formMap['is_returnable'] = _returnableBottle ? '1' : '0';

      final formData = FormData.fromMap(formMap);

      for (int i = 0; i < _selectedImages.length; i++) {
        final img = _selectedImages[i];
        final filename =
            img.path.split(Platform.pathSeparator).last.split('/').last;
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(
              img.path,
              filename: filename,
            ),
          ),
        );
        if (i == 0) {
          formData.files.add(
            MapEntry(
              'image',
              await MultipartFile.fromFile(
                img.path,
                filename: filename,
              ),
            ),
          );
        }
      }

      debugPrint(
        '==================== POST ADD WATER MENU ITEM ====================',
      );
      debugPrint('Endpoint: ${ApiEndPoints.addWaterMenuItem}');
      debugPrint('Fields: $formMap');
      debugPrint('Images count: ${_selectedImages.length}');

      final response = await DioClient().post(
        ApiEndPoints.addWaterMenuItem,
        body: formData,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint(
        '==================================================================',
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
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
          ? 'Product added successfully'
          : 'Failed to add product';

      if (dataMap != null && dataMap['message'] != null) {
        final msgObj = dataMap['message'];
        if (msgObj is Map) {
          final en = msgObj['message_en'] ?? msgObj['name'];
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

      if (mounted) {
        showToast(context, message);
      }

      if (isSuccess && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      debugPrint('Error adding water menu item: $e');
      if (mounted) {
        showToast(context, 'Error adding product: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundMid,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundTop,
                AppColors.backgroundMid,
                Colors.white,
              ],
              stops: [0, 0.2, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      if (_selectedImages.isEmpty) ...[
                        const Text(
                          'Product Image',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ImageUploadCard(onTap: _pickImages),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Product Image',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_selectedImages.length} image${_selectedImages.length > 1 ? "s" : ""} selected',
                              style: const TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ImagesPreviewList(
                          images: _selectedImages,
                          onAddMore: _pickImages,
                          onRemove: (idx) {
                            setState(() => _selectedImages.removeAt(idx));
                          },
                        ),
                      ],
                      const SizedBox(height: 14),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.info_outline_rounded,
                              title: 'BASIC INFORMATION',
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(height: 14),
                            const _FieldLabel('Product Name (English)'),
                            const SizedBox(height: 6),
                            _InputField(
                              controller: _nameController,
                              hint: 'e.g. Drinking Water',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('Brand'),
                                      const SizedBox(height: 6),
                                      _InputField(
                                        controller: _brandController,
                                        hint: 'Brand Name',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('Category'),
                                      const SizedBox(height: 6),
                                      _DropdownField(
                                        value: _category,
                                        items: _categories,
                                        onChanged: (v) =>
                                            setState(() => _category = v),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const _FieldLabel('Bottle Size'),
                            const SizedBox(height: 6),
                            _DropdownField(
                              value: _bottleSize,
                              items: _sizes,
                              onChanged: (v) =>
                                  setState(() => _bottleSize = v),
                            ),
                            const SizedBox(height: 12),
                            const _FieldLabel('Barcode'),
                            const SizedBox(height: 6),
                            _InputField(
                              controller: _barcodeController,
                              hint: 'Scan or enter barcode',
                              suffix: const _BarcodeScanIcon(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Product Description'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _descriptionController,
                              hint:
                                  'Describe the source, pH level, or benefits...',
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.payments_outlined,
                              title: 'PRICING (MRU)',
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('Selling Price'),
                                      const SizedBox(height: 6),
                                      _PriceField(
                                        controller: _sellingPriceController,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('Offer Price'),
                                      const SizedBox(height: 6),
                                      _PriceField(
                                        controller: _offerPriceController,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.inventory_2_outlined,
                              title: 'INVENTORY CONTROL',
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('Available Stock'),
                                      const SizedBox(height: 6),
                                      _InputField(
                                        controller: _stockController,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('Low Stock Alert'),
                                      const SizedBox(height: 6),
                                      _InputField(
                                        controller: _lowStockController,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.recycling_rounded,
                              title: 'BOTTLE RETURN SETTINGS',
                              color: AppColors.inventoryBottleGreen,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Returnable Bottle',
                                        style: TextStyle(
                                          color: AppColors.textDark,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Enable this option if customers must return the empty bottle after delivery or self pickup',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.5,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _returnableBottle,
                                  thumbColor: const WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                  trackColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return AppColors.primaryOrange;
                                      }
                                      return const Color(0xFFE2E5E9);
                                    },
                                  ),
                                  trackOutlineColor:
                                      WidgetStateProperty.resolveWith(
                                    (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return Colors.transparent;
                                      }
                                      return const Color(0xFFC5CAD1);
                                    },
                                  ),
                                  trackOutlineWidth:
                                      const WidgetStatePropertyAll(1.2),
                                  onChanged: (v) =>
                                      setState(() => _returnableBottle = v),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _FooterBar(
                  onReset: _reset,
                  onSave: _saveProduct,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'Add Product',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primaryOrange,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageUploadCard extends StatelessWidget {
  const _ImageUploadCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: const Color(0xFFD9B8A3),
            radius: 16,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8EEF8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primaryOrange,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tap to upload image',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'PNG, JPG up to 5MB',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
          Radius.circular(radius),
        ),
      );

    // Short dashes read as a dotted border, matching the design.
    const dashWidth = 3.0;
    const dashSpace = 3.5;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _ImagesPreviewList extends StatelessWidget {
  const _ImagesPreviewList({
    required this.images,
    required this.onAddMore,
    required this.onRemove,
  });

  final List<XFile> images;
  final VoidCallback onAddMore;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == images.length) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddMore,
                borderRadius: BorderRadius.circular(14),
                child: CustomPaint(
                  foregroundPainter: _DashedBorderPainter(
                    color: const Color(0xFFD9B8A3),
                    radius: 14,
                  ),
                  child: Container(
                    width: 95,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8EEF8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: AppColors.primaryOrange,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add More',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final img = images[index];
          return Stack(
            children: [
              Container(
                width: 95,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(img.path),
                    width: 95,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onRemove(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textLabel,
        fontWeight: FontWeight.w500,
        fontSize: 12.5,
      ),
    );
  }
}

class _BarcodeScanIcon extends StatelessWidget {
  const _BarcodeScanIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _BarcodeScanIconPainter(color: AppColors.primaryOrange),
      ),
    );
  }
}

class _BarcodeScanIconPainter extends CustomPainter {
  const _BarcodeScanIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    const corner = 6.0;

    final path = Path()
      ..moveTo(0, corner)
      ..lineTo(0, 0)
      ..lineTo(corner, 0)
      ..moveTo(w - corner, 0)
      ..lineTo(w, 0)
      ..lineTo(w, corner)
      ..moveTo(w, h - corner)
      ..lineTo(w, h)
      ..lineTo(w - corner, h)
      ..moveTo(corner, h)
      ..lineTo(0, h)
      ..lineTo(0, h - corner);
    canvas.drawPath(path, stroke);

    final bars = <(double, double)>[
      (0.28, 1.6),
      (0.38, 1.0),
      (0.46, 2.0),
      (0.56, 1.0),
      (0.64, 1.8),
      (0.74, 1.0),
    ];
    final top = h * 0.28;
    final bottom = h * 0.72;
    for (final bar in bars) {
      final x = w * bar.$1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x, top, x + bar.$2, bottom),
          const Radius.circular(0.6),
        ),
        fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodeScanIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textHint,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
        suffixIcon: suffix == null
            ? null
            : UnconstrainedBox(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                ),
              ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 12 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCDCDC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCDCDC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryOrange,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.inventorySoftCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMeta,
          ),
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _InputField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar({required this.onReset, required this.onSave});

  final VoidCallback onReset;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: onReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.inventoryResetBtn,
                    foregroundColor: AppColors.textDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Product',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
