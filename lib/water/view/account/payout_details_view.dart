import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

class PayoutDetailsView extends StatelessWidget {
  const PayoutDetailsView({
    super.key,
    required this.transactionId,
    required this.timestamp,
    required this.amount,
  });

  final String transactionId;
  final String timestamp;
  final String amount;

  static void open(
    BuildContext context, {
    required String transactionId,
    required String timestamp,
    required String amount,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PayoutDetailsView(
          transactionId: transactionId,
          timestamp: timestamp,
          amount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      _CreditedTxnCard(
                        id: transactionId,
                        timestamp: timestamp,
                        amount: amount,
                        paymentId: 'ABCD123456',
                        notes:
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
                      ),
                      const SizedBox(height: 12),
                      const _AdjustedOrderCard(
                        id: '#ORD-000246',
                        timestamp: 'Feb 07, 2026 11:45 AM, Today',
                        payoutAmount: '450.00 MRU',
                        orderAmount: '500.00 MRU',
                        reason: 'Lorem ipsum dolor sit amet',
                      ),
                      const SizedBox(height: 12),
                      const _SimpleOrderCard(
                        id: '#ORD-000241',
                        timestamp: 'Feb 07, 2026 10:45 AM, Today',
                        amount: '550.00 MRU',
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

class _CreditedTxnCard extends StatelessWidget {
  const _CreditedTxnCard({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.paymentId,
    required this.notes,
  });

  final String id;
  final String timestamp;
  final String amount;
  final String paymentId;
  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.orangeSoftBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryOrange.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                      id,
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
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
                            timestamp,
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'CREDITED',
                    style: TextStyle(
                      color: AppColors.inventoryAvailable,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Payment ID: $paymentId',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'View Payment Proof',
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Notes: $notes',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdjustedOrderCard extends StatelessWidget {
  const _AdjustedOrderCard({
    required this.id,
    required this.timestamp,
    required this.payoutAmount,
    required this.orderAmount,
    required this.reason,
  });

  final String id;
  final String timestamp;
  final String payoutAmount;
  final String orderAmount;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                      id,
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
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
                            timestamp,
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
                  const Text(
                    'Payout Amount',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    payoutAmount,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Order Amount',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    orderAmount,
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
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.inventoryOutOfStockBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Reason: $reason',
              style: const TextStyle(
                color: Color(0xFFC4452D),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleOrderCard extends StatelessWidget {
  const _SimpleOrderCard({
    required this.id,
    required this.timestamp,
    required this.amount,
  });

  final String id;
  final String timestamp;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
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
                        timestamp,
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
          Text(
            amount,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
