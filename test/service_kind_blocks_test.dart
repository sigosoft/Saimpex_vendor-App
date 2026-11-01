import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';
import 'package:saimpex_vendor/home_cleaning/model/service_kind.dart';
import 'package:saimpex_vendor/home_cleaning/view/service_kind_blocks.dart';

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

CleaningBooking _laundry({double? actual, bool pending = false}) => CleaningBooking.fromJson({
      'order_id': 7,
      'status': 2,
      'requires_weight': true,
      'processing_label': 'Standard (24h)',
      'estimate_kg': 3,
      'rate_per_kg': 150,
      'actual_kg': actual,
      'pickup_slot': '25 Aug 2026, 2:00 PM – 4:00 PM',
      'pickup_address': 'Sahara View Home',
      'delivery_address': 'Sahara View Home',
      'additional_payment_pending': pending,
      'additional_payment': pending ? 90 : 0,
      'total_paid': 460,
    });

void main() {
  tearDown(() => ServiceKinds.current = ServiceKind.homeCleaning);

  test('laundry and car wash have six tabs with Ready (status 4)', () {
    ServiceKinds.current = ServiceKind.laundry;
    expect(CleaningBookingTab.values.map((t) => t.statuses).toList(), [
      [1], [2], [3], [4], [9], [10],
    ]);
    ServiceKinds.current = ServiceKind.homeCleaning;
    expect(CleaningBookingTab.values.length, 5);
    expect(ServiceKinds.fromVendorType('8'), ServiceKind.carWash);
  });

  testWidgets('laundry block: estimate, slot, addresses, balance due', (t) async {
    await t.pumpWidget(_app(LaundryBookingBlock(booking: _laundry(actual: 3.6, pending: true))));
    expect(find.text('Standard (24h)'), findsOneWidget);
    expect(find.text('Customer estimate (3 kg)'), findsOneWidget);
    expect(find.text('Actual weight (3.6 kg)'), findsOneWidget);
    expect(find.text('540 MRU'), findsWidgets);
    expect(find.text('25 Aug 2026, 2:00 PM – 4:00 PM'), findsOneWidget);
    expect(find.text('Balance due'), findsOneWidget);
    expect(find.text('90 MRU'), findsOneWidget);
  });

  testWidgets('car wash block: vehicles with add-ons', (t) async {
    await t.pumpWidget(_app(CarWashBookingBlock(
      booking: CleaningBooking.fromJson({
        'order_id': 8,
        'status': 2,
        'place': 'At Wash Station',
        'vehicles': [
          {'plate': '1234 AB 01', 'type': 'Sedan', 'service': 'Exterior Wash', 'price': 550, 'addons': [
            {'name': 'Engine Wash', 'price': 50},
          ]},
        ],
      }),
    )));
    expect(find.text('1234 AB 01'), findsOneWidget);
    expect(find.text('550 MRU'), findsOneWidget);
    expect(find.text('• Engine Wash'), findsOneWidget);
    expect(find.text('+50 MRU'), findsOneWidget);
    expect(find.text('At Wash Station'), findsOneWidget);
  });

  Future<VerifyWeightResult?> weigh(WidgetTester t, CleaningBooking b, String kg, String button) async {
    VerifyWeightResult? result;
    await t.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await showVerifyWeightSheet(context, b),
        child: const Text('open'),
      ),
    )));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), kg);
    await t.pump();
    await t.tap(find.text(button));
    await t.pumpAndSettle();
    return result;
  }

  testWidgets('heavier than estimated: send a payment request', (t) async {
    final r = await weigh(t, _laundry(), '3.6', 'Send Payment Request');
    expect(r?.kg, 3.6);
    expect(r?.paymentRequest, isTrue);
  });

  testWidgets('not heavier, or already requested: confirm pickup', (t) async {
    final r = await weigh(t, _laundry(), '3', 'Confirm Pickup');
    expect(r?.paymentRequest, isFalse);
    final again = await weigh(t, _laundry(actual: 3.6, pending: true), '3.6', 'Confirm Pickup');
    expect(again?.paymentRequest, isFalse);
  });
}
