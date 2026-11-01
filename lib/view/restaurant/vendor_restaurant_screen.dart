import 'package:saimpex_vendor/utils/widgets/product_visibility.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/view_item_details.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/view_menu_details.dart';
import 'package:saimpex_vendor/view/restaurant/rating_reviews_screen.dart';
import '../../generated/l10n.dart';
import '../../utils/widgets/common_background.dart';
import '../payout/payout_list_screen.dart';
import '../reports/sales_reports.dart';
import '../basket/basketlisting.dart';
import 'add_menu_screen.dart';
import 'add_items_screen.dart';
import 'edit_menu_screen.dart';
import 'edit_items_screen.dart';
import 'quick_edit_item_sheet.dart';
import 'leave_history_screen.dart';
import 'Widgets/vendor_restaurant_reusable_widgets.dart';
import '../../controller/profile_controller.dart';
import '../../controller/menucontroller.dart' as menu_ctrl;
import '../../controller/item_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../configs/ApiConfigs.dart';
import '../../utils/utils.dart';
import '../../utils/widgets/app_loader.dart';
import '../../utils/widgets/no_data_widget.dart';

class VendorRestaurantScreen extends StatefulWidget {
  const VendorRestaurantScreen({super.key});

  @override
  State<VendorRestaurantScreen> createState() => _VendorRestaurantScreenState();
}

class _VendorRestaurantScreenState extends State<VendorRestaurantScreen> {
  String selectedMenu = "Account";
  bool _isRestaurantBusy = false;
  bool _busyStatusInitialized = false;
  bool isInstructionsExpanded = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = "";
  Timer? _searchDebounce;
  DateTime? _lastDownloadTemplateAt;

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

  Future<void> _pickBulkImportXlsxFile() async {
    final profileController = Get.find<ProfileController>();
    final categoryId = profileController.selectedRestaurantCategoryId;
    if (categoryId == null) {
      if (mounted) {
        showToast(context, S.of(context).importSelectCategoryFirst);
      }
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withReadStream: false,
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) return;
      final picked = result.files.single;
      final name = picked.name;
      final lower = name.toLowerCase();
      if (!lower.endsWith('.xlsx')) {
        showToast(context, S.of(context).pleaseSelectAnXlsxFileOnly);
        return;
      }
      final path = picked.path;
      if (path == null || path.isEmpty) {
        showToast(context, S.of(context).couldNotAccessTheSelectedFile);
        return;
      }
      final uploaded = await profileController.importRestaurantCatalogItems(
        context,
        path,
        categoryId,
      );

      if (mounted && uploaded) {
        setState(() {
          selectedMenu = "Items";
        });
      }
    } catch (e) {
      if (mounted) {
        showToast(context, e.toString());
      }
    }
  }

  Future<void> _onRefresh() async {
    final profileController = Get.find<ProfileController>();
    if (selectedMenu == 'Account') {
      await profileController.getProfile(context);
    } else if (selectedMenu == 'Items') {
      await profileController.fetchGroceryMenuItems(
        categoryId: profileController.selectedRestaurantCategoryId,
        keyword: _searchKeyword.trim(),
      );
    } else if (selectedMenu == 'Leaves') {
      await profileController.getProfile(context);
    } else if (selectedMenu == 'Working Hours') {
      await profileController.getProfile(context);
    } else {
      await profileController.getProfile(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      child: GetBuilder<ProfileController>(
        builder: (profileController) {
          final profile = profileController.profileData;
          // Initialize Busy toggle from server profile once.
          if (!_busyStatusInitialized && profile?.isBusy != null) {
            _isRestaurantBusy = (profile?.isBusy ?? 2) == 1; // 1 = Busy
            _busyStatusInitialized = true;
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFFFF5216),
            child: SingleChildScrollView(
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
                    imageUrl: profileController.profilePicture.isNotEmpty
                        ? profileController.profilePicture
                        : profile?.image,
                  ),
                  const SizedBox(height: 24),
                  // Menu Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildMenuButton(S.of(context).account, "Account"),
                        const SizedBox(width: 10),
                        _buildMenuButton(
                          S.of(context).workHours,
                          "Working Hours",
                        ),
                        const SizedBox(width: 10),
                        _buildMenuButton(S.of(context).leaves, "Leaves"),
                        const SizedBox(width: 10),
                        _buildMenuButton(S.of(context).items, "Items"),
                        const SizedBox(width: 10),
                        _buildMenuButton(
                          S.of(context).menuBulkImport,
                          "Menu Bulk Import",
                        ),
                        const SizedBox(width: 10),
                        _buildMenuButton(S.of(context).basket, "Basket"),
                        const SizedBox(width: 10),
                        _buildMenuButton(
                          S.of(context).receivedPayouts,
                          "Received Payouts",
                        ),
                        const SizedBox(width: 10),
                        _buildMenuButton(
                          S.of(context).storeReports,
                          "Store Reports",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (selectedMenu == "Account") ...[
                    _sectionHeader(S.of(context).restaurantStatus),
                    const SizedBox(height: 12),
                    Material(
                      elevation: 3,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 56,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                S.of(context).busy,
                                style: appFont('Rubik', 
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                              const Spacer(),
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  value: _isRestaurantBusy,
                                  onChanged: (value) async {
                                    setState(() => _isRestaurantBusy = value);
                                    final statusToSend = value ? 1 : 2;
                                    await profileController.updateBusyStatus(
                                      context,
                                      statusToSend,
                                    );
                                    // Re-sync from server on next rebuild if profile is refreshed elsewhere.
                                    _busyStatusInitialized = false;
                                  },
                                  activeTrackColor: const Color(0xFFEF4444),
                                  thumbColor: Colors.white,
                                  trackColor: const Color(0xFFE5E7EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionHeader(S.of(context).storeDetails),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      height: MediaQuery.of(context).size.height * 0.36,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _detailRow(
                            S.of(context).name,
                            profile?.name ?? "Store 1",
                          ),
                          _detailRow(
                            S.of(context).owner,
                            profile?.owner ?? "Salman",
                          ),
                          _detailRow(
                            S.of(context).storeId,
                            profile?.id?.toString() ?? "1",
                          ),
                          _detailRow(
                            S.of(context).contact,
                            "${profile?.countryCode ?? "+222"} ${profile?.mobile ?? ""}",
                          ),
                          _detailRow(
                            S.of(context).email,
                            profile?.email ?? "rest1@saimpex.com",
                          ),
                          _detailRow(
                            S.of(context).status,
                            profile?.status ?? "ACTIVE",
                            isStatus: true,
                          ),
                          _detailRow(
                            S.of(context).address,
                            _formatLongText(
                              profile?.address ?? "Store Block 5, Mauritania",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionHeader(S.of(context).bankDetails),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _detailRow(
                            S.of(context).holderName,
                            profile?.accountHolderName ?? "-",
                          ),
                          _detailRow(
                            S.of(context).accountNumber,
                            _formatLongText(profile?.accountNumber ?? "-"),
                          ),
                          _detailRow(
                            S.of(context).swiftCode,
                            profile?.ifscCode ?? "-",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (profileController.vendorType == "1") ...[
                      _sectionHeader(S.of(context).aboutTheStore),
                      const SizedBox(height: 12),
                      _buildDetailCard(
                        height: MediaQuery.of(context).size.height * 0.09,
                        child: _detailRow(
                          S.of(context).categoryLabel,
                          profile?.restaurantType == 1
                              ? S.of(context).veg
                              : profile?.restaurantType == 2
                              ? S.of(context).nonVeg
                              : "-",
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _sectionHeader(S.of(context).registrationDetails),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _detailRow(
                            S.of(context).regNumber,
                            profile?.registrationNumber ?? "-",
                          ),
                          _detailRow(
                            S.of(context).regDate,
                            _formatLeaveDate(profile?.registrationDate),
                          ),
                          _detailRow(
                            S.of(context).gstNumber,
                            profile?.gstNo ?? "-",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionHeader(S.of(context).paymentDetails),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      // Let card expand to content to avoid vertical overflow on small screens.
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _detailRow(
                            S.of(context).commissionPercentage,
                            profile?.commissionPercentage != null
                                ? "${profile!.commissionPercentage}%"
                                : "-",
                          ),
                          _detailRow(
                            S.of(context).totalProfit,
                            "${(double.tryParse(profile?.totalProfit ?? "0") ?? 0.0).toStringAsFixed(2)} MRU",
                            isBoldValue: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionHeader(S.of(context).ownerIdentityProof),
                    const SizedBox(height: 12),
                    _buildImageCard(
                      height: MediaQuery.of(context).size.height * 0.14,
                      imageUrl: profile?.ownerIdProof,
                    ),
                    const SizedBox(height: 24),
                    _sectionHeader(S.of(context).certificates),
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
                          S.of(context).ratingReviews +
                              " (${profileController.ratingReviewData?.totalReviews ?? 0})",
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RatingReviewsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            S.of(context).viewAll,
                            style: appFont('Rubik', 
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
                      ...profileController.ratingReviewData!.reviews!
                          .take(5)
                          .map((review) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildReviewItem(
                                name:
                                    review.username ?? S.of(context).anonymous,
                                date: review.createdAt ?? "",
                                rating:
                                    double.tryParse(review.rating ?? "0") ??
                                    0.0,
                                review:
                                    review.comment ?? S.of(context).noComment,
                                orderId: review.orderCode ?? "",
                              ),
                            );
                          })
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
                                builder: (context) =>
                                    const LeaveHistoryScreen(),
                              ),
                            );
                          },
                          child: Text(
                            S.of(context).viewAll,
                            style: appFont('Rubik', 
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
                      style: appFont('Rubik', 
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
                                onCancelLeave: leave.id == null
                                    ? null
                                    : () => Get.find<ProfileController>()
                                          .unmarkLeave(
                                            context,
                                            leave.id.toString(),
                                          ),
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
                      style: appFont('Rubik', 
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 35, 208, 102),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (profileController.leaveHistory.isNotEmpty)
                      ...profileController.leaveHistory
                          .take(3)
                          .map(
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
                  ] else if (selectedMenu == "Items") ...[
                    const SizedBox(height: 20),
                    _buildSearchRow(showFilter: false),
                    const SizedBox(height: 16),
                    _buildItemsActionRow(),
                    const SizedBox(height: 16),
                    _buildItemsList(),
                    const SizedBox(height: 20),
                  ] else if (selectedMenu == "Menu Bulk Import") ...[
                    const SizedBox(height: 20),
                    _sectionHeader(S.of(context).menuBulkImport),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).importSelectCategoryHint,
                      style: appFont('Rubik', 
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildBulkImportActionsRow(
                      profileController: profileController,
                    ),
                    const SizedBox(height: 18),
                    _buildBulkImportInstructions(),
                    const SizedBox(height: 18),
                    _buildBulkImportCategoryCardsGrid(
                      profileController: profileController,
                    ),
                    const SizedBox(height: 24),
                  ] else if (selectedMenu == "Basket") ...[
                    //const SizedBox(height: 20),
                    // _sectionHeader(S.of(context).baskets),
                    // const Siz
                    const BasketListing(),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkingHoursList() {
    return const VendorWorkingHoursList();
  }

  Widget _buildMenuButton(String displayTitle, String internalKey) {
    return VendorMenuButton(
      title: displayTitle,
      isSelected: selectedMenu == internalKey,
      onTap: () {
        setState(() {
          selectedMenu = internalKey;
        });
        if (internalKey == "Items") {
          final profileController = Get.find<ProfileController>();
          profileController.getAllCategories();
          profileController.fetchGroceryMenuItems(
            categoryId: profileController.selectedRestaurantCategoryId,
            keyword: _searchKeyword.trim(),
          );
        } else if (internalKey == "Menu Bulk Import") {
          final profileController = Get.find<ProfileController>();
          profileController.getAllCategories();
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
    VoidCallback? onCancelLeave,
  }) {
    return VendorLeaveTile(
      dateRange: dateRange,
      reason: reason,
      status: status,
      isUpcoming: isUpcoming,
      onCancelLeave: onCancelLeave,
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
      final category = lang == 'fr'
          ? (menu.categoryNameFr ?? menu.categoryNameEn ?? "")
          : lang == 'ar'
          ? (menu.categoryNameAr ?? menu.categoryNameEn ?? "")
          : (menu.categoryNameEn ?? "");
      return name.toLowerCase().contains(query) ||
          category.toLowerCase().contains(query) ||
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
            menu.id?.toString() ?? "",
            category,
            id: menu.id?.toString() ?? "",
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
          final category = lang == 'fr'
              ? (menu.categoryNameFr ?? menu.categoryNameEn ?? "")
              : lang == 'ar'
              ? (menu.categoryNameAr ?? menu.categoryNameEn ?? "")
              : (menu.categoryNameEn ?? "");
          return _menuItem(
            name,
            menu.id?.toString() ?? "",
            category,
            id: menu.id?.toString() ?? "",
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

  Widget _buildSearchRow({bool showFilter = false}) {
    return VendorSearchRow(
      controller: _searchController,
      showFilter: showFilter,
      onChanged: (value) {
        setState(() {
          _searchKeyword = value;
        });
        if (selectedMenu == "Items") {
          _searchDebounce?.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 400), () {
            if (!mounted) return;
            final profileController = Get.find<ProfileController>();
            profileController.fetchGroceryMenuItems(
              categoryId: profileController.selectedRestaurantCategoryId,
              keyword: _searchKeyword.trim(),
            );
          });
        }
      },
    );
  }

  Widget _buildItemsActionRow() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemsScreen()),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFFF5216), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Color(0xFFFF5216), size: 18),
            const SizedBox(width: 6),
            Text(
              S.of(context).addItem,
              style: appFont('Rubik', 
                fontSize: 13,
                color: const Color(0xFFFF5216),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuActionRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              final now = DateTime.now();
              final last = _lastDownloadTemplateAt;
              if (last != null &&
                  now.difference(last) < const Duration(seconds: 20)) {
                return;
              }
              _lastDownloadTemplateAt = now;
              final menuController =
                  Get.isRegistered<menu_ctrl.MenuController>()
                  ? Get.find<menu_ctrl.MenuController>()
                  : Get.put(menu_ctrl.MenuController(), permanent: false);
              menuController.downloadItemTemplate(context);
            },
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
                  S.of(context).menuExport,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appFont('Rubik', 
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
        const SizedBox(width: 5),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final menuController =
                  Get.isRegistered<menu_ctrl.MenuController>()
                  ? Get.find<menu_ctrl.MenuController>()
                  : Get.put(menu_ctrl.MenuController(), permanent: false);
              menuController.uploadItemTemplate(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Container(
              margin: const EdgeInsets.only(left: 3, right: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Upload Menu',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appFont('Rubik', 
                      fontSize: 12,
                      color: const Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
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
        ),
        const SizedBox(width: 5),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMenuScreen()),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: Text(
              'Add Menu',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appFont('Rubik', 
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5216),
              elevation: 0,
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

  Widget _buildCategoryDropdownOnly() {
    final profileController = Get.find<ProfileController>();
    return Row(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.055,
          width: MediaQuery.of(context).size.width * 0.45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: profileController.selectedRestaurantCategoryId,
              isExpanded: true,
              hint: Text(
                S.of(context).allCategories,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: appFont('Rubik', 
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
                    S.of(context).allCategories,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appFont('Rubik', 
                      fontSize: 14,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                ...profileController.restaurantCategoriesForDropdown.map(
                  (c) => DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(
                      c.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appFont('Rubik', 
                        fontSize: 14,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
              ],
              onChanged: (int? categoryId) {
                profileController.setSelectedRestaurantCategoryId(categoryId);
                profileController.fetchRestaurantMenus(keyword: _searchKeyword);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAddRow({bool isItemsTab = false}) {
    final profileController = Get.find<ProfileController>();
    return VendorCategoryAddRow(
      categories: profileController.restaurantCategoriesForDropdown,
      selectedCategoryId: profileController.selectedRestaurantCategoryId,
      onCategoryChanged: (int? categoryId) {
        profileController.setSelectedRestaurantCategoryId(categoryId);
        if (isItemsTab) {
          profileController.fetchGroceryMenuItems(
            categoryId: categoryId,
            keyword: _searchKeyword.trim(),
          );
        } else {
          profileController.fetchRestaurantMenus(keyword: _searchKeyword);
        }
      },
      onAddPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMenuScreen()),
        );
      },
    );
  }

  Widget _buildBulkImportCategoryRow() {
    final profileController = Get.find<ProfileController>();
    return VendorCategoryAddRow(
      categories: profileController.restaurantCategoriesForDropdown,
      selectedCategoryId: profileController.selectedRestaurantCategoryId,
      onCategoryChanged: (int? categoryId) {
        profileController.setSelectedRestaurantCategoryId(categoryId);
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
    String restaurantMenuItemId,
    String category, {
    String? imageUrl,
    String? id,
    String price = "",
    String? discountPrice,
    List<RestaurantCategory>? categories,
  }) {
    return _richCard(
      id: id ?? "",
      restaurantMenuItemId: restaurantMenuItemId,
      name: name,
      category: category,
      price: price,
      originalPrice: discountPrice,
      imageUrl: imageUrl,
      itemId: id ?? "",
      isMenu: true,
      categories: categories,
    );
  }

  Widget _richCard({
    required String id,
    required String restaurantMenuItemId,
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
        if (isMenu) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewMenuDetails(restaurantMenuId: itemId),
            ),
          );
        } else {
          debugPrint("restaurantMenuItemId: $restaurantMenuItemId");
          debugPrint("itemId: $itemId");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewItemDetails(
                itemId: restaurantMenuItemId,
                menuItemId: restaurantMenuItemId,
              ),
            ),
          );
        }
      },
      onEdit: () {
        if (isMenu) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditMenuScreen(itemId: restaurantMenuItemId),
            ),
          );
        } else {
          void openAdvanced() => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditItemsScreen(itemId: restaurantMenuItemId),
            ),
          );
          final profileController = Get.find<ProfileController>();
          if (profileController.vendorType != "1") {
            openAdvanced();
            return;
          }
          // Restaurant catalog: quick edit first, "Advanced edit" inside (V9).
          showQuickEditItemSheet(
            context,
            itemId: restaurantMenuItemId,
            onAdvanced: openAdvanced,
          ).then((saved) {
            if (saved == true) {
              profileController.fetchGroceryMenuItems(
                categoryId: profileController.selectedRestaurantCategoryId,
                keyword: _searchKeyword.trim(),
              );
            }
          });
        }
      },
      onDelete: isMenu
          ? () {
              final menuController =
                  Get.isRegistered<menu_ctrl.MenuController>()
                  ? Get.find<menu_ctrl.MenuController>()
                  : Get.put(menu_ctrl.MenuController(), permanent: false);
              menuController.deleteMenu(context, restaurantMenuId: itemId);
            }
          : () {
              final itemController = Get.isRegistered<ItemController>()
                  ? Get.find<ItemController>()
                  : Get.put(ItemController(), permanent: false);
              itemController.deleteItem(
                context,
                restaurantMenuItemId: restaurantMenuItemId,
              );
            },
      onAddItem: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddItemsScreen(initialMenuName: name),
          ),
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
          final card = _foodItem(
            name,
            price,
            item.menuItemId?.toString() ?? item.id?.toString() ?? "",
            item.image,
            item.menuItemId?.toString() ?? item.id.toString(),
            category: category,
            availabilityStatus: item.availableStatus,
          );
          // Hide / unhide (§6.21): grocery and local store rows are menu
          // rows, so the row id is the menu_id.
          if (item.id == null) return card;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              card,
              ProductVisibilityBar(
                key: ValueKey('vis-${item.id}'),
                vertical: groceryVerticalFor(profileController.vendorType),
                menuId: item.id!,
                initial: item.visibility,
              ),
              const SizedBox(height: 8),
            ],
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
          final card = _foodItem(
            name,
            displayPrice,
            item.restaurantMenuItemId?.toString() ?? item.id?.toString() ?? "",
            item.image ?? "",
            // Card "ID" should represent the actual restaurant menu item id.
            item.restaurantMenuItemId?.toString() ?? item.id.toString(),
            category: category,
            originalPrice: originalPrice,
            availabilityStatus: item.availableStatus,
          );
          // Hide / unhide (§6.21, backend #132): catalog rows are menu rows,
          // so the row id is the menu_id for vertical `food`.
          if (profileController.vendorType != "1" || item.id == null || item.id == 0) {
            return card;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              card,
              ProductVisibilityBar(
                key: ValueKey('vis-food-${item.id}'),
                vertical: 'food',
                menuId: item.id!,
                initial: item.visibility,
              ),
              const SizedBox(height: 8),
            ],
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
    String restaurantMenuItemId,
    String? imageUrl,
    String itemId, {
    String category = "",
    List<RestaurantCategory>? categories,
    String? originalPrice,
    int? availabilityStatus,
  }) {
    return _richCard(
      id: itemId,
      restaurantMenuItemId: restaurantMenuItemId,
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

  Widget _buildBulkImportActionsRow({
    required ProfileController profileController,
  }) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () =>
                profileController.downloadRestaurantCatalogTemplate(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2EB),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFCCBA), width: 1),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).downloadTemplate,
                      style: appFont('Rubik', 
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.file_download_outlined,
                      size: 16,
                      color: Color(0xFF374151),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () => profileController.uploadImages(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FE),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFBFD2F8), width: 1),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).uploadImagesLabel,
                      style: appFont('Rubik', 
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.file_upload_outlined,
                      size: 16,
                      color: Color(0xFF374151),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkImportCategoryCardsGrid({
    required ProfileController profileController,
  }) {
    if (profileController.isRestaurantCategoriesLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(
            color: Color(0xFFFF5216),
          ),
        ),
      );
    }

    final categories = profileController.restaurantCategories;

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: NoDataWidget(
          context,
          S.of(context).noCategoriesFound,
          "",
          "lib/assets/images/nodata.png",
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryId = category.id;
        final categoryName = category.displayName.isNotEmpty
            ? category.displayName
            : (category.nameEn ?? "Category");

        final rawImage = category.image?.trim();
        String? finalImageUrl;
        if (rawImage != null && rawImage.isNotEmpty) {
          if (rawImage.contains('localhost/storage/')) {
            finalImageUrl = rawImage
                .replaceFirst('http://localhost/storage/', ApiConfigs.IMAGE_URL)
                .replaceFirst('https://localhost/storage/', ApiConfigs.IMAGE_URL);
          } else if (rawImage.startsWith('http://') ||
              rawImage.startsWith('https://')) {
            finalImageUrl = rawImage;
          } else {
            finalImageUrl = '${ApiConfigs.IMAGE_URL}$rawImage';
          }
        }

        return _bulkImportCategoryCard(
          categoryName: categoryName,
          imageUrl: finalImageUrl,
          onImport: () async {
            profileController.setSelectedRestaurantCategoryId(categoryId);
            await _pickBulkImportXlsxFile();
          },
        );
      },
    );
  }

  Widget _bulkImportCategoryCard({
    required String categoryName,
    required String? imageUrl,
    required Future<void> Function() onImport,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: double.infinity,
                      height: 100,
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF5216),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 100,
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.fastfood,
                        color: Color(0xFFFF5216),
                        size: 30,
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 100,
                    color: const Color(0xFFF1F5F9),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.fastfood,
                      color: Color(0xFFFF5216),
                      size: 30,
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: appFont('Rubik', 
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: onImport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5216),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                "Import",
                style: appFont('Rubik', 
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
