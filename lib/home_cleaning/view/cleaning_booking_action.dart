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
  // Laundry, Confirm Pickup on a per-kg service: weigh first (V14). The
  // sheet either asks the customer for the difference (payment request,
  // status stays) or confirms the pickup with the actual weight.
  if (!reject && ServiceKinds.isLaundry && booking.status == 2 && booking.raw['requires_weight'] == true) {
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
