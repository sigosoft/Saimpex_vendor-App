import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/view/home/substitution/order_substitutions.dart';

class _FakeApi extends SubstitutionApi {
  _FakeApi(this.rows);

  List<Map<String, dynamic>> rows;
  final calls = <Map<String, dynamic>>[];

  @override
  Future<({List<Substitution> items, int timeoutMinutes})> list(String orderId) async =>
      (items: rows.map(Substitution.new).toList(), timeoutMinutes: 10);

  @override
  Future<String?> propose(String orderId, int orderItemId, {int? substituteProductId, int? quantity, String? note}) async {
    calls.add({'order_item_id': orderItemId, 'substitute_product_id': substituteProductId, 'quantity': quantity, 'note': note});
    return 'ok';
  }

  @override
  Future<List<StoreProduct>> products(String keyword, {int? categoryId}) async => [
        StoreProduct({'menu_item_id': 11, 'name_en': 'Coca-Cola 1L', 'price': '50', 'status': 1, 'available_status': 1}),
        StoreProduct({'menu_item_id': 22, 'name_en': 'Pepsi 1L', 'price': '45', 'status': 1, 'available_status': 1, 'stock': 12}),
        StoreProduct({'menu_item_id': 33, 'name_en': 'Fanta 1L', 'price': '45', 'status': 1, 'available_status': 2}),
      ];
}

const _lines = [
  SubstitutionLine(orderItemId: 1, productId: 11, name: 'Coca-Cola 1L', image: '', unitPrice: 50, quantity: 1),
  SubstitutionLine(orderItemId: 2, productId: 44, name: 'Banana 1Kg', image: '', unitPrice: 50, quantity: 3),
];

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: child,
    );

void main() {
  test('kind, latest per line, products', () {
    final a = Substitution({'id': 1, 'order_item_id': 5, 'status': 'rejected', 'substitute': null});
    final b = Substitution({'id': 2, 'order_item_id': 5, 'status': 'pending', 'kind': 'quantity', 'seconds_left': 90});
    expect(a.kind, 'unavailable');
    expect(b.kind, 'quantity');
    expect(latestByLine([b, a])[5]!.id, 2);
    final p = StoreProduct({'menu_item_id': 9, 'name_en': 'Milk', 'attribute_value': '1', 'variant_name_en': 'L', 'stock': 0});
    expect(p.id, 9);
    expect(p.name, 'Milk 1 L');
    expect(p.isAvailable, isFalse);
  });

  test('picker price is what the customer pays (discount price when set)', () {
    expect(StoreProduct({'price': '70', 'discount_price': '60'}).price, 60);
    expect(StoreProduct({'price': '70', 'selling_price': '60'}).price, 60);
    expect(StoreProduct({'price': '70', 'discount_price': '0'}).price, 70);
    expect(StoreProduct({'price': '70'}).price, 70);
    expect(StoreProduct({'price': '70', 'discount_price': '80'}).price, 70);
  });

  testWidgets('pending line shows its status; other lines offer the three actions', (t) async {
    final api = _FakeApi([
      {
        'id': 7,
        'order_item_id': 1,
        'status': 'pending',
        'kind': 'substitute',
        'seconds_left': 300,
        'original': {'quantity': 1, 'unit_price': 50},
        'substitute': {'name_en': 'Pepsi 1L', 'quantity': 1, 'unit_price': 45},
      },
    ]);
    await t.pumpWidget(_app(EditItemsView(orderId: '9', lines: _lines, api: api)));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Substitute Suggested'), findsOneWidget);
    expect(find.text('Waiting for customer · 05:00'), findsOneWidget);
    expect(find.text('Pepsi 1L'), findsOneWidget);
    // Only the banana line has buttons.
    expect(find.text('Remove Item'), findsOneWidget);
    expect(find.text('Change Qty'), findsOneWidget);

    await t.tap(find.text('Remove Item'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(TextButton, 'Remove Item'));
    await t.pumpAndSettle();
    expect(api.calls.single, {'order_item_id': 2, 'substitute_product_id': null, 'quantity': null, 'note': null});
  });

  test('removed lines, same category first, unit words', () {
    expect(Substitution({'status': 'accepted', 'substitute': null}).removesLine, isTrue);
    expect(Substitution({'status': 'auto_accepted', 'kind': 'unavailable'}).removesLine, isTrue);
    expect(Substitution({'status': 'rejected', 'kind': 'substitute', 'substitute': {}}).removesLine, isTrue);
    expect(Substitution({'status': 'accepted', 'kind': 'substitute', 'substitute': {}}).removesLine, isFalse);
    expect(Substitution({'status': 'pending', 'substitute': null}).removesLine, isFalse);

    final milk = StoreProduct({'menu_item_id': 1, 'category_name_en': 'Dairy'});
    final soap = StoreProduct({'menu_item_id': 2, 'category_name_en': 'Home'});
    final yogurt = StoreProduct({'menu_item_id': 3, 'category_name_en': 'dairy'});
    expect(sameCategoryFirst([soap, yogurt], milk).map((p) => p.id), [3, 2]);
    expect(sameCategoryFirst([soap, yogurt], null).map((p) => p.id), [2, 3]);
  });

  test('unit inside the variant value is translated, other words kept', () async {
    final s = await S.load(const Locale('ar'));
    expect(groceryUnitsInText(s, '30 pcs'), '30 ${s.unitPiece}');
    expect(groceryUnitsInText(s, '1 set'), '1 ${s.unitSet}');
    expect(groceryUnitsInText(s, '1L'), '1 ${s.unitLitre}');
    expect(groceryUnitsInText(s, '2 Family'), '2 Family');
    expect(groceryUnitsInText(s, 'Large'), 'Large');
  });

  testWidgets('a removed line shows no actions', (t) async {
    final api = _FakeApi([
      {'id': 8, 'order_item_id': 1, 'status': 'accepted', 'kind': 'unavailable', 'original': {'quantity': 1, 'unit_price': 50}},
    ]);
    await t.pumpWidget(_app(EditItemsView(orderId: '9', lines: _lines, api: api)));
    await t.pumpAndSettle();
    expect(find.text('Item Removed'), findsOneWidget);
    // Only the banana line keeps its buttons.
    expect(find.text('Remove Item'), findsOneWidget);
  });

  testWidgets('change quantity sends the same product with fewer units', (t) async {
    final api = _FakeApi([]);
    await t.pumpWidget(_app(EditItemsView(orderId: '9', lines: _lines, api: api)));
    await t.pumpAndSettle();
    await t.tap(find.text('Change Qty').last);
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('subQty')), '3');
    await t.pump();
    expect(find.text('Enter a quantity from 1 to 2.'), findsOneWidget);
    await t.enterText(find.byKey(const Key('subQty')), '2');
    await t.pump();
    await t.tap(find.text('Update Quantity'));
    await t.pumpAndSettle();
    expect(api.calls.single['substitute_product_id'], 44);
    expect(api.calls.single['quantity'], 2);
  });

  testWidgets('suggest substitute lists other available products and sends the pick', (t) async {
    t.view.physicalSize = const Size(1200, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final api = _FakeApi([]);
    await t.pumpWidget(_app(EditItemsView(orderId: '9', lines: _lines, api: api)));
    await t.pumpAndSettle();
    await t.tap(find.text('Suggest Substitute').first);
    await t.pumpAndSettle();
    // The ordered product and the unavailable one are left out.
    expect(find.text('Pepsi 1L'), findsOneWidget);
    expect(find.text('Fanta 1L'), findsNothing);
    expect(find.text('12 in stock'), findsOneWidget);
    await t.tap(find.byKey(const Key('plus-22')));
    await t.pump();
    await t.tap(find.text('Confirm Selection'));
    await t.pumpAndSettle();
    expect(api.calls.single['substitute_product_id'], 22);
    expect(api.calls.single['quantity'], 1);
  });
}
