import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';

import '../Utils/Utils.dart';
import '../configs/ApiConfigs.dart';
import '../configs/Dioclient.dart';
import '../generated/l10n.dart';
import '../model/notification_model.dart';
import '../view/Login/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NotificationController extends GetxController {

  final FlutterLocalization localization = FlutterLocalization.instance;
  @override
  void onInit() {
    super.onInit();
    debugPrint("NotificationController initialized");
    scrollController.addListener(_loadMoreNotifications);
  }

  @override
  void onClose() {
    scrollController.removeListener(_loadMoreNotifications);
    scrollController.dispose();
    debugPrint("NotificationController disposed");
    super.onClose();
  }

  List<Datum> notificationList = [];
  bool isLoading = false;

  // Pagination variables
  bool _hasNextPage = true;
  int _page = 1;
  int _limit = 10;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  final ScrollController scrollController = ScrollController();

  void _loadMoreNotifications() async {
    String vendorType = await getSavedObject("vendorType");
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
          ApiEndPoints.getNotifications,
          query: {"vendor_type":vendorType,"limit": _limit, "page": _page},
        );
      if (response.data?['status'].toString() == "true") {
        NotificationModel notificationModel = NotificationModel.fromJson(
          response.data,
        );
        if (notificationModel.status.toString() == "true") {
          List<Datum>? fetchedNotifications =
              notificationModel.data!.data;
            if (fetchedNotifications != null && fetchedNotifications.isNotEmpty) {
              notificationList.addAll(fetchedNotifications);
            }
            // Use API pagination metadata when available
            final data = notificationModel.data;
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
        debugPrint("loadMoreNotifications Error: $e");
        _hasNextPage = false;
      }

      isLoadMoreRunning = false;
      update();
    }
  }

  Future<void> getNotifications(BuildContext context) async {
    String vendorType = await getSavedObject("vendorType");
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
        ApiEndPoints.getNotifications,
        query: {"vendor_type":vendorType,"limit": _limit, "page": _page},
      );

      if (response.data?['status'].toString() == "true") {
        debugPrint("response.data: ${response.data}");
        NotificationModel notificationModel = NotificationModel.fromJson(
          response.data,
        );
        if (notificationModel.status.toString() == "true") {
          notificationList = notificationModel.data!.data ?? [];
          debugPrint("notificationList: ${notificationList.length}");
          // Use API pagination metadata when available
          final data = notificationModel.data;
          if (data?.currentPage != null && data?.lastPage != null) {
            _hasNextPage = data!.currentPage! < data.lastPage!;
          } else if (notificationList.length < _limit) {
            _hasNextPage = false;
          }
        } else {
          notificationList = [];
          _hasNextPage = false;
        }
      } else {
        notificationList = [];
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
      debugPrint("getNotifications Error: $error");
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
