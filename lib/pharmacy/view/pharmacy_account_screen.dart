import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/settings_controller.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_business_settings_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_coupons_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_delivery_boys_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_earnings_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_help_support_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_leave_management_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_privacy_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_profile_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_received_payouts_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_working_hours_screen.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';
import 'package:saimpex_vendor/view/login/login.dart';
import 'package:saimpex_vendor/view/settings/terms_and_conditions.dart';

class PharmacyAccountScreen extends StatefulWidget {
  const PharmacyAccountScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF1C1D1B);
  static const iconBg = Color(0xFFEFEEEA);

  @override
  State<PharmacyAccountScreen> createState() => _PharmacyAccountScreenState();
}

class _PharmacyAccountScreenState extends State<PharmacyAccountScreen> {
  int _language = 0;
  bool _notifications = true;
  ProfileData? _profileData;
  Map<String, dynamic>? _rawVendorData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPharmacyProfile();
  }

  Future<void> _fetchPharmacyProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        debugPrint("⚠️ No auth token found. Skipping profile API call in PharmacyAccountScreen.");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
              : "3");

      final now = DateTime.now();
      final fromDate =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final toDate = fromDate;

      final queryParams = <String, dynamic>{
        "vendor_type": vendorType,
        "from_date": fromDate,
        "to_date": toDate,
      };

      final headers = <String, dynamic>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      String base = ApiConfigs.BASE_URL.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      if (base.endsWith('/vendor')) {
        base = base.substring(0, base.length - 7);
      } else if (base.endsWith('/vendorapp')) {
        base = base.substring(0, base.length - 10);
      }
      final fullUrl =
          Uri.parse("$base/${ApiEndPoints.pharmacyProfile}")
              .replace(queryParameters: queryParams);

      debugPrint("==================== GET VENDOR PROFILE (ACCOUNT SCREEN) ====================");
      debugPrint("API Call: GET $fullUrl");
      debugPrint("Header: $headers");
      debugPrint("Request Body: null (GET request)");

      print("==================== GET VENDOR PROFILE (ACCOUNT SCREEN) ====================");
      print("API Call: GET $fullUrl");
      print("Header: $headers");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyProfile,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("============================================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("============================================================================");

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          dataMap = jsonDecode(response.data as String) as Map<String, dynamic>?;
        } catch (_) {}
      }

      if (dataMap != null) {
        final profileModel = ProfileModel.fromJson(dataMap);
        final fetchedData = profileModel.data;
        final rawData = (dataMap['data'] is Map<String, dynamic>)
            ? ((dataMap['data']['vendor'] as Map<String, dynamic>?) ??
                dataMap['data'] as Map<String, dynamic>?)
            : null;

        if (mounted) {
          setState(() {
            _profileData = fetchedData;
            _rawVendorData = rawData;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("==================== GET VENDOR PROFILE ERROR (ACCOUNT SCREEN) ====================");
      debugPrint("Error: $e");
      debugPrint("===================================================================================");

      print("==================== GET VENDOR PROFILE ERROR (ACCOUNT SCREEN) ====================");
      print("Error: $e");
      print("===================================================================================");

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getTermsAndConditionsUrl() {
    final rawBase = ApiConfigs.BASE_URL.trim();
    String base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    String endpoint = ApiEndPoints.pharmacyTermsandConditions.trim();
    if (endpoint.startsWith('/')) endpoint = endpoint.substring(1);

    if (base.endsWith('/vendorapp') && endpoint.startsWith('vendorapp/')) {
      return '$base/${endpoint.substring(10)}';
    }
    if (base.endsWith('/vendor') && endpoint.startsWith('vendor/')) {
      return '$base/${endpoint.substring(7)}';
    }
    if (base.endsWith('/vendor') && endpoint.startsWith('vendorapp/')) {
      final rootApi = base.substring(0, base.length - 7);
      return '$rootApi/$endpoint';
    }
    if (base.endsWith('/vendorapp') && endpoint.startsWith('vendor/')) {
      final rootApi = base.substring(0, base.length - 10);
      return '$rootApi/$endpoint';
    }
    return '$base/$endpoint';
  }

  Future<void> _onTermsAndConditionsTap() async {
    final url = _getTermsAndConditionsUrl();

    debugPrint("==================== GET TERMS AND CONDITIONS ====================");
    debugPrint("API Call: GET $url");
    debugPrint("Request Body: null (GET request)");

    print("==================== GET TERMS AND CONDITIONS ====================");
    print("API Call: GET $url");
    print("Request Body: null (GET request)");

    try {
      final response = await DioClient().get(
        ApiEndPoints.pharmacyTermsandConditions,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("==================================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("==================================================================");

      if (response.data is Map && response.data['status'] == true) {
        final terms = response.data['data']?['terms'];
        if (terms != null) {
          final settingsController = Get.isRegistered<SettingsController>()
              ? Get.find<SettingsController>()
              : Get.put(SettingsController());
          final localization = FlutterLocalization.instance;
          final languageCode = localization.currentLocale?.languageCode;

          if (languageCode == 'fr' && terms['content_fr'] != null) {
            settingsController.htmlData = terms['content_fr'].toString();
          } else if (languageCode == 'ar' && terms['content_ar'] != null) {
            settingsController.htmlData = terms['content_ar'].toString();
          } else {
            settingsController.htmlData =
                (terms['content_en'] ?? "No content available").toString();
          }
          settingsController.isLoading = false;
          settingsController.update();
        }
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const TermsandConditions(),
          ),
        );
      }
    } catch (e) {
      debugPrint("==================== GET TERMS AND CONDITIONS ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("========================================================================");

      print("==================== GET TERMS AND CONDITIONS ERROR ====================");
      print("Error: $e");
      print("========================================================================");

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const TermsandConditions(),
          ),
        );
      }
    }
  }

  void _openMenu() {
    final top = MediaQuery.paddingOf(context).top + 56;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogContext, _, _) {
        return Padding(
          padding: EdgeInsets.only(top: top, right: 12),
          child: Align(
            alignment: Alignment.topRight,
            child: Material(
              color: Colors.white,
              elevation: 6,
              shadowColor: const Color(0xFF1A1A1A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => Navigator.of(dialogContext).pop(),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _DeleteLidIcon(),
                      const SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1C1D1B),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFC8C8C8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await savename('loginStatus', 'false');
    await savename('token', '');
    Get.offAll(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1E4),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 8, bottom: 28),
              child: _AccountHeader(onBack: widget.onBack, onMenu: _openMenu),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _ProfileCard(
                    name: _profileData?.name ??
                        _rawVendorData?['name']?.toString() ??
                        _rawVendorData?['pharmacy_name']?.toString() ??
                        'Pharmacy SAIMPEX',
                    id: _profileData?.id?.toString() ??
                        _rawVendorData?['id']?.toString() ??
                        'PH-99283',
                    rating: _profileData?.rating ??
                        _rawVendorData?['rating']?.toString() ??
                        '4.8',
                    isOpen: true,
                    imageUrl: _profileData?.image ??
                        _rawVendorData?['image']?.toString(),
                    isVerified: true,
                  ),
                  const SizedBox(height:10),
                  Text(
                    'Language',
                    style: GoogleFonts.inter(
                      color: PharmacyAccountScreen.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LanguageBar(
                    selected: _language,
                    onSelect: (index) => setState(() => _language = index),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Business',
                    style: GoogleFonts.inter(
                      color: PharmacyAccountScreen.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    divided: true,
                    children: [
                      _MenuTile(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notification',
                        trailing: Switch(
                          value: _notifications,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() => _notifications = value);
                          },
                          thumbColor: const WidgetStatePropertyAll(Colors.white),
                          trackColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return PharmacyAccountScreen.orange;
                            }
                            return const Color(0xFFE5E7EB);
                          }),
                          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                        ),
                      ),
                      _MenuTile(
                        icon: Icons.domain_outlined,
                        label: 'Pharmacy Profile',
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyProfileScreen(),
                            ),
                          );
                          if (mounted) {
                            _fetchPharmacyProfile();
                          }
                        },
                      ),
                      _MenuTile(
                        icon: Icons.access_time_rounded,
                        label: 'Working hours',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyWorkingHoursScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        image: 'lib/pharmacy/Assets/images/business_settings.png',
                        imageSize: 19,
                        label: 'Business settings',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyBusinessSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        image: 'lib/pharmacy/Assets/images/leave_management.png',
                        imageSize: 19,
                        label: 'Leave Management',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyLeaveManagementScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        image: 'lib/pharmacy/Assets/images/currency.png',
                        imageSize: 20,
                        label: 'Earnings',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyEarningsScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        image: 'lib/pharmacy/Assets/images/received_payouts.png',
                        imageSize: 22,
                        label: 'Received Payouts',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyReceivedPayoutsScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        icon: Icons.sell_outlined,
                        label: 'Coupons',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyCouponsScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        icon: Icons.delivery_dining_outlined,
                        label: 'Delivery Boys',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyDeliveryBoysScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionLabel('Support & Legal'),
                  const SizedBox(height: 10),
                  _MenuCard(
                    divided: true,
                    children: [
                      _MenuTile(
                        icon: Icons.headset_mic_outlined,
                        label: 'Help & Support',
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyHelpSupportScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        icon: Icons.description_outlined,
                        label: 'Terms & Conditions',
                        onTap: _onTermsAndConditionsTap,
                      ),
                      _MenuTile(
                        image: 'lib/pharmacy/Assets/images/privacy_policy.png',
                        imageSize: 20,
                        label: 'Privacy Policy',
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyPrivacyScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: _logout,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: PharmacyAccountScreen.orange, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Logout',
                            style: GoogleFonts.inter(
                              color: PharmacyAccountScreen.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'V2.8.1',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF858585),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check for update',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF5C5C5C),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF5C5C5C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({this.onBack, this.onMenu});

  final VoidCallback? onBack;
  final VoidCallback? onMenu;

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
              'Account',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.2,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
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
                    color: PharmacyAccountScreen.orange,
                    size: 26,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onMenu,
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(Icons.more_vert, color: Color(0xFF1A1A1A), size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    this.name = 'Pharmacy SAIMPEX',
    this.id = 'PH-99283',
    this.rating = '4.8',
    this.isOpen = true,
    this.imageUrl,
    this.isVerified = true,
  });

  final String name;
  final String id;
  final String rating;
  final bool isOpen;
  final String? imageUrl;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
              const SizedBox(width: 2),
              Text(
                rating,
                style: GoogleFonts.inter(
                  color: PharmacyAccountScreen.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: isOpen ? const Color.fromARGB(255, 23, 155, 71) : const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOpen ? 'Open' : 'Closed',
                      style: GoogleFonts.inter(
                        color: isOpen ? const Color.fromARGB(255, 23, 155, 71) : const Color(0xFFDC2626),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _LogoBadge(imageUrl: imageUrl),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.inter(
              color: PharmacyAccountScreen.ink,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: isVerified ? const Color.fromARGB(255, 23, 155, 71) : const Color(0xFF9CA3AF),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isVerified ? 'Verified' : 'Unverified',
                  style: GoogleFonts.inter(
                    color: isVerified ? const Color.fromARGB(255, 23, 155, 71) : const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            id.startsWith('ID:') ? id : 'ID: $id',
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final String? fullUrl = imageUrl != null && imageUrl!.trim().isNotEmpty
        ? (imageUrl!.startsWith('http')
            ? imageUrl
            : '${ApiConfigs.IMAGE_URL}$imageUrl')
        : null;

    if (fullUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          fullUrl,
          width: 112,
          height: 112,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'lib/pharmacy/Assets/images/profile_iconimage.png',
            width: 112,
            height: 112,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Image.asset(
      'lib/pharmacy/Assets/images/profile_iconimage.png',
      width: 112,
      height: 112,
      fit: BoxFit.contain,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
        style: GoogleFonts.inter(
          color: const Color(0xFF8B919E),
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.2,
        ),
    );
  }
}

class _LanguageBar extends StatelessWidget {
  const _LanguageBar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _labels = ['English', 'French', 'Arabic'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDFD7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segment = constraints.maxWidth / _labels.length;
          return SizedBox(
            height: 40,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: selected * segment,
                  top: 0,
                  bottom: 0,
                  width: segment,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: PharmacyAccountScreen.orange,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_labels.length, (index) {
                    final isSelected = selected == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (index == selected) return;
                          HapticFeedback.selectionClick();
                          onSelect(index);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            style: GoogleFonts.inter(
                              color: isSelected ? Colors.white : const Color(0xFF3F3F4D),
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 14,
                              height: 1.1,
                            ),
                            child: Text(_labels[index]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children, this.divided = false});

  final List<Widget> children;
  final bool divided;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (divided && i != children.length - 1) {
        rows.add(const Divider(
          height: 1,
          thickness:.2,
          color: Color(0xFFF1F1F1),
        ));
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5216).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: rows),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    this.icon,
    this.image,
    this.imageSize = 20,
    required this.label,
    this.trailing,
    this.labelColor = const Color(0xFF1C1D1B),
    this.showChevron = true,
    this.onTap,
  });

  final IconData? icon;
  final String? image;
  final double imageSize;
  final String label;
  final Widget? trailing;
  final Color labelColor;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: PharmacyAccountScreen.iconBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            child: image != null
                ? SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Image.asset(image!, fit: BoxFit.contain),
                  )
                : Icon(icon, color: PharmacyAccountScreen.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: labelColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ),
          trailing ??
              (showChevron
                  ? const Icon(Icons.chevron_right_rounded, color: Color(0xFFC8C8C8), size: 22)
                  : const SizedBox(width: 22)),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

class _DeleteLidIcon extends StatefulWidget {
  const _DeleteLidIcon();

  @override
  State<_DeleteLidIcon> createState() => _DeleteLidIconState();
}

class _DeleteLidIconState extends State<_DeleteLidIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _lidOpen(double t) {
    if (t < 0.35) return Curves.easeOutCubic.transform(t / 0.35);
    if (t < 0.55) return 1;
    if (t < 0.90) return 1 - Curves.easeInCubic.transform((t - 0.55) / 0.35);
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _DeleteLidPainter(lidOpen: _lidOpen(_controller.value)),
          );
        },
      ),
    );
  }
}

class _DeleteLidPainter extends CustomPainter {
  const _DeleteLidPainter({required this.lidOpen});

  final double lidOpen;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PharmacyAccountScreen.orange
      ..style = PaintingStyle.fill;

    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.38,
        size.width * 0.56,
        size.height * 0.54,
      ),
      bottomLeft: const Radius.circular(2.5),
      bottomRight: const Radius.circular(2.5),
    );
    canvas.drawRRect(body, paint);

    final slot = Paint()..color = Colors.white;
    final slotTop = body.top + body.height * 0.18;
    final slotHeight = body.height * 0.55;
    final slotWidth = size.width * 0.07;
    for (final left in [body.left + body.width * 0.28, body.left + body.width * 0.58]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, slotTop, slotWidth, slotHeight),
          const Radius.circular(1.5),
        ),
        slot,
      );
    }

    final lid = Rect.fromLTWH(
      size.width * 0.12,
      size.height * 0.28,
      size.width * 0.76,
      size.height * 0.10,
    );
    final hinge = Offset(lid.left, lid.bottom);
    canvas.save();
    canvas.translate(hinge.dx, hinge.dy);
    canvas.rotate(-0.9 * lidOpen);
    canvas.translate(-hinge.dx, -hinge.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(lid, const Radius.circular(1.2)), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.38,
          size.height * 0.16,
          size.width * 0.24,
          size.height * 0.12,
        ),
        const Radius.circular(1.5),
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeleteLidPainter oldDelegate) {
    return oldDelegate.lidOpen != lidOpen;
  }
}
