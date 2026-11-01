import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/Widgets/custom_button.dart';
import 'package:saimpex_vendor/view/login/widgets/bold_text-rubik.dart';

import '../../../generated/l10n.dart';

class LogoutBottomSheet extends StatelessWidget {
  const LogoutBottomSheet({
    super.key,
    required this.onNo,
    required this.onLogout,
  });

  final VoidCallback onNo;
  final VoidCallback onLogout;

  FlutterLocalization get localization => FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Directionality(
      textDirection: localization.currentLocale!.languageCode.toString() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.all(media.size.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: BoldTextRubik(
                        text: S.of(context).logout,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(
                        'lib/assets/images/close_icon_big.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: media.size.height * 0.03),
              Text(
                S.of(context).areYouSureYouWantToLogout,
                textAlign: TextAlign.center,
                style: appFont('Rubik', 
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: media.size.height * 0.04),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: S.of(context).no,
                      onPressed: onNo,
                      backgroundColor: lightOrange,
                      textColor: colorPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      padding: EdgeInsets.symmetric(
                        vertical: media.size.height * 0.018,
                      ),
                      borderRadius: 12,
                    ),
                  ),
                  SizedBox(width: media.size.width * 0.04),
                  Expanded(
                    child: CustomButton(
                      text: S.of(context).logout,
                      onPressed: onLogout,
                      backgroundColor: colorPrimary,
                      textColor: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      padding: EdgeInsets.symmetric(
                        vertical: media.size.height * 0.018,
                      ),
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: media.size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required VoidCallback onNo,
    required VoidCallback onLogout,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LogoutBottomSheet(
        onNo: () {
          Get.back();
          onNo();
        },
        onLogout: () {
          Get.back();
          onLogout();
        },
      ),
    );
  }
}
