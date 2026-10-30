import 'dart:async';
import 'package:saimpex_vendor/configs/secure_credentials.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' hide Response;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/model/login_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/view/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  static Future<bool>? _reauthFuture;

  RetryInterceptor({required this.dio});

  Future<bool> _hasInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity.isNotEmpty && connectivity.any((r) => r != ConnectivityResult.none);
  }

  Future<Response?> _retry(RequestOptions requestOptions) async {
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }

  Future<bool> _getReauthFuture() {
    if (_reauthFuture != null) {
      return _reauthFuture!;
    }
    _reauthFuture = _performReauth().then((success) {
      _reauthFuture = null;
      return success;
    }).catchError((e) {
      _reauthFuture = null;
      return false;
    });
    return _reauthFuture!;
  }

  Future<bool> _performReauth() async {
    try {
      final username = await getSavedObject("username");
      final password = await SecureCredentials.readPassword();
      if (username == null || password == null) {
        return false;
      }

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        // Safe to ignore if firebase is not fully loaded or returns error
      }

      final loginDio = Dio(BaseOptions(
        baseUrl: ApiConfigs.BASE_URL,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));

      final response = await loginDio.post(
        ApiEndPoints.login,
        data: {
          "username": username,
          "password": password,
          "fcm": fcmToken,
        },
      );

      if (response.data != null) {
        final loginModel = LoginModel.fromJson(response.data);
        if (loginModel.status == true) {
          String token = loginModel.data?.details?.token ?? "";
          if (token.isEmpty && response.data is Map) {
            final d = response.data['data'];
            if (d is Map) {
              token = d['token']?.toString() ?? d['details']?['token']?.toString() ?? "";
            }
          }
          final vendorType = loginModel.data?.details?.vendorType;
          debugPrint("==================================================");
          debugPrint("[REAUTH LOGIN SUCCESS] API Vendor Type: $vendorType");
          debugPrint("==================================================");
          await savename("token", token);
          await savename("loginStatus", loginModel.status?.toString() ?? "false");
          await savename("name", loginModel.data?.details?.name ?? "");
          await savename("roleId", loginModel.data?.details?.roleId ?? 0);
          await savename("vendorType", loginModel.data?.details?.vendorType.toString() ?? "0");
          await savename("vendorId", loginModel.data?.details?.vendorId ?? 0);
          await savename("userId", loginModel.data?.details?.id ?? 0);
          return true;
        }
      }
    } catch (e) {
      print("Reauth error in RetryInterceptor: $e");
    }
    return false;
  }

  Future<void> _logoutAndRedirect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await savename("@isFirstLaunch", "true");
      
      Fluttertoast.showToast(
        msg: "Session expired. Please login again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      print("Logout and redirect error in RetryInterceptor: $e");
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 Unauthorized case
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;
      if (path.contains(ApiEndPoints.login) || path.contains('/login')) {
        // If login request itself returned 401, don't try to auto-authenticate
        return handler.next(err);
      }

      // If the request had no token or an empty token, try attaching the saved token first
      final currentAuth = err.requestOptions.headers["Authorization"]?.toString();
      final savedToken = (await getSavedObject("token"))?.toString();
      if ((currentAuth == null ||
              currentAuth.isEmpty ||
              currentAuth == "Bearer " ||
              currentAuth == "Bearer null") &&
          savedToken != null &&
          savedToken.isNotEmpty &&
          savedToken != "null" &&
          savedToken != "home_cleaning_mock_token") {
        err.requestOptions.headers["Authorization"] = "Bearer $savedToken";
        dio.options.headers["Authorization"] = "Bearer $savedToken";
        try {
          final retryResponse = await _retry(err.requestOptions);
          return handler.resolve(retryResponse!);
        } on DioException catch (retryErr) {
          if (retryErr.response?.statusCode != 401) {
            return handler.next(retryErr);
          }
        }
      }

      final success = await _getReauthFuture();
      if (success) {
        final newToken = await getSavedObject("token");
        dio.options.headers["Authorization"] = "Bearer $newToken";
        err.requestOptions.headers["Authorization"] = "Bearer $newToken";
        try {
          final retryResponse = await _retry(err.requestOptions);
          return handler.resolve(retryResponse!);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      } else {
        await _logoutAndRedirect();
        return handler.next(err);
      }
    }

    // No internet case
    if (err.type == DioExceptionType.unknown ||
        err.type == DioExceptionType.connectionError) {
      if (!await _hasInternet()) {
        // Wait until internet is restored
        await _waitForInternet();
        final retryResponse = await _retry(err.requestOptions);
        return handler.resolve(retryResponse!);
      }
    }

    return handler.next(err);
  }

  Future<void> _waitForInternet() async {
    final completer = Completer<void>();

    final subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.isNotEmpty && result.any((r) => r != ConnectivityResult.none)) {
        completer.complete();
      }
    });

    await completer.future;
    await subscription.cancel();
  }
}
