import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/view/settings/payout_details.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/Utils/Utils.dart';
import 'package:saimpex_vendor/Utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/Utils/widgets/no_data_widget.dart';
import 'package:saimpex_vendor/view/settings/earnings_all_orders.dart';

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

  bool _isLoadingSummary = true;
  Map<String, dynamic>? _earningsSummary;

  bool _isLoadingOrders = true;
  List<Map<String, dynamic>> _apiOrders = [];
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  int _page = 1;
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingPayouts = true;
  List<Map<String, dynamic>> _apiPayouts = [];
  bool _hasNextPagePayouts = true;
  bool _isLoadMoreRunningPayouts = false;
  int _pagePayouts = 1;

  void _loadMoreTabs() {
    if (_selectedTab == 1) {
      if (_hasNextPagePayouts &&
          !_isLoadingPayouts &&
          !_isLoadMoreRunningPayouts &&
          _scrollController.position.extentAfter < 300) {
        _fetchPayouts(loadMore: true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEarningsSummary();
    _fetchOrders();
    _fetchPayouts();
    _scrollController.addListener(_loadMoreTabs);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreTabs);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoadingOrders = true;
        _page = 1;
        _apiOrders.clear();
        _hasNextPage = true;
        _isLoadMoreRunning = false;
      });
    } else {
      if (_isLoadMoreRunning) return;
      setState(() {
        _isLoadMoreRunning = true;
      });
    }

    try {
      var token = await getSavedObject("token");
      DioClient().updateToken(token);

      final String filterStatus = _selectedFilter.toLowerCase();

      final response = await DioClient().get(
        ApiEndPoints.earningsOrders,
        query: {"limit": 10, "page": _page, "filter": filterStatus},
      );

      if (response.data?['status'].toString() == "true") {
        final ordersData = response.data['data']['orders']['data'] as List;
        final currentPage = response.data['data']['orders']['current_page'];
        final lastPage = response.data['data']['orders']['last_page'];

        List<Map<String, dynamic>> parsedOrders = ordersData.map((order) {
          // Parse date
          String rawDate = order['order_placed_at']?.toString() ?? '';
          DateTime? dt;
          if (rawDate.isNotEmpty) {
            dt = DateTime.tryParse(rawDate);
          }
          String formattedDate = rawDate;
          if (dt != null) {
            formattedDate = formatOrderPlacedAt(dt);
          }

          return {
            'id': order['order_code']?.toString() ?? '',
            'date': formattedDate,
            'status': order['earnings_status']?.toString() ?? '',
            'amount': '${order['earnings_amount'] ?? '0.00'} MRU',
          };
        }).toList();

        if (mounted) {
          setState(() {
            if (loadMore) {
              _apiOrders.addAll(parsedOrders);
              _isLoadMoreRunning = false;
            } else {
              _apiOrders = parsedOrders;
              _isLoadingOrders = false;
            }
            if (currentPage >= lastPage) {
              _hasNextPage = false;
            } else {
              _hasNextPage = true;
              _page++;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingOrders = false;
            _isLoadMoreRunning = false;
            _hasNextPage = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
          _isLoadMoreRunning = false;
          _hasNextPage = false;
        });
      }
      debugPrint("Error fetching orders: $e");
    }
  }

  Future<void> _fetchPayouts({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoadingPayouts = true;
        _pagePayouts = 1;
        _apiPayouts.clear();
        _hasNextPagePayouts = true;
        _isLoadMoreRunningPayouts = false;
      });
    } else {
      if (_isLoadMoreRunningPayouts) return;
      setState(() {
        _isLoadMoreRunningPayouts = true;
      });
    }

    try {
      var token = await getSavedObject("token");
      DioClient().updateToken(token);

      final response = await DioClient().get(
        ApiEndPoints.earningsPayoutHistory,
        query: {"limit": 10, "page": _pagePayouts},
      );

      if (response.data?['status'].toString() == "true") {
        final payoutsData = response.data['data']['payouts']['data'] as List;
        final int currentPage =
            response.data['data']['payouts']['current_page'] ?? 1;
        final int lastPage = response.data['data']['payouts']['last_page'] ?? 1;

        List<Map<String, dynamic>> parsedPayouts = payoutsData.map((payout) {
          String rawDate =
              payout['created_at']?.toString() ??
              payout['paid_at']?.toString() ??
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
            'id': '#PYT${payout['id'] ?? ''}',
            'date': formattedDate,
            'status': payout['status']?.toString() ?? 'CREDITED',
            'amount': '${payout['amount'] ?? '0.00'} MRU',
            'raw': payout,
          };
        }).toList();

        if (mounted) {
          setState(() {
            if (loadMore) {
              _apiPayouts.addAll(parsedPayouts);
              _isLoadMoreRunningPayouts = false;
            } else {
              _apiPayouts = parsedPayouts;
              _isLoadingPayouts = false;
            }

            if (currentPage >= lastPage) {
              _hasNextPagePayouts = false;
            } else {
              _hasNextPagePayouts = true;
              _pagePayouts++;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingPayouts = false;
            _isLoadMoreRunningPayouts = false;
            _hasNextPagePayouts = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPayouts = false;
          _isLoadMoreRunningPayouts = false;
          _hasNextPagePayouts = false;
        });
      }
      debugPrint("Error fetching payouts: $e");
    }
  }

  Future<void> _fetchEarningsSummary() async {
    try {
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(ApiEndPoints.earningsSummary);
      if (response.data?['status'].toString() == "true") {
        if (mounted) {
          setState(() {
            _earningsSummary = response.data['data'];
            _isLoadingSummary = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingSummary = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
      }
      debugPrint("Error fetching earnings summary: $e");
    }
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
        body: RefreshIndicator(
          color: colorPrimary,
          onRefresh: () async {
            await _fetchEarningsSummary();
            if (_selectedTab == 0) {
              await _fetchOrders();
            } else {
              await _fetchPayouts();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
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

                  // ─── View All ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => EarningsAllOrdersScreen(
                              initialFilter: _selectedFilter,
                            ),
                          );
                        },
                        child: Text(
                          S.of(context).viewAll,
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // ─── Order List ───
                  if (_isLoadingOrders)
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.05),
                      child: const Center(child: AppLoader()),
                    )
                  else if (_apiOrders.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.05),
                      child: NoDataWidget(
                        context,
                        S.of(context).noOrdersFound,
                        S.of(context).noOrdersFound,
                        'lib/assets/images/nodata.png',
                      ),
                    )
                  else ...[
                    ..._apiOrders
                        .map(
                          (order) =>
                              _buildOrderTile(order, screenWidth, screenHeight),
                        )
                        .toList(),
                    if (_isLoadMoreRunning)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: AppLoader()),
                      ),
                  ],
                ] else ...[
                  // ─── Payout List ───
                  if (_isLoadingPayouts)
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.05),
                      child: const Center(child: AppLoader()),
                    )
                  else if (_apiPayouts.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.05),
                      child: NoDataWidget(
                        context,
                        S.of(context).noPayoutsYet,
                        S.of(context).noPayoutsYet,
                        'lib/assets/images/nodata.png',
                      ),
                    )
                  else ...[
                    ..._apiPayouts
                        .map(
                          (payout) => _buildPayoutTile(
                            payout,
                            screenWidth,
                            screenHeight,
                          ),
                        )
                        .toList(),
                    if (_isLoadMoreRunningPayouts)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: AppLoader()),
                      ),
                  ],
                ],
              ],
            ),
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

    if (_isLoadingSummary) {
      return Container(
        width: screenWidth * 0.92,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: (screenHeight * 0.022) + 15,
        ),
        decoration: BoxDecoration(
          color: colorPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    String formatVal(dynamic val) {
      double parsed = double.tryParse(val.toString()) ?? 0.0;
      return parsed.toStringAsFixed(2);
    }

    String pendingOrderBal = '0.00';
    String availableOrderBal = '0.00';
    String orderTotalPayout = '0.00';

    String totalSaleAmount = '0.00';
    String availablePayoutBal = '0.00';
    String payoutTotalReceived = '0.00';

    if (_earningsSummary != null) {
      if (_earningsSummary!['order_amount_tab'] != null) {
        pendingOrderBal = formatVal(
          _earningsSummary!['order_amount_tab']['pending_order_balance'],
        );
        availableOrderBal = formatVal(
          _earningsSummary!['order_amount_tab']['available_order_balance'],
        );
        orderTotalPayout = formatVal(
          _earningsSummary!['order_amount_tab']['total_payout_received'],
        );
      }
      if (_earningsSummary!['payouts_tab'] != null) {
        totalSaleAmount = formatVal(
          _earningsSummary!['payouts_tab']['total_sale_amount'],
        );
        availablePayoutBal = formatVal(
          _earningsSummary!['payouts_tab']['available_payout_balance'],
        );
        payoutTotalReceived = formatVal(
          _earningsSummary!['payouts_tab']['total_payout_received'],
        );
      }
    }

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
            isPayouts
                ? S.of(context).totalSaleAmount
                : S.of(context).pendingOrderBalance,
            isPayouts ? '$totalSaleAmount MRU' : '$pendingOrderBal MRU',
            screenWidth,
          ),
          SizedBox(height: screenHeight * 0.012),
          _buildSummaryRow(
            isPayouts
                ? S.of(context).availablePayoutBalance
                : S.of(context).availableOrderBalance,
            isPayouts ? '$availablePayoutBal MRU' : '$availableOrderBal MRU',
            screenWidth,
          ),
          SizedBox(height: screenHeight * 0.012),
          _buildSummaryRow(
            S.of(context).totalPayoutReceived,
            isPayouts ? '$payoutTotalReceived MRU' : '$orderTotalPayout MRU',
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
            onTap: () {
              setState(() => _selectedFilter = filter);
              if (_selectedTab == 0) {
                _fetchOrders();
              }
            },
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
