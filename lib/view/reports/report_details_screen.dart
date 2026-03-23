import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import '../../generated/l10n.dart';
import '../../resources/colors.dart';
import '../../utils/Widgets/custom_app_bar.dart';

/// Data for the report/order details screen (summary + breakdown).
class ReportDetailsParams {
  final String orderId;
  final String status;
  final String customerName;
  final String phone;
  final String dateTime;
  final String totalAmount;
  final String subtotal;
  final String discount;
  final String deliveryFee;
  final String tax;
  final String earnings;
  final String commission;
  final String paymentMethod;
  final String currency;

  const ReportDetailsParams({
    required this.orderId,
    required this.status,
    required this.customerName,
    required this.phone,
    required this.dateTime,
    required this.totalAmount,
    this.subtotal = '20.00',
    this.discount = '00.00',
    this.deliveryFee = '00.00',
    this.tax = '00.00',
    this.earnings = '20.00',
    this.commission = '10.00',
    this.paymentMethod = 'Cash',
    this.currency = 'MRU',
  });
}

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.params});

  final ReportDetailsParams params;

  static const Color _bgColor = Color(0xFFFFF5F2);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1A1C1E);
  static const Color _textMuted = Color(0xFF707781);

  @override
  Widget build(BuildContext context) {
    final isRtl = FlutterLocalization.instance.currentLocale?.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: CommonBackground(
        backgroundColor: _bgColor,
        appBar: CustomAppBar(
          title: S.of(context).basketDetailsTitle,
          onTap: () => Get.back(),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryCard(context),
              const SizedBox(height: 16),
              _buildBreakdownCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final isCompleted = params.status.toUpperCase() == 'COMPLETED';
    final statusBg = isCompleted ? green : yellow;
    final statusTextColor = isCompleted ? Colors.white : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _badge(params.orderId, buttonbg, colorPrimary),
              const SizedBox(width: 8),
              _badge(params.status, statusBg, statusTextColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  params.customerName,
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                S.of(context).totalAmount.toUpperCase(),
                style: GoogleFonts.rubik(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.phone_rounded, size: 14, color: _textMuted),
                    const SizedBox(width: 6),
                    Text(
                      params.phone,
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${params.totalAmount} ${params.currency}',
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: _textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  params.dateTime,
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    color: _textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.rubik(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _breakdownRow(S.of(context).subtotal, '${params.subtotal} ${params.currency}'),
          _breakdownRow(S.of(context).discount, '${params.discount} ${params.currency}'),
          _breakdownRow(S.of(context).deliveryFee, '${params.deliveryFee} ${params.currency}'),
          _breakdownRow(S.of(context).tax, '${params.tax} ${params.currency}'),
          _breakdownRow(S.of(context).earnings, '${params.earnings} ${params.currency}'),
          _breakdownRow(S.of(context).commission, '${params.commission} ${params.currency}'),
          _breakdownRow(S.of(context).paymentMethod, params.paymentMethod=="1"?S.of(context).cash:S.of(context).onlinePayment, valueColor: colorPrimary),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 13,
              color: _textMuted,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
