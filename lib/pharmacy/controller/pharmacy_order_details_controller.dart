import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_order_detail_model.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_prescription_detail_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class PharmacyOrderDetailsController extends GetxController {
  double rotationTurns = 0;

  bool isLoadingOtcOrderDetail = false;
  PharmacyOrderDetailModel? otcOrderDetailModel;
  PharmacyOrderDetailData? get otcOrderDetailData => otcOrderDetailModel?.data;
  PharmacyOrderDetailOrder? get otcOrder => otcOrderDetailData?.order;
  List<PharmacyOrderItem> get otcItems => otcOrderDetailData?.items ?? [];
  bool get isLoadingOrderDetail => isLoadingOtcOrderDetail;
  PharmacyOrderDetailData? get orderDetailData => otcOrderDetailData;

  bool isLoadingPrescriptionDetail = false;
  PharmacyPrescriptionDetailModel? prescriptionDetailModel;
  PharmacyPrescriptionDetailData? get prescriptionDetailData =>
      prescriptionDetailModel?.data;
  PharmacyPrescriptionDetailPrescription? get prescriptionObj =>
      prescriptionDetailData?.prescription;
  List<PharmacyPrescriptionImage> get prescriptionImages =>
      prescriptionDetailData?.images ?? [];
  List<PharmacyPrescriptionQuoteItem> get prescriptionQuoteItems =>
      prescriptionDetailData?.quoteItems ?? [];

  Uint8List? prescriptionImageBytes;
  String? prescriptionImageLoadedUrl;
  bool isLoadingPrescriptionImage = false;

  void rotatePrescription() {
    rotationTurns += 0.25;
    update();
  }

  String _getPharmacyOrderDetailUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.pharmacyOrderDetail.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<void> fetchPharmacyOrderDetail(dynamic orderId) async {
    if (orderId == null) return;
    isLoadingOtcOrderDetail = true;
    update();
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        isLoadingOtcOrderDetail = false;
        update();
        return;
      }

      final queryParams = <String, dynamic>{'order_id': orderId};

      final url = _getPharmacyOrderDetailUrl(queryParams);
      debugPrint(
        "==================== GET PHARMACY ORDER DETAIL ====================",
      );
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyOrderDetail}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print(
        "==================== GET PHARMACY ORDER DETAIL ====================",
      );
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyOrderDetail}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final cleanEndpoint =
          ApiEndPoints.pharmacyOrderDetail.startsWith('vendorapp/')
              ? ApiEndPoints.pharmacyOrderDetail
              : 'vendorapp/${ApiEndPoints.pharmacyOrderDetail}';

      final response = await DioClient().get(
        cleanEndpoint,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "==================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "==================================================================",
      );

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString() == 'true')) {
        otcOrderDetailModel = PharmacyOrderDetailModel.fromJson(dataMap);
      } else {
        otcOrderDetailModel = null;
      }
    } catch (e) {
      debugPrint(
        "==================== GET PHARMACY ORDER DETAIL ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "=======================================================================",
      );

      print(
        "==================== GET PHARMACY ORDER DETAIL ERROR ====================",
      );
      print("Error: $e");
      print(
        "=======================================================================",
      );
      otcOrderDetailModel = null;
    } finally {
      isLoadingOtcOrderDetail = false;
      update();
    }
  }

  String _getPharmacyPrescriptionDetailUrl([Map<String, dynamic>? query]) {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final endpoint = ApiEndPoints.pharmacyPrescriptionDetails.trim().replaceFirst(
      RegExp(r'^/'),
      '',
    );
    final cleanEndpoint = endpoint.startsWith('vendorapp/')
        ? endpoint
        : 'vendorapp/$endpoint';
    var url = '$base/$cleanEndpoint';
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
          )
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }

  Future<void> fetchPharmacyPrescriptionDetails(dynamic prescriptionId) async {
    if (prescriptionId == null) return;
    isLoadingPrescriptionDetail = true;
    update();
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        isLoadingPrescriptionDetail = false;
        update();
        return;
      }

      final queryParams = <String, dynamic>{'prescription_id': prescriptionId};

      final url = _getPharmacyPrescriptionDetailUrl(queryParams);
      debugPrint(
        "==================== GET PHARMACY PRESCRIPTION DETAILS ====================",
      );
      debugPrint("API Call: GET $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyPrescriptionDetails}");
      debugPrint("Query: $queryParams");
      debugPrint("Request Body: null (GET request)");

      print(
        "==================== GET PHARMACY PRESCRIPTION DETAILS ====================",
      );
      print("API Call: GET $url");
      print("Endpoint: ${ApiEndPoints.pharmacyPrescriptionDetails}");
      print("Query: $queryParams");
      print("Request Body: null (GET request)");

      final cleanEndpoint =
          ApiEndPoints.pharmacyPrescriptionDetails.startsWith('vendorapp/')
              ? ApiEndPoints.pharmacyPrescriptionDetails
              : 'vendorapp/${ApiEndPoints.pharmacyPrescriptionDetails}';

      final response = await DioClient().get(
        cleanEndpoint,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "=========================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "=========================================================================",
      );

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (dataMap != null &&
          (dataMap['status'] == true ||
              dataMap['status'].toString() == 'true')) {
        prescriptionDetailModel =
            PharmacyPrescriptionDetailModel.fromJson(dataMap);
        debugPrint(
          "Parsed primaryImageUrl: ${prescriptionDetailData?.primaryImageUrl}",
        );
        print(
          "Parsed primaryImageUrl: ${prescriptionDetailData?.primaryImageUrl}",
        );

        final rawImg = prescriptionDetailData?.images.isNotEmpty == true
            ? (prescriptionDetailData!.images.first.imagePath ??
                prescriptionDetailData!.images.first.fullImageUrl)
            : prescriptionDetailData?.primaryImageUrl;

        if (rawImg != null && rawImg.isNotEmpty) {
          fetchPrescriptionImageBytes(rawImg);
        }
      } else {
        prescriptionDetailModel = null;
      }
    } catch (e) {
      debugPrint(
        "==================== GET PHARMACY PRESCRIPTION DETAILS ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "===============================================================================",
      );

      print(
        "==================== GET PHARMACY PRESCRIPTION DETAILS ERROR ====================",
      );
      print("Error: $e");
      print(
        "===============================================================================",
      );
      prescriptionDetailModel = null;
    } finally {
      isLoadingPrescriptionDetail = false;
      update();
    }
  }

  List<String> getPrescriptionImageCandidateUrls(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    var p = raw.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) {
      final uri = Uri.tryParse(p);
      if (uri != null) {
        p = uri.path;
      }
    }
    while (p.startsWith('/')) {
      p = p.substring(1);
    }
    if (p.startsWith('storage/')) {
      p = p.substring(8);
    }
    if (p.startsWith('public/')) {
      p = p.substring(7);
    }

    final candidates = <String>[];
    void addUrl(String u) {
      if (!candidates.contains(u)) candidates.add(u);
    }

    // 1. Configured base URL
    final base = ApiConfigs.IMAGE_URL.trim();
    final cleanBase = base.endsWith('/') ? base : '$base/';
    addUrl('$cleanBase$p');

    // 2. dev with storage
    addUrl('https://dev.saimpexenterprise.com/storage/$p');
    // 3. dev with public/storage
    addUrl('https://dev.saimpexenterprise.com/public/storage/$p');
    // 4. dev root
    addUrl('https://dev.saimpexenterprise.com/$p');
    // 5. dev storage/app/public
    addUrl('https://dev.saimpexenterprise.com/storage/app/public/$p');
    // 6. api.saimpexenterprise.com storage
    addUrl('https://api.saimpexenterprise.com/storage/$p');
    // 7. api.saimpexenterprise.com public/storage
    addUrl('https://api.saimpexenterprise.com/public/storage/$p');
    // 8. ourworks domain
    addUrl('https://ourworks.co.in/saimpex-backend/public/storage/$p');

    return candidates;
  }

  Future<void> fetchPrescriptionImageBytes(String? raw) async {
    final candidates = getPrescriptionImageCandidateUrls(raw);
    if (candidates.isEmpty) return;

    isLoadingPrescriptionImage = true;
    update();

    final token = (await getSavedObject("token"))?.toString() ?? "";
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.bytes,
      ),
    );

    for (final url in candidates) {
      for (final useAuth in [true, false]) {
        try {
          debugPrint("➡️ Trying prescription image URL: $url (auth: $useAuth)");
          print("➡️ Trying prescription image URL: $url (auth: $useAuth)");

          final headers = <String, String>{
            'Accept': 'image/*, */*',
          };
          if (useAuth && token.isNotEmpty) {
            headers['Authorization'] = 'Bearer $token';
          }

          final response = await dio.get<List<int>>(
            url,
            options: Options(headers: headers),
          );

          if (response.statusCode == 200 &&
              response.data != null &&
              response.data!.isNotEmpty) {
            prescriptionImageBytes = Uint8List.fromList(response.data!);
            prescriptionImageLoadedUrl = url;
            debugPrint(
              "✅ Prescription image loaded successfully: ${prescriptionImageBytes!.length} bytes from $url",
            );
            print(
              "✅ Prescription image loaded successfully: ${prescriptionImageBytes!.length} bytes from $url",
            );
            isLoadingPrescriptionImage = false;
            update();
            return;
          }
        } catch (e) {
          debugPrint("⚠️ Failed from $url (auth: $useAuth): $e");
          print("⚠️ Failed from $url (auth: $useAuth): $e");
        }
      }
    }

    isLoadingPrescriptionImage = false;
    update();
  }
}
