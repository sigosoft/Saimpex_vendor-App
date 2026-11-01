import 'package:saimpex_vendor/water/core/water_api.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/water/controller/inventory_details_controller.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/model/inventory_product.dart';
import 'package:saimpex_vendor/water/view/inventory/add_product_view.dart';
import 'package:saimpex_vendor/water/view/inventory/edit_price_dialog.dart';
import 'package:saimpex_vendor/water/view/inventory/update_stock_dialog.dart';

class InventoryDetailsView extends StatefulWidget {
  const InventoryDetailsView({super.key, required this.product});

  final InventoryProduct product;

  static Future<void> open(BuildContext context, InventoryProduct product) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InventoryDetailsView(product: product),
      ),
    );
  }

  @override
  State<InventoryDetailsView> createState() => _InventoryDetailsViewState();
}

class _InventoryDetailsViewState extends State<InventoryDetailsView> {
  late final WaterInventoryDetailsController controller;

  InventoryProduct get product => controller.product;

  bool get isInStock => product.status != InventoryStockStatus.outOfStock;

  @override
  void initState() {
    super.initState();
    controller =
        WaterInventoryDetailsController(initialProduct: widget.product);
    final dynamic itemId = widget.product.rawId ??
        widget.product.menuId ??
        widget.product.rawJson?['id'] ??
        widget.product.id.replaceAll('#', '').trim();
    controller.fetchWaterMenuItemDetail(itemId);
  }

  Future<void> _onEditPrice() async {
    final cleanPrice = product.price
        .replaceAll('MRU', '')
        .replaceAll(',', '')
        .trim();
    final newPrice = await showEditPriceDialog(
      context,
      initialPrice: cleanPrice,
    );
    if (newPrice == null || newPrice.isEmpty || !mounted) return;
    final dynamic itemId = product.rawId ??
        product.menuId ??
        product.rawJson?['id'] ??
        product.id.replaceAll('#', '').trim();
    await controller.updateWaterMenuItemPrice(
      itemId,
      newPrice,
      context: context,
    );
  }

  Future<void> _onUpdateStock() async {
    final quantity = await showUpdateStockDialog(
      context,
      initialQuantity: product.bottles,
    );
    if (quantity == null || !mounted) return;
    final dynamic itemId = product.rawId ??
        product.menuId ??
        product.rawJson?['id'] ??
        product.id.replaceAll('#', '').trim();
    await controller.updateWaterItemStock(
      itemId,
      quantity,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WaterInventoryDetailsController>(
      init: controller,
      global: false,
      builder: (_) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
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
              stops: [0, 0.18, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _HeroImage(
                        key: ValueKey(product.images.join(',')),
                        imagePath: product.image,
                        images: product.images,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _InfoGrid(
                        availableStock: isInStock ? '${product.bottles}' : '0',
                        todayOrders: controller.todayOrders,
                        sellingPrice: product.price.contains('MRU')
                            ? product.price
                                .replaceAll('.00', '')
                                .trim()
                            : '${product.price} MRU',
                        inStock: isInStock,
                      ),
                      const SizedBox(height: 10),
                      _BarcodeCard(
                        value: (product.barcode != null &&
                                product.barcode!.trim().isNotEmpty &&
                                product.barcode != 'null')
                            ? product.barcode!.trim()
                            : (product.rawId != null
                                ? product.rawId.toString()
                                : (product.id.isNotEmpty
                                    ? product.id.replaceAll('#', '').trim()
                                    : '—')),
                      ),
                      const SizedBox(height: 14),
                      _ActionButtons(
                        onEdit: _onEditPrice,
                        onUpdateStock: _onUpdateStock,
                      ),
                      const SizedBox(height: 14),
                      _BottleReturnCard(
                        enabled: controller.returnableBottle,
                        onChanged: controller.setReturnableBottle,
                      ),
                      const SizedBox(height: 14),
                      _ProductDetailsCard(
                        category: product.categoryName,
                        unitType: product.rawJson?['unit_name']?.toString() ??
                            product.rawJson?['unit']?.toString() ??
                            product.rawJson?['unit_type']?.toString(),
                        size: product.size,
                        storage: product.rawJson?['storage']?.toString(),
                        description: product.description,
                      ),
                      if (controller.salesData != null &&
                          controller.salesData!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _SalesPerformanceCard(salesData: controller.salesData!),
                      ],
                      const SizedBox(height: 18),
                      _StockHistorySection(stockLogs: controller.stockLogs),
                    ],
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
            Text(
              S.of(context).details,
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
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

class _HeroImage extends StatefulWidget {
  const _HeroImage({
    super.key,
    this.imagePath,
    this.images = const [],
  });

  final String? imagePath;
  final List<String> images;

  @override
  State<_HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<_HeroImage> {
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

  List<String> get _resolvedImages {
    final list = <String>[];
    for (final img in widget.images) {
      final t = img.trim();
      if (t.isNotEmpty && !list.contains(t)) {
        list.add(t);
      }
    }
    if (list.isEmpty &&
        widget.imagePath != null &&
        widget.imagePath!.trim().isNotEmpty) {
      list.add(widget.imagePath!.trim());
    }
    return list;
  }

  @override
  void didUpdateWidget(covariant _HeroImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final count = _resolvedImages.length;
    if (count > 0 && _currentIndex >= count) {
      _currentIndex = 0;
    }
  }

String _resolveWaterImageUrl(String path) {
  final str = path.trim();
  if (str.isEmpty) return '';
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
    final cleanBase =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$cleanBase$str';
  }
  final cleanBase = base.endsWith('/') ? base : '$base/';
  return '$cleanBase$str';
}

  Widget _buildSingleImage(String path) {
    if (path.isEmpty) {
      return Image.asset(
        AppAssets.waterCan19L,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.water_drop,
          size: 72,
          color: AppColors.planPurple,
        ),
      );
    }
    final resolved = _resolveWaterImageUrl(path);
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return Image.network(
        resolved,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset(
          AppAssets.waterCan19L,
          fit: BoxFit.contain,
        ),
      );
    }
    return Image.asset(
      resolved,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.water_drop,
        size: 72,
        color: AppColors.planPurple,
      ),
    );
  }

  Widget _buildThumbnailImage(String path) {
    if (path.isEmpty) {
      return Container(
        color: AppColors.inventoryHeroBg,
        child: const Icon(
          Icons.water_drop,
          size: 20,
          color: AppColors.planPurple,
        ),
      );
    }
    final resolved = _resolveWaterImageUrl(path);
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          AppAssets.waterCan19L,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      resolved,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.water_drop,
        size: 20,
        color: AppColors.planPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _resolvedImages;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 210,
          decoration: BoxDecoration(
            color: AppColors.inventoryHeroBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (images.length <= 1)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildSingleImage(images.isNotEmpty ? images.first : ''),
                  )
                else ...[
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildSingleImage(images[index]),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 12,
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
                                ? AppColors.primaryOrange
                                : AppColors.primaryOrange.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = index);
                    if (_pageController.hasClients) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryOrange
                            : AppColors.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: _buildThumbnailImage(images[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({
    required this.availableStock,
    required this.todayOrders,
    required this.sellingPrice,
    required this.inStock,
  });

  final String availableStock;
  final String todayOrders;
  final String sellingPrice;
  final bool inStock;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: S.of(context).waterAvailableStock,
                value: availableStock,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoTile(
                label: S.of(context).todaysOrders,
                value: todayOrders,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: S.of(context).waterSellingPrice,
                value: sellingPrice,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatusTile(inStock: inStock),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.inStock});

  final bool inStock;

  @override
  Widget build(BuildContext context) {
    final color = inStock
        ? AppColors.inventoryAvailable
        : AppColors.inventoryOutOfStock;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).status,
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                inStock ? S.of(context).waterInStock : S.of(context).outOfStock,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarcodeCard extends StatelessWidget {
  const _BarcodeCard({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.inventorySoftCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).waterBarcode,
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({this.onEdit, this.onUpdateStock});

  final VoidCallback? onEdit;
  final VoidCallback? onUpdateStock;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: onEdit ?? () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryOrange,
                side: const BorderSide(
                  color: AppColors.primaryOrange,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                S.of(context).edit,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ),
        // Gas has no stock (updateWaterItemStock → 422).
        if (!WaterApi.isGas) ...[
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onUpdateStock ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                S.of(context).waterUpdateStock,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ),
        ],
      ],
    );
  }
}

class _BottleReturnCard extends StatelessWidget {
  const _BottleReturnCard({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.recycling_rounded,
                color: AppColors.inventoryBottleGreen,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                S.of(context).waterBottleReturnSettings,
                style: TextStyle(
                  color: AppColors.inventoryBottleGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).waterReturnableBottle,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      S.of(context).waterReturnableBottleHint,
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
              const SizedBox(width: 8),
              Switch.adaptive(
                value: enabled,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primaryOrange,
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductDetailsCard extends StatelessWidget {
  const _ProductDetailsCard({
    this.category,
    this.unitType,
    this.size,
    this.storage,
    this.description,
  });

  final String? category;
  final String? unitType;
  final String? size;
  final String? storage;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final catVal = (category != null &&
            category!.trim().isNotEmpty &&
            category != 'null')
        ? category!.trim()
        : '—';
    final unitVal = (unitType != null &&
            unitType!.trim().isNotEmpty &&
            unitType != 'null')
        ? unitType!.trim()
        : '—';
    final sizeVal =
        (size != null && size!.trim().isNotEmpty && size != 'null')
            ? size!.trim()
            : '—';
    final storageVal = (storage != null &&
            storage!.trim().isNotEmpty &&
            storage != 'null')
        ? storage!.trim()
        : '—';
    final hasDesc = description != null &&
        description!.trim().isNotEmpty &&
        description != 'null';
    final descVal =
        hasDesc ? description!.trim() : S.of(context).noDescriptionAvailable;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context).waterProductDetails,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailPair(
                      label: S.of(context).category,
                      value: catVal,
                    ),
                    const SizedBox(height: 12),
                    _DetailPair(
                      label: S.of(context).waterUnitType,
                      value: unitVal,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailPair(
                      label: S.of(context).waterSize,
                      value: sizeVal,
                    ),
                    const SizedBox(height: 12),
                    _DetailPair(
                      label: S.of(context).waterStorage,
                      value: storageVal,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            S.of(context).waterDescription,
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            descVal,
            style: TextStyle(
              color: !hasDesc
                  ? AppColors.textSecondary
                  : AppColors.textDark,
              fontWeight: FontWeight.w400,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPair extends StatelessWidget {
  const _DetailPair({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _SalesPerformanceCard extends StatelessWidget {
  const _SalesPerformanceCard({required this.salesData});

  final Map<String, dynamic> salesData;

  @override
  Widget build(BuildContext context) {
    final todaySold = salesData['today_sold']?.toString() ??
        salesData['today']?.toString() ??
        '0';
    final weekSold = salesData['week_sold']?.toString() ??
        salesData['week']?.toString() ??
        '0';
    final monthSold = salesData['month_sold']?.toString() ??
        salesData['month']?.toString() ??
        '0';
    final totalSold = salesData['total_sold']?.toString() ??
        salesData['total']?.toString() ??
        '0';
    final todayRev = salesData['today_revenue']?.toString() ??
        salesData['revenue_today']?.toString() ??
        '0 MRU';
    final weekRev = salesData['week_revenue']?.toString() ??
        salesData['revenue_week']?.toString() ??
        '0 MRU';
    final monthRev = salesData['month_revenue']?.toString() ??
        salesData['revenue_month']?.toString() ??
        '0 MRU';
    final lastSold = salesData['last_sold']?.toString() ??
        salesData['last_order_at']?.toString() ??
        '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.inventorySalesBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                color: AppColors.primaryOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.of(context).waterSalesPerformance,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
              ),
              Text(
                S.of(context).waterLastSold(lastSold),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SalesStat(label: S.of(context).today, value: todaySold)),
              Expanded(child: _SalesStat(label: S.of(context).waterWeek, value: weekSold)),
              Expanded(child: _SalesStat(label: S.of(context).waterMonth, value: monthSold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    S.of(context).waterTotalSoldAllTime,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  totalSold,
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            S.of(context).waterRevenueSummary,
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _RevenueStat(label: S.of(context).today, value: todayRev),
              ),
              Expanded(
                child: _RevenueStat(label: S.of(context).waterWeek, value: weekRev),
              ),
              Expanded(
                child: _RevenueStat(label: S.of(context).waterMonth, value: monthRev),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalesStat extends StatelessWidget {
  const _SalesStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _RevenueStat extends StatelessWidget {
  const _RevenueStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.inventoryRevenueGreen,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

class _StockHistorySection extends StatelessWidget {
  const _StockHistorySection({this.stockLogs = const []});

  final List<dynamic> stockLogs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                S.of(context).waterStockHistory,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            if (stockLogs.isNotEmpty)
              Text(
                S.of(context).viewAll,
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (stockLogs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'lib/assets/images/nodata.png',
                  height: 90,
                  width: 110,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.history_rounded,
                    size: 40,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  S.of(context).waterNoStockHistoryFound,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  S.of(context).waterNoStockRecordsYet,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < stockLogs.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildHistoryItem(stockLogs[i]),
          ],
      ],
    );
  }

  Widget _buildHistoryItem(dynamic log) {
    if (log is! Map) {
      return const SizedBox.shrink();
    }
    final map = log;
    final stockId = map['id']?.toString() ??
        map['stock_id']?.toString() ??
        map['transaction_id']?.toString() ??
        '';
    final date = map['created_at']?.toString() ??
        map['date']?.toString() ??
        map['updated_at']?.toString() ??
        '';
    final type = (map['type']?.toString() ??
            map['status']?.toString() ??
            map['action']?.toString() ??
            '')
        .toLowerCase();
    final isRemoval = type.contains('remove') ||
        type.contains('decrease') ||
        type.contains('deduct') ||
        map['is_removal'] == true ||
        (map['quantity'] != null &&
            map['quantity'].toString().startsWith('-'));
    final title = map['title']?.toString() ??
        (isRemoval
            ? S.current.waterStockRemoved
            : S.current.waterStockAdded);
    final quantityRaw = map['quantity']?.toString() ??
        map['stock']?.toString() ??
        '0';
    final quantity = quantityRaw.startsWith('+') || quantityRaw.startsWith('-')
        ? quantityRaw
        : (isRemoval ? '-$quantityRaw' : '+$quantityRaw');
    final remaining = map['remaining']?.toString() ??
        map['remaining_stock']?.toString() ??
        map['current_stock']?.toString() ??
        map['stock']?.toString() ??
        '0';

    return _HistoryCard(
      stockId: stockId.isNotEmpty ? '#$stockId' : '—',
      date: date.isNotEmpty ? date : '—',
      title: title,
      quantity: quantity,
      remaining: remaining,
      isRemoval: isRemoval,
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.stockId,
    required this.date,
    required this.title,
    required this.quantity,
    required this.remaining,
    required this.isRemoval,
  });

  final String stockId;
  final String date;
  final String title;
  final String quantity;
  final String remaining;
  final bool isRemoval;

  @override
  Widget build(BuildContext context) {
    final accent = isRemoval
        ? AppColors.inventoryOutOfStock
        : AppColors.inventoryAvailable;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                S.of(context).waterStockIdLabel(stockId),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 11.5,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isRemoval
                    ? Icons.remove_circle_outline_rounded
                    : Icons.add_circle_outline_rounded,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                S.of(context).waterQuantityLabel,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              Text(
                quantity,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
              const Spacer(),
              Text(
                S.of(context).waterRemainingLabel,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
              ),
              Text(
                remaining,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
