import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../controller/otp_controller.dart';
import '../../generated/l10n.dart';
import '../../resources/colors.dart';
import '../../utils/Widgets/custom_app_bar.dart';
import '../../utils/Widgets/custom_button.dart';

class Otp extends StatefulWidget {
  const Otp({super.key, required this.country_code, required this.mobile});

  final String country_code;
  final String mobile;

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: localization.currentLocale!.languageCode.toString() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBar(
          title: S.of(context).otpVerification,
          onTap: () {
            Get.back();
          },
        ),
        body: GetBuilder<OtpController>(
          init: OtpController(),
          initState: (_) {},
          builder: (controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            S
                                .of(context)
                                .weveSentAVerificationCodeToYourWhatsapp,
                            textAlign: TextAlign.center,
                            style: appFont('Rubik', 
                              textStyle: Theme.of(
                                context,
                              ).textTheme.labelMedium,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Pinput(
                          length: 6,
                          controller: controller.pinController,
                          keyboardType: TextInputType.number,

                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],

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

                          onChanged: (value) {
                            // Debug
                            // print("Current OTP: $value");
                          },

                          onCompleted: (otp) {
                            controller.otp = otp;
                            controller.update();
                          },
                        ),

                        // OtpTextField(
                        //   clearText: controller.otp == "" ? true : false,
                        //   numberOfFields: 6,
                        //   borderColor: borderColor,
                        //   showCursor: true,
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.digitsOnly,
                        //     // Allow only digits
                        //   ],
                        //   fieldWidth: MediaQuery.of(context).size.width*0.13,
                        //   focusedBorderColor: borderColor,
                        //   cursorColor: colorPrimary,
                        //   //set to true to show as box or false to show as dash
                        //   showFieldAsBox: true,
                        //   //runs when a code is typed in
                        //   onCodeChanged: (String code) {
                        //     //handle validation or checks here
                        //     // controller.otp = code; // Store the entered OTP
                        //     // controller.update();
                        //   },
                        //   //runs when every textfield is filled
                        //   onSubmit: (String verificationCode) {
                        //     //handle validation or checks here
                        //     controller.otp = verificationCode; // Store the entered OTP
                        //     controller.update();
                        //   }, // end onSubmit
                        // ),
                        const SizedBox(height: 10),
                        Container(
                          margin: EdgeInsetsDirectional.only(start: 10),
                          child: Obx(
                            () => Text(
                              controller.canResend.value
                                  ? S.of(context).resendOtp
                                  : "Resend code in ${controller.remainingSeconds.value} sec",
                              textAlign: TextAlign.center,
                              style: appFont('Rubik', 
                                textStyle: Theme.of(
                                  context,
                                ).textTheme.labelMedium,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Obx(
                          () => InkWell(
                            onTap: controller.canResend.value
                                ? () {
                                    controller.resendOtp(
                                      context,
                                      widget.country_code,
                                      widget.mobile,
                                    );
                                  }
                                : null,
                            child: Center(
                              child: Wrap(
                                runAlignment: WrapAlignment.center,
                                alignment: WrapAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).didntGetTheOtp,
                                    style: appFont('Rubik', 
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    " " + S.of(context).resendOtp,
                                    style: appFont('Rubik', 
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: controller.canResend.value
                                          ? colorPrimary
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsetsDirectional.only(
                        start: 15,
                        end: 15,
                        bottom: 80,
                      ),
                      width: double.infinity,
                      child: CustomButton(
                        text: S.of(context).continuee, // localized text
                        backgroundColor: colorPrimary, // dynamic color
                        onPressed: () {
                          controller.verifyOtp(
                            context,
                            widget.country_code,
                            widget.mobile,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
