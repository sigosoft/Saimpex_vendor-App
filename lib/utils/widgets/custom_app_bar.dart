import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({super.key, required this.title, this.onTap, this.showBack=true});

  final void Function()? onTap;
  final String title;
  final bool showBack;
  final FlutterLocalization localization = FlutterLocalization.instance;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: localization.currentLocale!.languageCode.toString() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            backgroundColor: Colors.white,
            centerTitle: false,
            foregroundColor: Colors.white,
            forceMaterialTransparency: true,
            elevation: 0,
            leading: showBack?IconButton(
              icon: Transform.rotate(
                angle:
                    localization.currentLocale!.languageCode.toString() == "ar"
                    ? 3.1416
                    : 0, // 180 degrees in radians (π)
                child: Image.asset('lib/assets/images/back.png',height: 35,width: 35,),
              ),
              onPressed: onTap ?? () {
                Get.back();
              },
            ):Container(),
            title: Text(
              title,
              style: GoogleFonts.rubik(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
