import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';
import 'package:saimpex_vendor/utils/widgets/no_data_widget.dart';

class PharmacyReceivedPayoutsScreen extends StatefulWidget {
  const PharmacyReceivedPayoutsScreen({super.key});

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF111111);
  static const muted = Color(0xFF918E94);
  static const label = Color(0xFFA8B4C2);

  @override
  State<PharmacyReceivedPayoutsScreen> createState() => _PharmacyReceivedPayoutsScreenState();
}

class _Payout {
  const _Payout({
    required this.id,
    required this.when,
    required this.amount,
    required this.balance,
    this.raw,
  });

  final String id;
  final String when;
  final String amount;
  final String balance;
  final dynamic raw;
}

class _PharmacyReceivedPayoutsScreenState extends State<PharmacyReceivedPayoutsScreen> {
  final _search = TextEditingController();
  List<_Payout> _payouts = [];
  String _totalBalance = '0.00';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchReceivedPayouts();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _getReceivedPayoutsUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    final endpoint = ApiEndPoints.pharmacyReceivedPayouts.trim().replaceFirst(RegExp(r'^/'), '');
    var url = '$base/$endpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}')
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  String _formatBalanceNumber(dynamic val) {
    if (val == null) return '0.00';
    final s = val.toString().replaceAll('MRU', '').replaceAll(',', '').trim();
    if (s.isEmpty) return '0.00';
    final numVal = double.tryParse(s);
    if (numVal != null) {
      final parts = numVal.toStringAsFixed(2).split('.');
      final integerPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$integerPart.${parts[1]}';
    }
    return s;
  }

  String _formatAmount(dynamic val) {
    if (val == null) return '0.00 MRU';
    final s = val.toString().trim();
    if (s.isEmpty) return '0.00 MRU';
    if (s.contains('MRU')) return s;
    final numVal = double.tryParse(s.replaceAll(',', ''));
    if (numVal != null) {
      final parts = numVal.toStringAsFixed(2).split('.');
      final integerPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$integerPart.${parts[1]} MRU';
    }
    return '$s MRU';
  }

  Future<void> _fetchReceivedPayouts() async {
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

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorType = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "3");

      final queryParams = {
        'vendor_type': vendorType,
        'limit': 50,
        'page': 1,
      };

      final url = _getReceivedPayoutsUrl(queryParams);
      debugPrint("==================== GET PHARMACY RECEIVED PAYOUTS ====================");
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyReceivedPayouts}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print("==================== GET PHARMACY RECEIVED PAYOUTS ====================");
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyReceivedPayouts}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyReceivedPayouts,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("=======================================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("=======================================================================");

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
        final dataField = dataMap['data'];

        String balance = '0.00';
        if (dataField is Map) {
          final vendor = dataField['vendor'];
          if (vendor is Map && vendor['current_balance'] != null) {
            balance = _formatBalanceNumber(vendor['current_balance']);
          } else if (dataField['current_balance'] != null) {
            balance = _formatBalanceNumber(dataField['current_balance']);
          } else if (dataField['total_payout_balance'] != null) {
            balance = _formatBalanceNumber(dataField['total_payout_balance']);
          } else if (dataField['balance'] != null) {
            balance = _formatBalanceNumber(dataField['balance']);
          }
        }

        List rawList = [];
        if (dataField is Map) {
          final payoutsField = dataField['received_payouts'] ??
              dataField['payouts'] ??
              dataField['data'];
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

          String id = (payout['transaction_id'] ??
                  payout['transaction_code'] ??
                  payout['payout_code'] ??
                  payout['payout_id'] ??
                  payout['code'])
              ?.toString()
              .trim() ??
              '';
          if (id.isEmpty) {
            final rawId = payout['id'];
            if (rawId != null) {
              id = '#PYT$rawId';
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
              payout['payout_amount'] ??
              payout['total'] ??
              payout['total_amount'] ??
              payout['paid_amount'];
          final amountStr = _formatAmount(rawAmount);

          final rawBalance = payout['balance_after_payout'] ??
              payout['balance'] ??
              payout['current_balance'] ??
              payout['vendor_balance'] ??
              payout['remaining_balance'] ??
              payout['balance_after'];
          final balanceStr = _formatAmount(rawBalance);

          parsedPayouts.add(
            _Payout(
              id: id,
              when: whenStr,
              amount: amountStr,
              balance: balanceStr,
              raw: payout,
            ),
          );
        }

        if (mounted) {
          setState(() {
            _totalBalance = balance;
            _payouts = parsedPayouts;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _payouts = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("==================== GET PHARMACY RECEIVED PAYOUTS ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("============================================================================");

      print("==================== GET PHARMACY RECEIVED PAYOUTS ERROR ====================");
      print("Error: $e");
      print("============================================================================");

      if (mounted) {
        setState(() {
          _payouts = [];
          _isLoading = false;
        });
      }
    }
  }

  List<_Payout> get _visible {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _payouts;
    return _payouts
        .where(
          (payout) =>
              payout.id.toLowerCase().contains(query) ||
              payout.amount.toLowerCase().contains(query) ||
              payout.balance.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final payouts = _visible;
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
              stops: [0, 0.22, 0.4],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: RefreshIndicator(
                  color: PharmacyReceivedPayoutsScreen.orange,
                  onRefresh: _fetchReceivedPayouts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      _BalanceCard(balance: _totalBalance),
                      const SizedBox(height: 18),
                      Text(
                        'History',
                        style: appFont('Inter', 
                          color: const Color(0xFF3F4251),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        style: appFont('Inter', 
                          color: PharmacyReceivedPayoutsScreen.ink,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search amount or Transaction ID',
                          hintStyle: appFont('Inter', 
                            color: const Color(0xFFA9AEB6),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFFA9AEB6)),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: _searchBorder,
                          enabledBorder: _searchBorder,
                          focusedBorder: _searchBorder,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: PharmacyReceivedPayoutsScreen.orange,
                            ),
                          ),
                        )
                      else if (payouts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: NoDataWidget(
                            context,
                            S.of(context).noPayoutsYet,
                            "",
                            "lib/assets/images/nodata.png",
                          ),
                        )
                      else
                        for (final payout in payouts) ...[
                          _PayoutCard(payout: payout),
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

const _searchBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide(color: Color(0xFFE6E8EC)),
);

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
              'Received Payouts',
              style: appFont('Inter', 
                color: const Color(0xFF1C1D1B),
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
                    color: PharmacyReceivedPayoutsScreen.orange,
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final String balance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: CustomPaint(
        painter: const _BalanceBackdropPainter(),
        child: SizedBox(
          height: 115,
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Payout Balance',
                style: appFont('Inter', 
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balance,
                    style: appFont('Inter', 
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'MRU',
                      style: appFont('Inter', 
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _BalanceBackdropPainter extends CustomPainter {
  const _BalanceBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFF5317));
    final lighter = Paint()..color = const Color(0xFFFF642E);
    canvas.drawCircle(Offset(size.width * 0.98, size.height * 0.46), size.height * 0.78, lighter);
    canvas.drawCircle(Offset(size.width * -0.02, size.height * 0.9), size.height * 0.58, lighter);
  }

  @override
  bool shouldRepaint(covariant _BalanceBackdropPainter oldDelegate) => false;
}

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({required this.payout});

  final _Payout payout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payout.id,
                        style: appFont('Inter', 
                          color: PharmacyReceivedPayoutsScreen.orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_outlined,
                            size: 13,
                            color: PharmacyReceivedPayoutsScreen.muted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              payout.when,
                              style: appFont('Inter', 
                                color: PharmacyReceivedPayoutsScreen.muted,
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
                      'AMOUNT',
                      style: appFont('Inter', 
                        color: PharmacyReceivedPayoutsScreen.label,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payout.amount,
                      style: appFont('Inter', 
                        color: PharmacyReceivedPayoutsScreen.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
          ColoredBox(
            color: const Color(0xFFF4F5F7),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Text(
                    'BALANCE AFTER PAYOUT',
                    style: appFont('Inter', 
                      color: PharmacyReceivedPayoutsScreen.label,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    payout.balance,
                    style: appFont('Inter', 
                      color: PharmacyReceivedPayoutsScreen.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
