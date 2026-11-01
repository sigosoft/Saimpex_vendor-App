import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import '../../resources/colors.dart';
import '../../utils/Widgets/custom_button.dart';

class ServerDown extends StatelessWidget {
  ServerDown({super.key});
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
          padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 50),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      "lib/assets/images/serverdown.png",
                      // replace with your asset
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),

                  Text(
                    S.of(context).serverDown,
                    style: appFont('Rubik', 
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              Positioned(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: S.of(context).gotIt, // localized text
                      backgroundColor: colorPrimary, // dynamic color
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
