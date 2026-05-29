import 'dart:developer';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/RetryInterceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  final FlutterLocalization localization = FlutterLocalization.instance;
  Dio dio = Dio();

  DioClient._internal() {
    dio
      ..options.baseUrl = ApiConfigs.BASE_URL
      ..options.connectTimeout = Duration(seconds: 20)
      ..options.receiveTimeout = Duration(seconds: 20)
      ..options.headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
      };

    dio.interceptors.add(RetryInterceptor(dio: dio));
    dio.interceptors.add(_loggingInterceptor());
  }

  /// Logger Interceptor
  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        log("➡️ REQUEST: ${options.method} ${options.uri}");
        log("Headers: ${options.headers}");
        final requestData = options.data;
        if (requestData is FormData) {
          final fields = requestData.fields
              .map((e) => "${e.key}: ${e.value}")
              .join(", ");
          final files = requestData.files
              .map((e) => "${e.key}: ${e.value.filename ?? 'file'}")
              .join(", ");
          log("Data(FormData) fields: {$fields}");
          if (files.isNotEmpty) {
            log("Data(FormData) files: {$files}");
          }
        } else {
          log("Data: $requestData");
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log("⬅️ RESPONSE: ${response.statusCode} ${response.data}");
        final apiName = response.requestOptions.path;
        debugPrint(
          "✅ API SUCCESS: ${response.requestOptions.method} "
          "(Status code: ${response.statusCode}) "
          "API: $apiName",
        );
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        log("❌ ERROR: ${error.error}");
        final apiName = error.requestOptions.path;
        debugPrint(
          "❌ API ERROR: ${error.requestOptions.method} "
          "(Status code: ${error.response?.statusCode ?? 'No response'}) "
          "API: $apiName",
        );
        debugPrint("❌ API ERROR QUERY: ${error.requestOptions.queryParameters}");
        debugPrint("❌ API ERROR BODY: ${error.requestOptions.data}");
        debugPrint("❌ API ERROR RESPONSE: ${error.response?.data}");
        return handler.next(error);
      },
    );
  }

  /// Common GET Method
  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Common POST Method
  Future<Response> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
  }) async {
    try {
      final isMultipart = body is FormData;
      return await dio.post(
        path,
        data: body,
        queryParameters: query,
        options: isMultipart
            ? Options(contentType: Headers.multipartFormDataContentType)
            : null,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add token dynamically
  void updateToken(String token) {
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  // GLOBAL ERROR HANDLING
  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      final statusCode = e.response!.statusCode;

      if (statusCode == 422 && data is Map) {
        final msg = data['message'];

        if (msg is Map) {
          final langCode = localization.currentLocale?.languageCode ?? 'en';
          final langKey = langCode == 'ar'
              ? 'message_ar'
              : langCode == 'fr'
              ? 'message_fr'
              : 'message_en';
          // Nested structure: message.request_id.message_en (or message_fr, message_ar)
          for (final entry in msg.entries) {
            final value = entry.value;
            if (value is Map) {
              final list = value[langKey];
              if (list is List && list.isNotEmpty) {
                return list.first.toString();
              }
              final en = value['message_en'];
              if (en is List && en.isNotEmpty) return en.first.toString();
            } else if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
          }
          // Fallback: first key's value as list
          final keys = msg.keys.toList();
          if (keys.isNotEmpty) {
            final firstValue = msg[keys[0]];
            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }
          }
        }

        if (msg is String) {
          return msg;
        }

        return "Validation failed";
      } else if (statusCode == 500) {
        // Get.to(ServerDown());
        return "Server error occurred";
      } else if (statusCode == 401) {
        return "Unauthorized";
      } else {
        // Log more details about the error
        log("Error Status Code: $statusCode");
        log("Error Data: $data");
        if (data is Map && data['message'] != null) {
          final msg = data['message'];
          if (msg is String) return msg;
          if (msg is Map) {
            final langCode = localization.currentLocale?.languageCode ?? 'en';
            final langKey = langCode == 'ar'
                ? 'message_ar'
                : langCode == 'fr'
                ? 'message_fr'
                : 'message_en';
            for (final entry in msg.entries) {
              final value = entry.value;
              if (value is Map) {
                final list = value[langKey];
                if (list is List && list.isNotEmpty) {
                  return list.first.toString();
                }
                final en = value['message_en'];
                if (en is List && en.isNotEmpty) return en.first.toString();
              } else if (value is List && value.isNotEmpty) {
                return value.first.toString();
              }
            }
            final keys = msg.keys.toList();
            if (keys.isNotEmpty) {
              final firstValue = msg[keys[0]];
              if (firstValue is List && firstValue.isNotEmpty) {
                return firstValue.first.toString();
              }
              if (firstValue is String) return firstValue;
            }
          }
        }
        return "Something went wrong. Code: $statusCode";
      }

      // if (data['message'] != null) {
      //   if (data['message'] is String) return data['message'];
      //
      //   if (data['message'] is Map) {
      //     final msg = data['message'] as Map;
      //     final firstKey = msg.keys.first;
      //     final firstValue = msg[firstKey];
      //
      //     if (firstValue is List && firstValue.isNotEmpty) {
      //       return firstValue.first;
      //     }
      //   }
      // }
      //
      // return "Something went wrong. Code: $statusCode";
    }

    if (e.type == DioExceptionType.connectionError) {
      return "No Internet Connection";
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return "Connection Timeout. Try again.";
    }

    if (e.type == DioExceptionType.receiveTimeout) {
      return "Receive Timeout. Try again.";
    }

    if (e.type == DioExceptionType.sendTimeout) {
      return "Send Timeout. Try again.";
    }

    // Log the error type and message for debugging
    log("DioException Type: ${e.type}");
    log("DioException Message: ${e.message}");
    if (e.response != null) {
      log("Response Status: ${e.response!.statusCode}");
      log("Response Data: ${e.response!.data}");
    }

    return "Unexpected error occurred: ${e.message ?? e.type.toString()}";
  }

  /// Enhance an image using the imageEnhance endpoint.
  /// Returns the enhanced image bytes, or null if enhancement fails.
  Future<Uint8List?> enhanceImageBytes(String localPath, String originalFilename) async {
    try {
      final enhanceBodyMap = <String, dynamic>{
        'image': await MultipartFile.fromFile(
          localPath,
          filename: originalFilename,
        ),
        'file': await MultipartFile.fromFile(
          localPath,
          filename: originalFilename,
        ),
      };
      final enhanceBody = FormData.fromMap(enhanceBodyMap);

      final enhanceResponse = await dio.post(
        ApiConfigs.BASE_URL + ApiEndPoints.imageEnhance,
        data: enhanceBody,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final bytes = enhanceResponse.data as List<int>?;
      if (bytes != null && bytes.isNotEmpty) {
        final isJson = bytes[0] == 123; // '{' in ASCII
        if (isJson) {
          final jsonStr = utf8.decode(bytes);
          final map = jsonDecode(jsonStr);
          if (map is Map) {
            final rawPath = map['image'] ??
                map['data']?['image'] ??
                map['data'] ??
                map['enhanced_image'] ??
                map['url'];
            if (rawPath != null) {
              final String imageUrl = rawPath.toString();
              final fullUrl = imageUrl.startsWith('http')
                  ? imageUrl
                  : '${ApiConfigs.IMAGE_URL}$imageUrl';

              final downloadRes = await dio.get<List<int>>(
                fullUrl,
                options: Options(responseType: ResponseType.bytes),
              );
              if (downloadRes.data != null) {
                return Uint8List.fromList(downloadRes.data!);
              }
            }
          }
        } else {
          return Uint8List.fromList(bytes);
        }
      }
    } catch (e) {
      debugPrint("DioClient enhanceImageBytes error: $e");
    }
    return null;
  }
}
