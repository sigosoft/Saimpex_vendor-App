import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/water/controller/inventory_controller.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/model/inventory_product.dart';
import 'package:saimpex_vendor/water/view/chat/messages_list_view.dart';
import 'package:saimpex_vendor/water/view/inventory/add_product_view.dart';
import 'package:saimpex_vendor/water/view/inventory/inventory_details_view.dart';
import 'package:saimpex_vendor/water/view/inventory/mark_out_of_stock_dialog.dart';
import 'package:saimpex_vendor/water/view/inventory/update_stock_dialog.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key, this.embedded = false});

  /// When true, used as a bottom-nav tab (no own bottom nav / back button).
  final bool embedded;

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const InventoryView()),
    );
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
      controller.markOutOfStock(index);
      return;
    }

    final confirmed = await showMarkAvailableDialog(context);
    if (!confirmed || !mounted) return;
    controller.markAvailable(index);
  }

  Future<void> _onUpdateStock(int index) async {
    final product = controller.products[index];
    final quantity = await showUpdateStockDialog(
      context,
      initialQuantity: product.bottles,
    );
    if (quantity == null || !mounted) return;
    controller.updateQuantity(index, quantity);
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
        SizedBox(height: widget.embedded ? MediaQuery.paddingOf(context).top + 8 : 8),
        _Header(
          showBack: !widget.embedded,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              const _StatsGrid(),
              const SizedBox(height: 14),
              const _LowStockAlertCard(),
              const SizedBox(height: 14),
              const _SearchField(),
              const SizedBox(height: 12),
              _FilterChips(
                selectedIndex: controller.selectedFilter,
                onSelect: controller.selectFilter,
              ),
              const SizedBox(height: 12),
              const _CategoryActionsRow(),
              const SizedBox(height: 14),
              for (var i = 0; i < controller.products.length; i++) ...[
                _ProductCard(
                  product: controller.products[i],
                  onMarkStatus: () => _onMarkStatus(i),
                  onUpdateStock: () => _onUpdateStock(i),
                  onEdit: () => AddProductView.open(context),
                  onDelete: () => controller.removeAt(i),
                ),
                const SizedBox(height: 12),
              ],
            ],
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
            const Text(
              'Inventory',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: _HeaderIconButton(
                  onTap: onBack,
                  icon: Icons.chevron_left_rounded,
                  iconSize: 28,
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
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
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'AVAILABLE',
                value: '1,245',
                accent: AppColors.inventoryAvailable,
                iconBg: AppColors.inventoryAvailableBg,
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: "TODAY'S ORDERS",
                value: '12',
                accent: AppColors.inventoryOrders,
                iconBg: AppColors.inventoryOrdersBg,
                icon: Icons.description_outlined,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'LOW STOCK',
                value: '18',
                accent: AppColors.inventoryLowStock,
                iconBg: AppColors.inventoryLowStockBg,
                icon: Icons.warning_amber_rounded,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'OUT OF STOCK',
                value: '6',
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
  const _LowStockAlertCard();

  static const alerts = [
    (name: 'Drinking Water 19L', left: '10 Bottles Left'),
    (name: 'Drinking Water 10L', left: '10 Bottles Left'),
  ];

  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: [
              _LowStockHeaderIcon(),
              SizedBox(width: 10),
              Text(
                'Low Stock Alert',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < alerts.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.divider),
            _LowStockAlertRow(
              name: alerts[i].name,
              remaining: alerts[i].left,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '+5 More Products',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See All',
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
  });

  final String name;
  final String remaining;

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
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 7,
                color: AppColors.inventoryLowStock,
              ),
              SizedBox(width: 5),
              Text(
                'Low Stock',
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
              onPressed: () => showUpdateStockDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Update Stock',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

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
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textMeta, size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search products, ID',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
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
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const labels = ['All 1245', 'In Stock 3', 'Low Stock 18'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                  labels[i],
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
  const _CategoryActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.inventoryCategoryBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'All Categories',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMeta,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => AddProductView.open(context),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.primaryOrange, width: 1.2),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, color: AppColors.primaryOrange, size: 18),
                SizedBox(width: 4),
                Text(
                  'Add Item',
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onMarkStatus,
    required this.onUpdateStock,
    required this.onEdit,
    required this.onDelete,
  });

  final InventoryProduct product;
  final VoidCallback onMarkStatus;
  final VoidCallback onUpdateStock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _isOut => product.status == InventoryStockStatus.outOfStock;

  Color get _statusColor => _isOut
      ? AppColors.inventoryOutOfStock
      : AppColors.inventoryAvailable;

  Color get _statusBg => _isOut
      ? AppColors.inventoryOutOfStockBg
      : AppColors.inventoryAvailableBg;

  String get _statusLabel => _isOut ? 'Out Of Stock' : 'In Stock';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 74,
                height: 74,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.inventoryImageBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(
                  AppAssets.waterCan19L,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.water_drop,
                    color: AppColors.inventoryOrders,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 7,
                                color: _statusColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _statusLabel,
                                style: TextStyle(
                                  color: _statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 2),
                        _ProductMoreMenu(
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
                      ],
                    ),
                    Text(
                      'ID: ${product.id}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          product.price,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          product.originalPrice,
                          style: const TextStyle(
                            color: AppColors.inventoryStrike,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.inventoryStrike,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: _StockRing(
                  bottles: product.bottles,
                  maxBottles: product.maxBottles,
                  color: _statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onMarkStatus,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isOut
                          ? AppColors.inventoryAvailable
                          : AppColors.inventoryOutOfStock,
                      side: BorderSide(
                        color: _isOut
                            ? AppColors.inventoryAvailable
                            : AppColors.inventoryOutOfStock,
                        width: 1.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _isOut ? 'Mark Available' : 'Mark Out Of Stock',
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
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
                    onPressed: onUpdateStock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Update Stock',
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => InventoryDetailsView.open(context, product),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.orangeSoftBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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

class _ProductMoreMenu extends StatelessWidget {
  const _ProductMoreMenu({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ProductMenuAction>(
      tooltip: 'More',
      offset: const Offset(0, 36),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 150),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      surfaceTintColor: Colors.white,
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.textMuted,
        size: 20,
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
          height: 44,
          child: const _ProductMenuRow(
            icon: Icons.edit_outlined,
            label: 'Edit',
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: _ProductMenuAction.delete,
          height: 44,
          child: const _ProductMenuRow(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
          ),
        ),
      ],
    );
  }
}

enum _ProductMenuAction { edit, delete }

class _ProductMenuRow extends StatelessWidget {
  const _ProductMenuRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMeta, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
          size: 20,
        ),
      ],
    );
  }
}

class _StockRing extends StatelessWidget {
  const _StockRing({
    required this.bottles,
    required this.maxBottles,
    required this.color,
  });

  final int bottles;
  final int maxBottles;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = maxBottles == 0 ? 0.0 : bottles / maxBottles;
    final hasStock = bottles > 0;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: hasStock ? progress.clamp(0.08, 1.0) : 0,
              strokeWidth: 3.5,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$bottles',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Text(
                'Bottles',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InventoryBottomNav extends StatelessWidget {
  const _InventoryBottomNav({required this.onSelect});

  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Orders', 'Chat', 'Inventory', 'Account'];
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
                                color: AppColors.primaryOrange
                                    .withValues(alpha: 0.35),
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
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
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
