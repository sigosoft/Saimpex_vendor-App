import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  tearDown(() => LocalizationService.currentLanguageCode = 'en');

  test('offset-less server times are read as UTC, offsets are kept', () {
    final expected = DateTime.utc(2026, 11, 3, 12, 44).toLocal();
    expect(parseServerTime('2026-11-03 12:44:00'), expected);
    expect(parseServerTime('2026-11-03T12:44:00'), expected);
    expect(parseServerTime('2026-11-03T12:44:00Z'), expected);
    expect(parseServerTime('2026-11-03T13:44:00+01:00'), expected);
    expect(parseServerTime('2026-11-03 12:44:00')!.isUtc, isFalse);
  });

  test('date-only, empty and non-date values', () {
    expect(parseServerTime('2026-11-30'), DateTime(2026, 11, 30));
    expect(parseServerTime(null), isNull);
    expect(parseServerTime(''), isNull);
    expect(parseServerTime('null'), isNull);
    expect(parseServerTime('Nov 03, 2026 12:44 PM'), isNull);
  });

  test('formatServerDateTime uses the app language and keeps server text', () {
    // Mid-month, so the month is the same in every phone time zone.
    const raw = '2026-11-15 12:00:00';
    expect(formatServerDateTime(raw, pattern: 'MMMM'), 'November');
    LocalizationService.currentLanguageCode = 'fr';
    expect(formatServerDateTime(raw, pattern: 'MMMM'), 'novembre');
    LocalizationService.currentLanguageCode = 'ar';
    expect(formatServerDateTime(raw, pattern: 'MMMM'), 'نوفمبر');
    expect(formatServerDateTime('Today, 10:45 AM'), 'Today, 10:45 AM');
    expect(formatServerDateTime(null), '');
  });

  test('formatServerTimeAgo in the app language', () async {
    await S.load(const Locale('fr'));
    final placed = DateTime.utc(2026, 11, 3, 12, 0);
    const raw = '2026-11-03 12:00:00';
    DateTime after(Duration d) => placed.add(d).toLocal();
    expect(formatServerTimeAgo(raw, now: after(const Duration(seconds: 20))), S.current.cleaningJustNow);
    expect(formatServerTimeAgo(raw, now: after(const Duration(minutes: 5))), 'il y a 5 min');
    expect(formatServerTimeAgo(raw, now: after(const Duration(hours: 3))), 'il y a 3 h');
    expect(formatServerTimeAgo('not a date'), 'not a date');
    await S.load(const Locale('en'));
  });

  test('server-formatted English UTC times are read as UTC (status logs)', () {
    final expected = DateTime.utc(2026, 11, 7, 7, 39).toLocal();
    expect(parseServerTime('07 Nov 2026 07:39 AM'), expected);
    expect(parseServerTime('07 Nov 2026, 07:39 AM'), expected);
    // Mid-month so the month is the same in every phone time zone.
    LocalizationService.currentLanguageCode = 'fr';
    expect(formatServerDateTime('15 Nov 2026 12:00 PM', pattern: 'MMMM'), 'novembre');
    LocalizationService.currentLanguageCode = 'en';
    expect(parseServerTime('Today, 10:45 AM'), isNull);
  });
}
