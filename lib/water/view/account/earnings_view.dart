import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/widgets/balance_adjustments_section.dart';
import 'package:saimpex_vendor/water/view/account/payout_details_view.dart';

class EarningsView extends StatefulWidget {
  const EarningsView({super.key});

  static const orange = Color(0xFFFF5216);
  static const button = Color(0xFFFF5317);
  static const ink = Color(0xFF1C1D1B);
  static const muted = Color(0xFF918E94);

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EarningsView()),
    );
  }

  @override
  State<EarningsView> createState() => _EarningsViewState();
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
  });

  final String id;
  final String when;
  final String amount;
  final _OrderStatus status;
}

class _Payout {
  const _Payout({
    required this.id,
    required this.rawId,
    required this.when,
    required this.amount,
    required this.status,
    this.raw,
  });

  final String id;
  final String rawId;
  final String when;
  final String amount;
  final String status;
  final Map<String, dynamic>? raw;
}

class _EarningsViewState extends State<EarningsView> {
  _EarnTab _tab = _EarnTab.orders;
  _OrderFilter _filter = _OrderFilter.all;

  bool _isLoadingSummary = true;
  bool _isLoadingOrders = true;
  bool _isLoadingPayouts = true;
  Map<String, dynamic>? _earningsSummary;
  List<_Order> _orders = [];
  List<_Payout> _payouts = [];
  final GlobalKey<BalanceAdjustmentsSectionState> _adjustmentsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchEarningsSummary();
    _fetchOrders();
    _fetchPayouts();
  }

  Future<void> _fetchEarningsSummary() async {
    try {
      final token = await getSavedObject("token");
      if (token != null &&
          token.toString() != 'null' &&
          token.toString().isNotEmpty) {
        DioClient().updateToken(token);
      }

      debugPrint("==================== GET EARNINGS SUMMARY ====================");
      debugPrint("Endpoint: ${ApiEndPoints.earningsSummary}");

      final response = await DioClient().get(ApiEndPoints.earningsSummary);

      debugPrint("==================== GET EARNINGS SUMMARY RESPONSE ====================");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Data: ${response.data}");

      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        if (mounted) {
          setState(() {
            _earningsSummary = response.data['data'] is Map
                ? Map<String, dynamic>.from(response.data['data'])
                : null;
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
      debugPrint("Error fetching earnings summary: $e");
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
      }
    }
  }

  String get _filterQuery {
    switch (_filter) {
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

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoadingOrders = true;
    });

    try {
      final token = await getSavedObject("token");
      if (token != null &&
          token.toString() != 'null' &&
          token.toString().isNotEmpty) {
        DioClient().updateToken(token);
      }

      debugPrint("==================== GET EARNINGS ORDERS ====================");
      debugPrint("Endpoint: ${ApiEndPoints.earningsOrders}");
      debugPrint("Filter: $_filterQuery");

      final response = await DioClient().get(
        ApiEndPoints.earningsOrders,
        query: {"limit": 50, "filter": _filterQuery},
      );

      debugPrint("==================== GET EARNINGS ORDERS RESPONSE ====================");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Data: ${response.data}");

      List<dynamic> ordersRaw = [];
      if (response.data is Map) {
        final dataField = response.data['data'];
        if (dataField is Map) {
          final ordersField = dataField['orders'];
          if (ordersField is Map && ordersField['data'] is List) {
            ordersRaw = ordersField['data'] as List;
          } else if (ordersField is List) {
            ordersRaw = ordersField;
          } else if (dataField['data'] is List) {
            ordersRaw = dataField['data'] as List;
          }
        } else if (dataField is List) {
          ordersRaw = dataField;
        } else if (response.data['orders'] is List) {
          ordersRaw = response.data['orders'] as List;
        }
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
          } else {
            id = '#ORD-000000';
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
        final amountStr = '${_formatVal(rawAmount)} MRU';

        final rawStatus = order['earnings_status']?.toString() ??
            order['status']?.toString();
        final statusEnum = _parseOrderStatus(rawStatus);

        parsedOrders.add(
          _Order(
            id: id,
            when: whenStr,
            amount: amountStr,
            status: statusEnum,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _orders = parsedOrders;
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching earnings orders: $e");
      if (mounted) {
        setState(() {
          _orders = [];
          _isLoadingOrders = false;
        });
      }
    }
  }

  Future<void> _fetchPayouts() async {
    setState(() {
      _isLoadingPayouts = true;
    });

    try {
      final token = await getSavedObject("token");
      if (token != null &&
          token.toString() != 'null' &&
          token.toString().isNotEmpty) {
        DioClient().updateToken(token);
      }

      debugPrint("==================== GET EARNINGS PAYOUT HISTORY ====================");
      debugPrint("Endpoint: ${ApiEndPoints.earningsPayoutHistory}");

      final response = await DioClient().get(
        ApiEndPoints.earningsPayoutHistory,
        query: {"limit": 50},
      );

      debugPrint("==================== GET EARNINGS PAYOUT HISTORY RESPONSE ====================");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Data: ${response.data}");

      List<dynamic> payoutsRaw = [];
      if (response.data is Map) {
        final dataField = response.data['data'];
        if (dataField is Map) {
          final payoutsField = dataField['payouts'];
          if (payoutsField is Map && payoutsField['data'] is List) {
            payoutsRaw = payoutsField['data'] as List;
          } else if (payoutsField is List) {
            payoutsRaw = payoutsField;
          } else if (dataField['data'] is List) {
            payoutsRaw = dataField['data'] as List;
          }
        } else if (dataField is List) {
          payoutsRaw = dataField;
        } else if (response.data['payouts'] is List) {
          payoutsRaw = response.data['payouts'] as List;
        }
      }

      final List<_Payout> parsedPayouts = [];
      for (final item in payoutsRaw) {
        if (item is! Map) continue;
        final payout = Map<String, dynamic>.from(item);

        final rawId = payout['id']?.toString() ?? '';
        String id = payout['transaction_id']?.toString().trim() ??
            payout['transaction_ref']?.toString().trim() ??
            payout['payout_code']?.toString().trim() ??
            '';
        if (id.isEmpty) {
          id = rawId.isNotEmpty ? '#TRX$rawId' : '#TRX000';
        } else if (!id.startsWith('#')) {
          id = '#$id';
        }

        String whenStr = '';
        final rawDate = payout['paid_at']?.toString() ??
            payout['payment_date']?.toString() ??
            payout['created_at']?.toString() ??
            payout['date']?.toString() ??
            '';
        if (rawDate.isNotEmpty) {
          final dt = DateTime.tryParse(rawDate);
          if (dt != null) {
            whenStr = formatOrderPlacedAt(dt);
          } else {
            whenStr = rawDate;
          }
        }

        final rawAmount = payout['amount'] ?? payout['payout_amount'];
        final amountStr = '${_formatVal(rawAmount)} MRU';
        final statusStr = payout['status']?.toString() ?? 'CREDITED';

        parsedPayouts.add(
          _Payout(
            id: id,
            rawId: rawId,
            when: whenStr,
            amount: amountStr,
            status: statusStr,
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
    } catch (e) {
      debugPrint("Error fetching earnings payouts: $e");
      if (mounted) {
        setState(() {
          _payouts = [];
          _isLoadingPayouts = false;
        });
      }
    }
  }

  _OrderStatus _parseOrderStatus(String? status) {
    final s = status?.toString().trim().toLowerCase() ?? '';
    if (s.contains('avail') || s.contains('credit') || s.contains('complete') || s.contains('deliver')) {
      return _OrderStatus.available;
    } else if (s.contains('cancel') || s.contains('reject')) {
      return _OrderStatus.cancelled;
    } else {
      return _OrderStatus.pending;
    }
  }

  String _formatVal(dynamic val) {
    if (val == null) return '0.00';
    final str = val.toString().trim();
    if (str.isEmpty || str == 'null') return '0.00';
    final d = double.tryParse(str.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (d != null) {
      return d.toStringAsFixed(2);
    }
    return str;
  }

  List<_Order> get _visible {
    if (_filter == _OrderFilter.all) return _orders;
    final status = switch (_filter) {
      _OrderFilter.available => _OrderStatus.available,
      _OrderFilter.pending => _OrderStatus.pending,
      _OrderFilter.cancelled => _OrderStatus.cancelled,
      _OrderFilter.all => _OrderStatus.available,
    };
    return _orders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ordersTab = _tab == _EarnTab.orders;
    final orderTab = _earningsSummary?['order_amount_tab'] is Map
        ? _earningsSummary!['order_amount_tab'] as Map
        : null;
    final payoutsTab = _earningsSummary?['payouts_tab'] is Map
        ? _earningsSummary!['payouts_tab'] as Map
        : null;

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
              stops: [0, 0.22, 0.42],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: RefreshIndicator(
                  color: EarningsView.orange,
                  onRefresh: () async {
                    await Future.wait([
                      _fetchEarningsSummary(),
                      _fetchOrders(),
                      _fetchPayouts(),
                      if (_adjustmentsKey.currentState != null)
                        _adjustmentsKey.currentState!.refresh(),
                    ]);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      _TabSwitch(
                        orders: ordersTab,
                        onChanged: (orders) {
                          setState(() => _tab = orders ? _EarnTab.orders : _EarnTab.payouts);
                        },
                      ),
                      const SizedBox(height: 14),
                      _SummaryCard(
                        rows: ordersTab
                            ? [
                                (S.of(context).pendingOrderBalance, '${_formatVal(orderTab?['pending_order_balance'])} MRU'),
                                (S.of(context).availableOrderBalance, '${_formatVal(orderTab?['available_order_balance'])} MRU'),
                                (S.of(context).totalPayoutReceived, '${_formatVal(orderTab?['total_payout_received'])} MRU'),
                              ]
                            : [
                                (S.of(context).totalSaleAmount, '${_formatVal(payoutsTab?['total_sale_amount'] ?? '1300.00')} MRU'),
                                (S.of(context).availablePayoutBalance, '${_formatVal(payoutsTab?['available_payout_balance'] ?? '300.00')} MRU'),
                                (S.of(context).totalPayoutReceived, '${_formatVal(payoutsTab?['total_payout_received'] ?? '00.00')} MRU'),
                              ],
                      ),
                      const SizedBox(height: 14),
                      if (ordersTab) ...[
                        _Filters(
                          selected: _filter,
                          onSelected: (filter) {
                            setState(() => _filter = filter);
                            _fetchOrders();
                          },
                        ),
                        const SizedBox(height: 14),
                        if (_isLoadingOrders)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: EarningsView.orange,
                              ),
                            ),
                          )
                        else if (_visible.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'lib/assets/images/nodata.png',
                                    height: 120,
                                    width: 140,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    S.of(context).noOrdersFound,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: EarningsView.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    S.of(context).waterOrdersAppearHere,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: EarningsView.muted,
                                    ),
                                  ),
                                ],
                              ),
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
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: EarningsView.orange,
                              ),
                            ),
                          )
                        else if (_payouts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'lib/assets/images/nodata.png',
                                    height: 120,
                                    width: 140,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    S.of(context).waterNoPayoutsFound,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: EarningsView.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    S.of(context).waterPayoutHistoryAppearHere,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: EarningsView.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          for (final payout in _payouts) ...[
                            _PayoutCard(
                              payout: payout,
                              onDetails: () {
                                PayoutDetailsView.open(
                                  context,
                                  payoutId: payout.rawId,
                                  transactionId: payout.id,
                                  timestamp: payout.when,
                                  amount: payout.amount,
                                  status: payout.status,
                                  initialPayoutData: payout.raw,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        BalanceAdjustmentsSection(
                          key: _adjustmentsKey,
                          accent: EarningsView.orange,
                        ),
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
              S.of(context).earnings,
              style: GoogleFonts.inter(
                color: EarningsView.ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
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
                    color: EarningsView.orange,
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

  @override
  Widget build(BuildContext context) {
    final labels = [S.of(context).orderAmount, S.of(context).payouts];
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
          final segment = constraints.maxWidth / labels.length;
          return SizedBox(
            height: 38,
            child: Stack(
              children: [
                AnimatedPositionedDirectional(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  start: selected * segment,
                  top: 0,
                  bottom: 0,
                  width: segment,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: EarningsView.orange,
                      borderRadius: BorderRadius.all(Radius.circular(19)),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(labels.length, (index) {
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
                            child: Text(labels[index]),
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
    final items = [
      (_OrderFilter.all, S.of(context).all),
      (_OrderFilter.available, S.of(context).available),
      (_OrderFilter.pending, S.of(context).pending),
      (_OrderFilter.cancelled, S.of(context).cancelled),
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
          color: selected ? EarningsView.button : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected ? EarningsView.button : const Color(0xFFE6E8EC),
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
      _OrderStatus.available => (S.of(context).available.toUpperCase(), const Color(0xFF16A34A)),
      _OrderStatus.pending => (S.of(context).pending.toUpperCase(), const Color(0xFFF59E0B)),
      _OrderStatus.cancelled => (S.of(context).cancelled.toUpperCase(), const Color(0xFFF01E1E)),
    };
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
                    color: EarningsView.orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined, size: 13, color: EarningsView.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        order.when,
                        style: GoogleFonts.inter(
                          color: EarningsView.muted,
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
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                status.$1,
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
                  color: EarningsView.ink,
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

String _payoutStatusLabel(BuildContext context, String status) {
  switch (status.trim().toUpperCase()) {
    case 'CREDITED':
      return S.of(context).credited.toUpperCase();
    case 'CANCELLED':
      return S.of(context).cancelled.toUpperCase();
    case 'PENDING':
      return S.of(context).pending.toUpperCase();
    case 'AVAILABLE':
      return S.of(context).available.toUpperCase();
    default:
      return status.toUpperCase();
  }
}

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({
    required this.payout,
    required this.onDetails,
  });

  final _Payout payout;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final statusColor = payout.status.toUpperCase() == 'CANCELLED'
        ? const Color(0xFFEF4444)
        : const Color(0xFF16A34A);

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
                        color: EarningsView.orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined, size: 13, color: EarningsView.muted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            payout.when,
                            style: GoogleFonts.inter(
                              color: EarningsView.muted,
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
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _payoutStatusLabel(context, payout.status),
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    payout.amount,
                    style: GoogleFonts.inter(
                      color: statusColor,
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
                foregroundColor: EarningsView.orange,
                side: const BorderSide(color: EarningsView.orange, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                S.of(context).viewDetails,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
