import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';

import 'package:saimpex_vendor/view/Login/login.dart';

import 'package:saimpex_vendor/controller/home_controller.dart';
import '../../Utils/Utils.dart';
import '../home/home.dart';
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
    final homeController = Get.put(HomeController());
    homeController.maintenance(context);
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
