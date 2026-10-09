import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PayoutDetailsView extends StatelessWidget {
  const PayoutDetailsView({
    super.key,
    required this.transactionId,
    required this.timestamp,
    required this.amount,
  });

  final String transactionId;
  final String timestamp;
  final String amount;

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF1C1D1B);
  static const muted = Color(0xFF918E94);
  static const green = Color(0xFF16A34A);

  static void open(
    BuildContext context, {
    required String transactionId,
    required String timestamp,
    required String amount,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PayoutDetailsView(
          transactionId: transactionId,
          timestamp: timestamp,
          amount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE8E0), Color(0xFFFFF4EF), Colors.white],
              stops: [0, 0.18, 0.36],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE0D0)),
                      ),
                      child: const Icon(Icons.chevron_left_rounded, color: orange, size: 26),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33FFAE91),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0D7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFAE91)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transactionId,
                                        style: GoogleFonts.inter(
                                          color: orange,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time_outlined, size: 13, color: muted),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              timestamp,
                                              style: GoogleFonts.inter(
                                                color: muted,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'CREDITED',
                                      style: GoogleFonts.inter(
                                        color: green,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      amount,
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Payment ID: ABCD123456',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  'View Payment Proof',
                                  style: GoogleFonts.inter(
                                    color: orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    decorationColor: orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _ExpandableLine(
                              title: 'Notes',
                              text: 'Notes: Lorem ipsum dolor sit amet, consectetur adipiscing elit',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF9AA3B2),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _DetailOrderCard(
                      id: '#ORD-000246',
                      when: 'Feb 07, 2026 11:45 AM, Today',
                      reason: 'Lorem ipsum dolor sit amet',
                      payout: '450.00 MRU',
                      orderAmount: '500.00 MRU',
                    ),
                    const SizedBox(height: 12),
                    const _DetailOrderCard(
                      id: '#ORD-000241',
                      when: 'Feb 07, 2026 10:45 AM, Today',
                      amount: '550.00 MRU',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailOrderCard extends StatelessWidget {
  const _DetailOrderCard({
    required this.id,
    required this.when,
    this.reason,
    this.payout,
    this.orderAmount,
    this.amount,
  });

  final String id;
  final String when;
  final String? reason;
  final String? payout;
  final String? orderAmount;
  final String? amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: GoogleFonts.inter(
                    color: PayoutDetailsView.orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined, size: 13, color: PayoutDetailsView.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        when,
                        style: GoogleFonts.inter(
                          color: PayoutDetailsView.muted,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (reason != null) ...[
                  const SizedBox(height: 10),
                  _ExpandableLine(
                    title: 'Reason',
                    text: 'Reason: $reason',
                    fill: const Color(0xFFFDECEC),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    style: GoogleFonts.inter(
                      color: const Color(0xFFE24B4B),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (amount != null)
            Text(
              amount!,
              style: GoogleFonts.inter(
                color: PayoutDetailsView.ink,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _amountLine('Payout Amount', payout!),
                const SizedBox(height: 10),
                _amountLine('Order Amount', orderAmount!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _amountLine(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF9AA3B2),
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            color: PayoutDetailsView.ink,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ExpandableLine extends StatelessWidget {
  const _ExpandableLine({
    required this.title,
    required this.text,
    required this.style,
    this.fill,
    this.padding,
  });

  final String title;
  final String text;
  final TextStyle style;
  final Color? fill;
  final EdgeInsets? padding;

  void _open(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 12,
          shadowColor: const Color(0x33000000),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111111),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(text, style: style),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: PayoutDetailsView.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final line = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    final child = fill == null
        ? line
        : Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: line,
          );
    return GestureDetector(
      onTap: () => _open(context),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
