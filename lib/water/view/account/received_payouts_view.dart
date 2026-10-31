import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/water/core/water_api.dart';
import 'package:saimpex_vendor/water/core/water_state_view.dart';

class ReceivedPayoutsView extends StatefulWidget {
  const ReceivedPayoutsView({super.key});

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF111111);
  static const muted = Color(0xFF918E94);
  static const label = Color(0xFFA8B4C2);

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ReceivedPayoutsView()),
    );
  }

  @override
  State<ReceivedPayoutsView> createState() => _ReceivedPayoutsViewState();
}

class _Payout {
  const _Payout({
    required this.id,
    required this.when,
    required this.amount,
    required this.balance,
  });

  final String id;
  final String when;
  final String amount;
  final String balance;
}

class _ReceivedPayoutsViewState extends State<ReceivedPayoutsView> {
  static const _limit = 20;

  final _search = TextEditingController();
  final _scroll = ScrollController();
  final List<_Payout> _payouts = [];
  Timer? _debounce;
  String? _balance;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_hasMore &&
        !_loadingMore &&
        !_loading &&
        _scroll.position.extentAfter < 300) {
      _load(more: true);
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _load();
    });
  }

  /// `GET vendorapp/receivedPayouts` → `data.vendor.current_balance` and
  /// `data.received_payouts` (paginated: `id`, `amount`, `balance_amount`, `paid_at`).
  Future<void> _load({bool more = false}) async {
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
      }
    });
    final page = more ? _page + 1 : 1;
    try {
      await WaterApi.prepare();
      final keyword = _search.text.trim().replaceAll('#', '').replaceFirst(
            RegExp(r'^PYT', caseSensitive: false),
            '',
          );
      final response = await DioClient().get(
        ApiEndPoints.receivedPayouts,
        query: {
          'vendor_type': await WaterApi.vendorType(),
          'limit': _limit,
          'page': page,
          if (keyword.isNotEmpty) 'keyword': keyword,
        },
      );
      final body = response.data;
      if (!WaterApi.isOk(body)) {
        throw WaterApi.message(body) ?? S.current.waterSomethingWentWrong;
      }
      final data = body['data'] is Map ? body['data'] as Map : const {};
      final pageData = data['received_payouts'];
      final rows = WaterApi.pageItems(pageData).map((e) {
        final id = e['id']?.toString() ?? '';
        return _Payout(
          id: id.isEmpty ? '' : '#PYT$id',
          when: WaterApi.formatDateTime(e['paid_at']),
          amount: WaterApi.money(e['amount']),
          balance: WaterApi.money(e['balance_amount']),
        );
      }).toList();
      if (!mounted) return;
      setState(() {
        if (!more) _payouts.clear();
        _payouts.addAll(rows);
        final vendor = data['vendor'];
        if (vendor is Map && vendor['current_balance'] != null) {
          _balance = vendor['current_balance'].toString();
        }
        _page = page;
        _hasMore = WaterApi.hasMore(pageData);
      });
    } catch (e) {
      if (!mounted) return;
      if (more) {
        showToast(context, WaterApi.errorText(e));
      } else {
        setState(() => _error = WaterApi.errorText(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final payouts = _payouts;
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
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: RefreshIndicator(
                  color: ReceivedPayoutsView.orange,
                  onRefresh: _load,
                  child: ListView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    _BalanceCard(balance: _balance),
                    const SizedBox(height: 18),
                    Text(
                      S.of(context).history,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF3F4251),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _search,
                      onChanged: _onSearchChanged,
                      style: GoogleFonts.inter(
                        color: ReceivedPayoutsView.ink,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: S.of(context).searchAmountOrTransactionId,
                        hintStyle: GoogleFonts.inter(
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
                    if (_loading && payouts.isEmpty)
                      const WaterStateView.loading()
                    else if (_error != null && payouts.isEmpty)
                      WaterStateView.error(message: _error!, onRetry: _load)
                    else if (payouts.isEmpty)
                      WaterStateView.empty(
                        title: S.of(context).waterNoPayoutsFound,
                        icon: Icons.account_balance_wallet_outlined,
                      )
                    else ...[
                      for (final payout in payouts) ...[
                        _PayoutCard(payout: payout),
                        const SizedBox(height: 12),
                      ],
                      if (_loadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: ReceivedPayoutsView.orange,
                            ),
                          ),
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
              S.of(context).receivedPayouts,
              style: GoogleFonts.inter(
                color: const Color(0xFF1C1D1B),
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
                    color: ReceivedPayoutsView.orange,
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

  /// `vendor.current_balance`; null until loaded.
  final String? balance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: CustomPaint(
        painter: const _BalanceBackdropPainter(),
        child: SizedBox(
          height: 120,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).totalPayoutBalance,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height:5),
                Row(
                  // Amount + currency stays LTR ("10,140.00 MRU") in every locale.
                  textDirection: TextDirection.ltr,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _amountOnly(balance),
                      style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
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

String _amountOnly(String? value) {
  final n = double.tryParse(value ?? '');
  if (n == null) return '—';
  return NumberFormat('#,##0.00', 'en').format(n);
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
                        style: GoogleFonts.inter(
                          color: ReceivedPayoutsView.orange,
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
                            color: ReceivedPayoutsView.muted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              payout.when,
                              style: GoogleFonts.inter(
                                color: ReceivedPayoutsView.muted,
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
                      S.of(context).amount.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: ReceivedPayoutsView.label,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payout.amount,
                      style: GoogleFonts.inter(
                        color: ReceivedPayoutsView.ink,
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
                    S.of(context).balanceAfterPayout,
                    style: GoogleFonts.inter(
                      color: ReceivedPayoutsView.label,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    payout.balance,
                    style: GoogleFonts.inter(
                      color: ReceivedPayoutsView.ink,
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
