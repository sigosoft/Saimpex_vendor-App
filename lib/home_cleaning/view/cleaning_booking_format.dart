import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/utils/utils.dart' show localizeDatePattern;
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/cleaning_api.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';
import 'package:saimpex_vendor/home_cleaning/view/add_service_view.dart' show cleaningIssueLabel, cleaningPropertyLabel;
import 'package:saimpex_vendor/utils/bidi_text.dart';

/// Locale-aware formatting shared by the home list and the details screen.
class CleaningBookingFormat {
  const CleaningBookingFormat._();

  static String _locale() => CleaningApi.languageCode;

  static DateFormat _fmt(String pattern) {
    try {
      final lang = _locale();
      return DateFormat(localizeDatePattern(pattern, lang), lang);
    } catch (_) {
      return DateFormat(pattern, 'en');
    }
  }

  static String money(double? value) {
    final v = value ?? 0;
    final text = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return '$text MRU';
  }

  static String number(double? value) {
    final v = value ?? 0;
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  }

  /// "15 Aug 2026, 2:00 PM - 4:00 PM" from scheduled_for / slot_end; the
  /// date alone when the booking has no time (VA-29). Each date / time is
  /// isolated so its parts keep their order inside Arabic text.
  static String? slot(CleaningBooking b) {
    final start = b.scheduledFor;
    if (start == null) {
      final window = b.slotWindow;
      return window == null ? null : isolated(window);
    }
    if (b.scheduledDateOnly) return isolated(_fmt('d MMM yyyy').format(start));
    final day = isolated(_fmt('d MMM yyyy, h:mm a').format(start));
    final end = b.slotEnd;
    if (end == null) return day;
    final sameDay =
        end.year == start.year && end.month == start.month && end.day == start.day;
    final endText = sameDay
        ? _fmt('h:mm a').format(end)
        : _fmt('d MMM yyyy, h:mm a').format(end);
    return '$day - ${isolated(endText)}';
  }

  /// "2:00 PM - 4:00 PM" (or one time) as one isolated run; null when the
  /// booking has a day but no time.
  static String? timeRange(CleaningBooking b) {
    final start = b.scheduledFor;
    if (start == null || b.scheduledDateOnly) return null;
    final end = b.slotEnd;
    return isolated(end == null ? time(start) : '${time(start)} - ${time(end)}');
  }

  static String dateTime(DateTime value) => _fmt('d MMM yyyy, h:mm a').format(value);

  static String time(DateTime value) => _fmt('h:mm a').format(value);

  /// "Aug 25, 2026" (car wash BOOKING SLOT date chip).
  static String date(DateTime value) => _fmt('MMM d, yyyy').format(value);

  static String timeAgo(BuildContext context, DateTime? created) {
    if (created == null) return '';
    // created is already in phone time (CleaningBooking reads server UTC).
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 1) return S.of(context).cleaningJustNow;
    // Plural forms: Arabic needs 1 / 2 / 3-10 / 11+ ("منذ 5 ساعات", V18).
    if (diff.inHours < 1) {
      return S.of(context).cleaningMinutesAgoCount(diff.inMinutes);
    }
    if (diff.inDays < 1) {
      return S.of(context).cleaningHoursAgoCount(diff.inHours);
    }
    return S.of(context).cleaningDaysAgoCount(diff.inDays);
  }

  /// Chip label: "Bedroom × 4" for priced lines, plain name otherwise.
  /// Property types arrive as their English value ("Apartment", V17).
  static String chip(BuildContext context, CleaningBookingLine line) {
    final name = switch (line.kind) {
      'property' => cleaningPropertyLabel(context, line.name),
      // Pest issues arrive as their English value ("Cockroaches").
      'issue' => cleaningIssueLabel(context, line.name),
      _ => line.name,
    };
    if (line.isSpace || line.isAddon || line.quantity > 1) {
      return '$name × ${line.quantity}';
    }
    return name;
  }

  static String? paymentType(BuildContext context, String? type) {
    return switch (type) {
      '1' => S.of(context).cash,
      '2' => S.of(context).onlinePayment,
      _ => null,
    };
  }
}
