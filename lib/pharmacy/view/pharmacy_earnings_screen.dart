import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_payout_details_screen.dart';

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
  });

  final String id;
  final String when;
  final String amount;
  final _OrderStatus status;
}

class _PharmacyEarningsScreenState extends State<PharmacyEarningsScreen> {
  _EarnTab _tab = _EarnTab.orders;
  _OrderFilter _filter = _OrderFilter.all;

  static const _orders = [
    _Order(
      id: '#ORD-000246',
      when: 'Feb 07, 2026 11:45 AM, Today',
      amount: '450.00 MRU',
      status: _OrderStatus.available,
    ),
    _Order(
      id: '#ORD-000241',
      when: 'Feb 07, 2026 10:45 AM, Today',
      amount: '550.00 MRU',
      status: _OrderStatus.available,
    ),
    _Order(
      id: '#ORD-000230',
      when: 'Feb 07, 2026 09:45 AM, Today',
      amount: '300.00 MRU',
      status: _OrderStatus.available,
    ),
    _Order(
      id: '#ORD-000225',
      when: 'Feb 07, 2026 09:15 AM, Today',
      amount: '400.00 MRU',
      status: _OrderStatus.pending,
    ),
    _Order(
      id: '#ORD-000202',
      when: 'Feb 07, 2026 08:30 AM, Today',
      amount: '0.00 MRU',
      status: _OrderStatus.cancelled,
    ),
  ];

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
                child: ListView(
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
                          ? const [
                              ('Pending Order Balance', '400.00 MRU'),
                              ('Available Order Balance', '1300.00 MRU'),
                              ('Total Payout Received', '00.00 MRU'),
                            ]
                          : const [
                              ('Total Sale Amount', '1300.00 MRU'),
                              ('Available Payout Balance', '300.00 MRU'),
                              ('Total Payout Received', '00.00 MRU'),
                            ],
                    ),
                    const SizedBox(height: 14),
                    if (ordersTab) ...[
                      _Filters(
                        selected: _filter,
                        onSelected: (filter) =>
                            setState(() => _filter = filter),
                      ),
                      const SizedBox(height: 14),
                      for (final order in _visible) ...[
                        _OrderCard(order: order),
                        const SizedBox(height: 12),
                      ],
                    ] else ...[
                      _PayoutCard(
                        onDetails: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const PharmacyPayoutDetailsScreen(),
                            ),
                          );
                        },
                      ),
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
  const _PayoutCard({required this.onDetails});

  final VoidCallback onDetails;

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
                      '#TRX002',
                      style: GoogleFonts.inter(
                        color: PharmacyEarningsScreen.orange,
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
                          color: PharmacyEarningsScreen.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Feb 07, 2026 10:45 AM, Today',
                          style: GoogleFonts.inter(
                            color: PharmacyEarningsScreen.muted,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
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
                    'CREDITED',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '1000.00 MRU',
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
