import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import '../../resources/colors.dart';
import '../../utils/widgets/custom_button.dart';

class NoInternet extends StatelessWidget {
  NoInternet({super.key});
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
                children: [
                  Center(
                    child: Image.asset(
                      "lib/assets/images/no_internet.png",
                      // replace with your asset
                      height: MediaQuery.of(context).size.height * 0.25,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    S.of(context).noInternetConnection,
                    style: appFont('Rubik', 
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    S.of(context).noInternetConnectionDescription,
                    textAlign: TextAlign.center,
                    style: appFont('Rubik', 
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),

              Positioned(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: S.of(context).tryAgain, // localized text
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
