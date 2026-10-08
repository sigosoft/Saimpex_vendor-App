import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PharmacyAddProductScreen extends StatefulWidget {
  const PharmacyAddProductScreen({super.key});

  static const Color orange = Color(0xFFFF5722);
  static const Color ink = Color(0xFF111827);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color field = Color(0xFFF3F4F6);

  @override
  State<PharmacyAddProductScreen> createState() => _PharmacyAddProductScreenState();
}

class _PharmacyAddProductScreenState extends State<PharmacyAddProductScreen> {
  final _name = TextEditingController();
  final _expiry = TextEditingController();
  final _barcode = TextEditingController();
  final _description = TextEditingController();
  final _selling = TextEditingController(text: '0.00');
  final _offer = TextEditingController(text: '0.00');
  final _stock = TextEditingController(text: '300');
  final _lowStock = TextEditingController(text: '10');

  String? _category;
  String _form = 'Tablet';
  String? _dosage;
  String _unit = 'Strip';
  bool _prescription = false;

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

  void _reset() {
    setState(() {
      _name.clear();
      _expiry.clear();
      _barcode.clear();
      _description.clear();
      _selling.text = '0.00';
      _offer.text = '0.00';
      _stock.text = '300';
      _lowStock.text = '10';
      _category = null;
      _form = 'Tablet';
      _dosage = null;
      _unit = 'Strip';
      _prescription = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFEBE4),
                Color(0xFFFFF4F0),
                Color(0xFFFFFFFF),
              ],
              stops: [0, 0.22, 0.42],
            ),
          ),
          child: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top + 8),
            _Header(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  const _FieldLabel('Product Image', color: Color(0xFF4B5563)),
                  const SizedBox(height: 8),
                  const _UploadBox(),
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
                                  items: const [
                                    'Analgesics & Antipyretics',
                                    'Medical Devices',
                                    'Vitamins',
                                  ],
                                  onChanged: (value) => setState(() => _category = value),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _Labeled(
                                label: 'Form',
                                child: _SelectCategoryField(
                                  value: _form,
                                  items: const ['Tablet', 'Capsule', 'Syrup', 'Device'],
                                  onChanged: (value) {
                                    if (value != null) setState(() => _form = value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _Labeled(
                          label: 'Product Name (English)',
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
                                  items: const ['250mg', '500mg', '1000mg'],
                                  onChanged: (value) => setState(() => _dosage = value),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _Labeled(
                                label: 'Unit',
                                child: _SelectCategoryField(
                                  value: _unit,
                                  items: const ['Strip', 'Box', 'Bottle', 'Piece'],
                                  onChanged: (value) {
                                    if (value != null) setState(() => _unit = value);
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
                  const SizedBox(height: 12),
                  _PrescriptionCard(
                    value: _prescription,
                    onChanged: (value) => setState(() => _prescription = value),
                  ),
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
                            label: 'Selling Price',
                            child: _PriceField(controller: _selling),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Labeled(
                            label: 'Offer Price',
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
                    child: Row(
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
            _BottomActions(onReset: _reset),
          ],
        ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onReset});

  final VoidCallback onReset;

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
                onPressed: onReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF334155),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Reset',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
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
                  backgroundColor: const Color(0xFFFF5317),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFFFF5317).withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Save Product',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
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
              'Add Product',
              style: GoogleFonts.inter(
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
  const _UploadBox();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
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
              style: GoogleFonts.inter(
                color: const Color(0xFF394452),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PNG, JPG up to 5MB',
              style: GoogleFonts.inter(
                color: const Color(0xFF8A8B98),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  const _DashedPainter();

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
          const Radius.circular(18),
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
                style: GoogleFonts.inter(
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
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1C1D1B),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Customer must provide a prescription',
                  style: GoogleFonts.inter(
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
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        child,
      ],
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
      style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(
            color: value == null ? const Color(0xFF7C828F) : const Color(0xFF1F2937),
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
    hintStyle: GoogleFonts.inter(
      color: const Color(0xFF7C828F),
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    suffixText: suffix,
    suffixStyle: GoogleFonts.inter(
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
            style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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
                hintStyle: GoogleFonts.inter(
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(
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
            style: GoogleFonts.inter(
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
      style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
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
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
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
                border: Border.all(color: PharmacyAddProductScreen.orange, width: 2),
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
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
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
      Rect.fromLTWH(size.width * 0.06, size.height * 0.04, size.width * 0.88, size.height * 0.30),
      const Radius.circular(1.2),
    );
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.40, size.width * 0.76, size.height * 0.54),
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
