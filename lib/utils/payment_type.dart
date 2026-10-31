import 'package:saimpex_vendor/generated/l10n.dart';

/// Order `payment_type` codes (V2 scope §4.4).
class PaymentType {
  static const int cash = 1;
  static const int online = 2;
  static const int wallet = 3;
  static const int payAfterDelivery = 4;
}

/// Reads `payment_type` as sent by the API: a code (1–4, int or string) or an
/// older text value ("cash", "cod", "online", "wallet").
int? paymentTypeCode(dynamic raw) {
  final value = raw?.toString().trim().toLowerCase() ?? '';
  if (value.isEmpty) return null;
  final code = int.tryParse(value);
  if (code != null) return code;
  if (value.contains('cash') || value == 'cod') return PaymentType.cash;
  if (value.contains('wallet')) return PaymentType.wallet;
  if (value.contains('after')) return PaymentType.payAfterDelivery;
  if (value.contains('online')) return PaymentType.online;
  return null;
}

/// Only Cash on Delivery is cash; Wallet and Pay After Delivery are not.
bool isCashPayment(dynamic raw) => paymentTypeCode(raw) == PaymentType.cash;

/// Localised label for a `payment_type`. When the type is missing,
/// [cashFallback] picks between Cash on Delivery and Online Payment.
String paymentTypeLabel(dynamic raw, {bool cashFallback = false}) {
  switch (paymentTypeCode(raw)) {
    case PaymentType.cash:
      return S.current.cashOnDelivery;
    case PaymentType.online:
      return S.current.onlinePayment;
    case PaymentType.wallet:
      return S.current.walletPayment;
    case PaymentType.payAfterDelivery:
      return S.current.payAfterDelivery;
    default:
      return cashFallback ? S.current.cashOnDelivery : S.current.onlinePayment;
  }
}
