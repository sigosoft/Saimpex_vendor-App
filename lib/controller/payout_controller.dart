import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';

import '../Utils/Utils.dart';
import '../configs/ApiConfigs.dart';
import '../configs/Dioclient.dart';
import '../generated/l10n.dart';
import '../model/received_payout_model.dart';
import '../view/Login/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PayoutController extends GetxController {

  final FlutterLocalization localization = FlutterLocalization.instance;
  String keyword = "";
  String totalPayoutbalance = "0";
  @override
  void onInit() {
    super.onInit();
    debugPrint("PayoutController initialized");
    scrollController.addListener(_loadMoreReceivedPayouts);
  }

  @override
  void onClose() {
    scrollController.removeListener(_loadMoreReceivedPayouts);
    scrollController.dispose();
    debugPrint("PayoutController disposed");
    super.onClose();
  }

  List<Datum> receivedPayoutsList = [];
  bool isLoading = false;

  // Pagination variables
  bool _hasNextPage = true;
  int _page = 1;
  int _limit = 10;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  final ScrollController scrollController = ScrollController();

  void _loadMoreReceivedPayouts() async {
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
          ApiEndPoints.receivedPayouts,
          query: {"vendor_type":vendorType,"limit": _limit, "page": _page,"keyword":keyword},
        );
        if (response.data?['status'].toString() == "true") {
          ReceivedPayoutModel receivedPayoutModel = ReceivedPayoutModel.fromJson(
            response.data,
          );
          if (receivedPayoutModel.status.toString() == "true") {
            List<Datum>? fetchedNotifications =
                receivedPayoutModel.data!.receivedPayouts!.data;
            if (fetchedNotifications != null && fetchedNotifications.isNotEmpty) {
              receivedPayoutsList.addAll(fetchedNotifications);
            }
            // Use API pagination metadata when available
            final data = receivedPayoutModel.data!.receivedPayouts;
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
        debugPrint("loadMoreReceivedPayouts Error: $e");
        _hasNextPage = false;
      }

      isLoadMoreRunning = false;
      update();
    }
  }

  /// Call when user changes search text. Resets to page 1 and fetches with new keyword.
  void searchPayouts(BuildContext context, String value) {
    keyword = value.trim();
    getReceivedPayouts(context);
  }

  Future<void> getReceivedPayouts(BuildContext context) async {
    String vendorType = await getSavedObject("vendorType");
    try {
      // Reset pagination
      _page = 1;
      _limit = 10;
      _hasNextPage = true;
      isFirstLoadRunning = true;
      isLoadMoreRunning = false;
      isLoading = false;
      update();

      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.receivedPayouts,
        query: {"vendor_type":vendorType,"limit": _limit, "page": _page,"keyword":keyword},
      );

      if (response.data?['status'].toString() == "true") {
        debugPrint("response.data: ${response.data}");
        ReceivedPayoutModel receivedPayoutModel = ReceivedPayoutModel.fromJson(
          response.data,
        );
        if (receivedPayoutModel.status.toString() == "true") {
          receivedPayoutsList = receivedPayoutModel.data!.receivedPayouts!.data ?? [];
           totalPayoutbalance = receivedPayoutModel.data!.vendor!.currentBalance.toString();
          debugPrint("ReceivedPayoutsList: ${receivedPayoutsList.length}");
          // Use API pagination metadata when available
          final data = receivedPayoutModel.data!.receivedPayouts;
          if (data?.currentPage != null && data?.lastPage != null) {
            _hasNextPage = data!.currentPage! < data.lastPage!;
          } else if (receivedPayoutsList.length < _limit) {
            _hasNextPage = false;
          }
        } else {
          receivedPayoutsList = [];
          _hasNextPage = false;
        }
      } else {
        receivedPayoutsList = [];
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
      debugPrint("getReceivedPayouts Error: $error");
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
