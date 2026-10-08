import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../generated/l10n.dart';

import '../../controller/settings_controller.dart';
import '../../view/shimmer_loading/shimmer_text_content.dart';

class TermsandConditions extends StatelessWidget {
  const TermsandConditions({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = FlutterLocalization.instance;
    return Directionality(
      textDirection: localization.currentLocale!.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF333E63),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            S.of(context).termsConditions,
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF333E63),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Divider(color: Colors.grey.withOpacity(0.1), height: 1),
          ),
        ),
        body: GetBuilder<SettingsController>(
          init: SettingsController(),
          didChangeDependencies: (state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (state.controller!.htmlData.isEmpty) {
                state.controller!.getTerms();
              }
            });
          },
          builder: (controller) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: controller.isLoading
                  ? const ShimmerTextContent()
                  : Html(
                      data: controller.htmlData,
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
                          textAlign: TextAlign.justify,
                        ),
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
