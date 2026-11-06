import 'package:flutter_localization/flutter_localization.dart';

/// Picks the server's message in the app language from the API envelope
/// `{status, data, message}`.
///
/// `message` comes in several shapes:
/// - `{message_en, message_fr, message_ar}` (each a String or a List);
/// - validation / login errors keyed by field: `{password_en: [..],
///   password_fr: [..], password_ar: [..]}`;
/// - nested per field: `{field: {message_en: [..], ...}}`;
/// - a plain String (English).
///
/// Server English must not show in the Arabic or French app (VA-03: the
/// wrong-password reply has `password_ar`, but the app showed `password_en`
/// because it took the first entry of the map).
class ApiMessage {
  ApiMessage._();

  static String get _lang =>
      FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';

  static String? _first(dynamic v) {
    if (v is List && v.isNotEmpty) {
      final s = v.first?.toString().trim() ?? '';
      return s.isEmpty ? null : s;
    }
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return null;
  }

  /// The message in the app language only, else null. A plain String counts
  /// as English.
  static String? local(dynamic body) {
    if (body is! Map) return null;
    return fromMessage(body['message']);
  }

  /// Same as [local], for the `message` value itself.
  static String? fromMessage(dynamic msg) {
    final lang = _lang;
    if (msg is String) {
      return lang == 'en' && msg.trim().isNotEmpty ? msg.trim() : null;
    }
    if (msg is! Map) return null;
    final direct = _first(msg['message_$lang']);
    if (direct != null) return direct;
    // Field-keyed errors: <field>_<lang>.
    for (final entry in msg.entries) {
      if (entry.key.toString().endsWith('_$lang')) {
        final s = _first(entry.value);
        if (s != null) return s;
      }
    }
    // Nested per field: {field: {message_<lang>: [..]}}.
    for (final value in msg.values) {
      if (value is Map) {
        final s = _first(value['message_$lang']);
        if (s != null) return s;
      }
    }
    return null;
  }

  /// [local], or [fallback] (the app's own text) when the server has no text
  /// in the app language.
  static String localOr(dynamic body, String fallback) =>
      local(body) ?? fallback;
}
