import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/dashboard_controller.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/home/widgets/vendor_stat_card.dart';
import 'package:saimpex_vendor/view/home/popular_items_view_all.dart';

import 'package:saimpex_vendor/view/home/widgets/vendor_membership_card.dart';
import '../../utils/Widgets/custom_app_bar.dart';
import '../../generated/l10n.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: DashboardController(),
      didChangeDependencies: (state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          state.controller?.getDashboard();
        });
      },
      builder: (controller) {
        return CommonBackground(
          appBar: CustomAppBar(
            title: S.of(context).dashboard,
            onTap: () => Get.back(),
          ),
          child: controller.isLoading
              ? const AppLoader()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Membership Card
                      _buildMembershipCard(controller),
                      const SizedBox(height: 24),
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          VendorStatCard(
                            title: S.of(context).todaysOrders,
                            value:
                                controller.dashboardData?.todayOrders
                                    ?.toString() ??
                                "0",
                            icon: Icons.shopping_bag,
                            backgroundColor: const Color(0xFFE5E5FF),
                            iconDecorationColor: const Color(0xFF6B6BFF),
                          ),
                          VendorStatCard(
                            title: S.of(context).totalOrders,
                            value:
                                controller.dashboardData?.totalOrders
                                    ?.toString() ??
                                "0",
                            icon: Icons.payments,
                            backgroundColor: const Color(0xFFD9F9E7),
                            iconDecorationColor: const Color(0xFF00D15D),
                          ),
                          VendorStatCard(
                            title: S.of(context).products,
                            value:
                                controller.dashboardData?.totalProducts
                                    ?.toString() ??
                                "0",
                            icon: Icons.shopping_bag,
                            backgroundColor: const Color(0xFFFFE5D9),
                            iconDecorationColor: const Color(0xFFFF5216),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Revenue Report Section
                      Text(
                        S.of(context).revenueReport,
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRevenueCard(controller),
                      const SizedBox(height: 32),
                      // Popular Items Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).popularItems,
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F1F1F),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PopularItemsViewAll(),
                                ),
                              );
                            },
                            child: Text(
                              S.of(context).viewAll,
                              style: GoogleFonts.rubik(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF5216),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildPopularItems(controller),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMembershipCard(DashboardController controller) {
    final locale =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
    final subName = controller.getSubscriptionName(locale);
    final daysLeft = controller.subscriptionDaysLeft;

    return VendorMembershipCard(
      horizontalPadding: 0,
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.08,
      membershipName: subName.isNotEmpty ? subName : S.of(context).membership,
      expiryText: S.of(context).expiresInDays(daysLeft.toString()),
      isWarning: daysLeft <= 10,
    );
  }

  Widget _buildRevenueCard(DashboardController controller) {
    final revenueTotal = controller.dashboardData?.revenueYearTotal ?? "0.00";
    final report =
        controller.dashboardData?.revenueReport ?? List.filled(12, 0.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).totalRevenue,
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$revenueTotal MRU",
                    style: GoogleFonts.rubik(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
              // Year selector
              PopupMenuButton<String>(
                onSelected: (year) => controller.changeYear(year),
                itemBuilder: (context) => controller.years
                    .map(
                      (y) => PopupMenuItem<String>(
                        value: y,
                        child: Text(y, style: GoogleFonts.rubik(fontSize: 13)),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5D9),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFFF5216).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        controller.selectedYear,
                        style: GoogleFonts.rubik(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Dynamic chart with real revenue data
          Stack(
            alignment: Alignment.topRight,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.18,
                width: double.infinity,
                child: CustomPaint(
                  painter: RevenueChartPainter(
                    revenueData: report,
                    maxValue: controller.maxRevenue,
                  ),
                ),
              ),
              if (double.tryParse(revenueTotal) != null &&
                  double.parse(revenueTotal) > 0)
                Positioned(
                  top: 0,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5216),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$revenueTotal MRU",
                      style: GoogleFonts.rubik(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Jan", "Mar", "Jun", "Sep", "Dec"]
                .map(
                  (e) => Text(
                    e,
                    style: GoogleFonts.rubik(
                      fontSize: 10,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularItems(DashboardController controller) {
    final locale =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
    final items = controller.dashboardData?.popularItems ?? [];

    if (items.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              S.of(context).noPopularItemsFound,
              style: GoogleFonts.rubik(
                color: const Color(0xFF9CA3AF),
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final name = controller.getItemName(item, locale);
          final attrName = controller.getAttributeName(item, locale);
          final orders = "${item.orderCount ?? 0}"+" "+S.of(context).orders;
          final subtitle = attrName.isNotEmpty
              ? "#${item.id}-$attrName"
              : "#${item.id}";
          return Column(
            children: [
              _popularItem(
                name: name,
                subtitle: subtitle,
                orders: orders,
                imageUrl: item.image != null && item.image!.isNotEmpty
                    ? (item.image!.startsWith('http')
                          ? item.image!
                          : ApiConfigs.IMAGE_URL + item.image!)
                    : "",
              ),
              if (index < items.length - 1)
                const Divider(indent: 70, endIndent: 20, height: 1),
            ],
          );
        }),
      ),
    );
  }

  Widget _popularItem({
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
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Text(
            orders,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class RevenueChartPainter extends CustomPainter {
  final List<double> revenueData;
  final double maxValue;

  RevenueChartPainter({required this.revenueData, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF5216)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF5216).withOpacity(0.2),
          const Color(0xFFFF5216).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    final data = revenueData.length >= 12
        ? revenueData.sublist(0, 12)
        : [...revenueData, ...List.filled(12 - revenueData.length, 0.0)];

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalized = maxValue > 0 ? data[i] / maxValue : 0.0;
      final y =
          size.height - (normalized * size.height * 0.85) - size.height * 0.05;
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i + 1].dy,
      );
      path.cubicTo(
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }

    final fillPath = Path();
    fillPath.addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E5E5).withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      double x = i * size.width / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RevenueChartPainter oldDelegate) =>
      oldDelegate.revenueData != revenueData ||
      oldDelegate.maxValue != maxValue;
}
