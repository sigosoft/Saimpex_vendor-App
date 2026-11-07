import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/RetryInterceptor.dart';
import 'package:saimpex_vendor/configs/store_endpoints.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/api_message.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  final FlutterLocalization localization = FlutterLocalization.instance;
  Dio dio = Dio();

  DioClient._internal() {
    dio
      ..options.baseUrl = ApiConfigs.BASE_URL.endsWith('/')
          ? ApiConfigs.BASE_URL
          : "${ApiConfigs.BASE_URL}/"
      ..options.connectTimeout = Duration(seconds: 20)
      ..options.receiveTimeout = Duration(seconds: 20)
      ..options.headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
      };

    dio.interceptors.add(_authInterceptor());
    dio.interceptors.add(RetryInterceptor(dio: dio));
    // Request logs only in debug builds; release builds log nothing.
    if (kDebugMode) dio.interceptors.add(_loggingInterceptor());
  }

  /// Auth Interceptor: guarantees Authorization header is automatically attached to every request
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Local store vendors: grocery endpoints → localStore* (V12, §6.23).
        final vendorType = (await getSavedObject('vendorType'))?.toString();
        if (StoreEndpoints.isSwapped(options.path, vendorType)) {
          options.path = StoreEndpoints.forVendorType(options.path, vendorType);
          _toLocalStoreRequest(options);
        }
        final path = options.path;
        final isLogin = path.contains(ApiEndPoints.login) || path.contains('/login');
        if (!isLogin) {
          final authHeader = options.headers["Authorization"]?.toString();
          if (authHeader == null ||
              authHeader.isEmpty ||
              authHeader == "Bearer " ||
              authHeader == "Bearer null" ||
              authHeader == "Bearer false") {
            final token = (await getSavedObject("token"))?.toString();
            if (token != null &&
                token.isNotEmpty &&
                token != "null" &&
                token != "false" &&
                token != "home_cleaning_mock_token") {
              options.headers["Authorization"] = "Bearer $token";
              dio.options.headers["Authorization"] = "Bearer $token";
            }
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Local store replies use local_store_menu… keys; the grocery screens
        // read grocery_menu….
        if (response.requestOptions.extra['localStoreKeys'] == true) {
          response.data = StoreEndpoints.toGroceryKeys(response.data);
        }
        return handler.next(response);
      },
    );
  }

  /// Renames grocery_menu… / grocery_tag… request keys (query, form, JSON)
  /// for a local store endpoint, and marks the reply for renaming back.
  static void _toLocalStoreRequest(RequestOptions options) {
    options.extra['localStoreKeys'] = true;
    options.queryParameters = options.queryParameters
        .map((k, v) => MapEntry(StoreEndpoints.toLocalStoreKey(k), v));
    final data = options.data;
    if (data is FormData) {
      options.data = FormData()
        ..fields.addAll(data.fields.map((e) => MapEntry(StoreEndpoints.toLocalStoreKey(e.key), e.value)))
        ..files.addAll(data.files.map((e) => MapEntry(StoreEndpoints.toLocalStoreKey(e.key), e.value)));
    } else if (data is Map) {
      options.data = data.map((k, v) => MapEntry(k is String ? StoreEndpoints.toLocalStoreKey(k) : k, v));
    }
  }

  /// Logger Interceptor
  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        log("➡️ REQUEST: ${options.method} ${options.uri}");
        // Never print the bearer token, even in debug logs.
        final safeHeaders = Map.of(options.headers)
          ..updateAll((k, v) => k.toLowerCase() == 'authorization' ? 'Bearer ***' : v);
        log("Headers: $safeHeaders");
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
        debugPrint(
          "❌ API ERROR QUERY: ${error.requestOptions.queryParameters}",
        );
        debugPrint("❌ API ERROR BODY: ${error.requestOptions.data}");
        debugPrint("❌ API ERROR RESPONSE: ${error.response?.data}");
        return handler.next(error);
      },
    );
  }

  String _resolvePath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final base = (dio.options.baseUrl.isNotEmpty ? dio.options.baseUrl : ApiConfigs.BASE_URL).trim();
    if (base.isEmpty) return path;

    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    if (cleanBase.endsWith('/api')) {
      if (!cleanPath.startsWith('vendor/') && !cleanPath.startsWith('vendorapp/')) {
        return '$cleanBase/vendorapp/$cleanPath';
      }
      return '$cleanBase/$cleanPath';
    }

    if (cleanBase.endsWith('/vendor') && cleanPath.startsWith('vendor/')) {
      return '$cleanBase/${cleanPath.substring(7)}';
    }
    if (cleanBase.endsWith('/vendorapp') && cleanPath.startsWith('vendorapp/')) {
      return '$cleanBase/${cleanPath.substring(10)}';
    }
    if (cleanBase.endsWith('/vendor') && cleanPath.startsWith('vendorapp/')) {
      final rootApi = cleanBase.substring(0, cleanBase.length - 7);
      return '$rootApi/$cleanPath';
    }
    if (cleanBase.endsWith('/vendorapp') && cleanPath.startsWith('vendor/')) {
      final rootApi = cleanBase.substring(0, cleanBase.length - 10);
      return '$rootApi/$cleanPath';
    }

    return '$cleanBase/$cleanPath';
  }

  /// Common GET Method
  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await dio.get(_resolvePath(path), queryParameters: query);
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
        _resolvePath(path),
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

      // Server text in the app language first: login and validation errors
      // come as {field_en, field_fr, field_ar}, and taking the first entry
      // showed English in the Arabic app (VA-03).
      if (data is Map && statusCode != 401 && statusCode != 500) {
        final local = ApiMessage.fromMessage(data['message']);
        if (local != null) return local;
      }

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

        return S.current.somethingWentWrong;
      } else if (statusCode == 500) {
        return S.current.somethingWentWrong;
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
        return S.current.somethingWentWrong;
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
      return S.current.noInternetConnection;
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return S.current.requestTimedOut;
    }

    if (e.type == DioExceptionType.receiveTimeout) {
      return S.current.requestTimedOut;
    }

    if (e.type == DioExceptionType.sendTimeout) {
      return S.current.requestTimedOut;
    }

    // Log the error type and message for debugging
    log("DioException Type: ${e.type}");
    log("DioException Message: ${e.message}");
    if (e.response != null) {
      log("Response Status: ${e.response!.statusCode}");
      log("Response Data: ${e.response!.data}");
    }

    return S.current.somethingWentWrong;
  }

  /// Enhance an image using the imageEnhance endpoint.
  Future<Uint8List?> enhanceImageBytes(
    String localPath,
    String originalFilename, {
    String preset = 'general',
    String prompt =
        'Enhance image quality, improve sharpness, lighting, colors and details while preserving the original content and composition.',
    int width = 1024,
    int height = 1024,
    String format = 'png',
  }) async {
    File? tempCompressedOriginal;
    try {
      String pathToUpload = localPath;
      try {
        final originalFile = File(localPath);
        if (await originalFile.exists()) {
          final originalSize = await originalFile.length();
          if (originalSize > 1.5 * 1024 * 1024) {
            debugPrint(
              "[DioClient] Original image is large (${(originalSize / 1024 / 1024).toStringAsFixed(1)} MB). Compressing before enhancement...",
            );
            final tempDir = await getTemporaryDirectory();
            final targetPath =
                '${tempDir.path}/pre_enhance_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final compressedFile =
                await FlutterImageCompress.compressAndGetFile(
                  localPath,
                  targetPath,
                  format: CompressFormat.jpeg,
                  quality: 75,
                );
            if (compressedFile != null) {
              pathToUpload = compressedFile.path;
              tempCompressedOriginal = File(compressedFile.path);
              debugPrint(
                "[DioClient] Compressed original size: ${(await tempCompressedOriginal.length() / 1024).toStringAsFixed(1)} KB",
              );
            }
          }
        }
      } catch (compressError) {
        debugPrint(
          "[DioClient] Pre-enhancement compression failed: $compressError",
        );
      }

      final enhanceBodyMap = <String, dynamic>{
        'image': await MultipartFile.fromFile(
          pathToUpload,
          filename: originalFilename,
        ),
        'file': await MultipartFile.fromFile(
          pathToUpload,
          filename: originalFilename,
        ),
        'preset': preset,
        'prompt': prompt,
        'width': width.toString(),
        'height': height.toString(),
        'format': format,
      };
      final enhanceBody = FormData.fromMap(enhanceBodyMap);

      final enhanceResponse = await dio.post(
        ApiConfigs.BASE_URL + ApiEndPoints.imageEnhance,
        data: enhanceBody,
        options: Options(
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 120),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final responseData = enhanceResponse.data;
      debugPrint(
        "openai-image-enhance response statusCode: ${enhanceResponse.statusCode}",
      );
      debugPrint("openai-image-enhance response data: $responseData");
      String? base64Str;

      if (responseData is Map) {
        final dataField = responseData['data'];
        if (dataField is Map) {
          base64Str = dataField['enhanced_image_base64']?.toString();
        }
        base64Str ??= responseData['enhanced_image_base64']?.toString();
      } else if (responseData is String) {
        try {
          final map = jsonDecode(responseData);
          if (map is Map) {
            final dataField = map['data'];
            if (dataField is Map) {
              base64Str = dataField['enhanced_image_base64']?.toString();
            }
            base64Str ??= map['enhanced_image_base64']?.toString();
          }
        } catch (_) {}
      }

      if (base64Str == null || base64Str.isEmpty) {
        throw Exception(
          "Image enhancement failed: API did not return enhanced image base64.",
        );
      }

      final File file = await base64ToFile(base64Str);
      try {
        final targetPath = file.path.replaceFirst(
          RegExp(r'\.[^\.]+$'),
          '_compressed.jpg',
        );
        debugPrint("[DioClient] Compressing enhanced image...");
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.path,
          targetPath,
          format: CompressFormat.jpeg,
          quality: 80,
        );
        if (compressedFile != null) {
          final compressedBytes = await File(compressedFile.path).readAsBytes();
          debugPrint(
            "[DioClient] Compression successful: "
            "original=${((await file.length()) / 1024).toStringAsFixed(1)} KB, "
            "compressed=${(compressedBytes.length / 1024).toStringAsFixed(1)} KB",
          );
          try {
            await file.delete();
            await File(compressedFile.path).delete();
          } catch (_) {}
          return compressedBytes;
        } else {
          throw Exception("Compressor returned null for path: $targetPath");
        }
      } catch (compressError) {
        try {
          await file.delete();
        } catch (_) {}
        throw Exception("Enhanced image compression failed: $compressError");
      }
    } catch (e) {
      debugPrint("DioClient enhanceImageBytes error: $e");
      rethrow;
    } finally {
      if (tempCompressedOriginal != null) {
        try {
          await tempCompressedOriginal.delete();
        } catch (_) {}
      }
    }
  }
}

/// Helper to convert a base64 string to a File with MIME detection.
Future<File> base64ToFile(String base64Str) async {
  // Extract MIME type and cleaner base64 string
  String mimeType = 'image/jpeg';
  String cleanBase64 = base64Str;

  if (base64Str.startsWith('data:')) {
    final int colonIndex = base64Str.indexOf(':');
    final int semicolonIndex = base64Str.indexOf(';');
    if (colonIndex != -1 &&
        semicolonIndex != -1 &&
        semicolonIndex > colonIndex) {
      mimeType = base64Str.substring(colonIndex + 1, semicolonIndex);
    }
    final int commaIndex = base64Str.indexOf(',');
    if (commaIndex != -1) {
      cleanBase64 = base64Str.substring(commaIndex + 1);
    }
  }

  // Detect extension
  String extension = 'jpg';
  if (mimeType.contains('png')) {
    extension = 'png';
  } else if (mimeType.contains('gif')) {
    extension = 'gif';
  } else if (mimeType.contains('webp')) {
    extension = 'webp';
  } else if (mimeType.contains('jpeg') || mimeType.contains('jpg')) {
    extension = 'jpg';
  }

  // Clean whitespaces/newlines from base64 string
  cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');
  int remainder = cleanBase64.length % 4;
  if (remainder > 0) {
    cleanBase64 += '=' * (4 - remainder);
  }
  final bytes = base64Decode(cleanBase64);

  final tempDir = await getTemporaryDirectory();
  final tempFile = File(
    '${tempDir.path}/enhanced_image_${DateTime.now().millisecondsSinceEpoch}.$extension',
  );
  await tempFile.writeAsBytes(bytes);
  return tempFile;
}
