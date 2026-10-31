import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/cleaning_api.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';

/// Locale-aware formatting shared by the home list and the details screen.
class CleaningBookingFormat {
  const CleaningBookingFormat._();

  static String _locale() => CleaningApi.languageCode;

  static DateFormat _fmt(String pattern) {
    try {
      return DateFormat(pattern, _locale());
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

  /// "15 Aug 2026, 2:00 PM - 4:00 PM" from scheduled_for / slot_end.
  static String? slot(CleaningBooking b) {
    final start = b.scheduledFor;
    if (start == null) return b.slotWindow;
    final day = _fmt('d MMM yyyy, h:mm a').format(start);
    final end = b.slotEnd;
    if (end == null) return day;
    final sameDay =
        end.year == start.year && end.month == start.month && end.day == start.day;
    final endText = sameDay
        ? _fmt('h:mm a').format(end)
        : _fmt('d MMM yyyy, h:mm a').format(end);
    return '$day - $endText';
  }

  static String dateTime(DateTime value) => _fmt('d MMM yyyy, h:mm a').format(value);

  static String time(DateTime value) => _fmt('h:mm a').format(value);

  static String timeAgo(BuildContext context, DateTime? created) {
    if (created == null) return '';
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 1) return S.of(context).cleaningJustNow;
    if (diff.inHours < 1) {
      return S.of(context).cleaningBookingMinutesAgo(diff.inMinutes.toString());
    }
    if (diff.inDays < 1) {
      return S.of(context).cleaningBookingHoursAgo(diff.inHours.toString());
    }
    return S.of(context).cleaningBookingDaysAgo(diff.inDays.toString());
  }

  /// Chip label: "Bedroom × 4" for priced lines, plain name otherwise.
  static String chip(CleaningBookingLine line) {
    if (line.isSpace || line.isAddon || line.quantity > 1) {
      return '${line.name} × ${line.quantity}';
    }
    return line.name;
  }

  static String? paymentType(BuildContext context, String? type) {
    return switch (type) {
      '1' => S.of(context).cash,
      '2' => S.of(context).onlinePayment,
      _ => null,
    };
  }
}
