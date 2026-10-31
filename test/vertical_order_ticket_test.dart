import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/utils/printing/bluetooth_escpos_printer.dart';
import 'package:saimpex_vendor/utils/printing/esc_pos_receipt_builder.dart';
import 'package:saimpex_vendor/utils/printing/vertical_order_ticket.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Shape of vendorapp/pharmacyOrderDetail and waterOrderDetail: {order, items}.
  final pharmacy = <String, dynamic>{
    'order': {
      'id': 77,
      'order_code': 'PH-000077',
      'placed_at': '2026-10-31 10:30:00',
      'customer_name': 'Fatimetou',
      'payment_type': 1,
      'subtotal': 120,
      'tax': '0.00',
      'delivery_fee': 30,
      'total': '150.00',
      'notes': 'Ring twice',
    },
    'items': [
      {
        'quantity': 2,
        'unit_price': '45.00',
        'total_price': '90.00',
        'name_en': 'Paracetamol 500mg',
        'attribute_value': '20 tabs',
      },
      {
        'quantity': '1',
        'unit_price': 30,
        'name_en': 'Chef’s vitamin C',
        'name_ar': 'فيتامين',
      },
    ],
  };

  test('pharmacy/water details map onto the ticket model', () {
    final d = ticketDataFromVerticalDetail(pharmacy);
    expect(d.orderCode, 'PH-000077');
    expect(d.userName, 'Fatimetou');
    expect(d.paymentType, '1');
    expect(d.subtotal, '120');
    expect(d.deliveryFee, '30');
    expect(d.total, '150.00');
    expect(d.customerNote, 'Ring twice');
    expect(d.placedAt, DateTime(2026, 10, 31, 10, 30));
    expect(d.orderItems, hasLength(2));
    expect(d.orderItems![0].orderItem?.nameEn, 'Paracetamol 500mg (20 tabs)');
    expect(d.orderItems![0].quantity, 2);
    expect(d.orderItems![0].price, '90.00');
    // No total_price: unit price × quantity.
    expect(d.orderItems![1].price, '30.00');
  });

  test('water detail with a customer block and missing fields', () {
    final d = ticketDataFromVerticalDetail({
      'order': {
        'id': 5,
        'order_code': 'W-5',
        'created_at': '2026-10-31 09:00:00',
        'total': 60,
      },
      'customer': {'name': 'Sidi'},
      'items': [
        {
          'quantity': 3,
          'unit_price': '20.00',
          'total_price': '60.00',
          'name_en': '19L bottle',
        },
      ],
    });
    expect(d.userName, 'Sidi');
    expect(d.placedAt, DateTime(2026, 10, 31, 9));
    expect(d.subtotal, isNull);
    expect(d.orderItems!.single.orderItem?.nameEn, '19L bottle');
  });

  test('a ticket with a curly quote and Arabic text still builds', () async {
    // The logo asset is optional for this check.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (_) async => null);
    final result = await EscPosReceiptBuilder().buildReceipt(
      ticketDataFromVerticalDetail(pharmacy),
      vendorName: 'صيدلية النور',
    );
    expect(result.bytes80mm, isNotEmpty);
    expect(result.bytes58mm, isNotEmpty);
    // The bytes sent to the printer carry the Latin-1 version.
    expect(
      String.fromCharCodes(result.bytes80mm),
      contains("Chef's vitamin C"),
    );
  });

  test('latin1Safe keeps Latin-1, maps punctuation, replaces the rest', () {
    expect(latin1Safe('Chef’s “special” – crème'), 'Chef\'s "special" - crème');
    expect(latin1Safe('زيت'), '???');
  });

  test('test page is plain ESC/POS with a cut at the end', () {
    final bytes = BluetoothEscPosPrinter.buildTestPageBytes(
      title: 'Printer test',
      printerLabel: 'Imprimante – cuisine',
    );
    expect(bytes.take(2), [0x1B, 0x40]);
    expect(bytes.skip(bytes.length - 4), [0x1D, 0x56, 0x42, 0x00]);
    expect(bytes.every((b) => b < 128), isTrue);
  });
}
