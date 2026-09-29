import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/water/controller/earnings_controller.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/view/account/payout_details_view.dart';

enum _EarningStatus { available, pending, cancelled }

class _EarningOrder {
  const _EarningOrder({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.status,
  });

  final String id;
  final String timestamp;
  final String amount;
  final _EarningStatus status;
}

class _PayoutTxn {
  const _PayoutTxn({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.status,
  });

  final String id;
  final String timestamp;
  final String amount;
  final String status;
}

class EarningsView extends StatefulWidget {
  const EarningsView({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EarningsView()),
    );
  }

  @override
  State<EarningsView> createState() => _EarningsViewState();
}

class _EarningsViewState extends State<EarningsView> {
  late final WaterEarningsController controller;

  @override
  void initState() {
    super.initState();
    controller = WaterEarningsController();
  }

  static const orders = [
    _EarningOrder(
      id: '#ORD-000246',
      timestamp: 'Feb 07, 2026 11:45 AM, Today',
      amount: '450.00 MRU',
      status: _EarningStatus.available,
    ),
    _EarningOrder(
      id: '#ORD-000245',
      timestamp: 'Feb 07, 2026 10:20 AM, Today',
      amount: '320.00 MRU',
      status: _EarningStatus.pending,
    ),
    _EarningOrder(
      id: '#ORD-000244',
      timestamp: 'Feb 06, 2026 04:15 PM',
      amount: '180.00 MRU',
      status: _EarningStatus.cancelled,
    ),
    _EarningOrder(
      id: '#ORD-000243',
      timestamp: 'Feb 06, 2026 01:05 PM',
      amount: '275.00 MRU',
      status: _EarningStatus.available,
    ),
    _EarningOrder(
      id: '#ORD-000242',
      timestamp: 'Feb 05, 2026 09:30 AM',
      amount: '510.00 MRU',
      status: _EarningStatus.pending,
    ),
  ];

  static const _payouts = [
    _PayoutTxn(
      id: '#TRX002',
      timestamp: 'Feb 07, 2026 10:45 AM, Today',
      amount: '1000.00 MRU',
      status: 'CREDITED',
    ),
  ];

  List<_EarningOrder> get filteredOrders {
    switch (controller.filterIndex) {
      case 1:
        return orders
            .where((o) => o.status == _EarningStatus.available)
            .toList();
      case 2:
        return orders
            .where((o) => o.status == _EarningStatus.pending)
            .toList();
      case 3:
        return orders
            .where((o) => o.status == _EarningStatus.cancelled)
            .toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WaterEarningsController>(
      init: controller,
      global: false,
      builder: (_) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundMid,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundTop,
                AppColors.backgroundMid,
                Colors.white,
              ],
              stops: [0, 0.2, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    children: [
                      _TabSwitcher(
                        selectedIndex: controller.tabIndex,
                        onSelect: controller.selectTab,
                      ),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: Offset(controller.tabIndex == 1 ? 0.06 : -0.06, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<int>(controller.tabIndex),
                          child: controller.tabIndex == 0
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const _SummaryCard(isPayouts: false),
                                    const SizedBox(height: 14),
                                    _FilterChips(
                                      selectedIndex: controller.filterIndex,
                                      labels: WaterEarningsController.filters,
                                      onSelect: controller.selectFilter,
                                    ),
                                    const SizedBox(height: 14),
                                    for (final order in filteredOrders) ...[
                                      _OrderCard(order: order),
                                      const SizedBox(height: 10),
                                    ],
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const _SummaryCard(isPayouts: true),
                                    const SizedBox(height: 14),
                                    for (final payout in _payouts) ...[
                                      _PayoutCard(payout: payout),
                                      const SizedBox(height: 10),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            const Text(
              'Earnings',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primaryOrange,
                    size: 28,
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

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const tabs = ['Order Amount', 'Payouts'];
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onSelect(i),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            style: TextStyle(
                              color: selectedIndex == i
                                  ? Colors.white
                                  : AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                            child: Text(tabs[i]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.isPayouts});

  final bool isPayouts;

  @override
  Widget build(BuildContext context) {
    final rows = isPayouts
        ? const [
            _SummaryRow(
              label: 'Total Sale Amount',
              value: '1300.00 MRU',
            ),
            _SummaryRow(
              label: 'Available Payout Balance',
              value: '300.00 MRU',
            ),
            _SummaryRow(
              label: 'Total Payout Received',
              value: '00.00 MRU',
            ),
          ]
        : const [
            _SummaryRow(
              label: 'Pending Order Balance',
              value: '400.00 MRU',
            ),
            _SummaryRow(
              label: 'Available Order Balance',
              value: '1300.00 MRU',
            ),
            _SummaryRow(
              label: 'Total Payout Received',
              value: '00.00 MRU',
            ),
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: -10,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                rows[i],
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedIndex,
    required this.labels,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: selectedIndex == i
                      ? AppColors.primaryOrange
                      : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selectedIndex == i
                        ? AppColors.primaryOrange
                        : AppColors.fieldBorder,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: selectedIndex == i
                        ? Colors.white
                        : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _EarningOrder order;

  Color get _statusColor {
    switch (order.status) {
      case _EarningStatus.available:
        return AppColors.inventoryAvailable;
      case _EarningStatus.pending:
        return AppColors.primaryOrange;
      case _EarningStatus.cancelled:
        return AppColors.inventoryOutOfStock;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case _EarningStatus.available:
        return 'AVAILABLE';
      case _EarningStatus.pending:
        return 'PENDING';
      case _EarningStatus.cancelled:
        return 'CANCELLED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                _statusLabel,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.textMuted,
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  order.timestamp,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                order.amount,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
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
  const _PayoutCard({required this.payout});

  final _PayoutTxn payout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: AppColors.textMuted,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            payout.timestamp,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w400,
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
                    payout.status,
                    style: const TextStyle(
                      color: AppColors.inventoryAvailable,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    payout.amount,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () => PayoutDetailsView.open(
                context,
                transactionId: payout.id,
                timestamp: payout.timestamp,
                amount: payout.amount,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryOrange,
                side: const BorderSide(
                  color: AppColors.primaryOrange,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
