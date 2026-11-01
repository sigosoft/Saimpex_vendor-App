import 'package:saimpex_vendor/view/settings/order_rules_screen.dart';
import 'package:saimpex_vendor/view/support/support_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/route_manager.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/view/profile/widgets/language_selection_widget.dart';
import 'package:saimpex_vendor/view/profile/widgets/menu_item.dart';
import 'package:saimpex_vendor/view/profile/widgets/points_floating_widget.dart'
    show PointsFloatingWidget;
import 'package:saimpex_vendor/view/profile/widgets/social_button.dart';
import 'package:saimpex_vendor/view/shimmer_loading/shimmer_profile.dart';
import 'package:saimpex_vendor/view/login/widgets/bold_text-rubik.dart';
import 'package:saimpex_vendor/view/profile/widgets/logout_bottom_sheet.dart';
import 'package:saimpex_vendor/view/settings/settings.dart';
import 'package:saimpex_vendor/view/settings/about_us.dart';
import 'package:saimpex_vendor/view/settings/help_and_support.dart';
import 'package:saimpex_vendor/view/settings/privacy_policy.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/utils/widgets/custom_app_bar.dart';

import '../../controller/profile_controller.dart';
import '../settings/terms_and_conditions.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String selectedLanguage = 'English';
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Directionality(
      textDirection: LocalizationService().getTextDirection(),
      child: CommonBackground(
        appBar: CustomAppBar(
          title: S.of(context).profile,
          onTap: () => Get.back(),
        ),
        child: GetBuilder<ProfileController>(
          init: ProfileController(),
          didChangeDependencies: (state) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              dynamic lang = await getSavedObject("selected_locale");

              if (lang == "ar") {
                selectedLanguage = "Arabic";
              } else if (lang == "fr") {
                selectedLanguage = "French";
              } else {
                selectedLanguage = "English";
              }
              state.controller?.getProfile(context);
            });
          },
          builder: (controller) {
            if (controller.isProfileLoading || controller.profileData == null) {
              return const ShimmerProfile();
            }
            return SingleChildScrollView(
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    PointsFloatingWidget(points: controller.points),
                    // ProfilePicWidget(
                    //   media: media,
                    //   profileData: controller.profileData ?? ProfileData(),
                    // ),
                    SizedBox(height: media.size.height * 0.01),
                    BoldTextRubik(
                      text: controller.profileData?.name ?? '',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    SizedBox(height: media.size.height * 0.01),
                    BoldTextRubik(
                      text:
                          '${controller.profileData?.countryCode ?? ''} ${controller.profileData?.mobile ?? ''}',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: mutedTextColor,
                    ),
                    SizedBox(height: media.size.height * 0.04),
                    LanguageSelectionWidget(
                      selectedLanguage: selectedLanguage,
                      onLanguageChanged: (language) async {
                        await LocalizationService().updateLocale(language);
                        setState(() => selectedLanguage = language);
                      },
                    ),
                    SizedBox(height: media.size.height * 0.04),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              MenuItem(
                                media: media,
                                icon: "lib/assets/images/your_orders_icon.png",
                                title: S.of(context).yourOrders,
                                onTap: () {
                                  // Get.to(const MyOrders(route: 'profile'));
                                },
                              ),
                              SizedBox(height: media.size.height * 0.01),
                              controller.profileData?.hasBasketOrders == false
                                  ? Container()
                                  : MenuItem(
                                      media: media,
                                      icon:
                                          "lib/assets/images/your_orders_icon.png",
                                      title: S.of(context).basketOrderss,
                                      onTap: () {
                                        // Get.to(
                                        //   const BasketOrders(route: 'profile'),
                                        // );
                                      },
                                    ),
                              controller.profileData?.hasBasketOrders == false
                                  ? Container()
                                  : SizedBox(height: media.size.height * 0.01),
                              MenuItem(
                                media: media,
                                icon:
                                    "lib/assets/images/profile_mypoints_icon.png",
                                title: S.of(context).myPoints,
                                onTap: () {
                                  // Get.to(() => const RedeemableScreen());
                                },
                              ),
                              SizedBox(height: media.size.height * 0.01),
                              MenuItem(
                                media: media,
                                icon:
                                    "lib/assets/images/profile_settings_icon.png",
                                title: S.of(context).settings,
                                onTap: () {
                                  Get.to(() => const Settings());
                                },
                              ),
                              SizedBox(height: media.size.height * 0.01),
                              MenuItem(
                                media: media,
                                icon: "lib/assets/images/about_us_icon.png",
                                title: S.of(context).aboutUs,
                                onTap: () {
                                  Get.to(const AboutUs());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: media.size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              MenuItem(
                                media: media,
                                icon:
                                    "lib/assets/images/help_and_support_icon.png",
                                title: S.of(context).orderRules,
                                onTap: OrderRulesScreen.open,
                              ),
                              SizedBox(height: media.size.height * 0.01),
                              MenuItem(
                                media: media,
                                icon:
                                    "lib/assets/images/help_and_support_icon.png",
                                title: S.of(context).supportMessages,
                                onTap: () {
                                  Get.to(() => const SupportMessages());
                                },
                              ),
                              SizedBox(height: media.size.height * 0.01),
                              MenuItem(
                                media: media,
                                icon:
                                    "lib/assets/images/help_and_support_icon.png",
                                title: S.of(context).helpSupport,
                                onTap: () {
                                  Get.to(HelpAndSupport());
                                },
                              ),
                              SizedBox(height: media.size.height * 0.01),
                              MenuItem(
                                media: media,
                                icon:
                                    "lib/assets/images/terms_and_conditions_icon.png",
                                title: S.of(context).termsConditions,
                                onTap: () {
                                  Get.to(const TermsandConditions());
                                },
                              ),
                              SizedBox(height: media.size.height * 0.01),
                              MenuItem(
                                media: media,
                                icon:
                                    "lib/assets/images/privacy_policy_icon.png",
                                title: S.of(context).privacyPolicy,
                                onTap: () {
                                  Get.to(const PrivacyPolicy());
                                },
                              ),
                              SizedBox(height: media.size.height * 0.01),
                              MenuItem(
                                media: media,
                                icon: "lib/assets/images/logout_icon_red .png",
                                title: S.of(context).logout,
                                onTap: () {
                                  LogoutBottomSheet.show(
                                    context,
                                    onNo: () {},
                                    onLogout: () {
                                      controller.logout(context);
                                    },
                                  );
                                },

                                textColor: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: media.size.height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: media.size.width * 0.04),
                        SocialButton(
                          icon: "lib/assets/images/instagram_high.png",
                          color: Colors.white,
                          onTap: () {
                            debugPrint(
                              'instagramUrl: ${controller.profileData?.instagramUrl}',
                            );
                            launchUrl(
                              Uri.parse(
                                controller.profileData?.instagramUrl ?? '',
                              ),
                            );
                          },
                        ),
                        SizedBox(width: media.size.width * 0.04),
                        SocialButton(
                          icon: "lib/assets/images/facebook_high.png",
                          color: Colors.white,
                          onTap: () {
                            debugPrint(
                              'facebookUrl: ${controller.profileData?.facebookUrl}',
                            );
                            launchUrl(
                              Uri.parse(
                                controller.profileData?.facebookUrl ?? '',
                              ),
                            );
                          },
                        ),
                        SizedBox(width: media.size.width * 0.04),
                        SocialButton(
                          icon: "lib/assets/images/whatsapp_high.png",
                          color: Colors.white,
                          onTap: () {
                            debugPrint(
                              'whatsappUrl: ${controller.profileData?.whatsappUrl}',
                            );
                            launchUrl(
                              Uri.parse(
                                controller.profileData?.whatsappUrl ?? '',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: media.size.height * 0.02),
                    BoldTextRubik(
                      text: "${S.of(context).version} : ${controller.version}",
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: media.size.height * 0.02),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
