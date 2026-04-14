import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/colors.dart';

class PayoutDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> payout;

  const PayoutDetailsScreen({super.key, required this.payout});

  // Dummy related orders for this payout
  static const List<Map<String, dynamic>> _relatedOrders = [
    {
      'id': '#ORD-000246',
      'date': 'Feb 07, 2026 11:45 AM, Today',
      'amount': '450.00 MRU',
    },
    {
      'id': '#ORD-000241',
      'date': 'Feb 07, 2026 10:45 AM, Today',
      'amount': '550.00 MRU',
    },
  ];

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CREDITED':
      case 'AVAILABLE':
        return const Color(0xFF22C55E);
      case 'PENDING':
        return colorPrimary;
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final String status = payout['status'] as String? ?? '';
    final Color statusColor = _statusColor(status);

    return Directionality(
      textDirection: localization.currentLocale?.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7F3),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF333E63),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            S.of(context).earnings,
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF333E63),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Divider(color: Colors.grey.withOpacity(0.1), height: 1),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top Transaction Card (light orange bg) ───
              Container(
                width: screenWidth * 0.92,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.045,
                  vertical: screenHeight * 0.018,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDE6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorPrimary.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: ID + status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          payout['id'] as String? ?? '',
                          style: GoogleFonts.rubik(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w700,
                            color: colorPrimary,
                          ),
                        ),
                        Text(
                          _getLocalizedStatus(status, context),
                          style: GoogleFonts.rubik(
                            fontSize: screenWidth * 0.028,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.006),
                    // Row 2: date + amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: screenWidth * 0.03,
                              color: Colors.grey,
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              payout['date'] as String? ?? '',
                              style: GoogleFonts.rubik(
                                fontSize: screenWidth * 0.028,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          payout['amount'] as String? ?? '',
                          style: GoogleFonts.rubik(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF333E63),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // Row 3: Payment ID + View Payment Proof
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${S.of(context).paymentId}: ABCD123456',
                          style: GoogleFonts.rubik(
                            fontSize: screenWidth * 0.03,
                            color: const Color(0xFF333E63),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            S.of(context).viewPaymentProof,
                            style: GoogleFonts.rubik(
                              fontSize: screenWidth * 0.03,
                              color: colorPrimary,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              decorationColor: colorPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    // Row 4: Notes
                    Text(
                      '${S.of(context).notes}: Lorem ipsum dolor sit amet, consectetur adipiscing elit',
                      style: GoogleFonts.rubik(
                        fontSize: screenWidth * 0.028,
                        color: const Color(0xFF333E63),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // ─── Related Orders List ───
              ..._relatedOrders
                  .map((order) => _buildOrderTile(order, screenWidth, screenHeight))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  String _getLocalizedStatus(String status, BuildContext context) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return S.of(context).available;
      case 'CREDITED':
        return S.of(context).credited;
      case 'PENDING':
        return S.of(context).pending;
      case 'CANCELLED':
        return S.of(context).cancelled;
      default:
        return status;
    }
  }

  Widget _buildOrderTile(
    Map<String, dynamic> order,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      width: screenWidth * 0.92,
      margin: EdgeInsets.only(bottom: screenHeight * 0.012),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.018,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: ID + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['id'] as String,
                  style: GoogleFonts.rubik(
                    fontSize: screenWidth * 0.036,
                    fontWeight: FontWeight.w600,
                    color: colorPrimary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: screenWidth * 0.03,
                      color: Colors.grey,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Expanded(
                      child: Text(
                        order['date'] as String,
                        style: GoogleFonts.rubik(
                          fontSize: screenWidth * 0.028,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right: amount only
          Text(
            order['amount'] as String,
            style: GoogleFonts.rubik(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF333E63),
            ),
          ),
        ],
      ),
    );
  }
}
