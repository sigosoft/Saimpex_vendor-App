import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/view/support/support_messages.dart';

// The screen showed a grey error page because its controller was looked up
// before it was registered (retest 3 Nov).
void main() {
  testWidgets('Support messages opens without an error', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: const SupportMessages(),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
