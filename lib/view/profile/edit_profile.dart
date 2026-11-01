import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/view/profile/widgets/editable_name_field.dart';
import 'package:saimpex_vendor/view/profile/widgets/editable_phone_field.dart';
// import 'package:saimpex_vendor/view/Profile/widgets/edit_profile_picture_widget.dart';
import 'package:saimpex_vendor/view/profile/widgets/otp_verfication_alert_dialog.dart';
// // import 'package:saimpex_vendor/view/profile/widgets/select_image_alert_dialog.dart';
import 'package:saimpex_vendor/view/profile/widgets/update_profile_button.dart';
import 'package:saimpex_vendor/view/login/widgets/country_code_mobile_number.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/utils/widgets/custom_app_bar.dart';

import '../../generated/l10n.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Directionality(
      textDirection: localization.currentLocale!.languageCode.toString() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: CommonBackground(
        appBar: CustomAppBar(
          title: S.of(context).editProfile,
          onTap: () => Get.back(),
        ),
        child: GetBuilder<ProfileController>(
          init: ProfileController(),
          didChangeDependencies: (state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              state.controller?.getProfile(context);
            });
          },
          builder: (controller) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(height: media.size.height * 0.04),
                    /*
                    EditProfilePictureWidget(
                      profilePicture: controller.profilePicture,
                      imageSource: controller.imageSource,
                      media: media,
                      initial: controller.nameController.text.isNotEmpty
                          ? controller.nameController.text.substring(0, 1)
                          : "",
                      onEditTap: () {
                        SelectImageAlertDialog.show(
                          context,
                          onGallery: () {
                            controller.onGalleryTapped();
                          },
                          onCamera: () {
                            controller.onCameraTapped();
                          },
                        );
                      },
                    ),
*/
                    SizedBox(height: media.size.height * 0.06),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditableNameField(
                          media: media,
                          controller: controller.nameController,
                          onEditChanged: (value) {
                            setState(() {
                              controller.isNameEditable = value;
                              controller.update();
                            });
                          },
                        ),
                        SizedBox(height: media.size.height * 0.03),
                        controller.isPhoneEditable
                            ? CountryCodeMobileNumber(
                                selectedCountry: controller.selectedCountry,
                                phoneController: controller.phoneController,
                                onCountryChanged: (country) {
                                  controller.selectedCountry = country;
                                  controller.update();
                                },
                              )
                            : EditablePhoneField(
                                isEditable: controller.isPhoneEditable,
                                media: media,
                                controller: controller.phoneController,
                                countryCode: controller.countryCode.isNotEmpty
                                    ? controller.countryCode
                                    : '+222',
                                onEditChanged: (value) {
                                  setState(() {
                                    controller.isPhoneEditable = value;
                                    controller.update();
                                  });
                                },
                              ),
                        SizedBox(height: media.size.height * 0.06),
                        UpdateProfileButton(
                          media: media,
                          onPressed: () {
                            controller.isNameEditable = false;
                            controller.isPhoneEditable = false;
                            controller.isOtpSent = false;
                            final originalName =
                                controller.profileData?.name ?? '';
                            final originalPhone =
                                controller.profileData?.mobile ?? '';
                            final originalCountryCode =
                                controller.profileData?.countryCode ?? '+222';
                            final currentName = controller.nameController.text
                                .trim();
                            final currentPhone = controller.phoneController.text
                                .trim();
                            final currentCountryCode =
                                '+${controller.selectedCountry.phoneCode}';
                            final nameChanged = currentName != originalName;
                            final phoneChanged = currentPhone != originalPhone;
                            final countryCodeChanged =
                                currentCountryCode.trim() !=
                                originalCountryCode.trim();
                            final imageChanged = controller.imageSource != null;
                            if (phoneChanged || countryCodeChanged) {
                              controller
                                  .sendOtp(
                                    context,
                                    currentCountryCode,
                                    currentPhone,
                                  )
                                  .then((_) {
                                    if (controller.isOtpSent) {
                                      OtpVerficationAlertDialog.show(
                                        context,
                                        otpController: controller.otpController,
                                        phoneNumber: currentPhone,
                                        onPressed: () {
                                          controller.verifyOtp(
                                            context,
                                            currentCountryCode,
                                            currentPhone,
                                            controller.otpController.text,
                                          );
                                        },
                                      );
                                    }
                                  });
                            } else if ((nameChanged || imageChanged) &&
                                !phoneChanged &&
                                !countryCodeChanged) {
                              controller.postEditProfile(
                                context,
                                currentName,
                                currentCountryCode,
                                currentPhone,
                              );
                            }
                          },
                        ),
                        SizedBox(height: media.size.height * 0.04),
                      ],
                    ),
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
