import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import '../../controller/otp_controller.dart';
import '../../generated/l10n.dart';
import '../../resources/colors.dart';
import '../../utils/widgets/custom_app_bar.dart';
import '../../utils/widgets/custom_button.dart';
import '../../utils/widgets/custom_text_form_field.dart';

class WhatsName extends StatefulWidget {
  const WhatsName({super.key});

  @override
  State<WhatsName> createState() => _WhatsNameState();
}

class _WhatsNameState extends State<WhatsName> {
  final FlutterLocalization localization = FlutterLocalization.instance;
  String otp = '';
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: localization.currentLocale!.languageCode.toString() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: CustomAppBar(
          title: '',
          showBack: false,
          onTap: () {
            Get.back();
          },
        ),
        body: GetBuilder<OtpController>(
          init: OtpController(),
          initState: (_) {},
          builder: (controller) {
            return Form(
              key: controller.formKey1,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          S.of(context).whatsYourName,
                          textAlign: TextAlign.center,
                          style: appFont('Rubik', 
                            textStyle: Theme.of(context).textTheme.labelMedium,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          controller: controller.nameController,
                          hintText: S.of(context).enterYourName,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            return null;
                          },
                        ),
                      ],
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
                          text: S.of(context).done, // localized text
                          backgroundColor: colorPrimary, // dynamic color
                          onPressed: () {
                            controller.saveName(context);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
