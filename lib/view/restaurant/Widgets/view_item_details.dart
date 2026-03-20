import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/Utils/Utils.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/restaurant_items_detail_model.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/edit_items_screen.dart';

class ViewItemDetails extends StatefulWidget {
  /// `restaurant_menu_item_id` from backend.
  final String itemId;

  const ViewItemDetails({
    super.key,
    required this.itemId,
  });

  @override
  State<ViewItemDetails> createState() => _ViewItemDetailsState();
}

class _ViewItemDetailsState extends State<ViewItemDetails> {
  bool _isLoading = true;
  String? _error;
  RestaurantItemsDetailsModel? _detailsModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await getSavedObject("token");
      DioClient().updateToken(token?.toString() ?? "");

      final idInt = int.tryParse(widget.itemId);
      if (idInt == null) {
        throw Exception("Invalid itemId: ${widget.itemId}");
      }

      final response = await DioClient().get(
        ApiEndPoints.getRestaurantMenuItemDetails,
        query: {"item_id": idInt},
      );

      final raw = response.data;
      final map = raw is Map<String, dynamic>
          ? raw
          : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});

      _detailsModel = RestaurantItemsDetailsModel.fromJson(map);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    final lang = localization.currentLocale?.languageCode ?? "en";

    return Directionality(
      textDirection: lang == "ar" ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: CommonBackground(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
          ),
          title: Text(
            "Details",
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          centerTitle: false,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.07,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditItemsScreen(itemId: widget.itemId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5216),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Upload Drive",
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF5216)),
              )
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: GoogleFonts.rubik(color: Colors.red),
                    ),
                  )
                : _buildContent(lang),
      ),
    );
  }

  Widget _buildContent(String lang) {
    final details = _detailsModel?.data?.menuItemDetails;
    final menu = details?.restaurantMenu;
    if (details == null || menu == null) {
      return const SizedBox.shrink();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final imageUrl = menu.image != null && menu.image!.isNotEmpty
        ? (ApiConfigs.IMAGE_URL + menu.image!)
        : "";

    final menuName = _pickMenuName(menu, lang);
    final categoryName = _pickCategoryName(menu, lang);
    final description = _pickDescription(menu, lang);

    final createdText = _formatDateTime(details.createdAt);
    final updatedText = _formatDateTime(details.updatedAt);

    final priceText = _formatMoney(details.price);
    final discountText = details.discountPrice != null &&
            details.discountPrice!.isNotEmpty &&
            details.discountPrice != details.price
        ? _formatMoney(details.discountPrice)
        : "";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: screenHeight * 0.22,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        _placeholderBurger(screenHeight: screenHeight),
                  )
                : _placeholderBurger(screenHeight: screenHeight),
          ),
          SizedBox(height: screenHeight * 0.02),

          Text(
            "Menu Information",
            style: GoogleFonts.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),

          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv(
                  label: "MENU NAME",
                  value: menuName.isNotEmpty ? menuName : "#${details.id ?? widget.itemId}",
                ),
                const SizedBox(height: 10),
                _kv(
                  label: "PRICE",
                  value: priceText,
                  valueColor: const Color(0xFF1F2937),
                ),
                if (discountText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _kv(
                    label: "DISCOUNT PRICE",
                    value: discountText,
                    valueColor: const Color(0xFFFF5216),
                  ),
                ],
                const SizedBox(height: 10),
                _kv(
                  label: "PREPARATION TIME",
                  value: details.preparationTime?.toString() ?? "-",
                ),
                const SizedBox(height: 10),
                _kv(
                  label: "CATEGORY",
                  value: categoryName.isNotEmpty ? categoryName : "-",
                ),
                const SizedBox(height: 10),
                _isVegBadge(
                  isVeg: details.restaurantMenu?.isVeg == 1,
                  value: (details.restaurantMenu?.isVeg == 1) ? "Yes" : "No",
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _kvSimple(label: "CREATED DATE", value: createdText)),
                    const SizedBox(width: 12),
                    Expanded(child: _kvSimple(label: "UPDATED DATE", value: updatedText)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  "DESCRIPTION",
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description.isNotEmpty ? description : "No description available",
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          Text(
            "AVAILABLE THE",
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 10),

          _availabilityList(details.workingHours ?? []),

          SizedBox(height: screenHeight * 0.02),

          Text(
            "SALES & PERFORMANCE",
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 10),

          _statsGrid(
            totalOrders: _toInt(details.totalOrders?.toString()),
            totalRevenue: details.totalPriceAfterCommission ?? 0,
            avgRating: _toDouble(details.avgRating),
            totalRatings: _toInt(details.totalRatings?.toString()),
            lastPurchaseAgo: _timeAgo(details.lastOrderDate),
          ),

          SizedBox(height: screenHeight * 0.02),

          Row(
            children: [
              Expanded(
                child: Text(
                  "ITEM ORDERS",
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
              Text(
                "View All",
                style: GoogleFonts.rubik(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF5216),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _itemOrdersCard(
            orderId: widget.itemId,
            merchantName: menuName,
            isDelivered: (details.availableStatus == 1) ||
                (details.approvalStatus == 1),
            itemsCount: _toInt(details.quantityAllowed?.toString()),
            itemsPriceText: _formatMoneyTo2(details.price),
            dateTimeText: _formatOrderDateTime(details.lastOrderDate),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _availabilityList(List<WorkingHour> hours) {
    if (hours.isEmpty) {
      return _availabilityRow("Today", "0%");
    }

    final todayWeekday = DateTime.now().weekday; // 1..7 (Mon..Sun)
    final sorted = [...hours]
      ..sort((a, b) => (a.dayOfWeek ?? 0).compareTo(b.dayOfWeek ?? 0));

    return Column(
      children: sorted.take(7).map((h) {
        final dow = h.dayOfWeek ?? 0;
        final dayName = _dayNameFromDow(dow);
        final label = dow == todayWeekday ? "Today" : dayName;
        final percent = _openPercentFromWorkingHour(h);
        return _availabilityRow(label, "${percent}%");
      }).toList(),
    );
  }

  Widget _availabilityRow(String day, String percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              day,
              style: GoogleFonts.rubik(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const Spacer(),
          Text(
            percent,
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }

  int _openPercentFromWorkingHour(WorkingHour h) {
    if (h.isOpen24h == 1) return 100;
    final slots = h.timeSlots ?? [];
    if (slots.isEmpty) return 0;

    int totalMinutes = 0;
    for (final s in slots) {
      final openMin = _parseTimeToMinutes(s.openTime);
      final closeMin = _parseTimeToMinutes(s.closeTime);
      if (openMin == null || closeMin == null) continue;

      int diff = closeMin - openMin;
      if (diff <= 0) diff += 24 * 60; // crosses midnight
      totalMinutes += diff;
    }

    final percent = (totalMinutes / (24 * 60)) * 100.0;
    return percent.isFinite ? percent.round() : 0;
  }

  int? _parseTimeToMinutes(String? t) {
    if (t == null) return null;
    final trimmed = t.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  String _dayNameFromDow(int dow) {
    // Common backend: 1=Monday ... 7=Sunday
    const names = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (dow >= 1 && dow <= 7) return names[dow];
    return '—';
  }

  String _pickMenuName(RestaurantMenu menu, String lang) {
    // This API model only exposes English fields for menu items.
    return menu.nameEn ?? '';
  }

  String _pickCategoryName(RestaurantMenu menu, String lang) {
    // Optional fields from API (parsed in model).
    if (lang == 'fr') return menu.categoryNameFr ?? '';
    if (lang == 'ar') return menu.categoryNameAr ?? '';
    return menu.categoryNameEn ?? '';
  }

  String _pickDescription(RestaurantMenu menu, String lang) {
    return menu.descriptionEn ?? '';
  }

  String _formatDateTime(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final dt = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy, hh:mm a').format(dt);
    } catch (_) {
      return date;
    }
  }

  String _formatMoney(String? value) {
    if (value == null) return "-";
    final v = value.toString();
    if (v.trim().isEmpty) return "-";
    if (v.contains('MRU')) return v;
    return "$v MRU";
  }

  String _formatMoneyTo2(String? value) {
    if (value == null) return "-";
    final raw = value.toString().replaceAll('MRU', '').trim();
    if (raw.isEmpty) return "-";
    final v = double.tryParse(raw);
    if (v == null) return "-";
    return "${v.toStringAsFixed(2)} MRU";
  }

  int _toInt(String? v) {
    return int.tryParse(v ?? '') ?? 0;
  }

  double _toDouble(dynamic v) {
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  String _formatK(int value) {
    if (value >= 1000) {
      final k = value / 1000.0;
      final s = k.toStringAsFixed(1);
      final trimmed = s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
      return "${trimmed}k";
    }
    return value.toString();
  }

  String _timeAgo(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      final dt = DateTime.parse(date);
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 0) return "-";
      if (diff.inMinutes < 1) return "Just now";
      if (diff.inHours < 1) return "${diff.inMinutes} minutes ago";
      if (diff.inHours < 24) return "${diff.inHours} hours ago";
      if (diff.inDays < 7) return "${diff.inDays} days ago";
      return _formatDateTime(date);
    } catch (_) {
      return "-";
    }
  }

  Widget _statBox({
    required String label,
    required String value,
    required Color bg,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  String _formatOrderDateTime(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      final dt = DateTime.parse(date);
      final formatted = DateFormat('MMM dd, yyyy, hh:mm a').format(dt);
      final now = DateTime.now();
      final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
      return isToday ? "$formatted, Today" : formatted;
    } catch (_) {
      return date;
    }
  }

  Widget _statsGrid({
    required int totalOrders,
    required int totalRevenue,
    required double avgRating,
    required int totalRatings,
    required String lastPurchaseAgo,
  }) {
    final revenueText = _formatK(totalRevenue);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _statBox(
                  label: "Total Orders",
                  value: totalOrders.toString(),
                  bg: const Color(0xFFF8FAFC),
                  valueColor: const Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statBox(
                  label: "Revenue",
                  value: revenueText,
                  bg: const Color(0xFFF8FAFC),
                  valueColor: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Average Rating",
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: const Color(0xFFFF5216),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _lineStat(label: "Total Reviews", value: totalRatings.toString()),
          const SizedBox(height: 10),
          _lineStat(label: "Last Purchase", value: lastPurchaseAgo),
        ],
      ),
    );
  }

  Widget _lineStat({required String label, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.rubik(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _itemOrdersCard({
    required String orderId,
    required String merchantName,
    required bool isDelivered,
    required int itemsCount,
    required String itemsPriceText,
    required String dateTimeText,
  }) {
    final badgeBg = isDelivered ? const Color(0xFF16A34A) : const Color(0xFFFF5216);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                      "ORDER #ORD-${orderId}",
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      merchantName.isNotEmpty ? merchantName : "—",
                      style: GoogleFonts.rubik(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF5216),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isDelivered ? "DELIVERED" : "PENDING",
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  "ITEMS TOTAL",
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              Text(
                "DATE & TIME",
                style: GoogleFonts.rubik(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      "${itemsCount} Items total",
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      itemsPriceText,
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF5216),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                dateTimeText,
                style: GoogleFonts.rubik(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kvSimple({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.rubik(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _kv({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.rubik(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _isVegBadge({required bool isVeg, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isVeg ? const Color(0xFFDCFCE7) : const Color(0xFFFFF1EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVeg ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isVeg ? const Color(0xFF22C55E) : const Color(0xFFFF5216),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBurger({required double screenHeight}) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.22,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.fastfood, size: 60, color: Color(0xFF94A3B8)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}
