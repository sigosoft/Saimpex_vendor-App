import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/water/core/water_api.dart';

/// Grocery substitution per order line (API doc §6.11, task V2).
/// Figma: "Edit Items" (9249:21918), "Change Quantity" (9249:21538),
/// "Suggest Substitute" (9249:21725), "Order Adjustment" (9249:20942).
///
/// The store can, before the order is Ready (status < 4):
/// - remove a line (unavailable),
/// - offer fewer units of the same product (kind `quantity`),
/// - offer another product of the store (kind `substitute`).
/// Each choice is sent to the customer at once (one pending proposal per
/// line); they accept or reject, or it is accepted automatically after
/// `timeout_minutes`.

const _orange = Color(0xFFFF5216);
const _ink = Color(0xFF1F2937);
const _grey = Color(0xFF6B7280);
const _pinkBg = Color(0xFFFFE8EA);
const _red = Color(0xFFE11D48);
const _green = Color(0xFF16A34A);
const _blue = Color(0xFF2563EB);

String _pickName(Map? m, {String base = 'name'}) {
  if (m == null) return '';
  final lang = LocalizationService.currentLanguageCode;
  String clean(dynamic v) => (v == null || '$v' == 'null') ? '' : '$v'.trim();
  final v = clean(m['${base}_$lang']);
  return v.isNotEmpty ? v : clean(m['${base}_en']);
}

double _num(dynamic v) => double.tryParse('${v ?? ''}') ?? 0;

/// One order line that can be adjusted.
class SubstitutionLine {
  const SubstitutionLine({
    required this.orderItemId,
    required this.productId,
    required this.name,
    required this.image,
    required this.unitPrice,
    required this.quantity,
    this.nameEn = '',
  });

  final int orderItemId;
  final int productId;
  final String name;
  final String image;
  final double unitPrice;
  final int quantity;

  /// English name, used to find the product in the store list (the
  /// substitute picker puts its category first).
  final String nameEn;
}

/// A proposal as the API returns it.
class Substitution {
  Substitution(this.raw);

  final Map<String, dynamic> raw;

  int get id => int.tryParse('${raw['id']}') ?? 0;
  int get orderItemId => int.tryParse('${raw['order_item_id']}') ?? 0;

  /// pending | accepted | rejected | auto_accepted | withdrawn
  String get status => '${raw['status'] ?? 'pending'}';

  /// quantity | substitute | unavailable
  String get kind {
    final k = '${raw['kind'] ?? ''}';
    if (k.isNotEmpty && k != 'null') return k;
    return raw['substitute'] == null ? 'unavailable' : 'substitute';
  }

  Map<String, dynamic> get original => raw['original'] is Map ? Map<String, dynamic>.from(raw['original']) : const {};
  Map<String, dynamic>? get substitute => raw['substitute'] is Map ? Map<String, dynamic>.from(raw['substitute']) : null;
  String get note => raw['note'] == null ? '' : '${raw['note']}'.trim();
  int get secondsLeft => int.tryParse('${raw['seconds_left'] ?? 0}') ?? 0;
  double get amountChange => _num(raw['amount_change']);
  bool get isPending => status == 'pending';

  /// The line is gone from the order (quantity 0): a rejected proposal, or an
  /// unavailable item the customer accepted (or that was accepted
  /// automatically). §6.11 "Effect on the order".
  bool get removesLine =>
      status == 'rejected' || (kind == 'unavailable' && (status == 'accepted' || status == 'auto_accepted'));
}

/// A store product that can be offered instead (`GET groceryMenuItems`).
class StoreProduct {
  StoreProduct(this.raw);

  final Map<String, dynamic> raw;

  /// The grocery_menu_items id (the variant), which the API expects.
  int get id => int.tryParse('${raw['menu_item_id'] ?? raw['id']}') ?? 0;
  String get name {
    final variant = _pickName(raw, base: 'variant_name');
    final value = '${raw['attribute_value'] ?? ''}'.trim();
    final extra = [if (value.isNotEmpty && value != 'null') value, if (variant.isNotEmpty) variant].join(' ');
    final n = _pickName(raw);
    return extra.isEmpty ? n : '$n $extra';
  }

  /// [name] with the unit word ("pcs", "pack", "set"...) translated when the
  /// store gave no variant name in the app language (test day V17).
  String displayName(S s) {
    final lang = LocalizationService.currentLanguageCode;
    final own = '${raw['variant_name_$lang'] ?? ''}'.trim();
    var variant = _pickName(raw, base: 'variant_name');
    if (lang != 'en' && (own.isEmpty || own == 'null')) variant = groceryUnitLabel(s, variant);
    var value = '${raw['attribute_value'] ?? ''}'.trim();
    if (lang != 'en') value = groceryUnitsInText(s, value);
    final extra = [if (value.isNotEmpty && value != 'null') value, if (variant.isNotEmpty) variant].join(' ');
    final n = _pickName(raw);
    return extra.isEmpty ? n : '$n $extra';
  }

  /// Category of the row, to list the ordered product's category first.
  int? get categoryId => int.tryParse('${raw['category_id'] ?? ''}');
  String get categoryName => '${raw['category_name_en'] ?? ''}'.trim().toLowerCase();

  String get image => '${raw['image'] ?? ''}';
  /// What the customer pays: the discount (selling) price when the item has
  /// one, else the retail price. The picker showed the retail price, so a
  /// 70 MRU item was saved as a 60 MRU substitute (test day, ORD-001481).
  double get price {
    final retail = _num(raw['price']);
    final selling = _num(raw['discount_price'] ?? raw['selling_price']);
    return selling > 0 && (retail <= 0 || selling < retail) ? selling : retail;
  }

  /// Shown only when the list sends it (backend issue for `stock`).
  int? get stock => raw['stock'] == null ? null : int.tryParse('${raw['stock']}');
  bool get isAvailable =>
      '${raw['status'] ?? 1}' == '1' && '${raw['available_status'] ?? 1}' == '1' && (stock == null || stock! > 0);
}

/// Calls for §6.11. Injectable so the screens can be tested.
class SubstitutionApi {
  const SubstitutionApi();

  Future<void> _prepare() => WaterApi.prepare();

  Future<({List<Substitution> items, int timeoutMinutes})> list(String orderId) async {
    await _prepare();
    final res = await DioClient().get('orders/$orderId/substitutions');
    final body = res.data;
    if (!WaterApi.isOk(body)) throw WaterApi.message(body) ?? S.current.somethingWentWrong;
    final data = body['data'];
    final rows = data is Map ? data['substitutions'] : null;
    return (
      items: rows is List ? rows.whereType<Map>().map((m) => Substitution(Map<String, dynamic>.from(m))).toList() : <Substitution>[],
      timeoutMinutes: int.tryParse('${data is Map ? data['timeout_minutes'] : ''}') ?? 10,
    );
  }

  /// [substituteProductId] null = unavailable. Returns the server message.
  Future<String?> propose(String orderId, int orderItemId, {int? substituteProductId, int? quantity, String? note}) async {
    await _prepare();
    final res = await DioClient().post('orders/$orderId/substitutions', body: {
      'order_item_id': orderItemId,
      'substitute_product_id': ?substituteProductId,
      'quantity': ?quantity,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
    final body = res.data;
    if (!WaterApi.isOk(body)) throw WaterApi.message(body) ?? S.current.somethingWentWrong;
    return WaterApi.message(body);
  }

  /// [categoryId] narrows the list to one category (the same filter the
  /// store's item list sends).
  Future<List<StoreProduct>> products(String keyword, {int? categoryId}) async {
    await _prepare();
    final res = await DioClient().get(ApiEndPoints.groceryMenuItems, query: {
      'limit': 30,
      'page': 1,
      'status': 1,
      if (keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      'category_id': ?categoryId,
    });
    final body = res.data;
    if (!WaterApi.isOk(body)) throw WaterApi.message(body) ?? S.current.somethingWentWrong;
    final data = body['data'];
    return WaterApi.pageItems(data is Map ? data['grocery_menu_items'] : null).map(StoreProduct.new).toList();
  }
}

/// Translated unit word for a grocery variant ("pcs" → "قطعة"); anything
/// unknown is shown as the store wrote it.
String groceryUnitLabel(S s, String unit) => switch (unit.trim().toLowerCase()) {
      'pc' || 'pcs' || 'piece' || 'pieces' => s.unitPiece,
      'kg' || 'kgs' => s.unitKg,
      'g' || 'gm' || 'gram' || 'grams' => s.unitGram,
      'l' || 'ltr' || 'litre' || 'liter' => s.unitLitre,
      'ml' => s.unitMillilitre,
      'cl' => s.unitCentilitre,
      'pack' || 'packs' || 'pkt' => s.unitPack,
      'set' || 'sets' => s.unitSet,
      'box' || 'boxes' => s.unitBox,
      'bottle' || 'bottles' => s.unitBottle,
      'dozen' || 'dz' => s.unitDozen,
      _ => unit,
    };

final RegExp _amountUnit = RegExp(r'(\d+(?:[.,]\d+)?)\s*([A-Za-z]+)\b');

/// The unit in a variant value the store typed ("30 pcs", "1 set", "1L")
/// translated; the store's own words stay as written (retest 4 Nov: the
/// picker showed "بيض 30 pcs").
String groceryUnitsInText(S s, String text) => text.replaceAllMapped(_amountUnit, (m) {
      final unit = groceryUnitLabel(s, m[2]!);
      return unit == m[2] ? m[0]! : '${m[1]} $unit';
    });

/// Products of the ordered item's category first, server order otherwise.
List<StoreProduct> sameCategoryFirst(List<StoreProduct> list, StoreProduct? original) {
  if (original == null) return list;
  bool same(StoreProduct p) =>
      (original.categoryId != null && p.categoryId == original.categoryId) ||
      (original.categoryName.isNotEmpty && p.categoryName == original.categoryName);
  return [...list.where(same), ...list.where((p) => !same(p))];
}

/// Latest proposal per line (the list is oldest first).
Map<int, Substitution> latestByLine(List<Substitution> items) {
  final map = <int, Substitution>{};
  for (final s in items) {
    final cur = map[s.orderItemId];
    if (cur == null || s.id > cur.id) map[s.orderItemId] = s;
  }
  return map;
}

// ── Shared bits ──────────────────────────────────────────────────────────

Widget _thumb(String image, {double size = 64}) => ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: image.isEmpty || image == 'null'
          ? Container(width: size, height: size, color: const Color(0xFFF3F4F6))
          : Image.network(
              image.startsWith('http') ? image : ApiConfigs.IMAGE_URL + image,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(width: size, height: size, color: const Color(0xFFF3F4F6)),
            ),
    );

Widget _pill(String text, Color color, {IconData? icon, Color? bg}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
        Text(text, style: appFont('Inter', fontSize: 11, fontWeight: FontWeight.w500, color: color)),
      ]),
    );

String _countdown(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Kind chip ("Quantity Changed", "Substitute Suggested", "Item Removed").
Widget substitutionKindChip(BuildContext context, Substitution sub) {
  final s = S.of(context);
  return switch (sub.kind) {
    'quantity' => _pill(s.substitutionQuantityChanged, const Color(0xFFB45309), icon: Icons.hourglass_empty, bg: const Color(0xFFFFEDD5)),
    'unavailable' => _pill(s.substitutionItemRemoved, _red, icon: Icons.delete_outline),
    _ => _pill(s.substitutionSuggested, _blue, icon: Icons.swap_horiz, bg: const Color(0xFFE0E7FF)),
  };
}

/// Customer answer chip: Waiting (with countdown) / Accepted / Rejected /
/// Accepted automatically.
class SubstitutionStatusChip extends StatefulWidget {
  const SubstitutionStatusChip({super.key, required this.sub});

  final Substitution sub;

  @override
  State<SubstitutionStatusChip> createState() => _SubstitutionStatusChipState();
}

class _SubstitutionStatusChipState extends State<SubstitutionStatusChip> {
  Timer? _timer;
  late int _left = widget.sub.secondsLeft;

  @override
  void initState() {
    super.initState();
    if (widget.sub.isPending && _left > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _left = _left > 0 ? _left - 1 : 0);
        if (_left == 0) _timer?.cancel();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return switch (widget.sub.status) {
      'accepted' => _pill(s.substitutionAccepted, _green, icon: Icons.check),
      'auto_accepted' => _pill(s.substitutionAutoAccepted, _green, icon: Icons.check),
      'rejected' => _pill(s.substitutionRejected, _red, icon: Icons.close),
      'withdrawn' => _pill(s.substitutionWithdrawn, _grey),
      _ => _pill(
          _left > 0 ? s.substitutionWaitingFor(_countdown(_left)) : s.substitutionWaiting,
          const Color(0xFFB45309),
          icon: Icons.schedule,
        ),
    };
  }
}

/// What the store proposed for a line, under it on the order details
/// (Figma "Order Adjustment" 9249:20942).
class SubstitutionSummary extends StatelessWidget {
  const SubstitutionSummary({super.key, required this.sub});

  final Substitution sub;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final orig = sub.original;
    final repl = sub.substitute;
    final origQty = int.tryParse('${orig['quantity']}') ?? 0;
    final newQty = int.tryParse('${repl?['quantity']}') ?? 0;
    final unit = _num(orig['unit_price']);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, runSpacing: 6, children: [
          substitutionKindChip(context, sub),
          SubstitutionStatusChip(key: ValueKey('chip-${sub.id}-${sub.status}'), sub: sub),
        ]),
        const SizedBox(height: 8),
        if (sub.kind == 'quantity')
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: s.substitutionOrdered('$origQty', WaterApi.money(unit * origQty)),
                style: const TextStyle(decoration: TextDecoration.lineThrough, color: _grey),
              ),
              const TextSpan(text: '   '),
              TextSpan(
                text: s.substitutionUpdated('$newQty', WaterApi.money(unit * newQty)),
                style: const TextStyle(color: _orange, fontWeight: FontWeight.w600),
              ),
            ]),
            style: appFont('Inter', fontSize: 12),
          )
        else if (repl != null)
          Row(children: [
            _thumb('${repl['image'] ?? ''}', size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_pickName(repl), style: appFont('Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                Text('x$newQty • ${WaterApi.money(_num(repl['unit_price']) * newQty)}',
                    style: appFont('Inter', fontSize: 12, color: _orange, fontWeight: FontWeight.w600)),
              ]),
            ),
          ])
        else
          Text(s.substitutionRemovedNote, style: appFont('Inter', fontSize: 12, color: _grey)),
        if (sub.note.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.sticky_note_2_outlined, size: 16, color: _orange),
            const SizedBox(width: 6),
            Expanded(child: Text(sub.note, style: appFont('Inter', fontSize: 12, color: _ink))),
          ]),
        ],
      ]),
    );
  }
}

// ── Edit Items screen ────────────────────────────────────────────────────

/// Figma "Edit Items": every line with Remove Item / Change Qty / Suggest
/// Substitute. A line with a proposal waiting for the customer shows it
/// instead of the buttons; a removed line shows no buttons.
///
/// The screen reloads (test day V18: it kept showing "Waiting" after the
/// customer answered): pull to refresh, when the app comes back to the
/// foreground, on any push in [refreshSignals], and every 20 s while a
/// proposal is waiting (the vendor gets no push for the customer's answer).
class EditItemsView extends StatefulWidget {
  const EditItemsView({
    super.key,
    required this.orderId,
    required this.lines,
    this.api = const SubstitutionApi(),
    this.reloadLines,
    this.refreshSignals,
  });

  final String orderId;
  final List<SubstitutionLine> lines;
  final SubstitutionApi api;

  /// Fresh order lines (order details again); an accepted substitute or a
  /// removed item changes them.
  final Future<List<SubstitutionLine>> Function()? reloadLines;
  final Stream<Object?>? refreshSignals;

  @override
  State<EditItemsView> createState() => _EditItemsViewState();
}

class _EditItemsViewState extends State<EditItemsView> with WidgetsBindingObserver {
  static const _pollEvery = Duration(seconds: 20);

  late List<SubstitutionLine> _lines = widget.lines;
  Map<int, Substitution> _subs = {};
  int _timeout = 10;
  bool _loading = true;
  bool _busy = false;
  StreamSubscription<Object?>? _signals;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _signals = widget.refreshSignals?.listen((_) => _load(lines: true, quiet: true));
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _signals?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load(lines: true, quiet: true);
  }

  /// [lines] also reloads the order lines (an answer may have changed them);
  /// [quiet] skips the error message (background refreshes).
  Future<void> _load({bool lines = false, bool quiet = false}) async {
    try {
      final r = await widget.api.list(widget.orderId);
      final fresh = lines && widget.reloadLines != null ? await widget.reloadLines!() : null;
      if (!mounted) return;
      final before = _subs;
      setState(() {
        _subs = latestByLine(r.items);
        _timeout = r.timeoutMinutes;
        if (fresh != null && fresh.isNotEmpty) _lines = fresh;
      });
      // A proposal was answered since the last load: the lines changed too.
      final answered = before.values.any((b) => b.isPending && _subs[b.orderItemId]?.isPending != true);
      if (answered && !lines && widget.reloadLines != null) {
        final next = await widget.reloadLines!();
        if (mounted && next.isNotEmpty) setState(() => _lines = next);
      }
    } catch (e) {
      if (!quiet) _snack(WaterApi.errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
      _schedulePoll();
    }
  }

  void _schedulePoll() {
    _poll?.cancel();
    if (!mounted || !_subs.values.any((s) => s.isPending)) return;
    _poll = Timer(_pollEvery, () => _load(quiet: true));
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _send(SubstitutionLine line, {int? productId, int? quantity, String? note}) async {
    setState(() => _busy = true);
    try {
      await widget.api.propose(widget.orderId, line.orderItemId, substituteProductId: productId, quantity: quantity, note: note);
      _snack(S.current.substitutionSent);
      await _load();
    } catch (e) {
      _snack(WaterApi.errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(SubstitutionLine line) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.substitutionRemoveTitle),
        content: Text(s.substitutionRemoveBody(line.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(s.substitutionRemoveItem, style: const TextStyle(color: _red)),
          ),
        ],
      ),
    );
    if (ok == true) await _send(line);
  }

  Future<void> _changeQty(SubstitutionLine line) async {
    final r = await showChangeQuantitySheet(context, line);
    if (r != null) await _send(line, productId: line.productId, quantity: r.quantity, note: r.note);
  }

  Future<void> _suggest(SubstitutionLine line) async {
    final r = await showSuggestSubstituteSheet(context, line, api: widget.api);
    if (r != null) await _send(line, productId: r.productId, quantity: r.quantity);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9F6),
        elevation: 0,
        foregroundColor: _ink,
        // The app theme paints AppBar icons white, so the default arrow was
        // nearly invisible here; use the app's back icon (as CustomAppBar).
        leading: Navigator.canPop(context)
            ? IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: Transform.rotate(
                  angle: rtl ? 3.1416 : 0,
                  child: Image.asset(
                    'lib/assets/images/back.png',
                    height: 35,
                    width: 35,
                    errorBuilder: (c, e, st) => const Icon(Icons.arrow_back, color: _ink),
                  ),
                ),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: Text(s.substitutionEditItems, style: appFont('Inter', fontSize: 18, fontWeight: FontWeight.w600, color: _ink)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _orange))
          : Stack(children: [
              RefreshIndicator(
                color: _orange,
                onRefresh: () => _load(lines: true),
                child: ListView(
                // Clear of the system navigation bar (edge-to-edge Android).
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                children: [
                Text('${s.orderItems} (${_lines.length})',
                    style: appFont('Inter', fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF9CA3AF))),
                const SizedBox(height: 12),
                for (final line in _lines) _lineCard(line),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.info_outline, size: 18, color: _blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(s.substitutionInfo('$_timeout'), style: appFont('Inter', fontSize: 12, color: _ink)),
                    ),
                  ]),
                ),
              ]),
              ),
              if (_busy) const Positioned.fill(child: ColoredBox(color: Color(0x33FFFFFF), child: Center(child: CircularProgressIndicator(color: _orange)))),
            ]),
    );
  }

  Widget _lineCard(SubstitutionLine line) {
    final s = S.of(context);
    final sub = _subs[line.orderItemId];
    final pending = sub?.isPending == true;
    // Removed from the order: nothing left to change on it (test day V18).
    final removed = line.quantity <= 0 || sub?.removesLine == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pending ? _pinkBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          _thumb(line.image),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(line.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: appFont('Inter', fontSize: 15, fontWeight: FontWeight.w500, color: _ink)),
              Text('x${line.quantity}', style: appFont('Inter', fontSize: 13, color: _grey)),
              Text(WaterApi.money(line.unitPrice * line.quantity),
                  style: appFont('Inter', fontSize: 14, fontWeight: FontWeight.w600, color: _orange)),
            ]),
          ),
        ]),
        if (sub != null)
          SubstitutionSummary(key: ValueKey('sum-${sub.id}'), sub: sub)
        else if (removed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _pill(s.substitutionItemRemoved, _red, icon: Icons.delete_outline),
            ),
          ),
        if (!pending && !removed) ...[
          const SizedBox(height: 12),
          Row(children: [
            _action(Icons.delete_outline, s.substitutionRemoveItem, _red, () => _remove(line)),
            const SizedBox(width: 8),
            _action(Icons.hourglass_empty, s.substitutionChangeQty, _ink, line.quantity > 1
                ? () => _changeQty(line)
                // Quantity can only go down; with one left, say why instead of
                // a silently disabled button (VA-18).
                : () => _snack(s.substitutionChangeQtyOnlyOne)),
            const SizedBox(width: 8),
            _action(Icons.swap_horiz, s.substitutionSuggest, Colors.white, () => _suggest(line), filled: true),
          ]),
        ],
      ]),
    );
  }

  Widget _action(IconData icon, String label, Color color, VoidCallback? onTap, {bool filled = false}) {
    final enabled = onTap != null && !_busy;
    return Expanded(
      child: Material(
        color: filled ? (enabled ? _orange : const Color(0xFFFFD6C8)) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: filled ? 0 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(children: [
              Icon(icon, size: 18, color: enabled ? color : const Color(0xFF9CA3AF)),
              const SizedBox(height: 4),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                  style: appFont('Inter', fontSize: 12, color: enabled ? color : const Color(0xFF9CA3AF))),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Sheets ───────────────────────────────────────────────────────────────

Widget _sheetHeader(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(children: [
        Expanded(child: Text(title, style: appFont('Inter', fontSize: 17, fontWeight: FontWeight.w600, color: _ink))),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ]),
    );

Widget _originalCard(BuildContext context, SubstitutionLine line) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _pinkBg, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        _thumb(line.image),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(line.name, style: appFont('Inter', fontSize: 15, fontWeight: FontWeight.w500, color: _ink)),
            Text('x${line.quantity}', style: appFont('Inter', fontSize: 13, color: _grey)),
            Text(WaterApi.money(line.unitPrice * line.quantity),
                style: appFont('Inter', fontSize: 14, fontWeight: FontWeight.w600, color: _orange)),
          ]),
        ),
        _pill(S.of(context).outOfStock, _red, bg: Colors.white),
      ]),
    );

Widget _sheetButtons(BuildContext context, String confirm, VoidCallback? onConfirm) => Row(children: [
      Expanded(
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFE5EDFF),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel, style: appFont('Inter', fontSize: 14, fontWeight: FontWeight.w600, color: _ink)),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        flex: 2,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: onConfirm == null ? const Color(0xFFFFD6C8) : _orange,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onConfirm,
          child: Text(confirm, style: appFont('Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    ]);

Widget _totalRow(BuildContext context, double before, double after) {
  final diff = after - before;
  return Row(children: [
    Expanded(child: Text(S.of(context).substitutionUpdatedTotal, style: appFont('Inter', fontSize: 12, color: _grey))),
    if (diff != 0) ...[
      Text(WaterApi.money(before),
          style: appFont('Inter', fontSize: 12, color: _grey).copyWith(decoration: TextDecoration.lineThrough)),
      const SizedBox(width: 8),
    ],
    Text(WaterApi.money(after), style: appFont('Inter', fontSize: 16, fontWeight: FontWeight.w700, color: _orange)),
    if (diff != 0) ...[
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: _pinkBg, borderRadius: BorderRadius.circular(4)),
        child: Text('${diff > 0 ? '+' : '-'}${WaterApi.money(diff.abs())}',
            style: appFont('Inter', fontSize: 11, color: _red, fontWeight: FontWeight.w500)),
      ),
    ],
  ]);
}

/// Figma "Change Quantity": ordered quantity, available quantity (1 to
/// ordered − 1), notes, updated item total.
Future<({int quantity, String note})?> showChangeQuantitySheet(BuildContext context, SubstitutionLine line) {
  return showModalBottomSheet<({int quantity, String note})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _ChangeQuantitySheet(line: line),
  );
}

class _ChangeQuantitySheet extends StatefulWidget {
  const _ChangeQuantitySheet({required this.line});

  final SubstitutionLine line;

  @override
  State<_ChangeQuantitySheet> createState() => _ChangeQuantitySheetState();
}

class _ChangeQuantitySheetState extends State<_ChangeQuantitySheet> {
  late final _qtyCtrl = TextEditingController(text: '${widget.line.quantity - 1}');
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  int? get _qty {
    final q = int.tryParse(_qtyCtrl.text.trim());
    return q != null && q >= 1 && q < widget.line.quantity ? q : null;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final line = widget.line;
    final q = _qty;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _sheetHeader(context, s.substitutionChangeQuantity),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _originalCard(context, line),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 96),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(14)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.substitutionOrderedQuantity, style: appFont('Inter', fontSize: 12, fontWeight: FontWeight.w600, color: _grey)),
                      const SizedBox(height: 18),
                      Text('${line.quantity}', style: appFont('Inter', fontSize: 18, fontWeight: FontWeight.w600, color: _ink)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 96),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFF4EC), borderRadius: BorderRadius.circular(14)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.substitutionAvailableQuantity, style: appFont('Inter', fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFB45309))),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          key: const Key('subQty'),
                          controller: _qtyCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
              if (q == null) ...[
                const SizedBox(height: 6),
                Text(s.substitutionQuantityHint('${line.quantity - 1}'), style: appFont('Inter', fontSize: 12, color: _red)),
              ],
              const SizedBox(height: 16),
              Text(s.substitutionAddNotes, style: appFont('Inter', fontSize: 15, fontWeight: FontWeight.w600, color: _ink)),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                maxLength: 255,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 8),
              _totalRow(context, line.unitPrice * line.quantity, line.unitPrice * (q ?? line.quantity)),
              const SizedBox(height: 16),
              _sheetButtons(
                context,
                s.substitutionUpdateQuantity,
                q == null ? null : () => Navigator.pop(context, (quantity: q, note: _noteCtrl.text)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Figma "Suggest Substitute": search the store's products, pick one with a
/// quantity, see the updated item total.
Future<({int productId, int quantity})?> showSuggestSubstituteSheet(
  BuildContext context,
  SubstitutionLine line, {
  SubstitutionApi api = const SubstitutionApi(),
}) {
  return showModalBottomSheet<({int productId, int quantity})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => FractionallySizedBox(heightFactor: 0.9, child: _SuggestSubstituteSheet(line: line, api: api)),
  );
}

class _SuggestSubstituteSheet extends StatefulWidget {
  const _SuggestSubstituteSheet({required this.line, required this.api});

  final SubstitutionLine line;
  final SubstitutionApi api;

  @override
  State<_SuggestSubstituteSheet> createState() => _SuggestSubstituteSheetState();
}

class _SuggestSubstituteSheetState extends State<_SuggestSubstituteSheet> {
  List<StoreProduct> _products = [];
  bool _loading = true;
  String? _error;
  int? _selected;
  int _qty = 0;
  Timer? _debounce;

  /// The ordered product's own row (for its category), when found.
  StoreProduct? _original;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Suggestions were unrelated to the item (test day V18): the first page
  /// of the whole store. Find the ordered product's row by its name, then
  /// open on its category; the store's other products follow.
  Future<void> _start() async {
    final line = widget.line;
    final key = line.nameEn.trim().isNotEmpty ? line.nameEn : line.name;
    try {
      final rows = await widget.api.products(key);
      for (final p in rows) {
        if (p.id == line.productId) _original = p;
      }
    } catch (_) {
      // Not found: the plain list below still works.
    }
    if (mounted) await _search('');
  }

  bool _usable(StoreProduct p) => p.id != widget.line.productId && p.isAvailable;

  Future<void> _search(String keyword) async {
    setState(() => _loading = true);
    try {
      final categoryId = _original?.categoryId;
      var list = <StoreProduct>[];
      if (keyword.trim().isEmpty && categoryId != null) {
        list = (await widget.api.products('', categoryId: categoryId)).where(_usable).toList();
      }
      final ids = {for (final p in list) p.id};
      list = [...list, ...(await widget.api.products(keyword)).where((p) => _usable(p) && !ids.contains(p.id))];
      if (!mounted) return;
      setState(() {
        _products = sameCategoryFirst(list, _original);
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = WaterApi.errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _step(StoreProduct p, int delta) {
    setState(() {
      final current = _selected == p.id ? _qty : 0;
      var next = (current + delta).clamp(0, 999);
      if (p.stock != null && next > p.stock!) next = p.stock!;
      _selected = next == 0 ? null : p.id;
      _qty = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final line = widget.line;
    StoreProduct? chosen;
    for (final p in _products) {
      if (p.id == _selected) chosen = p;
    }
    final after = chosen == null ? line.unitPrice * line.quantity : chosen.price * _qty;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _sheetHeader(context, s.substitutionSuggestTitle),
        const Divider(height: 1),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(20), children: [
            _originalCard(context, line),
            const SizedBox(height: 14),
            TextField(
              key: const Key('subSearch'),
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () => _search(v));
              },
              decoration: InputDecoration(
                hintText: s.substitutionSearchProducts,
                prefixIcon: const Icon(Icons.search, color: _grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: _orange)))
            else if (_products.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error ?? s.noItemsFound, textAlign: TextAlign.center, style: appFont('Inter', fontSize: 14, color: _grey)),
              )
            else
              for (final p in _products) _productTile(p),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(children: [
            const Divider(),
            _totalRow(context, line.unitPrice * line.quantity, after),
            const SizedBox(height: 14),
            _sheetButtons(
              context,
              s.substitutionConfirmSelection,
              chosen == null || _qty < 1 ? null : () => Navigator.pop(context, (productId: chosen!.id, quantity: _qty)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _productTile(StoreProduct p) {
    final s = S.of(context);
    final qty = _selected == p.id ? _qty : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: qty > 0 ? _orange : const Color(0xFFFFE4E6)),
      ),
      child: Row(children: [
        _thumb(p.image),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.displayName(s), maxLines: 2, overflow: TextOverflow.ellipsis, style: appFont('Inter', fontSize: 15, fontWeight: FontWeight.w500, color: _ink)),
            if (p.stock != null) ...[
              const SizedBox(height: 4),
              _pill(s.substitutionInStock('${p.stock}'), _green),
            ],
            const SizedBox(height: 4),
            Text(WaterApi.money(p.price), style: appFont('Inter', fontSize: 14, fontWeight: FontWeight.w600, color: _orange)),
          ]),
        ),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFFFF4E0), borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              key: Key('minus-${p.id}'),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove_circle, color: _orange),
              onPressed: qty > 0 ? () => _step(p, -1) : null,
            ),
            Text('$qty', style: appFont('Inter', fontSize: 14, fontWeight: FontWeight.w600)),
            IconButton(
              key: Key('plus-${p.id}'),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_circle, color: _orange),
              onPressed: () => _step(p, 1),
            ),
          ]),
        ),
      ]),
    );
  }
}
