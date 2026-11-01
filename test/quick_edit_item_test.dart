import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/view/restaurant/quick_edit_item_sheet.dart';

final _single = <String, dynamic>{
  'id': 42,
  'name_en': 'Chicken Burger',
  'name_fr': 'Burger au poulet',
  'name_ar': 'برغر دجاج',
  'description_en': 'Crispy',
  'category_ids': [7],
  'serial_no': 'B-1',
  'in_kg': false,
  'has_variants': false,
  'variant_group_name': null,
  'preparation_time': '00:15',
  'price': '120.00',
  'discount_price': null,
  'available_status': 2,
  'tags': [3, 5],
  'images': [
    {'id': 9, 'image_url': 'https://x/a.jpg'},
    {'id': 10, 'image_url': 'https://x/b.jpg'},
  ],
  'variants': [],
  'option_groups': [
    {
      'id': 1,
      'name': 'Sauce',
      'selection_requirement': 'required',
      'min_selections': 1,
      'max_selections': 2,
      'options': [
        {'id': 11, 'name': 'Mayo', 'additional_price': '0.00', 'available_status': 1, 'image_url': 'https://x/m.jpg'},
      ],
    },
  ],
  'extras': {'selection_requirement': 'optional', 'items': []},
};

final _variants = <String, dynamic>{
  ..._single,
  'has_variants': true,
  'variant_group_name': 'Size',
  'price': null,
  'variants': [
    {'id': 100, 'name': 'Small', 'price': '100.00', 'sku': null, 'selection_requirement': 'optional'},
    {'id': 101, 'name': 'Large', 'price': '150.00', 'sku': 'L', 'selection_requirement': 'optional'},
  ],
};

class _FakeApi extends QuickEditApi {
  _FakeApi(this.detail);
  final Map<String, dynamic> detail;
  Map<String, String>? saved;
  String? savedImage;

  @override
  Future<Map<String, dynamic>> load(String itemId) async => detail;

  @override
  Future<String?> save(Map<String, String> fields, {String? imagePath}) async {
    saved = fields;
    savedImage = imagePath;
    return 'Updated';
  }
}

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  test('everything not edited goes back unchanged; extras are left out', () {
    final body = buildQuickEditBody(_single, name: 'Chicken Burger XL', price: '130', discountPrice: '', available: true);
    expect(body['item_id'], '42');
    expect(body['name_en'], 'Chicken Burger XL');
    expect(body['name_fr'], 'Burger au poulet');
    expect(body['price'], '130');
    expect(body.containsKey('discount_price'), isFalse);
    expect(body['available_status'], '1');
    expect(body['preparation_time'], '00:15');
    expect(jsonDecode(body['category_ids']!), [7]);
    expect(jsonDecode(body['tags']!), [3, 5]);
    expect(jsonDecode(body['remove_image_ids']!), isEmpty);
    expect(body.containsKey('extras'), isFalse);
    final groups = jsonDecode(body['option_groups']!) as List;
    expect(groups.single['id'], 1);
    expect(groups.single['min_selections'], 1);
    expect(groups.single['options'].single['id'], 11);
  });

  test('variant prices are edited by id; a new photo replaces the first image', () {
    final body = buildQuickEditBody(_variants, name: 'Burger', variantPrices: {101: '160'}, available: false, replaceImage: true);
    expect(body.containsKey('price'), isFalse);
    expect(body['has_variants'], '1');
    expect(body['available_status'], '2');
    final variants = jsonDecode(body['variants']!) as List;
    expect(variants[0]['price'], '100.00');
    expect(variants[1]['price'], '160');
    expect(variants[1]['sku'], 'L');
    expect(jsonDecode(body['remove_image_ids']!), [9]);
  });

  testWidgets('sheet loads the item, validates and saves the edits', (t) async {
    t.view.physicalSize = const Size(1200, 2600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final api = _FakeApi(_single);
    var advanced = false;
    await t.pumpWidget(_app(QuickEditItemSheet(
      itemId: '42',
      api: api,
      onAdvanced: () => advanced = true,
      pickImage: () async => '/tmp/new.jpg',
    )));
    await t.pumpAndSettle();
    expect(find.text('Chicken Burger'), findsOneWidget);
    expect(find.text('Shown as out of stock'), findsOneWidget);

    await t.enterText(find.byKey(const Key('quickEditOffer')), '150');
    await t.tap(find.byKey(const Key('quickEditSave')));
    await t.pump();
    expect(find.text('The discount price must not be higher than the price.'), findsOneWidget);
    expect(api.saved, isNull);

    await t.enterText(find.byKey(const Key('quickEditOffer')), '99');
    await t.tap(find.byKey(const Key('quickEditAvailable')));
    await t.tap(find.byKey(const Key('quickEditPhoto')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('quickEditSave')));
    await t.pumpAndSettle();
    expect(api.saved!['discount_price'], '99');
    expect(api.saved!['available_status'], '1');
    expect(api.savedImage, '/tmp/new.jpg');
    expect(jsonDecode(api.saved!['remove_image_ids']!), [9]);
    expect(advanced, isFalse);
  });
}
