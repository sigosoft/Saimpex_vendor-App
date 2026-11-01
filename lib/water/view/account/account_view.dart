import 'package:saimpex_vendor/water/core/water_api.dart';
import 'package:saimpex_vendor/view/settings/category_requests_screen.dart';
import 'package:saimpex_vendor/view/settings/order_rules_screen.dart';
import 'package:saimpex_vendor/view/support/support_messages.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/view/settings/widgets/printer_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
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
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/generated/l10n.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key, this.embedded = false});

  /// When true, used as a bottom-nav tab (no own bottom nav / back button).
  final bool embedded;

  static void open(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AccountView()));
  }

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  late final WaterAccountController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<WaterAccountController>()
        ? Get.find<WaterAccountController>()
        : Get.put(WaterAccountController());
    controller.fetchProfile();
  }

  Future<bool?> _showDeleteAccountConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
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
                    color: AppColors.primaryOrange,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).deleteAccount,
                  style: appFont('Inter', 
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).areYouSureYouWantToDeleteYourAccount,
                  textAlign: TextAlign.center,
                  style: appFont('Inter', 
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF454E5D),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            S.of(context).no,
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
                        height: 44,
                        child: FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3B30),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            S.of(context).yes,
                            style: appFont('Inter', 
                              fontWeight: FontWeight.w700,
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
        );
      },
    );
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _showDeleteAccountConfirmationDialog(context);
    if (confirmed != true) return;

    try {
      showLoadingDialog(context);
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      }

      debugPrint(
        "==================== GET DELETE ACCOUNT ====================",
      );
      debugPrint("Endpoint: ${ApiEndPoints.deleteAccount}");
      print("==================== GET DELETE ACCOUNT ====================");
      print("Endpoint: ${ApiEndPoints.deleteAccount}");

      final response = await DioClient().get(ApiEndPoints.deleteAccount);

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");

      if (mounted) {
        Get.back();
      }

      if (response.data != null &&
          (response.data['status'] == 'true' ||
              response.data['status'] == true ||
              response.data['status'] == 1 ||
              response.data['status'] == '1')) {
        final rawMsg = response.data['message'];
        String toastMessage = S.current.waterAccountDeletedSuccessfully;
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
        String errorMsg = S.current.waterFailedToDeleteAccount;
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
      print(
        "==================== GET DELETE ACCOUNT ERROR ====================",
      );
      print("Error: $e");
      if (mounted) {
        showToast(context, e.toString());
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x80000000),
      builder: (context) => const _LogoutConfirmDialog(),
    );

    if (confirmed != true) return;

    try {
      showLoadingDialog(context);
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
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
        String toastMessage = S.current.youAreLoggedOutSuccessfully;
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
        String errorMsg = S.current.waterLogoutFailed;
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
          height: widget.embedded ? MediaQuery.paddingOf(context).top + 8 : 8,
        ),
        _Header(
          showBack: !widget.embedded,
          onBack: () => Navigator.of(context).maybePop(),
          onDeleteAccount: _handleDeleteAccount,
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primaryOrange,
            onRefresh: () => controller.fetchProfile(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                _ProfileCard(controller: controller),
                const SizedBox(height: 18),
                _SectionLabel(S.of(context).language),
                const SizedBox(height: 10),
                _LanguageSelector(
                  selectedIndex: controller.languageIndex,
                  languages: WaterAccountController.languages,
                  onSelect: controller.selectLanguage,
                ),
                const SizedBox(height: 18),
                _SectionLabel(S.of(context).waterBusiness),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      edgeDivider: true,
                      icon: Icons.notifications_none_rounded,
                      iconSize: 26,
                      title: S.of(context).notification,
                      trailing: Switch(
                        value: controller.notificationsEnabled,
                        thumbColor: const WidgetStatePropertyAll(Colors.white),
                        trackColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primaryOrange;
                          }
                          return const Color(0xFFE2E5E9);
                        }),
                        trackOutlineColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.transparent;
                          }
                          return const Color(0xFFC5CAD1);
                        }),
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          controller.setNotifications(value);
                        },
                      ),
                    ),
                    _SettingsTile(
                      edgeDivider: true,
                      icon: Icons.apartment_rounded,
                      title: S.of(context).waterStoreProfile,
                      onTap: () => StoreProfileView.open(context),
                    ),
                    _SettingsTile(
                      edgeDivider: true,
                      icon: Icons.access_time_rounded,
                      title: S.of(context).workingHours,
                      onTap: () => WorkingHoursView.open(context),
                    ),
                    _SettingsTile(
                      edgeDivider: true,
                      imageAsset:
                          'lib/water/Assets/Images/business_settings.png',
                      imageSize: 20,
                      title: S.of(context).waterBusinessSettings,
                      onTap: () => BusinessSettingsView.open(context),
                    ),
                    _SettingsTile(
                      edgeDivider: true,
                      icon: Icons.event_busy_outlined,
                      title: S.of(context).waterLeaveManagement,
                      onTap: () => LeaveManagementView.open(context),
                    ),
                    _SettingsTile(
                      edgeDivider: true,
                      imageAsset: 'lib/water/Assets/Images/currency.png',
                      imageSize: 20,
                      title: S.of(context).earnings,
                      onTap: () => EarningsView.open(context),
                    ),
                    // Bluetooth printer for order tickets (V7).
                    _SettingsTile(
                      edgeDivider: true,
                      icon: Icons.print_outlined,
                      title: S.of(context).printer,
                      onTap: () => showPrinterPicker(context),
                    ),
                    _SettingsTile(
                      edgeDivider: true,
                      imageAsset:
                          'lib/water/Assets/Images/received_payouts.png',
                      imageSize: 22,
                      title: S.of(context).receivedPayouts,
                      onTap: () => ReceivedPayoutsView.open(context),
                    ),
                    _SettingsTile(
                      edgeDivider: true,
                      icon: Icons.local_offer_outlined,
                      title: S.of(context).coupons,
                      onTap: () => CouponsView.open(context),
                    ),
                    _SettingsTile(
                      icon: Icons.delivery_dining_outlined,
                      title: S.of(context).deliveryBoys,
                      onTap: () => DeliveryBoysView.open(context),
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionLabel(S.of(context).waterSupportLegal),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    // Water only: the API has no gas category requests.
                    if (!WaterApi.isGas)
                      _SettingsTile(
                        edgeDivider: true,
                        icon: Icons.playlist_add_outlined,
                        title: S.of(context).categoryRequests,
                        onTap: () => CategoryRequestsScreen.open(CategoryRequestKind.water),
                      ),
                    _SettingsTile(
                      edgeDivider: true,
                      icon: Icons.rule_outlined,
                      title: S.of(context).orderRules,
                      onTap: OrderRulesScreen.open,
                    ),
                    _SettingsTile(
                      edgeDivider: true,
                      icon: Icons.support_agent_outlined,
                      title: S.of(context).supportMessages,
                      onTap: () => Get.to(() => const SupportMessages()),
                    ),
                    _SettingsTile(
                      edgeDivider: true,
                      icon: Icons.help_outline_rounded,
                      title: S.of(context).helpSupport,
                      onTap: () => HelpSupportView.open(context),
                    ),
                    _SettingsTile(
                      edgeDivider: true,
                      icon: Icons.description_outlined,
                      title: S.of(context).termsConditions,
                      onTap: () => TermsConditionsView.open(context),
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: S.of(context).privacyPolicy,
                      onTap: () => PrivacySecurityView.open(context),
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _LogoutButton(onTap: _handleLogout),
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
                Text(
                  S.of(context).checkForUpdate,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
  const _Header({
    required this.onBack,
    this.showBack = true,
    this.onDeleteAccount,
  });

  final VoidCallback onBack;
  final bool showBack;
  final VoidCallback? onDeleteAccount;

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
              S.of(context).account,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            if (showBack)
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
              alignment: AlignmentDirectional.centerEnd,
              child: PopupMenuButton<String>(
                tooltip: S.of(context).waterMore,
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
                    onDeleteAccount?.call();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    height: 48,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.primaryOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            S.of(context).deleteAccount,
                            style: const TextStyle(
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
  const _ProfileCard({required this.controller});

  final WaterAccountController controller;

  @override
  Widget build(BuildContext context) {
    final image = controller.profileImage;
    final name = controller.storeName;
    final rating = controller.rating;
    final status = controller.storeStatusText;
    final isOpen = controller.isStoreOpen;

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
            child: image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, _, _) => _errorPlaceholder(),
                    ),
                  )
                : _errorPlaceholder(),
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
          if (rating.isNotEmpty || status.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (rating.isNotEmpty) ...[
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.primaryOrange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ],
                if (rating.isNotEmpty && status.isNotEmpty)
                  const SizedBox(width: 10),
                if (status.isNotEmpty) ...[
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: isOpen
                        ? AppColors.inventoryAvailable
                        : AppColors.primaryOrange,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    status == 'Open'
                        ? S.of(context).waterOpen
                        : status == 'Closed'
                            ? S.of(context).waterClosed
                            : status,
                    style: TextStyle(
                      color: isOpen
                          ? AppColors.inventoryAvailable
                          : AppColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segment = constraints.maxWidth / languages.length;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                start: selectedIndex * segment,
                top: 0,
                bottom: 0,
                width: segment,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(languages.length, (index) {
                  final selected = selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (index == selectedIndex) return;
                        HapticFeedback.selectionClick();
                        onSelect(index);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                          child: Text(languages[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
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
    this.icon,
    this.iconSize = 22,
    this.imageAsset,
    this.imageSize = 20,
    required this.title,
    this.trailing,
    this.showDivider = true,
    this.edgeDivider = false,
    this.onTap,
  });

  final IconData? icon;
  final double iconSize;
  final String? imageAsset;
  final double imageSize;
  final String title;
  final Widget? trailing;
  final bool showDivider;
  final bool edgeDivider;
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
                  child: imageAsset != null
                      ? Center(
                          child: Image.asset(
                            imageAsset!,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(
                          icon,
                          color: AppColors.primaryOrange,
                          size: iconSize,
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
          edgeDivider
              ? const Divider(
                  height: 1,
                  thickness: .2,
                  color: AppColors.divider,
                )
              : const Padding(
                  padding: EdgeInsetsDirectional.only(start: 64),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
              S.of(context).logout,
              style: const TextStyle(
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
                S.of(context).areYouSureYouWantToLogout,
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
                          foregroundColor: AppColors.primaryOrange,
                          side: const BorderSide(
                            color: Color(0xFFFF7F52),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          S.of(context).no,
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
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          S.of(context).yes,
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
