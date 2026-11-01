import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/view/login/widgets/bold_text-rubik.dart';

import '../../../generated/l10n.dart';

class SelectImageAlertDialog extends StatelessWidget {
  const SelectImageAlertDialog({
    super.key,
    required this.onGallery,
    required this.onCamera,
  });

  final VoidCallback onGallery;
  final VoidCallback onCamera;

  FlutterLocalization get localization => FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Directionality(
      textDirection: localization.currentLocale!.languageCode.toString() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: EdgeInsets.all(media.size.width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                SizedBox(height: media.size.height * 0.02),
                BoldTextRubik(
                  text: S.of(context).chooseImageFrom,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                SizedBox(height: media.size.height * 0.04),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onGallery();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: media.size.height * 0.025,
                          ),
                          decoration: BoxDecoration(
                            color: boxColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'lib/assets/images/gallery.png',
                                  width: 40,
                                  height: 40,
                                ),
                                SizedBox(height: media.size.height * 0.01),
                                Text(
                                  S.of(context).gallery,
                                  style: appFont('Rubik', 
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: media.size.width * 0.04),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onCamera();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: media.size.height * 0.025,
                          ),
                          decoration: BoxDecoration(
                            color: boxColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'lib/assets/images/camera_icon.png',
                                  width: 40,
                                  height: 40,
                                ),
                                SizedBox(height: media.size.height * 0.01),
                                Text(
                                  S.of(context).camera,
                                  style: appFont('Rubik', 
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: media.size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required VoidCallback onGallery,
    required VoidCallback onCamera,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) =>
          SelectImageAlertDialog(onGallery: onGallery, onCamera: onCamera),
    );
  }
}
