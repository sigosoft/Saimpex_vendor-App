import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/view/settings/payout_details.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  // Top tab: 0 = Order Amount, 1 = Payouts
  int _selectedTab = 0;

  // Filter: All, Available, Pending, Cancelled
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Available', 'Pending', 'Cancelled'];

  // Dummy order data
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#ORD-000246',
      'date': 'Feb 07, 2026 11:45 AM, Today',
      'status': 'AVAILABLE',
      'amount': '450.00 MRU',
    },
    {
      'id': '#ORD-000241',
      'date': 'Feb 07, 2026 10:45 AM, Today',
      'status': 'AVAILABLE',
      'amount': '550.00 MRU',
    },
    {
      'id': '#ORD-000230',
      'date': 'Feb 07, 2026 09:45 AM, Today',
      'status': 'AVAILABLE',
      'amount': '300.00 MRU',
    },
    {
      'id': '#ORD-000225',
      'date': 'Feb 07, 2026 09:15 AM, Today',
      'status': 'PENDING',
      'amount': '400.00 MRU',
    },
    {
      'id': '#ORD-000202',
      'date': 'Feb 07, 2026 08:30 AM, Today',
      'status': 'CANCELLED',
      'amount': '0.00 MRU',
    },
  ];

  // Dummy payout data
  final List<Map<String, dynamic>> _payouts = [
    {
      'id': '#TRX002',
      'date': 'Feb 07, 2026 10:45 AM, Today',
      'status': 'CREDITED',
      'amount': '1000.00 MRU',
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 'All') return _orders;
    return _orders
        .where(
          (o) =>
              o['status'].toString().toLowerCase() ==
              _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return const Color(0xFF22C55E);
      case 'CREDITED':
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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
              // ─── Top Tab: Order Amount / Payouts ───
              _buildTopTabBar(screenWidth, screenHeight),

              SizedBox(height: screenHeight * 0.02),

              // ─── Summary Card ───
              _buildSummaryCard(screenWidth, screenHeight),

              SizedBox(height: screenHeight * 0.02),

              if (_selectedTab == 0) ...[
                // ─── Filter Chips ───
                _buildFilterChips(screenWidth, screenHeight),

                SizedBox(height: screenHeight * 0.015),

                // ─── Order List ───
                ..._filteredOrders
                    .map(
                      (order) =>
                          _buildOrderTile(order, screenWidth, screenHeight),
                    )
                    .toList(),
              ] else ...[
                // ─── Payout List ───
                ..._payouts
                    .map(
                      (payout) =>
                          _buildPayoutTile(payout, screenWidth, screenHeight),
                    )
                    .toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Top Tab Bar ───────────────────────────────────────────────────────────
  Widget _buildTopTabBar(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.92,
      height: screenHeight * 0.055,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildTabItem(
            label: S.of(context).orderAmount,
            index: 0,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
          _buildTabItem(
            label: S.of(context).payouts,
            index: 1,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required int index,
    required double screenWidth,
    required double screenHeight,
  }) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: screenHeight * 0.055,
          decoration: BoxDecoration(
            color: isSelected ? colorPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: screenWidth * 0.035,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Summary Card ──────────────────────────────────────────────────────────
  Widget _buildSummaryCard(double screenWidth, double screenHeight) {
    final bool isPayouts = _selectedTab == 1;

    // Calculate payouts summary
    double totalReceived = 0;
    for (var p in _payouts) {
      String amt = p['amount'].toString().replaceAll(' MRU', '');
      totalReceived += double.tryParse(amt) ?? 0;
    }
    double totalSale = 1300.0;
    double availablePayoutBalance = totalSale - totalReceived;

    return Container(
      width: screenWidth * 0.92,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.022,
      ),
      decoration: BoxDecoration(
        color: colorPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            isPayouts ? S.of(context).totalSaleAmount : S.of(context).pendingOrderBalance,
            isPayouts ? '${totalSale.toStringAsFixed(2)} MRU' : '400.00 MRU',
            screenWidth,
          ),
          SizedBox(height: screenHeight * 0.012),
          _buildSummaryRow(
            isPayouts ? S.of(context).availablePayoutBalance : S.of(context).availableOrderBalance,
            isPayouts
                ? '${availablePayoutBalance.toStringAsFixed(2)} MRU'
                : '1300.00 MRU',
            screenWidth,
          ),
          SizedBox(height: screenHeight * 0.012),
          _buildSummaryRow(
            S.of(context).totalPayoutReceived,
            isPayouts
                ? (totalReceived == 0
                          ? '00.00'
                          : totalReceived.toStringAsFixed(2)) +
                      ' MRU'
                : '1000.00 MRU',
            screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: screenWidth * 0.033,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.rubik(
            fontSize: screenWidth * 0.033,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ─── Filter Chips ──────────────────────────────────────────────────────────
  Widget _buildFilterChips(double screenWidth, double screenHeight) {
    return Row(
      children: _filters.map((filter) {
        final bool isSelected = _selectedFilter == filter;
        return Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.02),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.035,
                vertical: screenHeight * 0.008,
              ),
              decoration: BoxDecoration(
                color: isSelected ? colorPrimary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? colorPrimary
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Text(
                _getLocalizedFilter(filter),
                style: GoogleFonts.rubik(
                  fontSize: screenWidth * 0.031,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getLocalizedFilter(String filter) {
    switch (filter.toLowerCase()) {
      case 'all':
        return S.of(context).all;
      case 'available':
        return S.of(context).available;
      case 'pending':
        return S.of(context).pending;
      case 'cancelled':
        return S.of(context).cancelled;
      default:
        return filter;
    }
  }

  String _getLocalizedStatus(String status) {
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

  // ─── Order Tile ────────────────────────────────────────────────────────────
  Widget _buildOrderTile(
    Map<String, dynamic> order,
    double screenWidth,
    double screenHeight,
  ) {
    final String status = order['status'] as String;
    final Color statusColor = _statusColor(status);

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
          // Right: status + amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getLocalizedStatus(status),
                style: GoogleFonts.rubik(
                  fontSize: screenWidth * 0.026,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                order['amount'] as String,
                style: GoogleFonts.rubik(
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333E63),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Payout Tile ───────────────────────────────────────────────────────────
  Widget _buildPayoutTile(
    Map<String, dynamic> payout,
    double screenWidth,
    double screenHeight,
  ) {
    final String status = payout['status'] as String;
    final Color statusColor = _statusColor(status);

    return Container(
      width: screenWidth * 0.92,
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: ID + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payout['id'] as String,
                      style: GoogleFonts.rubik(
                        fontSize: screenWidth * 0.038,
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
                            payout['date'] as String,
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
              // Right: status + amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _getLocalizedStatus(status),
                    style: GoogleFonts.rubik(
                      fontSize: screenWidth * 0.026,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    payout['amount'] as String,
                    style: GoogleFonts.rubik(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF333E63),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          // ─── View Details Button ───
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.045,
            child: OutlinedButton(
              onPressed: () {
                Get.to(() => PayoutDetailsScreen(payout: payout));
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorPrimary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                S.of(context).viewDetails,
                style: GoogleFonts.rubik(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                  color: colorPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
