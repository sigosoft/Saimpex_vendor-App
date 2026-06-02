import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/utils.dart';
// import 'package:saimpex_vendor/view/settings/about_us.dart';
import 'package:saimpex_vendor/view/settings/help_and_support.dart';
import 'package:saimpex_vendor/view/settings/privacy_policy.dart';
import 'package:saimpex_vendor/view/settings/terms_and_conditions.dart';
import 'package:saimpex_vendor/view/settings/app_settings.dart';
import 'package:saimpex_vendor/view/settings/coupons_screen.dart';
import 'package:saimpex_vendor/view/settings/delivery_boys.dart';
import 'package:saimpex_vendor/view/settings/earnings.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/controller/home_controller.dart';
import '../../generated/l10n.dart';
import 'package:saimpex_vendor/view/restaurant/restaurant_management_screen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FlutterLocalization localization = FlutterLocalization.instance;
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    dynamic lang = await getSavedObject("selected_locale");
    setState(() {
      if (lang == "ar") {
        selectedLanguage = "Arabic";
      } else if (lang == "fr") {
        selectedLanguage = "French";
      } else {
        selectedLanguage = "English";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: LocalizationService().getTextDirection(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GetBuilder<ProfileController>(
          init: ProfileController(),
          didChangeDependencies: (state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              state.controller?.getProfile(context);
            });
          },
          builder: (controller) => Stack(
            children: [
              // Custom Top Background (Circular Curve)
              Positioned.directional(
                textDirection: LocalizationService().getTextDirection(),
                top: -400,
                start: -context.width * 0.2,
                end: -context.width * 0.2,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2E2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Main Content
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                    ), // Spacing for the curve
                    // Profile R1 Icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EEFF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: controller.profilePicture.isNotEmpty
                              ? (controller.profilePicture.startsWith('http') ||
                                        controller.profilePicture.startsWith(
                                          'user/',
                                        ))
                                    ? Image.network(
                                        controller.profilePicture.startsWith(
                                              'http',
                                            )
                                            ? controller.profilePicture
                                            : ApiConfigs.IMAGE_URL +
                                                  controller.profilePicture,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _initials(
                                          controller.profileData?.name,
                                        ),
                                      )
                                    : controller.profilePicture.contains('/')
                                    ? Image.file(
                                        File(controller.profilePicture),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _initials(
                                          controller.profileData?.name,
                                        ),
                                      )
                                    : _initials(controller.profileData?.name)
                              : _initials(controller.profileData?.name),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Restaurant Name
                    Text(
                      controller.profileData?.name ?? "",
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333E63),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Details Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              context,
                              S.of(context).name,
                              controller.profileData?.name ?? "",
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              context,
                              S.of(context).owner,
                              controller.profileData?.owner ?? "",
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              context,
                              S.of(context).idNumber,
                              controller.profileData?.id?.toString() ?? "",
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              context,
                              S.of(context).contact,
                              (controller.profileData?.countryCode != null ||
                                      controller.profileData?.mobile != null)
                                  ? "${controller.profileData?.countryCode ?? '+222'} ${controller.profileData?.mobile ?? ''}"
                                  : "",
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              context,
                              S.of(context).email,
                              controller.profileData?.email ?? "",
                            ),
                            const SizedBox(height: 10),
                            _buildStatusRow(
                              context,
                              S.of(context).status,
                              controller.profileData?.status ?? "",
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              context,
                              S.of(context).address,
                              _formatLongText(controller.profileData?.address),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Language Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          S.of(context).language,
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333E63),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Language Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFE0D8,
                          ), // Changed from Color(0xFFFFE0D8) if needed, but keeping it for now
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLanguageButton("English", 'en'),
                            _buildLanguageButton("French", 'fr'),
                            _buildLanguageButton("Arabic", 'ar'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Settings Options Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              context,
                                S.of(context).restaurantManagement,
                              null,
                              () {
                                Get.to(() => const RestaurantManagementScreen());
                              },
                              leadingIcon: Icons.storefront_outlined,
                            ),
                            _buildMenuItem(
                              context,
                              S.of(context).deliveryBoys,
                              const AssetImage(
                                "lib/assets/images/DeliveryBoys.png",
                              ),
                              () {
                                Get.to(() => const DeliveryBoysScreen());
                              },
                            ),
                            _buildMenuItem(
                              context,
                              S.of(context).earnings,
                              const AssetImage(
                                "lib/assets/images/earnings.png",
                              ),
                              () {
                                Get.to(() => const EarningsScreen());
                              },
                            ),
                            _buildMenuItem(
                              context,
                              S.of(context).coupons,
                              const AssetImage("lib/assets/images/Coupons.png"),
                              () {
                                Get.to(() => const CouponsScreen());
                              },
                            ),
                            _buildMenuItem(
                              context,
                              S.of(context).settings,
                              const AssetImage(
                                "lib/assets/images/SettingsVendor.png",
                              ),
                              () {
                                Get.to(() => const AppSettings());
                              },
                            ),
                            // const Divider(height: 1),
                            _buildMenuItem(
                              context,
                              S.of(context).helpSupport,
                              AssetImage("lib/assets/images/Help&Support.png"),
                              () {
                                Get.to(() => HelpAndSupport());
                              },
                            ),
                            // const Divider(height: 1),
                            _buildMenuItem(
                              context,
                              S.of(context).termsConditions,
                              AssetImage(
                                "lib/assets/images/Terms&Conditions.png",
                              ),
                              () {
                                Get.to(() => const TermsandConditions());
                              },
                            ),
                            // const Divider(height: 1),
                            _buildMenuItem(
                              context,
                              S.of(context).privacyPolicy,
                              AssetImage(
                                "lib/assets/images/Privacy policy.png",
                              ),
                              () {
                                Get.to(() => const PrivacyPolicy());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Logout
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: InkWell(
                        onTap: () =>
                            _showLogoutBottomSheet(context, controller),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 33,
                          child: Row(
                            children: [
                              Image.asset(
                                "lib/assets/images/Logout.png",
                                height: 24,
                                width: 24,
                              ),
                              const SizedBox(width: 15),
                              Text(
                                S.of(context).logout,
                                style: GoogleFonts.rubik(
                                  color: colorPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Version
                    Text(
                      "${S.of(context).version} ${controller.version}",
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openStore(context),
                      child: Text(
                        S.of(context).checkForUpdate,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              // Back Button (Floating on top)
              Positioned(
                top: 50,
                left: 20,
                child: InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Get.back();
                    } else {
                      Get.find<HomeController>().onTabTapped(0, context);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(BuildContext context) async {
    final Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse(
        "https://play.google.com/store/apps/details?id=${ApiConfigs.androidPackageName}",
      );
    } else if (Platform.isIOS) {
      url = Uri.parse(
        "https://apps.apple.com/app/id${ApiConfigs.iosAppStoreId}",
      );
    } else {
      return;
    }
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context, e.toString());
      }
    }
  }

  void _showLogoutBottomSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    showConfirmationBottomSheet(
      context: context,
      title: S.of(context).logout,
      message: S.of(context).areYouSureYouWantToLogout,
      leftButtonText: S.of(context).no,
      rightButtonText: S.of(context).logout,
      onConfirm: () => controller.logout(context),
    );
  }

  String _formatLongText(String? text) {
    if (text == null || text.length <= 20) return text ?? "";
    return "${text.substring(0, 20)}\n${text.substring(20)}";
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    int maxLines = 1,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 13,
            color: const Color(0xFF8E99AF),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rubik(
              fontSize: 13,
              color: const Color(0xFF333E63),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 13,
            color: const Color(0xFF8E99AF),
            fontWeight: FontWeight.w400,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: lightgreen,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: GoogleFonts.rubik(
              fontSize: 11,
              color: greenlight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton(String title, String langCode) {
    bool isSelected = selectedLanguage == title;
    return InkWell(
      onTap: () async {
        await LocalizationService().updateLocale(langCode);
        setState(() => selectedLanguage = title);
      },
      child: Container(
        width: 99,
        height: 37,
        decoration: BoxDecoration(
          color: isSelected ? colorPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    ImageProvider? image,
    VoidCallback onTap, {
    IconData? leadingIcon,
  }) {
    return ListTile(
      leading: leadingIcon != null
          ? Icon(leadingIcon, color: Colors.grey, size: 24)
          : ImageIcon(image, color: Colors.grey[900], size: 24),
      title: Text(
        title,
        style: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF333E63),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _initials(String? name) {
    return Center(
      child: Text(
        name != null && name.length >= 2
            ? name.substring(0, 2).toUpperCase()
            : (name?.isNotEmpty == true ? name![0].toUpperCase() : "R1"),
        style: TextStyle(
          color: colorPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
