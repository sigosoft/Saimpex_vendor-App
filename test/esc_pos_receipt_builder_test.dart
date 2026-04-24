import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/model/OrderDetailsModel.dart';
import 'package:saimpex_vendor/utils/printing/esc_pos_receipt_builder.dart';

void main() {
  group('EscPosReceiptBuilder', () {
    test('appends feed and cut commands for 80mm receipt', () {
      final builder = EscPosReceiptBuilder();
      final data = Data(
        id: 101,
        orderCode: 'ORD-000101',
        placedAt: DateTime(2026, 3, 17, 10, 30),
        userName: 'Test Customer',
        countryCode: '+222',
        userMobile: '12345678',
        paymentType: 'Cash',
        subtotal: '12.00',
        tax: '1.00',
        deliveryFee: '0.50',
        total: '13.50',
        orderItems: [
          OrderItem(
            orderItem: OrderItemClass(nameEn: 'Chicken Burger'),
            quantity: 2,
            unitPrice: '4.00',
            price: '8.00',
          ),
        ],
      );

      final result = builder.build80mmReceipt(data);
      final bytes = result.bytes;

      final feedIndex = bytes.lastIndexOf(0x1B);
      expect(feedIndex, greaterThan(0));
      expect(bytes[feedIndex + 1], equals(0x64)); // ESC d n

      final cutStart = bytes.length - 3;
      expect(bytes.sublist(cutStart), equals([0x1D, 0x56, 0x00]));
    });

    test('renders order item and total in preview', () {
      final builder = EscPosReceiptBuilder();
      final data = Data(
        orderCode: 'ORD-77',
        subtotal: '15.00',
        tax: '0.00',
        deliveryFee: '0.00',
        total: '15.00',
        orderItems: [
          OrderItem(
            orderItem: OrderItemClass(nameEn: 'Fish Sandwich'),
            quantity: 1,
            unitPrice: '15.00',
            price: '15.00',
          ),
        ],
      );

      final result = builder.build80mmReceipt(data);
      expect(result.preview.contains('Fish Sandwich'), isTrue);
      expect(result.preview.contains('TOTAL'), isTrue);
      expect(result.preview.contains('15.00 MRU'), isTrue);
    });

    test('supports basket orders in receipt rows', () {
      final builder = EscPosReceiptBuilder();
      final data = Data(
        orderCode: 'BASK-1',
        subtotal: '25.00',
        tax: '0.00',
        deliveryFee: '0.00',
        total: '25.00',
        basketOrders: [
          BasketOrder(
            basket: BasketDetail(
              basketNameEn: 'Family Basket',
              quantity: 1,
              price: '25.00',
            ),
          ),
        ],
      );

      final result = builder.build80mmReceipt(data);
      expect(result.preview.contains('Family Basket'), isTrue);
      expect(result.preview.contains('25.00'), isTrue);
    });
  });
}

