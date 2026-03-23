import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/edit_items_screen.dart';
import 'package:saimpex_vendor/view/restaurant/edit_menu_screen.dart';

class MenuItemDetailsScreen extends StatefulWidget {
  final String itemId;
  final bool isMenu;

  const MenuItemDetailsScreen({
    super.key,
    required this.itemId,
    this.isMenu = true,
  });

  @override
  State<MenuItemDetailsScreen> createState() => _MenuItemDetailsScreenState();
}

class _MenuItemDetailsScreenState extends State<MenuItemDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileController = Get.find<ProfileController>();
      profileController.getRestaurantMenuDetails(
        restaurantMenuId: int.tryParse(widget.itemId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final profileController = Get.find<ProfileController>();
    return CommonBackground(
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
          S.of(context).basketDetailsTitle,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: false,
      ),
      child: GetBuilder<ProfileController>(
        builder: (_) {
          if (profileController.isRestaurantMenuDetailsLoading &&
              profileController.restaurantMenuDetails == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5216)),
            );
          }
          final details = profileController.restaurantMenuDetails;
          final menu = details?.restaurantMenu;
          final lang = profileController.localization.currentLocale?.languageCode;
          final name = _menuName(menu, lang);
          final categoryName = _categoryName(menu, lang);
          final imageUrl = menu?.image != null && menu!.image.isNotEmpty
              ? ApiConfigs.IMAGE_URL + menu.image
              : null;
          final isAvailable = menu?.approvalStatus == 1;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: screenHeight * 0.25,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(context),
                        )
                      : _placeholderImage(context),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name.isNotEmpty ? name : '#${widget.itemId}',
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                    _statusBadge(
                      context,
                      isAvailable
                          ? S.of(context).availableStatus
                          : S.of(context).unavailable,
                      isAvailable,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                _propertyRow(context, S.of(context).itemIdLabel, '# ${widget.itemId}'),
                if (menu != null) ...[
                  _propertyRow(
                    context,
                    S.of(context).categoryLabel,
                    categoryName.isNotEmpty ? categoryName : '—',
                  ),
                ],
                SizedBox(height: screenHeight * 0.032),
                _sectionHeader(context, S.of(context).salesPerformanceHeader),
                SizedBox(height: screenHeight * 0.012),
                _buildSalesPerformanceCard(
                  context,
                  totalOrders: details?.totalOrders ?? 0,
                  totalRevenue: details?.totalRevenue ?? 0,
                  averageRating: details?.averageRating ?? 0,
                  totalRatingCount: details?.totalRatingCount ?? 0,
                ),
                SizedBox(height: screenHeight * 0.032),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionHeader(context, S.of(context).itemOrdersHeader),
                    Text(
                      S.of(context).viewAll,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFF5216),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.012),
                _buildOrderCardsList(context, details?.orderDetails ?? []),
                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(screenHeight * 0.016),
        child: SizedBox(
          width: double.infinity,
          height: screenHeight * 0.06,
          child: ElevatedButton(
            onPressed: () {
              debugPrint("Button tapped");
              if (widget.isMenu) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMenuScreen(itemId: widget.itemId),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditItemsScreen(itemId: widget.itemId),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5216),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              S.of(context).updateDetailsButton,
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _menuName(dynamic menu, String? lang) {
    if (menu == null) return '';
    if (lang == 'fr') return menu.nameFr ?? menu.nameEn ?? '';
    if (lang == 'ar') return menu.nameAr ?? menu.nameEn ?? '';
    return menu.nameEn ?? '';
  }

  String _categoryName(dynamic menu, String? lang) {
    if (menu == null) return '';
    if (lang == 'fr') return menu.categoryNameFr ?? menu.categoryNameEn ?? '';
    if (lang == 'ar') return menu.categoryNameAr ?? menu.categoryNameEn ?? '';
    return menu.categoryNameEn ?? '';
  }

  Widget _placeholderImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.25,
      color: const Color(0xFFF1F5F9),
      child: const Icon(
        Icons.fastfood,
        size: 60,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String text, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.rubik(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _propertyRow(
    BuildContext context,
    String label,
    String value, {
    bool isPrice = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.rubik(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isPrice
                  ? const Color(0xFFFF5216)
                  : const Color(0xFF1F1F1F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.rubik(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1F1F1F),
      ),
    );
  }

  Widget _buildSalesPerformanceCard(
    BuildContext context, {
    required int totalOrders,
    required int totalRevenue,
    required int averageRating,
    required int totalRatingCount,
  }) {
    final ratingStr = totalRatingCount > 0
        ? (averageRating / totalRatingCount).toStringAsFixed(1)
        : '0';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatMiniCard(
                  context,
                  S.of(context).totalOrdersStat,
                  totalOrders.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatMiniCard(
                  context,
                  S.of(context).revenueLabel,
                  totalRevenue >= 1000
                      ? '${(totalRevenue / 1000).toStringAsFixed(1)}k'
                      : totalRevenue.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _propertyRowWithIcon(
            context,
            S.of(context).averageRatingLabel,
            ratingStr,
            Icons.star,
            const Color(0xFFF59E0B),
          ),
          _propertyRowSimple(
            context,
            S.of(context).totalReviewsStat,
            totalRatingCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCardsList(BuildContext context, List<dynamic> orderDetails) {
    if (orderDetails.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Center(
          child: Text(
            S.of(context).noOrders,
            style: GoogleFonts.rubik(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      );
    }
    return Column(
      children: orderDetails.take(5).map((e) {
        final map = e is Map ? e as Map<String, dynamic> : <String, dynamic>{};
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(
            context,
            orderId: map['order_id']?.toString() ?? map['id']?.toString() ?? '—',
            customerName: map['customer_name']?.toString() ??
                map['user_name']?.toString() ??
                '—',
            itemsTotal: map['total']?.toString() ??
                map['order_total']?.toString() ??
                '—',
            dateTime: map['created_at']?.toString() ??
                map['order_date']?.toString() ??
                '—',
            status: map['status']?.toString() ?? 'delivered',
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderCard(
    BuildContext context, {
    required String orderId,
    required String customerName,
    required String itemsTotal,
    required String dateTime,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).orderIdLabel(orderId),
                style: GoogleFonts.rubik(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF5216),
                ),
              ),
              _buildDeliverBadge(context, status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            customerName,
            style: GoogleFonts.rubik(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).itemsTotalLabel,
                    style: GoogleFonts.rubik(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$itemsTotal ${S.of(context).items}',
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF5216),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    S.of(context).dateTimeLabel,
                    style: GoogleFonts.rubik(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateTime,
                    style: GoogleFonts.rubik(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverBadge(BuildContext context, String status) {
    final isDelivered = status.toLowerCase().contains('deliver');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(isDelivered ? 0xFF166534 : 0xFF64748B),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.rubik(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatMiniCard(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F1F1F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _propertyRowWithIcon(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _propertyRowSimple(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.rubik(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F1F1F),
            ),
          ),
        ],
      ),
    );
  }

}
