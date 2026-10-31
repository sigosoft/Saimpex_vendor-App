import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/payment_type.dart';

void main() {
  test('reads payment_type codes and older text values', () {
    expect(paymentTypeCode(1), PaymentType.cash);
    expect(paymentTypeCode('2'), PaymentType.online);
    expect(paymentTypeCode(' 3 '), PaymentType.wallet);
    expect(paymentTypeCode('4'), PaymentType.payAfterDelivery);
    expect(paymentTypeCode('COD'), PaymentType.cash);
    expect(paymentTypeCode('Cash'), PaymentType.cash);
    expect(paymentTypeCode('online'), PaymentType.online);
    expect(paymentTypeCode('wallet'), PaymentType.wallet);
    expect(paymentTypeCode('pay_after_delivery'), PaymentType.payAfterDelivery);
    expect(paymentTypeCode(null), isNull);
    expect(paymentTypeCode(''), isNull);
  });

  test('only Cash on Delivery is cash', () {
    expect(isCashPayment('1'), isTrue);
    expect(isCashPayment('2'), isFalse);
    expect(isCashPayment('3'), isFalse);
    expect(isCashPayment('4'), isFalse);
    expect(isCashPayment(null), isFalse);
  });

  test('labels in English and Arabic', () async {
    await S.load(const Locale('en'));
    expect(paymentTypeLabel('1'), 'Cash on Delivery');
    expect(paymentTypeLabel('2'), 'Online Payment');
    expect(paymentTypeLabel('3'), 'SAIMPEX Wallet');
    expect(paymentTypeLabel('4'), 'Pay After Delivery');
    expect(paymentTypeLabel(null), 'Online Payment');
    expect(paymentTypeLabel(null, cashFallback: true), 'Cash on Delivery');

    await S.load(const Locale('ar'));
    expect(paymentTypeLabel('3'), 'محفظة SAIMPEX');
    expect(paymentTypeLabel('4'), 'الدفع بعد التوصيل');
  });
}
