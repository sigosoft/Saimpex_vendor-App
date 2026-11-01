import 'package:saimpex_vendor/view/settings/order_rules_screen.dart';
import 'package:saimpex_vendor/view/support/support_messages.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/services_api.dart';
import 'package:saimpex_vendor/home_cleaning/view/home_cleaning_home.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/view/login/login.dart';
import 'package:saimpex_vendor/view/settings/help_and_support.dart';
import 'package:saimpex_vendor/view/settings/privacy_policy.dart';
import 'package:saimpex_vendor/view/settings/terms_and_conditions.dart';
import 'package:saimpex_vendor/water/view/account/business_settings_view.dart';
import 'package:saimpex_vendor/water/view/account/coupons_view.dart';
import 'package:saimpex_vendor/water/view/account/earnings_view.dart';
import 'package:saimpex_vendor/water/view/account/received_payouts_view.dart';
import 'package:saimpex_vendor/water/view/account/store_profile_view.dart';
import 'package:saimpex_vendor/water/view/account/working_hours_view.dart';

class HomeCleaningAccountView extends StatefulWidget {
  const HomeCleaningAccountView({super.key, required this.controller});

  final HomeCleaningController controller;

  static const _orange = Color(0xFFFF5216);
  static const _ink = Color(0xFF1A1A1A);

  @override
  State<HomeCleaningAccountView> createState() =>
      _HomeCleaningAccountViewState();
}

class _HomeCleaningAccountViewState extends State<HomeCleaningAccountView> {
  int _selectedLanguage = 0;

  Map<String, dynamic>? _rawVendorData;
  bool? _storeOpen;
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _initLanguage();
    _loadProfile();
    _loadStoreStatus();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = info.version);
    } catch (_) {}
  }

  /// Today's open/closed state from GET serviceHours.
  Future<void> _loadStoreStatus() async {
    try {
      final hours = await CleaningServicesApi.fetchHours();
      final open = hours['store_open'];
      if (!mounted || open == null) return;
      setState(() => _storeOpen = open == true || open.toString() == '1');
    } on CleaningApiException catch (_) {}
  }

  void _initLanguage() {
    final code = LocalizationService.currentLanguageCode;
    if (code == 'fr') {
      _selectedLanguage = 1;
    } else if (code == 'ar') {
      _selectedLanguage = 2;
    } else {
      _selectedLanguage = 0;
    }
  }

  Future<void> _loadProfile() async {
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != 'null') {
        DioClient().updateToken(token);
      } else {
        return;
      }

      // GET profile requires vendor_type (home cleaning = 9).
      final saved = (await getSavedObject('vendorType'))?.toString() ?? '';
      final vendorType = saved.isNotEmpty && saved != 'null' && saved != '0'
          ? saved
          : '9';
      final response = await DioClient().get(
        ApiEndPoints.profile,
        query: {'vendor_type': vendorType},
      );
      if (mounted) {
        Map<String, dynamic>? dataMap;
        if (response.data is Map<String, dynamic>) {
          dataMap = response.data as Map<String, dynamic>;
        } else if (response.data is String) {
          try {
            dataMap =
                jsonDecode(response.data as String) as Map<String, dynamic>?;
          } catch (_) {}
        }

        if (dataMap != null && CleaningServicesApi.isOk(dataMap)) {
          final rawData = (dataMap['data'] is Map<String, dynamic>)
              ? ((dataMap['data']['vendor'] as Map<String, dynamic>?) ??
                    dataMap['data'] as Map<String, dynamic>?)
              : null;

          setState(() {
            _rawVendorData = rawData;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _onLanguageSelected(int index) async {
    HapticFeedback.selectionClick();
    setState(() => _selectedLanguage = index);
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
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          S.of(context).logout,
          style: appFont('Inter', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          S.of(context).areYouSureYouWantToLogout,
          style: appFont('Inter', 
            fontSize: 13.5,
            color: const Color(0xFF424242),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              S.of(context).cancel,
              style: appFont('Inter', 
                color: const Color(0xFF757575),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeCleaningAccountView._orange,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              S.of(context).logout,
              style: appFont('Inter', 
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DioClient().post(ApiEndPoints.logout);
      } catch (_) {}
      await savename('token', '');
      Get.offAll(() => const LoginScreen());
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 6,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: HomeCleaningAccountView._orange,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).deleteAccount,
                  style: appFont('Inter', 
                    color: HomeCleaningAccountView._ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).cleaningDeleteAccountConfirm,
                  textAlign: TextAlign.center,
                  style: appFont('Inter', 
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            S.of(context).cancel,
                            style: appFont('Inter', 
                              color: const Color(0xFF424242),
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: HomeCleaningAccountView._orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            S.of(context).delete,
                            style: appFont('Inter', 
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
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
        );
      },
    );

    if (confirmed == true) {
      try {
        await DioClient().get(ApiEndPoints.deleteAccount);
      } catch (_) {}
      await savename('token', '');
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 220,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFE8DC),
                      Color(0xFFFFF4ED),
                      Color(0xFFFFFFFF),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 18),
                        _buildLanguageSection(),
                        const SizedBox(height: 18),
                        _buildBusinessSection(),
                        const SizedBox(height: 18),
                        _buildSupportLegalSection(),
                        const SizedBox(height: 22),
                        _buildLogoutButton(),
                        const SizedBox(height: 12),
                        _buildVersionFooter(),
                      ],
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              S.of(context).account,
              style: appFont('Inter', 
                color: HomeCleaningAccountView._ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.controller.setNavIndex(0);
                },
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
                    color: HomeCleaningAccountView._orange,
                    size: 26,
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Theme(
                data: Theme.of(context).copyWith(cardColor: Colors.white),
                child: PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'delete') {
                      _showDeleteAccountDialog();
                    }
                  },
                  offset: const Offset(0, 42),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: HomeCleaningAccountView._ink,
                    size: 24,
                  ),
                  itemBuilder: (ctx) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            color: HomeCleaningAccountView._orange,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            S.of(context).deleteAccount,
                            style: appFont('Inter', 
                              color: HomeCleaningAccountView._orange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: HomeCleaningAccountView._orange,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _text(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty || text == 'null' ? null : text;
  }

  Widget _buildProfileCard() {
    final vendor = _rawVendorData;
    final lang = LocalizationService.currentLanguageCode;
    final String storeName =
        (lang == 'fr' ? _text(vendor?['name_fr']) : null) ??
        (lang == 'ar' ? _text(vendor?['name_ar']) : null) ??
        _text(vendor?['name']) ??
        '';
    final image = _text(vendor?['image']);
    final imageUrl = image == null
        ? null
        : (image.startsWith('http') ? image : '${ApiConfigs.IMAGE_URL}$image');
    final totalReviews = int.tryParse('${vendor?['total_reviews'] ?? 0}') ?? 0;
    final rating = double.tryParse('${vendor?['rating'] ?? ''}');
    final isActive = vendor?['status']?.toString() == '1';
    const imagePlaceholder = Icon(
      Icons.storefront_outlined,
      color: HomeCleaningAccountView._orange,
      size: 30,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl == null
                    ? imagePlaceholder
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => imagePlaceholder,
                      ),
              ),
              if (isActive)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            storeName,
            style: appFont('Inter', 
              color: HomeCleaningAccountView._ink,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rating != null && totalReviews > 0) ...[
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFFF9800),
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: appFont('Inter', 
                    color: const Color(0xFFFF9800),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (_storeOpen != null) ...[
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _storeOpen!
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF9E9E9E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _storeOpen!
                      ? S.of(context).cleaningOpenStatus
                      : S.of(context).cleaningClosedStatus,
                  style: appFont('Inter', 
                    color: _storeOpen!
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).language,
          style: appFont('Inter', 
            color: HomeCleaningAccountView._orange,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFECE5),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              _buildLangTab(S.of(context).cleaningLanguageEnglish, 0),
              _buildLangTab(S.of(context).cleaningLanguageFrench, 1),
              _buildLangTab(S.of(context).cleaningLanguageArabic, 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLangTab(String title, int index) {
    final isSelected = _selectedLanguage == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onLanguageSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? HomeCleaningAccountView._orange
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: appFont('Inter', 
              color: isSelected ? Colors.white : const Color(0xFF424242),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).cleaningBusinessSection,
          style: appFont('Inter', 
            color: HomeCleaningAccountView._orange,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildGroupedCard(
          children: [
            // The notification on/off switch was local only: the backend
            // has no notification preference endpoint, so it is hidden.
            _buildSettingRow(
              icon: Icons.storefront_outlined,
              title: S.of(context).cleaningVendorProfile,
              onTap: () => StoreProfileView.open(context),
            ),
            _buildSettingRow(
              icon: Icons.access_time_rounded,
              title: S.of(context).cleaningWorkingHoursBookingSlots,
              onTap: () => WorkingHoursView.open(context),
            ),
            _buildSettingRow(
              icon: Icons.store_mall_directory_outlined,
              title: S.of(context).cleaningBusinessSettings,
              onTap: () => BusinessSettingsView.open(context),
            ),
            _buildSettingRow(
              icon: Icons.payments_outlined,
              title: S.of(context).earnings,
              onTap: () => EarningsView.open(context),
            ),
            _buildSettingRow(
              icon: Icons.account_balance_wallet_outlined,
              title: S.of(context).receivedPayouts,
              onTap: () => ReceivedPayoutsView.open(context),
            ),
            _buildSettingRow(
              icon: Icons.local_offer_outlined,
              title: S.of(context).coupons,
              showDivider: false,
              onTap: () => CouponsView.open(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).cleaningSupportLegal,
          style: appFont('Inter', 
            color: HomeCleaningAccountView._orange,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildGroupedCard(
          children: [
            _buildSettingRow(
              icon: Icons.rule_outlined,
              title: S.of(context).orderRules,
              onTap: OrderRulesScreen.open,
            ),
            _buildSettingRow(
              icon: Icons.support_agent_outlined,
              title: S.of(context).supportMessages,
              onTap: () => Get.to(() => const SupportMessages()),
            ),
            _buildSettingRow(
              icon: Icons.help_outline_rounded,
              title: S.of(context).helpSupport,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HelpAndSupport(),
                  ),
                );
              },
            ),
            _buildSettingRow(
              icon: Icons.description_outlined,
              title: S.of(context).termsConditions,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TermsandConditions(),
                  ),
                );
              },
            ),
            _buildSettingRow(
              icon: Icons.shield_outlined,
              title: S.of(context).privacyPolicy,
              showDivider: false,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicy(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupedCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEFE9),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 18,
                    color: HomeCleaningAccountView._orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: appFont('Inter', 
                      color: HomeCleaningAccountView._ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Color(0xFF9E9E9E),
                    ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              thickness: 0.7,
              indent: 14,
              endIndent: 14,
              color: Color(0xFFF3F3F3),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: InkWell(
        onTap: _handleLogout,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: HomeCleaningAccountView._orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context).logout,
                style: appFont('Inter', 
                  color: HomeCleaningAccountView._orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionFooter() {
    return Column(
      children: [
        if (_appVersion != null)
          Text(
            'V$_appVersion',
            style: appFont('Inter', 
              color: const Color(0xFF9E9E9E),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        const SizedBox(height: 3),
        Text(
          S.of(context).checkForUpdate,
          style: appFont('Inter', 
            color: const Color(0xFF757575),
            fontWeight: FontWeight.w400,
            fontSize: 11,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}
