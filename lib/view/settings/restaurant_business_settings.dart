import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/notification_preference.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// Restaurant / grocery / local store "Business Settings" (Figma
/// "Settings › Business Settings"): store availability, push notifications,
/// delete account and express delivery pricing by distance.
///
/// API (vendorapp, BusinessSettingsController): `GET businessSettings`,
/// `POST updateStoreAvailability` {store_open | accepting_orders: 1 on, 2 off},
/// `POST updateExpressDelivery` {available}, `POST addDeliveryDistance`,
/// `updateDeliveryDistance`, `deleteDeliveryDistance` {id, min_km, max_km,
/// price}. Notifications: `GET/POST notification/preference`.
///
/// "Mark Store Busy" from the Figma frame is left out on purpose: the Busy
/// state is waiting for an owner decision.
class RestaurantBusinessSettings extends StatefulWidget {
  const RestaurantBusinessSettings({super.key});

  @override
  State<RestaurantBusinessSettings> createState() =>
      _RestaurantBusinessSettingsState();
}

const _orange = Color(0xFFFF5216);
const _ink = Color(0xFF2E3545);
const _muted = Color(0xFF6B7280);

class _Range {
  const _Range({
    required this.id,
    required this.min,
    required this.max,
    required this.price,
  });

  final int id;
  final double min;
  final double max;
  final double price;

  static _Range? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final id = int.tryParse('${raw['id']}');
    final min = double.tryParse('${raw['min_km']}');
    final max = double.tryParse('${raw['max_km']}');
    final price = double.tryParse('${raw['price']}');
    if (id == null || min == null || max == null || price == null) return null;
    return _Range(id: id, min: min, max: max, price: price);
  }
}

/// 5.0 → "5", 2.5 → "2.5".
String _num(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

class _RestaurantBusinessSettingsState
    extends State<RestaurantBusinessSettings> {
  bool _loading = true;
  bool _busy = false;
  bool? _storeOpen;
  bool? _acceptingOrders;
  bool? _expressAvailable;
  bool? _notifications;
  List<_Range> _ranges = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _auth() async {
    final token = (await getSavedObject('token'))?.toString() ?? '';
    if (token.isNotEmpty && token != 'null') DioClient().updateToken(token);
  }

  Future<void> _load() async {
    await _auth();
    final notifications = NotificationPreference.load();
    try {
      final res = await DioClient().get(ApiEndPoints.BusinessSettings);
      final body = res.data;
      if (body is Map && body['status'] == true && body['data'] is Map) {
        _apply(Map<String, dynamic>.from(body['data'] as Map));
      }
    } catch (_) {
      // Toggles stay disabled when the settings can't be read.
    }
    final push = await notifications;
    if (!mounted) return;
    setState(() {
      _notifications = push;
      _loading = false;
    });
  }

  void _apply(Map<String, dynamic> data) {
    bool? on(dynamic v) => v == null ? null : '$v' == '1';
    setState(() {
      _storeOpen = on(data['store_open']) ?? _storeOpen;
      _acceptingOrders = on(data['accepting_orders']) ?? _acceptingOrders;
      _expressAvailable = on(data['express_delivery']) ?? _expressAvailable;
      final ranges = data['distance_ranges'];
      if (ranges is List) {
        _ranges = ranges.map(_Range.fromJson).whereType<_Range>().toList();
      }
    });
  }

  /// Posts [body] to [path]; applies the returned settings. Returns success.
  Future<bool> _post(String path, Map<String, dynamic> body) async {
    if (_busy) return false;
    setState(() => _busy = true);
    showLoadingDialog(context);
    bool ok = false;
    try {
      await _auth();
      final res = await DioClient().post(path, body: body);
      final data = res.data;
      ok = data is Map && data['status'] == true;
      if (ok && data['data'] is Map) {
        _apply(Map<String, dynamic>.from(data['data'] as Map));
      }
    } catch (_) {
      ok = false;
    }
    if (!mounted) return ok;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _busy = false);
    showToast(
      context,
      ok
          ? S.of(context).waterBusinessSettingsUpdated
          : S.of(context).waterFailedToUpdateBusinessSettings,
    );
    return ok;
  }

  Future<void> _setStoreOpen(bool v) =>
      _post(ApiEndPoints.updateStoreAvailability, {'store_open': v ? 1 : 2});

  Future<void> _setAccepting(bool v) => _post(
    ApiEndPoints.updateStoreAvailability,
    {'accepting_orders': v ? 1 : 2},
  );

  Future<void> _setExpress(bool v) =>
      _post(ApiEndPoints.updateExpressDelivery, {'available': v ? 1 : 2});

  Future<void> _setNotifications(bool v) async {
    final previous = _notifications;
    setState(() => _notifications = v);
    final ok = await NotificationPreference.save(v);
    if (!mounted) return;
    if (!ok) setState(() => _notifications = previous);
    showToast(
      context,
      ok
          ? S.of(context).waterBusinessSettingsUpdated
          : S.of(context).waterFailedToUpdateBusinessSettings,
    );
  }

  Future<void> _openRange([_Range? current]) async {
    final result = await showDialog<_RangeResult>(
      context: context,
      builder: (_) => _RangeDialog(
        current: current,
        startMin: current == null && _ranges.isNotEmpty ? _ranges.last.max : 0,
        others: [
          for (final r in _ranges)
            if (r.id != current?.id) r,
        ],
      ),
    );
    if (result == null || !mounted) return;
    if (result.delete && current != null) {
      await _post(ApiEndPoints.deleteDeliveryDistance, {'id': current.id});
      return;
    }
    final body = {
      'min_km': result.min,
      'max_km': result.max,
      'price': result.price,
    };
    if (current == null) {
      await _post(ApiEndPoints.addDeliveryDistance, body);
    } else {
      await _post(ApiEndPoints.updateDeliveryDistance, {
        'id': current.id,
        ...body,
      });
    }
  }

  void _deleteAccount() {
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    showConfirmationBottomSheet(
      context: context,
      title: S.of(context).deleteAccount,
      message: S.of(context).areYouSureYouWantToDeleteYourAccount,
      leftButtonText: S.of(context).cancel,
      rightButtonText: S.of(context).delete,
      onConfirm: () => controller.deleteAccount(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Directionality(
      textDirection: LocalizationService().getTextDirection(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                _Header(title: s.waterBusinessSettings),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: _orange),
                        )
                      : RefreshIndicator(
                          color: _orange,
                          onRefresh: _load,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                            children: [
                              _SectionTitle(s.waterStoreAvailability),
                              const SizedBox(height: 10),
                              _Card(
                                children: [
                                  _SwitchRow(
                                    label: s.waterStoreStatusOpen,
                                    value: _storeOpen,
                                    onChanged: _setStoreOpen,
                                  ),
                                  const _Divider(),
                                  _SwitchRow(
                                    label: s.waterAcceptingOrders,
                                    value: _acceptingOrders,
                                    onChanged: _setAccepting,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _SectionTitle(s.settings),
                              const SizedBox(height: 10),
                              _Card(
                                children: [
                                  _SwitchRow(
                                    label: s.notification,
                                    value: _notifications,
                                    onChanged: _setNotifications,
                                  ),
                                  const _Divider(),
                                  InkWell(
                                    onTap: _deleteAccount,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        14,
                                        16,
                                        14,
                                        16,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s.deleteAccount,
                                              style: appFont(
                                                'Inter',
                                                color: _ink,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _SectionTitle(s.waterExpressDelivery),
                              const SizedBox(height: 10),
                              _Card(
                                children: [
                                  _SwitchRow(
                                    label: s.available,
                                    value: _expressAvailable,
                                    onChanged: _setExpress,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      8,
                                      14,
                                      8,
                                    ),
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        s.waterPricing,
                                        style: appFont(
                                          'Inter',
                                          color: _ink,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  for (final r in _ranges)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        14,
                                        0,
                                        14,
                                        8,
                                      ),
                                      child: _RangeRow(
                                        range: r,
                                        onEdit: () => _openRange(r),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      4,
                                      14,
                                      14,
                                    ),
                                    child: _AddRangeButton(
                                      label: s.waterAddDistanceRange,
                                      onTap: () => _openRange(),
                                    ),
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
      ),
    );
  }
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
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back_ios, size: 20, color: _ink),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: appFont(
                'Inter',
                color: const Color(0xFF1C1D1B),
                fontWeight: FontWeight.w700,
                fontSize: 18,
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
      style: appFont(
        'Inter',
        color: _orange,
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
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1));
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;

  /// Null when the server value couldn't be read: the switch is disabled.
  final bool? value;
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
              style: appFont(
                'Inter',
                color: _ink,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value ?? false,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: value == null
                ? null
                : (next) {
                    HapticFeedback.lightImpact();
                    onChanged(next);
                  },
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? _orange
                  : const Color(0xFFE3E2DF),
            ),
            trackOutlineColor: const WidgetStatePropertyAll(
              Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeRow extends StatelessWidget {
  const _RangeRow({required this.range, required this.onEdit});

  final _Range range;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final style = appFont(
      'Inter',
      color: _ink,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );
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
            S.of(context).waterDistanceRangeKm(_num(range.min), _num(range.max)),
            style: style,
          ),
          const Spacer(),
          Text(
            _num(range.price),
            style: style.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          Text(
            'MRU',
            style: style.copyWith(color: _muted, fontSize: 13),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.edit_outlined, color: _orange, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddRangeButton extends StatelessWidget {
  const _AddRangeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 46,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF8A5B)),
        ),
        child: Text(
          '+ $label',
          style: appFont(
            'Inter',
            color: _orange,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _RangeResult {
  const _RangeResult({
    this.min = 0,
    this.max = 0,
    this.price = 0,
    this.delete = false,
  });

  final double min;
  final double max;
  final double price;
  final bool delete;
}

/// Figma "Add Distance Range" dialog; also edits (and deletes) a range.
class _RangeDialog extends StatefulWidget {
  const _RangeDialog({
    required this.current,
    required this.startMin,
    required this.others,
  });

  final _Range? current;
  final double startMin;
  final List<_Range> others;

  @override
  State<_RangeDialog> createState() => _RangeDialogState();
}

class _RangeDialogState extends State<_RangeDialog> {
  late final TextEditingController _min;
  late final TextEditingController _max;
  late final TextEditingController _price;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = widget.current;
    _min = TextEditingController(text: _num(c?.min ?? widget.startMin));
    _max = TextEditingController(text: c == null ? '' : _num(c.max));
    _price = TextEditingController(text: c == null ? '' : _num(c.price));
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    _price.dispose();
    super.dispose();
  }

  void _submit() {
    final s = S.of(context);
    final min = double.tryParse(_min.text.trim());
    final max = double.tryParse(_max.text.trim());
    final price = double.tryParse(_price.text.trim());
    String? error;
    if (min == null || max == null || min < 0) {
      error = s.waterEnterMinMaxDistance;
    } else if (max <= min) {
      error = s.waterMaxGreaterThanMin;
    } else if (price == null || price < 0) {
      error = s.waterEnterPrice;
    } else if (widget.others.any((r) => min < r.max && max > r.min)) {
      error = s.waterRangeOverlaps;
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_RangeResult(min: min!, max: max!, price: price!));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final editing = widget.current != null;
    final labelStyle = appFont(
      'Inter',
      color: _muted,
      fontWeight: FontWeight.w500,
      fontSize: 13,
    );
    return Directionality(
      textDirection: LocalizationService().getTextDirection(),
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      editing ? s.waterEditDistanceRange : s.waterAddDistanceRange,
                      style: appFont(
                        'Inter',
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 18, color: _muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.waterMinimumDistance, style: labelStyle),
                        const SizedBox(height: 8),
                        _Field(controller: _min, suffix: s.km),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.waterMaximumDistance, style: labelStyle),
                        const SizedBox(height: 8),
                        _Field(controller: _max, suffix: s.km),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(s.price, style: labelStyle),
              const SizedBox(height: 8),
              _Field(
                controller: _price,
                hint: s.waterPriceExampleHint,
                suffix: 'MRU',
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: appFont(
                    'Inter',
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
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF454E5D),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(s.cancel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: _orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(editing ? s.update : s.add),
                      ),
                    ),
                  ),
                ],
              ),
              if (editing)
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(const _RangeResult(delete: true)),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                    label: Text(
                      s.delete,
                      style: const TextStyle(color: Color(0xFFDC2626)),
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

class _Field extends StatelessWidget {
  const _Field({required this.controller, this.suffix, this.hint});

  final TextEditingController controller;
  final String? suffix;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    const none = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      style: appFont(
        'Inter',
        color: const Color(0xFF1F2937),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F4F6),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        suffixText: suffix,
        border: none,
        enabledBorder: none,
        focusedBorder: none,
      ),
    );
  }
}
