import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final _search = TextEditingController();

  static const _payouts = [
    _Payout(
      id: '#PYT240',
      when: 'Feb 07, 2026 10:45 AM, Today',
      amount: '400.00 MRU',
      balance: '1,000.00 MRU',
    ),
    _Payout(
      id: '#PYT240',
      when: 'Feb 07, 2026 10:45 AM, Today',
      amount: '400.00 MRU',
      balance: '1,000.00 MRU',
    ),
    _Payout(
      id: '#PYT240',
      when: 'Feb 07, 2026 10:45 AM, Today',
      amount: '400.00 MRU',
      balance: '1,000.00 MRU',
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    const _BalanceCard(),
                    const SizedBox(height: 18),
                    Text(
                      'History',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF3F4251),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(
                        color: ReceivedPayoutsView.ink,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search amount or Transaction ID',
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
                    for (final payout in payouts) ...[
                      _PayoutCard(payout: payout),
                      const SizedBox(height: 12),
                    ],
                  ],
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
              style: GoogleFonts.inter(
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
  const _BalanceCard();

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
                  'Total Payout Balance',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height:5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '10,140.00',
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
                      'AMOUNT',
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
                    'BALANCE AFTER PAYOUT',
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
