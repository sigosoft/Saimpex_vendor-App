import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PharmacyBusinessSettingsScreen extends StatefulWidget {
  const PharmacyBusinessSettingsScreen({super.key});

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF2E3545);

  @override
  State<PharmacyBusinessSettingsScreen> createState() => _PharmacyBusinessSettingsScreenState();
}

class _PharmacyBusinessSettingsScreenState extends State<PharmacyBusinessSettingsScreen> {
  bool _storeOpen = true;
  bool _acceptingOrders = true;
  bool _storeBusy = false;
  bool _expressAvailable = true;
  final List<_Distance> _ranges = [_Distance(min: 0, max: 5, price: 15)];

  Future<_Distance?> _openSheet({_Distance? current, int? editingIndex}) {
    final last = _ranges.isEmpty ? null : _ranges.last;
    return showModalBottomSheet<_Distance>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
      builder: (context) => _AddDistanceSheet(
        initialMin: current?.min ?? last?.max ?? 0,
        initialMax: current?.max ?? ((last?.max ?? 0) + 5),
        initialPrice: current?.price,
        editing: current != null,
        others: [
          for (var i = 0; i < _ranges.length; i++)
            if (i != editingIndex) _ranges[i],
        ],
      ),
    );
  }

  Future<void> _openAddRange() async {
    final added = await _openSheet();
    if (added == null || !mounted) return;
    setState(() => _ranges.add(added));
  }

  Future<void> _openEditRange(int index) async {
    final edited = await _openSheet(current: _ranges[index], editingIndex: index);
    if (edited == null || !mounted) return;
    setState(() => _ranges[index] = edited);
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
              colors: [Color(0xFFFFEBE4), Color(0xFFFFF6F1), Colors.white],
              stops: [0, 0.22, 0.42],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  children: [
                    const _SectionTitle('Store Availability'),
                    const SizedBox(height: 10),
                    _Card(
                      children: [
                        _SwitchRow(
                          label: 'Store Status (Open)',
                          value: _storeOpen,
                          onChanged: (value) => setState(() => _storeOpen = value),
                        ),
                        const _Divider(),
                        _SwitchRow(
                          label: 'Accepting Orders',
                          value: _acceptingOrders,
                          onChanged: (value) => setState(() => _acceptingOrders = value),
                        ),
                        const _Divider(),
                        _SwitchRow(
                          label: 'Mark Store Busy',
                          value: _storeBusy,
                          onChanged: (value) => setState(() => _storeBusy = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle('Express Delivery'),
                    const SizedBox(height: 10),
                    _Card(
                      children: [
                        _SwitchRow(
                          label: 'Available',
                          value: _expressAvailable,
                          onChanged: (value) => setState(() => _expressAvailable = value),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Pricing',
                              style: GoogleFonts.inter(
                                color: PharmacyBusinessSettingsScreen.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            children: [
                              for (var i = 0; i < _ranges.length; i++) ...[
                                if (i > 0) const SizedBox(height: 8),
                                _DistanceRange(
                                  range: _ranges[i],
                                  onEdit: () => _openEditRange(i),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                          child: _AddRangeButton(onTap: _openAddRange),
                        ),
                      ],
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
              'Business settings',
              style: GoogleFonts.inter(
                color: const Color(0xFF1C1D1B),
                fontWeight: FontWeight.w700,
                fontSize: 18,
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
                    color: PharmacyBusinessSettingsScreen.orange,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: PharmacyBusinessSettingsScreen.orange,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1), indent: 14, endIndent: 14);
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: PharmacyBusinessSettingsScreen.ink,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (next) {
              HapticFeedback.lightImpact();
              onChanged(next);
            },
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return PharmacyBusinessSettingsScreen.orange;
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

class _Distance {
  const _Distance({required this.min, required this.max, required this.price});

  final int min;
  final int max;
  final int price;
}

class _DistanceRange extends StatelessWidget {
  const _DistanceRange({required this.range, required this.onEdit});

  final _Distance range;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '${range.min} – ${range.max} km',
            style: GoogleFonts.inter(
              color: PharmacyBusinessSettingsScreen.ink,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            '${range.price}',
            style: GoogleFonts.inter(
              color: PharmacyBusinessSettingsScreen.ink,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'MRU',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onEdit,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.edit_outlined, color: PharmacyBusinessSettingsScreen.orange, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddRangeButton extends StatelessWidget {
  const _AddRangeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
      painter: const _DashedBorderPainter(
        color: Color(0xFFFF8A5B),
        radius: 12,
      ),
      child: Container(
        height: 46,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+ Add Distance Range',
          style: GoogleFonts.inter(
            color: PharmacyBusinessSettingsScreen.orange,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()..addRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
    );
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}

class _AddDistanceSheet extends StatefulWidget {
  const _AddDistanceSheet({
    required this.initialMin,
    required this.initialMax,
    required this.others,
    this.initialPrice,
    this.editing = false,
  });

  final int initialMin;
  final int initialMax;
  final int? initialPrice;
  final bool editing;
  final List<_Distance> others;

  @override
  State<_AddDistanceSheet> createState() => _AddDistanceSheetState();
}

class _AddDistanceSheetState extends State<_AddDistanceSheet> {
  late final TextEditingController _min;
  late final TextEditingController _max;
  late final TextEditingController _price;
  String? _error;

  @override
  void initState() {
    super.initState();
    _min = TextEditingController(text: '${widget.initialMin}');
    _max = TextEditingController(text: '${widget.initialMax}');
    _price = TextEditingController(text: widget.initialPrice == null ? '' : '${widget.initialPrice}');
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    _price.dispose();
    super.dispose();
  }

  void _submit() {
    final min = int.tryParse(_min.text.trim());
    final max = int.tryParse(_max.text.trim());
    final price = int.tryParse(_price.text.trim());
    String? error;
    if (min == null || max == null) {
      error = 'Enter minimum and maximum distance';
    } else if (max <= min) {
      error = 'Maximum must be greater than minimum';
    } else if (price == null) {
      error = 'Enter a price';
    } else if (widget.others.any((range) => min < range.max && max > range.min)) {
      error = 'This range overlaps an existing range';
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_Distance(min: min!, max: max!, price: price!));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.editing ? 'Edit Distance Range' : 'Add Distance Range',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
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
            Row(
              children: [
                Expanded(child: _Field(label: 'Minimum Distance', controller: _min, suffix: 'Km')),
                const SizedBox(width: 12),
                Expanded(child: _Field(label: 'Maximum Distance', controller: _max, suffix: 'Km')),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Price',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Field(controller: _price, hint: 'e.g. 50')),
                const SizedBox(width: 12),
                Container(
                  width: 96,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'MRU',
                    style: GoogleFonts.inter(
                      color: const Color.fromARGB(255, 71, 73, 78),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: GoogleFonts.inter(
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF454E5D),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
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
                        backgroundColor: const Color(0xFFFF5317),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        widget.editing ? 'Update' : 'Add',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({this.label, this.controller, this.suffix, this.hint});

  final String? label;
  final TextEditingController? controller;
  final String? suffix;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final box = TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(
        color: const Color(0xFF1F2937),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF2F4F6),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixText: suffix,
        suffixStyle: GoogleFonts.inter(
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
    if (label == null) return box;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        box,
      ],
    );
  }
}
