/// Bidi helpers for numbers mixed into Arabic (right-to-left) text.
///
/// In an RTL line a "+" or "−" sign and a Latin unit ("L", "kg") are placed by
/// the bidi algorithm on the wrong side of the number ("MRU 240+", "L 19").
/// Wrapping the piece in a left-to-right isolate (U+2066 … U+2069) keeps it
/// together and in reading order; the marks are invisible and change nothing
/// in English or French.
library;

final String _lri = String.fromCharCode(0x2066); // LEFT-TO-RIGHT ISOLATE
final String _pdi = String.fromCharCode(0x2069); // POP DIRECTIONAL ISOLATE

/// [text] as one left-to-right run inside any paragraph.
String ltrIsolate(String text) => '$_lri$text$_pdi';

/// "+240 MRU" / "-40 MRU" with the sign kept next to the number in RTL.
/// [amount] is the formatted absolute value.
String signedMru(String sign, String amount) => '${ltrIsolate('$sign$amount')} MRU';

final RegExp _numberUnit = RegExp(
  r'(\d+(?:[.,]\d+)?)\s*(ml|mL|ML|cl|L|l|kg|Kg|KG|g)\b',
);

/// Keeps every "19 L" / "1.5L" / "12 kg" in [text] as one LTR run.
String keepNumberUnitsLtr(String text) =>
    text.replaceAllMapped(_numberUnit, (m) => ltrIsolate(m[0]!));

final String _fsi = String.fromCharCode(0x2068); // FIRST STRONG ISOLATE

/// [parts] joined with [separator], each laid out on its own. In Arabic a
/// Latin booking code followed by a date ("#HCNYJHTV • 5 نوفمبر") otherwise
/// merges into one left-to-right run and the day jumps next to the code.
String joinIsolated(Iterable<String> parts, String separator) =>
    parts.map((p) => '$_fsi$p$_pdi').join(separator);

/// [text] laid out on its own (first strong isolate), for a piece that sits
/// next to another one in its own style (booking code • date).
String isolated(String text) => '$_fsi$text$_pdi';
