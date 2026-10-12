import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/widgets/no_data_widget.dart';

class PharmacyPayoutDetailsScreen extends StatefulWidget {
  const PharmacyPayoutDetailsScreen({
    super.key,
    this.payoutId,
    this.payout,
  });

  final String? payoutId;
  final dynamic payout;

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF1C1D1B);
  static const muted = Color(0xFF918E94);
  static const green = Color(0xFF16A34A);

  @override
  State<PharmacyPayoutDetailsScreen> createState() =>
      _PharmacyPayoutDetailsScreenState();
}

class _PharmacyPayoutDetailsScreenState
    extends State<PharmacyPayoutDetailsScreen> {
  Map<String, dynamic>? _payoutDetails;
  List<Map<String, dynamic>> _relatedOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  String _getPayoutDetailsUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    final endpoint = ApiEndPoints.pharmacyEarningsPayoutDetails.trim().replaceFirst(RegExp(r'^/'), '');
    final uri = Uri.parse('$base/$endpoint');
    if (query != null && query.isNotEmpty) {
      return uri.replace(queryParameters: query.map((k, v) => MapEntry(k, v.toString()))).toString();
    }
    return uri.toString();
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

  Color _statusColor(String status) {
    final s = status.toUpperCase();
    if (s == 'CREDITED' || s == 'PAID' || s == 'COMPLETED' || s == 'SUCCESS' || s == 'AVAILABLE') {
      return PharmacyPayoutDetailsScreen.green;
    } else if (s == 'PENDING' || s == 'PROCESSING') {
      return const Color(0xFFF59E0B);
    } else if (s == 'FAILED' || s == 'CANCELLED' || s == 'REJECTED') {
      return const Color(0xFFF01E1E);
    }
    return PharmacyPayoutDetailsScreen.green;
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      dynamic idVal = widget.payout is Map ? widget.payout['id'] : null;
      if (idVal == null && widget.payoutId != null) {
        final digits = widget.payoutId!.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.isNotEmpty) {
          idVal = digits;
        } else {
          idVal = widget.payoutId;
        }
      }
      final payoutId = idVal?.toString() ?? "1";

      final queryParams = {"id": payoutId};
      final url = _getPayoutDetailsUrl(queryParams);
      debugPrint("==================== GET PHARMACY EARNINGS PAYOUT DETAILS ====================");
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyEarningsPayoutDetails}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print("==================== GET PHARMACY EARNINGS PAYOUT DETAILS ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyEarningsPayoutDetails}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyEarningsPayoutDetails,
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
        Map<String, dynamic>? payoutData;
        final dataField = dataMap['data'];
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

        final List<Map<String, dynamic>> parsedOrders = [];
        for (final o in rawOrdersList) {
          if (o is! Map) continue;
          final item = Map<String, dynamic>.from(o);

          String orderId = item['order_code']?.toString().trim() ?? '';
          if (orderId.isEmpty) {
            final rawOrderId = item['order_id'] ?? item['id'];
            if (rawOrderId != null) {
              orderId = '#ORD-$rawOrderId';
            }
          } else if (!orderId.startsWith('#')) {
            orderId = '#$orderId';
          }

          String orderWhen = '';
          final rawOrderDate = item['order_placed_at']?.toString() ??
              item['created_at']?.toString() ??
              item['date']?.toString() ??
              payoutData?['payment_date']?.toString() ??
              payoutData?['paid_at']?.toString() ??
              '';
          if (rawOrderDate.isNotEmpty) {
            final dt = DateTime.tryParse(rawOrderDate);
            if (dt != null) {
              orderWhen = formatOrderPlacedAt(dt);
            } else {
              orderWhen = rawOrderDate;
            }
          }

          String? reason = item['reason']?.toString() ??
              item['cancellation_reason']?.toString() ??
              item['note']?.toString();

          String? payoutAmount = item['payout_amount'] != null
              ? _formatAmount(item['payout_amount'])
              : null;
          String? orderAmount = item['order_amount'] != null
              ? _formatAmount(item['order_amount'])
              : null;
          String? amount;
          if (payoutAmount == null && orderAmount == null) {
            amount = _formatAmount(item['amount'] ?? item['total'] ?? '0.00');
          }

          parsedOrders.add({
            'id': orderId,
            'when': orderWhen,
            'reason': reason,
            'payout': payoutAmount,
            'orderAmount': orderAmount,
            'amount': amount,
          });
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
      debugPrint("==================== GET PHARMACY EARNINGS PAYOUT DETAILS ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("==================================================================================");

      print("==================== GET PHARMACY EARNINGS PAYOUT DETAILS ERROR ====================");
      print("Error: $e");
      print("==================================================================================");

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trxId = _payoutDetails?['transaction_ref']?.toString().trim() ??
        _payoutDetails?['transaction_code']?.toString().trim() ??
        _payoutDetails?['transaction_id']?.toString().trim() ??
        _payoutDetails?['payout_code']?.toString().trim() ??
        (widget.payout is Map
            ? (widget.payout['transaction_id'] ?? widget.payout['id'])?.toString().trim()
            : widget.payoutId?.toString().trim()) ??
        '';
    final displayTrxId = trxId.isNotEmpty
        ? (trxId.startsWith('#') ? trxId : '#$trxId')
        : '#TRX';

    String dateStr = '';
    final rawDate = _payoutDetails?['paid_at']?.toString() ??
        _payoutDetails?['payment_date']?.toString() ??
        _payoutDetails?['created_at']?.toString() ??
        (widget.payout is Map
            ? (widget.payout['paid_at'] ?? widget.payout['created_at'])?.toString()
            : null) ??
        '';
    if (rawDate.isNotEmpty) {
      final dt = DateTime.tryParse(rawDate);
      if (dt != null) {
        dateStr = formatOrderPlacedAt(dt);
      } else {
        dateStr = rawDate;
      }
    }

    final statusStr = (_payoutDetails?['status'] ??
            _payoutDetails?['payout_status'] ??
            (widget.payout is Map ? widget.payout['status'] : null) ??
            'CREDITED')
        .toString()
        .trim();

    final amountStr = _formatAmount(
      _payoutDetails?['amount'] ??
          _payoutDetails?['total'] ??
          _payoutDetails?['payout_amount'] ??
          (widget.payout is Map ? widget.payout['amount'] : null),
    );

    final paymentId = _payoutDetails?['payment_id']?.toString().trim() ??
        _payoutDetails?['transaction_ref']?.toString().trim() ??
        _payoutDetails?['transaction_id']?.toString().trim() ??
        '';

    final notes = _payoutDetails?['payment_note']?.toString().trim() ??
        _payoutDetails?['note']?.toString().trim() ??
        _payoutDetails?['notes']?.toString().trim() ??
        '';

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
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE0D0)),
                      ),
                      child: const Icon(Icons.chevron_left_rounded, color: PharmacyPayoutDetailsScreen.orange, size: 26),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: PharmacyPayoutDetailsScreen.orange,
                  onRefresh: _fetchDetails,
                  child: ListView(
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
                            color: const Color.fromARGB(255, 255, 226, 219),
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
                                          displayTrxId,
                                          style: GoogleFonts.inter(
                                            color: PharmacyPayoutDetailsScreen.orange,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (dateStr.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time_outlined, size: 13, color: PharmacyPayoutDetailsScreen.muted),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  dateStr,
                                                  style: GoogleFonts.inter(
                                                    color: PharmacyPayoutDetailsScreen.muted,
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        statusStr.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          color: _statusColor(statusStr),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        amountStr,
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
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Payment ID: ${paymentId.isNotEmpty ? paymentId : 'N/A'}',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'View Payment Proof',
                                    style: GoogleFonts.inter(
                                      color: PharmacyPayoutDetailsScreen.orange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                      decorationColor: PharmacyPayoutDetailsScreen.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _ExpandableLine(
                                title: 'Notes',
                                text: 'Notes: ${notes.isNotEmpty ? notes : 'N/A'}',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF9AA3B2),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: PharmacyPayoutDetailsScreen.orange,
                            ),
                          ),
                        )
                      else if (_relatedOrders.isEmpty)
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
                        for (final o in _relatedOrders) ...[
                          const SizedBox(height: 12),
                          _DetailOrderCard(
                            id: o['id'] as String,
                            when: o['when'] as String,
                            reason: o['reason'] as String?,
                            payout: o['payout'] as String?,
                            orderAmount: o['orderAmount'] as String?,
                            amount: o['amount'] as String?,
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
                  style: GoogleFonts.inter(
                    color: PharmacyPayoutDetailsScreen.orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined, size: 13, color: PharmacyPayoutDetailsScreen.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        when,
                        style: GoogleFonts.inter(
                          color: PharmacyPayoutDetailsScreen.muted,
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
                    title: 'Reason',
                    text: 'Reason: $reason',
                    fill: const Color(0xFFFDECEC),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
                color: PharmacyPayoutDetailsScreen.ink,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _amountLine('Payout Amount', payout!),
                const SizedBox(height: 10),
                _amountLine('Order Amount', orderAmount!),
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
          style: GoogleFonts.inter(
            color: const Color(0xFF9AA3B2),
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            color: PharmacyPayoutDetailsScreen.ink,
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
                  style: GoogleFonts.inter(
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
                      backgroundColor: PharmacyPayoutDetailsScreen.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
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
    final text = Text(
      this.text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    final child = fill == null
        ? text
        : Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: text,
          );
    return GestureDetector(
      onTap: () => _open(context),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
