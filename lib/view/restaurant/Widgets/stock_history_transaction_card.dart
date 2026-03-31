import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// One row in stock history: add/remove, quantity, remaining.
class StockHistoryTransactionCard extends StatelessWidget {
  const StockHistoryTransactionCard({
    super.key,
    required this.stockId,
    required this.dateTime,
    required this.byUser,
    required this.isStockAdded,
    required this.quantityDelta,
    required this.remaining,
  });

  final String stockId;
  final DateTime dateTime;
  final String byUser;
  final bool isStockAdded;
  final int quantityDelta;
  final int remaining;

  static final _dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  Widget build(BuildContext context) {
    final accent = isStockAdded ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    final qtyText = quantityDelta >= 0 ? '+$quantityDelta' : '$quantityDelta';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'STOCK ID: #$stockId',
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _dateFmt.format(dateTime),
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by $byUser',
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isStockAdded ? Icons.add : Icons.remove,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isStockAdded ? 'Stock Added' : 'Stock Removed',
                style: GoogleFonts.rubik(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _metricColumn(
                  label: 'QUANTITY',
                  value: qtyText,
                  valueColor: accent,
                ),
              ),
              Expanded(
                child: _metricColumn(
                  label: 'REMAINING',
                  value: '$remaining',
                  valueColor: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricColumn({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.rubik(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
