import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/controller/settings_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/view/shimmer_loading/shimmer_text_content.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupport extends StatelessWidget {
  const HelpAndSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: LocalizationService().getTextDirection(),
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
            S.of(context).helpSupport,
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
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: GetBuilder<SettingsController>(
            init: SettingsController(),
            didChangeDependencies: (state) {
              final controller = state.controller;
              if (controller != null &&
                  controller.contactEmail.isEmpty &&
                  controller.contactMobile.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.getHelpAndSupport();
                });
              }
            },
            builder: (controller) {
              final hasData =
                  controller.contactEmail.isNotEmpty ||
                  controller.contactMobile.isNotEmpty;
              return (controller.isHelpLoading || controller.isLoading) &&
                      !hasData
                  ? const SingleChildScrollView(child: ShimmerTextContent())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).callUs,
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            if (controller.contactMobile.isNotEmpty) {
                              await launchUrl(
                                Uri.parse(
                                  "tel:${controller.contactMobile.replaceAll(' ', '')}",
                                ),
                              );
                            }
                          },
                          child: Text(
                            controller.contactMobile.isNotEmpty
                                ? controller.contactMobile
                                : "N/A",
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF333E63),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          S.of(context).emailUs,
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            if (controller.contactEmail.isNotEmpty) {
                              await launchUrl(
                                Uri.parse("mailto:${controller.contactEmail}"),
                              );
                            }
                          },
                          child: Text(
                            controller.contactEmail.isNotEmpty
                                ? controller.contactEmail
                                : "N/A",
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF333E63),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Divider(
                          color: Colors.grey.withOpacity(0.1),
                          height: 1,
                          thickness: 1,
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
