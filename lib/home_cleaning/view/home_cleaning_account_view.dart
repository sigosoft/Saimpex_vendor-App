import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/home_cleaning/view/home_cleaning_home.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
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
  const HomeCleaningAccountView({
    super.key,
    required this.controller,
  });

  final HomeCleaningController controller;

  static const _orange = Color(0xFFFF5722);
  static const _ink = Color(0xFF1A1A1A);

  @override
  State<HomeCleaningAccountView> createState() =>
      _HomeCleaningAccountViewState();
}

class _HomeCleaningAccountViewState extends State<HomeCleaningAccountView> {
  int _selectedLanguage = 0;
  bool _notifications = true;

  ProfileData? _profileData;
  Map<String, dynamic>? _rawVendorData;

  @override
  void initState() {
    super.initState();
    _initLanguage();
    _loadProfile();
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

      final response = await DioClient().get(ApiEndPoints.profile);
      if (mounted) {
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

          setState(() {
            _profileData = fetchedData;
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
          'Logout',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF424242)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF757575), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeCleaningAccountView._orange,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
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
                  'Delete Account',
                  style: GoogleFonts.inter(
                    color: HomeCleaningAccountView._ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete your account? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
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
                            'Cancel',
                            style: GoogleFonts.inter(
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
                            'Delete',
                            style: GoogleFonts.inter(
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
              'Account',
              style: GoogleFonts.inter(
                color: HomeCleaningAccountView._ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
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
              alignment: Alignment.centerRight,
              child: Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.white,
                ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                            'Delete Account',
                            style: GoogleFonts.inter(
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

  Widget _buildProfileCard() {
    final String storeName = _profileData?.name ??
        _rawVendorData?['store_name']?.toString() ??
        'CleanPro Elite';

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
                child: Image.asset(
                  'lib/home_cleaning/Assets/images/regularcleaning.png',
                  fit: BoxFit.cover,
                ),
              ),
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
            style: GoogleFonts.inter(
              color: HomeCleaningAccountView._ink,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: Color(0xFFFF9800),
              ),
              const SizedBox(width: 4),
              Text(
                '4.8',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF9800),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Open',
                style: GoogleFonts.inter(
                  color: const Color(0xFF22C55E),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
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
          'Language',
          style: GoogleFonts.inter(
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
              _buildLangTab('English', 0),
              _buildLangTab('French', 1),
              _buildLangTab('Arabic', 2),
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
            color: isSelected ? HomeCleaningAccountView._orange : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
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
          'Business',
          style: GoogleFonts.inter(
            color: HomeCleaningAccountView._orange,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildGroupedCard(
          children: [
            _buildSettingRow(
              icon: Icons.notifications_none_rounded,
              title: 'Notification',
              trailing: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _notifications,
                  activeThumbColor: Colors.white,
                  activeTrackColor: HomeCleaningAccountView._orange,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFE0E0E0),
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    setState(() => _notifications = val);
                  },
                ),
              ),
            ),
            _buildSettingRow(
              icon: Icons.storefront_outlined,
              title: 'Vendor Profile',
              onTap: () => StoreProfileView.open(context),
            ),
            _buildSettingRow(
              icon: Icons.access_time_rounded,
              title: 'Working hours & Booking Slots',
              onTap: () => WorkingHoursView.open(context),
            ),
            _buildSettingRow(
              icon: Icons.store_mall_directory_outlined,
              title: 'Business settings',
              onTap: () => BusinessSettingsView.open(context),
            ),
            _buildSettingRow(
              icon: Icons.payments_outlined,
              title: 'Earnings',
              onTap: () => EarningsView.open(context),
            ),
            _buildSettingRow(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Received Payouts',
              onTap: () => ReceivedPayoutsView.open(context),
            ),
            _buildSettingRow(
              icon: Icons.local_offer_outlined,
              title: 'Coupons',
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
          'Support & Legal',
          style: GoogleFonts.inter(
            color: HomeCleaningAccountView._orange,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildGroupedCard(
          children: [
            _buildSettingRow(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
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
              title: 'Terms & Conditions',
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
              title: 'Privacy Policy',
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
                    style: GoogleFonts.inter(
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
                'Logout',
                style: GoogleFonts.inter(
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
        Text(
          'V2.8.1',
          style: GoogleFonts.inter(
            color: const Color(0xFF9E9E9E),
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Check for update',
          style: GoogleFonts.inter(
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
