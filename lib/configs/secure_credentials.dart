import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the vendor password, used for silent re-login and FCM token sync,
/// in the platform keystore instead of plain SharedPreferences.
class SecureCredentials {
  SecureCredentials._();

  static const _storage = FlutterSecureStorage();
  static const _passwordKey = 'vendor_password';

  static Future<void> savePassword(String password) =>
      _storage.write(key: _passwordKey, value: password);

  /// The saved password while a user is logged in. Logout clears the
  /// username from SharedPreferences, so a password without a username is
  /// left over from a logged-out session and is deleted instead of used.
  static Future<String?> readPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.get('username');
    // Older builds stored the password in plain SharedPreferences.
    // savename() JSON-encodes values, so decode it back to the raw password.
    final legacy = prefs.getString('password');
    if (legacy != null) {
      await prefs.remove('password');
      if (username != null) {
        String value;
        try {
          value = '${jsonDecode(legacy)}';
        } catch (_) {
          value = legacy;
        }
        await savePassword(value);
      }
    }
    if (username == null) {
      await clear();
      return null;
    }
    return _storage.read(key: _passwordKey);
  }

  static Future<void> clear() => _storage.delete(key: _passwordKey);
}
