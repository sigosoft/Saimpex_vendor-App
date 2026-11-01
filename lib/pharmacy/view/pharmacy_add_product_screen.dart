import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class PharmacyAddProductScreen extends StatefulWidget {
  const PharmacyAddProductScreen({
    super.key,
    this.isEdit = false,
    this.initialData,
  });

  final bool isEdit;
  final Map<String, dynamic>? initialData;

  static const Color orange = Color(0xFFFF5216);
  static const Color ink = Color(0xFF111827);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color field = Color(0xFFF3F4F6);

  @override
  State<PharmacyAddProductScreen> createState() =>
      _PharmacyAddProductScreenState();
}

class _PharmacyAddProductScreenState extends State<PharmacyAddProductScreen> {
  final _name = TextEditingController();
  final _expiry = TextEditingController();
  final _barcode = TextEditingController();
  final _description = TextEditingController();
  final _selling = TextEditingController();
  final _offer = TextEditingController();
  final _stock = TextEditingController();
  final _lowStock = TextEditingController();

  String? _category;
  String? _form;
  String? _dosage;
  String? _unit;
  bool _prescription = false;
  final List<String> _existingImages = [];
  final List<XFile> _selectedImages = [];

  int? _itemId;
  int? _categoryId;
  int? _formId;
  int? _unitId;
  String? _initialCategory;
  String? _initialForm;
  String? _initialUnit;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialData != null) {
      final d = widget.initialData!;
      _itemId = int.tryParse(
        d['id']?.toString() ?? d['item_id']?.toString() ?? '',
      );

      dynamic rawCat = d['category_id'];
      if (rawCat == null || rawCat.toString().isEmpty) {
        final menuCat = d['menu_category_id'];
        if (menuCat is List && menuCat.isNotEmpty) {
          rawCat = menuCat.first;
        } else if (menuCat != null && menuCat is! List) {
          rawCat = menuCat;
        }
      }
      _categoryId = int.tryParse(rawCat?.toString() ?? '');

      _formId = int.tryParse(d['form_id']?.toString() ?? '');
      _unitId = int.tryParse(d['unit_id']?.toString() ?? '');

      _name.text =
          d['name']?.toString() ??
          d['menu_name_en']?.toString() ??
          d['menu_name']?.toString() ??
          '';
      _expiry.text = d['expiry_date']?.toString() ?? '';

      final rawBarcode =
          d['barcode']?.toString() ?? d['serial_number']?.toString() ?? '';
      _barcode.text =
          (rawBarcode == 'null' || rawBarcode == '-' || rawBarcode == '—')
              ? ''
              : rawBarcode;

      _description.text =
          d['description']?.toString() ??
          d['description_en']?.toString() ??
          d['form_details']?.toString() ??
          '';

      _selling.text =
          d['price']?.toString() ??
          d['mrp']?.toString() ??
          d['selling_price']?.toString() ??
          '';
      _offer.text =
          d['discount_price']?.toString() ??
          d['offer_price']?.toString() ??
          d['price']?.toString() ??
          '';
      _stock.text = d['stock']?.toString() ?? '';
      _lowStock.text = d['low_stock_alert']?.toString() ?? '';

      _category =
          d['category_name']?.toString() ??
          d['menu_category_name']?.toString() ??
          _resolveCategoryNameFromId(_categoryId);
      _initialCategory = _category;

      _form =
          d['form_name']?.toString() ??
          d['form']?.toString() ??
          _resolveFormNameFromId(_formId) ??
          d['attribute_value']?.toString();
      _initialForm = _form;

      final rawDosage = d['dosage']?.toString();
      _dosage =
          (rawDosage != null && rawDosage.isNotEmpty && rawDosage != 'null')
              ? (rawDosage.toLowerCase().endsWith('mg')
                    ? rawDosage
                    : '${rawDosage}mg')
              : null;

      _unit =
          d['unit_name']?.toString() ??
          d['stock_unit']?.toString() ??
          _resolveUnitNameFromId(_unitId) ??
          d['attribute_value']?.toString();
      _initialUnit = _unit;

      _prescription =
          d['prescription_required'] == 1 ||
          d['prescription_required'] == '1' ||
          d['prescription_required'] == true;

      void appendImg(dynamic img) {
        if (img == null) return;
        final p = (img is Map ? img['image']?.toString() : img.toString())?.trim();
        if (p != null && p.isNotEmpty && p != 'null' && !_existingImages.contains(p)) {
          _existingImages.add(p);
        }
      }

      if (d['menu_image'] != null) {
        appendImg(d['menu_image']);
      }
      if (d['images'] is List) {
        for (final img in (d['images'] as List)) {
          appendImg(img);
        }
      }
      if (d['image_items'] is List) {
        for (final img in (d['image_items'] as List)) {
          appendImg(img);
        }
      }
    } else {
      _selling.clear();
      _offer.clear();
      _stock.clear();
      _lowStock.clear();
      _form = null;
      _unit = null;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _expiry.dispose();
    _barcode.dispose();
    _description.dispose();
    _selling.dispose();
    _offer.dispose();
    _stock.dispose();
    _lowStock.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const _BarcodeScanPage()),
    );
    if (!mounted || code == null || code.isEmpty) return;
    setState(() => _barcode.text = code);
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sc) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Image Source',
                style: appFont('Inter', 
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBE4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: PharmacyAddProductScreen.orange,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Camera',
                  style: appFont('Inter', 
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                subtitle: Text(
                  'Take a new photo',
                  style: appFont('Inter', 
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                onTap: () => Navigator.of(sc).pop(ImageSource.camera),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBE4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: PharmacyAddProductScreen.orange,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Gallery',
                  style: appFont('Inter', 
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                subtitle: Text(
                  'Pick one or more images from gallery',
                  style: appFont('Inter', 
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                onTap: () => Navigator.of(sc).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      if (source == ImageSource.gallery) {
        final List<XFile> pickedList = await picker.pickMultiImage(
          imageQuality: 85,
        );
        if (pickedList.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(pickedList);
          });
        }
      } else {
        final XFile? picked = await picker.pickImage(
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

  void _reset() {
    setState(() {
      _name.clear();
      _expiry.clear();
      _barcode.clear();
      _description.clear();
      _selling.clear();
      _offer.clear();
      _stock.clear();
      _lowStock.clear();
      _category = null;
      _form = null;
      _dosage = null;
      _unit = null;
      _prescription = false;
      _existingImages.clear();
      _selectedImages.clear();
    });
  }

  String? _resolveFormNameFromId(dynamic formId) {
    switch (formId?.toString()) {
      case '1':
        return 'Capsule';
      case '2':
        return 'Tablet';
      case '3':
        return 'Syrup';
      case '4':
        return 'Device';
      default:
        return null;
    }
  }

  String? _resolveCategoryNameFromId(dynamic categoryId) {
    switch (categoryId?.toString()) {
      case '1':
        return 'Vitamins';
      case '2':
        return 'Medical Devices';
      case '3':
        return 'Analgesics & Antipyretics';
      default:
        return null;
    }
  }

  String? _resolveUnitNameFromId(dynamic unitId) {
    switch (unitId?.toString()) {
      case '1':
        return 'Strip';
      case '2':
        return 'Box';
      case '3':
        return 'Bottle';
      case '4':
        return 'Piece';
      default:
        return null;
    }
  }

  int? _resolveCategoryId(String? categoryName) {
    if (_categoryId != null &&
        _initialCategory != null &&
        categoryName?.toLowerCase() == _initialCategory?.toLowerCase()) {
      return _categoryId;
    }
    switch (categoryName?.toLowerCase()) {
      case 'analgesics & antipyretics':
      case 'antipyretics':
        return 3;
      case 'medical devices':
        return 2;
      case 'vitamins':
        return 1;
      default:
        if (_categoryId != null) return _categoryId;
        dynamic cat = widget.initialData?['category_id'];
        if (cat == null) {
          final menuCat = widget.initialData?['menu_category_id'];
          if (menuCat is List && menuCat.isNotEmpty) {
            cat = menuCat.first;
          } else if (menuCat != null && menuCat is! List) {
            cat = menuCat;
          }
        }
        return int.tryParse(cat?.toString() ?? '');
    }
  }

  int? _resolveFormId(String? formName) {
    if (_formId != null &&
        _initialForm != null &&
        formName?.toLowerCase() == _initialForm?.toLowerCase()) {
      return _formId;
    }
    switch (formName?.toLowerCase()) {
      case 'capsule':
        return 1;
      case 'tablet':
        return 2;
      case 'syrup':
        return 3;
      case 'device':
        return 4;
      default:
        return _formId ??
            int.tryParse(widget.initialData?['form_id']?.toString() ?? '');
    }
  }

  int? _resolveUnitId(String? unitName) {
    if (_unitId != null &&
        _initialUnit != null &&
        unitName?.toLowerCase() == _initialUnit?.toLowerCase()) {
      return _unitId;
    }
    switch (unitName?.toLowerCase()) {
      case 'strip':
        return 1;
      case 'box':
        return 2;
      case 'bottle':
        return 3;
      case 'piece':
        return 4;
      default:
        return _unitId ??
            int.tryParse(widget.initialData?['unit_id']?.toString() ?? '');
    }
  }

  String _formatExpiryForApi(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.contains('-')) return trimmed;
    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      if (parts.length == 3) {
        if (parts[2].length == 4) {
          final mm = parts[0].padLeft(2, '0');
          final dd = parts[1].padLeft(2, '0');
          final yyyy = parts[2];
          return '$yyyy-$mm-$dd';
        } else if (parts[0].length == 4) {
          final yyyy = parts[0];
          final mm = parts[1].padLeft(2, '0');
          final dd = parts[2].padLeft(2, '0');
          return '$yyyy-$mm-$dd';
        }
      }
    }
    return trimmed;
  }

  DioMediaType _getImageContentType(String path) {
    final ext = path.contains('.') ? path.split('.').last.toLowerCase() : '';
    if (ext == 'png') return DioMediaType('image', 'png');
    if (ext == 'webp') return DioMediaType('image', 'webp');
    if (ext == 'gif') return DioMediaType('image', 'gif');
    if (ext == 'svg') return DioMediaType('image', 'svg+xml');
    return DioMediaType('image', 'jpeg');
  }

  String _sanitizeFilename(String path) {
    String name = path.split(RegExp(r'[/\\]')).last;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    if (!['jpg', 'jpeg', 'png', 'webp', 'gif', 'svg'].contains(ext)) {
      name = '$name.jpg';
    }
    return name;
  }

  Future<void> _updateProduct() async {
    if (_isSubmitting) return;

    final itemId =
        _itemId?.toString() ??
        widget.initialData?['id']?.toString() ??
        widget.initialData?['item_id']?.toString();
    if (itemId == null || itemId.isEmpty) {
      Fluttertoast.showToast(msg: 'Item ID is missing');
      return;
    }

    dynamic categoryId =
        _resolveCategoryId(_category) ??
        _categoryId ??
        widget.initialData?['category_id'];
    if (categoryId == null) {
      final menuCat = widget.initialData?['menu_category_id'];
      if (menuCat is List && menuCat.isNotEmpty) {
        categoryId = menuCat.first;
      } else if (menuCat != null && menuCat is! List) {
        categoryId = menuCat;
      }
    }
    categoryId ??= 3;

    dynamic formId = _resolveFormId(_form);
    formId ??= _formId ?? widget.initialData?['form_id'] ?? 2;

    dynamic unitId = _resolveUnitId(_unit);
    unitId ??= _unitId ?? widget.initialData?['unit_id'] ?? 1;

    final rawDosage =
        _dosage ?? widget.initialData?['dosage']?.toString() ?? '';
    final dosageDigits = rawDosage.replaceAll(RegExp(r'[^0-9]'), '');
    final dosage = dosageDigits.isNotEmpty
        ? dosageDigits
        : (rawDosage.isNotEmpty ? rawDosage : '500');

    final expiry = _formatExpiryForApi(_expiry.text.trim());

    final prescriptionRequired = _prescription
        ? 1
        : ((widget.initialData?['prescription_required'] == 1 ||
                  widget.initialData?['prescription_required'] == '1')
              ? 1
              : 0);

    final lowStock = _lowStock.text.trim().isNotEmpty
        ? _lowStock.text.trim()
        : (widget.initialData?['low_stock_alert']?.toString() ?? '10');

    setState(() => _isSubmitting = true);

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final Map<String, dynamic> formMap = {
        'category_id': categoryId.toString(),
        'name': _name.text.trim(),
        'dosage': dosage,
        'unit_id': unitId.toString(),
        'form_id': formId.toString(),
        'barcode': _barcode.text.trim(),
        'expiry_date': expiry,
        'description': _description.text.trim(),
        'prescription_required': prescriptionRequired.toString(),
        'price': _selling.text.trim(),
        'offer_price': _offer.text.trim(),
        'stock': _stock.text.trim(),
        'low_stock_alert': lowStock.toString(),
        'item_id': itemId.toString(),
      };

      if (_selectedImages.isNotEmpty) {
        final firstImg = _selectedImages.first;
        final baseName = _sanitizeFilename(firstImg.path);
        formMap['image'] = await MultipartFile.fromFile(
          firstImg.path,
          filename: baseName,
          contentType: _getImageContentType(baseName),
        );
      }

      final formData = FormData.fromMap(formMap);

      for (int i = 1; i < _selectedImages.length; i++) {
        final img = _selectedImages[i];
        final baseName = _sanitizeFilename(img.path);
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(
              img.path,
              filename: baseName,
              contentType: _getImageContentType(baseName),
            ),
          ),
        );
      }

      debugPrint(
        "==================== POST UPDATE PHARMACY MENU ITEM ====================",
      );
      debugPrint("Endpoint: ${ApiEndPoints.updatePharmacyMenuItem}");
      debugPrint("Form fields: $formMap");
      debugPrint("New images count: ${_selectedImages.length}");
      print(
        "==================== POST UPDATE PHARMACY MENU ITEM ====================",
      );
      print("Endpoint: ${ApiEndPoints.updatePharmacyMenuItem}");
      print("Form fields: $formMap");

      final response = await DioClient().post(
        ApiEndPoints.updatePharmacyMenuItem,
        body: formData,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "========================================================================",
      );
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "========================================================================",
      );

      if (response.statusCode == 200 &&
          response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final rawMsg = response.data['message'];
        final msg = rawMsg is String && rawMsg.isNotEmpty
            ? rawMsg
            : 'Pharmacy menu item updated';
        Fluttertoast.showToast(msg: msg);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        final rawMsg = response.data is Map ? response.data['message'] : null;
        Fluttertoast.showToast(
          msg: rawMsg is String && rawMsg.isNotEmpty
              ? rawMsg
              : 'Failed to update item',
        );
      }
    } catch (e) {
      debugPrint("Error updating pharmacy menu item: $e");
      final errorMsg = e.toString().replaceFirst('Exception: ', '').trim();
      Fluttertoast.showToast(
        msg: errorMsg.isNotEmpty ? errorMsg : 'Failed to update item',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _addProduct() async {
    if (_isSubmitting) return;

    final name = _name.text.trim();
    if (name.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter product name');
      return;
    }

    if (_selectedImages.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select product image');
      return;
    }

    final categoryId = _resolveCategoryId(_category) ?? 3;
    final formId = _resolveFormId(_form) ?? 2;
    final unitId = _resolveUnitId(_unit) ?? 1;

    final rawDosage = _dosage ?? '';
    final dosageDigits = rawDosage.replaceAll(RegExp(r'[^0-9]'), '');
    final dosage = dosageDigits.isNotEmpty
        ? dosageDigits
        : (rawDosage.isNotEmpty ? rawDosage : '500');

    final expiry = _formatExpiryForApi(_expiry.text.trim());
    final prescriptionRequired = _prescription ? '1' : '0';
    final price = _selling.text.trim().isNotEmpty ? _selling.text.trim() : '0';
    final offerPrice = _offer.text.trim().isNotEmpty
        ? _offer.text.trim()
        : price;
    final stock = _stock.text.trim().isNotEmpty ? _stock.text.trim() : '0';
    final lowStock = _lowStock.text.trim().isNotEmpty
        ? _lowStock.text.trim()
        : '10';

    setState(() => _isSubmitting = true);

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final Map<String, dynamic> formMap = {
        'category_id': categoryId.toString(),
        'name': name,
        'dosage': dosage,
        'unit_id': unitId.toString(),
        'form_id': formId.toString(),
        'barcode': _barcode.text.trim(),
        'expiry_date': expiry,
        'description': _description.text.trim(),
        'prescription_required': prescriptionRequired,
        'price': price,
        'offer_price': offerPrice,
        'stock': stock,
        'low_stock_alert': lowStock,
      };

      if (_selectedImages.isNotEmpty) {
        final firstImg = _selectedImages.first;
        final baseName = _sanitizeFilename(firstImg.path);
        formMap['image'] = await MultipartFile.fromFile(
          firstImg.path,
          filename: baseName,
          contentType: _getImageContentType(baseName),
        );
      }

      final formData = FormData.fromMap(formMap);

      for (int i = 1; i < _selectedImages.length; i++) {
        final img = _selectedImages[i];
        final baseName = _sanitizeFilename(img.path);
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(
              img.path,
              filename: baseName,
              contentType: _getImageContentType(baseName),
            ),
          ),
        );
      }

      debugPrint(
        "==================== POST ADD PHARMACY MENU ITEM ====================",
      );
      debugPrint("Endpoint: ${ApiEndPoints.addPharmacyMenuItem}");
      debugPrint("Form fields: $formMap");
      debugPrint("New images count: ${_selectedImages.length}");
      print(
        "==================== POST ADD PHARMACY MENU ITEM ====================",
      );
      print("Endpoint: ${ApiEndPoints.addPharmacyMenuItem}");
      print("Form fields: $formMap");

      final response = await DioClient().post(
        ApiEndPoints.addPharmacyMenuItem,
        body: formData,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "========================================================================",
      );
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "========================================================================",
      );

      if (response.statusCode == 200 &&
          response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final rawMsg = response.data['message'];
        final msg = rawMsg is String && rawMsg.isNotEmpty
            ? rawMsg
            : 'Pharmacy menu item added';
        Fluttertoast.showToast(msg: msg);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        final rawMsg = response.data is Map ? response.data['message'] : null;
        Fluttertoast.showToast(
          msg: rawMsg is String && rawMsg.isNotEmpty
              ? rawMsg
              : 'Failed to add item',
        );
      }
    } catch (e) {
      debugPrint("Error adding pharmacy menu item: $e");
      final errorMsg = e.toString().replaceFirst('Exception: ', '').trim();
      Fluttertoast.showToast(
        msg: errorMsg.isNotEmpty ? errorMsg : 'Failed to add item',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFEBE4), Color(0xFFFFF4F0), Color(0xFFFFFFFF)],
              stops: [0, 0.22, 0.42],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(
                title: widget.isEdit ? 'Edit Product' : 'Add Product',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _FieldLabel(
                          'Product Image',
                          color: Color(0xFF4B5563),
                        ),
                        if ((_existingImages.length + _selectedImages.length) >
                            0)
                          Text(
                            '${_existingImages.length + _selectedImages.length} image${(_existingImages.length + _selectedImages.length) > 1 ? "s" : ""} selected',
                            style: appFont('Inter', 
                              color: PharmacyAddProductScreen.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_existingImages.isEmpty && _selectedImages.isEmpty)
                      _UploadBox(onTap: _pickImages)
                    else
                      _ImagesPreviewList(
                        existingImages: _existingImages,
                        images: _selectedImages,
                        onAddMore: _pickImages,
                        onRemoveExisting: (idx) {
                          setState(() => _existingImages.removeAt(idx));
                        },
                        onRemoveSelected: (idx) {
                          setState(() => _selectedImages.removeAt(idx));
                        },
                      ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      icon: Icons.info_outline,
                      title: 'BASIC INFORMATION',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _Labeled(
                                  label: 'Category',
                                  child: _SelectCategoryField(
                                    value: _category,
                                    items: [
                                      if (_category != null &&
                                          _category!.isNotEmpty &&
                                          !const [
                                            'Analgesics & Antipyretics',
                                            'Medical Devices',
                                            'Vitamins',
                                          ].contains(_category))
                                        _category!,
                                      'Analgesics & Antipyretics',
                                      'Medical Devices',
                                      'Vitamins',
                                    ],
                                    onChanged: (value) =>
                                        setState(() => _category = value),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _Labeled(
                                  label: 'Form',
                                  child: _SelectCategoryField(
                                    value: _form,
                                    items: [
                                      if (_form != null &&
                                          _form!.isNotEmpty &&
                                          !const [
                                            'Tablet',
                                            'Capsule',
                                            'Syrup',
                                            'Device',
                                          ].contains(_form))
                                        _form!,
                                      'Tablet',
                                      'Capsule',
                                      'Syrup',
                                      'Device',
                                    ],
                                    onChanged: (value) {
                                      if (value != null)
                                        setState(() => _form = value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _Labeled(
                            label: widget.isEdit
                                ? 'Medicine Name'
                                : 'Product Name (English)',
                            child: _InputField(
                              controller: _name,
                              hint: 'e.g. Paracetamol 500mg',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _Labeled(
                                  label: 'Dosage',
                                  child: _SelectCategoryField(
                                    value: _dosage,
                                    items: [
                                      if (_dosage != null &&
                                          _dosage!.isNotEmpty &&
                                          !const [
                                            '250mg',
                                            '500mg',
                                            '1000mg',
                                          ].contains(_dosage))
                                        _dosage!,
                                      '250mg',
                                      '500mg',
                                      '1000mg',
                                    ],
                                    onChanged: (value) =>
                                        setState(() => _dosage = value),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _Labeled(
                                  label: 'Unit',
                                  child: _SelectCategoryField(
                                    value: _unit,
                                    items: [
                                      if (_unit != null &&
                                          _unit!.isNotEmpty &&
                                          !const [
                                            'Strip',
                                            'Box',
                                            'Bottle',
                                            'Piece',
                                          ].contains(_unit))
                                        _unit!,
                                      'Strip',
                                      'Box',
                                      'Bottle',
                                      'Piece',
                                    ],
                                    onChanged: (value) {
                                      if (value != null)
                                        setState(() => _unit = value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _Labeled(
                            label: 'Expiry Date',
                            child: _InputField(
                              controller: _expiry,
                              hint: 'mm/dd/yyyy',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Labeled(
                            label: 'Barcode',
                            child: _InputField(
                              controller: _barcode,
                              hint: 'Scan or enter barcode',
                              trailing: _BarcodeMark(onTap: _scanBarcode),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isEdit) ...[
                      const SizedBox(height: 12),
                      _PrescriptionCard(
                        value: _prescription,
                        onChanged: (value) =>
                            setState(() => _prescription = value),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _DescriptionCard(controller: _description),
                    const SizedBox(height: 14),
                    _SectionCard(
                      image: 'lib/pharmacy/Assets/images/currency.png',
                      title: 'PRICING (MRU)',
                      child: Row(
                        children: [
                          Expanded(
                            child: _Labeled(
                              label: widget.isEdit ? 'Price' : 'Selling Price',
                              child: _PriceField(controller: _selling),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Labeled(
                              label: widget.isEdit
                                  ? 'Discount Price'
                                  : 'Offer Price',
                              child: _PriceField(controller: _offer),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      leading: const _InventoryIcon(),
                      background: const Color(0xFFFFF8F6),
                      titleColor: const Color(0xFF3F4753),
                      title: 'INVENTORY CONTROL',
                      child: widget.isEdit
                          ? _Labeled(
                              label: 'Available Stock',
                              child: _InputField(
                                controller: _stock,
                                suffix: _unit,
                                suffixColor: const Color(0xFF1F2937),
                                keyboard: TextInputType.number,
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _Labeled(
                                    label: 'Available Stock',
                                    child: _InputField(
                                      controller: _stock,
                                      suffix: _unit,
                                      suffixColor: const Color(0xFF1F2937),
                                      keyboard: TextInputType.number,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _Labeled(
                                    label: 'Low Stock Alert',
                                    child: _InputField(
                                      controller: _lowStock,
                                      keyboard: TextInputType.number,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              _BottomActions(
                isEdit: widget.isEdit,
                onReset: _reset,
                onSave: () {
                  if (widget.isEdit) {
                    _updateProduct();
                  } else {
                    _addProduct();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onReset,
    this.onSave,
    this.isEdit = false,
  });

  final VoidCallback onReset;
  final VoidCallback? onSave;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, bottom + 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isEdit
                    ? () => Navigator.of(context).maybePop()
                    : onReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF334155),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isEdit ? 'Cancel' : 'Reset',
                  style: appFont('Inter', 
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onSave ?? () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5317),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFFFF5317).withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isEdit ? 'Update' : 'Save Product',
                  style: appFont('Inter', 
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, this.title = 'Add Product'});

  final VoidCallback onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              title,
              style: appFont('Inter', 
                color: const Color(0xFF1C1D1B),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.2,
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
                    border: Border.all(color: const Color(0xFFFFE0D0)),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: PharmacyAddProductScreen.orange,
                    size: 26,
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

class _UploadBox extends StatelessWidget {
  const _UploadBox({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: const _DashedPainter(),
          child: SizedBox(
            width: double.infinity,
            height: 156,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _UploadIcon(),
                const SizedBox(height: 12),
                Text(
                  'Tap to upload image',
                  style: appFont('Inter', 
                    color: const Color(0xFF394452),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG, JPG up to 5MB',
                  style: appFont('Inter', 
                    color: const Color(0xFF8A8B98),
                    fontWeight: FontWeight.w400,
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
}

class _ImagesPreviewList extends StatelessWidget {
  const _ImagesPreviewList({
    this.existingImages = const [],
    required this.images,
    required this.onAddMore,
    required this.onRemoveSelected,
    required this.onRemoveExisting,
  });

  final List<String> existingImages;
  final List<XFile> images;
  final VoidCallback onAddMore;
  final ValueChanged<int> onRemoveSelected;
  final ValueChanged<int> onRemoveExisting;

  @override
  Widget build(BuildContext context) {
    final totalCount = existingImages.length + images.length;
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalCount + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == totalCount) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddMore,
                borderRadius: BorderRadius.circular(14),
                child: CustomPaint(
                  painter: const _DashedPainter(radius: 14),
                  child: Container(
                    width: 95,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD7E9F8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: PharmacyAddProductScreen.orange,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add More',
                          style: appFont('Inter', 
                            color: const Color(0xFF394452),
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

          final isExisting = index < existingImages.length;
          final Widget imageWidget;
          if (isExisting) {
            final netPath = existingImages[index];
            if (netPath.startsWith('lib/') || netPath.startsWith('assets/')) {
              imageWidget = Image.asset(
                netPath,
                width: 95,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.medication_rounded,
                    color: PharmacyAddProductScreen.orange,
                    size: 28,
                  ),
                ),
              );
            } else {
              imageWidget = Image.network(
                _resolveImageUrl(netPath),
                width: 95,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.medication_rounded,
                    color: PharmacyAddProductScreen.orange,
                    size: 28,
                  ),
                ),
              );
            }
          } else {
            final fileIndex = index - existingImages.length;
            final img = images[fileIndex];
            imageWidget = Image.file(
              File(img.path),
              width: 95,
              height: 110,
              fit: BoxFit.cover,
            );
          }

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
                  child: imageWidget,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    if (isExisting) {
                      onRemoveExisting(index);
                    } else {
                      onRemoveSelected(index - existingImages.length);
                    }
                  },
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

String _resolveImageUrl(String path) {
  final str = path.trim();
  if (str.startsWith('http://') || str.startsWith('https://')) {
    return str;
  }
  if (str.startsWith('//')) {
    return 'https:$str';
  }
  final base = ApiConfigs.IMAGE_URL.trim();
  final uri = Uri.tryParse(base);
  final origin = (uri != null && uri.hasScheme)
      ? '${uri.scheme}://${uri.host}'
      : 'https://dev.saimpexenterprise.com';
  if (str.startsWith('/storage/')) {
    return '$origin$str';
  }
  if (str.startsWith('storage/')) {
    return '$origin/$str';
  }
  if (str.startsWith('/')) {
    final cleanBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    return '$cleanBase$str';
  }
  final cleanBase = base.endsWith('/') ? base : '$base/';
  return '$cleanBase$str';
}

class _UploadIcon extends StatelessWidget {
  const _UploadIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFFD7E9F8),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.add_a_photo_outlined,
        color: PharmacyAddProductScreen.orange,
        size: 26,
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter({this.radius = 18});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF3C8BA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          Radius.circular(radius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 6).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    this.icon,
    this.image,
    this.leading,
    this.background = Colors.white,
    this.titleColor = const Color(0xFF3F4753),
    required this.title,
    required this.child,
  });

  final IconData? icon;
  final String? image;
  final Widget? leading;
  final Color background;
  final Color titleColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null)
                leading!
              else if (image != null)
                Image.asset(image!, width: 18, height: 18, fit: BoxFit.contain)
              else
                Icon(icon, color: PharmacyAddProductScreen.orange, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: appFont('Inter', 
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.3,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6EC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prescription Requires',
                  style: appFont('Inter', 
                    color: const Color(0xFF1C1D1B),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Customer must provide a prescription',
                  style: appFont('Inter', 
                    color: const Color(0xFF53524F),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return PharmacyAddProductScreen.orange;
              }
              return const Color(0xFFE3E2DF);
            }),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_FieldLabel(label), const SizedBox(height: 6), child],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.color = const Color(0xFF6B7280)});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: appFont('Inter', 
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 13,
        height: 1.2,
      ),
    );
  }
}

class _SelectCategoryField extends StatelessWidget {
  const _SelectCategoryField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Color(0xFFD2D8E1)),
  );

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 46),
      color: Colors.white,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<String>(
            value: item,
            height: 40,
            child: Text(
              item,
              style: appFont('Inter', 
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
      ],
      child: SizedBox(
        width: double.infinity,
        child: InputDecorator(
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFFF2F4F6),
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(14, 13, 8, 13),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF7C828F),
            ),
            suffixIconConstraints: BoxConstraints(minWidth: 28, minHeight: 18),
            border: _border,
            enabledBorder: _border,
            focusedBorder: _border,
          ),
          child: Text(
            value ?? 'Select Category',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: appFont('Inter', 
              color: value == null
                  ? const Color(0xFF7C828F)
                  : const Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  String? hint,
  String? suffix,
  Color? suffixColor,
  Widget? suffixIcon,
}) {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Color(0xFFD2D8E1)),
  );
  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF2F4F6),
    hintText: hint,
    hintStyle: appFont('Inter', 
      color: const Color(0xFF7C828F),
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    suffixText: suffix,
    suffixStyle: appFont('Inter', 
      color: suffixColor ?? const Color(0xFF9CA3AF),
      fontWeight: FontWeight.w500,
      fontSize: 13,
    ),
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 24),
    isDense: true,
    contentPadding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    disabledBorder: border,
  );
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Description',
            style: appFont('Inter', 
              color: const Color(0xFF636973),
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 112,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC5CDD9)),
            ),
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: appFont('Inter', 
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.3,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Enter Description',
                hintStyle: appFont('Inter', 
                  color: const Color(0xFF7C828F),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: appFont('Inter', 
                color: const Color(0xFF3F4753),
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.2,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
            ),
          ),
          Text(
            'MRU',
            style: appFont('Inter', 
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    this.hint,
    this.suffix,
    this.suffixColor,
    this.trailing,
    this.keyboard,
  });

  final TextEditingController controller;
  final String? hint;
  final String? suffix;
  final Color? suffixColor;
  final Widget? trailing;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 1,
      keyboardType: keyboard,
      style: appFont('Inter', 
        color: const Color(0xFF1F2937),
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.3,
      ),
      decoration: _fieldDecoration(
        hint: hint,
        suffix: suffix,
        suffixColor: suffixColor,
        suffixIcon: trailing,
      ),
    );
  }
}

class _BarcodeMark extends StatelessWidget {
  const _BarcodeMark({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const Image(
          image: AssetImage('lib/pharmacy/Assets/images/barcode.png'),
          width: 22,
          height: 22,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _BarcodeScanPage extends StatefulWidget {
  const _BarcodeScanPage();

  @override
  State<_BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<_BarcodeScanPage> {
  var _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled || !mounted) return;
    String? code;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        code = value;
        break;
      }
    }
    if (code == null) return;
    _handled = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Scan barcode',
          style: appFont('Inter', fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Camera permission is required to scan barcodes',
                    textAlign: TextAlign.center,
                    style: appFont('Inter', color: Colors.white, fontSize: 15),
                  ),
                ),
              );
            },
          ),
          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(
                  color: PharmacyAddProductScreen.orange,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Text(
              'Position the barcode within the frame',
              textAlign: TextAlign.center,
              style: appFont('Inter', color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryIcon extends StatelessWidget {
  const _InventoryIcon();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(18, 18),
      painter: _InventoryIconPainter(),
    );
  }
}

class _InventoryIconPainter extends CustomPainter {
  const _InventoryIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PharmacyAddProductScreen.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeJoin = StrokeJoin.round;
    final lid = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.06,
        size.height * 0.04,
        size.width * 0.88,
        size.height * 0.30,
      ),
      const Radius.circular(1.2),
    );
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.40,
        size.width * 0.76,
        size.height * 0.54,
      ),
      const Radius.circular(1.2),
    );
    canvas.drawRRect(lid, paint);
    canvas.drawRRect(body, paint);
    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.64),
      Offset(size.width * 0.58, size.height * 0.64),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
