import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/model/conversations_model.dart';
import 'package:saimpex_vendor/utils/widgets/deletable_conversation.dart';

void main() {
  testWidgets('booking preview and online flag from the API', (t) async {
    late BuildContext ctx;
    await t.pumpWidget(MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    final withBooking = Conversation.fromJson({'id': 1, 'order_code': '22789002', 'customer_is_online': true});
    final plain = Conversation.fromJson({'id': 2});
    expect(withBooking.customerIsOnline, isTrue);
    expect(plain.customerIsOnline, isFalse);
    expect(conversationPreview(ctx, withBooking, 'Hello'), 'Booking #22789002 · Hello');
    expect(conversationPreview(ctx, plain, 'Hello'), 'Hello');
  });

  testWidgets('swipe asks before deleting; cancel keeps the row', (t) async {
    await t.pumpWidget(MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: DeletableConversation(conversationId: 5, onDeleted: () {}, child: const ListTile(title: Text('Ahmed'))),
      ),
    ));
    await t.drag(find.text('Ahmed'), const Offset(-500, 0));
    await t.pumpAndSettle();
    expect(find.text('Delete this chat?'), findsOneWidget);
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(find.text('Ahmed'), findsOneWidget);
  });
}
