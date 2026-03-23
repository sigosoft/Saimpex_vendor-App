import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import '../../Utils/Utils.dart';
import '../Home/Home.dart';
import '../Login/Login.dart';
import '../notifications/notification.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String? isFirstLaunch;
  @override
  void initState() {
    final firebaseMessaging = FCM();
    firebaseMessaging.setNotifications();
    splashNavigation();
    super.initState();
  }

  splashNavigation() async {
    var loginStatus = await getSavedObject("loginStatus");
    var token = await getSavedObject("token");
    debugPrint("loginStatus: $loginStatus");
    debugPrint("token: $token");
    if (loginStatus != null && loginStatus == "true") {
      Get.offAll(() => const Home());
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return CommonBackground(
      child: SizedBox.expand(
        child: Center(
          child: Image.asset(
            'lib/assets/images/logo.png',
            width: media.height * 0.8,
            height: media.width * 0.8,
          ),
        ),
      ),
    );
  }
}
