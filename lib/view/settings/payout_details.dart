import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/colors.dart';

import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/Utils/Utils.dart';
import 'package:saimpex_vendor/Utils/widgets/app_loader.dart';

class PayoutDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> payout;

  const PayoutDetailsScreen({super.key, required this.payout});

  @override
  State<PayoutDetailsScreen> createState() => _PayoutDetailsScreenState();
}

class _PayoutDetailsScreenState extends State<PayoutDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _payoutDetails;
  List<Map<String, dynamic>> _relatedOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      var token = await getSavedObject("token");
      DioClient().updateToken(token);

      var payoutId =
          widget.payout['raw']?['id']?.toString() ??
          widget.payout['id']?.toString().replaceAll(RegExp(r'[^0-9]'), '');

      final response = await DioClient().get(
        ApiEndPoints.earningsPayoutDetail,
        query: {"id": payoutId},
      );

      if (response.data?['status'].toString() == "true") {
        if (mounted) {
          setState(() {
            // The API wraps the payout inside response.data['data']['payout']
            _payoutDetails =
                response.data['data']?['payout'] as Map<String, dynamic>?;

            // Related orders are under the 'payout_orders' key
            final rawOrdersList = _payoutDetails?['payout_orders'];
            if (rawOrdersList != null && rawOrdersList is List) {
              _relatedOrders = (rawOrdersList as List<dynamic>).map((o) {
                // Try to get order specific date, fallback to payout's payment_date
                String rawDate =
                    o['order_placed_at']?.toString() ??
                    o['created_at']?.toString() ??
                    _payoutDetails?['payment_date']?.toString() ??
                    _payoutDetails?['created_at']?.toString() ??
                    '';

                DateTime? dt;
                if (rawDate.isNotEmpty) {
                  dt = DateTime.tryParse(rawDate);
                }

                String formattedDate = rawDate;
                if (dt != null) {
                  formattedDate = formatOrderPlacedAt(dt);
                }

                return {
                  'id': o['order_code']?.toString() ?? '#ORD-${o['order_id']}',
                  'date': formattedDate.isNotEmpty ? formattedDate : '—',
                  'amount':
                      '${o['payout_amount'] ?? o['amount'] ?? '0.00'} MRU',
                };
              }).toList();
            }

            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching payout details: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

    final String status = widget.payout['status'] as String? ?? '';
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
                  border: Border.all(color: colorPrimary.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: ID + status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.payout['id'] as String? ?? '',
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
                              widget.payout['date'] as String? ?? '',
                              style: GoogleFonts.rubik(
                                fontSize: screenWidth * 0.028,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          widget.payout['amount'] as String? ?? '',
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
                          '${S.of(context).paymentId}: ${_payoutDetails?['transaction_ref'] ?? _payoutDetails?['payment_id'] ?? 'N/A'}',
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
                    if (_payoutDetails?['payment_note'] != null &&
                        _payoutDetails!['payment_note']
                            .toString()
                            .isNotEmpty) ...[
                      Text(
                        '${S.of(context).notes}: ${_payoutDetails!['payment_note']}',
                        style: GoogleFonts.rubik(
                          fontSize: screenWidth * 0.028,
                          color: const Color(0xFF333E63),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      Text(
                        '${S.of(context).notes}: N/A',
                        style: GoogleFonts.rubik(
                          fontSize: screenWidth * 0.028,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // ─── Related Orders List ───
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: const Center(child: AppLoader()),
                )
              else if (_relatedOrders.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: Center(
                    child: Text(
                      S.of(context).noOrdersFound,
                      style: GoogleFonts.rubik(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else ...[
                ..._relatedOrders
                    .map(
                      (order) =>
                          _buildOrderTile(order, screenWidth, screenHeight),
                    )
                    .toList(),
              ],
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
