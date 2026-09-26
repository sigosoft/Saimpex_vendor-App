import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

class StoreProfileView extends StatelessWidget {
  const StoreProfileView({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const StoreProfileView()),
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
              stops: [0, 0.18, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    children: [
                      const _SectionTitle('Store Details'),
                      const SizedBox(height: 10),
                      const _InfoCard(
                        rows: [
                          _InfoRowData(label: 'Name', value: 'PureLife Water Co.'),
                          _InfoRowData(label: 'Owner', value: 'Salman'),
                          _InfoRowData(label: 'ID', value: '1'),
                          _InfoRowData(label: 'Contact', value: '+22241518211'),
                          _InfoRowData(label: 'Email', value: 'Purelife@.com'),
                          _InfoRowData(
                            label: 'Status',
                            value: 'ACTIVE',
                            isStatus: true,
                          ),
                          _InfoRowData(
                            label: 'Address',
                            value: 'Store Block 5, Mauritania',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _SectionTitle('Bank Details'),
                      const SizedBox(height: 10),
                      const _InfoCard(
                        rows: [
                          _InfoRowData(label: 'Holder Name', value: 'Salman H'),
                          _InfoRowData(
                            label: 'IBAN Number',
                            value: '121236218936189111',
                          ),
                          _InfoRowData(
                            label: 'SWIFT Code',
                            value: 'TESTMRMR001',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _SectionTitle('Registration Details'),
                      const SizedBox(height: 10),
                      const _InfoCard(
                        rows: [
                          _InfoRowData(
                            label: 'Reg. Number',
                            value: 'REST11MAUR13',
                          ),
                          _InfoRowData(
                            label: 'Reg. Date',
                            value: 'Dec 7, 2025',
                          ),
                          _InfoRowData(
                            label: 'TIN/NIF Number',
                            value: 'MR-TIN-127444',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _SectionTitle('Payment Details'),
                      const SizedBox(height: 10),
                      const _InfoCard(
                        rows: [
                          _InfoRowData(label: 'Commission %', value: '5.00%'),
                          _InfoRowData(
                            label: 'Total Profit',
                            value: '0 MRU',
                            valueBold: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _SectionTitle('Owner Identity Proof'),
                      const SizedBox(height: 10),
                      const _EmptyDocumentCard(),
                      const SizedBox(height: 18),
                      const _SectionTitle('Certificate'),
                      const SizedBox(height: 10),
                      const _EmptyDocumentCard(),
                      const SizedBox(height: 18),
                      const _ReviewsHeader(),
                      const SizedBox(height: 10),
                      const _ReviewCard(),
                      const SizedBox(height: 12),
                      const _ReviewCard(),
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
              'Store Profile',
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
                    border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.35),
                    ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }
}

class _InfoRowData {
  const _InfoRowData({
    required this.label,
    required this.value,
    this.isStatus = false,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final bool isStatus;
  final bool valueBold;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _InfoRow(data: rows[i]),
            if (i < rows.length - 1)
              const Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.data});

  final _InfoRowData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              data.label,
              style: const TextStyle(
                color: AppColors.textLabel,
                fontWeight: FontWeight.w500,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: data.isStatus
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inventoryAvailableBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data.value,
                        style: const TextStyle(
                          color: AppColors.inventoryAvailable,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : Text(
                      data.value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight:
                            data.valueBold ? FontWeight.w700 : FontWeight.w600,
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

class _EmptyDocumentCard extends StatelessWidget {
  const _EmptyDocumentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

class _ReviewsHeader extends StatelessWidget {
  const _ReviewsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'RATING & REVIEWS',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'See All',
            style: TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.inventoryAvailableBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'S',
                        style: TextStyle(
                          color: AppColors.inventoryAvailable,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aicha Mint Ahmed',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          _StarRating(rating: 3),
                        ],
                      ),
                    ),
                    const Text(
                      'Jan 12 2026, 07:13 am',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Lorem Ipsum has been the industry's standard dummy",
                  style: TextStyle(
                    color: AppColors.textLabel,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.softGrayFill,
            child: const Text(
              'Order: ORD-000091',
              style: TextStyle(
                color: AppColors.textMeta,
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: const Color(0xFFF2A000),
            size: 16,
          ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
