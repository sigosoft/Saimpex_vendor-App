import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';

/// Admin add/deduct adjustments to the vendor's Available Balance
/// (`GET earnings/balanceAdjustments`), shown under the payouts list.
/// No Figma screen: built in the style of the earnings payout cards.
class BalanceAdjustmentsSection extends StatefulWidget {
  const BalanceAdjustmentsSection({super.key, this.accent = const Color(0xFFF97316)});

  final Color accent;

  @override
  State<BalanceAdjustmentsSection> createState() =>
      BalanceAdjustmentsSectionState();
}

class BalanceAdjustmentsSectionState extends State<BalanceAdjustmentsSection> {
  static const Color _ink = Color(0xFF333E63);
  static const Color _added = Color(0xFF16A34A);
  static const Color _deducted = Color(0xFFDC2626);

  bool _loading = true;
  List<Map<String, dynamic>> _adjustments = [];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    if (mounted) setState(() => _loading = true);
    List<Map<String, dynamic>> rows = [];
    try {
      final response =
          await DioClient().get(ApiEndPoints.earningsBalanceAdjustments);
      final body = response.data;
      if (body is Map && body['status'].toString() == 'true') {
        final list = body['data']?['adjustments'];
        if (list is List) {
          rows = list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching balance adjustments: $e');
    }
    if (mounted) {
      setState(() {
        _adjustments = rows;
        _loading = false;
      });
    }
  }

  String _money(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '') ?? 0;
    return '${amount.toStringAsFixed(2)} MRU';
  }

  String _date(dynamic value) {
    final dt = DateTime.tryParse(value?.toString() ?? '');
    return dt == null ? '' : DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          S.of(context).balanceAdjustments,
          style: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 10),
        if (_loading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: widget.accent),
            ),
          )
        else if (_adjustments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              S.of(context).noBalanceAdjustmentsYet,
              style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey),
            ),
          )
        else
          for (final row in _adjustments) _tile(context, row),
      ],
    );
  }

  Widget _tile(BuildContext context, Map<String, dynamic> row) {
    final bool deduct = row['type']?.toString() == 'deduct';
    final String note = row['note']?.toString().trim() ?? '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.isEmpty ? S.of(context).adminAdjustment : note,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _date(row['date']),
                      style: GoogleFonts.rubik(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${deduct ? '-' : '+'} ${_money(row['amount'])}',
                textDirection: TextDirection.ltr,
                style: GoogleFonts.rubik(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: deduct ? _deducted : _added,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${S.of(context).balanceAfter}: ${_money(row['balance_after'])}',
                style: GoogleFonts.rubik(fontSize: 11, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
