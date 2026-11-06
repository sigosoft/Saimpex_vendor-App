import 'dart:io';

import 'package:saimpex_vendor/configs/ApiConfigs.dart';

/// Avatar initials for a store with no logo, as in the Figma "R1" avatar
/// ("Restaurant 1"): the first letter of the first two words of the real
/// name ("Le Méchoui du Ksar" → "LM"), or of the one word. Empty when the
/// name is unknown, so no sample text ("R1") is shown.
String vendorInitials(String? name) {
  final words = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  return words.take(2).map((w) => w.characters.first.toUpperCase()).join();
}

/// A store image just picked on the phone (absolute path that exists), else
/// null.
File? storeImageLocalFile(String? raw) {
  final v = (raw ?? '').trim();
  if (v.isEmpty || v.startsWith('http')) return null;
  final file = File(v);
  return file.isAbsolute && file.existsSync() ? file : null;
}

/// Network URL of a store image from the API: a full URL as is, or a storage
/// path (users.image, "user/images/x.png") under [ApiConfigs.IMAGE_URL].
/// Null when there is no image or [raw] is a phone file.
String? storeImageNetworkUrl(String? raw) {
  final v = (raw ?? '').trim();
  if (v.isEmpty || v == 'null') return null;
  if (v.startsWith('http://') || v.startsWith('https://')) return v;
  if (storeImageLocalFile(v) != null) return null;
  var path = v.startsWith('/') ? v.substring(1) : v;
  if (path.startsWith('storage/') && ApiConfigs.IMAGE_URL.endsWith('storage/')) {
    path = path.substring('storage/'.length);
  }
  return '${ApiConfigs.IMAGE_URL}$path';
}

extension on String {
  /// First user-visible character (keeps accented letters whole).
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
