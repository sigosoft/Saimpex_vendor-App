import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/utils/widgets/custom_search_box.dart';

import '../../../Utils/Utils.dart';

class VendorWorkingHoursList extends StatelessWidget {
  const VendorWorkingHoursList({super.key});

  @override
  Widget build(BuildContext context) {
    final days = [
      S.of(context).monday,
      S.of(context).tuesday,
      S.of(context).wednesday,
      S.of(context).thursday,
      S.of(context).friday,
      S.of(context).saturday,
      S.of(context).sunday,
    ];

    return Column(
      children: days.map((day) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VendorDetailCard(
            height: MediaQuery.of(context).size.height * 0.08,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    day,
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1EE),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    S.of(context).hr24,
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF5216),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class VendorSectionHeader extends StatelessWidget {
  final String title;

  const VendorSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    String localizedTitle = title;
    if (title == "RESTAURANT DETAILS") {
      localizedTitle = S.of(context).restaurantDetails;
    } else if (title == "BANK DETAILS") {
      localizedTitle = S.of(context).bankDetails;
    } else if (title == "ABOUT THE RESTAURANT") {
      localizedTitle = S.of(context).aboutTheRestaurant;
    } else if (title == "REGISTRATION DETAILS") {
      localizedTitle = S.of(context).registrationDetails;
    } else if (title == "PAYMENT DETAILS") {
      localizedTitle = S.of(context).paymentSummaryDetails;
    } else if (title == "OWNER IDENTITY PROOF") {
      localizedTitle = S.of(context).ownerIdentityProof;
    } else if (title == "CERTIFICATES") {
      localizedTitle = S.of(context).certificates;
    } else if (title == "RATING & REVIEWS") {
      localizedTitle = S.of(context).ratingReviews;
    } else if (title == "MARK LEAVE") {
      localizedTitle = S.of(context).markLeave;
    } else if (title == "LEAVES HISTORY") {
      localizedTitle = S.of(context).leavesHistory;
    } else if (title == "WORKING HOURS") {
      localizedTitle = S.of(context).workingHours;
    } else if (title == "ALL MENUS") {
      localizedTitle = S.of(context).allMenus;
    } else if (title == "ALL ITEMS") {
      localizedTitle = S.of(context).allItems;
    } else if (title == "MENU BULK IMPORT") {
      localizedTitle = S.of(context).menuBulkImport;
    } else if (title == "BASKETS") {
      localizedTitle = S.of(context).basket;
    } else if (title == "RECEIVED PAYOUTS") {
      localizedTitle = S.of(context).receivedPayouts;
    } else if (title == "STORE REPORTS") {
      localizedTitle = S.of(context).storeReports;
    }

    return Text(
      localizedTitle,
      style: GoogleFonts.rubik(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1F1F1F),
      ),
    );
  }
}

class VendorDetailCard extends StatelessWidget {
  final double? height;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const VendorDetailCard({
    super.key,
    this.height,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: child,
    );
  }
}

class VendorDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;
  final bool isBoldValue;

  const VendorDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isStatus = false,
    this.isBoldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    String localizedLabel = label;
    if (label == "Name") localizedLabel = S.of(context).name;
    if (label == "Owner") localizedLabel = S.of(context).owner;
    if (label == "ID") localizedLabel = S.of(context).idNumber;
    if (label == "Contact") localizedLabel = S.of(context).contact;
    if (label == "Email") localizedLabel = S.of(context).email;
    if (label == "Status") localizedLabel = S.of(context).status;
    if (label == "Address") localizedLabel = S.of(context).address;
    if (label == "Holder Name") localizedLabel = S.of(context).holderName;
    if (label == "IBAN Number") localizedLabel = S.of(context).ibanNumber;
    if (label == "SWIFT Code") localizedLabel = S.of(context).swiftCode;
    if (label == "Category") localizedLabel = S.of(context).categoryLabel;
    if (label == "Reg. Number") localizedLabel = S.of(context).regNumber;
    if (label == "Reg. Date") localizedLabel = S.of(context).regDate;
    if (label == "GST Number") localizedLabel = S.of(context).gstNumber;
    if (label == "Commission %") {
      localizedLabel = S.of(context).commissionPercentage;
    }
    if (label == "Total Profit") localizedLabel = S.of(context).totalProfit;
    if (label == "Service Delivery Charge") {
      localizedLabel = S.of(context).serviceDeliveryCharge;
    }
    if (label == "Restaurant Commission Percentage per Order") {
      localizedLabel = S.of(context).restaurantCommission;
    }
    if (label == "Gst/Vat") localizedLabel = S.of(context).gstVat;
    if (label == "Packaging Cost") localizedLabel = S.of(context).packagingCost;
    if (label == "Bank Name") localizedLabel = S.of(context).bankName;
    if (label == "Account Name") localizedLabel = S.of(context).accountName;
    if (label == "Account Number") localizedLabel = S.of(context).accountNumber;
    if (label == "Trade License No") {
      localizedLabel = S.of(context).tradeLicenseNo;
    }
    if (label == "Vat/Gst Number") localizedLabel = S.of(context).vatGstNumber;
    if (label == "National Id Type") {
      localizedLabel = S.of(context).nationalIdType;
    }
    if (label == "National Id Number") {
      localizedLabel = S.of(context).nationalIdNumber;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              localizedLabel,
              style: GoogleFonts.rubik(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Text(
                value,
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF166534),
                ),
              ),
            )
          else
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.right,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VendorImageCard extends StatelessWidget {
  final double? height;
  final String? imageUrl;

  const VendorImageCard({super.key, this.height, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final String? fullUrl = imageUrl != null && imageUrl!.isNotEmpty
        ? (imageUrl!.startsWith('http')
              ? imageUrl
              : '${ApiConfigs.IMAGE_URL}$imageUrl')
        : null;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: height ?? MediaQuery.of(context).size.height * 0.14,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: fullUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                fullUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF9CA3AF),
                    size: 36,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const AppLoader();
                },
              ),
            )
          : const Center(
              child: Icon(
                Icons.image_outlined,
                color: Color(0xFF9CA3AF),
                size: 36,
              ),
            ),
    );
  }
}

class VendorReviewItem extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String review;
  final String orderId;

  const VendorReviewItem({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
    required this.review,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.18,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFDCFCE7),
                child: Text(
                  name.isNotEmpty ? name[0] : "",
                  style: GoogleFonts.rubik(
                    color: const Color(0xFF166534),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: const Color(0xFFF59E0B),
                              size: 14,
                            );
                          }),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.rubik(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                formatOrderPlacedAt(DateTime.parse(date.toString())),
                style: GoogleFonts.rubik(
                  fontSize: 10,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: GoogleFonts.rubik(
              fontSize: 13,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  S.of(context).orderColon,
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    orderId,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
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

class VendorLeaveTile extends StatelessWidget {
  final String dateRange;
  final String reason;
  final String status;
  final bool isUpcoming;
  final VoidCallback? onCancelLeave;

  const VendorLeaveTile({
    super.key,
    required this.dateRange,
    required this.reason,
    required this.status,
    required this.isUpcoming,
    this.onCancelLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateRange,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    Text(
                      reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 10,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.rubik(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isUpcoming
                        ? const Color(0xFF4F46E1)
                        : const Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton(
                onPressed: onCancelLeave,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFCCBD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Cancel Leave",
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF5216),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VendorSearchRow extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const VendorSearchRow({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomSearchBox(
            hintText: S.of(context).searchByIdName,
            boxColor: Colors.white,
            controller: controller,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: const Icon(Icons.tune, color: Color(0xFF64748B), size: 24),
        ),
      ],
    );
  }
}

class VendorCategoryAddRow extends StatelessWidget {
  final List<RestaurantCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?>? onCategoryChanged;
  final VoidCallback onAddPressed;

  const VendorCategoryAddRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.055,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedCategoryId,
                isExpanded: true,
                hint: Text(
                  "All Categories",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      "All Categories",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  ...categories.map(
                    (c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(
                        c.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                ],
                onChanged: onCategoryChanged,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: OutlinedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add, color: Color(0xFFFF5216), size: 14),
            label: Text(
              S.of(context).addMenuTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: const Color(0xFFFF5216),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF5216), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows availability label: status 1 = Out of stock, 2 = Available.
class _AvailabilityChip extends StatelessWidget {
  final int status;

  const _AvailabilityChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isAvailable = status == 2;
    final label = isAvailable
        ? S.of(context).availableStatus
        : S.of(context).outOfStock;
    final color = isAvailable
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.rubik(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class VendorRichCard extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final String price;
  final String? originalPrice;
  final String? imageUrl;
  final String itemId;
  final bool isMenu;
  final List<RestaurantCategory>? categories;

  /// 1 = Out of stock, 2 = Available. When null, availability is not shown.
  final int? availabilityStatus;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const VendorRichCard({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    required this.itemId,
    required this.isMenu,
    this.categories,
    this.availabilityStatus,
    required this.onViewDetails,
    required this.onEdit,
    this.onDelete,
  });

  String get _displayCategory {
    if (categories == null || category.isEmpty) return category;
    // Support plain id "7" or API array string "[7]", "['7']", etc.
    int? categoryId = int.tryParse(category.trim());
    if (categoryId == null) {
      final firstNumber = RegExp(r'\d+').firstMatch(category);
      if (firstNumber != null) {
        categoryId = int.tryParse(firstNumber.group(0)!);
      }
    }
    if (categoryId == null) return category;
    try {
      final match = categories!.firstWhere((c) => c.id == categoryId);
      final name = match.name?.trim();
      return (name != null && name.isNotEmpty) ? name : category;
    } catch (_) {
      return category;
    }
  }

  /// Category text to show in the bubble; never empty so the bubble always shows a name.
  String get _displayCategoryLabel {
    final value = _displayCategory.trim();
    return value.isEmpty ? '—' : value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null && imageUrl!.isNotEmpty
                            ? Image.network(
                                imageUrl!.startsWith('http')
                                    ? imageUrl!
                                    : "${ApiConfigs.IMAGE_URL}$imageUrl",
                                width: MediaQuery.of(context).size.width * 0.22,
                                height:
                                    MediaQuery.of(context).size.width * 0.22,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const _VendorDefaultImage(),
                              )
                            : const _VendorDefaultImage(),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "New Arrival",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ID: # $id",
                          style: GoogleFonts.rubik(
                            fontSize: 10,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rubik(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F1F1F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1EE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _displayCategoryLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rubik(
                              fontSize: 10,
                              color: const Color(0xFFFF5216),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                price,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.rubik(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F1F1F),
                                ),
                              ),
                            ),
                            if (originalPrice != null) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  originalPrice!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.rubik(
                                    fontSize: 11,
                                    color: const Color(0xFF94A3B8),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                            if (availabilityStatus != null) ...[
                              const SizedBox(width: 12),
                              _AvailabilityChip(status: availabilityStatus!),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.05,
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF5216)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    S.of(context).viewDetails,
                    style: GoogleFonts.rubik(
                      color: const Color(0xFFFF5216),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: -8,
            right: -8,
            child: PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: const Icon(Icons.edit_outlined, size: 20),
                    title: Text("Edit", style: GoogleFonts.rubik(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                    title: Text(
                      "Delete",
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                    contentPadding: EdgeInsets.zero,
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

class _VendorDefaultImage extends StatelessWidget {
  const _VendorDefaultImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.fastfood, color: Color(0xFFFF5216)),
    );
  }
}

class VendorAddNewItemButton extends StatelessWidget {
  final VoidCallback onPressed;

  const VendorAddNewItemButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.06,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5216),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          S.of(context).addNewItem,
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class VendorBulkImportInstructions extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const VendorBulkImportInstructions({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
            ),
            child: Row(
              children: [
                Text(
                  "Instructions",
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _instructionBlock(
                  index: '1',
                  title: 'Download Template',
                  body:
                      'Download the template file and fill it with proper data.',
                ),
                const SizedBox(height: 12),
                _instructionBlock(
                  index: '2',
                  title: 'Select Category',
                  body:
                      'Once you have downloaded and filled the template, select the corresponding category and upload the file.',
                ),
                const SizedBox(height: 12),
                _instructionBlock(
                  index: '3',
                  title: 'Attributes Reference',
                  body:
                      'After Attributes reference, you can edit the attributes list below and use the attribute ID in the attribute_id column along with its corresponding value.',
                ),
                const SizedBox(height: 12),
                _instructionBlock(
                  index: '4',
                  title: 'Post-Upload Editing',
                  body:
                      'After uploading, you need to edit the items individually to set images and variations.',
                ),
                const SizedBox(height: 12),
                _instructionBlock(
                  index: '5',
                  title: 'Image File Naming',
                  body:
                      'Image file names must start with restaurant/menus/{filename.extension} (e.g., restaurant/menus/pizza.jpg).',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Available Attributes",
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1EE),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFFF5216),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "3 ATTRIBUTES",
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF5216),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _attributesTable(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

Widget _instructionBlock({
  required String index,
  required String title,
  required String body,
}) {
  return RichText(
    text: TextSpan(
      style: GoogleFonts.rubik(
        fontSize: 13,
        height: 1.6,
        color: const Color(0xFF6B7280),
      ),
      children: [
        TextSpan(
          text: '$index. ',
          style: GoogleFonts.rubik(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        TextSpan(
          text: title,
          style: GoogleFonts.rubik(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const TextSpan(text: '\n'),
        TextSpan(text: body),
      ],
    ),
  );
}

Widget _attributesTable() {
  TextStyle headerStyle = GoogleFonts.rubik(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF111827),
  );
  TextStyle valueStyle = GoogleFonts.rubik(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF374151),
  );

  Widget headerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ID", style: headerStyle),
          Text("NAME", style: headerStyle),
        ],
      ),
    );
  }

  Widget dataRow(String id, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(id, style: valueStyle),
          Text(name, style: valueStyle),
        ],
      ),
    );
  }

  return Container(
    color: Colors.white,
    child: Column(
      children: [
        headerRow(),
        dataRow('1', 'Full'),
        dataRow('2', 'Half'),
        dataRow('4', 'Quarter'),
        const SizedBox(height: 2),
      ],
    ),
  );
}

class VendorImportStep extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;

  const VendorImportStep({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFFF5216),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: GoogleFonts.rubik(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class VendorBasketItem extends StatelessWidget {
  final String name;
  final String count;
  final String status;

  const VendorBasketItem({
    super.key,
    required this.name,
    required this.count,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return VendorDetailCard(
      height: MediaQuery.of(context).size.height * 0.12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              Text(
                count,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (status == "Active" || status == S.of(context).activeLabel)
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.rubik(
                fontSize: 12,
                color:
                    (status == "Active" || status == S.of(context).activeLabel)
                    ? const Color(0xFF166534)
                    : const Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VendorPayoutItem extends StatelessWidget {
  final String id;
  final String date;
  final String amount;

  const VendorPayoutItem({
    super.key,
    required this.id,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return VendorDetailCard(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                id,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              Text(
                date,
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: GoogleFonts.rubik(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF166534),
            ),
          ),
        ],
      ),
    );
  }
}

class VendorProfileHeaderCard extends StatelessWidget {
  final String name;
  final String rating;

  const VendorProfileHeaderCard({
    super.key,
    required this.name,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.width * 0.2,
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "R1",
                style: GoogleFonts.rubik(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF5216),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF166534),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

class VendorMenuButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const VendorMenuButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  String _getLocalizedMenuTitle(BuildContext context) {
    if (title == "Account") return S.of(context).account;
    if (title == "Working Hours") return S.of(context).workingHours;
    if (title == "Leaves") return S.of(context).leaves;
    if (title == "Menu") return S.of(context).menu;
    if (title == "Items") return S.of(context).items;
    if (title == "Menu Bulk Import") return S.of(context).menuBulkImport;
    if (title == "Basket") return S.of(context).basket;
    if (title == "Received Payouts") return S.of(context).receivedPayouts;
    if (title == "Restaurant Reports") return S.of(context).restaurantReports;
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.25,
          minHeight: MediaQuery.of(context).size.height * 0.05,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF5216) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF5216)
                : const Color.fromARGB(255, 200, 202, 203),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            _getLocalizedMenuTitle(context),
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class VendorLeaveForm extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final TextEditingController reasonController;
  final String Function(DateTime?) formatDate;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onMarkLeave;

  const VendorLeaveForm({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.reasonController,
    required this.formatDate,
    required this.onFromTap,
    required this.onToTap,
    required this.onMarkLeave,
  });

  @override
  Widget build(BuildContext context) {
    return VendorDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "From Date",
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onFromTap,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDate(fromDate),
                              style: GoogleFonts.rubik(
                                fontSize: 13,
                                color: const Color(0xFF1F1F1F),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: Color(0xFF1F1F1F),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "To Date",
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onToTap,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDate(toDate),
                              style: GoogleFonts.rubik(
                                fontSize: 13,
                                color: const Color(0xFF1F1F1F),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: Color(0xFF1F1F1F),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Reason For Leave",
            style: GoogleFonts.rubik(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: MediaQuery.of(context).size.height * 0.12,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: reasonController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "e.g. Annual vacation, renovation...",
                hintStyle: GoogleFonts.rubik(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8).withOpacity(0.6),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: const Color(0xFF1F1F1F),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: onMarkLeave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5216),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Mark Leave",
                style: GoogleFonts.rubik(
                  fontSize: 14,
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
}
