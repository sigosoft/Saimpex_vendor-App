import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/model/service_item_model.dart';
import 'package:saimpex_vendor/home_cleaning/model/service_kind.dart';
import 'package:saimpex_vendor/home_cleaning/view/service_form_view.dart';

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: child,
    );

Future<List<CleaningServiceType>> _types() async => const [CleaningServiceType(id: 3, nameEn: 'Exterior Wash')];

void main() {
  tearDown(() => ServiceKinds.current = ServiceKind.homeCleaning);

  // The form is a lazy list; a tall screen builds every section.
  void tall(WidgetTester t) {
    t.view.physicalSize = const Size(1200, 4000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }

  testWidgets('laundry: per kg shows the price, per item shows item pricing', (t) async {
    tall(t);
    ServiceKinds.current = ServiceKind.laundry;
    await t.pumpWidget(_app(ServiceFormView(loadTypes: _types)));
    await t.pumpAndSettle();
    expect(find.text('Processing time'), findsOneWidget);
    expect(find.text('MRU / kg'), findsOneWidget);
    expect(find.text('ITEM PRICING'), findsNothing);

    await t.tap(find.text('Per kg'));
    await t.pumpAndSettle();
    await t.tap(find.text('Per item').last);
    await t.pumpAndSettle();
    expect(find.text('ITEM PRICING'), findsOneWidget);
    expect(find.text('MRU / kg'), findsNothing);
  });

  testWidgets('car wash: add a vehicle type through the sheet', (t) async {
    tall(t);
    ServiceKinds.current = ServiceKind.carWash;
    await t.pumpWidget(_app(ServiceFormView(loadTypes: _types)));
    await t.pumpAndSettle();
    expect(find.text('HOME / WORKPLACE PRICING'), findsOneWidget);

    await t.tap(find.widgetWithText(OutlinedButton, 'Add vehicle type'));
    await t.pumpAndSettle();
    await t.enterText(find.widgetWithText(TextField, 'Vehicle type, e.g. Sedan'), 'Sedan');
    await t.enterText(find.widgetWithText(TextField, 'Price'), '550');
    await t.pump();
    await t.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await t.pumpAndSettle();
    expect(find.text('Sedan'), findsOneWidget);
    expect(find.text('550 MRU'), findsOneWidget);
  });

  testWidgets('edit: fills the form from the saved service', (t) async {
    tall(t);
    ServiceKinds.current = ServiceKind.carWash;
    final item = CleaningServiceItem.fromJson({
      'id': 9,
      'service_type_id': 3,
      'name_en': 'Exterior Wash',
      'description_en': 'Foam and rinse',
      'price': 550,
      'spaces': [
        {'name': 'SUV', 'price': 650},
      ],
      'distances': [
        {'min_km': 0, 'max_km': 5, 'price': 100},
      ],
    });
    await t.pumpWidget(_app(ServiceFormView(initial: item, loadTypes: _types)));
    await t.pumpAndSettle();
    expect(find.text('Edit Service'), findsOneWidget);
    expect(find.text('Exterior Wash'), findsOneWidget);
    expect(find.text('SUV'), findsOneWidget);
    expect(find.text('0 – 5 km'), findsOneWidget);
  });
}
