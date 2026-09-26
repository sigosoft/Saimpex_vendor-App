import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/pharmacy/order_details_screen.dart';
import 'package:saimpex_vendor/pharmacy/reject_order_sheet.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/view/login/login.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

class PharmacyHome extends StatefulWidget {
  const PharmacyHome({super.key});

  @override
  State<PharmacyHome> createState() => _PharmacyHomeState();
}

class _PharmacyHomeState extends State<PharmacyHome> {
  bool isStoreOpen = true;
  int selectedOrderType = 0; // 0 = Prescription, 1 = OTC
  int selectedFilterIndex = 0;
  int bottomNavIndex = 0;
  final searchController = TextEditingController();

  final prescriptionFilters = const [
    'New Orders',
    'Under Review',
    'Review Completed',
  ];

  final otcFilters = const [
    'New Orders',
    'Preparing',
    'Ready',
  ];

  bool get isOtcTab => selectedOrderType == 1;

  List<String> get activeFilters =>
      isOtcTab ? otcFilters : prescriptionFilters;

  String get _filterBadgeLabel {
    if (!isOtcTab && selectedFilterIndex == 1) return '02';
    final count = isOtcTab ? 2 : 4;
    return count.toString().padLeft(2, '0');
  }

  void _selectOrderType(int index) {
    setState(() {
      selectedOrderType = index;
      selectedFilterIndex = 0;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onBottomNavSelect(int index) {
    if (index == bottomNavIndex) return;
    setState(() {
      bottomNavIndex = index;
      if (index == 1) {
        // Orders screen mirrors water: reset to first type + first filter.
        selectedOrderType = 0;
        selectedFilterIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundTop,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryOrange,
          surface: AppColors.card,
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          body: Column(
            children: [
              Expanded(
                child: switch (bottomNavIndex) {
                  0 => _buildHomeTab(context),
                  1 => _buildOrdersTab(context),
                  2 => const _PlaceholderTab(title: 'Chat'),
                  3 => const _PlaceholderTab(title: 'Inventory'),
                  _ => const _PharmacyAccountTab(),
                },
              ),
              _BottomNav(
                selectedIndex: bottomNavIndex,
                onSelect: _onBottomNavSelect,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF0E8),
            Color(0xFFFFF8F4),
            Color(0xFFF7F7F7),
          ],
          stops: [0, 0.22, 1],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: const _Header(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StoreStatusCard(
                  isOpen: isStoreOpen,
                  onToggle: (v) => setState(() => isStoreOpen = v),
                ),
                const SizedBox(height: 12),
                const _MetricsGrid(),
                const SizedBox(height: 16),
                const _TotalsRow(),
                const SizedBox(height: 18),
                _OrdersHeader(onSeeAll: () => _onBottomNavSelect(1)),
                const SizedBox(height: 12),
                if (isOtcTab || selectedFilterIndex == 0) ...[
                  _OrderTypeTabs(
                    selectedIndex: selectedOrderType,
                    onSelect: _selectOrderType,
                    prescriptionBadge: '2',
                    otcBadge: '2',
                  ),
                  const SizedBox(height: 14),
                ],
                _SearchField(controller: searchController),
                const SizedBox(height: 12),
                _StatusFilters(
                  filters: activeFilters,
                  selectedIndex:
                      selectedFilterIndex.clamp(0, activeFilters.length - 1),
                  onSelect: (i) => setState(() => selectedFilterIndex = i),
                  badgeLabel: _filterBadgeLabel,
                ),
                const SizedBox(height: 12),
                ..._buildHomeOrderCards(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHomeOrderCards() {
    if (isOtcTab) {
      return const [
        _OtcOrderCard(
          customerName: 'Fatima',
          orderId: '#22789021',
          timeAgo: '5 min ago',
          items: 'Paracetamol 500mg ×2  •  Cough Syrup ×1',
        ),
        SizedBox(height: 12),
        _OtcOrderCard(
          customerName: 'Mohamed',
          orderId: '#22789022',
          timeAgo: '12 min ago',
          items: 'Vitamin C ×1  •  Bandages ×2',
        ),
      ];
    }

    final filter = selectedFilterIndex.clamp(0, activeFilters.length - 1);
    if (filter == 1) {
      return const [
        _PrescriptionOrderCard(
          customerName: 'Ahmed',
          status: PharmacyPrescriptionCardStatus.underReview,
          notesType: PharmacyOrderNotesType.none,
        ),
      ];
    }
    if (filter == 2) {
      return const [
        _EmptyOrders(message: 'No review completed orders here'),
      ];
    }

    return const [
      _PrescriptionOrderCard(
        customerName: 'Ahmed',
        notesType: PharmacyOrderNotesType.voice,
      ),
      SizedBox(height: 12),
      _PrescriptionOrderCard(
        customerName: 'Sidi Ahmed',
        notesType: PharmacyOrderNotesType.text,
      ),
      SizedBox(height: 12),
      _PrescriptionOrderCard(
        customerName: 'Ahmed',
        notesType: PharmacyOrderNotesType.none,
      ),
      SizedBox(height: 12),
      _PrescriptionOrderCard(
        customerName: 'Ahmed',
        notesType: PharmacyOrderNotesType.none,
        isSelfPickup: true,
      ),
    ];
  }

  Widget _buildOrdersTab(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF0E8),
            Color(0xFFFFF8F4),
            Color(0xFFF7F7F7),
          ],
          stops: [0, 0.18, 1],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Orders',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => _onBottomNavSelect(0),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFE0D0),
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
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _OrderTypeTabs(
              selectedIndex: selectedOrderType,
              onSelect: _selectOrderType,
              prescriptionBadge: '2',
              otcBadge: '2',
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SearchField(controller: searchController),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              children: [
                _StatusFilters(
                  filters: activeFilters,
                  selectedIndex:
                      selectedFilterIndex.clamp(0, activeFilters.length - 1),
                  onSelect: (i) => setState(() => selectedFilterIndex = i),
                  badgeLabel: _filterBadgeLabel,
                ),
                const SizedBox(height: 12),
                ..._buildOrdersTabCards(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrdersTabCards() {
    final filter = selectedFilterIndex.clamp(0, activeFilters.length - 1);
    if (!isOtcTab && filter == 1) {
      return const [
        _PrescriptionOrderCard(
          customerName: 'Ahmed',
          status: PharmacyPrescriptionCardStatus.underReview,
          notesType: PharmacyOrderNotesType.none,
        ),
      ];
    }
    if (!isOtcTab && filter == 2) {
      return const [
        _EmptyOrders(message: 'No review completed orders here'),
      ];
    }
    if (isOtcTab) {
      return const [
        _OtcOrderCard(
          customerName: 'Fatima',
          orderId: '#22789021',
          timeAgo: '5 min ago',
          items: 'Paracetamol 500mg ×2  •  Cough Syrup ×1',
        ),
        SizedBox(height: 12),
        _OtcOrderCard(
          customerName: 'Mohamed',
          orderId: '#22789022',
          timeAgo: '12 min ago',
          items: 'Vitamin C ×1  •  Bandages ×2',
        ),
        SizedBox(height: 12),
        _OtcOrderCard(
          customerName: 'Aisha',
          orderId: '#22789023',
          timeAgo: '28 min ago',
          items: 'Ibuprofen 400mg ×1',
        ),
      ];
    }
    return const [
      _PrescriptionOrderCard(
        customerName: 'Ahmed',
        notesType: PharmacyOrderNotesType.voice,
      ),
      SizedBox(height: 12),
      _PrescriptionOrderCard(
        customerName: 'Sidi Ahmed',
        notesType: PharmacyOrderNotesType.text,
      ),
      SizedBox(height: 12),
      _PrescriptionOrderCard(
        customerName: 'Ahmed',
        notesType: PharmacyOrderNotesType.none,
      ),
      SizedBox(height: 12),
      _PrescriptionOrderCard(
        customerName: 'Ahmed',
        notesType: PharmacyOrderNotesType.none,
        isSelfPickup: true,
      ),
    ];
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 40,
            color: Color(0xFFB0B0B0),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            AppAssets.homeTopIcon,
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_pharmacy_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Welcome to Saimpex Vendor!',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.paymentDivider,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _StoreStatusCard extends StatelessWidget {
  const _StoreStatusCard({required this.isOpen, required this.onToggle});

  final bool isOpen;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.iconGreenBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              AppAssets.shopOpenIcon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.storefront_outlined,
                color: AppColors.iconGreen,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Open • Accepting orders' : 'Closed • Not accepting',
                  style: TextStyle(
                    color: isOpen ? AppColors.iconGreen : AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Today: 08:00 - 22:00',
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onToggle(!isOpen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isOpen
                    ? const Color(0xFFFF6B00)
                    : const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: isOpen ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                count: '2',
                label: 'New prescriptions',
                badgeGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF8A3D), Color(0xFFFF5722)],
                ),
                countColor: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: '2',
                label: 'New OTC orders',
                badgeColor: Color(0xFFB2DFDB),
                countColor: Color(0xFF00695C),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                count: '2',
                label: 'Preparing',
                badgeColor: Color(0xFFFFB300),
                countColor: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: '2',
                label: 'Ready',
                badgeColor: Color(0xFF43A047),
                countColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.count,
    required this.label,
    required this.countColor,
    this.badgeColor,
    this.badgeGradient,
  });

  final String count;
  final String label;
  final Color countColor;
  final Color? badgeColor;
  final Gradient? badgeGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeGradient == null ? badgeColor : null,
              gradient: badgeGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: TextStyle(
                color: countColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: _TotalItem(title: 'ORDERS', value: '15')),
          _VDivider(),
          Expanded(child: _TotalItem(title: 'COMPLETED', value: '2')),
          _VDivider(),
          Expanded(
            child: _TotalItem(
              title: 'REVENUE',
              value: '830',
              suffix: 'MRU',
              showTrend: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: AppColors.homeDivider);
  }
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({
    required this.title,
    required this.value,
    this.suffix,
    this.showTrend = false,
  });

  final String title;
  final String value;
  final String? suffix;
  final bool showTrend;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTrend) ...[
              const Icon(
                Icons.trending_up_rounded,
                size: 13,
                color: Color(0xFF2EAD5B),
              ),
              const SizedBox(width: 3),
            ],
            Text(
              title,
              style: const TextStyle(
                color: AppColors.homeLabel,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: AppColors.homeValue,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              if (suffix != null)
                TextSpan(
                  text: ' $suffix',
                  style: const TextStyle(
                    color: AppColors.homeValue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'ORDERS',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'See All',
            style: TextStyle(
              color: AppColors.primaryOrange,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderTypeTabs extends StatelessWidget {
  const _OrderTypeTabs({
    required this.selectedIndex,
    required this.onSelect,
    this.prescriptionBadge,
    this.otcBadge,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String? prescriptionBadge;
  final String? otcBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF5722),
            Color(0xFFFF8F3D),
            Color(0xFFFFC04D),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeTab(
              label: 'Prescription',
              selected: selectedIndex == 0,
              badge: selectedIndex == 0 ? prescriptionBadge : null,
              onTap: () => onSelect(0),
            ),
          ),
          Expanded(
            child: _TypeTab(
              label: 'OTC',
              selected: selectedIndex == 1,
              badge: selectedIndex == 1 ? otcBadge : null,
              onTap: () => onSelect(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? const Color(0xFF1A1A1A) : Colors.white,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (badge != null && selected)
            Positioned(
              right: 2,
              top: -3,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF9E9E9E), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Search by ID, name',
                hintStyle: TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({
    required this.filters,
    required this.selectedIndex,
    required this.onSelect,
    required this.badgeLabel,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    // Extra height so the floating "02" badge is not clipped.
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 6, right: 6),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          final showBadge = selected && index == 0;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: selected
                        ? const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFFF5421), Color(0xFFFFB800)],
                          )
                        : null,
                    color: selected ? null : Colors.white,
                    border: selected
                        ? null
                        : Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF757575),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (showBadge)
                  Positioned(
                    // Top-right corner of the pill, slightly overlapping outside.
                    top: -6,
                    right: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          color: Color(0xFFFF8A00),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum PharmacyPrescriptionCardStatus { newOrder, underReview }

class _PrescriptionOrderCard extends StatelessWidget {
  const _PrescriptionOrderCard({
    this.customerName = 'Ahmed',
    this.notesType = PharmacyOrderNotesType.none,
    this.isSelfPickup = false,
    this.status = PharmacyPrescriptionCardStatus.newOrder,
  });

  final String customerName;
  final PharmacyOrderNotesType notesType;
  final bool isSelfPickup;
  final PharmacyPrescriptionCardStatus status;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFC62828);
  static const Color _nameColor = Color(0xFF111827);
  static const Color _metaColor = Color(0xFF6B7280);
  static const Color _newBadge = Color(0xFFF99D1C);
  static const Color _reviewingBadge = Color(0xFF8E6CE0);
  static const Color _attachBg = Color(0xFFFAF9F7);
  static const Color _attachBorder = Color(0xFFEAEAEA);
  static const Color _linkOrange = Color(0xFFFF6B2B);
  static const Color _rejectBorder = Color(0xFFE0E0E0);

  bool get _isUnderReview =>
      status == PharmacyPrescriptionCardStatus.underReview;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = _isUnderReview ? 'REVIEWING' : 'NEW';
    final badgeColor = _isUnderReview ? _reviewingBadge : _newBadge;
    final primaryLabel =
        _isUnderReview ? 'Mark as Reviewed' : 'Review Prescription';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  customerName.isNotEmpty
                      ? customerName.substring(0, 1).toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: _avatarText,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        color: _nameColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '#22789007  •  2 min ago',
                      style: TextStyle(
                        color: _metaColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _attachBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _attachBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _PrescriptionThumb(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prescription_Jun25.jpg',
                        style: TextStyle(
                          color: _nameColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PharmacyOrderDetailsScreen(
                                customerName: customerName,
                                notesType: notesType,
                                isSelfPickup: isSelfPickup,
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Full Prescription',
                              style: TextStyle(
                                color: _linkOrange,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 14,
                              color: _linkOrange,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => showPharmacyRejectOrderSheet(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _nameColor,
                      side: const BorderSide(color: _rejectBorder, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      'Reject',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _linkOrange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _linkOrange.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PharmacyOrderDetailsScreen(
                              customerName: customerName,
                              notesType: notesType,
                              isSelfPickup: isSelfPickup,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        primaryLabel,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrescriptionThumb extends StatelessWidget {
  const _PrescriptionThumb();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        AppAssets.prescriptionHome,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD6E4FF)),
          ),
          child: const Icon(
            Icons.description_outlined,
            size: 22,
            color: Color(0xFF1565C0),
          ),
        ),
      ),
    );
  }
}

class _OtcOrderCard extends StatelessWidget {
  const _OtcOrderCard({
    required this.customerName,
    required this.orderId,
    required this.timeAgo,
    required this.items,
  });

  final String customerName;
  final String orderId;
  final String timeAgo;
  final String items;

  static const Color _avatarBg = Color(0xFFFDEAEA);
  static const Color _avatarText = Color(0xFFC62828);
  static const Color _nameColor = Color(0xFF111827);
  static const Color _metaColor = Color(0xFF6B7280);
  static const Color _newBadge = Color(0xFFF99D1C);
  static const Color _linkOrange = Color(0xFFFF6B2B);
  static const Color _rejectBorder = Color(0xFFE0E0E0);
  static const Color _itemBg = Color(0xFFFAF9F7);
  static const Color _itemBorder = Color(0xFFEAEAEA);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  customerName.isNotEmpty
                      ? customerName.substring(0, 1).toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: _avatarText,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        color: _nameColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$orderId  •  $timeAgo',
                      style: const TextStyle(
                        color: _metaColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _newBadge,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _itemBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _itemBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medication_outlined,
                    color: Color(0xFF00695C),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    items,
                    style: const TextStyle(
                      color: _nameColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => showPharmacyRejectOrderSheet(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _nameColor,
                      side: const BorderSide(color: _rejectBorder, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      'Reject',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _linkOrange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _linkOrange.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Accept Order',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Orders', 'Chat', 'Inventory', 'Account'];
    const assetIcons = <String?>[
      null,
      AppAssets.ordersIcon,
      AppAssets.chatIcon,
      AppAssets.inventoryIcon,
      AppAssets.accountIcon,
    ];
    const fallbacks = <IconData>[
      Icons.home_rounded,
      Icons.receipt_long_rounded,
      Icons.chat_bubble_outline_rounded,
      Icons.shopping_cart_outlined,
      Icons.person_outline_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(5, (index) {
              final selected = selectedIndex == index;
              final asset = assetIcons[index];
              return Expanded(
                child: InkWell(
                  onTap: () => onSelect(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: selected
                            ? Container(
                                key: const ValueKey('selected'),
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: _NavIcon(
                                  asset: asset,
                                  fallback: fallbacks[index],
                                  color: Colors.white,
                                  size: 24,
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey('idle'),
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: _NavIcon(
                                    asset: asset,
                                    fallback: fallbacks[index],
                                    color: AppColors.navInactive,
                                    size: asset == null ? 28 : 24,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? AppColors.primaryOrange
                              : AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.asset,
    required this.fallback,
    required this.color,
    required this.size,
  });

  final String? asset;
  final IconData fallback;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (asset == null) {
      return Icon(fallback, color: color, size: size);
    }
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(
        asset!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(fallback, color: color, size: size),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF7F7F7),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PharmacyAccountTab extends StatelessWidget {
  const _PharmacyAccountTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF7F7F7),
      child: Center(
        child: TextButton.icon(
          onPressed: () async {
            await savename('loginStatus', 'false');
            await savename('token', '');
            Get.offAll(() => const LoginScreen());
          },
          icon: const Icon(Icons.logout_rounded, color: AppColors.primaryOrange),
          label: const Text(
            'Logout',
            style: TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
