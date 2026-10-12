import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';

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
  const PharmacyAddCouponScreen({super.key, this.initialData});

  final Map<String, dynamic>? initialData;

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
  bool _isSubmitting = false;

  bool get _isEditing =>
      widget.initialData != null &&
      (widget.initialData!['id'] != null ||
          widget.initialData!['coupon_id'] != null);

  @override
  void initState() {
    super.initState();
    final init = widget.initialData;
    if (init != null) {
      _name.text = init['name']?.toString() ??
          init['name_en']?.toString() ??
          init['name_ar']?.toString() ??
          init['name_fr']?.toString() ??
          '';
      _code.text = init['code']?.toString() ?? '';

      final typeVal = init['type']?.toString().toLowerCase() ??
          init['kind']?.toString().toLowerCase() ??
          '';
      if (typeVal == '2' || typeVal.contains('percent')) {
        _kind = 'PERCENTAGE';
      } else if (typeVal == '1' ||
          typeVal.contains('flat') ||
          typeVal.contains('amount')) {
        _kind = 'FLAT';
      } else if (init['kind'] == 'PERCENTAGE' || init['kind'] == 'FLAT') {
        _kind = init['kind'];
      }

      final rawDiscount = init['discount_value']?.toString() ??
          init['discount']?.toString() ??
          '';
      _discount.text = rawDiscount
          .replaceAll('%', '')
          .replaceAll('MRU', '')
          .replaceAll('\$', '')
          .trim();

      _count.text = init['count']?.toString() ??
          init['usage_limit']?.toString() ??
          '';

      final rawDate = init['valid_upto'] ??
          init['valid_until'] ??
          init['expiry_date'];
      _validUntil = _parseValidUntil(rawDate);
    }
  }

  DateTime? _parseValidUntil(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    final s = val.toString().trim();
    if (s.isEmpty || s == 'N/A') return null;
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;

    final parts = s.split(RegExp(r'[-/]'));
    if (parts.length == 3) {
      final p1 = int.tryParse(parts[0]);
      final p2 = int.tryParse(parts[1]);
      final p3 = int.tryParse(parts[2]);
      if (p1 != null && p2 != null && p3 != null) {
        if (parts[0].length == 4) {
          return DateTime(p1, p2, p3);
        } else if (parts[2].length == 4) {
          return DateTime(p3, p2, p1);
        }
      }
    }

    final mMatch = RegExp(r'([A-Za-z]{3})\s+(\d{1,2}),?\s*(\d{4})').firstMatch(s);
    if (mMatch != null) {
      const months = [
        'jan', 'feb', 'mar', 'apr', 'may', 'jun',
        'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
      ];
      final monthName = mMatch.group(1)!.toLowerCase();
      final mIdx = months.indexOf(monthName);
      final day = int.tryParse(mMatch.group(2)!);
      final year = int.tryParse(mMatch.group(3)!);
      if (mIdx != -1 && day != null && year != null) {
        return DateTime(year, mIdx + 1, day);
      }
    }

    return null;
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
    final now = DateTime.now();
    final effectiveFirstDate = (_validUntil != null && _validUntil!.isBefore(now))
        ? _validUntil!
        : now.subtract(const Duration(days: 365));
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? now,
      firstDate: effectiveFirstDate,
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

  String _getAddCouponUrl() {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    final endpoint = ApiEndPoints.pharmacyAddCoupons.trim().replaceFirst(RegExp(r'^/'), '');
    return '$base/$endpoint';
  }

  String _getUpdateCouponUrl() {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    final endpoint = ApiEndPoints.pharmacyUpdateCoupon.trim().replaceFirst(RegExp(r'^/'), '');
    return '$base/$endpoint';
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final code = _code.text.trim();
    final discount = double.tryParse(_discount.text.trim());
    final count = int.tryParse(_count.text.trim());
    if (name.isEmpty ||
        code.isEmpty ||
        _kind == null ||
        discount == null ||
        count == null ||
        _validUntil == null) {
      setState(() => _error = 'Fill in every field');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final validUpto =
        "${_validUntil!.year.toString().padLeft(4, '0')}-${_validUntil!.month.toString().padLeft(2, '0')}-${_validUntil!.day.toString().padLeft(2, '0')}";
    final type = _kind == 'PERCENTAGE' ? 2 : 1;

    try {
      final token = await getSavedObject("token");
      if (token != null && token.toString().isNotEmpty) {
        DioClient().updateToken(token.toString());
      }

      Response response;

      if (_isEditing) {
        final couponId = widget.initialData!['id'] ??
            widget.initialData!['coupon_id'];

        final formData = FormData.fromMap({
          "code": code,
          "name": name,
          "type": type.toString(),
          "discount_value": _discount.text.trim(),
          "count": count.toString(),
          "valid_upto": validUpto,
          "coupon_id": couponId.toString(),
        });

        final url = _getUpdateCouponUrl();

        debugPrint("==================== POST UPDATE COUPON ====================");
        debugPrint("API Call: POST $url");
        debugPrint("FormData fields: code: $code, name: $name, type: $type, discount_value: ${_discount.text.trim()}, count: $count, valid_upto: $validUpto, coupon_id: $couponId");

        print("==================== POST UPDATE COUPON ====================");
        print("API Call: POST $url");
        print("FormData fields: code: $code, name: $name, type: $type, discount_value: ${_discount.text.trim()}, count: $count, valid_upto: $validUpto, coupon_id: $couponId");

        response = await DioClient().post(
          ApiEndPoints.pharmacyUpdateCoupon,
          body: formData,
        );

        debugPrint("Response Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.data}");
        debugPrint("==========================================================");

        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.data}");
        print("==========================================================");
      } else {
        final Map<String, dynamic> body = {
          "name": name,
          "code": code,
          "type": type,
          "discount_value": _discount.text.trim(),
          "count": count.toString(),
          "valid_upto": validUpto,
        };

        final url = _getAddCouponUrl();

        debugPrint("==================== POST ADD COUPON ====================");
        debugPrint("API Call: POST $url");
        debugPrint("Body: $body");

        print("==================== POST ADD COUPON ====================");
        print("API Call: POST $url");
        print("Body: $body");

        response = await DioClient().post(
          ApiEndPoints.pharmacyAddCoupons,
          body: body,
        );

        debugPrint("Response Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.data}");
        debugPrint("=========================================================");

        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.data}");
        print("=========================================================");
      }

      final resData = response.data;
      final bool isSuccess = resData is Map &&
          (resData['status'] == true ||
              resData['status'].toString() == 'true');

      if (isSuccess) {
        HapticFeedback.lightImpact();
        if (mounted) {
          final message = resData['message']?.toString() ??
              (_isEditing
                  ? 'Coupon updated successfully'
                  : 'Coupon added successfully');
          try {
            showToast(context, message);
          } catch (_) {}

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
      } else {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _error = resData is Map
                ? resData['message']?.toString() ??
                    (_isEditing
                        ? 'Failed to update coupon'
                        : 'Failed to add coupon')
                : (_isEditing
                    ? 'Failed to update coupon'
                    : 'Failed to add coupon');
          });
        }
      }
    } catch (e) {
      final tag = _isEditing ? "UPDATE" : "ADD";
      debugPrint("==================== POST $tag COUPON ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("===============================================================");

      print("==================== POST $tag COUPON ERROR ====================");
      print("Error: $e");
      print("===============================================================");

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = e.toString();
        });
      }
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
              _Header(title: _isEditing ? 'Update Coupon' : 'Add Coupon'),
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
                          onPressed: _isSubmitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: PharmacyAddCouponScreen.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                               : Text(
                                  _isEditing ? 'Update Coupon' : 'Add Coupon',
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
  const _Header({this.title = 'Add Coupon'});

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
