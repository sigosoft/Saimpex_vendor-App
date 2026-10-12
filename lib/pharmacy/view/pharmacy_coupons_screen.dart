import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_add_coupon_screen.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/widgets/no_data_widget.dart';

class PharmacyCouponsScreen extends StatefulWidget {
  const PharmacyCouponsScreen({super.key, this.initialCoupons});

  final List<dynamic>? initialCoupons;

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF10182B);
  static const slate = Color(0xFF2E3545);
  static const muted = Color(0xFF8A8D96);

  @override
  State<PharmacyCouponsScreen> createState() => _PharmacyCouponsScreenState();
}

class _Coupon {
  _Coupon({
    this.id,
    required this.name,
    required this.code,
    required this.kind,
    required this.discount,
    required this.count,
    required this.validUntil,
    required this.createdOn,
    required this.updatedOn,
    this.active = true,
    this.rawMap,
  });

  final dynamic id;
  final String name;
  final String code;
  final String kind;
  final String discount;
  final String count;
  final String validUntil;
  final String createdOn;
  final String updatedOn;
  bool active = true;
  final Map<String, dynamic>? rawMap;

  Map<String, dynamic> toMap() {
    if (rawMap != null) {
      final map = Map<String, dynamic>.from(rawMap!);
      map['id'] = id ?? map['id'];
      map['name'] = name;
      map['code'] = code;
      return map;
    }
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': kind == 'PERCENTAGE' ? '2' : '1',
      'discount_value': discount
          .replaceAll('%', '')
          .replaceAll('MRU', '')
          .trim(),
      'count': count,
      'valid_upto': validUntil,
    };
  }

  factory _Coupon.fromMap(Map<String, dynamic> raw) {
    final name =
        raw['name']?.toString() ??
        raw['name_en']?.toString() ??
        raw['name_ar']?.toString() ??
        raw['name_fr']?.toString() ??
        'Coupon';
    final code = raw['code']?.toString() ?? '';
    final typeRaw = raw['type']?.toString().toLowerCase() ?? '';
    final isPercentage = typeRaw == '2' || typeRaw.contains('percent');
    final kind = isPercentage ? 'PERCENTAGE' : 'AMOUNT';

    final discountVal =
        raw['discount_value']?.toString() ?? raw['discount']?.toString() ?? '0';
    final discount = isPercentage
        ? (discountVal.endsWith('%') ? discountVal : '$discountVal%')
        : discountVal;
    final count =
        raw['count']?.toString() ?? raw['usage_limit']?.toString() ?? '0';

    final validUntilRaw =
        raw['valid_upto']?.toString() ??
        raw['valid_until']?.toString() ??
        raw['expiry_date']?.toString() ??
        'N/A';
    final validUntil = _formatDate(validUntilRaw);

    final createdOn =
        raw['formatted_created_on']?.toString() ??
        raw['created_at']?.toString() ??
        raw['created_on']?.toString() ??
        'N/A';
    final updatedOn =
        raw['formatted_updated_on']?.toString() ??
        raw['updated_at']?.toString() ??
        raw['updated_on']?.toString() ??
        createdOn;

    final statusVal = raw['status'];
    final active =
        statusVal == 1 ||
        statusVal == '1' ||
        statusVal == true ||
        statusVal == 'true' ||
        statusVal == 'active';

    return _Coupon(
      id: raw['id'],
      name: name,
      code: code,
      kind: kind,
      discount: discount,
      count: count,
      validUntil: validUntil,
      createdOn: createdOn,
      updatedOn: updatedOn,
      active: active,
      rawMap: raw,
    );
  }

  static String _formatDate(String dateStr) {
    final s = dateStr.trim();
    if (s.isEmpty || s == 'N/A') return 'N/A';
    try {
      final dt = DateTime.tryParse(s);
      if (dt != null) {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        final m = months[dt.month - 1];
        final d = dt.day.toString().padLeft(2, '0');
        final y = dt.year;
        return '$m $d, $y';
      }
    } catch (_) {}
    return s;
  }
}

class _PharmacyCouponsScreenState extends State<PharmacyCouponsScreen> {
  final _search = TextEditingController();
  late List<_Coupon> _coupons;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCoupons != null) {
      _coupons = widget.initialCoupons!
          .whereType<Map>()
          .map((item) => _Coupon.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      _coupons = [];
      _fetchCoupons();
    }
  }

  Future<void> _fetchCoupons({
    int limit = 10,
    String keyword = "",
    dynamic status = 1,
  }) async {
    setState(() => _isLoading = true);
    try {
      final token = await getSavedObject("token");
      if (token != null && token.toString().isNotEmpty) {
        DioClient().updateToken(token.toString());
      }
      final queryParams = <String, dynamic>{
        "limit": limit,
        "keyword": keyword,
        "status": status,
      };
      final response = await DioClient().get(
        ApiEndPoints.pharmacyCoupons,
        query: queryParams,
      );
      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final data = response.data['data'];
        List<dynamic> list = [];
        if (data is Map) {
          final coupons = data['coupons'];
          if (coupons is List) {
            list = coupons;
          } else if (coupons is Map && coupons['data'] is List) {
            list = coupons['data'] as List;
          }
        } else if (data is List) {
          list = data;
        }
        if (mounted) {
          setState(() {
            _coupons = list
                .whereType<Map>()
                .map((e) => _Coupon.fromMap(Map<String, dynamic>.from(e)))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching pharmacy coupons: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getUpdateCouponStatusUrl(Map<String, dynamic> query) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.pharmacyUpdateCouponStatus
        .trim()
        .replaceFirst(RegExp(r'^/'), '');
    final q = query.entries.map((e) => "${e.key}=${e.value}").join('&');
    return '$base/$endpoint?$q';
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_Coupon> get _visible {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _coupons;
    return _coupons
        .where(
          (coupon) =>
              coupon.name.toLowerCase().contains(query) ||
              coupon.code.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final coupons = _visible;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE8E0), Color(0xFFFFF4EF), Colors.white],
              stops: [0, 0.2, 0.38],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _search,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.inter(
                              color: PharmacyCouponsScreen.ink,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search Coupon',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFFA9AEB6),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 18,
                                color: Color(0xFFA9AEB6),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: _fieldBorder,
                              enabledBorder: _fieldBorder,
                              focusedBorder: _fieldBorder,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 44,
                          child: FilledButton(
                            onPressed: () async {
                              final draft = await Navigator.of(context)
                                  .push<PharmacyCouponDraft>(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PharmacyAddCouponScreen(),
                                    ),
                                  );
                              if (draft == null || !mounted) return;
                              setState(() {
                                _coupons.insert(
                                  0,
                                  _Coupon(
                                    name: draft.name,
                                    code: draft.code,
                                    kind: draft.kind,
                                    discount: draft.discount,
                                    count: draft.count,
                                    validUntil: draft.validUntil,
                                    createdOn: draft.createdOn,
                                    updatedOn: draft.createdOn,
                                  ),
                                );
                              });
                              _fetchCoupons();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: PharmacyCouponsScreen.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const _AddPlusIcon(),
                                const SizedBox(width: 6),
                                Text(
                                  'Add Coupon',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: PharmacyCouponsScreen.orange,
                          ),
                        ),
                      )
                    else if (coupons.isEmpty)
                      NoDataWidget(
                        context,
                        S.of(context).noCouponsFound,
                        "",
                        "lib/assets/images/nodata.png",
                      )
                    else
                      for (final coupon in coupons) ...[
                        _CouponCard(
                          coupon: coupon,
                          onUpdateStatus: () async {
                            final blocking = coupon.active;
                            final confirmed = await showDialog<bool>(
                              context: context,
                              barrierColor: const Color(0x80000000),
                              builder: (context) => _CouponConfirmDialog(
                                message: blocking
                                    ? 'Are you sure you want to block this\nCoupon?'
                                    : 'Are you sure you want to unblock this\nCoupon?',
                                yesColor: const Color(0xFFFF5317),
                              ),
                            );
                            if (confirmed != true || !mounted) return;
                            HapticFeedback.lightImpact();

                            final couponId = coupon.id;
                            if (couponId == null) {
                              setState(() => coupon.active = !coupon.active);
                              return;
                            }

                            final newStatus = blocking ? 2 : 1;
                            final Map<String, dynamic> query = {
                              "coupon_id": couponId.toString(),
                              "status": newStatus.toString(),
                            };

                            final url = _getUpdateCouponStatusUrl(query);
                            debugPrint(
                              "==================== GET UPDATE COUPON STATUS ====================",
                            );
                            debugPrint("API Call: GET $url");
                            debugPrint("Query: $query");

                            print(
                              "==================== GET UPDATE COUPON STATUS ====================",
                            );
                            print("API Call: GET $url");
                            print("Query: $query");

                            try {
                              final token = await getSavedObject("token");
                              if (token != null &&
                                  token.toString().isNotEmpty) {
                                DioClient().updateToken(token.toString());
                              }

                              final response = await DioClient().get(
                                ApiEndPoints.pharmacyUpdateCouponStatus,
                                query: query,
                              );

                              debugPrint(
                                "Response Status Code: ${response.statusCode}",
                              );
                              debugPrint("Response Body: ${response.data}");
                              debugPrint(
                                "==================================================================",
                              );

                              print(
                                "Response Status Code: ${response.statusCode}",
                              );
                              print("Response Body: ${response.data}");
                              print(
                                "==================================================================",
                              );

                              final resData = response.data;
                              final bool isSuccess =
                                  resData is Map &&
                                  (resData['status'] == true ||
                                      resData['status'].toString() == 'true');

                              if (isSuccess) {
                                if (mounted) {
                                  final message =
                                      resData['message']?.toString() ??
                                      (blocking
                                          ? 'Coupon blocked successfully.'
                                          : 'Coupon unblocked successfully.');
                                  try {
                                    showToast(context, message);
                                  } catch (_) {}
                                  setState(() => coupon.active = !blocking);
                                  _fetchCoupons();
                                }
                              } else {
                                if (mounted) {
                                  final message = resData is Map
                                      ? resData['message']?.toString() ??
                                            'Failed to update coupon status'
                                      : 'Failed to update coupon status';
                                  try {
                                    showToast(context, message);
                                  } catch (_) {}
                                }
                              }
                            } catch (e) {
                              debugPrint(
                                "==================== GET UPDATE COUPON STATUS ERROR ====================",
                              );
                              debugPrint("Error: $e");
                              debugPrint(
                                "=======================================================================",
                              );

                              print(
                                "==================== GET UPDATE COUPON STATUS ERROR ====================",
                              );
                              print("Error: $e");
                              print(
                                "=======================================================================",
                              );

                              if (mounted) {
                                try {
                                  showToast(context, e.toString());
                                } catch (_) {}
                              }
                            }
                          },
                          onEdit: () async {
                            final draft = await Navigator.of(context)
                                .push<PharmacyCouponDraft>(
                                  MaterialPageRoute(
                                    builder: (_) => PharmacyAddCouponScreen(
                                      initialData: coupon.toMap(),
                                    ),
                                  ),
                                );
                            if (!mounted) return;
                            if (draft != null) {
                              setState(() {
                                final idx = _coupons.indexOf(coupon);
                                if (idx != -1) {
                                  _coupons[idx] = _Coupon(
                                    id: coupon.id,
                                    name: draft.name,
                                    code: draft.code,
                                    kind: draft.kind,
                                    discount: draft.discount,
                                    count: draft.count,
                                    validUntil: draft.validUntil,
                                    createdOn: coupon.createdOn,
                                    updatedOn: 'Today',
                                    active: coupon.active,
                                    rawMap: coupon.rawMap,
                                  );
                                }
                              });
                            }
                            _fetchCoupons();
                          },
                          onDelete: () {
                            HapticFeedback.lightImpact();
                            setState(() => _coupons.remove(coupon));
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
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

const _fieldBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide(color: Color(0xFFE6E8EC)),
);

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
              'Coupons',
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
                    color: PharmacyCouponsScreen.orange,
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

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.onUpdateStatus,
    required this.onDelete,
    required this.onEdit,
  });

  final _Coupon coupon;
  final VoidCallback onUpdateStatus;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F1F3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  coupon.name,
                  style: GoogleFonts.inter(
                    color: PharmacyCouponsScreen.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              _Pill(
                text: coupon.active ? 'ACTIVE' : 'INACTIVE',
                background: coupon.active
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFF3F4F6),
                foreground: coupon.active
                    ? const Color(0xFF059669)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Builder(
                builder: (iconContext) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _showCouponMenu(
                        iconContext,
                        onEdit: onEdit,
                        onDelete: onDelete,
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(2, 1, 0, 2),
                      child: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'CODE: ',
                style: GoogleFonts.inter(
                  color: const Color(0xFF4C5260),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                coupon.code,
                style: GoogleFonts.inter(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              _Pill(
                text: coupon.kind,
                background: const Color(0xFFFFCDBC),
                foreground: const Color(0xFFFF5317),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _DashedLine(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Stat(label: 'DISCOUNT', value: coupon.discount),
              ),
              const _StatDivider(),
              Expanded(
                child: _Stat(label: 'COUNT', value: coupon.count),
              ),
              const _StatDivider(),
              Expanded(
                child: _Stat(label: 'VALID UPTO', value: coupon.validUntil),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _DashedLine(),
          const SizedBox(height: 14),
          _MetaRow(label: 'CREATED ON:', value: coupon.createdOn),
          const SizedBox(height: 8),
          _MetaRow(label: 'UPDATED ON:', value: coupon.updatedOn),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onUpdateStatus,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF5418),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Update Coupon Status',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF8D8A95),
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: PharmacyCouponsScreen.orange,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: const Color(0xFFE4E5E8));
  }
}

void _showCouponMenu(
  BuildContext iconContext, {
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final box = iconContext.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return;
  final origin = box.localToGlobal(Offset.zero);
  final screen = MediaQuery.sizeOf(iconContext);

  showGeneralDialog<void>(
    context: iconContext,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              top: origin.dy - 4,
              right: screen.width - origin.dx + 6,
              child: _CouponMenu(
                onEdit: () {
                  Navigator.of(dialogContext).pop();
                  onEdit();
                },
                onDelete: () {
                  Navigator.of(dialogContext).pop();
                  _confirmDeleteCoupon(iconContext, onDelete);
                },
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

Future<void> _confirmDeleteCoupon(
  BuildContext context,
  VoidCallback onDelete,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x80000000),
    builder: (context) => const _CouponConfirmDialog(
      message: 'Are you sure you want to delete this\nCoupon?',
      yesColor: Color(0xFFFF3939),
    ),
  );
  if (confirmed == true) onDelete();
}

class _CouponConfirmDialog extends StatelessWidget {
  const _CouponConfirmDialog({required this.message, required this.yesColor});

  final String message;
  final Color yesColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 10,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(false),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Color(0xFF7F7F7F),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF4A4A4A),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF5317),
                        side: const BorderSide(
                          color: Color(0xFFFF7F52),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'No',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: yesColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
    );
  }
}

class _CouponMenu extends StatelessWidget {
  const _CouponMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CouponMenuRow(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: onEdit,
          ),
          _CouponMenuRow(
            label: 'Delete',
            onTap: onDelete,
            leading: const _MenuDeleteIcon(),
          ),
        ],
      ),
    );
  }
}

class _CouponMenuRow extends StatelessWidget {
  const _CouponMenuRow({
    required this.label,
    required this.onTap,
    this.icon,
    this.leading,
  });

  final IconData? icon;
  final Widget? leading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
          child: Row(
            children: [
              leading ?? Icon(icon, size: 16, color: const Color(0xFF6B7280)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF10182B),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFFC5C8CE),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuDeleteIcon extends StatefulWidget {
  const _MenuDeleteIcon();

  @override
  State<_MenuDeleteIcon> createState() => _MenuDeleteIconState();
}

class _MenuDeleteIconState extends State<_MenuDeleteIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _lidOpen(double t) {
    if (t < 0.35) return Curves.easeOutCubic.transform(t / 0.35);
    if (t < 0.55) return 1;
    if (t < 0.90) return 1 - Curves.easeInCubic.transform((t - 0.55) / 0.35);
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _MenuDeletePainter(lidOpen: _lidOpen(_controller.value)),
          );
        },
      ),
    );
  }
}

class _MenuDeletePainter extends CustomPainter {
  const _MenuDeletePainter({required this.lidOpen});

  final double lidOpen;

  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF6B7280);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.36,
        size.width * 0.64,
        size.height * 0.56,
      ),
      bottomLeft: const Radius.circular(1.6),
      bottomRight: const Radius.circular(1.6),
    );
    canvas.drawRRect(body, stroke);

    final slot = Paint()
      ..color = color
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final slotTop = body.top + body.height * 0.22;
    final slotBottom = body.bottom - body.height * 0.22;
    for (final x in [
      body.left + body.width * 0.35,
      body.left + body.width * 0.65,
    ]) {
      canvas.drawLine(Offset(x, slotTop), Offset(x, slotBottom), slot);
    }

    final hinge = Offset(size.width * 0.08, size.height * 0.30);
    canvas.save();
    canvas.translate(hinge.dx, hinge.dy);
    canvas.rotate(-0.85 * lidOpen);
    canvas.translate(-hinge.dx, -hinge.dy);
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.30),
      Offset(size.width * 0.92, size.height * 0.30),
      stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.38,
          size.height * 0.12,
          size.width * 0.24,
          size.height * 0.18,
        ),
        const Radius.circular(1),
      ),
      stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MenuDeletePainter oldDelegate) =>
      oldDelegate.lidOpen != lidOpen;
}

class _AddPlusIcon extends StatelessWidget {
  const _AddPlusIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 12,
      height: 12,
      child: CustomPaint(painter: _AddPlusPainter()),
    );
  }
}

class _AddPlusPainter extends CustomPainter {
  const _AddPlusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;
    final midX = size.width / 2;
    final midY = size.height / 2;
    final inset = stroke / 2;
    canvas.drawLine(
      Offset(inset, midY),
      Offset(size.width - inset, midY),
      paint,
    );
    canvas.drawLine(
      Offset(midX, inset),
      Offset(midX, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AddPlusPainter oldDelegate) => false;
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter()),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD8D9DC)
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      final end = (x + dash).clamp(0, size.width).toDouble();
      canvas.drawLine(Offset(x, 0), Offset(end, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) => false;
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: PharmacyCouponsScreen.muted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            color: PharmacyCouponsScreen.slate,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
