import 'package:flutter/material.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// "Needs your attention" on the notifications screens (API doc §6.44,
/// task V18): orders waiting to be accepted, water subscriptions to review
/// and low-stock water items, from `GET activityNotifications`. The feed is
/// live data, so a row disappears once it is handled. Opening it marks the
/// feed as read (`POST readActivityNotifications`). Admin broadcasts stay in
/// the list below it. Built without a Figma screen, in the list's style.
class ActivityNotificationsSection extends StatefulWidget {
  const ActivityNotificationsSection({super.key, this.onTap, this.loader});

  /// What a row opens (e.g. the order); null shows the rows without action.
  final void Function(Map<String, dynamic> row)? onTap;

  /// Rows source; the API by default (tests pass fixed rows).
  final Future<List<Map<String, dynamic>>> Function()? loader;

  @override
  State<ActivityNotificationsSection> createState() => _ActivityNotificationsSectionState();
}

class _ActivityNotificationsSectionState extends State<ActivityNotificationsSection> {
  static const _orange = Color(0xFFFF5216);
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<List<Map<String, dynamic>>> _fetch() async {
    final token = (await getSavedObject('token'))?.toString() ?? '';
    if (token.isNotEmpty) DioClient().updateToken(token);
    final res = await DioClient().get(ApiEndPoints.activityNotifications, query: {'limit': 30});
    final data = res.data is Map ? res.data['data'] : null;
    final list = data is Map ? data['notifications'] : null;
    // Seen now: the badge count resets (rows stay until handled).
    DioClient().post(ApiEndPoints.readActivityNotifications).then((_) {}, onError: (_) {});
    return list is List ? list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : [];
  }

  Future<void> _load() async {
    try {
      final rows = await (widget.loader ?? _fetch)();
      if (mounted) setState(() => _rows = rows);
    } catch (e) {
      debugPrint('activityNotifications: $e');
    }
  }

  String _local(Map<String, dynamic> r, String base) {
    final lang = LocalizationService.currentLanguageCode;
    final v = '${r['${base}_$lang'] ?? ''}'.trim();
    return v.isNotEmpty && v != 'null' ? v : '${r['${base}_en'] ?? ''}';
  }

  IconData _icon(String kind) => switch (kind) {
        'new_subscription' => Icons.autorenew_rounded,
        'low_stock' => Icons.inventory_2_outlined,
        _ => Icons.receipt_long_outlined,
      };

  @override
  Widget build(BuildContext context) {
    if (_rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(S.of(context).needsYourAttention.toUpperCase(),
              style: appFont('Inter', fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF6B7280))),
          const SizedBox(height: 8),
          for (final r in _rows.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              // Material (not a coloured box) so the ListTile's ripple shows.
              child: Material(
              color: r['read'] == true ? Colors.white : const Color(0xFFFFF4EC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFFFE0D0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: widget.onTap == null ? null : () => widget.onTap!(r),
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(_icon('${r['kind']}'), color: _orange, size: 20),
                ),
                title: Text(_local(r, 'title'), style: appFont('Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: '${r['content'] ?? ''}'.trim().isEmpty
                    ? null
                    : Text('${r['content']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: appFont('Inter', fontSize: 12)),
                trailing: Text(_local(r, 'action'), style: appFont('Inter', fontSize: 12, fontWeight: FontWeight.w700, color: _orange)),
              ),
              ),
            ),
        ],
      ),
    );
  }
}
