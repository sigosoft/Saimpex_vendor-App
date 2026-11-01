import 'package:flutter/material.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/water/core/water_api.dart';

/// One delivery of a subscription (§6.41): Delivered / In progress /
/// Cancelled, order code, date. Figma subscription details (8360:40537).
class DeliveryHistoryTile extends StatelessWidget {
  const DeliveryHistoryTile({super.key, required this.row});

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (String label, Color color, IconData icon) = switch ('${row['status_key'] ?? ''}') {
      'delivered' => (s.waterDelivered, const Color(0xFF16A34A), Icons.check_circle_outline),
      'cancelled' => (s.cancelled, const Color(0xFFE11D48), Icons.cancel_outlined),
      _ => (s.waterInProgress, const Color(0xFF2563EB), Icons.local_shipping_outlined),
    };
    final when = WaterApi.formatDate(row['delivered_at'] ?? row['scheduled_for']);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, size: 18, color: color)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: appFont('Inter', fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
            Text(
              [if (row['order_code'] != null) '#${row['order_code']}', if (when != '—') when].join(' • '),
              style: appFont('Inter', fontSize: 12, color: const Color(0xFF6B7280)),
            ),
          ]),
        ),
        if (row['total'] != null)
          Text(WaterApi.money(row['total']), style: appFont('Inter', fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
      ]),
    );
  }
}

/// All deliveries of a subscription, newest first
/// (`GET vendorapp/waterSubscriptionDeliveries`, paginated).
class DeliveryHistoryView extends StatefulWidget {
  const DeliveryHistoryView({super.key, required this.subscriptionId});

  final dynamic subscriptionId;

  static Future<void> open(BuildContext context, dynamic subscriptionId) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => DeliveryHistoryView(subscriptionId: subscriptionId)));

  @override
  State<DeliveryHistoryView> createState() => _DeliveryHistoryViewState();
}

class _DeliveryHistoryViewState extends State<DeliveryHistoryView> {
  final List<Map<String, dynamic>> _rows = [];
  int _page = 1;
  bool _loading = false;
  bool _more = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading || !_more) return;
    setState(() => _loading = true);
    try {
      await WaterApi.prepare();
      final res = await DioClient().get(ApiEndPoints.waterSubscriptionDeliveries,
          query: {'subscription_id': widget.subscriptionId, 'page': _page, 'limit': 20});
      final body = res.data;
      if (!WaterApi.isOk(body)) throw WaterApi.message(body) ?? S.current.waterSomethingWentWrong;
      final data = body is Map ? body['data'] : null;
      final page = data is Map ? (data['deliveries'] ?? data) : null;
      if (!mounted) return;
      setState(() {
        _rows.addAll(WaterApi.pageItems(page));
        _more = WaterApi.hasMore(page);
        _page++;
      });
    } catch (e) {
      if (mounted) setState(() => _error = WaterApi.errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9F6),
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF1A1A1A),
        title: Text(s.waterDeliveryHistory, style: appFont('Inter', fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 200) _load();
          return false;
        },
        child: ListView(padding: const EdgeInsets.all(16), children: [
          for (final r in _rows) DeliveryHistoryTile(row: r),
          if (_loading) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: Color(0xFFFF5216)))),
          if (!_loading && _rows.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(_error ?? s.waterNoDeliveriesYet, textAlign: TextAlign.center, style: appFont('Inter', fontSize: 14, color: const Color(0xFF6B7280))),
            ),
        ]),
      ),
    );
  }
}
