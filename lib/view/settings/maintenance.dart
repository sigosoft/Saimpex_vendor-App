import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';

class Maintenance extends StatelessWidget {
  Maintenance({super.key, required this.serverDownReason});
  final String? serverDownReason;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  "lib/assets/images/wewillback.png",
                  // replace with your asset
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
              ),

              const SizedBox(height: 20),
              Text(
                S.of(context).wellBeBackSoon,
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),
              Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Html(
                  data: serverDownReason.toString(),
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "p": Style(
                      fontSize: FontSize(14),
                      fontFamily: GoogleFonts.rubik().fontFamily,
                      lineHeight: LineHeight(1.6),
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                      textAlign: TextAlign.center,
                    ),
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
