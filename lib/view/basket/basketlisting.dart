import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../controller/basket_controller.dart';
import '../../controller/profile_controller.dart';
import '../../generated/l10n.dart';
import '../../model/basket_model.dart';
import '../../resources/colors.dart';
import '../../utils/widgets/no_data_widget.dart';
import 'basket_details_screen.dart';

/// Search, filter, basket cards, and create action for the **Basket** tab body.
class BasketListing extends StatefulWidget {
  const BasketListing({super.key});

  @override
  State<BasketListing> createState() => _BasketListingState();
}

class _BasketRowData {
  const _BasketRowData({
    required this.id,
    required this.createdAt,
    required this.itemsCount,
    required this.redeemPoints,
    required this.isActive,
    required this.listIndex,
  });

  final String id;
  final DateTime createdAt;
  final int itemsCount;
  final int redeemPoints;
  final bool isActive;
  /// 0-based order for title suffix.
  final int listIndex;
}

class _BasketListingState extends State<BasketListing> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  late final BasketController _basketController;

  BasketStatusFilter _statusFilter = BasketStatusFilter.all;

  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _titleColor = Color(0xFF1F2937);
  static const Color _subtitleColor = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _basketController = Get.put(BasketController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _basketController.getBaskets(context, statusFilter: _statusFilter);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    Get.delete<BasketController>();
    super.dispose();
  }

  String _restaurantTitlePrefix(String? profileName) {
    final t = profileName?.trim();
    if (t == null || t.isEmpty) return 'Restaurant';
    return t.split(RegExp(r'\s+')).first;
  }

  String _initialsBadge(String? profileName, int index) {
    final t = profileName?.trim();
    if (t == null || t.isEmpty) return 'R${index + 1}';
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length >= 2 &&
        parts[0].isNotEmpty &&
        parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (t.length >= 2) return t.substring(0, 2).toUpperCase();
    return '${t[0]}${index + 1}'.toUpperCase();
  }

  String _formatCreatedDate(BuildContext context, DateTime d) {
    final loc = Localizations.localeOf(context).toString();
    try {
      return DateFormat.yMMMd(loc).format(d);
    } catch (_) {
      return DateFormat.yMMMd('en').format(d);
    }
  }

  List<_BasketRowData> _rowsFromBaskets(List<Datum> baskets) {
    return baskets.asMap().entries.map((e) {
      final d = e.value;
      return _BasketRowData(
        id: d.id?.toString() ?? '',
        createdAt: d.createdAt ?? DateTime.now(),
        itemsCount: (d.basketItemsCount ?? d.quantity ?? 0).toInt(),
        redeemPoints: (d.redeemPoints ?? 0).toInt(),
        isActive: (d.status ?? 0) == 1,
        listIndex: e.key,
      );
    }).toList();
  }

  void _openFilterSheet() {
    final s = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(s.all, style: GoogleFonts.rubik()),
                onTap: () {
                  setState(() => _statusFilter = BasketStatusFilter.all);
                  _basketController.keyword = _searchController.text.trim();
                  _basketController.getBaskets(context,
                      statusFilter: _statusFilter);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(s.activeLabel, style: GoogleFonts.rubik()),
                onTap: () {
                  setState(() => _statusFilter = BasketStatusFilter.active);
                  _basketController.keyword = _searchController.text.trim();
                  _basketController.getBaskets(context,
                      statusFilter: _statusFilter);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                // API filter is `blocked`; UI uses the existing "inactive" label.
                title: Text(
                  'Blocked',
                  style: GoogleFonts.rubik(),
                ),
                onTap: () {
                  setState(() => _statusFilter = BasketStatusFilter.blocked);
                  _basketController.keyword = _searchController.text.trim();
                  _basketController.getBaskets(context,
                      statusFilter: _statusFilter);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          final shouldLoadMore = metrics.pixels >= metrics.maxScrollExtent - 250;
          if (shouldLoadMore) {
            if (_basketController.hasNextPage &&
                !_basketController.isLoading &&
                !_basketController.isLoadMoreRunning) {
              _basketController.loadMoreBaskets();
            }
          }
        }
        return false;
      },
      child: GetBuilder<ProfileController>(
        builder: (profileController) {
          final profileName = profileController.profileData?.name;

          return GetBuilder<BasketController>(
            builder: (basketController) {
              if (basketController.isLoading && basketController.basketList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(color: colorPrimary),
                  ),
                );
              }

              final rows = _rowsFromBaskets(basketController.basketList);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchRow(context),
                  const SizedBox(height: 16),
                  ...rows.asMap().entries.map((e) {
                    final row = e.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: e.key < rows.length - 1 ? 12 : 0,
                      ),
                      child: _BasketCard(
                        initials: 'R${row.listIndex + 1}',
                        title:
                            '${_restaurantTitlePrefix(profileName)} ${S.of(context).basket} ${row.listIndex + 1}',
                        subtitle:
                            '${S.of(context).basketIdLabel(row.id)} • ${S.of(context).createdLabel(_formatCreatedDate(context, row.createdAt))}',
                        itemsCount: row.itemsCount,
                        redeemPoints: row.redeemPoints,
                        isActive: row.isActive,
                        onViewDetails: () {
                          final basketId = int.tryParse(row.id) ?? 0;
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => BasketDetailsScreen(
                                basketId: basketId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  if (rows.isEmpty) ...[
                    const SizedBox(height: 24),
                    NoDataWidget(
                      context,
                      'No baskets found',
                      'No baskets found',
                      'lib/assets/images/nonotifications.png',
                    ),
                  ],
                  if (basketController.isLoadMoreRunning) ...[
                    const SizedBox(height: 12),
                    const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(12),
            //   border: Border.all(color: _cardBorder),
            // ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.rubik(
                fontSize: 14,
                color: _titleColor,
              ),
              decoration: InputDecoration(
                hintText: S.of(context).searchName,
                hintStyle: GoogleFonts.rubik(
                  fontSize: 14,
                  color: _subtitleColor,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: _subtitleColor,
                  size: 22,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _cardBorder, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _cardBorder, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _cardBorder, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              ),
              onChanged: (value) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                  _basketController.keyword = value.trim();
                  _basketController.getBaskets(context,
                      statusFilter: _statusFilter);
                });
              },
              onSubmitted: (value) {
                _searchDebounce?.cancel();
                _basketController.keyword = value.trim();
                _basketController.getBaskets(context,
                    statusFilter: _statusFilter);
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _openFilterSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _cardBorder),
              ),
              child: const Icon(
                Icons.tune,
                color: _subtitleColor,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BasketCard extends StatelessWidget {
  const _BasketCard({
    required this.initials,
    required this.title,
    required this.subtitle,
    required this.itemsCount,
    required this.redeemPoints,
    required this.isActive,
    required this.onViewDetails,
  });

  final String initials;
  final String title;
  final String subtitle;
  final int itemsCount;
  final int redeemPoints;
  final bool isActive;
  final VoidCallback onViewDetails;

  static const Color _iconBlueBg = Color(0xFFE3F2FD);
  static const Color _statBoxBg = Color(0xFFF3F4F6);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _titleColor = Color(0xFF1F2937);
  static const Color _subtitleColor = Color(0xFF6B7280);
  static const Color _activeBadgeBg = Color(0xFFF0FDF4);
  static const Color _activeBadgeText = Color(0xFF166534);
  static const Color _inactiveBadgeBg = Color(0xFFFEF2F2);
  static const Color _inactiveBadgeText = Color(0xFF991B1B);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final statusText =
        isActive ? s.activeLabel.toUpperCase() : 'Blocked';
    final statusBg = isActive ? _activeBadgeBg : _inactiveBadgeBg;
    final statusFg = isActive ? _activeBadgeText : _inactiveBadgeText;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
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
                decoration: BoxDecoration(
                  color: _iconBlueBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  initials,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.rubik(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _titleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: GoogleFonts.rubik(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusFg,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        color: _subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: s.itemsCountLabel,
                  value: '$itemsCount ${s.items}',
                  background: _statBoxBg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  label: s.redeemPointsLabel,
                  value: '$redeemPoints Pts',
                  background: _statBoxBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorPrimary,
                side: const BorderSide(color: colorPrimary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                s.viewDetails,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.background,
  });

  final String label;
  final String value;
  final Color background;

  static const Color _subtitleColor = Color(0xFF6B7280);
  static const Color _titleColor = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _subtitleColor,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _titleColor,
            ),
          ),
        ],
      ),
    );
  }
}
