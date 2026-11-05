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

extension on String {
  /// First user-visible character (keeps accented letters whole).
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
