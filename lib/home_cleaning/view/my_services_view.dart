import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/home_cleaning/view/add_service_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/home_cleaning_home.dart';

class ServiceItem {
  const ServiceItem({
    required this.title,
    required this.description,
    required this.image,
    required this.startingRate,
    required this.rateUnit,
    required this.categoryLabel,
    required this.badges,
  });

  final String title;
  final String description;
  final String image;
  final String startingRate;
  final String rateUnit;
  final String categoryLabel;
  final List<ServiceBadge> badges;
}

class ServiceBadge {
  const ServiceBadge({
    required this.label,
    this.price,
  });

  final String label;
  final String? price;
}

class MyServicesView extends StatefulWidget {
  const MyServicesView({super.key, required this.controller});

  final HomeCleaningController controller;

  static const _orange = Color(0xFFFF5722);
  static const _ink = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF757575);

  static const defaultServices = [
    ServiceItem(
      title: 'Regular Cleaning',
      description: 'Professional cleaning with flexible space-based pricing',
      image: 'lib/home_cleaning/Assets/images/regularcleaning.png',
      startingRate: '100',
      rateUnit: 'MRU / Room',
      categoryLabel: 'ADD-ONS:',
      badges: [
        ServiceBadge(label: 'Fridge Cleaning', price: '+100 MRU'),
        ServiceBadge(label: 'Dish Washing', price: '+150 MRU'),
      ],
    ),
    ServiceItem(
      title: 'Pest Control & Disinfection',
      description: 'Professional cleaning with flexible space-based pricing',
      image: 'lib/home_cleaning/Assets/images/pest_control.png',
      startingRate: '100',
      rateUnit: 'MRU / Room',
      categoryLabel: 'ISSUE COVERED:',
      badges: [
        ServiceBadge(label: 'Cockroaches'),
        ServiceBadge(label: 'Bed Bugs'),
        ServiceBadge(label: 'Termites'),
        ServiceBadge(label: 'Viral Disinfection'),
      ],
    ),
  ];

  @override
  State<MyServicesView> createState() => _MyServicesViewState();
}

class _MyServicesViewState extends State<MyServicesView> {
  final TextEditingController _searchController = TextEditingController();
  final List<ServiceItem> _services = List.of(MyServicesView.defaultServices);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceItem> get _filteredServices {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _services;
    return _services
        .where((s) => s.title.toLowerCase().contains(query))
        .toList();
  }

  void _handleDelete(ServiceItem item) {
    setState(() {
      _services.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final services = _filteredServices;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFE8DC),
            Color(0xFFFFF3EC),
            Color(0xFFFFFFFF),
          ],
          stops: [0, 0.22, 0.45],
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
                  Text(
                    'My Services',
                    style: GoogleFonts.inter(
                      color: MyServicesView._ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.controller.selectNav(0);
                      },
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
                          color: MyServicesView._orange,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() {}),
                style: GoogleFonts.inter(
                  color: MyServicesView._ink,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search Services',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFFBDBDBD),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFBDBDBD),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'YOUR SERVICES',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9AA3B2),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: services.isEmpty
                ? Center(
                    child: Text(
                      'No services found',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: services.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return _ServiceCard(
                        service: service,
                        onDelete: () => _handleDelete(service),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddServiceView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: MyServicesView._orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  '+ Add Service',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onDelete,
  });

  final ServiceItem service;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            service.image,
            height: 155,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 155,
              color: const Color(0xFFF5F5F5),
              alignment: Alignment.center,
              child: const Icon(
                Icons.cleaning_services,
                size: 40,
                color: MyServicesView._orange,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        service.title,
                        style: GoogleFonts.inter(
                          color: MyServicesView._ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _ServicePopupMenu(service: service, onDelete: onDelete),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  style: GoogleFonts.inter(
                    color: MyServicesView._muted,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STARTING RATE',
                        style: GoogleFonts.inter(
                          color: MyServicesView._orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${service.startingRate} ',
                              style: GoogleFonts.inter(
                                color: MyServicesView._orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: service.rateUnit,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFF8A65),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  service.categoryLabel,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF424242),
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final badge in service.badges)
                      _ServiceBadgeChip(badge: badge),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceBadgeChip extends StatelessWidget {
  const _ServiceBadgeChip({required this.badge});

  final ServiceBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: badge.price == null
          ? Text(
              badge.label,
              style: GoogleFonts.inter(
                color: const Color(0xFF424242),
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            )
          : Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${badge.label} ',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF424242),
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                  TextSpan(
                    text: badge.price!,
                    style: GoogleFonts.inter(
                      color: MyServicesView._orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ServicePopupMenu extends StatelessWidget {
  const _ServicePopupMenu({
    required this.service,
    required this.onDelete,
  });

  final ServiceItem service;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: const Color(0xFFEAEAEA),
        popupMenuTheme: PopupMenuThemeData(
          color: const Color(0xFFEAEAEA),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, color: Color(0xFF9E9E9E), size: 20),
        offset: const Offset(-10, 30),
        onSelected: (value) {
          HapticFeedback.lightImpact();
          if (value == 'edit') {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddServiceView(initialService: service),
              ),
            );
          } else if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'edit',
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Color(0xFF424242),
                ),
                const SizedBox(width: 8),
                Text(
                  'Edit',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF212121),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Color(0xFF757575),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: 'delete',
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: Color(0xFF424242),
                ),
                const SizedBox(width: 8),
                Text(
                  'Delete',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF212121),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Color(0xFF757575),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
