import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_prescription_detail_model.dart';
import 'package:saimpex_vendor/pharmacy/view/order_details_screen.dart';

Map<String, dynamic> _row(int id, String name, num price, int stock) => {
      'id': id,
      'menu_name_en': name,
      'menu_name_fr': name,
      'menu_name_ar': name,
      'selling_price': price,
      'offer_price': null,
      'stock': stock,
    };

final _inventory = [
  _row(1, 'Paracetamol 500 mg', 50, 40),
  _row(2, 'Ibuprofen 400 mg', 65, 6),
  _row(3, 'Ferrous Sulfate Syrup', 220, 0),
  _row(4, 'Iron Syrup', 180.5, 3),
];

CreateQuotationController _controller() => CreateQuotationController(
      search: (k) async => _inventory
          .where((r) => '${r['menu_name_en']}'.toLowerCase().contains(k.toLowerCase()))
          .toList(),
    );

/// Search, pick the first match, set the prescribed quantity, save.
Future<void> _add(WidgetTester t, CreateQuotationController c, String query, int qty, {String? alternative}) async {
  c.onMedicineQueryChanged(query);
  await t.pump(const Duration(milliseconds: 400));
  c.beginDraft(c.filter(query).first);
  c.setPrescribed(qty);
  if (alternative != null) {
    c.onAltQueryChanged(alternative);
    await t.pump(const Duration(milliseconds: 400));
    c.addAlternative(c.filterAlternatives(alternative).first);
  }
  c.saveDraft();
}

void main() {
  testWidgets('availability follows stock and items carry the §6.15 fields', (t) async {
    {
      final c = _controller();
      await _add(t, c, 'Paracetamol', 10); // 40 in stock → available
      await _add(t, c, 'Ibuprofen', 10); // 6 in stock → partial 6 of 10
      await _add(t, c, 'Ferrous', 2, alternative: 'Iron'); // none → unavailable + alternative
      await _add(t, c, 'Amoxicillin', 1); // not carried → unavailable

      final items = c.buildItems();
      expect(items, hasLength(5));
      expect(items[0], containsPair('availability', 'available'));
      expect(items[0], containsPair('quantity', 10));
      expect(items[0], containsPair('product_id', 1));
      expect(items[1], containsPair('availability', 'partial'));
      expect(items[1], containsPair('quantity', 6));
      expect(items[1], containsPair('requested_quantity', 10));
      expect(items[2], containsPair('availability', 'unavailable'));
      expect(items[3], containsPair('alternative_for', 'Ferrous Sulfate Syrup'));
      expect(items[3], containsPair('product_id', 4));
      expect(items[3], containsPair('quantity', 2));
      expect(items[4], containsPair('availability', 'unavailable'));
      expect(items[4].containsKey('product_id'), isFalse);
      expect(items[4], containsPair('name_en', 'Amoxicillin'));

      // Charged now: 10 × 50 + 6 × 65; the alternative only if accepted.
      expect(c.subtotal, 890);
      expect(c.alternativesTotal, 361);
    }
  });

  testWidgets('alternatives exclude the medicine itself and out-of-stock items', (t) async {
    {
      final c = _controller();
      c.onMedicineQueryChanged('Ferrous');
      await t.pump(const Duration(milliseconds: 400));
      c.beginDraft(c.filter('Ferrous').first);
      c.setPrescribed(1);
      c.onAltQueryChanged('S');
      await t.pump(const Duration(milliseconds: 400));
      final names = c.filterAlternatives('S').map((m) => m.name).toList();
      expect(names, isNot(contains('Ferrous Sulfate Syrup')));
      expect(names, contains('Iron Syrup'));
    }
  });

  test('quote items: what the customer pays', () {
    PharmacyPrescriptionQuoteItem item(Map<String, dynamic> j) => PharmacyPrescriptionQuoteItem.fromJson(j);
    final available = item({'name_en': 'A', 'quantity': 2, 'unit_price': '50', 'total_price': '100.00'});
    final unavailable = item({'name_en': 'B', 'quantity': 1, 'unit_price': '20', 'total_price': '0', 'availability': 'unavailable'});
    final pendingAlt = item({'name_en': 'C', 'quantity': 1, 'unit_price': '30', 'total_price': '30', 'alternative_for': 'B'});
    final acceptedAlt = item({'name_en': 'C', 'quantity': 1, 'unit_price': '30', 'total_price': '30', 'alternative_for': 'B', 'customer_decision': 'accepted'});
    expect(available.name, 'A');
    expect(quoteLineCharged(available), 100);
    expect(quoteLineCharged(unavailable), 0);
    expect(quoteLineCharged(pendingAlt), 0);
    expect(quoteLineCharged(acceptedAlt), 30);
    expect(pendingAlt.isAlternative, isTrue);
  });
}
