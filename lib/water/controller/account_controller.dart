import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class WaterAccountController extends GetxController {
  static const languages = ['English', 'French', 'Arabic'];

  int languageIndex = 0;
  bool notificationsEnabled = true;
  bool isLoading = false;

  ProfileModel? profileModel;
  ProfileData? get profileData => profileModel?.data;
  Map<String, dynamic>? rawData;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading = true;
      update();

      final token = await getSavedObject('token');
      if (token != null &&
          token.toString() != 'null' &&
          token.toString().isNotEmpty) {
        DioClient().updateToken(token);
      }

      final vendorType = await getSavedObject('vendorType');
      final Map<String, dynamic> query = {
        'limit': 10,
        'page': 1,
      };
      if (vendorType != null &&
          vendorType.toString() != 'null' &&
          vendorType.toString().isNotEmpty &&
          vendorType.toString() != '0') {
        query['vendor_type'] = vendorType.toString();
      }

      debugPrint("==================== GET WATER PROFILE ====================");
      debugPrint("Endpoint: ${ApiEndPoints.profile}");
      debugPrint("Query: $query");

      final response = await DioClient().get(
        ApiEndPoints.profile,
        query: query,
      );

      debugPrint("==================== GET WATER PROFILE RESPONSE ====================");
      debugPrint("Profile response status: ${response.statusCode}");

      if (response.data != null) {
        if (response.data is Map<String, dynamic>) {
          rawData = response.data['data'] is Map<String, dynamic>
              ? response.data['data']
              : null;
        }
        profileModel = ProfileModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("Water fetchProfile error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  String get profileImage {
    final img = profileData?.image?.trim() ??
        rawData?['vendor']?['image']?.toString().trim() ??
        rawData?['image']?.toString().trim();
    if (img != null && img.isNotEmpty && img != 'null') {
      if (img.startsWith('http://') || img.startsWith('https://')) {
        return img;
      }
      return '${ApiConfigs.IMAGE_URL}$img';
    }
    return '';
  }

  String get storeName {
    final name = profileData?.name?.trim() ??
        rawData?['vendor']?['name']?.toString().trim() ??
        rawData?['vendor']?['name_en']?.toString().trim() ??
        rawData?['name']?.toString().trim();
    if (name != null && name.isNotEmpty && name != 'null') {
      return name;
    }
    return '';
  }

  String get rating {
    final r = profileData?.rating?.trim() ??
        rawData?['vendor']?['rating']?.toString().trim() ??
        rawData?['rating']?.toString().trim();
    if (r != null && r.isNotEmpty && r != 'null') {
      return r;
    }
    return '';
  }

  bool get isStoreOpen {
    final rawVendor = rawData?['vendor'] is Map<String, dynamic>
        ? rawData!['vendor'] as Map<String, dynamic>
        : rawData;
    final isOpenVal = rawVendor?['is_open'] ?? rawVendor?['open_status'];
    if (isOpenVal != null) {
      return isOpenVal == 1 ||
          isOpenVal == '1' ||
          isOpenVal == true ||
          isOpenVal.toString().toLowerCase() == 'open';
    }
    final isBusy = profileData?.isBusy ?? rawVendor?['is_busy'];
    if (isBusy != null) {
      return isBusy == 2 || isBusy == '2';
    }
    final status = profileData?.status ?? rawVendor?['status']?.toString();
    if (status != null) {
      final s = status.toUpperCase();
      return s == 'ACTIVE' || s == '1' || s == 'OPEN';
    }
    return false;
  }

  String get storeStatusText {
    final rawVendor = rawData?['vendor'] is Map<String, dynamic>
        ? rawData!['vendor'] as Map<String, dynamic>
        : rawData;
    final statusStr = rawVendor?['open_status_text']?.toString() ??
        rawVendor?['status_text']?.toString();
    if (statusStr != null && statusStr.isNotEmpty && statusStr != 'null') {
      return statusStr;
    }
    final rawStatus = profileData?.status ?? rawVendor?['status']?.toString();
    if (rawStatus != null && rawStatus.isNotEmpty && rawStatus != 'null') {
      final s = rawStatus.toUpperCase();
      if (s == 'ACTIVE' || s == '1') return 'Open';
      if (s == 'INACTIVE' || s == '0') return 'Closed';
      return rawStatus;
    }
    return isStoreOpen ? 'Open' : 'Closed';
  }

  void selectLanguage(int index) {
    languageIndex = index;
    update();
  }

  void setNotifications(bool value) {
    notificationsEnabled = value;
    update();
  }
}
