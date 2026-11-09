import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/view/notifications/notification.dart';

void main() {
  test('booking code is read from the push text', () {
    expect(FCM.bookingCodeFromText('New booking #HCVRQZLW received.'), 'HCVRQZLW');
    expect(FCM.bookingCodeFromText('حجز جديد #LNMR4R1P مستلم.'), 'LNMR4R1P');
    expect(FCM.bookingCodeFromText('New booking received'), isNull);
    expect(FCM.bookingCodeFromText(null), isNull);
  });

  test('popup shows a booking code with #, an id as ORD-', () {
    expect(FCM.cleanOrderNumber('HCVRQZLW'), '#HCVRQZLW');
    expect(FCM.cleanOrderNumber('1557'), 'ORD-001557');
  });
}
