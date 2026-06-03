import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/controller/home_controller.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/controller/order_details_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import '../../Utils/Utils.dart';
import '../Home/Home.dart';

String? deviceToken;

/// Store notification data for later retrieval
Future<void> _storeNotificationData(Map<String, dynamic> data) async {
  try {
    // Store each key-value pair
    for (var entry in data.entries) {
      await savename("noti_data_${entry.key}", entry.value.toString());
    }
    // Mark that we have stored notification data
    await savename("has_noti_data", "1");
  } catch (e) {
    print("Error storing notification data: $e");
  }
}

/// Background handler
Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  await savename("noti_count", "1");
  // Save flag to indicate notification came in background
  await savename("pending_notification", "1");
  // Store notification data for later use
  await _storeNotificationData(message.data);

  if (message.data.containsKey('data')) {
    final data = message.data['data'];
    print("Background data: $data");
  }

  if (message.data.containsKey('notification')) {
    final notification = message.data['notification'];
    print("Background notification: $notification");
  }
}

class FCM {
  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static String cleanOrderNumber(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    var cleaned = raw.trim();
    while (cleaned.startsWith('#')) {
      cleaned = cleaned.substring(1).trim();
    }
    return '#$cleaned';
  }

  static String? extractOrderCodeFromText(String? text) {
    if (text == null || text.isEmpty) return null;
    final regExp = RegExp(r'#?[A-Za-z0-9_-]*\d{3,}');
    final match = regExp.firstMatch(text);
    return match?.group(0);
  }

  static Future<void> syncFcmToken(String token) async {
    try {
      final isLoggedIn = await isUserLoggedIn();
      if (!isLoggedIn) return;
      final savedUsername = await getSavedObject("username");
      final savedPassword = await getSavedObject("password");
      if (savedUsername != null && savedPassword != null) {
        print("Background FCM token sync started...");
        final response = await DioClient().post(
          ApiEndPoints.login,
          body: {
            "username": savedUsername.toString(),
            "password": savedPassword.toString(),
            "fcm": token,
          },
        );
        print("Background FCM token sync completed: ${response.data}");
      }
    } catch (e) {
      print("Background FCM token sync failed: $e");
    }
  }

  static Map<String, dynamic> getEffectiveData(Map<String, dynamic> data) {
    if (data.containsKey('data')) {
      final nested = data['data'];
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      } else if (nested is String) {
        try {
          final decoded = jsonDecode(nested);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
    }
    return data;
  }

  /// Call this in `main()` after Firebase.initializeApp()
  Future<void> setNotifications() async {
    // Init notifications
    await _initLocalNotifications();

    // Request permissions
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    print("iOS Notification permission: ${settings.authorizationStatus}");

    // Get FCM token
    String token = await getDeviceToken();
    print("firebase token $token");
    await savename("fcm", token);
    await syncFcmToken(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("FCM token refreshed: $newToken");
      await savename("fcm", newToken);
      await syncFcmToken(newToken);
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) async {
      final effectiveData = getEffectiveData(message.data);
      final String? notificationType = effectiveData['type']?.toString();
      
      final String title = message.notification?.title ?? '';
      final String body = message.notification?.body ?? '';

      // Diagnostic Toast
      try {
        Fluttertoast.showToast(
          msg: "FCM Received: ${title.isNotEmpty ? title : (notificationType ?? 'Order Notification')}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.black.withOpacity(0.8),
          textColor: Colors.white,
        );
      } catch (e) {
        print("Diagnostic Toast Error: $e");
      }

      final orderData = _extractOrderData(message.data, notificationBody: body);
      final String? orderId = orderData['orderId'];
      final String? orderNumber = orderData['orderNumber'];
      final bool hasOrderInfo = (orderId != null && orderId.isNotEmpty) || (orderNumber != null && orderNumber.isNotEmpty);

      final bool isOrderRequestType = notificationType == 'order_request' || 
                                       notificationType == 'new_order_request' || 
                                       notificationType == 'other_order_request' ||
                                       hasOrderInfo ||
                                       title.toLowerCase().contains('order') ||
                                       body.toLowerCase().contains('order');

      if (message.data.containsKey('data')) {
        streamCtlr.sink.add(message.data['data'].toString());
      }
      if (message.data.containsKey('notification')) {
        streamCtlr.sink.add(message.data['notification'].toString());
      }

      try {
        if (message.notification != null) {
          titleCtlr.sink.add(message.notification!.title ?? "");
          bodyCtlr.sink.add(message.notification!.body ?? "");
          print("Message received foreground: ${message.notification!.title}");
          incrementNotiCount();

          await showNotification(message);
        } else if (message.data.isNotEmpty) {
          print("Message received data foreground: ${message.data.toString()}");
          await showNotification(message);
        }
      } catch (e) {
        print("Error presenting notification: $e");
      }

      // Store notification data
      await _storeNotificationData(message.data);

      print(
        "Foreground notification type: $notificationType, data empty: ${message.data.isEmpty}",
      );

      if (isOrderRequestType) {
        // Refresh Home UI & Show In-App Dialog Alert in real-time
        await refreshHomeUI();
        showInAppNewOrderAlert(message.data, notificationBody: body);
      } else {
        // For other types, refresh Home UI if app is in foreground
        print(
          "Refreshing Home UI - type: $notificationType",
        );
        if (notificationType == "other_order_request" ||
            notificationType == "new_order_request") {
          await refreshHomeUI();
        }
      }
    });

    // Terminated state - Check if app was opened from notification
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null && message.data.isNotEmpty) {
        print("App opened from terminated state");
        await savename("pending_notification", "1");
        // Store notification data for later use
        await _storeNotificationData(message.data);
        // Cancel any local notifications that might be showing
        await flutterLocalNotificationsPlugin.cancelAll();
        // Wait for app to be fully initialized before navigating
        Future.delayed(const Duration(milliseconds: 1000), () async {
          // Navigate and parse order data if present, regardless of type
          await navigateToAcceptOrderIfLoggedIn(notificationData: message.data);
        });
      }
    });

    // Background (app in background but opened by notification)
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print("App opened from background");
      // Cancel any local notifications that might be showing
      await flutterLocalNotificationsPlugin.cancelAll();
      // Navigate and parse order data if present, regardless of type
      if (message.data.isNotEmpty) {
        navigateToAcceptOrderIfLoggedIn(notificationData: message.data);
      }
    });
  }

  /// Initialize Local Notifications (Android + iOS)
  Future<void> _initLocalNotifications() async {
    // Handle notification tap when app is opened from notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Delete existing channel if it exists (Android 8.0+ channels are immutable)
    // This ensures the channel is recreated with the correct sound settings
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      try {
        await androidImplementation.deleteNotificationChannel(
          'default_channel_id',
        );
        // Wait a bit to ensure channel is fully deleted before recreating
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print("Error deleting notification channel: $e");
      }
    }

    // Create Android notification channel with custom sound for order_request
    const AndroidNotificationChannel orderRequestChannel =
        AndroidNotificationChannel(
          'default_channel_id',
          'default_channel',
          description: 'Default notification channel',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('notification_ring'),
          enableLights: true,
        );

    // Create a separate channel for default sounds (non-order_request notifications)
    const AndroidNotificationChannel defaultSoundChannel =
        AndroidNotificationChannel(
          'default_sound_channel_id',
          'default_sound_channel',
          description: 'Default sound notification channel',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          // No custom sound - will use default system sound
          enableLights: true,
        );

    try {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        // Delete default sound channel if exists
        try {
          await androidImplementation.deleteNotificationChannel(
            'default_sound_channel_id',
          );
          await Future.delayed(const Duration(milliseconds: 50));
        } catch (e) {
          // Ignore if channel doesn't exist
        }

        // Create both channels
        await androidImplementation.createNotificationChannel(
          orderRequestChannel,
        );
        await androidImplementation.createNotificationChannel(
          defaultSoundChannel,
        );
        print(
          "Notification channels created: order_request (custom sound) and default (system sound)",
        );
      }
    } catch (e) {
      print("Error creating notification channels: $e");
    }

    // Important for iOS: show notifications in foreground
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final loginStatus = await getSavedObject("loginStatus");
    final token = await getSavedObject("token");
    return loginStatus == "true" &&
        token != null &&
        token.toString().isNotEmpty;
  }

  /// Refresh Home UI by updating HomeController
  static Future<void> refreshHomeUI() async {
    print("=== refreshHomeUI called ===");
    try {
      final isLoggedIn = await isUserLoggedIn();
      print("User logged in: $isLoggedIn");
      print("Get.context is null: ${Get.context == null}");

      if (!isLoggedIn) {
        print("User not logged in, skipping Home refresh");
        return;
      }

      // Try to find and update HomeController if it exists
      try {
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          homeController.triggerFullRefresh();
          if (Get.context != null) {
            await homeController.refreshHomeData(Get.context!);
          }
        }
      } catch (e) {
        print("Error refreshing Home UI: $e");
        print("Stack trace: ${StackTrace.current}");
      }
    } catch (e) {
      print("Error in refreshHomeUI: $e");
      print("Stack trace: ${StackTrace.current}");
    }
    print("=== refreshHomeUI completed ===");
  }

  /// Navigate to AcceptOrder only if user is logged in and notification data is not empty
  static Future<void> navigateToAcceptOrderIfLoggedIn({
    Map<String, dynamic>? notificationData,
  }) async {
    // Check if notification data is empty or null
    if (notificationData == null || notificationData.isEmpty) {
      print("Notification data is empty, skipping AcceptOrder navigation");
      return;
    }

    // Cancel any active notifications when navigating
    // await flutterLocalNotificationsPlugin.cancelAll();

    final isLoggedIn = await isUserLoggedIn();
    if (isLoggedIn) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.context != null) {
          // Extract and map notification data
          final orderData = _extractOrderData(notificationData);
          final statusIdStr = orderData['statusId'];
          String targetTab = "Pending";
          if (statusIdStr != null) {
            final statusId = int.tryParse(statusIdStr);
            if (statusId == 2)
              targetTab = "Accepted";
            else if (statusId == 3)
              targetTab = "Preparing";
            else if (statusId == 4)
              targetTab = "Ready";
            else if (statusId == 8)
              targetTab = "On Going";
            else if (statusId == 9)
              targetTab = "Delivered";
            else if (statusId == 10)
              targetTab = "Cancelled";
          }

          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().targetOrderStatusTab = targetTab;
          } else {
            Get.put(HomeController()).targetOrderStatusTab = targetTab;
          }
          Get.offAll(() => Home());
        }
      });
    } else {
      print("User not logged in, skipping AcceptOrder navigation");
    }
  }

  /// Extract order data from notification payload
  /// Maps various possible key names to standard field names
  static Map<String, String?> _extractOrderData(Map<String, dynamic>? data, {String? notificationBody}) {
    if (data == null || data.isEmpty) {
      if (notificationBody != null && notificationBody.isNotEmpty) {
        final orderNumber = extractOrderCodeFromText(notificationBody);
        if (orderNumber != null) {
          return {'orderNumber': orderNumber};
        }
      }
      return {};
    }

    final effectiveData = getEffectiveData(data);

    // Helper function to safely get string value from various key names
    String? getValue(List<String> possibleKeys) {
      for (var key in possibleKeys) {
        if (effectiveData.containsKey(key) && effectiveData[key] != null) {
          return effectiveData[key].toString();
        }
      }
      return null;
    }

    // Extract order ID
    final orderId = getValue(['order_id']);

    // Extract request ID
    final requestId = getValue(['request_id']);

    // Extract order number/code
    var orderNumber = getValue(['order_code', 'order_number', 'order_id']);
    if (orderNumber == null || orderNumber.isEmpty) {
      orderNumber = extractOrderCodeFromText(notificationBody);
    }

    // Extract order date
    final orderDate = getValue(['order_created_at_formatted']);

    // Extract restaurant/vendor name
    final restaurantName = getValue(['vendor_name']);

    // Extract restaurant/vendor address
    final restaurantAddress = getValue(['vendor_address']);

    // Extract restaurant/vendor image
    final restaurantImage = getValue(['vendor_image']);

    // Extract amount
    String? amount = getValue(['total_delivery_amount']);
    // Add currency if amount exists and doesn't already have it
    if (amount != null &&
        amount.isNotEmpty &&
        !amount.toUpperCase().contains('MRU')) {
      amount = '$amount MRU';
    }

    // Extract phone number
    final phoneNumber = getValue(['vendor_mobile']);

    // Extract country code
    final countryCode = getValue(['vendor_country_code']);

    // Extract latitude
    final latitude = getValue(['vendor_latitude']);

    // Extract longitude
    final longitude = getValue(['vendor_longitude']);

    // Extract order status
    final statusId = getValue(['order_status', 'status']);

    return {
      'orderId': orderId,
      'requestId': requestId,
      'orderNumber': orderNumber,
      'orderDate': orderDate,
      'restaurantName': restaurantName,
      'restaurantAddress': restaurantAddress,
      'restaurantImage': restaurantImage,
      'amount': amount,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
      'statusId': statusId,
    };
  }

  /// Handle local notification tap
  static void _onNotificationTap(NotificationResponse response) {
    print("Local notification tapped: ${response.payload}");

    // Cancel/dismiss the notification from the phone's notification tray
    if (response.id != null) {
      flutterLocalNotificationsPlugin.cancel(response.id!);
    } else {
      // If ID is null, cancel all notifications (fallback)
      flutterLocalNotificationsPlugin.cancelAll();
    }

    // Navigate to AcceptOrder when local notification is tapped (only if logged in)
    // Note: payload might contain JSON string, parse it if needed
    Map<String, dynamic>? notificationData;
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        // If payload is JSON string, parse it
        notificationData = <String, dynamic>{};
        // For now, we'll try to get data from stored notification if available
        // In a real scenario, you might want to store the last notification data
      } catch (e) {
        print("Error parsing notification payload: $e");
      }
    }
    navigateToAcceptOrderIfLoggedIn(notificationData: notificationData);
  }

  /// Retrieve stored notification data
  static Future<Map<String, dynamic>?> _getStoredNotificationData() async {
    try {
      final hasData = await getSavedObject("has_noti_data");
      if (hasData != "1") {
        return null;
      }

      // Common notification data keys to retrieve
      final keys = [
        'type', // Include type key for notification handling
        'order_id', 'request_id',
        'order_code',
        'order_created_at_formatted',
        'vendor_name',
        'vendor_address',
        'vendor_image',
        'total_delivery_amount',
        'vendor_mobile',
        'vendor_country_code',
        'vendor_latitude',
        'vendor_longitude',
      ];

      Map<String, dynamic> storedData = {};
      for (var key in keys) {
        final value = await getSavedObject("noti_data_$key");
        if (value != null && value.toString().isNotEmpty) {
          storedData[key] = value;
        }
      }

      // Clear stored data after retrieval
      await savename("has_noti_data", "0");
      for (var key in keys) {
        await savename("noti_data_$key", "");
      }

      return storedData.isNotEmpty ? storedData : null;
    } catch (e) {
      print("Error retrieving stored notification data: $e");
      return null;
    }
  }

  /// Show in-app alert dialog for a new order request when app is in foreground
  static void showInAppNewOrderAlert(Map<String, dynamic> notificationData, {String? notificationBody}) {
    if (Get.context == null) return;

    final orderData = _extractOrderData(notificationData, notificationBody: notificationBody);
    final orderNumber = orderData['orderNumber'] ?? orderData['orderId'] ?? '';
    final formattedOrderNumber = orderNumber.isNotEmpty ? cleanOrderNumber(orderNumber) : 'New';
    final amount = orderData['amount'] ?? '';

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      color: Colors.red,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "A new order!",
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "New order received: $formattedOrderNumber",
                  style: GoogleFonts.rubik(fontSize: 15, color: Colors.black87),
                ),
                if (amount.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Total Amount: $amount",
                    style: GoogleFonts.rubik(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Dismiss",
                        style: GoogleFonts.rubik(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigate to AcceptOrder / Home Pending tab
                        navigateToAcceptOrderIfLoggedIn(
                          notificationData: notificationData,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        "View Order",
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Check for pending notification and navigate if needed
  /// Call this method from Home screen or after app is fully loaded
  static Future<void> checkPendingNotification() async {
    final pendingNoti = await getSavedObject("pending_notification");
    if (pendingNoti == "1") {
      await savename("pending_notification", "0");
      // Try to get stored notification data if available
      final storedData = await _getStoredNotificationData();
      if (storedData != null && storedData.isNotEmpty) {
        final String? notificationType = storedData['type']?.toString();
        final bool isOrderRequestType =
            notificationType == 'order_request' ||
            notificationType == 'new_order_request' ||
            notificationType == 'other_order_request';
        if (isOrderRequestType) {
          await navigateToAcceptOrderIfLoggedIn(notificationData: storedData);
        } else {
          // For other types, refresh Home UI
          await refreshHomeUI();
        }
      }
    }
  }

  /// Get FCM Token
  Future<String> getDeviceToken() async {
    try {
      FirebaseMessaging firebaseMessage = FirebaseMessaging.instance;
      deviceToken = await firebaseMessage.getToken();
      return (deviceToken == null) ? "" : deviceToken!;
    } catch (e) {
      print("Error getting device token: $e");
      return "";
    }
  }

  /// Show notification on both Android & iOS
  static Future<void> showNotification(RemoteMessage payload) async {
    final effectiveData = getEffectiveData(payload.data);
    String? notificationType = effectiveData['type']?.toString();

    String title = payload.notification?.title ?? 'New Notification';
    String body = payload.notification?.body ?? '';

    final orderData = _extractOrderData(payload.data, notificationBody: body);
    final String? orderId = orderData['orderId'];
    final String? orderNumberVal = orderData['orderNumber'];
    final bool hasOrderInfo = (orderId != null && orderId.isNotEmpty) || (orderNumberVal != null && orderNumberVal.isNotEmpty);

    final bool isOrderRequest = notificationType == 'new_order_request' ||
        notificationType == 'order_request' ||
        notificationType == 'other_order_request' ||
        hasOrderInfo ||
        title.toLowerCase().contains('order') ||
        body.toLowerCase().contains('order');

    if (isOrderRequest) {
      var orderNumber = orderNumberVal ?? orderId ?? '';
      title = "A new order!";
      if (orderNumber.isNotEmpty) {
        final formattedOrderNumber = cleanOrderNumber(orderNumber);
        body = "New order received: $formattedOrderNumber";
      } else {
        body = "New order received";
      }
    }

    print("=== Notification Debug ===");
    print("Full payload.data: ${payload.data}");
    print("Notification type found: $notificationType");
    print("isOrderRequest: $isOrderRequest");
    print("=========================");

    // Use custom sound only if type is 'order_request'
    AndroidNotificationDetails androidDetails;
    DarwinNotificationDetails iOSDetails;

    if (isOrderRequest) {
      // Use custom notification_ring sound only for order_request type
      androidDetails = AndroidNotificationDetails(
        'default_channel_id', // Channel with custom sound
        'default_channel',
        channelDescription: 'Default notification channel',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
        enableVibration: true,
        sound: const RawResourceAndroidNotificationSound('notification_ring'),
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
      );

      iOSDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_ring.caf',
      );
    } else {
      // Use default system sound channel for all other types (or when data is empty)
      androidDetails = AndroidNotificationDetails(
        'default_sound_channel_id', // Separate channel without custom sound
        'default_sound_channel',
        channelDescription: 'Default sound notification channel',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
        enableVibration: true,
        // No custom sound - will use default system sound from channel
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
      );

      iOSDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        // No custom sound - will use default system sound
      );
    }

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
      );
      if (isOrderRequest) {
        print(
          "✓ Foreground notification shown with CUSTOM sound (notification_ring) - type: $notificationType",
        );
      } else {
        print(
          "✓ Foreground notification shown with DEFAULT system sound - type: ${notificationType ?? 'null'}",
        );
      }
    } catch (e) {
      print("Error showing notification: $e");
      // Fallback: use default system sound
      try {
        final AndroidNotificationDetails fallbackAndroidDetails =
            AndroidNotificationDetails(
              'default_channel_id',
              'default_channel',
              channelDescription: 'Default notification channel',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              // No custom sound - will use default system sound
            );

        const DarwinNotificationDetails fallbackIOSDetails =
            DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              // No custom sound - will use default system sound
            );

        final NotificationDetails fallbackDetails = NotificationDetails(
          android: fallbackAndroidDetails,
          iOS: fallbackIOSDetails,
        );

        await flutterLocalNotificationsPlugin.show(
          0,
          title,
          body,
          fallbackDetails,
        );
        print(
          "Foreground notification shown with default system sound (fallback)",
        );
      } catch (fallbackError) {
        print("Error showing notification with fallback: $fallbackError");
      }
    }
  }

  void dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }

  void incrementNotiCount() async {
    await savename("noti_count", "1");
  }
}
