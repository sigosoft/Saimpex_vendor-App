import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/cleaning_api.dart';
import 'package:saimpex_vendor/home_cleaning/controller/home_cleaning_controller.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';
import 'package:saimpex_vendor/home_cleaning/view/reject_booking_sheet.dart';

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
  if (reject) {
    rejection = await showRejectBookingSheet(context);
    if (rejection == null) return null;
    status = CleaningStatus.cancelled;
  } else {
    status = booking.resolvedNextStatus;
  }
  if (status == null) return null;

  final CleaningApiResult res;
  if (Get.isRegistered<HomeCleaningController>()) {
    res = await Get.find<HomeCleaningController>().updateBookingStatus(
      booking,
      status,
      reason: rejection?.reason,
      note: rejection?.note,
    );
  } else {
    res = await CleaningBookingActions.updateStatus(
      booking.id,
      status,
      reason: rejection?.reason,
      note: rejection?.note,
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
