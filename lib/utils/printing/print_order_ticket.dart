import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/printing/order_print_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// Prints one order's ticket on the saved printer (Settings → Printer) and
/// shows the result. Used by the pharmacy and water order screens (V7).
Future<void> printOrderTicket(
  BuildContext context, {
  required dynamic orderId,
  required String orderType,
}) async {
  final id = orderId?.toString().trim() ?? '';
  if (id.isEmpty || id == 'null') return;
  showToast(context, S.of(context).sendingToPrinter);
  try {
    await OrderPrintService().printOrder(orderId: id, orderType: orderType);
    if (context.mounted) showToast(context, S.of(context).ticketSentToPrinter);
  } catch (e) {
    debugPrint('Print $orderType order $id failed: $e');
    if (context.mounted) showToast(context, S.of(context).printFailed);
  }
}
