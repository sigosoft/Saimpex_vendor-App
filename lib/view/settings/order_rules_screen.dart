import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// The store's order rules, read-only (API doc §6.22, task V10): minimum
/// order value, preparation time, delivery fee and who pays it, delivery
/// model. SAIMPEX sets them in Admin. Built without a Figma screen, in the
/// style of the support screens.
class OrderRulesScreen extends StatefulWidget {
  const OrderRulesScreen({super.key});

  static void open() => Get.to(() => const OrderRulesScreen());

  @override
  State<OrderRulesScreen> createState() => _OrderRulesScreenState();
}

class _OrderRulesScreenState extends State<OrderRulesScreen> {
  static const Color _pageBg = Color(0xffFDF9F0);
  static const Color _cardBorder = Color(0xffF0ECE4);
  static const Color _text = Color(0xff111827);
  static const Color _muted = Color(0xff6B7280);
  static const Color _orange = Color(0xFFFF5216);

  Map<String, dynamic>? _rules;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      DioClient().updateToken((await getSavedObject('token'))?.toString() ?? '');
      final res = await DioClient().get(ApiEndPoints.orderRules);
      final data = res.data is Map ? res.data['data'] : null;
      if (data is Map) _rules = Map<String, dynamic>.from(data);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _num(dynamic v) {
    final d = double.tryParse(v?.toString() ?? '');
    if (d == null) return '';
    return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
  }

  String _fee(S s, Map<String, dynamic> r) {
    final value = _num(r['delivery_fee_value']);
    switch (r['delivery_fee_type']?.toString()) {
      case 'per_km':
        return s.deliveryFeePerKm(value);
      case 'fixed':
        return s.deliveryFeeFixed(value);
      case 'percent':
        return s.deliveryFeePercent(value);
      default:
        return s.deliveryFeeFree;
    }
  }

  String _paidBy(S s, Map<String, dynamic> r) {
    switch (r['delivery_fee_paid_by']?.toString()) {
      case 'vendor':
        return s.feePaidByStore;
      case 'saimpex':
        return s.feePaidBySaimpex;
      case 'split':
        return s.feePaidSplit(_num(r['delivery_fee_vendor_percent']));
      default:
        return s.feePaidByCustomer;
    }
  }

  String _model(S s, String? m) => switch (m) {
        'own' => s.deliveryModelOwn,
        'saimpex' => s.deliveryModelSaimpex,
        _ => s.deliveryModelBoth,
      };

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: appFont('Inter', fontSize: 13, color: _muted))),
            const SizedBox(width: 12),
            Flexible(
              child: Text(value, textAlign: TextAlign.end, style: appFont('Inter', fontSize: 14, fontWeight: FontWeight.w600, color: _text)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rtl = LocalizationService.currentLanguageCode == 'ar';
    final r = _rules;
    final minOrder = double.tryParse(r?['min_order_value']?.toString() ?? '') ?? 0;
    final defaultPrep = r?['default_preparation_time'];
    final effectivePrep = r?['effective_preparation_time'];
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _pageBg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      elevation: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => Get.back(),
                        child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, color: _orange)),
                      ),
                    ),
                    Expanded(
                      child: Text(s.orderRules, textAlign: TextAlign.center, style: appFont('Inter', fontSize: 18, fontWeight: FontWeight.w600, color: _text)),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: _orange))
                    : RefreshIndicator(
                        color: _orange,
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (r == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 60),
                                child: Text(_error ?? s.orderRulesUnavailable, textAlign: TextAlign.center, style: appFont('Inter', fontSize: 14, color: _muted)),
                              )
                            else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: _cardBorder),
                                ),
                                child: Column(
                                  children: [
                                    _row(s.minimumOrderValue, minOrder > 0 ? '${_num(minOrder)} MRU' : s.noMinimum),
                                    if (effectivePrep != null || defaultPrep != null)
                                      _row(s.defaultPreparationTime, s.minutesShort(_num(defaultPrep ?? effectivePrep))),
                                    _row(s.deliveryFeeLabel, _fee(s, r)),
                                    _row(s.deliveryFeePaidBy, _paidBy(s, r)),
                                    _row(s.deliveryModel, _model(s, r['delivery_model']?.toString())),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(s.orderRulesSetBySaimpex, style: appFont('Inter', fontSize: 12, color: _muted)),
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
