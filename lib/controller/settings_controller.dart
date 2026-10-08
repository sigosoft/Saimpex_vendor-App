import 'package:flutter/foundation.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';

class SettingsController extends GetxController {
  final FlutterLocalization localization = FlutterLocalization.instance;
  String htmlData = "";
  String contactEmail = "";
  String contactMobile = "";
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getAboutUs() async {
    try {
      isLoading = true;
      update();

      final response = await DioClient().get(ApiEndPoints.getAbout);

      if (response.data['status'] == true) {
        final about = response.data['data']['about'];
        final languageCode = localization.currentLocale?.languageCode;

        if (languageCode == 'fr' && about['content_fr'] != null) {
          htmlData = about['content_fr'];
        } else if (languageCode == 'ar' && about['content_ar'] != null) {
          htmlData = about['content_ar'];
        } else {
          htmlData = about['content_en'] ?? "No content available";
        }
      } else {
        htmlData = "About content not found";
      }
    } catch (error) {
      debugPrint("about Error: $error");
      htmlData = "Failed to load about us";
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getPrivacy() async {
    try {
      isLoading = true;
      update();

      final response = await DioClient().get(ApiEndPoints.getPrivacyPolicy);

      if (response.data['status'] == true) {
        final privacy = response.data['data']['privacy_policy'];
        final languageCode = localization.currentLocale?.languageCode;

        if (languageCode == 'fr' && privacy['content_fr'] != null) {
          htmlData = privacy['content_fr'];
        } else if (languageCode == 'ar' && privacy['content_ar'] != null) {
          htmlData = privacy['content_ar'];
        } else {
          htmlData = privacy['content_en'] ?? "No content available";
        }
      } else {
        htmlData = "Privacy policy not found";
      }
    } catch (error) {
      debugPrint("privacy Error: $error");
      htmlData = "Failed to load privacy policy";
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getTerms({String? endpoint}) async {
    try {
      isLoading = true;
      update();

      final apiEndpoint = endpoint ?? ApiEndPoints.pharmacyTermsandConditions;
      final response = await DioClient().get(apiEndpoint);

      if (response.data['status'] == true) {
        final terms = response.data['data']['terms'];
        final languageCode = localization.currentLocale?.languageCode;

        if (languageCode == 'fr' && terms['content_fr'] != null) {
          htmlData = terms['content_fr'];
        } else if (languageCode == 'ar' && terms['content_ar'] != null) {
          htmlData = terms['content_ar'];
        } else {
          htmlData = terms['content_en'] ?? "No content available";
        }
      } else {
        htmlData = "Terms and conditions not found";
      }
    } catch (error) {
      debugPrint("terms Error: $error");
      htmlData = "Failed to load terms and conditions";
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getHelpAndSupport() async {
    try {
      isLoading = true;
      update();

      final response = await DioClient().get(ApiEndPoints.getContact);

      if (response.data['status'] == true) {
        final contact = response.data['data']['contact'];
        contactEmail = contact['email'] ?? "";
        contactMobile =
            "${contact['country_code'] ?? ""} ${contact['mobile'] ?? ""}"
                .trim();
      }
    } catch (error) {
      debugPrint("HelpAndSupport Error: $error");
    } finally {
      isLoading = false;
      update();
    }
  }
}
