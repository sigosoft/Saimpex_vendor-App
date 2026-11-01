import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pinput/pinput.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/widgets/custom_button.dart';
import 'package:saimpex_vendor/view/login/widgets/bold_text-rubik.dart';

class OtpVerficationAlertDialog extends StatelessWidget {
  const OtpVerficationAlertDialog({
    super.key,
    required this.phoneNumber,
    required this.onPressed,
    required this.otpController,
  });
  final String phoneNumber;
  final VoidCallback onPressed;
  final TextEditingController otpController;
  FlutterLocalization get localization => FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Directionality(
      textDirection: localization.currentLocale!.languageCode.toString() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey),
              ),
              padding: EdgeInsets.all(media.size.width * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: media.size.height * 0.03),
                  BoldTextRubik(
                    textAlign: TextAlign.center,
                    text:
                       "${S.of(context).pleaseEnterTheVerificationCodeSentTo}$phoneNumber",
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                  SizedBox(height: media.size.height * 0.04),
                  Pinput(
                    length: 6,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    defaultPinTheme: PinTheme(
                      width: MediaQuery.of(context).size.width * 0.13,
                      height: 55,
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: MediaQuery.of(context).size.width * 0.13,
                      height: 55,
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                    ),
                    cursor: Container(
                      width: 2,
                      height: 22,
                      color: colorPrimary,
                    ),
                    showCursor: true,
                    onChanged: (value) {},
                    onCompleted: (otp) {},
                  ),
                  SizedBox(height: media.size.height * 0.03),
                  CustomButton(
                    text: S.of(context).continuee,
                    backgroundColor: colorPrimary,
                    onPressed: onPressed,
                  ),
                ],
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: IconButton(
                padding: EdgeInsets.only(
                  right: media.size.width * 0.03,
                  top: media.size.height * 0.02,
                ),
                constraints: const BoxConstraints(),
                icon: Image.asset(
                  'lib/assets/images/close_icon_big.png',
                  width: 15,
                  height: 15,
                  fit: BoxFit.contain,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String phoneNumber,
    required VoidCallback onPressed,
    required TextEditingController otpController,
  }) {
    showDialog(
      context: context,
      builder: (context) => OtpVerficationAlertDialog(
        otpController: otpController,
        phoneNumber: phoneNumber,
        onPressed: onPressed,
      ),
    );
  }
}
