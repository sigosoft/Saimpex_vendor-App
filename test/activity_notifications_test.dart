import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/widgets/activity_notifications_section.dart';

void main() {
  testWidgets('shows the activity rows and opens them', (t) async {
    Map<String, dynamic>? opened;
    await t.pumpWidget(MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: ActivityNotificationsSection(
          onTap: (r) => opened = r,
          loader: () async => [
            {'kind': 'new_order', 'title_en': 'New order #1001', 'action_en': 'View Order', 'content': '2 items', 'order_id': 12, 'read': false},
            {'kind': 'low_stock', 'title_en': 'Low stock', 'action_en': 'Update Stock', 'read': true},
          ],
        ),
      ),
    ));
    await t.pumpAndSettle();
    expect(find.text('NEEDS YOUR ATTENTION'), findsOneWidget);
    expect(find.text('New order #1001'), findsOneWidget);
    expect(find.text('Update Stock'), findsOneWidget);
    await t.tap(find.text('New order #1001'));
    expect(opened?['order_id'], 12);
  });

  testWidgets('nothing to do: the section is hidden', (t) async {
    await t.pumpWidget(MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: ActivityNotificationsSection(loader: () async => [])),
    ));
    await t.pumpAndSettle();
    expect(find.text('NEEDS YOUR ATTENTION'), findsNothing);
  });
}
