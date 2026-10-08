import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PharmacyCouponDraft {
  const PharmacyCouponDraft({
    required this.name,
    required this.code,
    required this.kind,
    required this.discount,
    required this.count,
    required this.validUntil,
    required this.createdOn,
  });

  final String name;
  final String code;
  final String kind;
  final String discount;
  final String count;
  final String validUntil;
  final String createdOn;
}

class PharmacyAddCouponScreen extends StatefulWidget {
  const PharmacyAddCouponScreen({super.key});

  static const orange = Color(0xFFFF5317);
  static const ink = Color(0xFF10182B);

  @override
  State<PharmacyAddCouponScreen> createState() => _PharmacyAddCouponScreenState();
}

class _PharmacyAddCouponScreenState extends State<PharmacyAddCouponScreen> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _discount = TextEditingController();
  final _count = TextEditingController();
  final _typeKey = GlobalKey();

  String? _kind;
  DateTime? _validUntil;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _discount.dispose();
    _count.dispose();
    super.dispose();
  }

  Future<void> _pickType() async {
    final box = _typeKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final origin = box.localToGlobal(Offset.zero);
    final selected = await showMenu<String>(
      context: context,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(
        origin.dx,
        origin.dy + box.size.height + 4,
        origin.dx + box.size.width,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'PERCENTAGE',
          child: Text('Percentage', style: _valueStyle),
        ),
        PopupMenuItem(
          value: 'FLAT',
          child: Text('Flat', style: _valueStyle),
        ),
      ],
    );
    if (selected == null) return;
    setState(() {
      _kind = selected;
      _error = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PharmacyAddCouponScreen.orange,
              onPrimary: Colors.white,
              onSurface: PharmacyAddCouponScreen.ink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _validUntil = picked;
      _error = null;
    });
  }

  void _submit() {
    final name = _name.text.trim();
    final code = _code.text.trim();
    final discount = double.tryParse(_discount.text.trim());
    final count = int.tryParse(_count.text.trim());
    if (name.isEmpty || code.isEmpty || _kind == null || discount == null || count == null || _validUntil == null) {
      setState(() => _error = 'Fill in every field');
      return;
    }
    HapticFeedback.lightImpact();
    final suffix = _kind == 'PERCENTAGE' ? '%' : ' MRU';
    Navigator.of(context).pop(
      PharmacyCouponDraft(
        name: name.toUpperCase(),
        code: code.toUpperCase(),
        kind: _kind!,
        discount: '${discount.toStringAsFixed(2)}$suffix',
        count: '$count',
        validUntil: _formatShort(_validUntil!),
        createdOn: _formatStamp(DateTime.now()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFEBE4), Color(0xFFFFF4F0), Colors.white],
              stops: [0, 0.42, 0.7],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              const _Header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  children: [
                    _Field(
                      label: 'Coupon Name',
                      controller: _name,
                      hint: 'Enter coupon name',
                      onChanged: _clearError,
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      label: 'Coupon Code',
                      controller: _code,
                      hint: 'Enter coupon code',
                      onChanged: _clearError,
                    ),
                    const SizedBox(height: 16),
                    _label('Coupon Type'),
                    const SizedBox(height: 8),
                    _SelectBox(
                      key: _typeKey,
                      text: _kind == null ? 'Select' : (_kind == 'PERCENTAGE' ? 'Percentage' : 'Flat'),
                      filled: _kind != null,
                      icon: Icons.keyboard_arrow_down_rounded,
                      onTap: _pickType,
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      label: 'Discount',
                      controller: _discount,
                      hint: 'Enter discount',
                      keyboard: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: _clearError,
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      label: 'Count',
                      controller: _count,
                      hint: 'Enter count',
                      keyboard: TextInputType.number,
                      onChanged: _clearError,
                    ),
                    const SizedBox(height: 16),
                    _label('Valid Upto'),
                    const SizedBox(height: 8),
                    _SelectBox(
                      text: _validUntil == null ? 'dd-mm-yyyy' : _formatInput(_validUntil!),
                      filled: _validUntil != null,
                      calendar: true,
                      onTap: _pickDate,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFBA1B1B),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 12),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF4C586A),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: PharmacyAddCouponScreen.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Add Coupon',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }
}

TextStyle get _valueStyle => GoogleFonts.inter(
      color: const Color(0xFF3F4555),
      fontWeight: FontWeight.w500,
      fontSize: 13,
    );

Widget _label(String text) {
  return Text(
    text,
    style: GoogleFonts.inter(
      color: const Color(0xFF404250),
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
  );
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatInput(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day-$month-${date.year}';
}

String _formatShort(DateTime date) {
  return '${_months[date.month - 1]} ${date.day},${date.year}';
}

String _formatStamp(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  var hour = date.hour % 12;
  if (hour == 0) hour = 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour < 12 ? 'AM' : 'PM';
  return '${_months[date.month - 1]} $day, ${date.year} $hour:$minute $suffix, Today';
}

class _Header extends StatelessWidget {
  const _Header();

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
              'Add Coupon',
              style: GoogleFonts.inter(
                color: PharmacyAddCouponScreen.ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
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
                    color: Color(0xFFFF5216),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboard,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD7DDE4)),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboard,
            style: _valueStyle,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: _hintStyle,
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectBox extends StatelessWidget {
  const _SelectBox({
    super.key,
    required this.text,
    required this.filled,
    required this.onTap,
    this.icon,
    this.calendar = false,
  });

  final String text;
  final bool filled;
  final VoidCallback onTap;
  final IconData? icon;
  final bool calendar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD7DDE4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(text, style: filled ? _valueStyle : _hintStyle),
              ),
              if (calendar)
                Image.asset(
                  'lib/pharmacy/Assets/images/calender.png',
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                )
              else
                Icon(icon, size: 20, color: const Color(0xFF9AA3B2)),
            ],
          ),
        ),
      ),
    );
  }
}

final _hintStyle = GoogleFonts.inter(
  color: const Color(0xFF9BA9BD),
  fontWeight: FontWeight.w500,
  fontSize: 13,
);
