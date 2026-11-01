import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
import 'package:saimpex_vendor/model/rating_review_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';
import 'package:saimpex_vendor/view/restaurant/rating_reviews_screen.dart';

class StoreProfileView extends StatefulWidget {
  const StoreProfileView({super.key});

  static const _label = Color(0xFF8A97A8);
  static const _value = Color(0xFF4C5260);
  static const _ink = Color(0xFF1C1D1B);
  static const _orange = Color(0xFFFF5216);

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const StoreProfileView()),
    );
  }

  @override
  State<StoreProfileView> createState() => _StoreProfileViewState();
}

class _StoreProfileViewState extends State<StoreProfileView> {
  ProfileData? _profileData;
  Map<String, dynamic>? _rawVendorData;
  List<ReviewItem> _reviews = [];

  /// Home cleaning: the cleaner's review per order, from `vendorapp/profile`
  /// `reviews[].cleaner_review` (API doc §6.39, task V16).
  Map<int, Map<String, dynamic>> _cleanerReviews = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchProfile(),
      _fetchRatingsReviews(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      } else {
        return;
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorType = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "1");

      final now = DateTime.now();
      final fromDate =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final queryParams = <String, dynamic>{
        "vendor_type": vendorType,
        "from_date": fromDate,
        "to_date": fromDate,
        "limit": 10,
        "page": 1,
      };

      debugPrint("==================== GET STORE PROFILE ====================");
      debugPrint("Endpoint: ${ApiEndPoints.profile}");
      debugPrint("Query: $queryParams");

      print("==================== GET STORE PROFILE ====================");
      print("Endpoint: ${ApiEndPoints.profile}");
      print("Query: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.profile,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      print("Response Status Code: ${response.statusCode}");

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          dataMap = jsonDecode(response.data as String) as Map<String, dynamic>?;
        } catch (_) {}
      }

      if (dataMap != null && mounted) {
        final profileModel = ProfileModel.fromJson(dataMap);
        final fetchedData = profileModel.data;
        final rawData = (dataMap['data'] is Map<String, dynamic>)
            ? ((dataMap['data']['vendor'] as Map<String, dynamic>?) ??
                dataMap['data'] as Map<String, dynamic>?)
            : null;

        final rawReviews = dataMap['data'] is Map ? (dataMap['data'] as Map)['reviews'] : null;
        final cleanerReviews = <int, Map<String, dynamic>>{};
        if (rawReviews is List) {
          for (final rv in rawReviews.whereType<Map>()) {
            final orderId = int.tryParse('${rv['order_id'] ?? ''}');
            final cr = rv['cleaner_review'];
            if (orderId != null && cr is Map) cleanerReviews[orderId] = Map<String, dynamic>.from(cr);
          }
        }
        setState(() {
          _profileData = fetchedData;
          _rawVendorData = rawData;
          _cleanerReviews = cleanerReviews;
        });
      }
    } catch (e) {
      debugPrint("==================== GET STORE PROFILE ERROR ====================");
      debugPrint("Error: $e");
      print("==================== GET STORE PROFILE ERROR ====================");
      print("Error: $e");
    }
  }

  Future<void> _fetchRatingsReviews() async {
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorType = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "1");

      final queryParams = <String, dynamic>{
        "limit": 10,
        "vendor_type": vendorType,
        "page": 1,
      };

      debugPrint("==================== GET RATING & REVIEWS ====================");
      debugPrint("Endpoint: ${ApiEndPoints.getRatingReview}");
      debugPrint("Query: $queryParams");

      print("==================== GET RATING & REVIEWS ====================");
      print("Endpoint: ${ApiEndPoints.getRatingReview}");
      print("Query: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.getRatingReview,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      print("Response Status Code: ${response.statusCode}");

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          dataMap = jsonDecode(response.data as String) as Map<String, dynamic>?;
        } catch (_) {}
      }

      if (dataMap != null && mounted) {
        List<ReviewItem> items = [];
        if (dataMap['data'] is Map<String, dynamic>) {
          final model = RatingReviewModel.fromJson(dataMap);
          items = model.data?.reviews ?? [];
        } else if (dataMap['data'] is List) {
          items = (dataMap['data'] as List)
              .map((i) => ReviewItem.fromJson(i as Map<String, dynamic>?))
              .toList();
        }

        setState(() {
          _reviews = items;
        });
      }
    } catch (e) {
      debugPrint("==================== GET RATING & REVIEWS ERROR ====================");
      debugPrint("Error: $e");
      print("==================== GET RATING & REVIEWS ERROR ====================");
      print("Error: $e");
    }
  }

  String _formatContact(String? code, String? mobile) {
    final c = (code ?? '').trim();
    final m = (mobile ?? '').trim();
    if (c.isEmpty && m.isEmpty) return '';
    if (c.isEmpty) return m;
    if (m.isEmpty) return c;
    return '$c$m';
  }

  String _formatCommission(String? value) {
    if (value == null || value.trim().isEmpty || value == 'null') return '';
    final trimmed = value.trim();
    return trimmed.endsWith('%') ? trimmed : '$trimmed%';
  }

  String _formatProfit(String? value) {
    if (value == null || value.trim().isEmpty || value == 'null') return '';
    final trimmed = value.trim();
    return trimmed.contains('MRU') ? trimmed : '$trimmed MRU';
  }

  @override
  Widget build(BuildContext context) {
    final storeName = _profileData?.name ??
        _rawVendorData?['name']?.toString() ??
        _rawVendorData?['store_name']?.toString() ??
        _rawVendorData?['vendor_name']?.toString() ??
        '';
    final ownerName = _profileData?.owner ??
        _rawVendorData?['owner']?.toString() ??
        _rawVendorData?['owner_name']?.toString() ??
        '';
    final storeId = _profileData?.id?.toString() ??
        _rawVendorData?['id']?.toString() ??
        '';
    final contact = _formatContact(
      _profileData?.countryCode ?? _rawVendorData?['country_code']?.toString(),
      _profileData?.mobile ?? _rawVendorData?['mobile']?.toString(),
    );
    final email = _profileData?.email ??
        _rawVendorData?['email']?.toString() ??
        '';
    final rawStatus = _profileData?.status ?? _rawVendorData?['status']?.toString();
    final status = (rawStatus == '1' || rawStatus?.toLowerCase() == 'active' || rawStatus?.toLowerCase() == 'true')
        ? S.of(context).active
        : (rawStatus == '0' || rawStatus?.toLowerCase() == 'inactive' || rawStatus?.toLowerCase() == 'false'
            ? S.of(context).inactive
            : (rawStatus != null && rawStatus != 'null' ? rawStatus.toUpperCase() : ''));
    final address = _profileData?.address ??
        _rawVendorData?['address']?.toString() ??
        '';

    final holderName = _profileData?.accountHolderName ??
        _rawVendorData?['account_holder_name']?.toString() ??
        _rawVendorData?['holder_name']?.toString() ??
        _rawVendorData?['bank_holder_name']?.toString() ??
        '';
    final ibanNumber = _profileData?.accountNumber ??
        _rawVendorData?['account_number']?.toString() ??
        _rawVendorData?['iban']?.toString() ??
        _rawVendorData?['iban_number']?.toString() ??
        '';
    final swiftCode = _profileData?.ifscCode ??
        _rawVendorData?['ifsc_code']?.toString() ??
        _rawVendorData?['swift']?.toString() ??
        _rawVendorData?['swift_code']?.toString() ??
        '';

    final regNumber = _profileData?.registrationNumber ??
        _rawVendorData?['registration_number']?.toString() ??
        _rawVendorData?['reg_number']?.toString() ??
        '';
    final regDate = _profileData?.registrationDate ??
        _rawVendorData?['registration_date']?.toString() ??
        _rawVendorData?['reg_date']?.toString() ??
        '';
    final tinNumber = _profileData?.gstNo ??
        _rawVendorData?['gst_no']?.toString() ??
        _rawVendorData?['tin_number']?.toString() ??
        _rawVendorData?['nif_number']?.toString() ??
        '';

    final commission = _formatCommission(
      _profileData?.commissionPercentage ??
          _rawVendorData?['commission_percentage']?.toString() ??
          _rawVendorData?['commission']?.toString(),
    );
    final totalProfit = _formatProfit(
      _profileData?.totalProfit ??
          _rawVendorData?['total_profit']?.toString() ??
          _rawVendorData?['profit']?.toString(),
    );

    final ownerIdProof = _profileData?.ownerIdProof ??
        _rawVendorData?['owner_id_proof']?.toString();
    final certificate = _profileData?.certificate ??
        _rawVendorData?['certificate']?.toString();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE8E0), Color(0xFFFFF4F0), Colors.white],
              stops: [0, 0.18, 0.36],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: StoreProfileView._orange,
                        ),
                      )
                    : RefreshIndicator(
                        color: StoreProfileView._orange,
                        onRefresh: _fetchData,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                          children: [
                            _SectionTitle(S.of(context).waterStoreDetails),
                            const SizedBox(height: 8),
                            _InfoCard(
                              rows: [
                                _InfoRow(S.of(context).name, storeName),
                                _InfoRow(S.of(context).owner, ownerName),
                                _InfoRow(S.of(context).idNumber, storeId),
                                // Phone number is embedded LTR so "+222…" keeps its order in RTL.
                                _InfoRow(S.of(context).contact, contact.isEmpty ? '' : '\u202A$contact\u202C'),
                                _InfoRow(S.of(context).email, email),
                                _InfoRow(S.of(context).status, status, badge: true),
                                _InfoRow(S.of(context).address, address),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _SectionTitle(S.of(context).waterBankDetails),
                            const SizedBox(height: 8),
                            _InfoCard(
                              rows: [
                                _InfoRow(S.of(context).holderName, holderName),
                                _InfoRow(S.of(context).ibanNumber, ibanNumber),
                                _InfoRow(S.of(context).swiftCode, swiftCode),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _SectionTitle(S.of(context).waterRegistrationDetails),
                            const SizedBox(height: 8),
                            _InfoCard(
                              rows: [
                                _InfoRow(S.of(context).regNumber, regNumber),
                                _InfoRow(S.of(context).regDate, regDate),
                                _InfoRow(S.of(context).waterTinNifNumber, tinNumber),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _SectionTitle(S.of(context).waterPaymentDetails),
                            const SizedBox(height: 8),
                            _InfoCard(
                              rows: [
                                _InfoRow(S.of(context).commissionPercentage, commission),
                                _InfoRow(S.of(context).totalProfit, totalProfit, emphasize: true),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _SectionTitle(S.of(context).waterOwnerIdentityProof),
                            const SizedBox(height: 8),
                            _EmptyCard(imageUrl: ownerIdProof),
                            const SizedBox(height: 18),
                            _SectionTitle(S.of(context).waterCertificate),
                            const SizedBox(height: 8),
                            _EmptyCard(imageUrl: certificate),
                            const SizedBox(height: 20),
                            _ReviewsHeader(
                              onSeeAll: () {
                                if (!Get.isRegistered<ProfileController>()) {
                                  Get.put(ProfileController());
                                }
                                Get.find<ProfileController>().getRatingsReviews(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RatingReviewsScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            if (_reviews.isNotEmpty)
                              for (var i = 0; i < _reviews.length; i++) ...[
                                _ReviewCard(review: _reviews[i], cleanerReview: _cleanerReviews[_reviews[i].orderId]),
                                if (i < _reviews.length - 1) const SizedBox(height: 10),
                              ]
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'lib/assets/images/nodata.png',
                                        height: 100,
                                        width: 120,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        S.of(context).noReviewsFound,
                                        textAlign: TextAlign.center,
                                        style: appFont('Inter', 
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: StoreProfileView._ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              S.of(context).waterStoreProfile,
              style: appFont('Inter', 
                color: StoreProfileView._ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE0D0)),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: StoreProfileView._orange,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: appFont('Inter', 
        color: const Color(0xFF37383A),
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value, {this.emphasize = false, this.badge = false});

  final String label;
  final String value;
  final bool emphasize;
  final bool badge;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      rows[i].label,
                      style: appFont('Inter', 
                        color: StoreProfileView._label,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (rows[i].badge)
                    rows[i].value.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              rows[i].value,
                              style: appFont('Inter', 
                                color: const Color(0xFF16A34A),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : const SizedBox()
                  else
                    Expanded(
                      flex: 6,
                      child: Text(
                        rows[i].value,
                        textAlign: TextAlign.end,
                        style: appFont('Inter', 
                          color: rows[i].emphasize
                              ? StoreProfileView._ink
                              : StoreProfileView._value,
                          fontWeight: rows[i].emphasize ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              const Divider(height: 1, thickness: .2, color: Color(0xFFF1F1F1)),
          ],
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final String? fullUrl = imageUrl != null && imageUrl!.trim().isNotEmpty && imageUrl != 'null'
        ? (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')
            ? imageUrl
            : '${ApiConfigs.IMAGE_URL}$imageUrl')
        : null;

    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: fullUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                fullUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            )
          : null,
    );
  }
}

class _ReviewsHeader extends StatelessWidget {
  const _ReviewsHeader({this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          S.of(context).ratingReviews.toUpperCase(),
          style: appFont('Inter', 
            color: const Color(0xFF2E3032),
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.4,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          behavior: HitTestBehavior.opaque,
          child: Text(
            S.of(context).viewAll,
            style: appFont('Inter', 
              color: StoreProfileView._orange,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({this.review, this.cleanerReview});

  final ReviewItem? review;

  /// Home cleaning: the customer's review of the cleaner on that booking.
  final Map<String, dynamic>? cleanerReview;

  String _formatDate(String? raw, String locale) {
    if (raw == null || raw.trim().isEmpty || raw == 'null') return '';
    final dt = DateTime.tryParse(raw.trim());
    if (dt != null) {
      try {
        return DateFormat('MMM dd yyyy, hh:mm a', locale)
            .format(dt)
            .replaceAll('AM', 'am')
            .replaceAll('PM', 'pm');
      } catch (_) {
        return formatOrderPlacedAt(dt);
      }
    }
    return raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    final username = review?.username?.trim().isNotEmpty == true
        ? review!.username!.trim()
        : '';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'S';
    final dateStr = _formatDate(
      review?.createdAt,
      Localizations.localeOf(context).languageCode,
    );

    final ratingVal = double.tryParse(review?.rating?.toString() ?? '0') ?? 0.0;
    final ratingDisplay = review?.rating?.toString().trim().isNotEmpty == true
        ? review!.rating!.toString().trim()
        : (ratingVal > 0 ? ratingVal.toStringAsFixed(1) : '0.0');

    final comment = review?.comment?.trim() ?? '';
    final rawOrder = review?.orderCode?.trim() ??
        (review?.orderId != null ? review!.orderId.toString() : '');
    final orderDisplay = rawOrder.isNotEmpty
        ? (rawOrder.toLowerCase().startsWith('order:')
            ? rawOrder
            : '${S.of(context).orderColon}$rawOrder')
        : '';

    final hasUserImage = review?.userImage != null &&
        review!.userImage!.trim().isNotEmpty &&
        review!.userImage != 'null';
    final String? userImageUrl = hasUserImage
        ? (review!.userImage!.startsWith('http')
            ? review!.userImage
            : '${ApiConfigs.IMAGE_URL}${review!.userImage}')
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: userImageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          userImageUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            initial,
                            style: appFont('Inter', 
                              color: const Color(0xFF059669),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        initial,
                        style: appFont('Inter', 
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            username,
                            style: appFont('Inter', 
                              color: const Color(0xFF3F4555),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (dateStr.isNotEmpty)
                          Text(
                            dateStr,
                            style: appFont('Inter', 
                              color: const Color(0xFF9AA8B8),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            i < ratingVal.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: i < ratingVal.round()
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFD1D5DB),
                            size: 16,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          ratingDisplay,
                          style: appFont('Inter', 
                            color: const Color(0xFF9AA8B8),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              comment,
              style: appFont('Inter', 
                color: const Color(0xFF3F4555),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
          if (cleanerReview != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      S.of(context).cleanerReviewOf('${cleanerReview!['cleaner_name'] ?? ''}'),
                      if (cleanerReview!['rating'] != null) '${double.tryParse('${cleanerReview!['rating']}')?.toStringAsFixed(1) ?? cleanerReview!['rating']} ★',
                    ].join('  ·  '),
                    style: appFont('Inter', color: const Color(0xFF9A3412), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  if ('${cleanerReview!['comment'] ?? ''}'.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${cleanerReview!['comment']}'.trim(),
                      style: appFont('Inter', color: const Color(0xFF3F4555), fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (orderDisplay.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 34,
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                orderDisplay,
                style: appFont('Inter', 
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
