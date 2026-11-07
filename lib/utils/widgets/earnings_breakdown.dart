import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';

/// "Commission −12.50 MRU · Net 112.50 MRU" under an earnings order row.
///
/// `earnings/orders` sends `commission_amount` (what SAIMPEX keeps) and
/// `net_amount` (what the vendor gets) per order (VA-12, backend #173).
/// Shows nothing when the server sends neither, so older servers are fine.
class EarningsBreakdown extends StatelessWidget {
  const EarningsBreakdown({
    super.key,
    required this.commission,
    required this.net,
    this.fontSize = 11.5,
    this.alignEnd = true,
  });

  final dynamic commission;
  final dynamic net;
  final double fontSize;
  final bool alignEnd;

  static double? _num(dynamic v) => v == null ? null : double.tryParse('$v');

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  /// True when the row has a breakdown to show.
  static bool has(dynamic commission, dynamic net) =>
      _num(commission) != null && _num(net) != null;

  @override
  Widget build(BuildContext context) {
    final c = _num(commission);
    final n = _num(net);
    // Nothing to explain on a cancelled (0 MRU) order: the phone showed
    // "Commission −0 MRU · Net 0 MRU" on every cancelled row.
    if (c == null || n == null || (c == 0 && n == 0)) {
      return const SizedBox.shrink();
    }
    final s = S.of(context);
    final style = appFont(
      'Inter',
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF6B7280),
    );
    // Amounts stay left-to-right in Arabic.
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${s.commission} '),
            TextSpan(text: '⁦${c > 0 ? '−' : ''}${_fmt(c)} MRU⁩'),
            const TextSpan(text: '  ·  '),
            TextSpan(text: '${s.earningsNet} '),
            TextSpan(
              text: '⁦${_fmt(n)} MRU⁩',
              style: style.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        style: style,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      ),
    );
  }
}
