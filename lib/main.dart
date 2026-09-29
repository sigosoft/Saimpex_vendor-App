import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/Utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:saimpex_vendor/view/splash/Splash.dart';
import 'generated/l10n.dart';

// localization.translate('ar');
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterLocalization.instance.ensureInitialized();

  if (Platform.isAndroid && (await Permission.notification.isDenied)) {
    await Permission.notification.request();
  }

  String? langCode = await getSavedObject("selected_locale") ?? "en";
  Locale locale = Locale(langCode!);
  // print("locale: "+langCode);
  FlutterLocalization.instance.init(
    mapLocales: [
      const MapLocale(
        'en',
        AppLocale.EN,
        countryCode: 'US',
        fontFamily: 'Font EN',
      ),
      const MapLocale(
        'fr',
        AppLocale.FR,
        countryCode: 'FR',
        fontFamily: 'Font AR',
      ),
      const MapLocale(
        'ar',
        AppLocale.AR,
        countryCode: 'OM',
        fontFamily: 'Font AR',
      ),
    ],
    initLanguageCode: langCode,
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp(initialLocale: locale));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;

  const MyApp({required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

mixin AppLocale {
  static const String title = 'title';

  static const Map<String, dynamic> EN = {title: 'Localization'};
  static const Map<String, dynamic> AR = {title: 'الترجمه'};

  static const Map<String, dynamic> FR = {title: 'Localisation'};
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GetMaterialApp(
          // routerDelegate: router.routerDelegate,
          // routeInformationParser: router.routeInformationParser,
          locale: widget.initialLocale,
          fallbackLocale: Locale('en'),
          localizationsDelegates: [
            S.delegate,
            CountryLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          debugShowCheckedModeBanner: false,
          title: 'Saimpex SA',
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: colorPrimary,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            scaffoldBackgroundColor: Colors.white,
            textTheme: GoogleFonts.baloo2TextTheme(),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            useMaterial3: true,
          ),
          home: Splash(),
        );
      },
    );
  }
}
