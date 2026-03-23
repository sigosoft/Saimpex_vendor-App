import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/view/login/widgets/bold_text-rubik.dart';

import '../../../generated/l10n.dart';

class GuestLoginButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String? text;

  const GuestLoginButtonWidget({super.key, required this.onTap, this.text});
  FlutterLocalization get localization => FlutterLocalization.instance;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: localization.currentLocale!.languageCode.toString() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: size.height * 0.06,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorPrimary, width: 1.5),
          ),
          child: Center(
            child: BoldTextRubik(
              text: text ?? S.of(context).guestLogin,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
