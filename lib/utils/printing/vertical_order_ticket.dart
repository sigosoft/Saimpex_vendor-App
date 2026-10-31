import 'package:saimpex_vendor/model/OrderDetailsModel.dart';

/// Pharmacy and water order details (`pharmacyOrderDetail`, `waterOrderDetail`)
/// come back as `{order, items}`. This maps them onto the restaurant/grocery
/// order model the ticket builder already prints (V7, handover P12).
Data ticketDataFromVerticalDetail(Map<String, dynamic> data) {
  final order = Map<String, dynamic>.from((data['order'] as Map?) ?? const {});
  final rawItems = (data['items'] as List?) ?? const [];
  final customer = data['customer'] is Map ? data['customer'] as Map : const {};

  String? str(dynamic v) => v?.toString();
  String? firstText(List<dynamic> values) {
    for (final v in values) {
      final s = v?.toString().trim();
      if (s != null && s.isNotEmpty && s != 'null') return s;
    }
    return null;
  }

  final items = rawItems.whereType<Map>().map((raw) {
    final i = Map<String, dynamic>.from(raw);
    final attr = firstText([i['attribute_value']]);
    String? named(String key) {
      final n = firstText([i[key]]);
      return (n != null && attr != null) ? '$n ($attr)' : n;
    }

    final qty = int.tryParse(i['quantity']?.toString() ?? '') ?? 1;
    final unit = double.tryParse(i['unit_price']?.toString() ?? '');
    final lineTotal =
        firstText([i['total_price']]) ??
        (unit != null ? (unit * qty).toStringAsFixed(2) : null);
    return {
      'order_item': {
        'name_en': named('name_en'),
        'name_fr': named('name_fr'),
        'name_ar': named('name_ar'),
      },
      'quantity': qty,
      'unit_price': str(i['unit_price']),
      'price': lineTotal,
    };
  }).toList();

  return Data.fromJson({
    'id': order['id'],
    'order_code': str(order['order_code']),
    'placed_at': firstText([order['placed_at'], order['created_at']]),
    'user_name': firstText([
      order['customer_name'],
      customer['name'],
      order['user_name'],
    ]),
    'payment_type': str(order['payment_type']),
    'subtotal': str(order['subtotal']),
    'tax': str(order['tax']),
    'delivery_fee': str(order['delivery_fee']),
    'total': str(order['total']),
    'customer_note': firstText([
      order['notes'],
      order['order_note'],
      order['customer_note'],
    ]),
    'type': 'normal',
    'orderItems': items,
  });
}
