import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// Push notifications on / off for this vendor (API doc §6.42, task V18):
/// `GET` / `POST vendorapp/notification/preference`. With it off the server
/// sends no push; the in-app notification list is unchanged.
class NotificationPreference {
  const NotificationPreference._();

  static Future<void> _auth() async {
    final token = (await getSavedObject('token'))?.toString() ?? '';
    if (token.isNotEmpty) DioClient().updateToken(token);
  }

  /// The saved choice; null when it couldn't be read.
  static Future<bool?> load() async {
    try {
      await _auth();
      final res = await DioClient().get(ApiEndPoints.notificationPreference);
      final data = res.data is Map ? res.data['data'] : null;
      if (data is! Map) return null;
      final v = data['notification_enabled'];
      return v == true || v?.toString() == '1';
    } catch (_) {
      return null;
    }
  }

  /// Saves [enabled]; returns false when the server refused or failed.
  static Future<bool> save(bool enabled) async {
    try {
      await _auth();
      final res = await DioClient().post(ApiEndPoints.notificationPreference, body: {'notification_enabled': enabled});
      return res.data is Map && res.data['status'] == true;
    } catch (_) {
      return false;
    }
  }
}
