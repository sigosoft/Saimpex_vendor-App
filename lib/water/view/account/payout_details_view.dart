import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class PayoutDetailsView extends StatefulWidget {
  const PayoutDetailsView({
    super.key,
    this.payoutId,
    required this.transactionId,
    required this.timestamp,
    required this.amount,
    this.status = 'CREDITED',
    this.initialPayoutData,
  });

  final String? payoutId;
  final String transactionId;
  final String timestamp;
  final String amount;
  final String status;
  final Map<String, dynamic>? initialPayoutData;

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF1C1D1B);
  static const muted = Color(0xFF918E94);
  static const green = Color(0xFF16A34A);

  static void open(
    BuildContext context, {
    String? payoutId,
    required String transactionId,
    required String timestamp,
    required String amount,
    String status = 'CREDITED',
    Map<String, dynamic>? initialPayoutData,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PayoutDetailsView(
          payoutId: payoutId,
          transactionId: transactionId,
          timestamp: timestamp,
          amount: amount,
          status: status,
          initialPayoutData: initialPayoutData,
        ),
      ),
    );
  }

  @override
  State<PayoutDetailsView> createState() => _PayoutDetailsViewState();
}

class _PayoutOrder {
  const _PayoutOrder({
    required this.id,
    required this.when,
    this.reason,
    this.payout,
    this.orderAmount,
    this.amount,
  });

  final String id;
  final String when;
  final String? reason;
  final String? payout;
  final String? orderAmount;
  final String? amount;
}

class _PayoutDetailsViewState extends State<PayoutDetailsView> {
  bool _isLoading = true;
  Map<String, dynamic>? _payoutDetails;
  List<_PayoutOrder> _relatedOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchPayoutDetail();
  }

  Future<void> _fetchPayoutDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await getSavedObject("token");
      if (token != null &&
          token.toString() != 'null' &&
          token.toString().isNotEmpty) {
        DioClient().updateToken(token);
      }

      final payoutId = widget.payoutId?.toString().trim().replaceAll(RegExp(r'[^0-9]'), '') ??
          widget.initialPayoutData?['id']?.toString() ??
          widget.transactionId.replaceAll(RegExp(r'[^0-9]'), '');

      debugPrint("==================== GET EARNINGS PAYOUT DETAIL ====================");
      debugPrint("Endpoint: ${ApiEndPoints.earningsPayoutDetail}");
      debugPrint("Query ID: $payoutId");

      final response = await DioClient().get(
        ApiEndPoints.earningsPayoutDetail,
        query: {"id": payoutId},
      );

      debugPrint("==================== GET EARNINGS PAYOUT DETAIL RESPONSE ====================");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Data: ${response.data}");

      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final dataField = response.data['data'];
        Map<String, dynamic>? payoutData;
        if (dataField is Map) {
          if (dataField['payout'] is Map) {
            payoutData = Map<String, dynamic>.from(dataField['payout'] as Map);
          } else {
            payoutData = Map<String, dynamic>.from(dataField);
          }
        }

        List rawOrdersList = [];
        if (payoutData != null) {
          if (payoutData['payout_orders'] is List) {
            rawOrdersList = payoutData['payout_orders'] as List;
          } else if (payoutData['orders'] is List) {
            rawOrdersList = payoutData['orders'] as List;
          }
        }
        if (rawOrdersList.isEmpty && dataField is Map) {
          if (dataField['payout_orders'] is List) {
            rawOrdersList = dataField['payout_orders'] as List;
          } else if (dataField['orders'] is List) {
            rawOrdersList = dataField['orders'] as List;
          }
        }

        final List<_PayoutOrder> parsedOrders = [];
        for (final o in rawOrdersList) {
          if (o is! Map) continue;
          final item = Map<String, dynamic>.from(o);

          String orderId = item['order_code']?.toString().trim() ?? '';
          if (orderId.isEmpty) {
            final rawOrderId = item['order_id'] ?? item['id'];
            orderId = rawOrderId != null ? '#ORD-$rawOrderId' : '';
          } else if (!orderId.startsWith('#')) {
            orderId = '#$orderId';
          }

          String whenStr = '';
          final rawDate = item['order_placed_at']?.toString() ??
              item['created_at']?.toString() ??
              payoutData?['payment_date']?.toString() ??
              payoutData?['paid_at']?.toString() ??
              item['date']?.toString() ??
              '';
          if (rawDate.isNotEmpty) {
            final dt = DateTime.tryParse(rawDate);
            if (dt != null) {
              whenStr = formatOrderPlacedAt(dt);
            } else {
              whenStr = rawDate;
            }
          }

          final reason = item['reason']?.toString() ?? item['note']?.toString();
          final rawPayout = item['payout_amount'] ?? item['amount'];
          final rawOrderAmount = item['order_amount'] ?? item['total_amount'] ?? item['total'];

          String? payoutStr;
          String? orderAmountStr;
          String? amountStr;

          if (rawPayout != null && rawOrderAmount != null) {
            payoutStr = '${_formatVal(rawPayout)} MRU';
            orderAmountStr = '${_formatVal(rawOrderAmount)} MRU';
          } else if (rawPayout != null) {
            amountStr = '${_formatVal(rawPayout)} MRU';
          } else if (rawOrderAmount != null) {
            amountStr = '${_formatVal(rawOrderAmount)} MRU';
          } else {
            amountStr = '0.00 MRU';
          }

          parsedOrders.add(
            _PayoutOrder(
              id: orderId,
              when: whenStr.isNotEmpty ? whenStr : widget.timestamp,
              reason: (reason != null && reason.isNotEmpty && reason != 'null') ? reason : null,
              payout: payoutStr,
              orderAmount: orderAmountStr,
              amount: amountStr,
            ),
          );
        }

        if (mounted) {
          setState(() {
            _payoutDetails = payoutData;
            _relatedOrders = parsedOrders;
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
      debugPrint("Error fetching payout detail: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  void _showProofDialog(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).waterPaymentProof,
                      style: appFont('Inter', 
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PayoutDetailsView.ink,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(S.of(context).waterFailedToLoadImage),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionId = _payoutDetails?['transaction_id']?.toString() ??
        _payoutDetails?['transaction_ref']?.toString() ??
        widget.transactionId;

    String timestamp = widget.timestamp;
    final rawDate = _payoutDetails?['paid_at']?.toString() ??
        _payoutDetails?['payment_date']?.toString() ??
        _payoutDetails?['created_at']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      final dt = DateTime.tryParse(rawDate);
      if (dt != null) {
        timestamp = formatOrderPlacedAt(dt);
      }
    }

    final statusStr = _payoutDetails?['status']?.toString().toUpperCase() ?? widget.status.toUpperCase();
    final statusColor = statusStr == 'CANCELLED'
        ? const Color(0xFFEF4444)
        : PayoutDetailsView.green;

    final amountStr = _payoutDetails?['amount'] != null
        ? '${_formatVal(_payoutDetails!['amount'])} MRU'
        : widget.amount;

    final paymentId = _payoutDetails?['transaction_ref']?.toString() ??
        _payoutDetails?['payment_id']?.toString() ??
        _payoutDetails?['reference_number']?.toString() ??
        S.current.waterNotAvailable;

    final notes = _payoutDetails?['payment_note']?.toString() ??
        _payoutDetails?['note']?.toString() ??
        _payoutDetails?['notes']?.toString() ??
        S.current.waterNotAvailable;

    final proofUrl = _payoutDetails?['payment_proof']?.toString() ??
        _payoutDetails?['proof']?.toString() ??
        _payoutDetails?['proof_image']?.toString();

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
              stops: [0, 0.18, 0.36],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE0D0)),
                      ),
                      child: const Icon(Icons.chevron_left_rounded, color: PayoutDetailsView.orange, size: 26),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: PayoutDetailsView.orange,
                  onRefresh: _fetchPayoutDetail,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33FFAE91),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE0D7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFAE91)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transactionId,
                                          style: appFont('Inter', 
                                            color: PayoutDetailsView.orange,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time_outlined, size: 13, color: PayoutDetailsView.muted),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                timestamp,
                                                style: appFont('Inter', 
                                                  color: PayoutDetailsView.muted,
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _statusLabel(context, statusStr),
                                        style: appFont('Inter', 
                                          color: statusColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        amountStr,
                                        style: appFont('Inter', 
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${S.of(context).paymentId}: $paymentId',
                                      style: appFont('Inter', 
                                        color: const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (proofUrl != null && proofUrl.isNotEmpty && proofUrl != 'null') {
                                        _showProofDialog(context, proofUrl);
                                      }
                                    },
                                    child: Text(
                                      S.of(context).viewPaymentProof,
                                      style: appFont('Inter', 
                                        color: PayoutDetailsView.orange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                        decorationColor: PayoutDetailsView.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _ExpandableLine(
                                title: S.of(context).notes,
                                text: '${S.of(context).notes}: $notes',
                                style: appFont('Inter', 
                                  color: const Color(0xFF9AA3B2),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: PayoutDetailsView.orange,
                            ),
                          ),
                        )
                      else if (_relatedOrders.isEmpty)
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
                                  style: appFont('Inter', 
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: PayoutDetailsView.ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  S.of(context).waterPayoutOrdersAppearHere,
                                  textAlign: TextAlign.center,
                                  style: appFont('Inter', 
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: PayoutDetailsView.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        for (final order in _relatedOrders) ...[
                          _DetailOrderCard(
                            id: order.id,
                            when: order.when,
                            reason: order.reason,
                            payout: order.payout,
                            orderAmount: order.orderAmount,
                            amount: order.amount,
                          ),
                          const SizedBox(height: 12),
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

String _statusLabel(BuildContext context, String status) {
  switch (status.trim().toUpperCase()) {
    case 'CREDITED':
      return S.of(context).credited.toUpperCase();
    case 'CANCELLED':
      return S.of(context).cancelled.toUpperCase();
    case 'PENDING':
      return S.of(context).pending.toUpperCase();
    default:
      return status;
  }
}

class _DetailOrderCard extends StatelessWidget {
  const _DetailOrderCard({
    required this.id,
    required this.when,
    this.reason,
    this.payout,
    this.orderAmount,
    this.amount,
  });

  final String id;
  final String when;
  final String? reason;
  final String? payout;
  final String? orderAmount;
  final String? amount;

  @override
  Widget build(BuildContext context) {
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
                  id,
                  style: appFont('Inter', 
                    color: PayoutDetailsView.orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined, size: 13, color: PayoutDetailsView.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        when,
                        style: appFont('Inter', 
                          color: PayoutDetailsView.muted,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (reason != null) ...[
                  const SizedBox(height: 10),
                  _ExpandableLine(
                    title: S.of(context).reasonLabel,
                    text: S.of(context).reasonColonLabel(reason!),
                    fill: const Color(0xFFFDECEC),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    style: appFont('Inter', 
                      color: const Color(0xFFE24B4B),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (amount != null)
            Text(
              amount!,
              style: appFont('Inter', 
                color: PayoutDetailsView.ink,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _amountLine(S.of(context).waterPayoutAmount, payout!),
                const SizedBox(height: 10),
                _amountLine(S.of(context).orderAmount, orderAmount!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _amountLine(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: appFont('Inter', 
            color: const Color(0xFF9AA3B2),
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: appFont('Inter', 
            color: PayoutDetailsView.ink,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ExpandableLine extends StatelessWidget {
  const _ExpandableLine({
    required this.title,
    required this.text,
    required this.style,
    this.fill,
    this.padding,
  });

  final String title;
  final String text;
  final TextStyle style;
  final Color? fill;
  final EdgeInsets? padding;

  void _open(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 12,
          shadowColor: const Color(0x33000000),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: appFont('Inter', 
                    color: const Color(0xFF111111),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(text, style: style),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: PayoutDetailsView.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      MaterialLocalizations.of(context).closeButtonLabel,
                      style: appFont('Inter', fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final line = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    final child = fill == null
        ? line
        : Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: line,
          );
    return GestureDetector(
      onTap: () => _open(context),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
