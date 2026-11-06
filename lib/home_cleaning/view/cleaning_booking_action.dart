import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/cleaning_api.dart';
import 'package:saimpex_vendor/home_cleaning/controller/home_cleaning_controller.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';
import 'package:saimpex_vendor/home_cleaning/view/reject_booking_sheet.dart';
import 'package:saimpex_vendor/home_cleaning/model/service_kind.dart';
import 'package:saimpex_vendor/home_cleaning/view/service_kind_blocks.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaners/assign_cleaner_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaning_booking_format.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/bidi_text.dart';

/// Runs the next step for [booking] (accept / start cleaning / mark completed,
/// using the server's `next_status`) or, with [reject], asks for a reason and
/// sends status 10. Shows the server message and returns the updated booking
/// from the response, or null when nothing changed.
Future<CleaningBooking?> runCleaningBookingAction(
  BuildContext context,
  CleaningBooking booking, {
  bool reject = false,
}) async {
  HapticFeedback.lightImpact();
  final messenger = ScaffoldMessenger.maybeOf(context);
  final fallbackError = S.of(context).cleaningBookingUpdateFailed;

  int? status;
  RejectBookingResult? rejection;
  Map<String, dynamic>? extra;
  // Home cleaning, accepted without a cleaner: the next step is Assign
  // Cleaner (V16; the server sends next_action_key assign_cleaner and no
  // next_status). Reloaded by the caller afterwards.
  if (!reject && ServiceKinds.isCleaning && booking.needsCleaner) {
    final assigned = await AssignCleanerView.open(context, booking);
    if (assigned == true && Get.isRegistered<HomeCleaningController>()) {
      Get.find<HomeCleaningController>().loadBookings();
    }
    return assigned == true ? booking : null;
  }
  // Laundry, Confirm Pickup on a per-kg service: weigh first (V14). The
  // sheet either asks the customer for the difference (payment request,
  // status stays) or confirms the pickup with the actual weight.
  if (!reject && ServiceKinds.isLaundry && booking.status == 2 && booking.raw['requires_weight'] == true) {
    // The sheet is its own confirmation; a pickup before the booked day is
    // warned about first (VA-30).
    if (_scheduledAfterToday(booking) &&
        !await _confirmStep(context, booking, ServiceKinds.actionLabel(context, booking.status))) {
      return null;
    }
    if (!context.mounted) return null;
    final weighed = await showVerifyWeightSheet(context, booking);
    if (weighed == null) return null;
    extra = {'actual_weight': weighed.kg};
    if (weighed.paymentRequest) {
      extra['payment_request'] = 1;
    } else {
      status = 3;
    }
  } else if (reject) {
    rejection = await showRejectBookingSheet(context);
    if (rejection == null) return null;
    status = CleaningStatus.cancelled;
  } else {
    status = booking.resolvedNextStatus;
    // Every step (Accept, Confirm Pickup, Ready, Delivered…) ran on one tap
    // with no way back (VA-30): ask first.
    if (status != null) {
      final label = booking.isNew
          ? S.of(context).cleaningAcceptBooking
          : ServiceKinds.actionLabel(context, booking.status, needsCleaner: booking.needsCleaner);
      if (!await _confirmStep(context, booking, label)) return null;
    }
  }
  if (status == null && extra == null) return null;

  final CleaningApiResult res;
  if (Get.isRegistered<HomeCleaningController>()) {
    res = await Get.find<HomeCleaningController>().updateBookingStatus(
      booking,
      status,
      reason: rejection?.reason,
      note: rejection?.note,
      extra: extra,
    );
  } else {
    res = await CleaningBookingActions.updateStatus(
      booking.id,
      status,
      reason: rejection?.reason,
      note: rejection?.note,
      extra: extra,
    );
  }

  final text = (res.message?.trim().isNotEmpty ?? false)
      ? res.message!
      : (res.ok ? null : fallbackError);
  if (text != null) {
    messenger?.showSnackBar(SnackBar(content: Text(text)));
  }
  if (!res.ok) return null;
  final raw = res.map['booking'];
  return raw is Map ? CleaningBooking.fromJson(Map<String, dynamic>.from(raw)) : null;
}

/// The booked day is after today (phone date). Accepting early is normal,
/// so a new booking is never warned about.
bool _scheduledAfterToday(CleaningBooking booking) {
  final at = booking.scheduledFor;
  if (at == null || booking.isNew) return false;
  return DateUtils.dateOnly(at).isAfter(DateUtils.dateOnly(DateTime.now()));
}

/// "Confirm Pickup: Confirm this step for booking LND85SQ4?" with Cancel /
/// Confirm, plus a warning when the booking is for a later day (VA-30; the
/// server allows the step, so the app only warns). True when confirmed.
Future<bool> _confirmStep(BuildContext context, CleaningBooking booking, String title) async {
  final s = S.of(context);
  final future = _scheduledAfterToday(booking);
  const orange = Color(0xFFFF5216);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: appFont('Inter', fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.serviceStepConfirmBody(isolated(booking.displayCode)),
            style: appFont('Inter', fontSize: 13.5, color: const Color(0xFF424242)),
          ),
          if (future) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4EC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: orange),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.serviceStepFutureWarning(isolated(CleaningBookingFormat.date(booking.scheduledFor!))),
                      style: appFont('Inter', fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(s.cancel, style: appFont('Inter', color: const Color(0xFF757575), fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(s.serviceStepConfirm, style: appFont('Inter', color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return ok == true;
}
