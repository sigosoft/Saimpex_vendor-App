import 'dart:convert';

import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';

/// Result of one vendorapp call: the `data` payload when `status` is true,
/// plus the server message in the current language.
class CleaningApiResult {
  const CleaningApiResult({required this.ok, this.data, this.message});

  final bool ok;
  final dynamic data;
  final String? message;

  Map<String, dynamic> get map =>
      data is Map ? Map<String, dynamic>.from(data as Map) : <String, dynamic>{};
}

/// Thin wrapper over [DioClient] for the service-vertical endpoints
/// (ServiceVerticalController). Never logs headers or tokens.
class CleaningApi {
  const CleaningApi._();

  static String get languageCode {
    final code = Get.locale?.languageCode ?? LocalizationService.currentLanguageCode;
    return (code == 'fr' || code == 'ar') ? code : 'en';
  }

  static Future<CleaningApiResult> get(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _run(() => DioClient().get(path, query: query));
  }

  static Future<CleaningApiResult> post(String path, Map<String, dynamic> body) {
    return _run(() => DioClient().post(path, body: body));
  }

  static Future<CleaningApiResult> _run(Future<dynamic> Function() call) async {
    try {
      final response = await call();
      final body = _asMap(response.data);
      if (body == null) {
        return const CleaningApiResult(ok: false);
      }
      final status = body['status'];
      final ok = status == true || status.toString() == 'true';
      return CleaningApiResult(
        ok: ok,
        data: body['data'],
        message: pickMessage(body['message']),
      );
    } catch (e) {
      // DioClient rethrows its own localised/English error string.
      final text = e is String ? e : null;
      return CleaningApiResult(ok: false, message: text);
    }
  }

  static Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  /// `{message_en: [..], message_fr: [..], message_ar: [..]}` (lists or
  /// strings) to the text for the current language, falling back to English.
  static String? pickMessage(dynamic message) {
    if (message is String) return message.trim().isEmpty ? null : message;
    if (message is! Map) return null;
    String? read(String key) {
      final v = message[key];
      if (v is List && v.isNotEmpty) return v.first?.toString();
      if (v is String && v.trim().isNotEmpty) return v;
      return null;
    }

    return read('message_$languageCode') ?? read('message_en');
  }
}
