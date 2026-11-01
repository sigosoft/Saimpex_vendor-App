import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart' show FormData;
import 'package:intl/intl.dart' show DateFormat;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/water/core/water_api.dart';
import 'package:saimpex_vendor/generated/l10n.dart';

/// Existing coupon values for editing (`coupons` row).
class WaterCouponDraft {
  const WaterCouponDraft({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.discount,
    required this.count,
    required this.validUntil,
  });

  final dynamic id;
  final String name;
  final String code;

  /// Backend `type`: 1 fixed amount, 2 percentage.
  final int type;
  final String discount;
  final String count;
  final DateTime? validUntil;
}

class AddCouponView extends StatefulWidget {
  const AddCouponView({super.key, this.initial});

  /// When set, the form edits this coupon (`POST updateCoupon`); otherwise it
  /// creates one (`POST addCoupon`).
  final WaterCouponDraft? initial;

  static const orange = Color(0xFFFF5317);
  static const ink = Color(0xFF10182B);

  /// Resolves to true when the coupon was saved on the server.
  static Future<bool?> open(BuildContext context, {WaterCouponDraft? initial}) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddCouponView(initial: initial)),
    );
  }

  @override
  State<AddCouponView> createState() => _AddCouponViewState();
}

class _AddCouponViewState extends State<AddCouponView> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _discount = TextEditingController();
  final _count = TextEditingController();
  final _typeKey = GlobalKey();

  String? _kind;
  DateTime? _validUntil;
  String? _error;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _name.text = initial.name;
      _code.text = initial.code;
      _discount.text = initial.discount;
      _count.text = initial.count;
      _kind = initial.type == 2 ? 'PERCENTAGE' : 'FLAT';
      _validUntil = initial.validUntil;
    }
  }

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
          child: Text(S.of(context).percentage, style: _valueStyle),
        ),
        PopupMenuItem(
          value: 'FLAT',
          child: Text(S.of(context).waterFlat, style: _valueStyle),
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = _validUntil;
    final picked = await showDatePicker(
      context: context,
      initialDate: current == null || current.isBefore(today) ? today : current,
      firstDate: today,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AddCouponView.orange,
              onPrimary: Colors.white,
              onSurface: AddCouponView.ink,
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

  Future<void> _submit() async {
    if (_saving) return;
    final name = _name.text.trim();
    final code = _code.text.trim();
    final discount = double.tryParse(_discount.text.trim());
    final count = int.tryParse(_count.text.trim());
    if (name.isEmpty || code.isEmpty || _kind == null || discount == null || count == null || _validUntil == null) {
      setState(() => _error = S.of(context).waterFillInEveryField);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await WaterApi.prepare();
      final body = <String, dynamic>{
        if (_isEditing) 'coupon_id': widget.initial!.id.toString(),
        'name': name,
        'code': code.toUpperCase(),
        'type': _kind == 'PERCENTAGE' ? '2' : '1',
        'discount_value': _discount.text.trim(),
        'count': '$count',
        'valid_upto': DateFormat('yyyy-MM-dd').format(_validUntil!),
      };
      final response = await DioClient().post(
        _isEditing ? ApiEndPoints.updateCoupon : ApiEndPoints.addCoupon,
        body: FormData.fromMap(body),
      );
      final data = response.data;
      if (!mounted) return;
      if (WaterApi.isOk(data)) {
        final msg = WaterApi.message(data);
        if (msg != null) showToast(context, msg);
        Navigator.of(context).pop(true);
      } else {
        setState(() => _error = WaterApi.message(data) ?? S.of(context).waterSomethingWentWrong);
      }
    } catch (e) {
      if (mounted) setState(() => _error = WaterApi.errorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
              _Header(title: _isEditing ? S.of(context).updateCoupon : S.of(context).addCoupon),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  children: [
                    _Field(
                      label: S.of(context).couponName,
                      controller: _name,
                      hint: S.of(context).enterCouponName,
                      onChanged: _clearError,
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      label: S.of(context).couponCode,
                      controller: _code,
                      hint: S.of(context).enterCouponCode,
                      onChanged: _clearError,
                    ),
                    const SizedBox(height: 16),
                    _label(S.of(context).couponType),
                    const SizedBox(height: 8),
                    _SelectBox(
                      key: _typeKey,
                      text: _kind == null
                          ? S.of(context).select
                          : (_kind == 'PERCENTAGE' ? S.of(context).percentage : S.of(context).waterFlat),
                      filled: _kind != null,
                      icon: Icons.keyboard_arrow_down_rounded,
                      onTap: _pickType,
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      label: S.of(context).discount,
                      controller: _discount,
                      hint: S.of(context).enterDiscount,
                      keyboard: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: _clearError,
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      label: S.of(context).waterCount,
                      controller: _count,
                      hint: S.of(context).enterCount,
                      keyboard: TextInputType.number,
                      onChanged: _clearError,
                    ),
                    const SizedBox(height: 16),
                    _label(S.of(context).waterValidUpto),
                    const SizedBox(height: 8),
                    _SelectBox(
                      text: _validUntil == null ? S.of(context).waterDatePlaceholder : _formatInput(_validUntil!),
                      filled: _validUntil != null,
                      calendar: true,
                      onTap: _pickDate,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        style: appFont('Inter', 
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
                            S.of(context).cancel,
                            style: appFont('Inter', fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _saving ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AddCouponView.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  _isEditing ? S.of(context).updateCoupon : S.of(context).addCoupon,
                                  style: appFont('Inter', fontWeight: FontWeight.w700, fontSize: 15),
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

TextStyle get _valueStyle => appFont('Inter', 
      color: const Color(0xFF3F4555),
      fontWeight: FontWeight.w500,
      fontSize: 13,
    );

Widget _label(String text) {
  return Text(
    text,
    style: appFont('Inter', 
      color: const Color(0xFF404250),
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
  );
}

String _formatInput(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day-$month-${date.year}';
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

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
              title,
              style: appFont('Inter', 
                color: AddCouponView.ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
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

final _hintStyle = appFont('Inter', 
  color: const Color(0xFF9BA9BD),
  fontWeight: FontWeight.w500,
  fontSize: 13,
);
