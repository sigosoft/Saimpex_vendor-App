import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../resources/colors.dart';
import '../../utils/Widgets/custom_button.dart';
import '../home/home.dart';

class NeedAnUpdate extends StatelessWidget {
  NeedAnUpdate({super.key});
  final localization = FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: localization.currentLocale!.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Center(
                child: Image.asset(
                  "lib/assets/images/logo.png",
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.08),

              Text(
                S.of(context).needsAnUpdate,
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  S.of(context).aNewUpdateIsAvailableForThisAppPleaseDownload,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: S.of(context).update, // Use your "Update" key
                  backgroundColor: colorPrimary,
                  onPressed: () async {
                    final Uri url = Platform.isAndroid
                        ? Uri.parse(
                            "https://play.google.com/store/apps/details?id=${ApiConfigs.androidPackageName}",
                          )
                        : Uri.parse(
                            "https://apps.apple.com/app/id${ApiConfigs.iosAppStoreId}",
                          );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      ).then((value) {
                        Get.offAll(Home());
                      });
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ),

              const SizedBox(height: 25),

              Image.asset(
                Platform.isAndroid
                    ? "lib/assets/images/googleplay.png"
                    : "lib/assets/images/appstore.png",
                height: 20,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
