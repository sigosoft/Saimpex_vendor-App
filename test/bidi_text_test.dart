import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/utils/bidi_text.dart';

String _strip(String s) => s.replaceAll(String.fromCharCode(0x2066), '').replaceAll(String.fromCharCode(0x2069), '');

void main() {
  test('signed amount keeps the sign with the number (V18)', () {
    final text = signedMru('+', '240');
    expect(_strip(text), '+240 MRU');
    expect(text.startsWith(String.fromCharCode(0x2066)), isTrue);
  });

  test('number and unit stay one LTR run; other text untouched (V18)', () {
    expect(_strip(keepNumberUnitsLtr('مياه 19 L')), 'مياه 19 L');
    expect(keepNumberUnitsLtr('مياه 19 L'), contains('${String.fromCharCode(0x2066)}19 L${String.fromCharCode(0x2069)}'));
    expect(keepNumberUnitsLtr('Litre'), 'Litre');
    expect(keepNumberUnitsLtr('12 items'), '12 items');
  });

  test('joined header parts are isolated so the code and day stay apart', () {
    final fsi = String.fromCharCode(0x2068), pdi = String.fromCharCode(0x2069);
    expect(joinIsolated(['الحجز #HCNYJHTV', '5 نوفمبر 2026'], ' • '),
        '$fsiالحجز #HCNYJHTV$pdi • ${fsi}5 نوفمبر 2026$pdi');
  });
}
