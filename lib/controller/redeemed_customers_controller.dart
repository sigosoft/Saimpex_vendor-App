import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/model/basket_customers_model.dart';
import 'package:saimpex_vendor/model/basket_details_model.dart';

import '../Utils/Utils.dart';
import '../configs/ApiConfigs.dart';
import '../configs/Dioclient.dart';
import '../generated/l10n.dart';
import '../view/Login/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RedeemedCustomersController extends GetxController {

  final FlutterLocalization localization = FlutterLocalization.instance;
  String basket_id = "";


  @override
  void onInit() {
    super.onInit();
    debugPrint("RedeemedCustomersController initialized");
    scrollController.addListener(_loadMoreBaskets);
  }

  @override
  void onClose() {
    scrollController.removeListener(_loadMoreBaskets);
    scrollController.dispose();
    debugPrint("RedeemedCustomersController disposed");
    super.onClose();
  }

  List<Datum> basketList = [];
  bool isLoading = false;

  bool isBasketDetailsLoading = false;
  BasketDetailsModel? basketDetailsModel;

  // Pagination variables
  bool _hasNextPage = true;
  int _page = 1;
  int _limit = 10;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  final ScrollController scrollController = ScrollController();

  bool get hasNextPage => _hasNextPage;

  void _loadMoreBaskets() async {
    // In practice, UI can either rely on this listener or call `loadMoreBaskets()`.
    if (!scrollController.hasClients) return;
    if (scrollController.position.extentAfter < 300) {
      await loadMoreBaskets();
    }
  }

  Future<void> loadMoreBaskets() async {
    if (_hasNextPage == false ||
        isFirstLoadRunning == true ||
        isLoadMoreRunning == true) {
      return;
    }

    isLoadMoreRunning = true;
    update();
    _page += 1;

    try {
      final vendorType = await getSavedObject("vendorType");
      final token = await getSavedObject("token");
      DioClient().updateToken(token);

      final query = <String, dynamic>{
        "limit": _limit,
        "page": _page,
        "vendor_type": vendorType,
        "basket_id": basket_id,
      };

      final response = await DioClient().get(
        ApiEndPoints.basketRedeemedCustomers,
        query: query,
      );

      if (response.data?['status'].toString() == "true") {
        final basketModel = BasketCustomersModel.fromJson(response.data);
        if (basketModel.status.toString() == "true") {
          final fetched = basketModel.data!.redeemedCustomers!.data ?? [];
          if (fetched.isNotEmpty) {
            basketList.addAll(fetched);
          }

          final data = basketModel.data;
          if (data?.redeemedCustomers!.currentPage != null && data?.redeemedCustomers!.lastPage != null) {
            _hasNextPage = data!.redeemedCustomers!.currentPage! < data.redeemedCustomers!.lastPage!;
          } else if (fetched.length < _limit) {
            _hasNextPage = false;
          }
        } else {
          _hasNextPage = false;
        }
      } else {
        _hasNextPage = false;
      }
    } catch (e, stackTrace) {
      debugPrint("Basket loadMore error: $e");
      debugPrint("stackTrace: $stackTrace");
      _hasNextPage = false;
    } finally {
      isLoadMoreRunning = false;
      update();
    }
  }


  Future<void> getBasketsCustomers(
      BuildContext context) async {
    try {
      _page = 1;
      _limit = 10;
      _hasNextPage = true;
      isFirstLoadRunning = true;
      isLoadMoreRunning = false;
      isLoading = true;
      update();
      String vendorType = await getSavedObject("vendorType");
      var token = await getSavedObject("token");
      DioClient().updateToken(token);

      final query = <String, dynamic>{
        "limit": _limit,
        "page": _page,
        "vendor_type": vendorType,
        "basket_id": basket_id,
      };

      final response = await DioClient().get(
        ApiEndPoints.basketRedeemedCustomers,
        query: query,
      );

      if (response.data?['status'].toString() == "true") {
        //debugPrint("response.data: ${response.data}");
        BasketCustomersModel basketModel = BasketCustomersModel.fromJson(
          response.data,
        );
        if (basketModel.status.toString() == "true") {
          basketList = basketModel.data!.redeemedCustomers!.data ?? [];
          debugPrint("basketReportList: ${basketList.length}");
          // Use API pagination metadata when available
          final data = basketModel.data;
          if (data?.redeemedCustomers!.currentPage != null && data?.redeemedCustomers!.lastPage != null) {
            _hasNextPage = data!.redeemedCustomers!.currentPage! < data.redeemedCustomers!.lastPage!;
          } else if (basketList.length < _limit) {
            _hasNextPage = false;
          }
        } else {
          basketList = [];
          _hasNextPage = false;
        }
      } else {
        basketList = [];
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
      debugPrint("getbasketReport Error: $error");
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
