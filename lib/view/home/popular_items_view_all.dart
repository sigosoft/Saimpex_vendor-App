import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/dashboard_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import '../../utils/Widgets/custom_app_bar.dart';

class PopularItemsViewAll extends StatefulWidget {
  const PopularItemsViewAll({super.key});

  @override
  State<PopularItemsViewAll> createState() => _PopularItemsViewAllState();
}

class _PopularItemsViewAllState extends State<PopularItemsViewAll> {
  final ScrollController _scrollController = ScrollController();
  int _currentMax = 15;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 200) {
        if (mounted) {
          setState(() {
            _currentMax += 15;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: S.of(context).popularItems,
        onTap: () => Get.back(),
      ),
      body: CommonBackground(
        child: GetBuilder<DashboardController>(
          builder: (controller) {
            final items = controller.dashboardData?.popularItems ?? [];

            if (items.isEmpty) {
              return Center(
                child: Text(
                  S.of(context).noPopularItemsFound,
                  style: GoogleFonts.rubik(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
              );
            }

            final paginatedItems = items.take(_currentMax).toList();

            return Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight + 40),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 40),
                itemCount:
                    paginatedItems.length +
                    (items.length > paginatedItems.length ? 1 : 0),
                separatorBuilder: (context, index) {
                  if (index == paginatedItems.length)
                    return const SizedBox.shrink();
                  return const Divider(
                    indent: 70,
                    endIndent: 20,
                    height: 1,
                    color: Color(0xFFF3F4F6),
                  );
                },
                itemBuilder: (context, index) {
                  if (index == paginatedItems.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(child: AppLoader(size: 40)),
                    );
                  }

                  final item = paginatedItems[index];
                  final name = controller.getItemName(item, locale);
                  final attrName = controller.getAttributeName(item, locale);
                  final orders = "${item.orderCount ?? 0}"+" "+S.of(context).orders;
                  final subtitle = attrName.isNotEmpty
                      ? "#${item.id}-$attrName"
                      : "#${item.id}";

                  final imageUrl = item.image != null && item.image!.isNotEmpty
                      ? (item.image!.startsWith('http')
                            ? item.image!
                            : ApiConfigs.IMAGE_URL + item.image!)
                      : "";

                  return _popularItem(
                    context: context,
                    name: name,
                    subtitle: subtitle,
                    orders: orders,
                    imageUrl: imageUrl,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _popularItem({
    required BuildContext context,
    required String name,
    required String subtitle,
    required String orders,
    required String imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: MediaQuery.of(context).size.width * 0.12,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.12,
                        height: MediaQuery.of(context).size.width * 0.12,
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      );
                    },
                  )
                : Image.asset(
                    imageUrl.isNotEmpty
                        ? imageUrl
                        : "lib/assets/images/Food vendor.png",
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: MediaQuery.of(context).size.width * 0.12,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.12,
                        height: MediaQuery.of(context).size.width * 0.12,
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      );
                    },
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              orders,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rubik(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4F46E1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
