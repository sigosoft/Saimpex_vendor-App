import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../generated/l10n.dart';
import '../../utils/widgets/common_background.dart';
import '../payout/payout_list_screen.dart';
import '../reports/sales_reports.dart';
import 'add_menu_screen.dart';
import 'add_items_screen.dart';
import 'edit_menu_screen.dart';
import 'edit_items_screen.dart';
import 'menu_item_details_screen.dart';
import 'basket_details_screen.dart';
import 'rating_reviews_screen.dart';
import 'leave_history_screen.dart';
import 'Widgets/vendor_restaurant_reusable_widgets.dart';
import '../../controller/profile_controller.dart';
import '../../controller/menucontroller.dart' as menu_ctrl;
import '../../controller/item_controller.dart';
import '../../Utils/Utils.dart';
import '../../utils/widgets/app_loader.dart';
import '../../utils/widgets/no_data_widget.dart';

class VendorRestaurantScreen extends StatefulWidget {
  const VendorRestaurantScreen({super.key});

  @override
  State<VendorRestaurantScreen> createState() => _VendorRestaurantScreenState();
}

class _VendorRestaurantScreenState extends State<VendorRestaurantScreen> {
  String selectedMenu = "Account";
  bool isInstructionsExpanded = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = "";
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _reasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatLeaveDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      return "${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}";
    } catch (_) {
      return dateStr;
    }
  }

  String _formatLongText(String? text) {
    if (text == null || text.length <= 20) return text ?? "-";
    return "${text.substring(0, 20)}\n${text.substring(20)}";
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF5216)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "dd-mm-yyyy";
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  String _formatApiDate(DateTime? date) {
    if (date == null) return "";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      child: GetBuilder<ProfileController>(
        builder: (profileController) {
          final profile = profileController.profileData;
          return SingleChildScrollView(
            controller: profileController.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                VendorProfileHeaderCard(
                  name: profile?.name ?? S.of(context).restaurantOne,
                  rating: profile?.rating?.isNotEmpty == true
                      ? profile!.rating!
                      : "4.6",
                ),
                const SizedBox(height: 24),
                // Menu Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMenuButton("Account"),
                      const SizedBox(width: 10),
                      _buildMenuButton("Working Hours"),
                      const SizedBox(width: 10),
                      _buildMenuButton("Leaves"),
                      const SizedBox(width: 10),
                      _buildMenuButton("Menu"),
                      const SizedBox(width: 10),
                      _buildMenuButton("Items"),
                      const SizedBox(width: 10),
                      _buildMenuButton("Menu Bulk Import"),
                      const SizedBox(width: 10),
                      _buildMenuButton("Basket"),
                      const SizedBox(width: 10),
                      _buildMenuButton("Received Payouts"),
                      const SizedBox(width: 10),
                      _buildMenuButton("Store Reports"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (selectedMenu == "Account") ...[
                  _sectionHeader("RESTAURANT DETAILS"),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      children: [
                        _detailRow("Name", profile?.name ?? "Restaurant 1"),
                        _detailRow("Owner", profile?.owner ?? "Salman"),
                        _detailRow("ID", profile?.id?.toString() ?? "1"),
                        _detailRow(
                          "Contact",
                          "${profile?.countryCode ?? "+222"} ${profile?.mobile ?? ""}",
                        ),
                        _detailRow(
                          "Email",
                          profile?.email ?? "rest1@saimpex.com",
                        ),
                        _detailRow(
                          "Status",
                          profile?.status ?? "ACTIVE",
                          isStatus: true,
                        ),
                        _detailRow(
                          "Address",
                          _formatLongText(
                            profile?.address ??
                                "Restaurant Block 5, Mauritania",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader("BANK DETAILS"),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                      children: [
                        _detailRow(
                          "Holder Name",
                          profile?.accountHolderName ?? "-",
                        ),
                        _detailRow(
                          "Account Number",
                          _formatLongText(profile?.accountNumber ?? "-"),
                        ),
                        _detailRow("SWIFT Code", profile?.ifscCode ?? "-"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader("ABOUT THE RESTAURANT"),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: _detailRow(
                      "Category",
                      profile?.restaurantType == 1
                          ? "Veg"
                          : profile?.restaurantType == 2
                          ? "Non-Veg"
                          : "-",
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader("REGISTRATION DETAILS"),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    height: MediaQuery.of(context).size.height * 0.19,
                    child: Column(
                      children: [
                        _detailRow(
                          "Reg. Number",
                          profile?.registrationNumber ?? "-",
                        ),
                        _detailRow(
                          "Reg. Date",
                          _formatLeaveDate(profile?.registrationDate),
                        ),
                        _detailRow("GST Number", profile?.gstNo ?? "-"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader("PAYMENT DETAILS"),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: Column(
                      children: [
                        _detailRow(
                          "Commission %",
                          profile?.commissionPercentage != null
                              ? "${profile!.commissionPercentage}%"
                              : "-",
                        ),
                        _detailRow(
                          "Total Profit",
                          "${profile?.totalProfit ?? "0"} MRU",
                          isBoldValue: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader("OWNER IDENTITY PROOF"),
                  const SizedBox(height: 12),
                  _buildImageCard(
                    height: MediaQuery.of(context).size.height * 0.14,
                    imageUrl: profile?.ownerIdProof,
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader("CERTIFICATES"),
                  const SizedBox(height: 12),
                  _buildImageCard(
                    height: MediaQuery.of(context).size.height * 0.14,
                    imageUrl: profile?.certificate,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionHeader(
                        "RATING & REVIEWS (${profileController.ratingReviewData?.totalReviews ?? 0})",
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RatingReviewsScreen(),
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
                  const SizedBox(height: 12),
                  if (profileController.isRatingReviewLoading)
                    const AppLoader()
                  else if (profileController.ratingReviewData?.reviews !=
                          null &&
                      profileController.ratingReviewData!.reviews!.isNotEmpty)
                    ...profileController.ratingReviewData!.reviews!.take(5).map(
                      (review) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildReviewItem(
                            name: review.username ?? S.of(context).anonymous,
                            date: review.createdAt ?? "",
                            rating:
                                double.tryParse(review.rating ?? "0") ?? 0.0,
                            review: review.comment ?? S.of(context).noComment,
                            orderId: review.orderCode ?? "",
                          ),
                        );
                      },
                    )
                  else
                    NoDataWidget(
                      context,
                      S.of(context).noReviewsFound,
                      "",
                      "lib/assets/images/nodata.png",
                    ),
                  const SizedBox(height: 8),
                ] else if (selectedMenu == "Leaves") ...[
                  const SizedBox(height: 20),
                  _sectionHeader(S.of(context).markLeave),
                  const SizedBox(height: 12),
                  _buildLeaveForm(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionHeader(S.of(context).leavesHistory),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaveHistoryScreen(),
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
                  const SizedBox(height: 12),
                  Text(
                    S.of(context).upcomingLeaves,
                    style: GoogleFonts.rubik(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 95, 145, 245),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (profileController.upcomingLeaves.isNotEmpty)
                    ...profileController.upcomingLeaves
                        .take(3)
                        .map(
                          (leave) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildLeaveTile(
                              dateRange: _formatLeaveDate(leave.date),
                              reason: leave.reason ?? S.of(context).leave,
                              status: "SCHEDULED",
                              isUpcoming: true,
                            ),
                          ),
                        )
                  else
                    NoDataWidget(
                      context,
                      S.of(context).noUpcomingLeavesFound,
                      "",
                      "lib/assets/images/nodata.png",
                    ),
                  const SizedBox(height: 12),
                  Text(
                    S.of(context).completedLeaves,
                    style: GoogleFonts.rubik(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 35, 208, 102),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (profileController.leaveHistory.isNotEmpty)
                    ...profileController.leaveHistory.take(3).map(
                      (leave) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildLeaveTile(
                          dateRange: _formatLeaveDate(leave.date),
                          reason: leave.reason ?? S.of(context).leave,
                          status: "COMPLETED",
                          isUpcoming: false,
                        ),
                      ),
                    )
                  else
                    NoDataWidget(
                      context,
                      S.of(context).noCompletedLeavesFound,
                      "",
                      "lib/assets/images/nodata.png",
                    ),
                  const SizedBox(height: 20),
                ] else if (selectedMenu == "Working Hours") ...[
                  const SizedBox(height: 20),
                  _sectionHeader(S.of(context).workingHours),
                  const SizedBox(height: 12),
                  _buildWorkingHoursList(),
                  const SizedBox(height: 20),
                ] else if (selectedMenu == "Menu") ...[
                  const SizedBox(height: 20),
                  _buildSearchRow(),
                  const SizedBox(height: 16),
                  _buildCategoryAddRow(),
                  const SizedBox(height: 20),
                  _buildMenuList(),
                  const SizedBox(height: 20),
                ] else if (selectedMenu == "Items") ...[
                  const SizedBox(height: 20),
                  _buildSearchRow(),
                  const SizedBox(height: 16),
                  _buildItemsActionRow(),
                  const SizedBox(height: 16),
                  _buildItemsList(),
                  const SizedBox(height: 20),
                ] else if (selectedMenu == "Menu Bulk Import") ...[
                  const SizedBox(height: 20),
                  _sectionHeader(S.of(context).menuBulkImport),
                  const SizedBox(height: 24),
                  _buildBulkImportInstructions(),
                  const SizedBox(height: 24),
                  _buildImportSteps(),
                  const SizedBox(height: 40),
                ] else if (selectedMenu == "Basket") ...[
                  const SizedBox(height: 20),
                  _sectionHeader(S.of(context).baskets),
                  const SizedBox(height: 12),
                  _buildBasketList(),
                  const SizedBox(height: 20),
                ] else if (selectedMenu == "Received Payouts") ...[
                  // const SizedBox(height: 20),
                  // _sectionHeader("RECEIVED PAYOUTS"),
                  //const SizedBox(height: 5),
                  //_buildPayoutsList(),
                  PayoutListScreen(),
                  const SizedBox(height: 20),
                ] else if (selectedMenu == "Store Reports") ...[
                  const SalesReportsScreen(),
                  // const SizedBox(height: 20),
                ],
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkingHoursList() {
    return const VendorWorkingHoursList();
  }

  Widget _buildMenuButton(String title) {
    return VendorMenuButton(
      title: title,
      isSelected: selectedMenu == title,
      onTap: () {
        setState(() {
          selectedMenu = title;
        });
        if (title == "Menu") {
          final profileController = Get.find<ProfileController>();
          profileController.getAllCategories();
          profileController.fetchGroceryMenus();
          profileController.fetchRestaurantMenus(keyword: _searchKeyword);
        } else if (title == "Items") {
          final profileController = Get.find<ProfileController>();
          profileController.fetchGroceryMenuItems();
          profileController.fetchRestaurantMenuItems();
        }
      },
    );
  }

  Widget _sectionHeader(String title) {
    return VendorSectionHeader(title: title);
  }

  Widget _buildDetailCard({
    double? height,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return VendorDetailCard(height: height, padding: padding, child: child);
  }

  Widget _detailRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isBoldValue = false,
  }) {
    return VendorDetailRow(
      label: label,
      value: value,
      isStatus: isStatus,
      isBoldValue: isBoldValue,
    );
  }

  Widget _buildImageCard({double? height, String? imageUrl}) {
    return VendorImageCard(height: height, imageUrl: imageUrl);
  }

  Widget _buildReviewItem({
    required String name,
    required String date,
    required double rating,
    required String review,
    required String orderId,
  }) {
    return VendorReviewItem(
      name: name,
      date: date,
      rating: rating,
      review: review,
      orderId: orderId,
    );
  }

  Widget _buildLeaveForm() {
    return VendorLeaveForm(
      fromDate: _fromDate,
      toDate: _toDate,
      reasonController: _reasonController,
      formatDate: _formatDate,
      onFromTap: () => _selectDate(context, true),
      onToTap: () => _selectDate(context, false),
      onMarkLeave: () {
        if (_fromDate == null || _toDate == null) {
          showToast(context, "Please select both dates");
          return;
        }
        Get.find<ProfileController>()
            .markLeave(
              context,
              _formatApiDate(_fromDate),
              _formatApiDate(_toDate),
              _reasonController.text.trim(),
            )
            .then((_) {
              Get.find<ProfileController>().getProfile(context);
              setState(() {
                _fromDate = null;
                _toDate = null;
                _reasonController.clear();
              });
            });
      },
    );
  }

  Widget _buildLeaveTile({
    required String dateRange,
    required String reason,
    required String status,
    required bool isUpcoming,
  }) {
    return VendorLeaveTile(
      dateRange: dateRange,
      reason: reason,
      status: status,
      isUpcoming: isUpcoming,
    );
  }

  Widget _buildMenuList() {
    final profileController = Get.find<ProfileController>();

    if (profileController.isGroceryMenusLoading ||
        profileController.isRestaurantMenusLoading) {
      return const AppLoader();
    }

    final query = _searchKeyword.trim().toLowerCase();
    final filteredGroceryMenus = profileController.groceryMenus.where((menu) {
      if (query.isEmpty) return true;
      final lang = profileController.localization.currentLocale?.languageCode;
      final name = lang == 'fr'
          ? (menu.nameFr ?? menu.nameEn ?? "")
          : lang == 'ar'
          ? (menu.nameAr ?? menu.nameEn ?? "")
          : (menu.nameEn ?? "");
      final category = lang == 'fr'
          ? (menu.categoryNameFr ?? menu.categoryNameEn ?? "")
          : lang == 'ar'
          ? (menu.categoryNameAr ?? menu.categoryNameEn ?? "")
          : (menu.categoryNameEn ?? "");
      return name.toLowerCase().contains(query) ||
          category.toLowerCase().contains(query) ||
          (menu.id?.toString() ?? "").contains(query);
    }).toList();

    final filteredRestaurantMenus = profileController.restaurantMenus.where((
      menu,
    ) {
      if (query.isEmpty) return true;
      final lang = profileController.localization.currentLocale?.languageCode;
      final name = lang == 'fr'
          ? (menu.nameFr ?? menu.nameEn ?? "")
          : lang == 'ar'
          ? (menu.nameAr ?? menu.nameEn ?? "")
          : (menu.nameEn ?? "");
      return name.toLowerCase().contains(query) ||
          (menu.categoryId ?? "").toLowerCase().contains(query) ||
          (menu.id?.toString() ?? "").contains(query);
    }).toList();

    if (filteredGroceryMenus.isEmpty && filteredRestaurantMenus.isEmpty) {
      return NoDataWidget(
        context,
        "No menus found.",
        "",
        "lib/assets/images/nodata.png",
      );
    }

    return Column(
      children: [
        ...filteredGroceryMenus.map((menu) {
          final lang =
              profileController.localization.currentLocale?.languageCode;
          final name = lang == 'fr'
              ? (menu.nameFr ?? menu.nameEn ?? "")
              : lang == 'ar'
              ? (menu.nameAr ?? menu.nameEn ?? "")
              : (menu.nameEn ?? "");
          final category = lang == 'fr'
              ? (menu.categoryNameFr ?? menu.categoryNameEn ?? "")
              : lang == 'ar'
              ? (menu.categoryNameAr ?? menu.categoryNameEn ?? "")
              : (menu.categoryNameEn ?? "");

          return _menuItem(
            name,
            category,
            id: menu.id.toString(),
            imageUrl: menu.image,
          );
        }).toList(),
        ...filteredRestaurantMenus.map((menu) {
          final lang =
              profileController.localization.currentLocale?.languageCode;
          final name = lang == 'fr'
              ? (menu.nameFr ?? menu.nameEn ?? "")
              : lang == 'ar'
              ? (menu.nameAr ?? menu.nameEn ?? "")
              : (menu.nameEn ?? "");
          return _menuItem(
            name,
            menu.categoryId?.toString() ?? "",
            id: menu.id.toString(),
            imageUrl: menu.image,
            categories: profileController.restaurantCategoriesForDropdown,
          );
        }).toList(),
        if (profileController.isLoadMoreRunning)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5216)),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return VendorSearchRow(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchKeyword = value;
        });
        if (selectedMenu == "Menu") {
          _searchDebounce?.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 400), () {
            if (!mounted) return;
            Get.find<ProfileController>().fetchRestaurantMenus(
              keyword: _searchKeyword.trim(),
            );
          });
        }
      },
    );
  }

  Widget _buildItemsActionRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF5216), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Download',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: const Color(0xFFFF5216),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'lib/assets/images/download_image.png',
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Upload Menu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: const Color(0xFF3B82F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'lib/assets/images/upload_button.png',
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                  color: const Color(0xFF3B82F6),
                  colorBlendMode: BlendMode.srcIn,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddItemsScreen()),
              );
            },
            icon: const Icon(Icons.add, color: Color(0xFFFF5216), size: 18),
            label: Text(
              S.of(context).addItem,
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
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAddRow() {
    final profileController = Get.find<ProfileController>();
    return VendorCategoryAddRow(
      categories: profileController.restaurantCategoriesForDropdown,
      selectedCategoryId: profileController.selectedRestaurantCategoryId,
      onCategoryChanged: (int? categoryId) {
        profileController.setSelectedRestaurantCategoryId(categoryId);
        profileController.fetchRestaurantMenus(keyword: _searchKeyword);
      },
      onAddPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMenuScreen()),
        );
      },
    );
  }

  Widget _menuItem(
    String name,
    String category, {
    String? imageUrl,
    String? id,
    String price = "50.00 MRU",
    String? discountPrice = "100.00 MRU",
    List<RestaurantCategory>? categories,
  }) {
    return _richCard(
      id: id ?? "33",
      name: name,
      category: category,
      price: price,
      originalPrice: discountPrice,
      imageUrl: imageUrl,
      itemId: id ?? "33",
      isMenu: true,
      categories: categories,
    );
  }

  Widget _richCard({
    required String id,
    required String name,
    required String category,
    required String price,
    String? originalPrice,
    String? imageUrl,
    required String itemId,
    bool isMenu = false,
    List<RestaurantCategory>? categories,
    int? availabilityStatus,
  }) {
    return VendorRichCard(
      id: id,
      name: name,
      category: category,
      price: price,
      originalPrice: originalPrice,
      imageUrl: imageUrl,
      itemId: itemId,
      isMenu: isMenu,
      categories: categories,
      availabilityStatus: availabilityStatus,
      onViewDetails: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuItemDetailsScreen(
              itemId: itemId,
              isMenu: isMenu,
            ),
          ),
        );
      },
      onEdit: () {
        if (isMenu) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditMenuScreen(itemId: itemId),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditItemsScreen(itemId: itemId),
            ),
          );
        }
      },
      onDelete: isMenu
          ? () {
              final menuController = Get.isRegistered<menu_ctrl.MenuController>()
                  ? Get.find<menu_ctrl.MenuController>()
                  : Get.put(menu_ctrl.MenuController(), permanent: false);
              menuController.deleteMenu(context,
                  restaurantMenuId: itemId);
            }
          : () {
              final itemController = Get.isRegistered<ItemController>()
                  ? Get.find<ItemController>()
                  : Get.put(ItemController(), permanent: false);
              itemController.deleteItem(
                context,
                restaurantMenuItemId: itemId,
              );
            },
    );
  }

  Widget _buildItemsList() {
    final profileController = Get.find<ProfileController>();
    if (profileController.isGroceryMenuItemsLoading ||
        profileController.isRestaurantMenuItemsLoading) {
      return const AppLoader();
    }
    final query = _searchKeyword.trim().toLowerCase();
    final filteredGroceryItems = profileController.groceryMenuItems.where((
      item,
    ) {
      if (query.isEmpty) return true;
      final lang = profileController.localization.currentLocale?.languageCode;
      final name = lang == 'fr'
          ? (item.nameFr ?? item.nameEn ?? "")
          : lang == 'ar'
          ? (item.nameAr ?? item.nameEn ?? "")
          : (item.nameEn ?? "");
      final category = lang == 'fr'
          ? (item.categoryNameFr ?? item.categoryNameEn ?? "")
          : lang == 'ar'
          ? (item.categoryNameAr ?? item.categoryNameEn ?? "")
          : (item.categoryNameEn ?? "");
      return name.toLowerCase().contains(query) ||
          category.toLowerCase().contains(query) ||
          (item.id?.toString() ?? "").contains(query);
    }).toList();

    final filteredRestaurantItems = profileController.restaurantMenuItems.where(
      (item) {
        if (query.isEmpty) return true;
        final lang = profileController.localization.currentLocale?.languageCode;
        final name = lang == 'fr'
            ? (item.nameFr ?? item.nameEn ?? "")
            : lang == 'ar'
            ? (item.nameAr ?? item.nameEn ?? "")
            : (item.nameEn ?? "");
        final category = lang == 'fr'
            ? (item.categoryNameFr ?? item.categoryNameEn ?? "")
            : lang == 'ar'
            ? (item.categoryNameAr ?? item.categoryNameEn ?? "")
            : (item.categoryNameEn ?? "");
        return name.toLowerCase().contains(query) ||
            category.toLowerCase().contains(query) ||
            (item.id?.toString() ?? "").contains(query);
      },
    ).toList();

    if (filteredGroceryItems.isEmpty && filteredRestaurantItems.isEmpty) {
      return Column(
        children: [
          NoDataWidget(
            context,
            "No items found.",
            "",
            "lib/assets/images/nodata.png",
          ),
          const SizedBox(height: 20),
          _addNewItemButton(),
        ],
      );
    }
    return Column(
      children: [
        ...filteredGroceryItems.map((item) {
          final lang =
              profileController.localization.currentLocale?.languageCode;
          final name = lang == 'fr'
              ? (item.nameFr ?? item.nameEn ?? "")
              : lang == 'ar'
              ? (item.nameAr ?? item.nameEn ?? "")
              : (item.nameEn ?? "");
          final category = lang == 'fr'
              ? (item.categoryNameFr ?? item.categoryNameEn ?? "")
              : lang == 'ar'
              ? (item.categoryNameAr ?? item.categoryNameEn ?? "")
              : (item.categoryNameEn ?? "");
          final price = "${item.price} MRU";
          return _foodItem(
            name,
            price,
            item.image,
            item.id.toString(),
            category: category,
            availabilityStatus: item.availableStatus,
          );
        }).toList(),
        ...filteredRestaurantItems.map((item) {
          final lang =
              profileController.localization.currentLocale?.languageCode;
          final name = lang == 'fr'
              ? (item.nameFr ?? item.nameEn ?? "")
              : lang == 'ar'
              ? (item.nameAr ?? item.nameEn ?? "")
              : (item.nameEn ?? "");
          final category = lang == 'fr'
              ? (item.categoryNameFr ?? item.categoryNameEn ?? "")
              : lang == 'ar'
              ? (item.categoryNameAr ?? item.categoryNameEn ?? "")
              : (item.categoryNameEn ?? "");
          final hasDiscount =
              item.discountPrice != null &&
              item.discountPrice!.isNotEmpty &&
              item.discountPrice != item.price;
          final displayPrice = hasDiscount
              ? "${item.discountPrice} MRU"
              : "${item.price} MRU";
          final originalPrice = hasDiscount ? "${item.price} MRU" : null;
          return _foodItem(
            name,
            displayPrice,
            item.image,
            item.id.toString(),
            category: category,
            originalPrice: originalPrice,
            availabilityStatus: item.availableStatus,
          );
        }).toList(),
        const SizedBox(height: 20),
        _addNewItemButton(),
      ],
    );
  }

  Widget _addNewItemButton() {
    return VendorAddNewItemButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddItemsScreen()),
        );
      },
    );
  }

  Widget _foodItem(
    String name,
    String price,
    String? imageUrl,
    String itemId, {
    String category = "Category",
    List<RestaurantCategory>? categories,
    String? originalPrice,
    int? availabilityStatus,
  }) {
    return _richCard(
      id: itemId,
      name: name,
      category: category,
      price: price,
      originalPrice: originalPrice,
      imageUrl: imageUrl,
      itemId: itemId,
      isMenu: false,
      categories: categories,
      availabilityStatus: availabilityStatus,
    );
  }

  Widget _buildBulkImportInstructions() {
    return VendorBulkImportInstructions(
      isExpanded: isInstructionsExpanded,
      onToggle: () {
        setState(() {
          isInstructionsExpanded = !isInstructionsExpanded;
        });
      },
    );
  }

  Widget _buildImportSteps() {
    return Column(
      children: [
        _importStep(1, "Upload File", "Select your completed menu file"),
        const SizedBox(height: 16),
        _importStep(2, "Review Data", "Verify the imported items"),
        const SizedBox(height: 16),
        _importStep(3, "Complete", "Finalize the bulk import"),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.15,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 8),
              Text(
                "Click or drag file to upload",
                style: GoogleFonts.rubik(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _importStep(int number, String title, String subtitle) {
    return VendorImportStep(number: number, title: title, subtitle: subtitle);
  }

  Widget _buildBasketList() {
    return Column(
      children: [
        _basketItem(
          S.of(context).classicBasket,
          "10 Items",
          S.of(context).activeLabel,
        ),
        const SizedBox(height: 12),
        _basketItem(
          S.of(context).comboOffer,
          "5 Items",
          S.of(context).inactiveLabel,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.06,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BasketDetailsScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5216),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              S.of(context).createNewBasket,
              style: GoogleFonts.rubik(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _basketItem(String name, String count, String status) {
    return VendorBasketItem(name: name, count: count, status: status);
  }

  Widget _buildPayoutsList() {
    return Column(
      children: [
        _payoutItem("PO-2025-001", "Mar 01, 2025", "\$450.00"),
        const SizedBox(height: 12),
        _payoutItem("PO-2025-002", "Feb 23, 2025", "\$320.50"),
        const SizedBox(height: 12),
        _payoutItem("PO-2025-003", "Feb 15, 2025", "\$580.00"),
      ],
    );
  }

  Widget _payoutItem(String id, String date, String amount) {
    return VendorPayoutItem(id: id, date: date, amount: amount);
  }
}
