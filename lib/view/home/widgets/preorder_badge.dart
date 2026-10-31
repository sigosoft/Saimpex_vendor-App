import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:saimpex_vendor/generated/l10n.dart';

const Color preorderColor = Color(0xFF7C3AED);
const Color preorderTint = Color(0xFFEDE9FE);

/// Delivery time of a pre-order, e.g. "02/11 13:30" (DD/MM, 24 h).
String formatPreorderTime(DateTime time) =>
    DateFormat('dd/MM HH:mm').format(time.toLocal());

/// "In 1 h 20 min" / "In 15 min" / "Due now".
String preorderDueText(DateTime time) {
  final minutes = time.difference(DateTime.now()).inMinutes;
  if (minutes <= 0) return S.current.preorderDueNow;
  if (minutes < 60) return S.current.dueInMinutes('$minutes');
  return S.current.dueInHoursMinutes('${minutes ~/ 60}', '${minutes % 60}');
}

/// "Pre-order · 02/11 13:30" chip shown next to the order id.
/// No Figma screen for pre-orders: built in the style of the order card chips.
class PreorderBadge extends StatelessWidget {
  const PreorderBadge({super.key, required this.scheduledFor});

  final DateTime scheduledFor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: preorderTint,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 12, color: preorderColor),
          const SizedBox(width: 4),
          Text(
            '${S.of(context).preorderBadge} · ${formatPreorderTime(scheduledFor)}',
            textDirection: Directionality.of(context),
            style: GoogleFonts.rubik(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: preorderColor,
            ),
          ),
        ],
      ),
    );
  }
}
