import 'package:flutter/foundation.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';

class SettingsController extends GetxController {
  final FlutterLocalization localization = FlutterLocalization.instance;

  String htmlData = "";
  String privacyPolicyHtml = "";
  String termsConditionsHtml = "";
  String aboutUsHtml = "";

  String contactEmail = "";
  String contactMobile = "";

  bool isLoading = false;
  bool isPrivacyLoading = false;
  bool isTermsLoading = false;
  bool isAboutLoading = false;
  bool isHelpLoading = false;

  Map<String, dynamic>? _rawPrivacy;
  Map<String, dynamic>? _rawTerms;
  Map<String, dynamic>? _rawAbout;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Preload common settings in the background to ensure instantaneous navigation and rendering
  void preloadSettings() {
    if (privacyPolicyHtml.isEmpty && !isPrivacyLoading) {
      getPrivacy();
    }
    if (termsConditionsHtml.isEmpty && !isTermsLoading) {
      getTerms();
    }
    if ((contactEmail.isEmpty && contactMobile.isEmpty) && !isHelpLoading) {
      getHelpAndSupport();
    }
  }

  String _getLocalizedContent(Map<dynamic, dynamic> data) {
    final languageCode = localization.currentLocale?.languageCode;
    if (languageCode == 'fr' && data['content_fr'] != null) {
      return data['content_fr'].toString();
    } else if (languageCode == 'ar' && data['content_ar'] != null) {
      return data['content_ar'].toString();
    } else {
      return (data['content_en'] ?? "No content available").toString();
    }
  }

  Future<void> getAboutUs({bool forceRefresh = false}) async {
    if (!forceRefresh && aboutUsHtml.isNotEmpty) {
      htmlData = aboutUsHtml;
      update();
      return;
    }
    try {
      isAboutLoading = true;
      if (aboutUsHtml.isEmpty) isLoading = true;
      update();

      final response = await DioClient().get(ApiEndPoints.getAbout);

      if (response.data is Map && response.data['status'] == true) {
        final about = response.data['data']?['about'];
        if (about is Map) {
          _rawAbout = Map<String, dynamic>.from(about);
          aboutUsHtml = _getLocalizedContent(about);
          htmlData = aboutUsHtml;
        } else {
          aboutUsHtml = "About content not found";
          htmlData = aboutUsHtml;
        }
      } else {
        aboutUsHtml = "About content not found";
        htmlData = aboutUsHtml;
      }
    } catch (error) {
      debugPrint("about Error: $error");
      if (aboutUsHtml.isEmpty) {
        aboutUsHtml = "Failed to load about us";
        htmlData = aboutUsHtml;
      }
    } finally {
      isAboutLoading = false;
      isLoading = false;
      update();
    }
  }

  Future<void> getPrivacy({bool forceRefresh = false}) async {
    if (!forceRefresh && privacyPolicyHtml.isNotEmpty) {
      htmlData = privacyPolicyHtml;
      update();
      return;
    }
    try {
      isPrivacyLoading = true;
      if (privacyPolicyHtml.isEmpty) isLoading = true;
      update();

      final response = await DioClient().get(ApiEndPoints.getPrivacyPolicy);

      if (response.data is Map && response.data['status'] == true) {
        final privacy = response.data['data']?['privacy_policy'];
        if (privacy is Map) {
          _rawPrivacy = Map<String, dynamic>.from(privacy);
          privacyPolicyHtml = _getLocalizedContent(privacy);
          htmlData = privacyPolicyHtml;
        } else {
          privacyPolicyHtml = "Privacy policy not found";
          htmlData = privacyPolicyHtml;
        }
      } else {
        privacyPolicyHtml = "Privacy policy not found";
        htmlData = privacyPolicyHtml;
      }
    } catch (error) {
      debugPrint("privacy Error: $error");
      if (privacyPolicyHtml.isEmpty) {
        privacyPolicyHtml = "Failed to load privacy policy";
        htmlData = privacyPolicyHtml;
      }
    } finally {
      isPrivacyLoading = false;
      isLoading = false;
      update();
    }
  }

  Future<void> getTerms({String? endpoint, bool forceRefresh = false}) async {
    if (!forceRefresh && termsConditionsHtml.isNotEmpty) {
      htmlData = termsConditionsHtml;
      update();
      return;
    }
    try {
      isTermsLoading = true;
      if (termsConditionsHtml.isEmpty) isLoading = true;
      update();

      final apiEndpoint = endpoint ?? ApiEndPoints.pharmacyTermsandConditions;
      final response = await DioClient().get(apiEndpoint);

      if (response.data is Map && response.data['status'] == true) {
        final terms = response.data['data']?['terms'];
        if (terms is Map) {
          _rawTerms = Map<String, dynamic>.from(terms);
          termsConditionsHtml = _getLocalizedContent(terms);
          htmlData = termsConditionsHtml;
        } else {
          termsConditionsHtml = "Terms and conditions not found";
          htmlData = termsConditionsHtml;
        }
      } else {
        termsConditionsHtml = "Terms and conditions not found";
        htmlData = termsConditionsHtml;
      }
    } catch (error) {
      debugPrint("terms Error: $error");
      if (termsConditionsHtml.isEmpty) {
        termsConditionsHtml = "Failed to load terms and conditions";
        htmlData = termsConditionsHtml;
      }
    } finally {
      isTermsLoading = false;
      isLoading = false;
      update();
    }
  }

  Future<void> getHelpAndSupport({bool forceRefresh = false}) async {
    if (!forceRefresh && (contactEmail.isNotEmpty || contactMobile.isNotEmpty)) {
      update();
      return;
    }
    try {
      isHelpLoading = true;
      if (contactEmail.isEmpty && contactMobile.isEmpty) isLoading = true;
      update();

      final response = await DioClient().get(ApiEndPoints.getContact);

      if (response.data is Map && response.data['status'] == true) {
        final contact = response.data['data']?['contact'];
        if (contact is Map) {
          contactEmail = (contact['email'] ?? "").toString();
          contactMobile =
              "${contact['country_code'] ?? ""} ${contact['mobile'] ?? ""}"
                  .trim();
        }
      }
    } catch (error) {
      debugPrint("HelpAndSupport Error: $error");
    } finally {
      isHelpLoading = false;
      isLoading = false;
      update();
    }
  }

  void onLanguageChanged() {
    if (_rawPrivacy != null) {
      privacyPolicyHtml = _getLocalizedContent(_rawPrivacy!);
      htmlData = privacyPolicyHtml;
    }
    if (_rawTerms != null) {
      termsConditionsHtml = _getLocalizedContent(_rawTerms!);
    }
    if (_rawAbout != null) {
      aboutUsHtml = _getLocalizedContent(_rawAbout!);
    }
    update();
  }
}
