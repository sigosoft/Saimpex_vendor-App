import 'package:flutter/material.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/cleaning_api.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';

// Account screens of the service section (laundry, car wash, home cleaning;
// task V15). They used to open the Water screens, which call the water
// endpoints. Now on the service endpoints: serviceHours / saveServiceHours,
// serviceAvailability, serviceEarnings. Built in the section's style
// (VENDOR_APP_DESIGNS.md §3).

const Color _bg = Color(0xFFFFF8F0);
const Color _orange = Color(0xFFFF5216);
const Color _ink = Color(0xFF111827);
const Color _muted = Color(0xFF6B7280);
const Color _border = Color(0xFFF0ECE4);

TextStyle _t(double size, FontWeight w, Color c) => appFont('Inter', fontSize: size, fontWeight: w, color: c);

String _mru(num v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

Widget _scaffold(BuildContext context, {required String title, required Widget body, Widget? bottom}) {
  final rtl = LocalizationService.currentLanguageCode == 'ar';
  return Directionality(
    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    child: Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: _ink,
        title: Text(title, style: _t(17, FontWeight.w700, _ink)),
      ),
      body: body,
      bottomNavigationBar: bottom == null ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: bottom)),
    ),
  );
}

Widget _card(List<Widget> children) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );

Widget _primary(String label, VoidCallback? onTap, {bool busy = false}) => SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: busy ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          disabledBackgroundColor: _orange.withValues(alpha: 0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: _t(15, FontWeight.w700, Colors.white)),
      ),
    );

// ── Working hours & booking slots ───────────────────────────────────────

class ServiceWorkingHoursView extends StatefulWidget {
  const ServiceWorkingHoursView({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ServiceWorkingHoursView()));

  @override
  State<ServiceWorkingHoursView> createState() => _ServiceWorkingHoursViewState();
}

class _ServiceWorkingHoursViewState extends State<ServiceWorkingHoursView> {
  List<Map<String, dynamic>> _days = [];
  List<Map<String, dynamic>> _slots = [];
  int _capacity = 1;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await CleaningApi.get(ApiEndPoints.serviceHours);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (!res.ok) {
        _error = res.message ?? '';
        return;
      }
      List<Map<String, dynamic>> rows(dynamic v) =>
          v is List ? v.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : [];
      _days = rows(res.map['days']);
      _slots = rows(res.map['slots']);
      _capacity = int.tryParse('${res.map['slot_capacity'] ?? 1}') ?? 1;
    });
  }

  String _dayLabel(BuildContext context, String day) {
    final s = S.of(context);
    return switch (day.toLowerCase()) {
      'monday' => s.monday,
      'tuesday' => s.tuesday,
      'wednesday' => s.wednesday,
      'thursday' => s.thursday,
      'friday' => s.friday,
      'saturday' => s.saturday,
      'sunday' => s.sunday,
      _ => day,
    };
  }

  Future<void> _pickTime(Map<String, dynamic> day, String key) async {
    final parts = '${day[key] ?? '08:00'}'.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0),
    );
    if (picked == null) return;
    setState(() => day[key] = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final res = await CleaningApi.post(ApiEndPoints.saveServiceHours, {
      'days': [
        for (final d in _days) {'day': d['day'], 'start': d['start'], 'end': d['end'], 'closed': d['closed'] == true || d['closed'] == 1},
      ],
      'slots': [
        for (final s in _slots) {'label': s['label'], 'available': s['available'] == true || s['available'] == 1},
      ],
      'slot_capacity': _capacity,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if ((res.message ?? '').isNotEmpty) messenger.showSnackBar(SnackBar(content: Text(res.message!)));
    if (res.ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _scaffold(
      context,
      title: s.cleaningWorkingHoursBookingSlots,
      bottom: _loading || _error != null ? null : _primary(s.saveChanges, _save, busy: _saving),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _orange))
          : _error != null
              ? Center(child: Text(_error!, style: _t(14, FontWeight.w400, _muted)))
              : ListView(padding: const EdgeInsets.all(16), children: [
                  Text(s.workingHours.toUpperCase(), style: _t(12, FontWeight.w700, _muted)),
                  const SizedBox(height: 8),
                  _card([
                    for (final d in _days)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Expanded(child: Text(_dayLabel(context, '${d['day']}'), style: _t(14, FontWeight.w600, _ink))),
                          if (d['closed'] == true || d['closed'] == 1)
                            Text(s.closed, style: _t(13, FontWeight.w500, _muted))
                          else ...[
                            _timeChip('${d['start']}', () => _pickTime(d, 'start')),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('–')),
                            _timeChip('${d['end']}', () => _pickTime(d, 'end')),
                          ],
                          Switch(
                            value: !(d['closed'] == true || d['closed'] == 1),
                            activeThumbColor: Colors.white,
                            activeTrackColor: _orange,
                            onChanged: (open) => setState(() => d['closed'] = !open),
                          ),
                        ]),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  Text(s.bookingSlots.toUpperCase(), style: _t(12, FontWeight.w700, _muted)),
                  const SizedBox(height: 8),
                  _card([
                    for (final slot in _slots)
                      Row(children: [
                        Expanded(child: Text('${slot['label']}', textDirection: TextDirection.ltr, style: _t(14, FontWeight.w600, _ink))),
                        Text(slot['available'] == true || slot['available'] == 1 ? s.slotAvailable : s.slotUnavailable,
                            style: _t(12, FontWeight.w500, _muted)),
                        Switch(
                          value: slot['available'] == true || slot['available'] == 1,
                          activeThumbColor: Colors.white,
                          activeTrackColor: _orange,
                          onChanged: (v) => setState(() => slot['available'] = v),
                        ),
                      ]),
                  ]),
                  _card([
                    Row(children: [
                      Expanded(child: Text(s.maxBookingsPerSlot, style: _t(14, FontWeight.w600, _ink))),
                      IconButton(
                        onPressed: _capacity > 1 ? () => setState(() => _capacity--) : null,
                        icon: const Icon(Icons.remove_circle_outline, color: _orange),
                      ),
                      Text('$_capacity', style: _t(16, FontWeight.w700, _ink)),
                      IconButton(
                        onPressed: _capacity < 50 ? () => setState(() => _capacity++) : null,
                        icon: const Icon(Icons.add_circle_outline, color: _orange),
                      ),
                    ]),
                  ]),
                ]),
    );
  }

  Widget _timeChip(String text, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
          child: Text(text, textDirection: TextDirection.ltr, style: _t(13, FontWeight.w600, _ink)),
        ),
      );
}

// ── Business settings ───────────────────────────────────────────────────

class ServiceBusinessSettingsView extends StatefulWidget {
  const ServiceBusinessSettingsView({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ServiceBusinessSettingsView()));

  @override
  State<ServiceBusinessSettingsView> createState() => _ServiceBusinessSettingsViewState();
}

class _ServiceBusinessSettingsViewState extends State<ServiceBusinessSettingsView> {
  bool? _accepting;
  bool? _busy;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await CleaningApi.get(ApiEndPoints.serviceDashboard);
    if (!mounted) return;
    final m = res.map;
    setState(() {
      _accepting = '${m['accepting_bookings'] ?? 1}' != '2';
      _busy = '${m['is_busy'] ?? m['busy'] ?? 2}' == '1';
    });
  }

  Future<void> _set({bool? accepting, bool? busy}) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final res = await CleaningApi.post(ApiEndPoints.serviceAvailability, {
      if (accepting != null) 'accepting_bookings': accepting ? 1 : 2,
      if (busy != null) 'is_busy': busy ? 1 : 2,
    });
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (res.ok) {
        _accepting = res.map['accepting_bookings'] == null ? (accepting ?? _accepting) : '${res.map['accepting_bookings']}' != '2';
        _busy = res.map['is_busy'] == null ? (busy ?? _busy) : '${res.map['is_busy']}' == '1';
      }
    });
    if ((res.message ?? '').isNotEmpty) messenger.showSnackBar(SnackBar(content: Text(res.message!)));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    Widget row(String title, String help, bool? value, ValueChanged<bool> onChanged) => Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: _t(15, FontWeight.w600, _ink)),
              Text(help, style: _t(12, FontWeight.w400, _muted)),
            ]),
          ),
          Switch(
            value: value ?? false,
            activeThumbColor: Colors.white,
            activeTrackColor: _orange,
            onChanged: value == null || _saving ? null : onChanged,
          ),
        ]);
    return _scaffold(
      context,
      title: s.cleaningBusinessSettings,
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _card([row(s.acceptingBookings, s.acceptingBookingsHelp, _accepting, (v) => _set(accepting: v))]),
        _card([row(s.markAsBusy, s.markAsBusyHelp, _busy, (v) => _set(busy: v))]),
      ]),
    );
  }
}

// ── Earnings ────────────────────────────────────────────────────────────

class ServiceEarningsView extends StatefulWidget {
  const ServiceEarningsView({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ServiceEarningsView()));

  @override
  State<ServiceEarningsView> createState() => _ServiceEarningsViewState();
}

class _ServiceEarningsViewState extends State<ServiceEarningsView> {
  Map<String, dynamic> _data = {};
  bool _loading = true;
  String _balance = 'all';
  bool _payoutsTab = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await CleaningApi.get(ApiEndPoints.serviceEarnings, query: {'balance': _balance, 'limit': 50});
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.ok) _data = res.map;
    });
  }

  double _num(String key) => double.tryParse('${_data[key] ?? 0}') ?? 0;

  List<Map<String, dynamic>> _rows(String key) {
    final v = _data[key];
    final list = v is Map ? v['data'] : v;
    return list is List ? list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : [];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final filters = [('all', s.cleanerFilterAll), ('available', s.earningsAvailable), ('pending', s.earningsPending), ('cancelled', s.cancelled)];
    return _scaffold(
      context,
      title: s.earnings,
      body: RefreshIndicator(
        color: _orange,
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            _stat(s.earningsPending, _num('pending_order_balance')),
            const SizedBox(width: 8),
            _stat(s.earningsAvailable, _num('available_order_balance')),
            const SizedBox(width: 8),
            _stat(s.payoutReceived, _num('total_payout_received')),
          ]),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(s.earnings)),
              ButtonSegment(value: true, label: Text(s.payouts)),
            ],
            selected: {_payoutsTab},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() => _payoutsTab = v.first),
          ),
          const SizedBox(height: 12),
          if (!_payoutsTab)
            Wrap(spacing: 8, children: [
              for (final (key, label) in filters)
                ChoiceChip(
                  label: Text(label),
                  selected: _balance == key,
                  selectedColor: const Color(0xFFFFE4D6),
                  onSelected: (_) {
                    setState(() => _balance = key);
                    _load();
                  },
                ),
            ]),
          const SizedBox(height: 8),
          if (_loading)
            const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: _orange)))
          else if (!_payoutsTab) ...[
            if (_rows('orders').isEmpty) _empty(s.noEarningsYet),
            for (final o in _rows('orders')) _orderRow(s, o),
          ] else ...[
            if (_rows('payouts').isEmpty) _empty(s.noPayoutsYet),
            for (final p in _rows('payouts')) _payoutRow(p),
          ],
        ]),
      ),
    );
  }

  Widget _empty(String text) =>
      Padding(padding: const EdgeInsets.only(top: 32), child: Text(text, textAlign: TextAlign.center, style: _t(14, FontWeight.w400, _muted)));

  Widget _stat(String label, double value) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: _t(11, FontWeight.w500, _muted)),
            const SizedBox(height: 4),
            Text('${_mru(value)} MRU', style: _t(15, FontWeight.w700, _ink)),
          ]),
        ),
      );

  Widget _orderRow(S s, Map<String, dynamic> o) {
    final status = '${o['earnings_status'] ?? ''}';
    final (String label, Color color) = switch (status) {
      'AVAILABLE' => (s.earningsAvailable, const Color(0xFF16A34A)),
      'CANCELLED' => (s.cancelled, const Color(0xFFE11D48)),
      _ => (s.earningsPending, const Color(0xFFEA7A1A)),
    };
    return _card([
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#${o['order_code'] ?? o['id']}', style: _t(14, FontWeight.w700, _ink)),
            if ('${o['window'] ?? ''}'.isNotEmpty) Text('${o['window']}', style: _t(12, FontWeight.w400, _muted)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${_mru(double.tryParse('${o['amount'] ?? o['total'] ?? 0}') ?? 0)} MRU', style: _t(14, FontWeight.w700, _ink)),
          Text(label, style: _t(12, FontWeight.w600, color)),
        ]),
      ]),
    ]);
  }

  Widget _payoutRow(Map<String, dynamic> p) {
    final amount = double.tryParse('${p['total_paid_amount'] ?? p['amount'] ?? 0}') ?? 0;
    final date = DateTime.tryParse('${p['created_at'] ?? ''}')?.toLocal();
    final note = '${p['notes'] ?? p['note'] ?? ''}'.trim();
    return _card([
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_mru(amount)} MRU', style: _t(15, FontWeight.w700, _ink)),
            if (date != null)
              Text('${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                  style: _t(12, FontWeight.w400, _muted)),
            if (note.isNotEmpty && note != 'null') Text(note, style: _t(12, FontWeight.w400, _muted)),
          ]),
        ),
        const Icon(Icons.account_balance_wallet_outlined, color: _orange),
      ]),
    ]);
  }
}
