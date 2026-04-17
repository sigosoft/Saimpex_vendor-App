import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/Utils/Utils.dart';
import 'package:saimpex_vendor/Utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/Utils/widgets/no_data_widget.dart';

class EarningsAllOrdersScreen extends StatefulWidget {
  final String initialFilter;
  const EarningsAllOrdersScreen({super.key, this.initialFilter = 'All'});

  @override
  State<EarningsAllOrdersScreen> createState() =>
      _EarningsAllOrdersScreenState();
}

class _EarningsAllOrdersScreenState extends State<EarningsAllOrdersScreen> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Available', 'Pending', 'Cancelled'];

  bool _isLoadingOrders = true;
  List<Map<String, dynamic>> _apiOrders = [];
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  int _page = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _fetchOrders();
    _scrollController.addListener(_loadMoreOrders);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreOrders);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreOrders() {
    if (_hasNextPage &&
        !_isLoadingOrders &&
        !_isLoadMoreRunning &&
        _scrollController.position.extentAfter < 300) {
      _fetchOrders(loadMore: true);
    }
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
            S.of(context).orders,
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
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterChips(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.015),

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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(double screenWidth, double screenHeight) {
    return Row(
      children: _filters.map((filter) {
        final bool isSelected = _selectedFilter == filter;
        return Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.02),
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = filter);
              _fetchOrders();
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
}
