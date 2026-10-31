import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// Small shared helpers for the Water screens that talk to `vendorapp/*`.
/// Envelope: `{status, data, message}`; `status` may be bool or "true";
/// `message` may be a String or `{message_en, message_fr, message_ar}` (each a
/// String or a List).
class WaterApi {
  WaterApi._();

  /// Water vendors are `vendor_type = 4` (see backend §6.23).
  static const String waterVendorType = '4';

  /// Attaches the saved token (DioClient also does this in its interceptor).
  static Future<void> prepare() async {
    final token = (await getSavedObject('token'))?.toString() ?? '';
    if (token.isNotEmpty && token != 'null' && token != 'false') {
      DioClient().updateToken(token);
    }
  }

  /// Saved vendor type, falling back to water (4).
  static Future<String> vendorType() async {
    final saved = (await getSavedObject('vendorType'))?.toString() ?? '';
    if (saved.isEmpty || saved == 'null' || saved == '0') return waterVendorType;
    return saved;
  }

  static bool isOk(dynamic body) {
    if (body is! Map) return false;
    final status = body['status'];
    return status == true || status?.toString() == 'true' || status?.toString() == '1';
  }

  /// Server message in the current app language, or null.
  static String? message(dynamic body) {
    if (body is! Map) return null;
    final msg = body['message'];
    if (msg is String) return msg.trim().isEmpty ? null : msg;
    if (msg is Map) {
      final lang =
          FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
      final key = lang == 'ar'
          ? 'message_ar'
          : lang == 'fr'
              ? 'message_fr'
              : 'message_en';
      String? pick(dynamic v) {
        if (v is List && v.isNotEmpty) return v.first?.toString();
        if (v is String && v.trim().isNotEmpty) return v;
        return null;
      }

      return pick(msg[key]) ?? pick(msg['message_en']);
    }
    return null;
  }

  /// Laravel paginator `{data: [...], current_page, last_page}` or a list.
  static List<Map<String, dynamic>> pageItems(dynamic page) {
    final raw = page is Map ? page['data'] : page;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static bool hasMore(dynamic page) {
    if (page is! Map) return false;
    final current = int.tryParse('${page['current_page']}') ?? 1;
    final last = int.tryParse('${page['last_page']}') ?? 1;
    return current < last;
  }

  /// DioClient throws the (already localised) server message as a String.
  static String errorText(Object error) {
    if (error is String && error.trim().isNotEmpty) return error;
    return S.current.waterSomethingWentWrong;
  }

  /// "5m ago" / "3h ago" / "2d ago", then DD/MM/YYYY after a week.
  static String timeAgo(dynamic value) {
    final dt = parseDate(value);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return S.current.cleaningJustNow;
    if (diff.inHours < 1) return '${diff.inMinutes}${S.current.mAgo}';
    if (diff.inDays < 1) return '${diff.inHours}${S.current.hAgo}';
    if (diff.inDays < 7) return '${diff.inDays}${S.current.dAgo}';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  static String _locale() =>
      FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';

  /// Server timestamps are UTC ISO strings or "Y-m-d H:i:s"; null when unparseable.
  static DateTime? parseDate(dynamic value) {
    final s = value?.toString().trim() ?? '';
    if (s.isEmpty || s == 'null') return null;
    final dt = DateTime.tryParse(s);
    if (dt == null) return null;
    return dt.isUtc ? dt.toLocal() : dt;
  }

  /// DD/MM/YYYY, or '—' when missing.
  static String formatDate(dynamic value) {
    final dt = parseDate(value);
    if (dt == null) return '—';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  /// DD/MM/YYYY hh:mm a, or '—' when missing.
  static String formatDateTime(dynamic value) {
    final dt = parseDate(value);
    if (dt == null) return '—';
    return DateFormat('dd/MM/yyyy • hh:mm a', _locale()).format(dt);
  }

  static String formatTime(DateTime dt) =>
      DateFormat('hh:mm a', _locale()).format(dt);

  static String weekday(DateTime dt) => DateFormat('EEEE', _locale()).format(dt);

  /// "1,234.00 MRU"
  static String money(dynamic value) {
    final n = double.tryParse(value?.toString() ?? '');
    if (n == null) return '—';
    return '${NumberFormat('#,##0.00', 'en').format(n)} MRU';
  }
}
