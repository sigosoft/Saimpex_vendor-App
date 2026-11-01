import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/model/restaurant_items_detail_model.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/view_stock_history_screen.dart';
import 'package:saimpex_vendor/view/restaurant/edit_items_screen.dart';
import 'package:get/get.dart';

import '../../../generated/l10n.dart';

class ViewItemDetails extends StatefulWidget {
  final String itemId;
  final String? menuItemId;

  const ViewItemDetails({super.key, required this.itemId, this.menuItemId});

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
    debugPrint(
      "ViewItemDetails _fetch widget.itemId=${widget.itemId} widget.menuItemId=${widget.menuItemId}",
    );
    try {
      final token = await getSavedObject("token");
      final vendorType = await getSavedObject("vendorType");
      DioClient().updateToken(token?.toString() ?? "");
      final itemIdInt = int.tryParse(widget.itemId);
      final menuItemIdInt = int.tryParse(widget.menuItemId ?? "");
      if (itemIdInt == null && menuItemIdInt == null) {
        throw Exception("Invalid item/menu item ids");
      }
      final selectedItemId = vendorType == "1"
          ? (itemIdInt ?? menuItemIdInt)
          : (menuItemIdInt ?? itemIdInt);
      if (selectedItemId == null) {
        throw Exception(
          vendorType == "1"
              ? S.of(context).invalidItemidWidgetitemid
              : "Missing menuItemId for grocery vendor",
        );
      }
      final query = {"item_id": selectedItemId.toString()};
      final endpoint = vendorType == "1"
          ? ApiEndPoints.restaurantCatalogItemDetail
          : ApiEndPoints.getGroceryMenuItemDetails;
      debugPrint(
        '[ViewItemDetails] _fetch vendorType=$vendorType endpoint=$endpoint itemId=${widget.itemId} menuItemId=${widget.menuItemId} query=$query',
      );
      dynamic response;
      try {
        response = await DioClient().get(endpoint, query: query);
      } on DioException catch (dioErr) {
        if (vendorType == "1" && dioErr.response?.statusCode == 404) {
          debugPrint(
            '[ViewItemDetails] 404 on $endpoint, trying fallback ${ApiEndPoints.restaurantCatalogItemDetailAlt}',
          );
          try {
            response = await DioClient().get(
              ApiEndPoints.restaurantCatalogItemDetailAlt,
              query: query,
            );
          } on DioException catch (altErr) {
            if (altErr.response?.statusCode == 404) {
              debugPrint(
                '[ViewItemDetails] 404 on alt, trying getRestaurantMenuItemDetails',
              );
              response = await DioClient().get(
                ApiEndPoints.getRestaurantMenuItemDetails,
                query: query,
              );
            } else {
              rethrow;
            }
          }
        } else {
          rethrow;
        }
      }
      debugPrint(
        '[ViewItemDetails] response.data runtimeType=${response.data.runtimeType}',
      );
      final raw = response.data;
      final map = raw is Map<String, dynamic>
          ? raw
          : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});

      _detailsModel = RestaurantItemsDetailsModel.fromJson(map);
      debugPrint(
        '[ViewItemDetails] parsed status=${_detailsModel?.status} message=${_detailsModel?.message} dataPresent=${_detailsModel?.data != null}',
      );
    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint("Error: $e");
      debugPrint("StackTrace: $stackTrace");
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
              Icons.arrow_back_ios_new,
              color: Color(0xFF1F2937),
              size: 20,
            ),
          ),
          title: Text(
            S.of(context).details,
            style: appFont('Rubik', 
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
                final details = _detailsModel?.data?.menuItemDetails;
                final menu = details?.restaurantMenu;
                if (menu == null) return;
                final name = _pickMenuName(menu, lang);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewStockHistoryScreen(
                      itemName: name.isNotEmpty ? name : 'Item',
                      imageUrl: menu.image,
                      editItemId: widget.menuItemId ?? widget.itemId,
                    ),
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
                'View Stock History',
                style: appFont('Rubik', 
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
                  style: appFont('Rubik', color: Colors.red),
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

    final imageUrl = menu.image != null && menu.image!.isNotEmpty
        ? (menu.image!.startsWith('http://') || menu.image!.startsWith('https://')
            ? menu.image!
            : (ApiConfigs.IMAGE_URL + menu.image!))
        : "";

    final menuName = _pickMenuName(menu, lang);
    final categoryName = _pickCategoryName(menu, lang);
    final description = _pickDescription(menu, lang);

    final isAvailable = (details.availableStatus ?? 1) == 1;
    final tags = _detailsModel?.data?.menuItemTags ?? [];

    String cleanMoney(String val) {
      if (val.endsWith('.00')) {
        return val.substring(0, val.length - 3);
      }
      return val;
    }

    final rawPrice = details.price != null && details.price!.isNotEmpty
        ? details.price!.replaceAll('MRU', '').trim()
        : "-";
    final priceStr = cleanMoney(rawPrice);

    final rawDiscount =
        details.discountPrice != null &&
            details.discountPrice!.isNotEmpty &&
            details.discountPrice != details.price
        ? details.discountPrice!.replaceAll('MRU', '').trim()
        : "";
    final discountStr = cleanMoney(rawDiscount);

    final hasDiscount =
        discountStr.isNotEmpty && (double.tryParse(discountStr) ?? 0) > 0;

    final String boldPrice;
    final String? strikePrice;
    if (hasDiscount) {
      boldPrice = discountStr;
      strikePrice = priceStr;
    } else {
      boldPrice = priceStr;
      strikePrice = null;
    }

    final serialStr =
        details.serialNumber != null && details.serialNumber!.isNotEmpty
        ? details.serialNumber!
        : "-";
    final prepTimeRaw =
        details.preparationTime != null && details.preparationTime!.isNotEmpty
        ? details.preparationTime!
        : "-";
    final prepTimeStr = _formatPrepTime(prepTimeRaw);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Food Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Image.asset(
                      'lib/assets/images/Burger.jpg',
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'lib/assets/images/Burger.jpg',
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 14),

          // 2. Main Details Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Name and Available status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        menuName.isNotEmpty
                            ? menuName
                            : "#${details.id ?? widget.itemId}",
                        style: appFont('Rubik', 
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAvailable ? "Available" : "Out of Stock",
                            style: appFont('Rubik', 
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isAvailable
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Row 2: Category and Serial No
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Category: ",
                              style: appFont('Rubik', 
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: categoryName.isNotEmpty
                                  ? categoryName
                                  : "-",
                              style: appFont('Rubik', 
                                fontSize: 12,
                                color: const Color(0xFF1F2937),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Serial No: ",
                            style: appFont('Rubik', 
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: serialStr,
                            style: appFont('Rubik', 
                              fontSize: 12,
                              color: const Color(0xFF1F2937),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 3: Price (with strikethrough if available) & Preparation Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              boldPrice,
                              style: appFont('Rubik', 
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF5216),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "MRU",
                            style: appFont('Rubik', 
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFF5216),
                            ),
                          ),
                          if (strikePrice != null &&
                              strikePrice.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "$strikePrice MRU",
                                style: appFont('Rubik', 
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8),
                                  decoration: TextDecoration.lineThrough,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Preparation Time: ",
                            style: appFont('Rubik', 
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: prepTimeStr,
                            style: appFont('Rubik', 
                              fontSize: 12,
                              color: const Color(0xFF1F2937),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (prepTimeStr != "-")
                            TextSpan(
                              text: " min",
                              style: appFont('Rubik', 
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              t.nameEn ?? '',
                              style: appFont('Rubik', 
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 14),

                // Description
                Text(
                  "DESCRIPTION",
                  style: appFont('Rubik', 
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description.isNotEmpty
                      ? description
                      : S.of(context).noDescriptionAvailable,
                  style: appFont('Rubik', 
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Edit Item Button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditItemsScreen(itemId: widget.itemId),
                  ),
                ).then((_) => _fetch());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5216),
                elevation: 2,
                shadowColor: const Color(0xFFFF5216).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Edit Item",
                style: appFont('Rubik', 
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // SALES & PERFORMANCE Section (Dynamic Data from Response)
          const SizedBox(height: 22),
          Text(
            "SALES & PERFORMANCE",
            style: appFont('Rubik', 
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4B5563),
              letterSpacing: 0.5,
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeaderWithBadge({
    required String title,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: appFont('Rubik', 
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badgeText,
            style: appFont('Rubik', 
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _optionCard({
    required String title,
    required String price,
    required bool isAvailable,
    String? assetImage,
    String? networkImage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 44,
              height: 44,
              child: networkImage != null && networkImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: networkImage,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Image.asset(
                        assetImage ?? 'lib/assets/images/Burger.jpg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      assetImage ?? 'lib/assets/images/Burger.jpg',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: appFont('Rubik', 
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          Text(
            price,
            style: appFont('Rubik', 
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF5216),
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isAvailable ? "Available" : "Out of Stock",
                style: appFont('Rubik', 
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isAvailable
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
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
              style: appFont('Rubik', 
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const Spacer(),
          Text(
            percent,
            style: appFont('Rubik', 
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

  String _formatPrepTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return "7";
    final trimmed = raw.trim();
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      final total = h * 60 + m;
      if (total > 0) return total.toString();
      final s = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
      return s > 0 ? s.toString() : "0";
    }
    return trimmed;
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
            style: appFont('Rubik', 
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: appFont('Rubik', 
              fontSize: 18,
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
      final isToday =
          dt.year == now.year && dt.month == now.month && dt.day == now.day;
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
                  label: S.of(context).totalOrders,
                  value: totalOrders.toString(),
                  bg: const Color(0xFFF8FAFC),
                  valueColor: const Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statBox(
                  label: S.of(context).revenue,
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
                  S.of(context).averageRating,
                  style: appFont('Rubik', 
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 16, color: const Color(0xFFFF5216)),
                  const SizedBox(width: 6),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: appFont('Rubik', 
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
          _lineStat(
            label: S.of(context).totalReviews,
            value: totalRatings.toString(),
          ),
          const SizedBox(height: 10),
          _lineStat(label: S.of(context).lastPurchase, value: lastPurchaseAgo),
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
            style: appFont('Rubik', 
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
        Text(
          value,
          style: appFont('Rubik', 
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
    final badgeBg = isDelivered
        ? const Color(0xFF15803D)
        : const Color(0xFFFF5216);
    return Container(
      padding: const EdgeInsets.all(16),
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
                      style: appFont('Rubik', 
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF5216),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      merchantName.isNotEmpty ? merchantName : "—",
                      style: appFont('Rubik', 
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDelivered ? "DELIVERED" : "PENDING",
                  style: appFont('Rubik', 
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
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
                  style: appFont('Rubik', 
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                "DATE & TIME",
                style: appFont('Rubik', 
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      "${itemsCount} Items - ",
                      style: appFont('Rubik', 
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      itemsPriceText,
                      style: appFont('Rubik', 
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
                style: appFont('Rubik', 
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kvSimple({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appFont('Rubik', 
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: appFont('Rubik', 
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
          style: appFont('Rubik', 
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: appFont('Rubik', 
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
            style: appFont('Rubik', 
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
