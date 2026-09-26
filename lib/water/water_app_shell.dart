import 'package:flutter/material.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/views/home/home_view.dart';

/// Hosts the migrated water UI with the same ThemeData as the
/// original SaimpexWater-Vendor app, so screens look identical
/// inside the shared vendor shell.
class WaterAppShell extends StatelessWidget {
  const WaterAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundTop,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryOrange,
          surface: AppColors.card,
        ),
      ),
      child: const HomeView(),
    );
  }
}
