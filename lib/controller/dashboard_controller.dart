import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/dashboard_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class DashboardController extends GetxController {
  bool isLoading = false;
  DashboardData? dashboardData;
  String selectedYear = DateTime.now().year.toString();

  // From 2024 to this year (the list stopped at 2026).
  final List<String> years = [
    for (var y = 2024; y <= DateTime.now().year; y++) y.toString(),
  ];

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getDashboard() async {
    try {
      isLoading = true;
      update();

      var token = await getSavedObject("token");
      var vendorType = await getSavedObject("vendorType");
      if (token != null) {
        DioClient().updateToken(token);
      } else {
        DioClient().updateToken("");
      }

      final response = await DioClient().get(
        ApiEndPoints.dashboard,
        query: {"vendor_type": vendorType ?? "1", "revenue_year": selectedYear},
      );

      DashboardModel model = DashboardModel.fromJson(response.data);
      if (model.status == true && model.data != null) {
        dashboardData = model.data;
      }
    } catch (error) {
      debugPrint("getDashboard Error: $error");
    } finally {
      isLoading = false;
      update();
    }
  }

  void changeYear(String year) {
    selectedYear = year;
    update();
    getDashboard();
  }

  /// Returns the subscription name based on the current locale
  String getSubscriptionName(String locale) {
    if (dashboardData?.subscriptionDetails == null) return "";
    final sub = dashboardData!.subscriptionDetails!;
    if (locale == 'ar') return sub.nameAr ?? sub.nameEn ?? "";
    if (locale == 'fr') return sub.nameFr ?? sub.nameEn ?? "";
    return sub.nameEn ?? "";
  }

  /// Returns days remaining until subscription ends
  int get subscriptionDaysLeft {
    final endDate = dashboardData?.subscriptionDetails?.subscriptionEndDate;
    if (endDate == null) return 0;
    try {
      final end = DateTime.parse(endDate);
      final diff = end.difference(DateTime.now()).inDays;
      return diff < 0 ? 0 : diff;
    } catch (_) {
      return 0;
    }
  }

  /// Returns the max value in revenue_report for chart scaling
  double get maxRevenue {
    final report = dashboardData?.revenueReport;
    if (report == null || report.isEmpty) return 1.0;
    double max = report.reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1.0 : max;
  }

  /// Returns the popular item name based on locale
  String getItemName(PopularItem item, String locale) {
    if (locale == 'ar') return item.nameAr ?? item.nameEn ?? "";
    if (locale == 'fr') return item.nameFr ?? item.nameEn ?? "";
    return item.nameEn ?? "";
  }

  /// Returns the attribute name for a popular item based on locale
  String getAttributeName(PopularItem item, String locale) {
    if (locale == 'ar')
      return item.attributeNameAr ?? item.attributeNameEn ?? "";
    if (locale == 'fr')
      return item.attributeNameFr ?? item.attributeNameEn ?? "";
    return item.attributeNameEn ?? "";
  }
}
