/// Text in the app language from the API's `_en` / `_fr` / `_ar` fields.
///
/// Empty counts as missing: the models store a missing `name_ar` as "", so
/// `nameAr ?? nameEn` gave "" and Arabic item cards showed no name (VA-10).
/// Order: app language, then English, then the other languages.
String pickLang(String? lang, String? en, String? fr, String? ar) {
  String? clean(String? v) {
    final t = v?.trim() ?? '';
    return t.isEmpty || t == 'null' ? null : t;
  }

  final order = switch (lang) {
    'fr' => [fr, en, ar],
    'ar' => [ar, en, fr],
    _ => [en, fr, ar],
  };
  for (final v in order) {
    final c = clean(v);
    if (c != null) return c;
  }
  return '';
}
