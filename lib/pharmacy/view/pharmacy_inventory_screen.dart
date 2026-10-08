import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_add_product_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_inventory_details_screen.dart';

enum _StockStatus { inStock, lowStock, outOfStock }

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

  late final List<_InventoryItem> _items = [
    _InventoryItem(
      id: '33',
      name: 'Paracetamol 500mg',
      subtitle: 'Tablet',
      asPill: true,
      price: '50.00 MRU',
      originalPrice: '100.00 MRU',
      boxes: 300,
      status: _StockStatus.inStock,
      image: 'lib/pharmacy/Assets/images/paracetamol.jpg',
    ),
    _InventoryItem(
      id: '34',
      name: 'Digital Thermometer',
      subtitle: 'Fast Reading • Waterproof',
      asPill: true,
      price: '50.00 MRU',
      originalPrice: '100.00 MRU',
      boxes: 0,
      status: _StockStatus.outOfStock,
      image: 'lib/pharmacy/Assets/images/digital_thermometer.jpg',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final quantity = await showDialog<int>(
      context: context,
      barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
      builder: (_) => const _UpdateStockDialog(),
    );
    if (!mounted || quantity == null || item == null) return;
    setState(() {
      item.boxes = quantity;
      if (quantity == 0) {
        item.status = _StockStatus.outOfStock;
      } else if (item.status == _StockStatus.outOfStock) {
        item.status = _StockStatus.inStock;
      }
    });
  }

  void _toggleStock(_InventoryItem item) {
    setState(() {
      if (item.status == _StockStatus.outOfStock) {
        item.status = _StockStatus.inStock;
        if (item.boxes == 0) item.boxes = 1;
      } else {
        item.status = _StockStatus.outOfStock;
        item.boxes = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF0E8),
            Color(0xFFFFF6F1),
            Color(0xFFFFF8F4),
          ],
          stops: [0, 0.28, 1],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8),
          _InventoryHeader(onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              children: [
                const _StatsGrid(),
                const SizedBox(height: 14),
                _LowStockAlertCard(
                  onUpdate: (name) {
                    _InventoryItem? match;
                    for (final item in _items) {
                      if (item.name == name) match = item;
                    }
                    _promptUpdateStock(match);
                  },
                ),
                const SizedBox(height: 14),
                _SearchField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _FilterChips(
                  selected: _filter,
                  onSelect: (index) => setState(() => _filter = index),
                ),
                const SizedBox(height: 12),
                const _CategoryRow(),
                const SizedBox(height: 14),
                for (final item in _visibleItems) ...[
                  _ProductCard(
                    item: item,
                    onToggleStock: () => _toggleStock(item),
                    onUpdateStock: () => _promptUpdateStock(item),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryHeader extends StatelessWidget {
  const _InventoryHeader({this.onBack});

  final VoidCallback? onBack;

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
              'Inventory',
              style: GoogleFonts.inter(
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
  const _HeaderButton({
    required this.icon,
    this.onTap,
    this.iconSize = 22,
  });

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
        child: Icon(icon, color: const Color(0xFFFF5722), size: iconSize),
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
                label: 'TOTAL MEDICINES',
                value: '1,245',
                accent: Color(0xFFFF5216),
                icon: Icons.medication_rounded,
                iconColor: Color(0xFFE8C4B4),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'LOW STOCK',
                value: '18',
                accent: Color(0xFFF59E0B),
                icon: Icons.warning_rounded,
                iconColor: Color(0xFFF6D59A),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'OUT OF STOCK',
                value: '6',
                accent: Color(0xFFBA1A1A),
                icon: Icons.block_rounded,
                iconColor: Color(0xFFF0C4C4),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'EXPIRING SOON',
                value: '12',
                accent: Color(0xFF0058BE),
                icon: Icons.calendar_month_rounded,
                iconColor: Color(0xFFCCDEF2),
                customIcon: _ExpiringCalendarIcon(),
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
                            style: GoogleFonts.inter(
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
                            style: GoogleFonts.inter(
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
    canvas.drawLine(Offset(cx - arm, cy - arm), Offset(cx + arm, cy + arm), paint);
    canvas.drawLine(Offset(cx + arm, cy - arm), Offset(cx - arm, cy + arm), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LowStockAlertCard extends StatelessWidget {
  const _LowStockAlertCard({this.onUpdate});

  final ValueChanged<String>? onUpdate;

  static const _amber = Color(0xFFF79009);
  static const _button = Color(0xFFFF5317);

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(Icons.warning_amber_rounded, color: _amber, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Low Stock Alert',
                style: GoogleFonts.inter(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LowStockRow(
            name: 'Paracetamol 500mg',
            onUpdate: () => onUpdate?.call('Paracetamol 500mg'),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE6E8EC)),
          const SizedBox(height: 12),
          _LowStockRow(
            name: 'Amoxicillin 250mg',
            onUpdate: () => onUpdate?.call('Amoxicillin 250mg'),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE6E8EC)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '+5 More Products',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                'See All',
                style: GoogleFonts.inter(
                  color: _button,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LowStockRow extends StatelessWidget {
  const _LowStockRow({required this.name, this.onUpdate});

  final String name;
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
                style: GoogleFonts.inter(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '10 Boxes Left',
                style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
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
    final yesColor = markAvailable ? const Color(0xFF22C55E) : const Color(0xFFFF4D4D);
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
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF7F7F7F)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 18, 18),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
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
                      color: const Color(0xFFFF5722),
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
    final value = int.tryParse(_quantity.text.trim());
    if (value == null || value < 0) return;
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
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF7F7F7F)),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Update',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                side: BorderSide(color: color, width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
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
        style: GoogleFonts.inter(
          color: const Color(0xFF1A1A1A),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search products, ID',
          hintStyle: GoogleFonts.inter(
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
  const _FilterChips({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _labels = ['All 18', 'In Stock 14', 'Low Stock 3'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == selected ? const Color(0xFFFF5722) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: i == selected
                      ? null
                      : Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  _labels[i],
                  style: GoogleFonts.inter(
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
  const _CategoryRow();

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
                style: GoogleFonts.inter(
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
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PharmacyAddProductScreen(),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFF5722),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFFF5722)),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 38),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            'Add Item',
            style: GoogleFonts.inter(
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
  });

  final _InventoryItem item;
  final VoidCallback onToggleStock;
  final VoidCallback onUpdateStock;

  bool get _out => item.status == _StockStatus.outOfStock;

  @override
  Widget build(BuildContext context) {
    final stockColor = _out ? const Color(0xFFFF3A3A) : const Color.fromARGB(255, 29, 169, 81);
    final stockBg = _out ? const Color(0xFFFFEBEB) : const Color(0xFFE9FAEF);
    final stockLabel = switch (item.status) {
      _StockStatus.inStock => 'In Stock',
      _StockStatus.lowStock => 'Low Stock',
      _StockStatus.outOfStock => 'Out Of Stock',
    };
    final actionColor = _out ? const Color.fromARGB(255, 29, 172, 81) : const Color(0xFFFF3A3A);
    final actionBorder = _out ? const Color.fromARGB(255, 29, 172, 81) : const Color(0xFFFFB5B5);

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
                child: Image.asset(
                  item.image,
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                ),
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
                          style: GoogleFonts.inter(
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
                                style: GoogleFonts.inter(
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
                        const Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: Color(0xFFB0B7C3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A2332),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                                      vertical:6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF1EC),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.subtitle,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFFF5722),
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
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.2,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    item.price,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.originalPrice,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFC4C4C4),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      height: 1,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: const Color(0xFFC4C4C4),
                                    ),
                                  ),
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
                                style: GoogleFonts.inter(
                                  color: stockColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Boxes',
                                style: GoogleFonts.inter(
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
                        barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
                        builder: (_) => _StockConfirmDialog(markAvailable: _out),
                      );
                      if (confirmed == true) onToggleStock();
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
                      style: GoogleFonts.inter(
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
                      'Update Stock',
                      style: GoogleFonts.inter(
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
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PharmacyInventoryDetailsScreen(
                        name: item.name,
                        image: item.name.toLowerCase().contains('paracetamol')
                            ? 'lib/pharmacy/Assets/images/paracetamol.png'
                            : item.image,
                        inStock: !_out,
                      ),
                    ),
                  );
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(23, 8, 18, 8),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.inter(
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
