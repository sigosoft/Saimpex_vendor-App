import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaner.dart';
import 'package:saimpex_vendor/home_cleaning/model/service_kind.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaners/my_cleaners_view.dart';

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: child,
    );

Future<CleanersPage> _page() async => CleanersPage([
      Cleaner.fromJson({'id': 1, 'name': 'Fatou Ba', 'phone': '+22222111111', 'rating': 4.8, 'reviews_count': 126, 'availability': 'available', 'status': 1})!,
      Cleaner.fromJson({
        'id': 2, 'name': 'Aminata Sy', 'rating': 4.6, 'reviews_count': 88, 'availability': 'busy', 'status': 1,
        'busy_with': {'scheduled_for': DateTime(2026, 11, 2, 10).toIso8601String(), 'order_code': '22789002'},
      })!,
      Cleaner.fromJson({'id': 3, 'name': 'Khadija Diallo', 'availability': 'inactive', 'status': 2})!,
    ], const {'total': 3, 'available': 1, 'busy': 1, 'inactive': 1});

void main() {
  testWidgets('My Cleaners: counts, pills and filters', (t) async {
    await t.pumpWidget(_app(MyCleanersView(loader: _page)));
    await t.pumpAndSettle();
    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Busy 1'), findsOneWidget);
    expect(find.text('4.8 ★ · 126 reviews'), findsOneWidget);
    expect(find.text('Busy · 10:00'), findsOneWidget);
    expect(find.text('Deactivated'), findsOneWidget);
    expect(find.text('Activate'), findsOneWidget); // only the inactive one
    expect(find.text('Deactivate'), findsNWidgets(2));

    await t.tap(find.text('Inactive 1'));
    await t.pumpAndSettle();
    expect(find.text('Khadija Diallo'), findsOneWidget);
    expect(find.text('Fatou Ba'), findsNothing);
  });

  testWidgets('cleaning action labels follow the backend flow', (t) async {
    ServiceKinds.current = ServiceKind.homeCleaning;
    late BuildContext ctx;
    await t.pumpWidget(_app(Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })));
    expect(ServiceKinds.actionLabel(ctx, 2, needsCleaner: true), 'Assign Cleaner');
    expect(ServiceKinds.actionLabel(ctx, 2), 'Mark On the Way');
    expect(ServiceKinds.actionLabel(ctx, 8), 'Start Cleaning');
    expect(ServiceKinds.actionLabel(ctx, 3), 'Mark as Completed');
  });
}
