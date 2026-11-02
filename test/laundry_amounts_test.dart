import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';

// Laundry weight top-up (test day 2 Nov, LNKKNMD1): estimate 3 kg x 120 =
// 360 paid by wallet, weighed 5 kg = 600, 240 still due.
CleaningBooking _booking(int status, num total, num totalPaid, num extra) =>
    CleaningBooking.fromJson({
      'id': 1,
      'status': status,
      'total': total,
      'total_paid': totalPaid,
      'additional_payment': extra,
    });

void main() {
  test('payment requested, before pickup: 360 paid, 600 final', () {
    final b = _booking(2, 360, 360, 240);
    expect(b.paidAmount, 360);
    expect(b.finalAmount, 600);
  });

  test('after pickup the total is already 600: still 360 paid, 600 final', () {
    final b = _booking(3, 600, 600, 240);
    expect(b.paidAmount, 360);
    expect(b.finalAmount, 600);
  });

  test('top-up paid: 600 paid, 600 final', () {
    final b = _booking(4, 600, 600, 0);
    expect(b.paidAmount, 600);
    expect(b.finalAmount, 600);
  });

  test('unpaid cash booking stays at 0 paid', () {
    final b = _booking(3, 600, 0, 240);
    expect(b.paidAmount, 0);
    expect(b.finalAmount, 600);
  });
}
