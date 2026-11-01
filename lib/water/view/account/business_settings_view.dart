import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';

class BusinessSettingsView extends StatefulWidget {
  const BusinessSettingsView({super.key});

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF2E3545);

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BusinessSettingsView()),
    );
  }

  @override
  State<BusinessSettingsView> createState() => _BusinessSettingsViewState();
}

class _BusinessSettingsViewState extends State<BusinessSettingsView> {
  bool _storeOpen = true;
  bool _acceptingOrders = true;
  bool _storeBusy = false;
  bool _expressAvailable = true;
  List<_Distance> _ranges = [];

  @override
  void initState() {
    super.initState();
    _fetchBusinessSettings();
  }

  Future<void> _fetchBusinessSettings() async {
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      } else {
        return;
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorTypeStr =
          (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
                ? savedAppType.toString()
                : "1");
      final vendorType = int.tryParse(vendorTypeStr) ?? 1;

      final queryParams = <String, dynamic>{"vendor_type": vendorType};

      debugPrint(
        "==================== GET BUSINESS SETTINGS ====================",
      );
      debugPrint("Endpoint: ${ApiEndPoints.BusinessSettings}");
      debugPrint("Query: $queryParams");

      print("==================== GET BUSINESS SETTINGS ====================");
      print("Endpoint: ${ApiEndPoints.BusinessSettings}");
      print("Query: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.BusinessSettings,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "===============================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("===============================================================");

      if (mounted) {
        _parseAndApplySettings(response.data);
      }
    } catch (e) {
      debugPrint(
        "==================== GET BUSINESS SETTINGS ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "=====================================================================",
      );

      print(
        "==================== GET BUSINESS SETTINGS ERROR ====================",
      );
      print("Error: $e");
      print(
        "=====================================================================",
      );
    }
  }

  void _parseAndApplySettings(dynamic rawData) {
    Map<String, dynamic>? dataMap;
    if (rawData is Map<String, dynamic>) {
      dataMap = rawData;
    } else if (rawData is Map) {
      dataMap = Map<String, dynamic>.from(rawData);
    } else if (rawData is String) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map) {
          dataMap = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    if (dataMap == null) return;

    Map<String, dynamic> target = dataMap;
    if (dataMap['data'] is Map) {
      final inner = Map<String, dynamic>.from(dataMap['data'] as Map);
      target = inner;
      if (inner['business_settings'] is Map) {
        target = Map<String, dynamic>.from(inner['business_settings'] as Map);
      } else if (inner['settings'] is Map) {
        target = Map<String, dynamic>.from(inner['settings'] as Map);
      } else if (inner['vendor'] is Map) {
        target = Map<String, dynamic>.from(inner['vendor'] as Map);
      }
    }

    setState(() {
      // 1. Store Status (Open)
      final dynamic storeOpenVal =
          target['store_open'] ??
          target['store_status'] ??
          target['is_store_open'] ??
          target['is_open'] ??
          target['open_status'] ??
          target['open'];
      if (storeOpenVal != null) {
        if (storeOpenVal is bool) {
          _storeOpen = storeOpenVal;
        } else {
          final s = storeOpenVal.toString().trim().toLowerCase();
          _storeOpen = s == '1' || s == 'true' || s == 'open';
        }
      }

      // 2. Accepting Orders
      final dynamic acceptVal =
          target['accepting_orders'] ??
          target['is_accepting_orders'] ??
          target['accept_orders'] ??
          target['orders_accepted'];
      if (acceptVal != null) {
        if (acceptVal is bool) {
          _acceptingOrders = acceptVal;
        } else {
          final s = acceptVal.toString().trim().toLowerCase();
          _acceptingOrders = s == '1' || s == 'true';
        }
      }

      // 3. Mark Store Busy (1 = Busy, 2/0 = Not Busy)
      final dynamic busyVal =
          target['is_busy'] ??
          target['store_busy'] ??
          target['is_store_busy'] ??
          target['busy'];
      if (busyVal != null) {
        if (busyVal is bool) {
          _storeBusy = busyVal;
        } else {
          final s = busyVal.toString().trim().toLowerCase();
          _storeBusy = s == '1' || s == 'true';
        }
      }

      // 4. Express Delivery Available
      final dynamic expressVal =
          target['express_delivery'] ??
          target['is_express'] ??
          target['express_available'] ??
          target['express_delivery_status'] ??
          target['is_express_delivery'];
      if (expressVal != null) {
        if (expressVal is bool) {
          _expressAvailable = expressVal;
        } else {
          final s = expressVal.toString().trim().toLowerCase();
          _expressAvailable = s == '1' || s == 'true';
        }
      }

      // 5. Distance Ranges / Pricing
      final dynamic rangesVal =
          target['pricing'] ??
          target['distance_ranges'] ??
          target['ranges'] ??
          target['express_pricing'] ??
          target['distance_pricing'] ??
          target['delivery_ranges'] ??
          dataMap?['data']?['pricing'] ??
          dataMap?['data']?['distance_ranges'];

      if (rangesVal is List) {
        final List<_Distance> parsedRanges = [];
        for (final item in rangesVal) {
          if (item is Map) {
            final minVal =
                item['min'] ??
                item['min_distance'] ??
                item['from'] ??
                item['min_km'] ??
                item['start'];
            final maxVal =
                item['max'] ??
                item['max_distance'] ??
                item['to'] ??
                item['max_km'] ??
                item['end'];
            final priceVal =
                item['price'] ??
                item['delivery_charge'] ??
                item['amount'] ??
                item['cost'] ??
                item['rate'];

            final min =
                int.tryParse(minVal?.toString() ?? '') ??
                double.tryParse(minVal?.toString() ?? '')?.toInt();
            final max =
                int.tryParse(maxVal?.toString() ?? '') ??
                double.tryParse(maxVal?.toString() ?? '')?.toInt();
            final price =
                int.tryParse(priceVal?.toString() ?? '') ??
                double.tryParse(priceVal?.toString() ?? '')?.toInt();

            if (min != null && max != null && price != null) {
              parsedRanges.add(_Distance(min: min, max: max, price: price));
            }
          }
        }
        _ranges = parsedRanges;
      }
    });
  }

  String _extractMessage(dynamic resData, String defaultMessage) {
    if (resData is Map && resData['message'] != null) {
      final msg = resData['message'];
      if (msg is Map) {
        String lang = 'en';
        try {
          lang =
              FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
        } catch (_) {}
        final key = lang == 'ar'
            ? 'message_ar'
            : lang == 'fr'
            ? 'message_fr'
            : 'message_en';
        if (msg[key] != null) {
          final raw = msg[key];
          if (raw is List && raw.isNotEmpty) {
            return raw.first.toString();
          }
          return raw.toString();
        }
        if (msg['message_en'] != null) {
          final raw = msg['message_en'];
          if (raw is List && raw.isNotEmpty) {
            return raw.first.toString();
          }
          return raw.toString();
        }
      } else if (msg is String && msg.trim().isNotEmpty) {
        return msg.trim();
      }
    }
    return defaultMessage;
  }

  Future<bool> _updateBusinessSettings() async {
    showLoadingDialog(context);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorTypeStr =
          (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
                ? savedAppType.toString()
                : "1");
      final vendorType = int.tryParse(vendorTypeStr) ?? 1;

      final pricingPayload = _ranges
          .map(
            (r) => {
              "min": r.min,
              "max": r.max,
              "price": r.price,
              "min_distance": r.min,
              "max_distance": r.max,
            },
          )
          .toList();

      final Map<String, dynamic> body = {
        "vendor_type": vendorType,
        "store_status": _storeOpen ? 1 : 0,
        "store_open": _storeOpen ? 1 : 0,
        "is_store_open": _storeOpen ? 1 : 0,
        "accepting_orders": _acceptingOrders ? 1 : 0,
        "is_accepting_orders": _acceptingOrders ? 1 : 0,
        "is_busy": _storeBusy ? 1 : 2,
        "store_busy": _storeBusy ? 1 : 0,
        "express_available": _expressAvailable ? 1 : 0,
        "express_delivery": _expressAvailable ? 1 : 0,
        "is_express": _expressAvailable ? 1 : 0,
        "pricing": pricingPayload,
        "distance_ranges": pricingPayload,
      };

      debugPrint(
        "==================== POST BUSINESS SETTINGS ====================",
      );
      debugPrint("Endpoint: ${ApiEndPoints.BusinessSettings}");
      debugPrint("Body: ${jsonEncode(body)}");

      print("==================== POST BUSINESS SETTINGS ====================");
      print("Endpoint: ${ApiEndPoints.BusinessSettings}");
      print("Body: ${jsonEncode(body)}");

      final response = await DioClient().get(
        ApiEndPoints.BusinessSettings,
        // body: body,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("================================================================");

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      final resData = response.data;
      final bool isSuccess =
          resData is Map &&
          (resData['status'] == true ||
              resData['status'].toString() == 'true' ||
              resData['status'] == 1 ||
              resData['status'] == '1');

      if (isSuccess) {
        HapticFeedback.lightImpact();
        if (mounted) {
          String message = _extractMessage(
            resData,
            S.current.waterBusinessSettingsUpdated,
          );
          showToast(context, message);
        }
        return true;
      } else {
        if (mounted) {
          String message = _extractMessage(
            resData,
            S.current.waterFailedToUpdateBusinessSettings,
          );
          showToast(context, message);
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      debugPrint(
        "==================== POST BUSINESS SETTINGS ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "======================================================================",
      );

      print(
        "==================== POST BUSINESS SETTINGS ERROR ====================",
      );
      print("Error: $e");
      print(
        "======================================================================",
      );

      if (mounted) {
        showErrorMessage(e);
      }
      return false;
    }
  }

  Future<void> _onStoreOpenChanged(bool value) async {
    final previous = _storeOpen;
    setState(() => _storeOpen = value);
    final success = await _updateBusinessSettings();
    if (!success && mounted) {
      setState(() => _storeOpen = previous);
    }
  }

  Future<void> _onAcceptingOrdersChanged(bool value) async {
    final previous = _acceptingOrders;
    setState(() => _acceptingOrders = value);
    final success = await _updateBusinessSettings();
    if (!success && mounted) {
      setState(() => _acceptingOrders = previous);
    }
  }

  Future<void> _onStoreBusyChanged(bool value) async {
    final previous = _storeBusy;
    setState(() => _storeBusy = value);
    final success = await _updateBusinessSettings();
    if (!success && mounted) {
      setState(() => _storeBusy = previous);
    }
  }

  Future<void> _onExpressAvailableChanged(bool value) async {
    final previous = _expressAvailable;
    setState(() => _expressAvailable = value);
    final success = await _updateBusinessSettings();
    if (!success && mounted) {
      setState(() => _expressAvailable = previous);
    }
  }

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
    final previous = List<_Distance>.from(_ranges);
    setState(() => _ranges.add(added));
    final success = await _updateBusinessSettings();
    if (!success && mounted) {
      setState(() => _ranges = previous);
    }
  }

  Future<void> _openEditRange(int index) async {
    final edited = await _openSheet(
      current: _ranges[index],
      editingIndex: index,
    );
    if (edited == null || !mounted) return;
    final previous = List<_Distance>.from(_ranges);
    setState(() => _ranges[index] = edited);
    final success = await _updateBusinessSettings();
    if (!success && mounted) {
      setState(() => _ranges = previous);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              colors: [Color(0xFFFFEBE4), Color(0xFFFFF6F1), Colors.white],
              stops: [0, 0.22, 0.42],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: RefreshIndicator(
                  color: BusinessSettingsView.orange,
                  onRefresh: _fetchBusinessSettings,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    children: [
                      _SectionTitle(S.of(context).waterStoreAvailability),
                      const SizedBox(height: 10),
                      _Card(
                        children: [
                          _SwitchRow(
                            label: S.of(context).waterStoreStatusOpen,
                            value: _storeOpen,
                            onChanged: _onStoreOpenChanged,
                          ),
                          const _Divider(),
                          _SwitchRow(
                            label: S.of(context).waterAcceptingOrders,
                            value: _acceptingOrders,
                            onChanged: _onAcceptingOrdersChanged,
                          ),
                          const _Divider(),
                          _SwitchRow(
                            label: S.of(context).waterMarkStoreBusy,
                            value: _storeBusy,
                            onChanged: _onStoreBusyChanged,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(S.of(context).waterExpressDelivery),
                      const SizedBox(height: 10),
                      _Card(
                        children: [
                          _SwitchRow(
                            label: S.of(context).available,
                            value: _expressAvailable,
                            onChanged: _onExpressAvailableChanged,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                S.of(context).waterPricing,
                                style: appFont('Inter', 
                                  color: BusinessSettingsView.ink,
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
              S.of(context).waterBusinessSettings,
              style: appFont('Inter', 
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
                    color: BusinessSettingsView.orange,
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
      style: appFont('Inter', 
        color: BusinessSettingsView.orange,
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
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1));
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

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
              style: appFont('Inter', 
                color: BusinessSettingsView.ink,
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
                return BusinessSettingsView.orange;
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
            S.of(context).waterDistanceRangeKm('${range.min}', '${range.max}'),
            style: appFont('Inter', 
              color: BusinessSettingsView.ink,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            '${range.price}',
            style: appFont('Inter', 
              color: BusinessSettingsView.ink,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'MRU',
            style: appFont('Inter', 
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
              child: Icon(
                Icons.edit_outlined,
                color: BusinessSettingsView.orange,
                size: 16,
              ),
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
            '+ ${S.of(context).waterAddDistanceRange}',
            style: appFont('Inter', 
              color: BusinessSettingsView.orange,
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
    final path = Path()
      ..addRRect(
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
    _price = TextEditingController(
      text: widget.initialPrice == null ? '' : '${widget.initialPrice}',
    );
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
      error = S.of(context).waterEnterMinMaxDistance;
    } else if (max <= min) {
      error = S.of(context).waterMaxGreaterThanMin;
    } else if (price == null) {
      error = S.of(context).waterEnterPrice;
    } else if (widget.others.any(
      (range) => min < range.max && max > range.min,
    )) {
      error = S.of(context).waterRangeOverlaps;
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
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.editing
                        ? S.of(context).waterEditDistanceRange
                        : S.of(context).waterAddDistanceRange,
                    style: appFont('Inter', 
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
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF7F7F7F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      label: S.of(context).waterMinimumDistance,
                      controller: _min,
                      suffix: S.of(context).km,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      label: S.of(context).waterMaximumDistance,
                      controller: _max,
                      suffix: S.of(context).km,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                S.of(context).price,
                style: appFont('Inter', 
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _Field(controller: _price, hint: S.of(context).waterPriceExampleHint),
                  ),
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
                      style: appFont('Inter', 
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
                  style: appFont('Inter', 
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          S.of(context).cancel,
                          style: appFont('Inter', 
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.editing ? S.of(context).update : S.of(context).add,
                          style: appFont('Inter', 
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
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
      style: appFont('Inter', 
        color: const Color(0xFF1F2937),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: appFont('Inter', 
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF2F4F6),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        suffixText: suffix,
        suffixStyle: appFont('Inter', 
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
          style: appFont('Inter', 
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
