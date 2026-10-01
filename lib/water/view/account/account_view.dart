import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/view/login/login.dart';
import 'package:saimpex_vendor/water/controller/account_controller.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/view/account/store_profile_view.dart';
import 'package:saimpex_vendor/water/view/account/business_settings_view.dart';
import 'package:saimpex_vendor/water/view/account/working_hours_view.dart';
import 'package:saimpex_vendor/water/view/account/leave_management_view.dart';
import 'package:saimpex_vendor/water/view/account/earnings_view.dart';
import 'package:saimpex_vendor/water/view/account/received_payouts_view.dart';
import 'package:saimpex_vendor/water/view/account/coupons_view.dart';
import 'package:saimpex_vendor/water/view/account/delivery_boys_view.dart';
import 'package:saimpex_vendor/water/view/account/help_support_view.dart';
import 'package:saimpex_vendor/water/view/account/terms_conditions_view.dart';
import 'package:saimpex_vendor/water/view/account/privacy_security_view.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key, this.embedded = false});

  /// When true, used as a bottom-nav tab (no own bottom nav / back button).
  final bool embedded;

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AccountView()),
    );
  }

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  late final WaterAccountController controller;

  @override
  void initState() {
    super.initState();
    controller = WaterAccountController();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WaterAccountController>(
      init: controller,
      global: false,
      builder: (_) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final body = Column(
      children: [
        SizedBox(
          height: widget.embedded
              ? MediaQuery.paddingOf(context).top + 8
              : 8,
        ),
        _Header(
          showBack: !widget.embedded,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              const _ProfileCard(),
              const SizedBox(height: 18),
              const _SectionLabel('Language'),
              const SizedBox(height: 10),
              _LanguageSelector(
                selectedIndex: controller.languageIndex,
                languages: WaterAccountController.languages,
                onSelect: controller.selectLanguage,
              ),
              const SizedBox(height: 18),
              const _SectionLabel('Business'),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification',
                    trailing: Switch(
                      value: controller.notificationsEnabled,
                      thumbColor: const WidgetStatePropertyAll(Colors.white),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primaryOrange;
                        }
                        return const Color(0xFFE2E5E9);
                      }),
                      trackOutlineColor: WidgetStateProperty.resolveWith(
                        (states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.transparent;
                          }
                          return const Color(0xFFC5CAD1);
                        },
                      ),
                      onChanged: controller.setNotifications,
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.apartment_rounded,
                    title: 'Store Profile',
                    onTap: () => StoreProfileView.open(context),
                  ),
                  _SettingsTile(
                    icon: Icons.access_time_rounded,
                    title: 'Working hours',
                    onTap: () => WorkingHoursView.open(context),
                  ),
                  _SettingsTile(
                    icon: Icons.storefront_outlined,
                    title: 'Business settings',
                    onTap: () => BusinessSettingsView.open(context),
                  ),
                  _SettingsTile(
                    icon: Icons.event_busy_outlined,
                    title: 'Leave Management',
                    onTap: () => LeaveManagementView.open(context),
                  ),
                  _SettingsTile(
                    icon: Icons.payments_outlined,
                    title: 'Earnings',
                    onTap: () => EarningsView.open(context),
                  ),
                  _SettingsTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Received Payouts',
                    onTap: () => ReceivedPayoutsView.open(context),
                  ),
                  _SettingsTile(
                    icon: Icons.local_offer_outlined,
                    title: 'Coupons',
                    onTap: () => CouponsView.open(context),
                  ),
                  _SettingsTile(
                    icon: Icons.delivery_dining_outlined,
                    title: 'Delivery Boys',
                    onTap: () => DeliveryBoysView.open(context),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _SectionLabel('Support & Legal'),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    onTap: () => HelpSupportView.open(context),
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () => TermsConditionsView.open(context),
                  ),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => PrivacySecurityView.open(context),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _LogoutButton(),
              const SizedBox(height: 14),
              const Text(
                'V2.8.1',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Check for update',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final decorated = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundTop,
            AppColors.backgroundMid,
            Colors.white,
          ],
          stops: [0, 0.18, 1],
        ),
      ),
      child: body,
    );

    if (widget.embedded) return decorated;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundMid,
        body: SafeArea(child: decorated),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, this.showBack = true});

  final VoidCallback onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'Account',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            if (showBack)
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.primaryOrange,
                      size: 28,
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                tooltip: 'More',
                offset: const Offset(0, 40),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 180),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.18),
                surfaceTintColor: Colors.white,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textDark,
                  size: 22,
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    // Placeholder for delete-account flow.
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    height: 48,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.primaryOrange,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Delete Account',
                            style: TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primaryOrange,
                          size: 20,
                        ),
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
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 118,
            height: 118,
            child: Image.asset(
              AppAssets.profileImage,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, _, _) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: const Icon(
                  Icons.local_pharmacy_outlined,
                  color: AppColors.primaryOrange,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'PureLife Water Co.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.primaryOrange,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                '4.8',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.circle,
                size: 6,
                color: AppColors.inventoryAvailable,
              ),
              SizedBox(width: 5),
              Text(
                'Open',
                style: TextStyle(
                  color: AppColors.inventoryAvailable,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ],
      ),
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
      style: const TextStyle(
        color: AppColors.primaryOrange,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selectedIndex,
    required this.languages,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<String> languages;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.orangeSoftBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          for (var i = 0; i < languages.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? AppColors.primaryOrange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: selectedIndex == i
                        ? [
                            BoxShadow(
                              color: AppColors.primaryOrange
                                  .withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    languages[i],
                    style: TextStyle(
                      color: selectedIndex == i
                          ? Colors.white
                          : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.showDivider = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: trailing is Switch ? null : (onTap ?? () {}),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.orangeSoftBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 64),
            child: Divider(height: 1, color: AppColors.divider),
          ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await savename('loginStatus', 'false');
        await savename('token', '');
        Get.offAll(() => const LoginScreen());
      },
      borderRadius: BorderRadius.circular(12),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.primaryOrange,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
