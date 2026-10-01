import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/water/controller/inventory_details_controller.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/model/inventory_product.dart';

class InventoryDetailsView extends StatefulWidget {
  const InventoryDetailsView({super.key, required this.product});

  final InventoryProduct product;

  static void open(BuildContext context, InventoryProduct product) {
    Navigator.of(context).push(
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

  InventoryProduct get product => widget.product;

  bool get isInStock => product.status != InventoryStockStatus.outOfStock;

  @override
  void initState() {
    super.initState();
    controller = WaterInventoryDetailsController();
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
                      _HeroImage(),
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
                        availableStock: isInStock ? '248' : '0',
                        todayOrders: '10',
                        sellingPrice: product.price.contains('MRU')
                            ? product.price
                                .replaceAll('.00', '')
                                .trim()
                            : '${product.price} MRU',
                        inStock: isInStock,
                      ),
                      const SizedBox(height: 10),
                      const _BarcodeCard(value: '8901234567890'),
                      const SizedBox(height: 14),
                      const _ActionButtons(),
                      const SizedBox(height: 14),
                      _BottleReturnCard(
                        enabled: controller.returnableBottle,
                        onChanged: controller.setReturnableBottle,
                      ),
                      const SizedBox(height: 14),
                      const _ProductDetailsCard(),
                      const SizedBox(height: 14),
                      const _SalesPerformanceCard(),
                      const SizedBox(height: 18),
                      const _StockHistorySection(),
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
            const Text(
              'Details',
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

class _HeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 210,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.inventoryHeroBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Image.asset(
        AppAssets.waterCan19L,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(
          Icons.water_drop,
          size: 72,
          color: AppColors.planPurple,
        ),
      ),
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
              child: _InfoTile(label: 'Available Stock', value: availableStock),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoTile(label: 'Today Orders', value: todayOrders),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _InfoTile(label: 'Selling Price', value: sellingPrice),
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
          const Text(
            'Status',
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
                inStock ? 'In Stock' : 'Out Of Stock',
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
          const Text(
            'Barcode',
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
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () {},
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
              child: const Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Update Stock',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ),
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
          const Row(
            children: [
              Icon(
                Icons.recycling_rounded,
                color: AppColors.inventoryBottleGreen,
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                'BOTTLE RETURN SETTINGS',
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
  const _ProductDetailsCard();

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryOrange,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Product Details',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailPair(label: 'Category', value: 'Water Bottle'),
                    SizedBox(height: 12),
                    _DetailPair(label: 'Unit Type', value: 'Bottle'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailPair(label: 'Size', value: '10 Litres'),
                    SizedBox(height: 12),
                    _DetailPair(label: 'Storage', value: 'Warehouse A'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            'Description',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Premium purified water, mineral-balanced for optimal hydration. Sourced from high quality aquifers and treated with state of the art reverse osmosis.',
            style: TextStyle(
              color: AppColors.textDark,
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
  const _SalesPerformanceCard();

  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: AppColors.primaryOrange,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sales Performance',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
              ),
              Text(
                'Last Sold: Today - 2:15 PM',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _SalesStat(label: 'Today', value: '12')),
              Expanded(child: _SalesStat(label: 'Week', value: '68')),
              Expanded(child: _SalesStat(label: 'Month', value: '245')),
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
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Total Sold (All Time)',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '3,482',
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Revenue Summary',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _RevenueStat(label: 'Today', value: '120 MRU'),
              ),
              Expanded(
                child: _RevenueStat(label: 'Week', value: '680 MRU'),
              ),
              Expanded(
                child: _RevenueStat(label: 'Month', value: '2,450 MRU'),
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
  const _StockHistorySection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Stock History',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              'See All',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _HistoryCard(
          stockId: '#927',
          date: '26 Mar, 2026, 03:59 AM',
          title: 'Stock Removed',
          quantity: '-50',
          remaining: '400',
          isRemoval: true,
        ),
        SizedBox(height: 10),
        _HistoryCard(
          stockId: '#926',
          date: '26 Mar, 2026, 03:59 AM',
          title: 'Stock Added',
          quantity: '+450',
          remaining: '450',
          isRemoval: false,
        ),
      ],
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
                'STOCK ID: $stockId',
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
                'QUANTITY: ',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              Text(
                quantity,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
              const Spacer(),
              const Text(
                'REMAINING: ',
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
