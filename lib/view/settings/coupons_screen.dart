import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/view/settings/add_coupon_screen.dart';
import 'package:saimpex_vendor/utils/widgets/custom_search_box.dart';
import 'package:saimpex_vendor/controller/coupon_controller.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CouponController _couponController =
      Get.isRegistered<CouponController>()
      ? Get.find<CouponController>()
      : Get.put(CouponController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _couponController.fetchCoupons();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 300 &&
          _couponController.hasNextPage &&
          !_couponController.isLoading &&
          !_couponController.isLoadMoreRunning) {
        _couponController.fetchCoupons(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          S.of(context).coupons,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Center(
              child: GestureDetector(
                onTap: () => Get.to(() => const AddCouponScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorPrimary, width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: colorPrimary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        S.of(context).addCoupon,
                        style: GoogleFonts.rubik(
                          color: colorPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      body: GetBuilder<CouponController>(
        builder: (controller) {
          return Column(
            children: [
              const SizedBox(height: 16),
              // Search Box
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomSearchBox(
                    hintText: S.of(context).searchCoupon,
                    controller: _searchController,
                    boxColor: Colors.white,
                    width: screenWidth * 0.92,
                    height: 48,
                    onChanged: (value) {
                      // Search logic
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Coupon List
              Expanded(
                child: RefreshIndicator(
                  color: colorPrimary,
                  onRefresh: () => controller.fetchCoupons(),
                  child: controller.isLoading
                      ? const Center(child: AppLoader())
                      : controller.couponsList.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: screenHeight * 0.6,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/nodata.png',
                                  width: 200,
                                  height: 200,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  S.of(context).noCouponsFound,
                                  style: GoogleFonts.rubik(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8E99AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                          ),
                          itemCount: controller.couponsList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == controller.couponsList.length) {
                              if (controller.isLoadMoreRunning) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(child: AppLoader()),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            }
                            return _buildCouponCard(
                              controller.couponsList[index],
                              screenWidth,
                              screenHeight,
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(
    dynamic couponData,
    double screenWidth,
    double screenHeight,
  ) {
    final Map<String, dynamic> coupon = Map<String, dynamic>.from(couponData);

    // Map dynamic data to UI fields
    final String name =
        coupon['name_en']?.toString() ??
        coupon['name_ar']?.toString() ??
        coupon['name_fr']?.toString() ??
        'N/A';
    final int statusInt =
        int.tryParse(coupon['status']?.toString() ?? '0') ?? 0;
    final String status = statusInt == 1
        ? S.of(context).active
        : S.of(context).inactive;
    final String code = coupon['code']?.toString() ?? 'N/A';
    final int typeInt = int.tryParse(coupon['type']?.toString() ?? '1') ?? 1;
    final String type = typeInt == 2
        ? S.of(context).percentage.toUpperCase()
        : S.of(context).amount.toUpperCase();
    final String discountValue = coupon['discount_value']?.toString() ?? '0.00';
    final String discount = typeInt == 2 ? '$discountValue%' : discountValue;
    final String count = coupon['count']?.toString() ?? '0';
    final String validUpto = coupon['valid_upto']?.toString() ?? 'N/A';
    final String createdOn =
        coupon['formatted_created_on']?.toString() ?? 'N/A';
    final String updatedOn =
        coupon['formatted_updated_on']?.toString() ?? 'N/A';

    return Container(
      width: screenWidth * 0.92,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Row(
                children: [
                  _buildBadge(
                    status,
                    statusInt == 1 ? lightgreen : Colors.grey.withOpacity(0.2),
                    statusInt == 1 ? greenlight : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      _showPopupMenu(details.globalPosition, coupon);
                    },
                    child: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF8E99AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Code Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${S.of(context).codeLabel}:  ',
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    TextSpan(
                      text: code,
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBadge(type, lightOrange.withOpacity(0.4), colorPrimary),
            ],
          ),
          const SizedBox(height: 12),
          // Dotted Divider (using thin gray line as fallback for dot)
          _buildDottedDivider(),
          const SizedBox(height: 16),
          // Details Row
          IntrinsicHeight(
            child: Row(
              children: [
                _buildDetailItem(
                  S.of(context).discountLabel,
                  discount,
                  screenWidth,
                ),
                _buildVerticalDivider(),
                _buildDetailItem(S.of(context).countLabel, count, screenWidth),
                _buildVerticalDivider(),
                _buildDetailItem(
                  S.of(context).validUptoLabel,
                  validUpto,
                  screenWidth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDottedDivider(),
          const SizedBox(height: 16),
          // Created/Updated On
          _buildDateRow('${S.of(context).createdOnLabel}:', createdOn),
          const SizedBox(height: 8),
          _buildDateRow('${S.of(context).updatedOnLabel}:', updatedOn),
          const SizedBox(height: 20),
          // Status Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                _showUpdateStatusDialog(
                  context,
                  int.tryParse(coupon['id']?.toString() ?? '0') ?? 0,
                  statusInt,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                S.of(context).updateCouponStatus,
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.rubik(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.1));
  }

  Widget _buildDottedDivider() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3)),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, double screenWidth) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8E99AF),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8E99AF),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.rubik(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  void _showPopupMenu(Offset offset, Map<String, dynamic> coupon) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(offset, offset),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          height: 35,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Text(
                S.of(context).edit,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'delete',
          height: 35,
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Text(
                S.of(context).delete,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
        ),
      ],
    ).then((String? value) {
      if (value == 'edit') {
        Get.to(() => AddCouponScreen(couponData: coupon));
      } else if (value == 'delete') {
        _showDeleteDialog(
          context,
          int.tryParse(coupon['id']?.toString() ?? '0') ?? 0,
        );
      }
    });
  }

  void _showDeleteDialog(BuildContext context, int couponId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  S.of(context).areYouSureYouWantToDeleteThisCoupon,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          S.of(context).no,
                          style: GoogleFonts.rubik(
                            color: colorPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _couponController.deleteCoupon(
                            context: context,
                            couponId: couponId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          S.of(context).yes,
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    int couponId,
    int currentStatus,
  ) {
    final int nextStatus = currentStatus == 1 ? 2 : 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  currentStatus == 1
                      ? S.of(context).areYouSureYouWantToBlockThisCoupon
                      : S.of(context).areYouSureYouWantToActivateThisCoupon,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          S.of(context).no,
                          style: GoogleFonts.rubik(
                            color: colorPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          final couponController =
                              Get.isRegistered<CouponController>()
                              ? Get.find<CouponController>()
                              : Get.put(CouponController());
                          couponController.updateCouponStatus(
                            context,
                            couponId,
                            nextStatus,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          S.of(context).yes,
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
