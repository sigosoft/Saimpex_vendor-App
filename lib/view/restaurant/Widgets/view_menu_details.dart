import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/model/restaurant_menu_details_model.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/edit_menu_screen.dart';

import '../../../generated/l10n.dart';

class ViewMenuDetails extends StatefulWidget {
  final String restaurantMenuId;

  const ViewMenuDetails({super.key, required this.restaurantMenuId});

  @override
  State<ViewMenuDetails> createState() => _ViewMenuDetailsState();
}

class _ViewMenuDetailsState extends State<ViewMenuDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController(), permanent: false);
      controller.getRestaurantMenuDetails(
        restaurantMenuId: int.tryParse(widget.restaurantMenuId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
          S.of(context).details,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: screenHeight * 0.07,
          child: ElevatedButton(
            onPressed: () {
              final controller = Get.find<ProfileController>();
              final id = controller.restaurantMenuDetails?.restaurantMenu?.id;
              if (id == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMenuScreen(itemId: id.toString()),
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
              S.of(context).editMenu,
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      child: GetBuilder<ProfileController>(
        builder: (controller) {
          final details = controller.restaurantMenuDetails;
          final menu = details?.restaurantMenu;
          if (controller.isRestaurantMenuDetailsLoading && menu == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5216)),
            );
          }

          if (menu == null || details == null) {
            return const SizedBox.shrink();
          }

          final FlutterLocalization localization = FlutterLocalization.instance;
          final lang = localization.currentLocale?.languageCode ?? 'en';

          final menuName = _menuText(menu, lang);
          final categoryName = _categoryText(menu, lang);
          final description = _descriptionText(menu, lang);
          final createdText = _formatDateTime(menu.createdAt);
          final updatedText = _formatDateTime(menu.updatedAt);

          final imageUrl = menu.image.isNotEmpty
              ? (ApiConfigs.IMAGE_URL + menu.image)
              : '';

          final isVeg = menu.isVeg == 1;

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
                          height: screenHeight * 0.26,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _placeholderBurger(screenHeight: screenHeight),
                        )
                      : _placeholderBurger(screenHeight: screenHeight),
                ),
                SizedBox(height: screenHeight * 0.02),

                Text(
                  S.of(context).menuInformation,
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 12),

                _InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelValue(
                        label: S.of(context).menuName,
                        value: menuName.isNotEmpty ? menuName : '#${menu.id}',
                      ),
                      const SizedBox(height: 10),
                      _labelValue(
                        label: S.of(context).category,
                        value: categoryName.isNotEmpty ? categoryName : '—',
                      ),
                      const SizedBox(height: 10),
                      if (Get.find<ProfileController>().vendorType != '2') ...[
                        _labelIsVeg(isVeg: isVeg, value: isVeg ? 'Yes' : 'No'),
                        const SizedBox(height: 14),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: _labelValue(
                              label: S.of(context).createdDate,
                              value: createdText,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _labelValue(
                              label: S.of(context).updatedDate,
                              value: updatedText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        S.of(context).description,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description.isNotEmpty
                            ? description
                            : S.of(context).noDescriptionAvailable,
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF94A3B8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                Text(
                  S.of(context).statistics,
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 12),

                _StatsMiniRow(
                  leftLabel: S.of(context).totalOrders,
                  leftValue: details.totalOrders.toString(),
                  leftColor: const Color(0xFFE0F2FE),
                  rightLabel: S.of(context).totalRevenue,
                  rightValue: details.totalRevenue.toString(),
                  rightColor: const Color(0xFFDCFCE7),
                ),
                const SizedBox(height: 12),
                _StatsMiniRow(
                  leftLabel: S.of(context).averageRating,
                  leftValue: details.averageRating.toString(),
                  leftColor: const Color(0xFFF1F5F9),
                  rightLabel: S.of(context).totalRatings,
                  rightValue: details.totalRatingCount.toString(),
                  rightColor: const Color(0xFFF1F5F9),
                ),

                SizedBox(height: screenHeight * 0.08),
              ],
            ),
          );
        },
      ),
    );
  }

  String _menuText(RestaurantMenu menu, String lang) {
    if (lang == 'fr') return menu.nameFr;
    if (lang == 'ar') return menu.nameAr;
    return menu.nameEn;
  }

  String _categoryText(RestaurantMenu menu, String lang) {
    if (lang == 'fr') return menu.categoryNameFr;
    if (lang == 'ar') return menu.categoryNameAr;
    return menu.categoryNameEn;
  }

  String _descriptionText(RestaurantMenu menu, String lang) {
    if (lang == 'fr') return menu.descriptionFr;
    if (lang == 'ar') return menu.descriptionAr;
    return menu.descriptionEn;
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

  Widget _placeholderBurger({required double screenHeight}) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.26,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.fastfood, size: 60, color: Color(0xFF94A3B8)),
    );
  }
}

// Local helpers for the view UI.
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

Widget _labelValue({required String label, required String value}) {
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
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
      ),
    ],
  );
}

Widget _labelIsVeg({required bool isVeg, required String value}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'IS VEG',
        style: GoogleFonts.rubik(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF94A3B8),
        ),
      ),
      const SizedBox(height: 6),
      Container(
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
      ),
    ],
  );
}

class _StatsMiniRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final Color leftColor;
  final String rightLabel;
  final String rightValue;
  final Color rightColor;

  const _StatsMiniRow({
    required this.leftLabel,
    required this.leftValue,
    required this.leftColor,
    required this.rightLabel,
    required this.rightValue,
    required this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _statBox(label: leftLabel, value: leftValue, color: leftColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statBox(
            label: rightLabel,
            value: rightValue,
            color: rightColor,
          ),
        ),
      ],
    );
  }
}

Widget _statBox({
  required String label,
  required String value,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color,
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
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    ),
  );
}
