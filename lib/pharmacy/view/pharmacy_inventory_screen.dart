import 'package:saimpex_vendor/utils/widgets/product_visibility.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_add_product_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_inventory_details_screen.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';

enum _StockStatus { inStock, lowStock, outOfStock }

class _InventorySummary {
  const _InventorySummary({
    this.totalMedicines = 0,
    this.lowStock = 0,
    this.outOfStock = 0,
    this.expiringSoon = 0,
  });

  final int totalMedicines;
  final int lowStock;
  final int outOfStock;
  final int expiringSoon;

  factory _InventorySummary.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val is num) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return _InventorySummary(
      totalMedicines: toInt(json['total_medicines']),
      lowStock: toInt(json['low_stock']),
      outOfStock: toInt(json['out_of_stock']),
      expiringSoon: toInt(json['expiring_soon']),
    );
  }
}

class _InventoryItem {
  _InventoryItem({
    required this.id,
    required this.name,
    required this.subtitle,
    this.asPill = false,
    required this.price,
    required this.originalPrice,
    required this.boxes,
    required this.status,
    required this.image,
    this.images = const [],
    this.unitName,
    this.stockLabel,
    this.availableStatus,
    this.dosage,
    this.categoryName,
    this.expiryDate,
    this.barcode,
    this.rawJson,
  });

  final String id;
  final String name;
  final String subtitle;
  final bool asPill;
  final String price;
  final String originalPrice;
  int boxes;
  _StockStatus status;
  final String image;
  final List<String> images;
  final String? unitName;
  final String? stockLabel;
  int? availableStatus;
  final String? dosage;
  final String? categoryName;
  final String? expiryDate;
  final String? barcode;
  final Map<String, dynamic>? rawJson;

  factory _InventoryItem.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name =
        json['menu_name_en']?.toString() ?? json['menu_name']?.toString() ?? '';
    String formName = json['form_name']?.toString() ?? json['form']?.toString() ?? '';
    if (formName.isEmpty) {
      switch (json['form_id']?.toString()) {
        case '1':
          formName = 'Capsule';
          break;
        case '2':
          formName = 'Tablet';
          break;
        case '3':
          formName = 'Syrup';
          break;
        case '4':
          formName = 'Device';
          break;
        default:
          formName = json['attribute_value']?.toString() ?? '';
      }
    }
    final subtitle = formName.isNotEmpty
        ? formName
        : (json['category_name']?.toString() ?? '');

    final rawDiscount = json['discount_price'] ?? json['offer_price'];
    final rawPrice = json['price'] ?? json['selling_price'] ?? json['mrp_amount'] ?? json['mrp'];

    final showingPrice = (rawDiscount != null && rawDiscount.toString().trim().isNotEmpty)
        ? rawDiscount
        : rawPrice;
    final priceStr = showingPrice != null ? '$showingPrice MRU' : '';

    String originalPriceStr = '';
    if (rawPrice != null &&
        rawPrice.toString().trim().isNotEmpty &&
        rawDiscount != null &&
        rawDiscount.toString().trim().isNotEmpty) {
      final numPrice = num.tryParse(rawPrice.toString());
      final numDiscount = num.tryParse(rawDiscount.toString());
      if (numPrice != null && numDiscount != null) {
        if (numPrice > numDiscount) {
          originalPriceStr = '$rawPrice MRU';
        }
      } else if (rawPrice.toString() != rawDiscount.toString()) {
        originalPriceStr = '$rawPrice MRU';
      }
    }

    final stockInt = (json['stock'] is num)
        ? (json['stock'] as num).toInt()
        : int.tryParse(json['stock']?.toString() ?? '0') ?? 0;

    final stockStatusStr = (json['stock_status']?.toString() ?? '')
        .toLowerCase()
        .trim();
    final availStatus = (json['available_status'] is num)
        ? (json['available_status'] as num).toInt()
        : int.tryParse(json['available_status']?.toString() ?? '1') ?? 1;

    final lowStockAlert = (json['low_stock_alert'] is num)
        ? (json['low_stock_alert'] as num).toInt()
        : int.tryParse(json['low_stock_alert']?.toString() ?? '0') ?? 0;

    _StockStatus status;
    if (stockStatusStr == 'out of stock' ||
        stockStatusStr == 'out_of_stock' ||
        availStatus == 2 ||
        stockInt <= 0) {
      status = _StockStatus.outOfStock;
    } else if (stockStatusStr == 'low stock' ||
        stockStatusStr == 'low_stock' ||
        (lowStockAlert > 0 && stockInt <= lowStockAlert)) {
      status = _StockStatus.lowStock;
    } else {
      status = _StockStatus.inStock;
    }

    final List<String> allImages = [];
    final mainImage = json['menu_image']?.toString().trim();
    if (mainImage != null && mainImage.isNotEmpty) {
      allImages.add(mainImage);
    }
    if (json['images'] is List) {
      for (final im in (json['images'] as List)) {
        final path = im is Map ? im['image']?.toString().trim() : im?.toString().trim();
        if (path != null && path.isNotEmpty && !allImages.contains(path)) {
          allImages.add(path);
        }
      }
    }
    if (json['image_items'] is List) {
      for (final im in (json['image_items'] as List)) {
        final path = im is Map ? im['image']?.toString().trim() : im?.toString().trim();
        if (path != null && path.isNotEmpty && !allImages.contains(path)) {
          allImages.add(path);
        }
      }
    }
    final rawImage = allImages.isNotEmpty
        ? allImages.first
        : (json['menu_image']?.toString() ?? '');

    return _InventoryItem(
      id: id,
      name: name,
      subtitle: subtitle,
      asPill: subtitle.isNotEmpty,
      price: priceStr,
      originalPrice: originalPriceStr,
      boxes: stockInt,
      status: status,
      image: rawImage,
      images: allImages,
      unitName:
          json['unit_name']?.toString() ??
          json['stock_unit']?.toString() ??
          json['attribute_value']?.toString() ??
          (json['unit_id']?.toString() == '1'
              ? 'Strip'
              : json['unit_id']?.toString() == '2'
                  ? 'Box'
                  : json['unit_id']?.toString() == '3'
                      ? 'Bottle'
                      : json['unit_id']?.toString() == '4'
                          ? 'Piece'
                          : ''),
      stockLabel: json['stock_label']?.toString(),
      availableStatus: availStatus,
      dosage: json['dosage']?.toString(),
      categoryName: json['category_name']?.toString() ??
          json['menu_category_name']?.toString() ??
          ((() {
            dynamic cat = json['category_id'] ?? json['menu_category_id'];
            if (cat is List && cat.isNotEmpty) cat = cat.first;
            switch (cat?.toString()) {
              case '1':
                return 'Vitamins';
              case '2':
                return 'Medical Devices';
              case '3':
                return 'Analgesics & Antipyretics';
              default:
                return null;
            }
          })()),
      expiryDate: json['expiry_date']?.toString(),
      barcode: json['barcode']?.toString(),
      rawJson: json,
    );
  }
}

class PharmacyInventoryTab extends StatefulWidget {
  const PharmacyInventoryTab({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<PharmacyInventoryTab> createState() => _PharmacyInventoryTabState();
}

class _PharmacyInventoryTabState extends State<PharmacyInventoryTab> {
  final _searchController = TextEditingController();
  int _filter = 0;
  bool _isLoading = false;
  _InventorySummary _summary = const _InventorySummary();
  List<_InventoryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInventory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final queryParams = <String, dynamic>{'limit': 50};

      debugPrint(
        "==================== GET PHARMACY MENU ITEMS ====================",
      );
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyMenuItems}");
      debugPrint("Query: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyMenuItems,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "=================================================================",
      );

      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final data = response.data['data'];
        if (data is Map) {
          final summaryMap = data['summary'];
          if (summaryMap is Map) {
            _summary = _InventorySummary.fromJson(
              Map<String, dynamic>.from(summaryMap),
            );
          }

          final menuItemsObj = data['pharmacy_menu_items'];
          List<dynamic> itemsList = [];
          if (menuItemsObj is Map && menuItemsObj['data'] is List) {
            itemsList = menuItemsObj['data'] as List;
          } else if (menuItemsObj is List) {
            itemsList = menuItemsObj;
          }

          if (mounted) {
            setState(() {
              _items = itemsList
                  .whereType<Map>()
                  .map(
                    (e) =>
                        _InventoryItem.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList();
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching pharmacy menu items: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<_InventoryItem> get _visibleItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      final matchesFilter = switch (_filter) {
        1 => item.status == _StockStatus.inStock,
        2 => item.status == _StockStatus.lowStock,
        _ => true,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;
      return item.name.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _promptUpdateStock(_InventoryItem? item) async {
    if (item == null) return;
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
        'item_id': item.id,
        'stock': quantity.toString(),
      });

      debugPrint(
        "==================== POST UPDATE PHARMACY ITEM STOCK ====================",
      );
      debugPrint("Endpoint: ${ApiEndPoints.updatePharmacyItemStock}");
      debugPrint("item_id: ${item.id}, stock: $quantity");

      final response = await DioClient().post(
        ApiEndPoints.updatePharmacyItemStock,
        body: formData,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "=========================================================================",
      );

      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final rawMsg = response.data['message'];
        String toastMsg = 'Stock updated successfully';
        if (rawMsg is String && rawMsg.isNotEmpty) {
          toastMsg = rawMsg;
        } else if (rawMsg is Map) {
          toastMsg =
              rawMsg['message_en']?.toString() ??
              rawMsg['en']?.toString() ??
              toastMsg;
        }
        Fluttertoast.showToast(msg: toastMsg);

        if (mounted) {
          setState(() {
            item.boxes = quantity;
            if (quantity == 0) {
              item.status = _StockStatus.outOfStock;
            } else if (item.status == _StockStatus.outOfStock) {
              item.status = _StockStatus.inStock;
            }
          });
          _fetchInventory();
        }
      } else {
        final rawMsg = response.data is Map ? response.data['message'] : null;
        String errorMsg = 'Failed to update stock';
        if (rawMsg is String && rawMsg.isNotEmpty) {
          errorMsg = rawMsg;
        } else if (rawMsg is Map) {
          errorMsg =
              rawMsg['message_en']?.toString() ??
              rawMsg['en']?.toString() ??
              errorMsg;
        }
        Fluttertoast.showToast(msg: errorMsg);
      }
    } catch (e) {
      debugPrint("Error updating pharmacy item stock: $e");
      Fluttertoast.showToast(msg: 'Failed to update stock');
    }
  }

  Future<void> _toggleStock(_InventoryItem item, {bool? markAvailable}) async {
    final shouldMarkAvailable = markAvailable ??
        (item.status == _StockStatus.outOfStock || item.availableStatus == 2);
    final targetStatus = shouldMarkAvailable ? 1 : 2;

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final queryParams = <String, dynamic>{
        'item_id': item.id,
        'available_status': targetStatus,
      };

      debugPrint(
        "==================== GET UPDATE PHARMACY ITEM AVAILABILITY STATUS ====================",
      );
      debugPrint(
        "Endpoint: ${ApiEndPoints.updatePharmacyItemAvailabilityStatus}",
      );
      debugPrint("Query: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.updatePharmacyItemAvailabilityStatus,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "======================================================================================",
      );

      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final rawMsg = response.data['message'];
        String toastMsg = targetStatus == 2
            ? 'Item marked out of stock'
            : 'Item marked available';
        if (rawMsg is String && rawMsg.isNotEmpty) {
          toastMsg = rawMsg;
        } else if (rawMsg is Map) {
          toastMsg =
              rawMsg['message_en']?.toString() ??
              rawMsg['en']?.toString() ??
              toastMsg;
        }
        Fluttertoast.showToast(msg: toastMsg);

        if (mounted) {
          setState(() {
            item.availableStatus = targetStatus;
            if (targetStatus == 1) {
              item.status = item.boxes > 0 ? _StockStatus.inStock : _StockStatus.inStock;
              if (item.boxes == 0) item.boxes = 1;
            } else {
              item.status = _StockStatus.outOfStock;
            }
          });
          _fetchInventory();
        }
      } else {
        final rawMsg = response.data is Map ? response.data['message'] : null;
        String errorMsg = 'Failed to update availability status';
        if (rawMsg is String && rawMsg.isNotEmpty) {
          errorMsg = rawMsg;
        } else if (rawMsg is Map) {
          errorMsg =
              rawMsg['message_en']?.toString() ??
              rawMsg['en']?.toString() ??
              errorMsg;
        }
        Fluttertoast.showToast(msg: errorMsg);
      }
    } catch (e) {
      debugPrint("Error updating pharmacy item availability status: $e");
      Fluttertoast.showToast(msg: 'Failed to update availability status');
    }
  }

  Future<void> _onEditProduct(_InventoryItem item) async {
    final raw = Map<String, dynamic>.from(item.rawJson ?? {});
    final initialData = <String, dynamic>{
      ...raw,
      'id': item.id,
      'item_id': item.id,
      'name': raw['name'] ?? raw['menu_name_en'] ?? item.name,
      'menu_name_en': raw['menu_name_en'] ?? item.name,
      'stock': raw['stock'] ?? item.boxes.toString(),
      'category_name': raw['category_name'] ?? item.categoryName,
      'form_name': raw['form_name'] ?? item.subtitle,
      'unit_name': raw['unit_name'] ?? item.unitName,
      'dosage': raw['dosage'] ?? item.dosage,
      'barcode': raw['barcode'] ?? item.barcode,
      'expiry_date': raw['expiry_date'] ?? item.expiryDate,
      'images': item.images.map((im) => {'image': im}).toList(),
      'menu_image': item.image.isNotEmpty ? item.image : raw['menu_image'],
    };

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PharmacyAddProductScreen(
          isEdit: true,
          initialData: initialData,
        ),
      ),
    );
    if (updated == true) {
      _fetchInventory();
    }
  }

  Future<void> _onDeleteProduct(_InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          'Delete Product',
          style: appFont('Inter', 
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF1F2937),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"?',
          style: appFont('Inter', 
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: appFont('Inter', 
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: appFont('Inter', 
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      final queryParams = <String, dynamic>{'item_id': item.id};

      debugPrint(
        "==================== GET DELETE PHARMACY MENU ITEM ====================",
      );
      debugPrint("Endpoint: ${ApiEndPoints.deletePharmacyMenuItem}");
      debugPrint("Query: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.deletePharmacyMenuItem,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "=======================================================================",
      );

      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final rawMsg = response.data['message'];
        Fluttertoast.showToast(
          msg: rawMsg is String && rawMsg.isNotEmpty
              ? rawMsg
              : 'Product deleted successfully',
        );
        _fetchInventory();
      } else {
        final rawMsg = response.data is Map ? response.data['message'] : null;
        Fluttertoast.showToast(
          msg: rawMsg is String && rawMsg.isNotEmpty
              ? rawMsg
              : 'Failed to delete product',
        );
      }
    } catch (e) {
      debugPrint("Error deleting pharmacy menu item: $e");
      final errorMsg = e.toString().replaceFirst('Exception: ', '').trim();
      Fluttertoast.showToast(
        msg: errorMsg.isNotEmpty ? errorMsg : 'Failed to delete product',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inStockCount = _summary.totalMedicines > 0
        ? (_summary.totalMedicines - _summary.lowStock - _summary.outOfStock)
        : _items.where((i) => i.status == _StockStatus.inStock).length;
    final lowStockCount = _summary.lowStock > 0
        ? _summary.lowStock
        : _items.where((i) => i.status == _StockStatus.lowStock).length;
    final allCount = _summary.totalMedicines > 0
        ? _summary.totalMedicines
        : _items.length;
    final lowStockItems = _items
        .where((i) => i.status == _StockStatus.lowStock)
        .toList();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF0E8), Color(0xFFFFF6F1), Color(0xFFFFF8F4)],
          stops: [0, 0.28, 1],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8),
          _InventoryHeader(onBack: widget.onBack, onRefresh: _fetchInventory),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFFFF5216),
              onRefresh: _fetchInventory,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  _StatsGrid(summary: _summary),
                  if (lowStockItems.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _LowStockAlertCard(
                      items: lowStockItems,
                      onUpdate: (item) => _promptUpdateStock(item),
                      onSeeAll: () => setState(() => _filter = 2),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _SearchField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  _FilterChips(
                    selected: _filter,
                    onSelect: (index) => setState(() => _filter = index),
                    allCount: allCount,
                    inStockCount: inStockCount < 0 ? 0 : inStockCount,
                    lowStockCount: lowStockCount,
                  ),
                  const SizedBox(height: 12),
                  _CategoryRow(onRefresh: _fetchInventory),
                  const SizedBox(height: 14),
                  if (_isLoading && _items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF5216),
                        ),
                      ),
                    )
                  else if (_visibleItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No medicines found',
                          style: appFont('Inter', 
                            color: const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    for (final item in _visibleItems) ...[
                      _ProductCard(
                        item: item,
                        onToggleStock: (markAvailable) =>
                            _toggleStock(item, markAvailable: markAvailable),
                        onUpdateStock: () => _promptUpdateStock(item),
                        onRefresh: _fetchInventory,
                        onEdit: () => _onEditProduct(item),
                        onDelete: () => _onDeleteProduct(item),
                      ),
                      // Hide / unhide (§6.21): pharmacy item rows carry menu_id.
                      if (int.tryParse(item.rawJson?['menu_id']?.toString() ?? '') case final menuId?)
                        ProductVisibilityBar(
                          key: ValueKey('vis-$menuId-${item.id}'),
                          vertical: 'pharmacy',
                          menuId: menuId,
                          initial: ProductVisibilityState.fromJson(item.rawJson),
                        ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryHeader extends StatelessWidget {
  const _InventoryHeader({this.onBack, this.onRefresh});

  final VoidCallback? onBack;
  final VoidCallback? onRefresh;

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
              LocalizationService.tr('Inventory'),
              style: appFont('Inter', 
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.2,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _HeaderButton(
                onTap: onBack,
                icon: Icons.chevron_left_rounded,
                iconSize: 26,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _HeaderButton(
                onTap: () {},
                icon: Icons.qr_code_scanner_rounded,
                iconSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, this.onTap, this.iconSize = 22});

  final IconData icon;
  final VoidCallback? onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
        child: Icon(icon, color: const Color(0xFFFF5216), size: iconSize),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.summary});

  final _InventorySummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: LocalizationService.tr('TOTAL MEDICINES'),
                value: summary.totalMedicines.toString(),
                accent: const Color(0xFFFF5216),
                icon: Icons.medication_rounded,
                iconColor: const Color(0xFFE8C4B4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: LocalizationService.tr('LOW STOCK'),
                value: summary.lowStock.toString(),
                accent: const Color(0xFFF59E0B),
                icon: Icons.warning_rounded,
                iconColor: const Color(0xFFF6D59A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: LocalizationService.tr('OUT OF STOCK'),
                value: summary.outOfStock.toString(),
                accent: const Color(0xFFBA1A1A),
                icon: Icons.block_rounded,
                iconColor: const Color(0xFFF0C4C4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: LocalizationService.tr('EXPIRING SOON'),
                value: summary.expiringSoon.toString(),
                accent: const Color(0xFF0058BE),
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFFCCDEF2),
                customIcon: const _ExpiringCalendarIcon(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
    required this.iconColor,
    this.customIcon,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  final Color iconColor;
  final Widget? customIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: appFont('Inter', 
                              color: const Color(0xFF8B919E),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              letterSpacing: 0.4,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            value,
                            style: appFont('Inter', 
                              color: const Color(0xFF0B1C30),
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    customIcon ?? Icon(icon, color: iconColor, size: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiringCalendarIcon extends StatelessWidget {
  const _ExpiringCalendarIcon();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(28, 28),
      painter: _ExpiringCalendarPainter(),
    );
  }
}

class _ExpiringCalendarPainter extends CustomPainter {
  const _ExpiringCalendarPainter();

  static const Color _blue = Color(0xFFCCDEF2);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.075;
    final paint = Paint()
      ..color = _blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bodyTop = size.height * 0.2;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        stroke / 2,
        bodyTop,
        size.width - stroke,
        size.height - bodyTop - stroke / 2,
      ),
      Radius.circular(size.width * 0.14),
    );
    canvas.drawRRect(body, paint);

    final tabWidth = size.width * 0.11;
    final tabHeight = size.height * 0.16;
    for (final left in [size.width * 0.26, size.width * 0.63]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, stroke / 2, tabWidth, tabHeight),
          Radius.circular(stroke * 0.6),
        ),
        paint,
      );
    }

    final cx = size.width / 2;
    final cy = bodyTop + (size.height - bodyTop) / 2;
    final arm = size.width * 0.16;
    canvas.drawLine(
      Offset(cx - arm, cy - arm),
      Offset(cx + arm, cy + arm),
      paint,
    );
    canvas.drawLine(
      Offset(cx + arm, cy - arm),
      Offset(cx - arm, cy + arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LowStockAlertCard extends StatelessWidget {
  const _LowStockAlertCard({required this.items, this.onUpdate, this.onSeeAll});

  final List<_InventoryItem> items;
  final ValueChanged<_InventoryItem>? onUpdate;
  final VoidCallback? onSeeAll;

  static const _amber = Color(0xFFF79009);
  static const _button = Color(0xFFFF5317);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final displayItems = items.take(2).toList();
    final remaining = items.length - displayItems.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                LocalizationService.tr('Low Stock Alert'),
                style: appFont('Inter', 
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < displayItems.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE6E8EC)),
              const SizedBox(height: 12),
            ],
            _LowStockRow(
              name: displayItems[i].name,
              stockText:
                  displayItems[i].stockLabel != null &&
                      displayItems[i].stockLabel!.isNotEmpty
                  ? '${displayItems[i].stockLabel} Left'
                  : '${displayItems[i].boxes} ${displayItems[i].unitName ?? 'Boxes'} Left',
              onUpdate: () => onUpdate?.call(displayItems[i]),
            ),
          ],
          if (remaining > 0 || onSeeAll != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE6E8EC)),
            const SizedBox(height: 12),
            Row(
              children: [
                if (remaining > 0)
                  Text(
                    '+$remaining More Products',
                    style: appFont('Inter', 
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text(
                    'See All',
                    style: appFont('Inter', 
                      color: _button,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LowStockRow extends StatelessWidget {
  const _LowStockRow({
    required this.name,
    required this.stockText,
    this.onUpdate,
  });

  final String name;
  final String stockText;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: appFont('Inter', 
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                stockText,
                style: appFont('Inter', 
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: _LowStockAlertCard._amber,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Low Stock',
              style: appFont('Inter', 
                color: _LowStockAlertCard._amber,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 34,
          child: ElevatedButton(
            onPressed: onUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: _LowStockAlertCard._button,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const StadiumBorder(),
            ),
            child: Text(
              'Update Stock',
              style: appFont('Inter', 
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StockConfirmDialog extends StatelessWidget {
  const _StockConfirmDialog({required this.markAvailable});

  final bool markAvailable;

  @override
  Widget build(BuildContext context) {
    final yesColor = markAvailable
        ? const Color(0xFF22C55E)
        : const Color(0xFFFF4D4D);
    final message = markAvailable
        ? 'Are you sure you want to mark this item as available?'
        : 'Are you sure you want to mark this item as out of stock?';
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(false),
                borderRadius: BorderRadius.circular(14),
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 18, 18),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: appFont('Inter', 
                  color: const Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                children: [
                  Expanded(
                    child: _ConfirmButton(
                      label: 'No',
                      filled: false,
                      color: const Color(0xFFFF5216),
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ConfirmButton(
                      label: 'Yes',
                      filled: true,
                      color: yesColor,
                      onTap: () => Navigator.of(context).pop(true),
                    ),
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
    const orange = Color(0xFFFF5216);
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
                    style: appFont('Inter', 
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
              style: appFont('Inter', 
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              style: appFont('Inter', 
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
                        style: appFont('Inter', 
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
                        style: appFont('Inter', 
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

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.label,
    required this.filled,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: appFont('Inter', 
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                side: BorderSide(color: color, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: appFont('Inter', 
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: appFont('Inter', 
          color: const Color(0xFF1A1A1A),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: LocalizationService.tr('Search medicines, barcode...'),
          hintStyle: appFont('Inter', 
            color: const Color(0xFFB0B7C3),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFB0B7C3),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onSelect,
    required this.allCount,
    required this.inStockCount,
    required this.lowStockCount,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final int allCount;
  final int inStockCount;
  final int lowStockCount;

  @override
  Widget build(BuildContext context) {
    final labels = [
      '${LocalizationService.tr('All')} $allCount',
      '${LocalizationService.tr('In Stock')} $inStockCount',
      '${LocalizationService.tr('Low Stock')} $lowStockCount',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == selected ? const Color(0xFFFF5216) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: i == selected
                      ? null
                      : Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  labels[i],
                  style: appFont('Inter', 
                    color: i == selected
                        ? Colors.white
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'All Categories',
                style: appFont('Inter', 
                  color: const Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PharmacyAddProductScreen(),
              ),
            );
            onRefresh?.call();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFF5216),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFFF5216)),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 38),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            'Add Item',
            style: appFont('Inter', 
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.onToggleStock,
    required this.onUpdateStock,
    this.onRefresh,
    this.onEdit,
    this.onDelete,
  });

  final _InventoryItem item;
  final void Function(bool markAvailable) onToggleStock;
  final VoidCallback onUpdateStock;
  final VoidCallback? onRefresh;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  bool get _out =>
      item.status == _StockStatus.outOfStock || item.availableStatus == 2;

  @override
  Widget build(BuildContext context) {
    final isLow = item.status == _StockStatus.lowStock;
    final stockColor = _out
        ? const Color(0xFFFF3A3A)
        : (isLow
              ? const Color(0xFFF79009)
              : const Color.fromARGB(255, 29, 169, 81));
    final stockBg = _out
        ? const Color(0xFFFFEBEB)
        : (isLow ? const Color(0xFFFFF7ED) : const Color(0xFFE9FAEF));
    final stockLabel = switch (item.status) {
      _StockStatus.inStock => 'In Stock',
      _StockStatus.lowStock => 'Low Stock',
      _StockStatus.outOfStock => 'Out Of Stock',
    };
    final actionColor = _out
        ? const Color.fromARGB(255, 29, 172, 81)
        : const Color(0xFFFF3A3A);
    final actionBorder = _out
        ? const Color.fromARGB(255, 29, 172, 81)
        : const Color(0xFFFFB5B5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildProductImage(item.image),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ID: # ${item.id}',
                                style: appFont('Inter', 
                                  color: const Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.1,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.fromLTRB(7, 4, 8, 4),
                                decoration: BoxDecoration(
                                  color: stockBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: stockColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      stockLabel,
                                      style: appFont('Inter', 
                                        color: stockColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 2),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                ),
                                child: PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  iconSize: 18,
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: Color(0xFFB0B7C3),
                                  ),
                                  tooltip: '',
                                  color: Colors.white,
                                  elevation: 4,
                                  shadowColor: Colors.black.withValues(alpha: 0.15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      onEdit?.call();
                                    } else if (val == 'delete') {
                                      onDelete?.call();
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      height: 38,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                            color: Color(0xFF374151),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Edit',
                                            style: appFont('Inter', 
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF374151),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(height: 1),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      height: 38,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 16,
                                            color: Color(0xFFEF4444),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: appFont('Inter', 
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFFEF4444),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.name,
                            style: appFont('Inter', 
                              color: const Color(0xFF1A2332),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.asPill)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF1EC),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            item.subtitle,
                                            maxLines: 1,
                                            softWrap: false,
                                            style: appFont('Inter', 
                                              color: const Color(0xFFFF5216),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                              height: 1.1,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Text(
                                        item.subtitle,
                                        style: appFont('Inter', 
                                          color: const Color(0xFF9CA3AF),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          height: 1.1,
                                        ),
                                      ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Text(
                                          item.price,
                                          style: appFont('Inter', 
                                            color: const Color(0xFF0F172A),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            height: 1,
                                          ),
                                        ),
                                        if (item.originalPrice.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            item.originalPrice,
                                            style: appFont('Inter', 
                                              color: const Color(0xFFC4C4C4),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              height: 1,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: const Color(
                                                0xFFC4C4C4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 54,
                                height: 54,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: stockColor.withValues(alpha: 0.04),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${item.boxes}',
                                      style: appFont('Inter', 
                                        color: stockColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.unitName != null &&
                                              item.unitName!.isNotEmpty
                                          ? item.unitName!
                                          : 'Boxes',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: appFont('Inter', 
                                        color: const Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              barrierColor: const Color(
                                0xFF1A1A1A,
                              ).withValues(alpha: 0.45),
                              builder: (_) =>
                                  _StockConfirmDialog(markAvailable: _out),
                            );
                            if (confirmed == true) onToggleStock(_out);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: actionColor,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: actionBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            _out ? 'Mark Available' : 'Mark Out Of Stock',
                            maxLines: 1,
                            softWrap: false,
                            style: appFont('Inter', 
                              color: actionColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: onUpdateStock,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5216),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            'Update Stock',
                            style: appFont('Inter', 
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: const Color(0xFFFFE3D9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
              ),
              child: InkWell(
                onTap: () {
                  final detailImage = item.image;

                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => PharmacyInventoryDetailsScreen(
                            itemId: item.id,
                            name: item.name,
                            image: detailImage,
                            initialImages: item.images,
                            inStock: !_out,
                            categoryName: item.categoryName,
                            formName: item.subtitle,
                          ),
                        ),
                      )
                      .then((_) {
                        onRefresh?.call();
                      });
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(23, 8, 18, 8),
                  child: Text(
                    'View Details',
                    style: appFont('Inter', 
                      color: const Color(0xFFFF5216),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.1,
                    ),
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

Widget _buildProductImage(String image) {
  if (image.isEmpty) {
    return _buildImagePlaceholder();
  }
  if (image.startsWith('lib/') || image.startsWith('assets/')) {
    return Image.asset(
      image,
      width: 86,
      height: 86,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
    );
  }
  final fullUrl = _resolveImageUrl(image);
  return Image.network(
    fullUrl,
    width: 86,
    height: 86,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
  );
}

Widget _buildImagePlaceholder() {
  return Container(
    width: 86,
    height: 86,
    decoration: BoxDecoration(
      color: const Color(0xFFFFF0E8),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Icon(
      Icons.medication_rounded,
      color: Color(0xFFFF5216),
      size: 36,
    ),
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
