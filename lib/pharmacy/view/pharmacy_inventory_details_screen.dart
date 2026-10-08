import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PharmacyInventoryDetailsScreen extends StatelessWidget {
  const PharmacyInventoryDetailsScreen({
    super.key,
    required this.name,
    required this.image,
    this.inStock = true,
  });

  final String name;
  final String image;
  final bool inStock;

  static const Color _orange = Color(0xFFFF5722);
  static const Color _green = Color(0xFF22C55E);

  bool get _isParacetamol => name.toLowerCase().contains('paracetamol');

  @override
  Widget build(BuildContext context) {
    final stockValue = _isParacetamol ? '248' : (inStock ? '120' : '0');
    final priceValue = _isParacetamol ? '890' : '50';
    final expiryShort = _isParacetamol ? "Oct '25" : "Dec '26";
    final barcode = _isParacetamol ? '8901234567890' : '8901234567891';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _DetailsHeader(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        image,
                        width: double.infinity,
                        height: 188,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
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
                    ),
                    const SizedBox(height: 10),
                    _BarcodeBlock(code: barcode),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _EditButton(onTap: () {})),
                        const SizedBox(width: 10),
                        Expanded(child: _UpdateStockButton(onTap: () {})),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SpecCard(isParacetamol: _isParacetamol),
                    const SizedBox(height: 12),
                    const _SalesCard(),
                    const SizedBox(height: 12),
                    const _HistoryCard(),
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
  });

  final String stock;
  final String price;
  final String expiry;
  final bool inStock;

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
                child: _ValueUnit(value: stock, unit: 'Units'),
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
          side: const BorderSide(color: PharmacyInventoryDetailsScreen._orange, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
  const _SpecCard({required this.isParacetamol});

  final bool isParacetamol;

  @override
  Widget build(BuildContext context) {
    final rows = isParacetamol
        ? const [
            ('Category', 'Analgesics & Antipyretics'),
            ('Form', 'Tablet'),
            ('Dosage', '500mg'),
            ('Price', '100 MRU'),
            ('Discount Price', '50 MRU'),
            ('Expiry Date', '25 Oct, 2026'),
          ]
        : const [
            ('Category', 'Medical Devices'),
            ('Form', 'Device'),
            ('Dosage', '—'),
            ('Price', '100 MRU'),
            ('Discount Price', '50 MRU'),
            ('Expiry Date', '25 Dec, 2026'),
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
              "Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem ipsum has been the industry's standard dummy text.",
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
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
              Expanded(child: _SaleStat(label: 'Today', value: '12')),
              Expanded(child: _SaleStat(label: 'Week', value: '68')),
              Expanded(child: _SaleStat(label: 'Month', value: '245')),
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
              Expanded(child: _RevenueStat(label: 'Today', amount: '120 MRU')),
              Expanded(child: _RevenueStat(label: 'Week', amount: '680 MRU')),
              Expanded(child: _RevenueStat(label: 'Month', amount: '2,450 MRU')),
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
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
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
