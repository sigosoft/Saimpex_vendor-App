import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:dio/dio.dart' show FormData;
import 'package:saimpex_vendor/water/core/water_api.dart';
import 'package:saimpex_vendor/water/core/water_state_view.dart';
import 'package:saimpex_vendor/water/view/account/add_coupon_view.dart';

class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF10182B);
  static const slate = Color(0xFF2E3545);
  static const muted = Color(0xFF8A8D96);

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CouponsView()),
    );
  }

  @override
  State<CouponsView> createState() => _CouponsViewState();
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
    required this.draft,
    this.active = true,
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

  /// Raw values for the edit form.
  final WaterCouponDraft draft;
  bool active;
}

class _CouponsViewState extends State<CouponsView> {
  final _search = TextEditingController();
  bool _isLoading = true;
  String? _error;
  List<_Coupon> _coupons = [];

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await getSavedObject('token');
      if (token == null ||
          token.toString() == 'null' ||
          token.toString().isEmpty ||
          token.toString() == 'home_cleaning_mock_token') {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _coupons = [];
          });
        }
        return;
      }
      DioClient().updateToken(token.toString());

      debugPrint("==================== GET COUPONS ====================");
      debugPrint("Endpoint: ${ApiEndPoints.coupons}");

      final response = await DioClient().get(
        ApiEndPoints.coupons,
        query: {"limit": "50"},
      );

      debugPrint("==================== GET COUPONS RESPONSE ====================");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Data: ${response.data}");

      List<dynamic> rawList = [];
      if (response.data is Map) {
        final data = response.data['data'];
        if (data is Map) {
          if (data['coupons'] is Map && data['coupons']['data'] is List) {
            rawList = data['coupons']['data'] as List;
          } else if (data['coupons'] is List) {
            rawList = data['coupons'] as List;
          } else if (data['data'] is List) {
            rawList = data['data'] as List;
          }
        } else if (data is List) {
          rawList = data;
        } else if (response.data['coupons'] is List) {
          rawList = response.data['coupons'] as List;
        }
      }

      if (!mounted) return;
      final lang = Localizations.localeOf(context).languageCode;
      final List<_Coupon> loaded = [];
      for (final item in rawList) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final id = map['id'];
          final String? localName = map['name_$lang']?.toString();
          final String name = (localName != null && localName.trim().isNotEmpty ? localName : null) ??
              map['name_en']?.toString() ??
              map['name_ar']?.toString() ??
              map['name_fr']?.toString() ??
              map['name']?.toString() ??
              map['title']?.toString() ??
              S.current.waterNotAvailable;
          final int statusInt = int.tryParse(map['status']?.toString() ?? '0') ?? 0;
          final bool active = statusInt == 1 ||
              map['status'] == true ||
              map['status']?.toString() == '1';
          final String code = map['code']?.toString() ?? S.current.waterNotAvailable;

          // `type`: 1 fixed amount, 2 percentage.
          final int typeInt = int.tryParse(map['type']?.toString() ?? '1') ?? 1;
          final String kind = typeInt == 2 ? 'PERCENTAGE' : 'AMOUNT';
          final String discountValue = map['discount_value']?.toString() ?? '';
          final double? discountNum = double.tryParse(discountValue);
          final String discount = discountNum == null
              ? S.current.waterNotAvailable
              : (typeInt == 2
                  ? '${discountNum.toStringAsFixed(discountNum % 1 == 0 ? 0 : 2)}%'
                  : WaterApi.money(discountNum));
          final String rawCount = map['count']?.toString() ?? '';
          final String count =
              (rawCount.isEmpty || rawCount == 'null') ? S.current.waterNotAvailable : rawCount;
          final DateTime? validDate = WaterApi.parseDate(map['valid_upto']);
          final String validUntil = validDate == null
              ? S.current.waterNotAvailable
              : WaterApi.formatDate(map['valid_upto']);
          final String createdOn = map['formatted_created_on']?.toString() ??
              S.current.waterNotAvailable;
          final String updatedOn = map['formatted_updated_on']?.toString() ??
              S.current.waterNotAvailable;
          final draft = WaterCouponDraft(
            id: id,
            name: map['name_en']?.toString() ?? name,
            code: code == S.current.waterNotAvailable ? '' : code,
            type: typeInt,
            discount: discountNum == null
                ? ''
                : discountNum.toStringAsFixed(discountNum % 1 == 0 ? 0 : 2),
            count: (rawCount.isEmpty || rawCount == 'null') ? '' : rawCount,
            validUntil: validDate,
          );

          loaded.add(
            _Coupon(
              id: id,
              name: name,
              code: code,
              kind: kind,
              discount: discount,
              count: count,
              validUntil: validUntil,
              createdOn: createdOn,
              updatedOn: updatedOn,
              draft: draft,
              active: active,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _coupons = loaded;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching coupons: $e");
      if (mounted) {
        setState(() {
          _coupons = [];
          _error = WaterApi.errorText(e);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openForm([WaterCouponDraft? initial]) async {
    final saved = await AddCouponView.open(context, initial: initial);
    if (saved == true && mounted) _fetchCoupons();
  }

  /// Runs a coupon action; on success shows the server message and reloads.
  Future<void> _run(Future<dynamic> Function() call) async {
    showLoadingDialog(context);
    String? message;
    bool ok = false;
    try {
      await WaterApi.prepare();
      final response = await call();
      final data = response.data;
      ok = WaterApi.isOk(data);
      message = WaterApi.message(data);
    } catch (e) {
      message = WaterApi.errorText(e);
    }
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    final text = message ?? (ok ? null : S.current.waterSomethingWentWrong);
    if (text != null) showToast(context, text);
    if (ok) _fetchCoupons();
  }

  /// `GET updateCouponStatus?coupon_id=&status=` (1 active, 2 blocked).
  Future<void> _setStatus(_Coupon coupon, bool active) => _run(
        () => DioClient().get(
          ApiEndPoints.updateCouponStatus,
          query: {'coupon_id': coupon.id, 'status': active ? 1 : 2},
        ),
      );

  /// `POST deleteCoupon` {coupon_id}.
  Future<void> _delete(_Coupon coupon) => _run(
        () => DioClient().post(
          ApiEndPoints.deleteCoupon,
          body: FormData.fromMap({'coupon_id': coupon.id.toString()}),
        ),
      );

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
              coupon.name.toLowerCase().contains(query) || coupon.code.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final coupons = _visible;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
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
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: RefreshIndicator(
                  color: CouponsView.orange,
                  onRefresh: _fetchCoupons,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _search,
                              onChanged: (_) => setState(() {}),
                              style: GoogleFonts.inter(
                                color: CouponsView.ink,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: S.of(context).searchCoupon,
                                hintStyle: GoogleFonts.inter(
                                  color: const Color(0xFFA9AEB6),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFFA9AEB6)),
                                filled: true,
                                fillColor: Colors.white,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                              onPressed: () => _openForm(),
                              style: FilledButton.styleFrom(
                                backgroundColor: CouponsView.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const _AddPlusIcon(),
                                  const SizedBox(width: 6),
                                  Text(
                                    S.of(context).addCoupon,
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (!_isLoading && _error != null && _coupons.isEmpty)
                        WaterStateView.error(message: _error!, onRetry: _fetchCoupons)
                      else if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: CouponsView.orange,
                            ),
                          ),
                        )
                      else if (coupons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'lib/assets/images/nodata.png',
                                  height: 120,
                                  width: 140,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  S.of(context).noCouponsFound,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: CouponsView.ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  S.of(context).waterCreatedCouponsAppearHere,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: CouponsView.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                      ? S.of(context).areYouSureYouWantToBlockThisCoupon
                                      : S.of(context).areYouSureYouWantToActivateThisCoupon,
                                  yesColor: const Color(0xFFFF5317),
                                ),
                              );
                              if (confirmed != true || !mounted) return;
                              HapticFeedback.lightImpact();
                              await _setStatus(coupon, !blocking);
                            },
                            onEdit: () => _openForm(coupon.draft),
                            onDelete: () {
                              HapticFeedback.lightImpact();
                              _delete(coupon);
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                    ],
                  ),
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
              S.of(context).coupons,
              style: GoogleFonts.inter(
                color: const Color(0xFF1C1D1B),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
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
                    color: CouponsView.orange,
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
    required this.onEdit,
    required this.onDelete,
  });

  final _Coupon coupon;
  final VoidCallback onUpdateStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F1F3)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 6)),
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
                    color: CouponsView.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              _Pill(
                text: coupon.active ? S.of(context).active : S.of(context).inactive,
                background: coupon.active ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
                foreground: coupon.active ? const Color(0xFF059669) : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Builder(
                builder: (iconContext) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _showCouponMenu(iconContext, onEdit: onEdit, onDelete: onDelete);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(2, 1, 0, 2),
                      child: Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)),
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
                '${S.of(context).codeLabel}: ',
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
                text: _kindLabel(context, coupon.kind),
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
              Expanded(child: _Stat(label: S.of(context).discountLabel, value: coupon.discount)),
              const _StatDivider(),
              Expanded(child: _Stat(label: S.of(context).countLabel, value: coupon.count)),
              const _StatDivider(),
              Expanded(child: _Stat(label: S.of(context).validUptoLabel, value: coupon.validUntil)),
            ],
          ),
          const SizedBox(height: 14),
          const _DashedLine(),
          const SizedBox(height: 14),
          _MetaRow(label: '${S.of(context).createdOnLabel}:', value: coupon.createdOn),
          const SizedBox(height: 8),
          _MetaRow(label: '${S.of(context).updatedOnLabel}:', value: coupon.updatedOn),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onUpdateStatus,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF5418),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                S.of(context).updateCouponStatus,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _kindLabel(BuildContext context, String kind) {
  final upper = kind.toUpperCase();
  if (upper.contains('PERCENT')) return S.of(context).percentage.toUpperCase();
  if (upper == 'AMOUNT') return S.of(context).amount.toUpperCase();
  if (upper == 'FLAT') return S.of(context).waterFlat.toUpperCase();
  return kind;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.background, required this.foreground});

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
            color: CouponsView.orange,
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
  final isRtl = Directionality.of(iconContext) == TextDirection.rtl;

  showGeneralDialog<void>(
    context: iconContext,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(iconContext).closeButtonLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              top: origin.dy - 4,
              left: isRtl ? origin.dx + box.size.width + 6 : null,
              right: isRtl ? null : screen.width - origin.dx + 6,
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

Future<void> _confirmDeleteCoupon(BuildContext context, VoidCallback onDelete) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x80000000),
    builder: (context) => _CouponConfirmDialog(
      message: S.of(context).areYouSureYouWantToDeleteThisCoupon,
      yesColor: const Color(0xFFFF3939),
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
              alignment: AlignmentDirectional.centerEnd,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(false),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE7E7E7)),
                  ),
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF7F7F7F)),
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
                        side: const BorderSide(color: Color(0xFFFF7F52), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        S.of(context).no,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        S.of(context).yes,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
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
          BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CouponMenuRow(icon: Icons.edit_outlined, label: S.of(context).edit, onTap: onEdit),
          _CouponMenuRow(label: S.of(context).delete, onTap: onDelete, leading: const _MenuDeleteIcon()),
        ],
      ),
    );
  }
}

class _CouponMenuRow extends StatelessWidget {
  const _CouponMenuRow({required this.label, required this.onTap, this.icon, this.leading});

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
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC5C8CE)),
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

class _MenuDeleteIconState extends State<_MenuDeleteIcon> with SingleTickerProviderStateMixin {
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
      Rect.fromLTWH(size.width * 0.18, size.height * 0.36, size.width * 0.64, size.height * 0.56),
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
    for (final x in [body.left + body.width * 0.35, body.left + body.width * 0.65]) {
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
        Rect.fromLTWH(size.width * 0.38, size.height * 0.12, size.width * 0.24, size.height * 0.18),
        const Radius.circular(1),
      ),
      stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MenuDeletePainter oldDelegate) => oldDelegate.lidOpen != lidOpen;
}

class _AddPlusIcon extends StatelessWidget {
  const _AddPlusIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 13,
      height: 13,
      child: CustomPaint(painter: _AddPlusPainter()),
    );
  }
}

class _AddPlusPainter extends CustomPainter {
  const _AddPlusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.4;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;
    final midX = size.width / 2;
    final midY = size.height / 2;
    final inset = stroke / 2;
    canvas.drawLine(Offset(inset, midY), Offset(size.width - inset, midY), paint);
    canvas.drawLine(Offset(midX, inset), Offset(midX, size.height - inset), paint);
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
            color: CouponsView.muted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            color: CouponsView.slate,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
