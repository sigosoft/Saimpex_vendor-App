import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/utils/utils.dart';

void main() {
  test('English patterns are unchanged', () {
    expect(localizeDatePattern('MMM dd, yyyy hh:mm a', 'en'),
        'MMM dd, yyyy hh:mm a');
  });

  test('French: day first and 24-hour clock', () {
    expect(localizeDatePattern('MMM dd, yyyy hh:mm a', 'fr'),
        'dd MMM yyyy HH:mm');
    expect(localizeDatePattern('MMM dd, yyyy, h:mm a', 'fr'),
        'dd MMM yyyy, H:mm');
    expect(localizeDatePattern('MMM d, yyyy', 'fr'), 'd MMM yyyy');
    expect(localizeDatePattern('MMM dd yyyy, hh:mm a', 'fr'),
        'dd MMM yyyy, HH:mm');
    expect(localizeDatePattern('MMM d', 'fr'), 'd MMM');
    expect(localizeDatePattern('hh:mm a', 'fr'), 'HH:mm');
  });

  test('Arabic: day first, keeps AM/PM', () {
    expect(localizeDatePattern('MMM dd, yyyy hh:mm a', 'ar'),
        'dd MMM yyyy hh:mm a');
    expect(localizeDatePattern('dd MMM yyyy, hh:mm a', 'ar'),
        'dd MMM yyyy, hh:mm a');
  });
}
