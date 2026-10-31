import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/water/controller/inventory_controller.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/model/inventory_product.dart';
import 'package:saimpex_vendor/water/view/chat/messages_list_view.dart';
import 'package:saimpex_vendor/water/view/inventory/add_product_view.dart';
import 'package:saimpex_vendor/water/view/inventory/edit_price_dialog.dart';
import 'package:saimpex_vendor/water/view/inventory/inventory_details_view.dart';
import 'package:saimpex_vendor/water/view/inventory/mark_out_of_stock_dialog.dart';
import 'package:saimpex_vendor/water/view/inventory/update_stock_dialog.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key, this.embedded = false});

  /// When true, used as a bottom-nav tab (no own bottom nav / back button).
  final bool embedded;

  static void open(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const InventoryView()));
  }

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  late final WaterInventoryController controller;

  @override
  void initState() {
    super.initState();
    controller = WaterInventoryController();
  }

  Future<void> _onMarkStatus(int index) async {
    final product = controller.products[index];
    final isOut = product.status == InventoryStockStatus.outOfStock;

    if (!isOut) {
      final confirmed = await showMarkOutOfStockDialog(context);
      if (!confirmed || !mounted) return;
      final dynamic menuItemId =
          product.rawId ??
          product.menuId ??
          product.rawJson?['id'] ??
          product.id.replaceAll('#', '').trim();
      await controller.updateItemStatus(
        menuItemId,
        availableStatus: 2,
        context: context,
      );
      return;
    }

    final confirmed = await showMarkAvailableDialog(context);
    if (!confirmed || !mounted) return;
    final dynamic menuItemId =
        product.rawId ??
        product.menuId ??
        product.rawJson?['id'] ??
        product.id.replaceAll('#', '').trim();
    await controller.updateItemStatus(
      menuItemId,
      availableStatus: 1,
      context: context,
    );
  }

  Future<void> _onUpdateStock(int index) async {
    final product = controller.products[index];
    final quantity = await showUpdateStockDialog(
      context,
      initialQuantity: product.bottles,
    );
    if (quantity == null || !mounted) return;
    final dynamic itemId =
        product.rawId ??
        product.menuId ??
        product.rawJson?['id'] ??
        product.id.replaceAll('#', '').trim();
    await controller.updateWaterItemStock(itemId, quantity, context: context);
  }

  Future<void> _onUpdateStockForProduct(InventoryProduct product) async {
    final quantity = await showUpdateStockDialog(
      context,
      initialQuantity: product.bottles,
    );
    if (quantity == null || !mounted) return;
    final dynamic itemId =
        product.rawId ??
        product.menuId ??
        product.rawJson?['id'] ??
        product.id.replaceAll('#', '').trim();
    await controller.updateWaterItemStock(itemId, quantity, context: context);
  }

  Future<void> _onEditProduct(int index) async {
    final product = controller.products[index];
    final cleanPrice = product.price
        .replaceAll('MRU', '')
        .replaceAll(',', '')
        .trim();
    final newPrice = await showEditPriceDialog(
      context,
      initialPrice: cleanPrice,
    );
    if (newPrice == null || newPrice.isEmpty || !mounted) return;
    final dynamic itemId =
        product.rawId ??
        product.menuId ??
        product.rawJson?['id'] ??
        product.id.replaceAll('#', '').trim();
    await controller.updateWaterMenuItemPrice(
      itemId,
      newPrice,
      context: context,
    );
  }

  Future<void> _onDeleteProduct(int index) async {
    final product = controller.products[index];
    final confirmed = await showDeleteProductDialog(
      context,
      productName: product.name,
    );
    if (!confirmed || !mounted) return;
    final dynamic itemId =
        product.rawId ??
        product.menuId ??
        product.rawJson?['id'] ??
        product.id.replaceAll('#', '').trim();
    await controller.deleteWaterMenuItem(
      itemId,
      context: context,
    );
  }

  Future<void> _onViewDetails(InventoryProduct product) async {
    await InventoryDetailsView.open(context, product);
    controller.fetchWaterMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WaterInventoryController>(
      init: controller,
      global: false,
      builder: (_) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final body = Column(
      children: [
        SizedBox(
          height: widget.embedded ? MediaQuery.paddingOf(context).top + 8 : 8,
        ),
        _Header(
          showBack: !widget.embedded,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primaryOrange,
            onRefresh: () => controller.fetchWaterMenuItems(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                _StatsGrid(summary: controller.summary),
                if (controller.lowStockProducts.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _LowStockAlertCard(
                    lowStockProducts: controller.lowStockProducts,
                    onUpdateStock: (p) => _onUpdateStockForProduct(p),
                  ),
                ],
                const SizedBox(height: 14),
                _SearchField(controller: controller.searchController),
                const SizedBox(height: 12),
                _FilterChips(
                  selectedIndex: controller.selectedFilter,
                  onSelect: controller.selectFilter,
                  allCount: controller.allCount,
                  inStockCount: controller.inStockCount,
                  lowStockCount: controller.lowStockCount,
                ),
                const SizedBox(height: 12),
                _CategoryActionsRow(
                  selectedCategory: controller.selectedCategory,
                  categories: controller.categories,
                  onSelectCategory: controller.selectCategory,
                  onAdded: () => controller.fetchWaterMenuItems(),
                ),
                const SizedBox(height: 14),
                if (controller.isLoading && controller.allProducts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  )
                else if (controller.products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'lib/assets/images/nodata.png',
                            height: 120,
                            width: 140,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            S.of(context).waterNoProductsFound,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            S.of(context).waterAddedProductsWillAppearHere,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < controller.products.length; i++) ...[
                    _ProductCard(
                      product: controller.products[i],
                      onMarkStatus: () => _onMarkStatus(i),
                      onUpdateStock: () => _onUpdateStock(i),
                      onEdit: () => _onEditProduct(i),
                      onDelete: () => _onDeleteProduct(i),
                      onViewDetails: () =>
                          _onViewDetails(controller.products[i]),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
        if (!widget.embedded)
          _InventoryBottomNav(
            onSelect: (index) {
              if (index == 3) return;
              if (index == 2) {
                MessagesListView.open(context);
                return;
              }
              Navigator.of(context).maybePop();
            },
          ),
      ],
    );

    if (widget.embedded) {
      return DecoratedBox(
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
        child: body,
      );
    }

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
          child: SafeArea(child: body),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, this.showBack = true});

  final VoidCallback onBack;
  final bool showBack;

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
              S.of(context).waterInventory,
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            if (showBack)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _HeaderIconButton(
                  onTap: onBack,
                  icon: Icons.chevron_left_rounded,
                  iconSize: 28,
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _HeaderIconButton(
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.onTap,
    required this.icon,
    this.iconSize = 22,
  });

  final VoidCallback onTap;
  final IconData icon;
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
        child: Icon(icon, color: AppColors.primaryOrange, size: iconSize),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.summary});

  final WaterInventorySummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: S.of(context).available.toUpperCase(),
                value: summary.available.toString(),
                accent: AppColors.inventoryAvailable,
                iconBg: AppColors.inventoryAvailableBg,
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: S.of(context).todaysOrders.toUpperCase(),
                value: summary.todayOrders.toString(),
                accent: AppColors.inventoryOrders,
                iconBg: AppColors.inventoryOrdersBg,
                icon: Icons.description_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: S.of(context).waterLowStock.toUpperCase(),
                value: summary.lowStock.toString(),
                accent: AppColors.inventoryLowStock,
                iconBg: AppColors.inventoryLowStockBg,
                icon: Icons.warning_amber_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: S.of(context).outOfStock.toUpperCase(),
                value: summary.outOfStock.toString(),
                accent: AppColors.inventoryOutOfStock,
                iconBg: AppColors.inventoryOutOfStockBg,
                icon: Icons.error_outline_rounded,
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
    required this.iconBg,
    required this.icon,
  });

  final String label;
  final String value;
  final Color accent;
  final Color iconBg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(width: 4, color: accent),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 9.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accent, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LowStockAlertCard extends StatelessWidget {
  const _LowStockAlertCard({
    required this.lowStockProducts,
    required this.onUpdateStock,
  });

  final List<InventoryProduct> lowStockProducts;
  final ValueChanged<InventoryProduct> onUpdateStock;

  @override
  Widget build(BuildContext context) {
    if (lowStockProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayItems = lowStockProducts.take(2).toList();
    final remainingCount = lowStockProducts.length - displayItems.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _LowStockHeaderIcon(),
              const SizedBox(width: 10),
              Text(
                S.of(context).waterLowStockAlert,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < displayItems.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.divider),
            _LowStockAlertRow(
              name: displayItems[i].name,
              remaining: displayItems[i].stockLabel.isNotEmpty
                  ? displayItems[i].stockLabel
                  : S.of(context).waterBottlesLeft(
                      displayItems[i].bottles.toString(),
                    ),
              onUpdateStock: () => onUpdateStock(displayItems[i]),
            ),
          ],
          if (remainingCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  S.of(context).waterMoreProducts(remainingCount.toString()),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    S.of(context).viewAll,
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
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

class _LowStockHeaderIcon extends StatelessWidget {
  const _LowStockHeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.inventoryLowStockBg,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.inventoryLowStock,
        size: 18,
      ),
    );
  }
}

class _LowStockAlertRow extends StatelessWidget {
  const _LowStockAlertRow({
    required this.name,
    required this.remaining,
    required this.onUpdateStock,
  });

  final String name;
  final String remaining;
  final VoidCallback onUpdateStock;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remaining,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 7, color: AppColors.inventoryLowStock),
              const SizedBox(width: 5),
              Text(
                S.of(context).waterLowStock,
                style: TextStyle(
                  color: AppColors.inventoryLowStock,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: onUpdateStock,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                S.of(context).waterUpdateStock,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textMeta, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: S.of(context).waterSearchProductsHint,
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedIndex,
    required this.onSelect,
    required this.allCount,
    required this.inStockCount,
    required this.lowStockCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final int allCount;
  final int inStockCount;
  final int lowStockCount;

  List<String> _labels(BuildContext context) => [
    S.of(context).waterFilterAllCount(allCount.toString()),
    S.of(context).waterFilterInStockCount(inStockCount.toString()),
    S.of(context).waterFilterLowStockCount(lowStockCount.toString()),
  ];

  @override
  Widget build(BuildContext context) {
    final list = _labels(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == i
                      ? AppColors.primaryOrange
                      : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selectedIndex == i
                        ? AppColors.primaryOrange
                        : AppColors.fieldBorder,
                  ),
                ),
                child: Text(
                  list[i],
                  style: TextStyle(
                    color: selectedIndex == i
                        ? Colors.white
                        : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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

class _CategoryActionsRow extends StatelessWidget {
  const _CategoryActionsRow({
    required this.selectedCategory,
    required this.categories,
    required this.onSelectCategory,
    this.onAdded,
  });

  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback? onAdded;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<String>(
            tooltip: S.of(context).waterFilterByCategory,
            offset: const Offset(0, 46),
            padding: EdgeInsets.zero,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: onSelectCategory,
            itemBuilder: (context) => categories
                .map(
                  (cat) => PopupMenuItem<String>(
                    value: cat,
                    child: Text(
                      _categoryLabel(context, cat),
                      style: TextStyle(
                        color: cat == selectedCategory
                            ? AppColors.primaryOrange
                            : AppColors.textDark,
                        fontWeight: cat == selectedCategory
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                )
                .toList(),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.inventoryCategoryBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _categoryLabel(context, selectedCategory),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMeta,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () async {
            final added = await AddProductView.open(context);
            if (added == true) {
              onAdded?.call();
            }
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.primaryOrange, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(Icons.add, color: AppColors.primaryOrange, size: 18),
                const SizedBox(width: 4),
                Text(
                  S.of(context).addItem,
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The controller uses the English 'All Categories' value as a sentinel;
/// only its displayed label is localised.
String _categoryLabel(BuildContext context, String category) =>
    category == 'All Categories' ? S.of(context).allCategories : category;

Widget _buildItemImage(String? imagePath) {
  if (imagePath == null || imagePath.trim().isEmpty) {
    return Image.asset(
      AppAssets.waterCan19L,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.water_drop, color: AppColors.inventoryOrders),
    );
  }

  final fullUrl = _resolveWaterImageUrl(imagePath);
  return Image.network(
    fullUrl,
    fit: BoxFit.contain,
    errorBuilder: (_, _, _) => Image.asset(
      AppAssets.waterCan19L,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.water_drop, color: AppColors.inventoryOrders),
    ),
  );
}

String _resolveWaterImageUrl(String path) {
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onMarkStatus,
    required this.onUpdateStock,
    required this.onEdit,
    required this.onDelete,
    this.onViewDetails,
  });

  final InventoryProduct product;
  final VoidCallback onMarkStatus;
  final VoidCallback onUpdateStock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewDetails;

  bool get _isOut => product.status == InventoryStockStatus.outOfStock;

  @override
  Widget build(BuildContext context) {
    final bool isLow = product.status == InventoryStockStatus.lowStock;
    final stockColor = _isOut
        ? const Color(0xFFFF3A3A)
        : (isLow
              ? const Color(0xFFF79009)
              : const Color.fromARGB(255, 29, 169, 81));
    final stockBg = _isOut
        ? const Color(0xFFFFEBEB)
        : (isLow ? const Color(0xFFFFF7ED) : const Color(0xFFE9FAEF));
    final stockLabel = switch (product.status) {
      InventoryStockStatus.inStock => S.of(context).waterInStock,
      InventoryStockStatus.lowStock => S.of(context).waterLowStock,
      InventoryStockStatus.outOfStock => S.of(context).outOfStock,
    };
    final actionColor = _isOut
        ? const Color.fromARGB(255, 29, 172, 81)
        : const Color(0xFFFF3A3A);
    final actionBorder = _isOut
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
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: _buildItemImage(product.image),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                S.of(context).waterIdLabel(
                                  product.id.isNotEmpty
                                      ? (product.id.startsWith('#')
                                            ? product.id
                                            : '# ${product.id}')
                                      : (product.rawId != null
                                            ? '# ${product.rawId}'
                                            : '—'),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
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
                                      style: TextStyle(
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
                                child: PopupMenuButton<_ProductMenuAction>(
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
                                  shadowColor: Colors.black.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (action) {
                                    switch (action) {
                                      case _ProductMenuAction.edit:
                                        onEdit();
                                      case _ProductMenuAction.delete:
                                        onDelete();
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: _ProductMenuAction.edit,
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
                                            S.of(context).edit,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(height: 1),
                                    PopupMenuItem(
                                      value: _ProductMenuAction.delete,
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
                                            S.of(context).delete,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFEF4444),
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
                          // const SizedBox(height: 2),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1A2332),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: 0.1,
                            ),
                          ),
                          // const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          product.price.contains('MRU')
                                              ? product.price
                                              : '${product.price} MRU',
                                          style: const TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            height: 0.1,
                                          ),
                                        ),
                                        if (product.originalPrice.isNotEmpty &&
                                            product.originalPrice != '0' &&
                                            product.originalPrice !=
                                                product.price) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            product.originalPrice.contains(
                                                  'MRU',
                                                )
                                                ? product.originalPrice
                                                : '${product.originalPrice} MRU',
                                            style: const TextStyle(
                                              color: Color(0xFFC4C4C4),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              height: 1,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: Color(
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
                                  border: Border.all(
                                    color: stockColor.withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: stockColor.withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${product.bottles}',
                                      style: TextStyle(
                                        color: stockColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      S.of(context).waterBottles,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xFF9CA3AF),
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
                          onPressed: onMarkStatus,
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
                            _isOut
                                ? S.of(context).waterMarkAvailable
                                : S.of(context).waterMarkOutOfStock,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
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
                            backgroundColor: const Color(0xFFFF5722),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            S.of(context).waterUpdateStock,
                            style: TextStyle(
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
                onTap:
                    onViewDetails ??
                    () => InventoryDetailsView.open(context, product),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(23, 8, 18, 8),
                  child: Text(
                    S.of(context).viewDetails,
                    style: TextStyle(
                      color: Color(0xFFFF5216),
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

enum _ProductMenuAction { edit, delete }

class _InventoryBottomNav extends StatelessWidget {
  const _InventoryBottomNav({required this.onSelect});

  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final labels = [
      S.of(context).home,
      S.of(context).orders,
      S.of(context).chat,
      S.of(context).waterInventory,
      S.of(context).account,
    ];
    const icons = [
      Icons.home_rounded,
      Icons.assignment_outlined,
      Icons.chat_bubble_outline_rounded,
      Icons.shopping_cart_outlined,
      Icons.person_outline_rounded,
    ];

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(5, (index) {
              final selected = index == 3;
              return Expanded(
                child: InkWell(
                  onTap: () => onSelect(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected)
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryOrange.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        )
                      else if (index == 2)
                        Image.asset(
                          'lib/home_cleaning/Assets/images/chat.png',
                          width: 24,
                          height: 24,
                          color: AppColors.navInactive,
                          colorBlendMode: BlendMode.srcIn,
                        )
                      else
                        Icon(
                          icons[index],
                          color: AppColors.navInactive,
                          size: 24,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primaryOrange
                              : AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
