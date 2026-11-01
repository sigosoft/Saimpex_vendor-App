import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/water/view/subscription_calendar/subscription_calendar_view.dart';

String _ymd(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() {
  setUpAll(() => initializeDateFormatting());

  testWidgets('calendar: totals, day counts and deliveries by slot', (t) async {
    t.view.physicalSize = const Size(1200, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final today = DateTime.now();
    final queries = <Map<String, dynamic>>[];
    await t.pumpWidget(MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: SubscriptionCalendarView(loader: (q) async {
        queries.add(q);
        return {
          'calendar': [
            {'date': _ymd(today), 'count': 18},
          ],
          'stats': {'total': 18, 'morning': 10, 'afternoon': 6, 'evening': 2, 'paused': 2},
          'slots': [
            {
              'slot': 'morning',
              'period': '8:00 – 10:00 AM',
              'deliveries': [
                {'customer_name': 'Ahmed Mohamed', 'customer_id': 5, 'subscription_id': 9, 'order_code': 'SUB0007',
                 'product_name': 'Drinking Water 19L', 'bottles': 2, 'frequency_days': 7, 'status': 'active', 'delivery': 'delivery'},
              ],
            },
          ],
        };
      }),
    ));
    await t.pumpAndSettle();
    expect(queries.first['date'], _ymd(today));
    expect(find.text('18'), findsWidgets); // total card + today's count
    expect(find.text('8:00 – 10:00 AM'), findsOneWidget);
    expect(find.text('Ahmed Mohamed'), findsOneWidget);
    expect(find.text('Drinking Water 19L × 2'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Chat With Customer'), findsOneWidget);

    await t.tap(find.text('Paused').last);
    await t.pumpAndSettle();
    expect(queries.last['status'], 'paused');
  });
}
