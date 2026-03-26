import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/model/sales_report_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../Utils/Utils.dart';
import '../configs/ApiConfigs.dart';
import '../configs/Dioclient.dart';
import '../generated/l10n.dart';
import '../view/Login/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SalesReportController extends GetxController {

  final FlutterLocalization localization = FlutterLocalization.instance;
  String keyword = "";
  String totalPayoutbalance = "0";
  @override
  void onInit() {
    super.onInit();
    debugPrint("SalesReportController initialized");
    getVendorType();
  }

  @override
  void onClose() {
    scrollController.removeListener(_loadMoreRestaurantReports);
    scrollController.removeListener(_loadMoreGroceryReports);
    scrollController.dispose();
    debugPrint("SalesReportController disposed");
    super.onClose();
  }

  getVendorType() async {
    String vendorType = await getSavedObject("vendorType");
    if(vendorType == "1") {
      scrollController.addListener(_loadMoreRestaurantReports);
    }else{
      scrollController.addListener(_loadMoreGroceryReports);
    }

  }

  List<Datum> reportsList = [];
  bool isLoading = false;

  // Pagination variables
  bool _hasNextPage = true;
  int _page = 1;
  int _limit = 10;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  final ScrollController scrollController = ScrollController();
  String from_date = "";
  String to_date = "";

  /// Set date range for API. Pass null to clear. Format: yyyy/MM/dd.
  void setDateRange(DateTime? from, DateTime? to) {
    from_date = from != null
        ? '${from.year}/${from.month.toString().padLeft(2, '0')}/${from.day.toString().padLeft(2, '0')}'
        : '';
    to_date = to != null
        ? '${to.year}/${to.month.toString().padLeft(2, '0')}/${to.day.toString().padLeft(2, '0')}'
        : '';
    update();
  }

  void _loadMoreRestaurantReports() async {
    if (_hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.hasClients &&
        scrollController.position.extentAfter < 300) {
      isLoadMoreRunning = true;
      update();
      _page += 1;
      try {
        var token = await getSavedObject("token");
        DioClient().updateToken(token);
        final response = await DioClient().get(
          ApiEndPoints.resturantReport,
          query: {"limit": _limit, "page": _page,"from_date":from_date,"to_date":to_date},
        );
        if (response.data?['status'].toString() == "true") {
          SalesReportModel salesReportModel = SalesReportModel.fromJson(
            response.data,
          );
          if (salesReportModel.status.toString() == "true") {
            List<Datum>? fetchedNotifications =
                salesReportModel.data!.data;
            if (fetchedNotifications != null && fetchedNotifications.isNotEmpty) {
              reportsList.addAll(fetchedNotifications);
            }
            // Use API pagination metadata when available
            final data = salesReportModel.data;
            if (data?.currentPage != null && data?.lastPage != null) {
              _hasNextPage = data!.currentPage! < data.lastPage!;
            } else if (fetchedNotifications == null || fetchedNotifications.length < _limit) {
              _hasNextPage = false;
            }
          } else {
            _hasNextPage = false;
          }
        } else {
          _hasNextPage = false;
        }
      } catch (e, stackTrace) {
        debugPrint("stackTrace: $stackTrace");
        debugPrint("loadMoreresturantReport Error: $e");
        _hasNextPage = false;
      }

      isLoadMoreRunning = false;
      update();
    }
  }

  /// Download restaurant report using current date filters.
  /// Sends `from_date` and `to_date` in query and token in Authorization header.
  Future<void> restaurantReportDownload(BuildContext context) async {
    try {
      isLoading = true;
      update();

      final token = await getSavedObject("token");
      DioClient().updateToken(token);

      final response = await DioClient().dio.get<List<int>>(
        ApiEndPoints.restaurantReportDownload,
        queryParameters: {
          "from_date": from_date,
          "to_date": to_date,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {"Accept": "application/pdf"},
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw "Empty PDF response";
      }

      // `from_date` / `to_date` are formatted as yyyy/MM/dd for API.
      // Sanitize for file names to avoid creating nested directories.
      final safeFrom = (from_date.isEmpty ? 'all' : from_date).replaceAll('/', '-');
      final safeTo = (to_date.isEmpty ? 'all' : to_date).replaceAll('/', '-');
      final fileName =
          "restaurant_report_${safeFrom}_${safeTo}_${DateTime.now().millisecondsSinceEpoch}.pdf";

      Directory? targetDir;
      if (Platform.isAndroid) {
        final downloads = Directory("/storage/emulated/0/Download");
        // Create if missing (best-effort).
        if (!await downloads.exists()) {
          await downloads.create(recursive: true);
        }
        if (await downloads.exists()) targetDir = downloads;
      } else if (Platform.isIOS) {
        targetDir = await getApplicationDocumentsDirectory();
      }
      targetDir ??= await getApplicationDocumentsDirectory();

      try {
        final file = File("${targetDir.path}/$fileName");
        await file.writeAsBytes(bytes, flush: true);
        showToast(context, "Saved: ${file.path}");
        await OpenFilex.open(file.path);
      } catch (e) {
        // Fallback: app documents directory
        final fallbackDir = await getApplicationDocumentsDirectory();
        final file = File("${fallbackDir.path}/$fileName");
        await file.writeAsBytes(bytes, flush: true);
        showToast(context, "Saved: ${file.path}");
        await OpenFilex.open(file.path);
      }

      isLoading = false;
      update();
    } catch (error, stackTrace) {
      debugPrint("stackTrace: $stackTrace");
      isLoading = false;
      update();
      debugPrint("restaurantReportDownload Error: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> getRestaurantReports(BuildContext context) async {
    try {
      // Reset pagination
      _page = 1;
      _limit = 10;
      _hasNextPage = true;
      isFirstLoadRunning = true;
      isLoadMoreRunning = false;
      isLoading = true;
      update();

      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.resturantReport,
        query: {"limit": _limit, "page": _page,"from_date":from_date,"to_date":to_date},
      );

      if (response.data?['status'].toString() == "true") {
        //debugPrint("response.data: ${response.data}");
        SalesReportModel salesReportModel = SalesReportModel.fromJson(
          response.data,
        );
        if (salesReportModel.status.toString() == "true") {
          reportsList = salesReportModel.data!.data ?? [];
          debugPrint("resturantReportList: ${reportsList.length}");
          // Use API pagination metadata when available
          final data = salesReportModel.data;
          if (data?.currentPage != null && data?.lastPage != null) {
            _hasNextPage = data!.currentPage! < data.lastPage!;
          } else if (reportsList.length < _limit) {
            _hasNextPage = false;
          }
        } else {
          reportsList = [];
          _hasNextPage = false;
        }
      } else {
        reportsList = [];
        _hasNextPage = false;
      }

      isFirstLoadRunning = false;
      isLoading = false;
      update();
    } catch (error, stackTrace) {
      debugPrint("stackTrace: $stackTrace");
      isFirstLoadRunning = false;
      isLoading = false;
      _hasNextPage = false;
      update();
      debugPrint("getresturantReport Error: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(LoginScreen());
      }else{
        showToast(context, error.toString());
      }
    }
  }

  void _loadMoreGroceryReports() async {
    if (_hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.hasClients &&
        scrollController.position.extentAfter < 300) {
      isLoadMoreRunning = true;
      update();
      _page += 1;
      try {
        var token = await getSavedObject("token");
        DioClient().updateToken(token);
        final response = await DioClient().get(
          ApiEndPoints.groceryReport,
          query: {"limit": _limit, "page": _page,"from_date":from_date,"to_date":to_date},
        );
        if (response.data?['status'].toString() == "true") {
          SalesReportModel salesReportModel = SalesReportModel.fromJson(
            response.data,
          );
          if (salesReportModel.status.toString() == "true") {
            List<Datum>? fetchedNotifications =
                salesReportModel.data!.data;
            if (fetchedNotifications != null && fetchedNotifications.isNotEmpty) {
              reportsList.addAll(fetchedNotifications);
            }
            // Use API pagination metadata when available
            final data = salesReportModel.data;
            if (data?.currentPage != null && data?.lastPage != null) {
              _hasNextPage = data!.currentPage! < data.lastPage!;
            } else if (fetchedNotifications == null || fetchedNotifications.length < _limit) {
              _hasNextPage = false;
            }
          } else {
            _hasNextPage = false;
          }
        } else {
          _hasNextPage = false;
        }
      } catch (e, stackTrace) {
        debugPrint("stackTrace: $stackTrace");
        debugPrint("loadMoreresturantReport Error: $e");
        _hasNextPage = false;
      }

      isLoadMoreRunning = false;
      update();
    }
  }

  /// Download restaurant report using current date filters.
  /// Sends `from_date` and `to_date` in query and token in Authorization header.
  Future<void> groceryReportDownload(BuildContext context) async {
    try {
      isLoading = true;
      update();

      final token = await getSavedObject("token");
      DioClient().updateToken(token);

      final response = await DioClient().dio.get<List<int>>(
        ApiEndPoints.groceryReportDownload,
        queryParameters: {
          "from_date": from_date,
          "to_date": to_date,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {"Accept": "application/pdf"},
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw "Empty PDF response";
      }

      // `from_date` / `to_date` are formatted as yyyy/MM/dd for API.
      // Sanitize for file names to avoid creating nested directories.
      final safeFrom = (from_date.isEmpty ? 'all' : from_date).replaceAll('/', '-');
      final safeTo = (to_date.isEmpty ? 'all' : to_date).replaceAll('/', '-');
      final fileName =
          "restaurant_report_${safeFrom}_${safeTo}_${DateTime.now().millisecondsSinceEpoch}.pdf";

      Directory? targetDir;
      if (Platform.isAndroid) {
        final downloads = Directory("/storage/emulated/0/Download");
        // Create if missing (best-effort).
        if (!await downloads.exists()) {
          await downloads.create(recursive: true);
        }
        if (await downloads.exists()) targetDir = downloads;
      } else if (Platform.isIOS) {
        targetDir = await getApplicationDocumentsDirectory();
      }
      targetDir ??= await getApplicationDocumentsDirectory();

      try {
        final file = File("${targetDir.path}/$fileName");
        await file.writeAsBytes(bytes, flush: true);
        showToast(context, "Saved: ${file.path}");
        await OpenFilex.open(file.path);
      } catch (e) {
        // Fallback: app documents directory
        final fallbackDir = await getApplicationDocumentsDirectory();
        final file = File("${fallbackDir.path}/$fileName");
        await file.writeAsBytes(bytes, flush: true);
        showToast(context, "Saved: ${file.path}");
        await OpenFilex.open(file.path);
      }

      isLoading = false;
      update();
    } catch (error, stackTrace) {
      debugPrint("stackTrace: $stackTrace");
      isLoading = false;
      update();
      debugPrint("restaurantReportDownload Error: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(LoginScreen());
      } else {
        showToast(context, error.toString());
      }
    }
  }

  Future<void> getGroceryReports(BuildContext context) async {
    try {
      // Reset pagination
      _page = 1;
      _limit = 10;
      _hasNextPage = true;
      isFirstLoadRunning = true;
      isLoadMoreRunning = false;
      isLoading = true;
      update();

      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.groceryReport,
        query: {"limit": _limit, "page": _page,"from_date":from_date,"to_date":to_date},
      );

      if (response.data?['status'].toString() == "true") {
        //debugPrint("response.data: ${response.data}");
        SalesReportModel salesReportModel = SalesReportModel.fromJson(
          response.data,
        );
        if (salesReportModel.status.toString() == "true") {
          reportsList = salesReportModel.data!.data ?? [];
          debugPrint("resturantReportList: ${reportsList.length}");
          // Use API pagination metadata when available
          final data = salesReportModel.data;
          if (data?.currentPage != null && data?.lastPage != null) {
            _hasNextPage = data!.currentPage! < data.lastPage!;
          } else if (reportsList.length < _limit) {
            _hasNextPage = false;
          }
        } else {
          reportsList = [];
          _hasNextPage = false;
        }
      } else {
        reportsList = [];
        _hasNextPage = false;
      }

      isFirstLoadRunning = false;
      isLoading = false;
      update();
    } catch (error, stackTrace) {
      debugPrint("stackTrace: $stackTrace");
      isFirstLoadRunning = false;
      isLoading = false;
      _hasNextPage = false;
      update();
      debugPrint("getresturantReport Error: $error");
      if (error.toString() == "Unauthorized") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        showToast(context, S.of(context).youAreLoggedOutSuccessfully);
        Get.offAll(LoginScreen());
      }else{
        showToast(context, error.toString());
      }
    }
  }

}
