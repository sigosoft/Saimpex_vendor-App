import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_payout_details_screen.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/widgets/no_data_widget.dart';

class PharmacyEarningsScreen extends StatefulWidget {
  const PharmacyEarningsScreen({super.key});

  static const orange = Color(0xFFFF5216);
  static const button = Color(0xFFFF5317);
  static const ink = Color(0xFF1C1D1B);
  static const muted = Color(0xFF918E94);

  @override
  State<PharmacyEarningsScreen> createState() => _PharmacyEarningsScreenState();
}

enum _EarnTab { orders, payouts }

enum _OrderFilter { all, available, pending, cancelled }

enum _OrderStatus { available, pending, cancelled }

class _Order {
  const _Order({
    required this.id,
    required this.when,
    required this.amount,
    required this.status,
    this.statusLabel,
  });

  final String id;
  final String when;
  final String amount;
  final _OrderStatus status;
  final String? statusLabel;
}

class _Payout {
  const _Payout({
    required this.id,
    required this.when,
    required this.amount,
    required this.status,
    this.raw,
  });

  final String id;
  final String when;
  final String amount;
  final String status;
  final dynamic raw;
}

class _PharmacyEarningsScreenState extends State<PharmacyEarningsScreen> {
  _EarnTab _tab = _EarnTab.orders;
  _OrderFilter _filter = _OrderFilter.all;
  Map<String, dynamic>? _earningsSummary;
  bool _isLoadingSummary = false;
  List<_Order> _orders = [];
  bool _isLoadingOrders = false;
  List<_Payout> _payouts = [];
  bool _isLoadingPayouts = false;

  @override
  void initState() {
    super.initState();
    _fetchEarningsSummary();
    _fetchOrders();
    _fetchPayouts();
  }

  String _getEarningsSummaryUrl() {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    final endpoint = ApiEndPoints.pharmacyEarningsSummary.trim().replaceFirst(RegExp(r'^/'), '');
    return '$base/$endpoint';
  }

  Future<void> _fetchEarningsSummary() async {
    setState(() => _isLoadingSummary = true);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        if (mounted) {
          setState(() => _isLoadingSummary = false);
        }
        return;
      }

      final url = _getEarningsSummaryUrl();
      debugPrint("==================== GET PHARMACY EARNINGS SUMMARY ====================");
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyEarningsSummary}");
      debugPrint("Request Body: null (GET request)");

      print("==================== GET PHARMACY EARNINGS SUMMARY ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyEarningsSummary}");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(ApiEndPoints.pharmacyEarningsSummary);

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("======================================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("======================================================================");

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString() == 'true')) {
        final d = dataMap['data'];
        Map<String, dynamic>? summary;
        if (d is Map<String, dynamic>) {
          summary = d;
        } else if (d is Map) {
          summary = Map<String, dynamic>.from(d);
        }
        if (mounted) {
          setState(() {
            _earningsSummary = summary;
            _isLoadingSummary = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingSummary = false);
        }
      }
    } catch (e) {
      debugPrint("==================== GET PHARMACY EARNINGS SUMMARY ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("============================================================================");

      print("==================== GET PHARMACY EARNINGS SUMMARY ERROR ====================");
      print("Error: $e");
      print("============================================================================");

      if (mounted) {
        setState(() => _isLoadingSummary = false);
      }
    }
  }

  String _formatAmount(dynamic val) {
    if (val == null) return '0.00 MRU';
    final s = val.toString().trim();
    if (s.isEmpty) return '0.00 MRU';
    if (s.contains('MRU')) return s;
    final numVal = double.tryParse(s.replaceAll(',', ''));
    if (numVal != null) {
      return '${numVal.toStringAsFixed(2)} MRU';
    }
    return '$s MRU';
  }

  String _getEarningsOrdersUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    final endpoint = ApiEndPoints.pharmacyEarningsOrders.trim().replaceFirst(RegExp(r'^/'), '');
    final uri = Uri.parse('$base/$endpoint');
    if (query != null && query.isNotEmpty) {
      return uri.replace(queryParameters: query.map((k, v) => MapEntry(k, v.toString()))).toString();
    }
    return uri.toString();
  }

  String _getPendingOrderPaymentsUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    final endpoint = ApiEndPoints.pharmacyEarningsPendingOrderPayment.trim().replaceFirst(RegExp(r'^/'), '');
    final uri = Uri.parse('$base/$endpoint');
    if (query != null && query.isNotEmpty) {
      return uri.replace(queryParameters: query.map((k, v) => MapEntry(k, v.toString()))).toString();
    }
    return uri.toString();
  }

  String _getPayoutHistoryUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    final endpoint = ApiEndPoints.pharmacyEarningsPayoutHistory.trim().replaceFirst(RegExp(r'^/'), '');
    final uri = Uri.parse('$base/$endpoint');
    if (query != null && query.isNotEmpty) {
      return uri.replace(queryParameters: query.map((k, v) => MapEntry(k, v.toString()))).toString();
    }
    return uri.toString();
  }

  String _getOrderFilterQuery(_OrderFilter filter) {
    switch (filter) {
      case _OrderFilter.all:
        return 'all';
      case _OrderFilter.available:
        return 'available';
      case _OrderFilter.pending:
        return 'pending';
      case _OrderFilter.cancelled:
        return 'cancelled';
    }
  }

  _OrderStatus _parseOrderStatus(String? status) {
    final s = status?.toString().trim().toLowerCase() ?? '';
    if (s == 'available' || s == 'credited') {
      return _OrderStatus.available;
    } else if (s == 'cancelled' || s == 'canceled' || s == 'rejected') {
      return _OrderStatus.cancelled;
    } else {
      return _OrderStatus.pending;
    }
  }

  Future<void> _fetchOrders() async {
    if (_filter == _OrderFilter.pending) {
      await _fetchPendingOrderPayments();
      return;
    }
    setState(() => _isLoadingOrders = true);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        if (mounted) {
          setState(() => _isLoadingOrders = false);
        }
        return;
      }

      final queryParams = {
        'limit': 50,
        'page': 1,
        'filter': _getOrderFilterQuery(_filter),
      };

      final url = _getEarningsOrdersUrl(queryParams);
      debugPrint("==================== GET PHARMACY EARNINGS ORDERS ====================");
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyEarningsOrders}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print("==================== GET PHARMACY EARNINGS ORDERS ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyEarningsOrders}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyEarningsOrders,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("====================================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("====================================================================");

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString() == 'true')) {
        List ordersRaw = [];
        final dataField = dataMap['data'];
        if (dataField is Map) {
          final ordersField = dataField['orders'];
          if (ordersField is Map && ordersField['data'] is List) {
            ordersRaw = ordersField['data'] as List;
          } else if (ordersField is List) {
            ordersRaw = ordersField;
          }
        } else if (dataField is List) {
          ordersRaw = dataField;
        }

        final List<_Order> parsedOrders = [];
        for (final item in ordersRaw) {
          if (item is! Map) continue;
          final order = Map<String, dynamic>.from(item);

          String id = order['order_code']?.toString().trim() ?? '';
          if (id.isEmpty) {
            final rawId = order['id'] ?? order['order_id'] ?? order['order_number'];
            if (rawId != null) {
              id = '#ORD-$rawId';
            }
          } else if (!id.startsWith('#')) {
            id = '#$id';
          }

          String whenStr = '';
          final rawDate = order['order_placed_at']?.toString() ??
              order['created_at']?.toString() ??
              order['when']?.toString() ??
              order['date']?.toString() ??
              '';
          if (rawDate.isNotEmpty) {
            final dt = DateTime.tryParse(rawDate);
            if (dt != null) {
              whenStr = formatOrderPlacedAt(dt);
            } else {
              whenStr = rawDate;
            }
          }

          final rawAmount = order['earnings_amount'] ??
              order['amount'] ??
              order['total'] ??
              order['total_amount'];
          final amountStr = _formatAmount(rawAmount);

          final rawStatus = order['earnings_status']?.toString() ??
              order['status']?.toString();
          final statusEnum = _parseOrderStatus(rawStatus);

          parsedOrders.add(
            _Order(
              id: id,
              when: whenStr,
              amount: amountStr,
              status: statusEnum,
              statusLabel: rawStatus,
            ),
          );
        }

        if (mounted) {
          setState(() {
            _orders = parsedOrders;
            _isLoadingOrders = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _orders = [];
            _isLoadingOrders = false;
          });
        }
      }
    } catch (e) {
      debugPrint("==================== GET PHARMACY EARNINGS ORDERS ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("==========================================================================");

      print("==================== GET PHARMACY EARNINGS ORDERS ERROR ====================");
      print("Error: $e");
      print("==========================================================================");

      if (mounted) {
        setState(() {
          _orders = [];
          _isLoadingOrders = false;
        });
      }
    }
  }

  Future<void> _fetchPendingOrderPayments() async {
    setState(() => _isLoadingOrders = true);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        if (mounted) {
          setState(() => _isLoadingOrders = false);
        }
        return;
      }

      final queryParams = {
        'limit': 50,
        'page': 1,
      };

      final url = _getPendingOrderPaymentsUrl(queryParams);
      debugPrint("==================== GET PHARMACY EARNINGS PENDING ORDER PAYMENTS ====================");
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyEarningsPendingOrderPayment}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print("==================== GET PHARMACY EARNINGS PENDING ORDER PAYMENTS ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyEarningsPendingOrderPayment}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyEarningsPendingOrderPayment,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("====================================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("====================================================================");

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString() == 'true')) {
        List rawList = [];
        final dataField = dataMap['data'];
        if (dataField is Map) {
          final paymentsField = dataField['payments'];
          if (paymentsField is Map && paymentsField['data'] is List) {
            rawList = paymentsField['data'] as List;
          } else if (paymentsField is List) {
            rawList = paymentsField;
          } else {
            final ordersField = dataField['orders'];
            if (ordersField is Map && ordersField['data'] is List) {
              rawList = ordersField['data'] as List;
            } else if (ordersField is List) {
              rawList = ordersField;
            }
          }
        } else if (dataField is List) {
          rawList = dataField;
        }

        final List<_Order> parsedOrders = [];
        for (final item in rawList) {
          if (item is! Map) continue;
          final payment = Map<String, dynamic>.from(item);

          String id = payment['order_code']?.toString().trim() ??
              payment['payment_code']?.toString().trim() ??
              payment['transaction_code']?.toString().trim() ??
              '';
          if (id.isEmpty) {
            final rawId = payment['order_id'] ?? payment['id'] ?? payment['payment_id'];
            if (rawId != null) {
              id = '#ORD-$rawId';
            }
          } else if (!id.startsWith('#')) {
            id = '#$id';
          }

          String whenStr = '';
          final rawDate = payment['order_placed_at']?.toString() ??
              payment['created_at']?.toString() ??
              payment['payment_date']?.toString() ??
              payment['date']?.toString() ??
              payment['when']?.toString() ??
              '';
          if (rawDate.isNotEmpty) {
            final dt = DateTime.tryParse(rawDate);
            if (dt != null) {
              whenStr = formatOrderPlacedAt(dt);
            } else {
              whenStr = rawDate;
            }
          }

          final rawAmount = payment['pending_amount'] ??
              payment['earnings_amount'] ??
              payment['amount'] ??
              payment['total'] ??
              payment['total_amount'];
          final amountStr = _formatAmount(rawAmount);

          final rawStatus = payment['status']?.toString() ??
              payment['earnings_status']?.toString() ??
              payment['payment_status']?.toString() ??
              'PENDING';
          final statusEnum = _parseOrderStatus(rawStatus);

          parsedOrders.add(
            _Order(
              id: id,
              when: whenStr,
              amount: amountStr,
              status: statusEnum,
              statusLabel: rawStatus.isNotEmpty ? rawStatus : 'PENDING',
            ),
          );
        }

        if (mounted) {
          setState(() {
            _orders = parsedOrders;
            _isLoadingOrders = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _orders = [];
            _isLoadingOrders = false;
          });
        }
      }
    } catch (e) {
      debugPrint("==================== GET PHARMACY EARNINGS PENDING ORDER PAYMENTS ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("==========================================================================");

      print("==================== GET PHARMACY EARNINGS PENDING ORDER PAYMENTS ERROR ====================");
      print("Error: $e");
      print("==========================================================================");

      if (mounted) {
        setState(() {
          _orders = [];
          _isLoadingOrders = false;
        });
      }
    }
  }

  List<_Order> get _visible {
    if (_filter == _OrderFilter.all || _filter == _OrderFilter.pending) return _orders;
    final status = switch (_filter) {
      _OrderFilter.available => _OrderStatus.available,
      _OrderFilter.pending => _OrderStatus.pending,
      _OrderFilter.cancelled => _OrderStatus.cancelled,
      _OrderFilter.all => _OrderStatus.available,
    };
    return _orders.where((order) => order.status == status).toList();
  }

  Future<void> _fetchPayouts() async {
    setState(() => _isLoadingPayouts = true);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        if (mounted) {
          setState(() => _isLoadingPayouts = false);
        }
        return;
      }

      final queryParams = {
        'limit': 50,
        'page': 1,
      };

      final url = _getPayoutHistoryUrl(queryParams);
      debugPrint("==================== GET PHARMACY EARNINGS PAYOUT HISTORY ====================");
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyEarningsPayoutHistory}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print("==================== GET PHARMACY EARNINGS PAYOUT HISTORY ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyEarningsPayoutHistory}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyEarningsPayoutHistory,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("============================================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("============================================================================");

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString() == 'true')) {
        List rawList = [];
        final dataField = dataMap['data'];
        if (dataField is Map) {
          final payoutsField = dataField['payouts'];
          if (payoutsField is Map && payoutsField['data'] is List) {
            rawList = payoutsField['data'] as List;
          } else if (payoutsField is List) {
            rawList = payoutsField;
          }
        } else if (dataField is List) {
          rawList = dataField;
        }

        final List<_Payout> parsedPayouts = [];
        for (final item in rawList) {
          if (item is! Map) continue;
          final payout = Map<String, dynamic>.from(item);

          String id = payout['transaction_id']?.toString().trim() ??
              payout['transaction_code']?.toString().trim() ??
              payout['payout_code']?.toString().trim() ??
              payout['payout_id']?.toString().trim() ??
              '';
          if (id.isEmpty) {
            final rawId = payout['id'];
            if (rawId != null) {
              id = '#TRX$rawId';
            }
          } else if (!id.startsWith('#')) {
            id = '#$id';
          }

          String whenStr = '';
          final rawDate = payout['paid_at']?.toString() ??
              payout['created_at']?.toString() ??
              payout['payment_date']?.toString() ??
              payout['date']?.toString() ??
              payout['when']?.toString() ??
              '';
          if (rawDate.isNotEmpty) {
            final dt = DateTime.tryParse(rawDate);
            if (dt != null) {
              whenStr = formatOrderPlacedAt(dt);
            } else {
              whenStr = rawDate;
            }
          }

          final rawAmount = payout['amount'] ??
              payout['total'] ??
              payout['payout_amount'] ??
              payout['total_amount'];
          final amountStr = _formatAmount(rawAmount);

          final rawStatus = payout['status']?.toString().trim() ??
              payout['payout_status']?.toString().trim() ??
              'CREDITED';

          parsedPayouts.add(
            _Payout(
              id: id,
              when: whenStr,
              amount: amountStr,
              status: rawStatus.isNotEmpty ? rawStatus : 'CREDITED',
              raw: payout,
            ),
          );
        }

        if (mounted) {
          setState(() {
            _payouts = parsedPayouts;
            _isLoadingPayouts = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _payouts = [];
            _isLoadingPayouts = false;
          });
        }
      }
    } catch (e) {
      debugPrint("==================== GET PHARMACY EARNINGS PAYOUT HISTORY ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("==================================================================================");

      print("==================== GET PHARMACY EARNINGS PAYOUT HISTORY ERROR ====================");
      print("Error: $e");
      print("==================================================================================");

      if (mounted) {
        setState(() {
          _payouts = [];
          _isLoadingPayouts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersTab = _tab == _EarnTab.orders;

    final orderTab = _earningsSummary?['order_amount_tab'] is Map
        ? _earningsSummary!['order_amount_tab'] as Map
        : null;
    final payoutTab = _earningsSummary?['payouts_tab'] is Map
        ? _earningsSummary!['payouts_tab'] as Map
        : null;

    final pendingOrderBal = _formatAmount(orderTab?['pending_order_balance']);
    final availableOrderBal = _formatAmount(orderTab?['available_order_balance']);
    final orderTotalPayout = _formatAmount(orderTab?['total_payout_received']);

    final totalSaleAmount = _formatAmount(payoutTab?['total_sale_amount']);
    final availablePayoutBal = _formatAmount(payoutTab?['available_payout_balance']);
    final payoutTotalReceived = _formatAmount(payoutTab?['total_payout_received']);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE8E0), Color(0xFFFFF4EF), Colors.white],
              stops: [0, 0.22, 0.42],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: RefreshIndicator(
                  color: PharmacyEarningsScreen.orange,
                  onRefresh: () async {
                    await Future.wait([
                      _fetchEarningsSummary(),
                      _tab == _EarnTab.payouts
                          ? _fetchPayouts()
                          : _fetchOrders(),
                    ]);
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      _TabSwitch(
                        orders: ordersTab,
                        onChanged: (orders) {
                          setState(() => _tab = orders ? _EarnTab.orders : _EarnTab.payouts);
                          if (!orders && _payouts.isEmpty && !_isLoadingPayouts) {
                            _fetchPayouts();
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      _SummaryCard(
                        rows: ordersTab
                            ? [
                                ('Pending Order Balance', pendingOrderBal),
                                ('Available Order Balance', availableOrderBal),
                                ('Total Payout Received', orderTotalPayout),
                              ]
                            : [
                                ('Total Sale Amount', totalSaleAmount),
                                ('Available Payout Balance', availablePayoutBal),
                                ('Total Payout Received', payoutTotalReceived),
                              ],
                      ),
                    const SizedBox(height: 14),
                    if (ordersTab) ...[
                      _Filters(
                        selected: _filter,
                        onSelected: (filter) {
                          if (_filter != filter) {
                            setState(() => _filter = filter);
                            _fetchOrders();
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      if (_isLoadingOrders)
                        const Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: PharmacyEarningsScreen.orange,
                            ),
                          ),
                        )
                      else if (_visible.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: NoDataWidget(
                            context,
                            S.of(context).noOrdersFound,
                            "",
                            "lib/assets/images/nodata.png",
                          ),
                        )
                      else
                        for (final order in _visible) ...[
                          _OrderCard(order: order),
                          const SizedBox(height: 12),
                        ],
                    ] else ...[
                      if (_isLoadingPayouts)
                        const Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: PharmacyEarningsScreen.orange,
                            ),
                          ),
                        )
                      else if (_payouts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: NoDataWidget(
                            context,
                            S.of(context).noPayoutsYet,
                            "",
                            "lib/assets/images/nodata.png",
                          ),
                        )
                      else
                        for (final payout in _payouts) ...[
                          _PayoutCard(
                            payout: payout,
                            onDetails: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      PharmacyPayoutDetailsScreen(
                                        payoutId: payout.id,
                                        payout: payout.raw,
                                      ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Earnings',
              style: GoogleFonts.inter(
                color: PharmacyEarningsScreen.ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE0D0)),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: PharmacyEarningsScreen.orange,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabSwitch extends StatelessWidget {
  const _TabSwitch({required this.orders, required this.onChanged});

  final bool orders;
  final ValueChanged<bool> onChanged;

  static const _labels = ['Order Amount', 'Payouts'];

  @override
  Widget build(BuildContext context) {
    final selected = orders ? 0 : 1;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segment = constraints.maxWidth / _labels.length;
          return SizedBox(
            height: 38,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: selected * segment,
                  top: 0,
                  bottom: 0,
                  width: segment,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: PharmacyEarningsScreen.orange,
                      borderRadius: BorderRadius.all(Radius.circular(19)),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_labels.length, (index) {
                    final isSelected = selected == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (index == selected) return;
                          HapticFeedback.selectionClick();
                          onChanged(index == 0);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            style: GoogleFonts.inter(
                              color: isSelected ? Colors.white : const Color(0xFF585D6B),
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                              height: 1.1,
                            ),
                            child: Text(_labels[index]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: CustomPaint(
        painter: const _SummaryBackdropPainter(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    rows[i].$1,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  rows[i].$2,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
        ),
      ),
    );
  }
}

class _SummaryBackdropPainter extends CustomPainter {
  const _SummaryBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFF5317));
    final lighter = Paint()..color = const Color(0xFFFF642E);
    canvas.drawCircle(Offset(size.width * 0.98, size.height * 0.46), size.height * 0.78, lighter);
    canvas.drawCircle(Offset(size.width * -0.02, size.height * 0.9), size.height * 0.58, lighter);
  }

  @override
  bool shouldRepaint(covariant _SummaryBackdropPainter oldDelegate) => false;
}

class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.onSelected});

  final _OrderFilter selected;
  final ValueChanged<_OrderFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (_OrderFilter.all, 'All'),
      (_OrderFilter.available, 'Available'),
      (_OrderFilter.pending, 'Pending'),
      (_OrderFilter.cancelled, 'Cancelled'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in items) ...[
            _Chip(
              label: item.$2,
              selected: selected == item.$1,
              onTap: () => onSelected(item.$1),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? PharmacyEarningsScreen.button : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? PharmacyEarningsScreen.button
                : const Color(0xFFE6E8EC),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _Order order;

  @override
  Widget build(BuildContext context) {
    final status = switch (order.status) {
      _OrderStatus.available => ('AVAILABLE', const Color(0xFF16A34A)),
      _OrderStatus.pending => ('PENDING', const Color(0xFFF59E0B)),
      _OrderStatus.cancelled => ('CANCELLED', const Color(0xFFF01E1E)),
    };
    final statusText = (order.statusLabel != null && order.statusLabel!.trim().isNotEmpty)
        ? order.statusLabel!.toUpperCase()
        : status.$1;
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
                  order.id,
                  style: GoogleFonts.inter(
                    color: PharmacyEarningsScreen.orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (order.when.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        size: 13,
                        color: PharmacyEarningsScreen.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          order.when,
                          style: GoogleFonts.inter(
                            color: PharmacyEarningsScreen.muted,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                statusText,
                style: GoogleFonts.inter(
                  color: status.$2,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                order.amount,
                style: GoogleFonts.inter(
                  color: PharmacyEarningsScreen.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({
    required this.payout,
    required this.onDetails,
  });

  final _Payout payout;
  final VoidCallback onDetails;

  Color _statusColor(String status) {
    final s = status.toUpperCase();
    if (s == 'CREDITED' || s == 'PAID' || s == 'COMPLETED' || s == 'SUCCESS') {
      return const Color(0xFF16A34A);
    } else if (s == 'PENDING' || s == 'PROCESSING') {
      return const Color(0xFFF59E0B);
    } else if (s == 'FAILED' || s == 'CANCELLED' || s == 'REJECTED') {
      return const Color(0xFFF01E1E);
    }
    return const Color(0xFF16A34A);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payout.id,
                      style: GoogleFonts.inter(
                        color: PharmacyEarningsScreen.orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (payout.when.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_outlined,
                            size: 13,
                            color: PharmacyEarningsScreen.muted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              payout.when,
                              style: GoogleFonts.inter(
                                color: PharmacyEarningsScreen.muted,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payout.status.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: _statusColor(payout.status),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    payout.amount,
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onDetails,
              style: OutlinedButton.styleFrom(
                foregroundColor: PharmacyEarningsScreen.orange,
                side: const BorderSide(
                  color: PharmacyEarningsScreen.orange,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'View Details',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
