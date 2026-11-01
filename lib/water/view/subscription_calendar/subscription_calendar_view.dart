import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/water/core/water_api.dart';
import 'package:saimpex_vendor/water/view/chat/chat_view.dart';

/// Water subscription delivery calendar (task V18), Figma "Vendor Apps" →
/// water Home / Subscription Calendar (8360:37494), API doc §6.41
/// `GET vendorapp/waterDeliveryCalendar?from=&to=&date=&slot=&status=&keyword=`:
/// totals for the day, a weekly planner with counts, search, slot / paused
/// filters, and the day's deliveries grouped by slot.
class SubscriptionCalendarView extends StatefulWidget {
  const SubscriptionCalendarView({super.key, this.loader});

  /// Data source; the API by default (tests pass a fixed payload).
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> query)? loader;

  @override
  State<SubscriptionCalendarView> createState() => _SubscriptionCalendarViewState();
}

class _SubscriptionCalendarViewState extends State<SubscriptionCalendarView> {
  static const _orange = Color(0xFFFF5216);
  static const _ink = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF6B7280);

  late DateTime _selected = _dateOnly(DateTime.now());
  late DateTime _weekStart = _monday(_selected);
  String _filter = 'all'; // all | morning | afternoon | evening | paused
  final _search = TextEditingController();
  Timer? _debounce;

  Map<String, dynamic> _data = {};
  bool _loading = true;
  String? _error;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime _monday(DateTime d) => d.subtract(Duration(days: d.weekday - 1));
  static String _ymd(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetch(Map<String, dynamic> query) async {
    await WaterApi.prepare();
    final res = await DioClient().get(ApiEndPoints.waterDeliveryCalendar, query: query);
    final body = res.data;
    if (!WaterApi.isOk(body) || body is! Map || body['data'] is! Map) {
      throw WaterApi.message(body) ?? S.current.waterSomethingWentWrong;
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final query = <String, dynamic>{
      'from': _ymd(_weekStart),
      'to': _ymd(_weekStart.add(const Duration(days: 6))),
      'date': _ymd(_selected),
      if (const {'morning', 'afternoon', 'evening'}.contains(_filter)) 'slot': _filter,
      if (_filter == 'paused') 'status': 'paused',
      if (_search.text.trim().isNotEmpty) 'keyword': _search.text.trim(),
    };
    try {
      final data = await (widget.loader ?? _fetch)(query);
      if (mounted) setState(() => _data = data);
    } catch (e) {
      if (mounted) setState(() => _error = WaterApi.errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _countFor(DateTime day) {
    final cal = _data['calendar'];
    if (cal is! List) return 0;
    for (final c in cal.whereType<Map>()) {
      if (c['date']?.toString().startsWith(_ymd(day)) == true) return int.tryParse('${c['count']}') ?? 0;
    }
    return 0;
  }

  int _stat(String key) {
    final stats = _data['stats'];
    return stats is Map ? int.tryParse('${stats[key] ?? 0}') ?? 0 : 0;
  }

  List<Map<String, dynamic>> get _slots {
    final slots = _data['slots'];
    return slots is List ? slots.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : [];
  }

  void _shiftWeek(int weeks) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * weeks));
      _selected = _weekStart;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final total = _stat('total');
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9F6),
        body: Column(children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8),
          _Header(onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: RefreshIndicator(
              color: _orange,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(children: [
                    _statCard(s.waterCalendarTotal, total, _ink),
                    const SizedBox(width: 10),
                    _statCard(s.waterCalendarMorning, _stat('morning'), const Color(0xFF2563EB)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _statCard(s.waterCalendarAfternoon, _stat('afternoon'), _orange),
                    const SizedBox(width: 10),
                    _statCard(s.waterCalendarPaused, _stat('paused'), const Color(0xFFE11D48)),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Text(s.waterWeeklyPlanner.toUpperCase(), style: _t(12, FontWeight.w700, _muted))),
                    IconButton(onPressed: () => _shiftWeek(-1), icon: Icon(rtl ? Icons.chevron_right : Icons.chevron_left, color: _orange)),
                    Text(WaterApi.monthYear(_selected), style: _t(13, FontWeight.w600, _ink)),
                    IconButton(onPressed: () => _shiftWeek(1), icon: Icon(rtl ? Icons.chevron_left : Icons.chevron_right, color: _orange)),
                  ]),
                  SizedBox(
                    height: 78,
                    child: Row(children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(child: _dayCell(_weekStart.add(Duration(days: i)))),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    onChanged: (_) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 400), _load);
                    },
                    decoration: InputDecoration(
                      hintText: s.waterSearchSubscription,
                      prefixIcon: const Icon(Icons.search, color: _muted),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF0E6E0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF0E6E0))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView(scrollDirection: Axis.horizontal, children: [
                      for (final (key, label) in [
                        ('all', s.waterCalendarAll),
                        ('morning', s.waterCalendarMorning),
                        ('afternoon', s.waterCalendarAfternoon),
                        ('evening', s.waterCalendarEvening),
                        ('paused', s.waterCalendarPaused),
                      ])
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(label, style: _t(13, FontWeight.w600, _filter == key ? Colors.white : _ink)),
                            selected: _filter == key,
                            showCheckmark: false,
                            selectedColor: _orange,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            onSelected: (_) {
                              setState(() => _filter = key);
                              _load();
                            },
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Text(WaterApi.longDate(_selected), style: _t(15, FontWeight.w700, _ink)),
                  Text(s.waterScheduledDeliveries(total.toString()), style: _t(12, FontWeight.w400, _muted)),
                  const SizedBox(height: 8),
                  if (_loading)
                    const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: _orange)))
                  else if (_error != null)
                    Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center, style: _t(14, FontWeight.w400, _muted)))
                  else if (_slots.every((sl) => (sl['deliveries'] as List?)?.isEmpty ?? true))
                    Padding(padding: const EdgeInsets.all(24), child: Text(s.waterNoDeliveriesThisDay, textAlign: TextAlign.center, style: _t(14, FontWeight.w400, _muted)))
                  else
                    for (final slot in _slots)
                      if ((slot['deliveries'] as List?)?.isNotEmpty ?? false) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(children: [
                            const Icon(Icons.schedule, size: 16, color: Color(0xFF2563EB)),
                            const SizedBox(width: 6),
                            Text('${slot['period'] ?? slot['slot'] ?? ''}', textDirection: TextDirection.ltr, style: _t(13, FontWeight.w600, const Color(0xFF2563EB))),
                          ]),
                        ),
                        for (final d in (slot['deliveries'] as List).whereType<Map>()) _deliveryCard(s, Map<String, dynamic>.from(d)),
                      ],
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  TextStyle _t(double size, FontWeight w, Color c) => appFont('Inter', fontSize: size, fontWeight: w, color: c);

  Widget _statCard(String label, int value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(), style: _t(11, FontWeight.w600, _muted)),
            const SizedBox(height: 4),
            Text('$value', style: _t(22, FontWeight.w700, color)),
          ]),
        ),
      );

  Widget _dayCell(DateTime day) {
    final selected = day == _selected;
    final count = _countFor(day);
    return GestureDetector(
      onTap: () {
        setState(() => _selected = day);
        _load();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: selected ? _orange : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(WaterApi.shortWeekday(day).toUpperCase(), style: _t(10, FontWeight.w600, selected ? Colors.white : _muted)),
          Text('${day.day}', style: _t(17, FontWeight.w700, selected ? Colors.white : _ink)),
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: selected ? Colors.white24 : const Color(0xFFFFEDE4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count', style: _t(10, FontWeight.w700, selected ? Colors.white : _orange)),
          ),
        ]),
      ),
    );
  }

  Widget _deliveryCard(S s, Map<String, dynamic> d) {
    final paused = '${d['status']}' == 'paused';
    final selfPickup = '${d['delivery']}' == 'self_pickup';
    final freq = int.tryParse('${d['frequency_days'] ?? ''}') ?? 0;
    final freqLabel = switch (freq) {
      1 => s.waterDaily,
      7 => s.waterWeekly,
      14 => s.waterBiWeekly,
      30 => s.waterMonthly,
      final n when n > 0 => s.waterEveryNDays(n.toString()),
      _ => '',
    };
    final name = '${d['customer_name'] ?? ''}';
    final customerId = int.tryParse('${d['customer_id'] ?? ''}');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFFFEDE4),
            child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: _t(14, FontWeight.w700, _orange)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: _t(14, FontWeight.w700, _ink)),
              Text(
                [selfPickup ? s.waterSelfPickup : s.waterDelivery, if (d['order_code'] != null) '#${d['order_code']}'].join(' • '),
                style: _t(11, FontWeight.w500, _orange),
              ),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _pill(paused ? s.waterCalendarPaused : s.waterActive, paused ? const Color(0xFFE11D48) : const Color(0xFF16A34A)),
            if (freqLabel.isNotEmpty) ...[const SizedBox(height: 4), _pill(freqLabel, const Color(0xFF7C3AED))],
          ]),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${d['product_name'] ?? ''} × ${d['bottles'] ?? 1}', style: _t(13, FontWeight.w600, _ink)),
            if ('${d['time'] ?? d['period'] ?? ''}'.isNotEmpty)
              Text('${d['time'] ?? d['period']}', textDirection: TextDirection.ltr, style: _t(12, FontWeight.w400, _muted)),
          ]),
        ),
        if (customerId != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () => ChatView.open(
                context,
                customerName: name,
                customerId: customerId,
                orderId: int.tryParse('${d['subscription_id'] ?? ''}'),
              ),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(s.waterChatWithCustomer, style: _t(14, FontWeight.w600, Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: _t(11, FontWeight.w600, color)),
      );
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
              S.of(context).waterSubscriptionCalendar,
              style: appFont('Inter', color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 18),
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
                  child: const Icon(Icons.chevron_left_rounded, color: Color(0xFFFF5216), size: 26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
