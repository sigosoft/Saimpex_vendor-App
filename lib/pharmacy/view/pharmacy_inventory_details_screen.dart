import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_add_product_screen.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class PharmacyInventoryDetailsScreen extends StatefulWidget {
  const PharmacyInventoryDetailsScreen({
    super.key,
    this.itemId,
    required this.name,
    required this.image,
    this.initialImages,
    this.inStock = true,
    this.categoryName,
    this.formName,
  });

  final String? itemId;
  final String name;
  final String image;
  final List<String>? initialImages;
  final bool inStock;
  final String? categoryName;
  final String? formName;

  static const Color _orange = Color(0xFFFF5722);
  static const Color _green = Color(0xFF22C55E);

  @override
  State<PharmacyInventoryDetailsScreen> createState() =>
      _PharmacyInventoryDetailsScreenState();
}

class _PharmacyInventoryDetailsScreenState
    extends State<PharmacyInventoryDetailsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _itemData;

  @override
  void initState() {
    super.initState();
    _fetchItemDetail();
  }

  Future<void> _fetchItemDetail() async {
    if (widget.itemId == null || widget.itemId!.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final queryParams = <String, dynamic>{'item_id': widget.itemId};

      debugPrint(
        "==================== GET PHARMACY MENU ITEM DETAIL ====================",
      );
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyMenuItemDetail}");
      debugPrint("Query: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyMenuItemDetail,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "========================================================================",
      );

      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final data = response.data['data'];
        if (data is Map && data['item'] is Map) {
          if (mounted) {
            setState(() {
              _itemData = Map<String, dynamic>.from(data['item'] as Map);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching pharmacy menu item detail: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _promptUpdateStock() async {
    final id = widget.itemId ?? _itemData?['id']?.toString();
    if (id == null || id.isEmpty) return;

    final quantity = await showDialog<int>(
      context: context,
      barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
      builder: (_) => const _UpdateStockDialog(),
    );
    if (!mounted || quantity == null) return;

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final formData = FormData.fromMap({
        'item_id': id,
        'stock': quantity.toString(),
      });

      final response = await DioClient().post(
        ApiEndPoints.updatePharmacyItemStock,
        body: formData,
      );

      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final rawMsg = response.data['message'];
        Fluttertoast.showToast(
          msg: rawMsg is String && rawMsg.isNotEmpty
              ? rawMsg
              : 'Stock updated successfully',
        );
        _fetchItemDetail();
      } else {
        Fluttertoast.showToast(msg: 'Failed to update stock');
      }
    } catch (e) {
      debugPrint("Error updating stock: $e");
      Fluttertoast.showToast(msg: 'Failed to update stock');
    }
  }

  String _resolveFormName(Map<String, dynamic>? item, String? fallback) {
    if (item != null) {
      final raw = item['form_name'] ?? item['form_details'] ?? item['form'];
      if (raw != null &&
          raw.toString().trim().isNotEmpty &&
          raw.toString().trim() != '—') {
        return raw.toString().trim();
      }
      final formId = item['form_id']?.toString();
      switch (formId) {
        case '1':
          return 'Capsule';
        case '2':
          return 'Tablet';
        case '3':
          return 'Syrup';
        case '4':
          return 'Device';
      }
      final attr = item['attribute_value']?.toString().trim();
      if (attr != null && attr.isNotEmpty && attr != '—') {
        return attr;
      }
    }
    if (fallback != null && fallback.isNotEmpty && fallback != '—') {
      return fallback;
    }
    return '—';
  }

  String _resolveCategoryName(Map<String, dynamic>? item, String? fallback) {
    if (item != null) {
      final raw = item['category_name'] ?? item['menu_category_name'];
      if (raw != null &&
          raw.toString().trim().isNotEmpty &&
          raw.toString().trim() != '—') {
        return raw.toString().trim();
      }
      final catId =
          item['category_id']?.toString() ?? item['menu_id']?.toString();
      switch (catId) {
        case '1':
          return 'Vitamins';
        case '2':
          return 'Medical Devices';
        case '3':
          return (fallback != null && fallback.isNotEmpty && fallback != '—')
              ? fallback
              : 'Analgesics & Antipyretics';
      }
    }
    if (fallback != null && fallback.isNotEmpty && fallback != '—') {
      return fallback;
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final item = _itemData;

    final displayName = item != null
        ? (item['menu_name_en']?.toString() ??
              item['menu_name']?.toString() ??
              widget.name)
        : widget.name;

    final List<String> images = [];
    void appendImage(dynamic val) {
      if (val == null) return;
      if (val is Map && val['image'] != null) {
        final p = val['image'].toString().trim();
        if (p.isNotEmpty && !images.contains(p)) {
          images.add(p);
        }
      } else if (val is String && val.trim().isNotEmpty) {
        final p = val.trim();
        if (!images.contains(p)) {
          images.add(p);
        }
      }
    }

    if (item != null) {
      final menuImg = item['menu_image']?.toString().trim();
      if (menuImg != null && menuImg.isNotEmpty) {
        images.add(menuImg);
      }

      if (item['images'] is List) {
        for (final imgObj in (item['images'] as List)) {
          appendImage(imgObj);
        }
      }

      if (item['image_items'] is List) {
        for (final imgObj in (item['image_items'] as List)) {
          appendImage(imgObj);
        }
      }
    }

    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      for (final img in widget.initialImages!) {
        final trimmed = img.trim();
        if (trimmed.isNotEmpty && !images.contains(trimmed)) {
          images.add(trimmed);
        }
      }
    }

    if (images.isEmpty && widget.image.trim().isNotEmpty) {
      images.add(widget.image.trim());
    }

    final stockInt = item != null
        ? ((item['stock'] is num)
              ? (item['stock'] as num).toInt()
              : int.tryParse(item['stock']?.toString() ?? '0') ?? 0)
        : (widget.inStock ? 1 : 0);

    final availableStatus = item != null
        ? ((item['available_status'] is num)
              ? (item['available_status'] as num).toInt()
              : int.tryParse(item['available_status']?.toString() ?? '1') ?? 1)
        : (widget.inStock ? 1 : 2);

    final inStock = item != null
        ? (stockInt > 0 && availableStatus == 1)
        : widget.inStock;

    final stockValue = item != null
        ? stockInt.toString()
        : (widget.inStock ? '1' : '0');

    final priceNum = item != null
        ? (item['discount_price'] ?? item['price'] ?? '')
        : '';
    final priceValue = priceNum.toString().isNotEmpty
        ? (priceNum is num ? priceNum.toString() : priceNum.toString())
        : '0';

    final expiryDateRaw = item?['expiry_date']?.toString();
    final expiryShort = _formatExpiryShort(expiryDateRaw);
    final expiryLong = _formatExpiryLong(expiryDateRaw);

    final rawBarcode =
        item?['barcode']?.toString().trim() ??
        item?['serial_number']?.toString().trim() ??
        '';
    final hasBarcode =
        rawBarcode.isNotEmpty &&
        rawBarcode != 'null' &&
        rawBarcode != '—' &&
        rawBarcode != '-';
    final barcode = hasBarcode ? rawBarcode : '';

    final formName = _resolveFormName(item, widget.formName);

    final unitName = item != null
        ? (item['unit_name']?.toString() ??
              item['stock_unit']?.toString() ??
              item['attribute_value']?.toString() ??
              '')
        : '';

    final dosage = item != null
        ? (item['dosage'] != null && item['dosage'].toString().isNotEmpty
              ? (item['dosage'].toString().toLowerCase().endsWith('mg')
                    ? item['dosage'].toString()
                    : '${item['dosage']}mg')
              : '—')
        : '—';

    final categoryName = _resolveCategoryName(item, widget.categoryName);

    final mrpPrice = item != null && item['mrp'] != null
        ? '${item['mrp']} MRU'
        : (item != null && item['price'] != null
              ? '${item['price']} MRU'
              : '—');

    final discountPrice = item != null && item['discount_price'] != null
        ? '${item['discount_price']} MRU'
        : (item != null && item['price'] != null
              ? '${item['price']} MRU'
              : '—');

    final description =
        (item?['description'] ?? item?['description_en'])?.toString().trim() ??
        '';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top + 8),
            _DetailsHeader(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: _isLoading && item == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: PharmacyInventoryDetailsScreen._orange,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        _ProductImageCarousel(images: images),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF111827),
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SummaryGrid(
                          stock: stockValue,
                          price: priceValue,
                          expiry: expiryShort,
                          inStock: inStock,
                          unit: unitName,
                        ),
                        if (hasBarcode) ...[
                          const SizedBox(height: 10),
                          _BarcodeBlock(code: barcode),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _EditButton(
                                onTap: () async {
                                  final updated = await Navigator.of(context)
                                      .push<bool>(
                                        MaterialPageRoute<bool>(
                                          builder: (_) => PharmacyAddProductScreen(
                                            isEdit: true,
                                            initialData: {
                                              ...?_itemData,
                                              if (_itemData?['category_name'] ==
                                                      null &&
                                                  categoryName != '—')
                                                'category_name': categoryName,
                                              if (_itemData?['form_name'] ==
                                                      null &&
                                                  formName != '—')
                                                'form_name': formName,
                                              if (unitName.isNotEmpty &&
                                                  _itemData?['unit_name'] ==
                                                      null)
                                                'unit_name': unitName,
                                            },
                                          ),
                                        ),
                                      );
                                  if (updated == true) {
                                    _fetchItemDetail();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _UpdateStockButton(
                                onTap: _promptUpdateStock,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SpecCard(
                          category: categoryName,
                          form: formName,
                          dosage: dosage,
                          price: mrpPrice,
                          discountPrice: discountPrice,
                          expiryDate: expiryLong,
                          description: description,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.onBack});

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
            Text(
              'Details',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: PharmacyInventoryDetailsScreen._orange,
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

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.stock,
    required this.price,
    required this.expiry,
    required this.inStock,
    this.unit = '',
  });

  final String stock;
  final String price;
  final String expiry;
  final bool inStock;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final statusColor = inStock
        ? PharmacyInventoryDetailsScreen._green
        : const Color(0xFFFF3A3A);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Current Stock',
                child: _ValueUnit(value: stock, unit: unit),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Price',
                child: _ValueUnit(value: price, unit: 'MRU'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Expiry',
                child: Text(
                  expiry,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Status',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      inStock ? 'In Stock' : 'Out Of Stock',
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ValueUnit extends StatelessWidget {
  const _ValueUnit({required this.value, required this.unit});

  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: GoogleFonts.inter(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.1,
            ),
          ),
          if (unit.isNotEmpty)
            TextSpan(
              text: ' $unit',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 1.1,
              ),
            ),
        ],
      ),
    );
  }
}

class _BarcodeBlock extends StatelessWidget {
  const _BarcodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Barcode',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            code,
            style: GoogleFonts.inter(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: PharmacyInventoryDetailsScreen._orange,
          side: const BorderSide(
            color: PharmacyInventoryDetailsScreen._orange,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Edit',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}

class _UpdateStockButton extends StatelessWidget {
  const _UpdateStockButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: PharmacyInventoryDetailsScreen._orange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Update Stock',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  const _SpecCard({
    required this.category,
    required this.form,
    required this.dosage,
    required this.price,
    required this.discountPrice,
    required this.expiryDate,
    required this.description,
  });

  final String category;
  final String form;
  final String dosage;
  final String price;
  final String discountPrice;
  final String expiryDate;
  final String description;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Category', category),
      ('Form', form),
      ('Dosage', dosage),
      ('Price', price),
      ('Discount Price', discountPrice),
      ('Expiry Date', expiryDate),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF4E7E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: PharmacyInventoryDetailsScreen._orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Product Specifications',
                style: GoogleFonts.inter(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final row in rows) _SpecRow(label: row.$1, value: row.$2),
          if (description.isNotEmpty) ...[
            Text(
              'Description',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6E8EE)),
              ),
              child: Text(
                description,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF6E4DC)),
        ],
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard();

  static const Color _muted = Color(0xFF6B7280);
  static const Color _ink = Color(0xFF111827);
  static const Color _revenue = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                color: PharmacyInventoryDetailsScreen._orange,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sales Performance',
                  style: GoogleFonts.inter(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
              ),
              Text(
                'Last Sold: Today - 2:15 PM',
                style: GoogleFonts.inter(
                  color: _muted,
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _SaleStat(label: 'Today', value: '12'),
              ),
              Expanded(
                child: _SaleStat(label: 'Week', value: '68'),
              ),
              Expanded(
                child: _SaleStat(label: 'Month', value: '245'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  'Total Sold (All Time)',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  '3,482',
                  style: GoogleFonts.inter(
                    color: PharmacyInventoryDetailsScreen._orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Revenue Summary',
            style: GoogleFonts.inter(
              color: _ink,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _RevenueStat(label: 'Today', amount: '120 MRU'),
              ),
              Expanded(
                child: _RevenueStat(label: 'Week', amount: '680 MRU'),
              ),
              Expanded(
                child: _RevenueStat(label: 'Month', amount: '2,450 MRU'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaleStat extends StatelessWidget {
  const _SaleStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: _SalesCard._muted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: _SalesCard._ink,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _RevenueStat extends StatelessWidget {
  const _RevenueStat({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: _SalesCard._muted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: GoogleFonts.inter(
            color: _SalesCard._revenue,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Stock History',
              style: GoogleFonts.inter(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              'See All',
              style: GoogleFonts.inter(
                color: PharmacyInventoryDetailsScreen._orange,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _StockHistoryTile(
          stockId: 'STOCK ID: #927',
          date: '26 Mar, 2026, 03:59 AM',
          added: false,
          title: 'Stock Removed',
          quantity: '-50',
          remaining: '400',
        ),
        const SizedBox(height: 12),
        const _StockHistoryTile(
          stockId: 'STOCK ID: #926',
          date: '26 Mar, 2026, 03:59 AM',
          added: true,
          title: 'Stock Added',
          quantity: '+450',
          remaining: '450',
        ),
      ],
    );
  }
}

class _StockHistoryTile extends StatelessWidget {
  const _StockHistoryTile({
    required this.stockId,
    required this.date,
    required this.added,
    required this.title,
    required this.quantity,
    required this.remaining,
  });

  final String stockId;
  final String date;
  final bool added;
  final String title;
  final String quantity;
  final String remaining;

  @override
  Widget build(BuildContext context) {
    final accent = added ? const Color(0xFF22C55E) : const Color(0xFFFF3B30);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                stockId,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.4,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  added ? Icons.add : Icons.remove,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'QUANTITY',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Text(
                'REMAINING',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  quantity,
                  style: GoogleFonts.inter(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.1,
                  ),
                ),
              ),
              Text(
                remaining,
                style: GoogleFonts.inter(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpdateStockDialog extends StatefulWidget {
  const _UpdateStockDialog();

  @override
  State<_UpdateStockDialog> createState() => _UpdateStockDialogState();
}

class _UpdateStockDialogState extends State<_UpdateStockDialog> {
  final _quantity = TextEditingController();

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _quantity.text.trim();
    if (text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter quantity');
      return;
    }
    final value = int.tryParse(text);
    if (value == null || value < 0) {
      Fluttertoast.showToast(msg: 'Please enter a valid quantity');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF5722);
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Update Stock',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE3E3E3)),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF7F7F7F),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Enter Quantity',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: orange,
                        side: const BorderSide(color: orange, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Update',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatExpiryShort(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '—';
  try {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[date.month - 1];
    final y = (date.year % 100).toString().padLeft(2, '0');
    return "$m '$y";
  } catch (_) {
    return dateStr;
  }
}

String _formatExpiryLong(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '—';
  try {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final d = date.day;
    final m = months[date.month - 1];
    final y = date.year;
    return "$d $m, $y";
  } catch (_) {
    return dateStr;
  }
}

class _ProductImageCarousel extends StatefulWidget {
  const _ProductImageCarousel({required this.images});

  final List<String> images;

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ProductImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images.length != oldWidget.images.length) {
      if (_currentIndex >= widget.images.length) {
        _currentIndex = 0;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildDetailsImage(''),
      );
    }

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildDetailsImage(images.first),
      );
    }

    if (_currentIndex >= images.length) {
      _currentIndex = 0;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: 188,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return SizedBox(
                  width: double.infinity,
                  height: 188,
                  child: _buildDetailsImage(images[index]),
                );
              },
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  final isSelected = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isSelected ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF5722)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailsImage(String image) {
  if (image.isEmpty) {
    return Container(
      width: double.infinity,
      height: 188,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.medication_rounded,
        color: PharmacyInventoryDetailsScreen._orange,
        size: 54,
      ),
    );
  }
  if (image.startsWith('lib/') || image.startsWith('assets/')) {
    return Image.asset(
      image,
      width: double.infinity,
      height: 188,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildDetailsImage(''),
    );
  }
  final fullUrl = _resolveImageUrl(image);
  return Image.network(
    fullUrl,
    width: double.infinity,
    height: 188,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => _buildDetailsImage(''),
  );
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
