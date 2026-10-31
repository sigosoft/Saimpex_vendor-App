import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/home_cleaning/model/service_item_model.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// Error carrying a message ready to show to the user (server message in the
/// current language when the server sent one).
class CleaningApiException implements Exception {
  const CleaningApiException(this.message);

  final String? message;

  @override
  String toString() => message ?? '';
}

/// Calls for the home cleaning vertical (vendorapp ServiceVerticalController).
class CleaningServicesApi {
  CleaningServicesApi._();

  static String get _lang => LocalizationService.currentLanguageCode;

  static Future<void> _ensureToken() async {
    final token = (await getSavedObject('token'))?.toString() ?? '';
    if (token.isNotEmpty && token != 'null') {
      DioClient().updateToken(token);
    }
  }

  static Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  static bool isOk(Map<String, dynamic>? body) {
    final status = body?['status'];
    return status == true ||
        status == 1 ||
        status?.toString().toLowerCase() == 'true' ||
        status?.toString() == '1';
  }

  /// Envelope message {message_en, message_fr, message_ar} in the current
  /// language, falling back to English; plain string messages as they are.
  static String? serverMessage(dynamic body) {
    final map = _asMap(body);
    final msg = map?['message'];
    if (msg is String) return msg.trim().isEmpty ? null : msg.trim();
    if (msg is! Map) return null;
    String? pick(dynamic value) {
      if (value is List && value.isNotEmpty) return value.first?.toString();
      if (value is String && value.trim().isNotEmpty) return value.trim();
      return null;
    }

    return pick(msg['message_$_lang']) ?? pick(msg['message_en']);
  }

  /// Runs a request and returns the decoded envelope, throwing
  /// [CleaningApiException] when the call fails or status is false.
  static Future<Map<String, dynamic>> _call(
    Future<dio.Response> Function() request,
  ) async {
    await _ensureToken();
    dio.Response response;
    try {
      response = await request();
    } on String catch (message) {
      // DioClient rethrows HTTP errors as the server message string.
      throw CleaningApiException(message);
    } on SocketException {
      throw const CleaningApiException(null);
    } catch (_) {
      throw const CleaningApiException(null);
    }
    final body = _asMap(response.data);
    if (body == null || !isOk(body)) {
      throw CleaningApiException(serverMessage(body));
    }
    return body;
  }

  /// GET serviceTypes: approved types for this vendor's vertical.
  static Future<List<CleaningServiceType>> fetchTypes() async {
    final body = await _call(() => DioClient().get(ApiEndPoints.serviceTypes));
    final data = body['data'];
    final list = data is Map ? data['service_types'] : null;
    if (list is! List) return const [];
    return list
        .map(CleaningServiceType.fromJson)
        .whereType<CleaningServiceType>()
        .toList();
  }

  /// GET serviceItems (paginated): all of the vendor's services.
  static Future<List<CleaningServiceItem>> fetchServices() async {
    final items = <CleaningServiceItem>[];
    var page = 1;
    var lastPage = 1;
    do {
      final body = await _call(
        () => DioClient().get(
          ApiEndPoints.serviceItems,
          query: {'page': page, 'limit': 50},
        ),
      );
      final data = body['data'];
      final services = data is Map ? data['services'] : null;
      final rows = services is Map ? services['data'] : services;
      if (rows is List) {
        items.addAll(
          rows
              .map(CleaningServiceItem.fromJson)
              .whereType<CleaningServiceItem>(),
        );
      }
      lastPage = services is Map
          ? int.tryParse('${services['last_page'] ?? 1}') ?? 1
          : 1;
      page++;
    } while (page <= lastPage && page <= 20);
    return items;
  }

  /// POST addServiceItem / updateServiceItem (multipart). List fields are sent
  /// as JSON strings, which the backend decodes. Every field is sent on update
  /// because the backend overwrites the row with what it receives.
  static Future<String?> saveService({
    int? serviceItemId,
    required CleaningServiceType type,
    required String description,
    required int status,
    required List<String> propertyTypes,
    required List<String> productSupply,
    double? supplyFee,
    required List<CleaningServiceSpace> spaces,
    required List<CleaningServiceAddon> addons,
    required List<String> issues,
    File? image,
  }) async {
    final fields = <String, dynamic>{
      'service_item_id': ?serviceItemId,
      'service_type_id': type.id,
      'name_en': type.nameEn ?? type.localizedName(_lang),
      'name_fr': ?type.nameFr,
      'name_ar': ?type.nameAr,
      'description_en': description,
      'price': spaces.isNotEmpty ? spaces.first.price : 0,
      'status': status,
      'property_types': jsonEncode(propertyTypes),
      'product_supply': jsonEncode(productSupply),
      'supply_fee': ?supplyFee,
      'spaces': jsonEncode(spaces.map((s) => s.toJson()).toList()),
      'addons': jsonEncode(addons.map((a) => a.toJson()).toList()),
      'issues': jsonEncode(issues),
    };
    if (image != null) {
      fields['image'] = await dio.MultipartFile.fromFile(
        image.path,
        filename: image.path.split(Platform.pathSeparator).last,
      );
    }
    final endpoint = serviceItemId == null
        ? ApiEndPoints.addServiceItem
        : ApiEndPoints.updateServiceItem;
    final body = await _call(
      () => DioClient().post(endpoint, body: dio.FormData.fromMap(fields)),
    );
    return serverMessage(body);
  }

  /// GET deleteServiceItem (soft delete on the server).
  static Future<String?> deleteService(int serviceItemId) async {
    final body = await _call(
      () => DioClient().get(
        ApiEndPoints.deleteServiceItem,
        query: {'service_item_id': serviceItemId},
      ),
    );
    return serverMessage(body);
  }

  /// GET serviceHours: days, slots, store_open, today_hours, accepting_bookings.
  static Future<Map<String, dynamic>> fetchHours() async {
    final body = await _call(() => DioClient().get(ApiEndPoints.serviceHours));
    final data = body['data'];
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }
}
