import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/basket_controller.dart';
import 'package:saimpex_vendor/model/basket_details_model.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';

import 'redeemed_customers.dart';

class BasketDetailsScreen extends StatefulWidget {
  const BasketDetailsScreen({super.key, required this.basketId});

  final int basketId;

  @override
  State<BasketDetailsScreen> createState() => _BasketDetailsScreenState();
}

class _BasketDetailsScreenState extends State<BasketDetailsScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.isRegistered<BasketController>()
        ? Get.find<BasketController>()
        : Get.put(BasketController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getBasketDetail(context, basketId: widget.basketId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BasketController>(
      builder: (controller) {
        final detail = controller.basketDetailsModel?.data;
        final isLoading =
            controller.isBasketDetailsLoading && detail == null;

        if (isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isActive = (detail?.status ?? 0) == 1;
        final vendorName = _pickLocalizedString(
          context,
          detail?.vendorName,
          detail?.vendorNameAr,
          detail?.vendorNameFr,
        );
        final basketInitials = _initialsFromName(vendorName);
        final createdAtStr = detail?.createdAt != null
            ? DateFormat('MMM dd, yyyy').format(detail!.createdAt!)
            : '';

        final priceStr = detail?.price?.isNotEmpty == true
            ? '${detail!.price} MRU'
            : '${detail?.redeemPoints ?? 0} MRU';

        final basketItems = detail?.basketItems ?? const <BasketItem>[];

        return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context).basketDetailsTitle,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: false,
      ),
      body: CommonBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).redeemedCustomersHeader,
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => RedeemedCustomersScreen(
                            basketId: widget.basketId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5216),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(110, 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      S.of(context).viewAll,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Header Details Container
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.55,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              basketInitials,
                              style: GoogleFonts.rubik(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF5216),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    vendorName.isNotEmpty
                                        ? vendorName
                                        : S.of(context).restaurantOne,
                                    style: GoogleFonts.rubik(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1F1F1F),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFFFE4E6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isActive ? S.of(context).active : 'Blocked',
                                      style: GoogleFonts.rubik(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isActive
                                            ? const Color(0xFF22C55E)
                                            : const Color(0xFF991B1B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${S.of(context).basketIdLabel(detail?.id?.toString() ?? '')} • ${S.of(context).createdLabel(createdAtStr)}",
                                style: GoogleFonts.rubik(
                                  fontSize: 10,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Info Grid
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _infoBox(
                                context,
                                S.of(context).vendor.toUpperCase(),
                                vendorName.isNotEmpty
                                    ? vendorName
                                    : S.of(context).restaurantOne,
                              ),
                              const SizedBox(width: 12),
                              _infoBox(
                                context,
                                S.of(context).priceLabel,
                                priceStr,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _infoBox(
                                context,
                                S.of(context).redeemPointsLabel,
                                (detail?.redeemPoints ?? 0).toString(),
                              ),
                              const SizedBox(width: 12),
                              _infoBox(
                                context,
                                S.of(context).quantity.toUpperCase(),
                                (detail?.quantity ?? 0).toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _infoBox(
                                context,
                                S.of(context).itemsCountLabel,
                                '${detail?.basketItemsCount ?? 0} ${S.of(context).items}',
                              ),
                              const SizedBox(width: 12),
                              _infoBox(
                                context,
                                S.of(context).ordersCountLabel,
                                (detail?.basketOrdersCount ?? 0).toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _infoBox(
                                context,
                                S.of(context).address.toUpperCase(),
                                (detail?.vendorAddress ?? '-').toString(),
                                isFullWidth: true,
                                maxLines: 2,
                              ),
                            ],
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
                  Text(
                    "${S.of(context).basketItemsHeader} ",
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                  Text(
                    '(${basketItems.length})',
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...basketItems.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;

                final name = _pickLocalizedString(
                  context,
                  item.menuNameEn,
                  item.menuNameAr,
                  item.menuNameFr,
                );
                final desc = _pickLocalizedString(
                  context,
                  item.menuDescriptionEn?.toString(),
                  item.menuDescriptionAr?.toString(),
                  item.menuDescriptionFr?.toString(),
                );
                final resolvedImage = (item.menuImage ?? '').isNotEmpty
                    ? (item.menuImage!.startsWith('http')
                        ? item.menuImage!
                        : '${ApiConfigs.IMAGE_URL}${item.menuImage!}')
                    : '';

                final qtyVal = item.quantity?.toString() ?? '0';
                return Column(
                  children: [
                    _buildBasketItemTile(
                      context,
                      name.isNotEmpty ? name : '-',
                      desc.isNotEmpty ? desc : "",
                      resolvedImage,
                      (item.menuId ?? 0).toString(),
                      S.of(context).qtyLabel(qtyVal),
                    ),
                    if (i != basketItems.length - 1)
                      const SizedBox(height: 12),
                  ],
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
        );
      },
    );
  }

  String _initialsFromName(String name) {
    final t = name.trim();
    if (t.isEmpty) return 'R1';
    final parts =
        t.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return t.length >= 2 ? t.substring(0, 2).toUpperCase() : t.toUpperCase();
  }

  String _pickLocalizedString(
    BuildContext context,
    String? en,
    String? ar,
    String? fr,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ar') return ar ?? en ?? '';
    if (lang == 'fr') return fr ?? en ?? '';
    return en ?? ar ?? fr ?? '';
  }

  Widget _infoBox(
    BuildContext context,
    String label,
    String value, {
    bool isFullWidth = false,
    int maxLines = 1,
  }) {
    return Expanded(
      flex: isFullWidth ? 2 : 1,
      child: Container(
        height: isFullWidth
            ? (maxLines > 1 ? 90 : 70)
            : 64,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.rubik(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.rubik(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F1F1F),
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasketItemTile(
    BuildContext context,
    String name,
    String desc,
    String image,
    String id,
    String qty,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.15,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image.isEmpty
                ? const SizedBox(
                    width: 80,
                    height: 80,
                    child: Icon(Icons.image_not_supported),
                  )
                : (image.startsWith('http')
                    ? Image.network(
                        image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                      )
                    : Image.asset(
                        image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                      )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ID: #$id",
                  style: GoogleFonts.rubik(
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    qty,
                    style: GoogleFonts.rubik(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
