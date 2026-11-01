import 'package:saimpex_vendor/view/settings/category_requests_screen.dart';
import 'package:saimpex_vendor/view/settings/order_rules_screen.dart';
import 'package:saimpex_vendor/view/support/support_messages.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/view/settings/widgets/printer_picker_dialog.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/settings_controller.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
import 'package:saimpex_vendor/pharmacy/controller/pharmacy_home_controller.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_business_settings_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_coupons_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_earnings_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_leave_management_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_profile_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_received_payouts_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_working_hours_screen.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';
import 'package:saimpex_vendor/controller/delivery_boys_controller.dart';
import 'package:saimpex_vendor/model/delivery_boys_model.dart';
import 'package:saimpex_vendor/view/login/login.dart';
import 'package:saimpex_vendor/view/settings/delivery_boys.dart';
import 'package:saimpex_vendor/view/settings/help_and_support.dart';
import 'package:saimpex_vendor/view/settings/privacy_policy.dart';
import 'package:saimpex_vendor/view/settings/terms_and_conditions.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _t(String key) {
  return LocalizationService.tr(key);
}

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
    _initSelectedLanguage();
    _fetchPharmacyProfile();
    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());
    settingsController.preloadSettings();
  }

  void _initSelectedLanguage() {
    final lang = LocalizationService.currentLanguageCode;
    if (lang == 'fr') {
      _language = 1;
    } else if (lang == 'ar') {
      _language = 2;
    } else {
      _language = 0;
    }
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final dynamic lang = await getSavedObject("selected_locale");
    if (lang != null && mounted) {
      final code = lang.toString();
      setState(() {
        if (code == 'fr') {
          _language = 1;
        } else if (code == 'ar') {
          _language = 2;
        } else {
          _language = 0;
        }
      });
    }
  }

  Future<void> _onLanguageSelected(int index) async {
    setState(() => _language = index);
    String langCode = 'en';
    if (index == 1) {
      langCode = 'fr';
    } else if (index == 2) {
      langCode = 'ar';
    }
    await LocalizationService().updateLocale(langCode);
    if (mounted) {
      setState(() {});
    }
    if (Get.isRegistered<PharmacyHomeController>()) {
      Get.find<PharmacyHomeController>().update();
    }
    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().onLanguageChanged();
    }
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
        debugPrint(
          "⚠️ No auth token found. Skipping profile API call in PharmacyAccountScreen.",
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorType =
          (savedVendorType != null &&
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
      final cleanEndpoint = ApiEndPoints.pharmacyProfile.replaceFirst(
        RegExp(r'^/'),
        '',
      );
      final fullUrl = Uri.parse(
        "$base/$cleanEndpoint",
      ).replace(queryParameters: queryParams);

      debugPrint(
        "==================== GET VENDOR PROFILE (ACCOUNT SCREEN) ====================",
      );
      debugPrint("API Call: GET $fullUrl");
      debugPrint("Header: $headers");
      debugPrint("Request Body: null (GET request)");

      print(
        "==================== GET VENDOR PROFILE (ACCOUNT SCREEN) ====================",
      );
      print("API Call: GET $fullUrl");
      print("Header: $headers");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyProfile,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "============================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "============================================================================",
      );

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          dataMap =
              jsonDecode(response.data as String) as Map<String, dynamic>?;
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
        final pName = fetchedData?.name ??
            rawData?['name']?.toString() ??
            rawData?['pharmacy_name']?.toString();
        if (pName != null && pName.isNotEmpty && Get.isRegistered<PharmacyHomeController>()) {
          Get.find<PharmacyHomeController>().setShopName(pName);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint(
        "==================== GET VENDOR PROFILE ERROR (ACCOUNT SCREEN) ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "===================================================================================",
      );

      print(
        "==================== GET VENDOR PROFILE ERROR (ACCOUNT SCREEN) ====================",
      );
      print("Error: $e");
      print(
        "===================================================================================",
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onTermsAndConditionsTap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TermsandConditions()),
    );
  }

  void _onHelpAndSupportTap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HelpAndSupport()),
    );
  }

  void _onPrivacyPolicyTap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PrivacyPolicy()),
    );
  }

  String _getCouponsUrl(Map<String, dynamic> query) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.pharmacyCoupons.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    final q = query.entries.map((e) => "${e.key}=${e.value}").join('&');
    return '$base/$endpoint?$q';
  }

  Future<void> _onCouponsTap() async {
    final queryParams = <String, dynamic>{
      "limit": 10,
      "keyword": "",
      "status": 1,
    };
    final url = _getCouponsUrl(queryParams);

    debugPrint("==================== GET COUPONS ====================");
    debugPrint("API Call: GET $url");
    debugPrint("Query: $queryParams");
    debugPrint("Request Body: null (GET request)");

    print("==================== GET COUPONS ====================");
    print("API Call: GET $url");
    print("Query: $queryParams");
    print("Request Body: null (GET request)");

    try {
      final response = await DioClient().get(
        ApiEndPoints.pharmacyCoupons,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("=====================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("=====================================================");

      List<dynamic> couponsData = [];
      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status'].toString() == 'true')) {
        final data = response.data['data'];
        if (data is Map) {
          final coupons = data['coupons'];
          if (coupons is List) {
            couponsData = coupons;
          } else if (coupons is Map && coupons['data'] is List) {
            couponsData = coupons['data'] as List;
          }
        } else if (data is List) {
          couponsData = data;
        }
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PharmacyCouponsScreen(initialCoupons: couponsData),
          ),
        );
      }
    } catch (e) {
      debugPrint("==================== GET COUPONS ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("===========================================================");

      print("==================== GET COUPONS ERROR ====================");
      print("Error: $e");
      print("===========================================================");

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const PharmacyCouponsScreen(),
          ),
        );
      }
    }
  }

  String _getDeliveryBoysUrl() {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.pharmacyDeliveryBoys.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    return '$base/$endpoint';
  }

  Future<void> _onDeliveryBoysTap() async {
    final url = _getDeliveryBoysUrl();

    debugPrint("==================== GET DELIVERY BOYS ====================");
    debugPrint("API Call: GET $url");
    debugPrint("Request Body: null (GET request)");

    print("==================== GET DELIVERY BOYS ====================");
    print("API Call: GET $url");
    print("Request Body: null (GET request)");

    try {
      final response = await DioClient().get(
        ApiEndPoints.pharmacyDeliveryBoys,
        query: {"limit": 10},
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("===========================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("===========================================================");

      if (response.data is Map) {
        final model = DeliveryBoysModel.fromJson(response.data);
        if (model.status == true && model.data?.deliveryStaffs?.data != null) {
          final controller = Get.isRegistered<DeliveryBoysController>()
              ? Get.find<DeliveryBoysController>()
              : Get.put(DeliveryBoysController());
          controller.deliveryBoysList = model.data!.deliveryStaffs!.data!;
          controller.filteredList = controller.deliveryBoysList;
          controller.isLoading = false;
          controller.update();
        }
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const DeliveryBoysScreen(isPharmacy: true),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "==================== GET DELIVERY BOYS ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "=================================================================",
      );

      print(
        "==================== GET DELIVERY BOYS ERROR ====================",
      );
      print("Error: $e");
      print(
        "=================================================================",
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const DeliveryBoysScreen()),
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
        final textDirection = LocalizationService().getTextDirection();
        final isRtl = textDirection == TextDirection.rtl;
        return Directionality(
          textDirection: textDirection,
          child: Padding(
            padding: EdgeInsets.only(
              top: top,
              right: isRtl ? 0 : 12,
              left: isRtl ? 12 : 0,
            ),
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Material(
                color: Colors.white,
                elevation: 6,
                shadowColor: const Color(0xFF1A1A1A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _showDeleteAccountConfirmation();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _DeleteLidIcon(),
                        const SizedBox(width: 8),
                        Text(
                          _t('Delete Account'),
                          style: appFont('Inter', 
                            color: const Color(0xFF1C1D1B),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          isRtl
                              ? Icons.chevron_left_rounded
                              : Icons.chevron_right_rounded,
                          color: const Color(0xFFC8C8C8),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteAccountConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x80000000),
      builder: (context) => const _DeleteAccountConfirmDialog(),
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    try {
      showLoadingDialog(context);
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      String base = ApiConfigs.BASE_URL.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      final cleanEndpoint = ApiEndPoints.deleteAccount.replaceFirst(
        RegExp(r'^/'),
        '',
      );
      final fullUrl = cleanEndpoint.startsWith('vendorapp/')
          ? "$base/$cleanEndpoint"
          : "$base/vendorapp/$cleanEndpoint";

      final headers = <String, dynamic>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      debugPrint(
        "==================== GET DELETE ACCOUNT ====================",
      );
      debugPrint("API Call: GET $fullUrl");
      debugPrint("Header: $headers");

      print("==================== GET DELETE ACCOUNT ====================");
      print("API Call: GET $fullUrl");
      print("Header: $headers");

      final response = await DioClient().get(ApiEndPoints.deleteAccount);

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("===========================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("===========================================================");

      if (mounted) {
        Get.back();
      }

      if (response.data != null &&
          (response.data['status'] == 'true' ||
              response.data['status'] == true ||
              response.data['status'] == 1 ||
              response.data['status'] == '1')) {
        final rawMsg = response.data['message'];
        String toastMessage = 'Account deleted successfully';
        if (rawMsg is String && rawMsg.isNotEmpty) {
          toastMessage = rawMsg;
        } else if (rawMsg is Map) {
          final list = rawMsg['message_en'] ?? rawMsg['message'];
          if (list is List && list.isNotEmpty) {
            toastMessage = list.first.toString();
          } else if (list is String && list.isNotEmpty) {
            toastMessage = list;
          }
        }
        if (mounted) {
          showToast(context, toastMessage);
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await savename("@isFirstLaunch", "true");
        await savename('loginStatus', 'false');
        await savename('token', '');
        Get.offAll(() => const LoginScreen());
      } else {
        final rawMsg = response.data is Map ? response.data['message'] : null;
        String errorMsg = 'Failed to delete account';
        if (rawMsg is String && rawMsg.isNotEmpty) {
          errorMsg = rawMsg;
        }
        if (mounted) {
          showToast(context, errorMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        Get.back();
      }
      debugPrint(
        "==================== GET DELETE ACCOUNT ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "==================================================================",
      );
      print(
        "==================== GET DELETE ACCOUNT ERROR ====================",
      );
      print("Error: $e");
      print(
        "==================================================================",
      );
      if (mounted) {
        showToast(context, e.toString().replaceFirst('Exception: ', '').trim());
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x80000000),
      builder: (context) => const _LogoutConfirmDialog(),
    );

    if (confirmed == true) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    try {
      showLoadingDialog(context);
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      }

      String base = ApiConfigs.BASE_URL.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      final cleanEndpoint = ApiEndPoints.logout.replaceFirst(RegExp(r'^/'), '');
      final fullUrl = cleanEndpoint.startsWith('vendorapp/')
          ? "$base/$cleanEndpoint"
          : "$base/vendorapp/$cleanEndpoint";

      final headers = <String, dynamic>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      debugPrint("==================== POST LOGOUT ====================");
      debugPrint("API Call: POST $fullUrl");
      debugPrint("Header: $headers");

      print("==================== POST LOGOUT ====================");
      print("API Call: POST $fullUrl");
      print("Header: $headers");

      final response = await DioClient().post(ApiEndPoints.logout);

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("=====================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("=====================================================");

      if (mounted) {
        Get.back();
      }

      if (response.data != null &&
          (response.data['status'] == 'true' ||
              response.data['status'] == true ||
              response.data['status'] == 1 ||
              response.data['status'] == '1')) {
        final rawMsg = response.data['message'];
        String toastMessage = 'You are logged out successfully.';
        if (rawMsg is String && rawMsg.isNotEmpty) {
          toastMessage = rawMsg;
        } else if (rawMsg is Map) {
          final list = rawMsg['message_en'] ?? rawMsg['message'];
          if (list is List && list.isNotEmpty) {
            toastMessage = list.first.toString();
          } else if (list is String && list.isNotEmpty) {
            toastMessage = list;
          }
        }
        if (mounted) {
          showToast(context, toastMessage);
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await savename("@isFirstLaunch", "true");
        await savename('loginStatus', 'false');
        await savename('token', '');
        Get.offAll(() => const LoginScreen());
      } else {
        final rawMsg = response.data is Map ? response.data['message'] : null;
        String errorMsg = 'Logout failed.';
        if (rawMsg is String && rawMsg.isNotEmpty) {
          errorMsg = rawMsg;
        }
        if (mounted) {
          showToast(context, errorMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        Get.back();
      }
      debugPrint("==================== POST LOGOUT ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("===========================================================");
      print("==================== POST LOGOUT ERROR ====================");
      print("Error: $e");
      print("===========================================================");
      if (mounted) {
        showToast(context, e.toString().replaceFirst('Exception: ', '').trim());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCode = LocalizationService.currentLanguageCode;
    _language = activeCode == 'fr' ? 1 : (activeCode == 'ar' ? 2 : 0);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Directionality(
        textDirection: LocalizationService().getTextDirection(),
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
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top + 8,
                  bottom: 28,
                ),
                child: _AccountHeader(onBack: widget.onBack, onMenu: _openMenu),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _ProfileCard(
                      name:
                          _profileData?.name ??
                          _rawVendorData?['name']?.toString() ??
                          _rawVendorData?['pharmacy_name']?.toString() ??
                          '',
                      id:
                          _profileData?.id?.toString() ??
                          _rawVendorData?['id']?.toString() ??
                          '',
                      rating:
                          _profileData?.rating ??
                          _rawVendorData?['rating']?.toString() ??
                          '',
                      isOpen:
                          (_profileData?.status?.toUpperCase() == 'ACTIVE' ||
                              _rawVendorData?['status']?.toString() == '1' ||
                              _profileData?.isBusy == 2) &&
                          (_profileData?.isBusy != 1),
                      imageUrl:
                          _profileData?.image ??
                          _rawVendorData?['image']?.toString(),
                      isVerified: true,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _t('Language'),
                      style: appFont('Inter', 
                        color: PharmacyAccountScreen.orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LanguageBar(
                      selected: _language,
                      onSelect: _onLanguageSelected,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _t('Business'),
                      style: appFont('Inter', 
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
                          label: _t('Notification'),
                          trailing: Switch(
                            value: _notifications,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: (value) {
                              HapticFeedback.selectionClick();
                              setState(() => _notifications = value);
                            },
                            thumbColor: const WidgetStatePropertyAll(
                              Colors.white,
                            ),
                            trackColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return PharmacyAccountScreen.orange;
                              }
                              return const Color(0xFFE5E7EB);
                            }),
                            trackOutlineColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.domain_outlined,
                          label: _t('Pharmacy Profile'),
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
                          label: _t('Working hours'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const PharmacyWorkingHoursScreen(),
                              ),
                            );
                          },
                        ),
                        _MenuTile(
                          image:
                              'lib/pharmacy/Assets/images/business_settings.png',
                          imageSize: 19,
                          label: _t('Business settings'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const PharmacyBusinessSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        _MenuTile(
                          image:
                              'lib/pharmacy/Assets/images/leave_management.png',
                          imageSize: 19,
                          label: _t('Leave Management'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const PharmacyLeaveManagementScreen(),
                              ),
                            );
                          },
                        ),
                        _MenuTile(
                          image: 'lib/pharmacy/Assets/images/currency.png',
                          imageSize: 20,
                          label: _t('Earnings'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const PharmacyEarningsScreen(),
                              ),
                            );
                          },
                        ),
                        // Bluetooth printer for order tickets (V7).
                        _MenuTile(
                          icon: Icons.print_outlined,
                          label: S.of(context).printer,
                          onTap: () => showPrinterPicker(context),
                        ),
                        _MenuTile(
                          image:
                              'lib/pharmacy/Assets/images/received_payouts.png',
                          imageSize: 22,
                          label: _t('Received Payouts'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const PharmacyReceivedPayoutsScreen(),
                              ),
                            );
                          },
                        ),
                        _MenuTile(
                          icon: Icons.sell_outlined,
                          label: _t('Coupons'),
                          onTap: _onCouponsTap,
                        ),
                        _MenuTile(
                          icon: Icons.delivery_dining_outlined,
                          label: _t('Delivery Boys'),
                          onTap: _onDeliveryBoysTap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SectionLabel(_t('Support & Legal')),
                    const SizedBox(height: 10),
                    _MenuCard(
                      divided: true,
                      children: [
                        _MenuTile(
                          icon: Icons.playlist_add_outlined,
                          label: S.of(context).categoryRequests,
                          onTap: () => CategoryRequestsScreen.open(CategoryRequestKind.pharmacy),
                        ),
                        _MenuTile(
                          icon: Icons.rule_outlined,
                          label: S.of(context).orderRules,
                          onTap: OrderRulesScreen.open,
                        ),
                        _MenuTile(
                          icon: Icons.support_agent_outlined,
                          label: S.of(context).supportMessages,
                          onTap: () => Get.to(() => const SupportMessages()),
                        ),
                        _MenuTile(
                          icon: Icons.headset_mic_outlined,
                          label: _t('Help & Support'),
                          onTap: _onHelpAndSupportTap,
                        ),
                        _MenuTile(
                          icon: Icons.description_outlined,
                          label: _t('Terms & Conditions'),
                          onTap: _onTermsAndConditionsTap,
                        ),
                        _MenuTile(
                          image:
                              'lib/pharmacy/Assets/images/privacy_policy.png',
                          imageSize: 20,
                          label: _t('Privacy Policy'),
                          onTap: _onPrivacyPolicyTap,
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
                            Image.asset(
                              "lib/assets/images/Logout.png",
                              height: 22,
                              width: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _t('Logout'),
                              style: appFont('Inter', 
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
                      style: appFont('Inter', 
                        color: const Color(0xFF858585),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _t('Check for update'),
                      textAlign: TextAlign.center,
                      style: appFont('Inter', 
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
              _t('Account'),
              style: appFont('Inter', 
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.2,
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
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    color: PharmacyAccountScreen.orange,
                    size: 26,
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: InkWell(
                onTap: onMenu,
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    Icons.more_vert,
                    color: Color(0xFF1A1A1A),
                    size: 22,
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    this.name = '',
    this.id = '',
    this.rating = '',
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
              if (rating.isNotEmpty) ...[
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF59E0B),
                  size: 16,
                ),
                const SizedBox(width: 2),
                Text(
                  rating,
                  style: appFont('Inter', 
                    color: PharmacyAccountScreen.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: isOpen
                            ? const Color.fromARGB(255, 23, 155, 71)
                            : const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOpen ? _t('Open') : _t('Closed'),
                      style: appFont('Inter', 
                        color: isOpen
                            ? const Color.fromARGB(255, 23, 155, 71)
                            : const Color(0xFFDC2626),
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
            style: appFont('Inter', 
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
              color: isVerified
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: isVerified
                      ? const Color.fromARGB(255, 23, 155, 71)
                      : const Color(0xFF9CA3AF),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isVerified ? _t('Verified') : _t('Unverified'),
                  style: appFont('Inter', 
                    color: isVerified
                        ? const Color.fromARGB(255, 23, 155, 71)
                        : const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (id.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              id.startsWith('ID:') ? id : 'ID: $id',
              style: appFont('Inter', 
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
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
      style: appFont('Inter', 
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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
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
                              style: appFont('Inter', 
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF3F3F4D),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
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
        rows.add(
          const Divider(height: 1, thickness: .2, color: Color(0xFFF1F1F1)),
        );
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
              style: appFont('Inter', 
                color: labelColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ),
          trailing ??
              (showChevron
                  ? Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: const Color(0xFFC8C8C8),
                      size: 22,
                    )
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

class _DeleteLidIconState extends State<_DeleteLidIcon>
    with SingleTickerProviderStateMixin {
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
    for (final left in [
      body.left + body.width * 0.28,
      body.left + body.width * 0.58,
    ]) {
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
    canvas.drawRRect(
      RRect.fromRectAndRadius(lid, const Radius.circular(1.2)),
      paint,
    );
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

class _DeleteAccountConfirmDialog extends StatelessWidget {
  const _DeleteAccountConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: LocalizationService().getTextDirection(),
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 10,
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(false),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE7E7E7)),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF7F7F7F),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _t('Are you sure you want to delete your\naccount?'),
                textAlign: TextAlign.center,
                style: appFont('Inter', 
                  color: const Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF5317),
                          side: const BorderSide(
                            color: Color(0xFFFF7F52),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _t('No'),
                          style: appFont('Inter', 
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3939),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _t('Yes'),
                          style: appFont('Inter', 
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: LocalizationService().getTextDirection(),
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 10,
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(false),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE7E7E7)),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF7F7F7F),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _t('Are you sure you want to log out?'),
                textAlign: TextAlign.center,
                style: appFont('Inter', 
                  color: const Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF5317),
                          side: const BorderSide(
                            color: Color(0xFFFF7F52),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _t('No'),
                          style: appFont('Inter', 
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5317),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _t('Yes'),
                          style: appFont('Inter', 
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
