import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
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

    // Background handler
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) async {
      if (message.data.containsKey('data')) {
        streamCtlr.sink.add(message.data['data']);
      }
      if (message.data.containsKey('notification')) {
        streamCtlr.sink.add(message.data['notification']);
      }

      if (message.notification != null) {
        titleCtlr.sink.add(message.notification!.title ?? "");
        bodyCtlr.sink.add(message.notification!.body ?? "");
        print("Message received foreground: ${message.notification!.title}");
        incrementNotiCount();

        await showNotification(message);
      }
      if (message.data.isNotEmpty) {
        print("Message received data foreground: ${message.data.toString()}");
        await showNotification(message);
      }

      // Store notification data
      await _storeNotificationData(message.data);

      // Check notification type and handle accordingly
      final String? notificationType = message.data['type']?.toString();
      print(
        "Foreground notification type: $notificationType, data empty: ${message.data.isEmpty}",
      );

      if (notificationType == 'order_request' && message.data.isNotEmpty) {
        // Navigate to AcceptOrder screen for order_request type (only if data is not empty)
        await navigateToAcceptOrderIfLoggedIn(notificationData: message.data);
      } else {
        // For other types or when data is empty, refresh Home UI if app is in foreground
        print(
          "Refreshing Home UI - type: $notificationType, data empty: ${message.data.isEmpty}",
        );
        if (notificationType == "other_order_request" ||
            notificationType == "new_order_request") {
          Get.offAll(Home());
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
          final String? notificationType = message.data['type']?.toString();
          if (notificationType == 'order_request') {
            await navigateToAcceptOrderIfLoggedIn(
              notificationData: message.data,
            );
          } else {
            // For other types, just refresh Home UI when app loads
            await refreshHomeUI();
          }
        });
      }
    });

    // Background (app in background but opened by notification)
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print("App opened from background");
      // Cancel any local notifications that might be showing
      await flutterLocalNotificationsPlugin.cancelAll();
      // Check notification type and handle accordingly
      if (message.data.isNotEmpty) {
        final String? notificationType = message.data['type']?.toString();
        print("Background notification type: $notificationType");
        if (notificationType == 'order_request') {
          navigateToAcceptOrderIfLoggedIn(notificationData: message.data);
        } else {
          // For other types, refresh Home UI
          await refreshHomeUI();
        }
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
        //Get.offAll(Home());
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
          Get.offAll(() => Home());
          // Get.offAll(() => AcceptOrder(
          //   orderId: orderData['orderId'],
          //   requestId: orderData['requestId'],
          //   orderNumber: orderData['orderNumber'],
          //   orderDate: orderData['orderDate'],
          //   restaurantName: orderData['restaurantName'],
          //   restaurantAddress: orderData['restaurantAddress'],
          //   restaurantImage: orderData['restaurantImage'],
          //   amount: orderData['amount'],
          //   phoneNumber: orderData['phoneNumber'],
          //   countryCode: orderData['countryCode'],
          //   latitude: orderData['latitude'],
          //   longitude: orderData['longitude'],
          // ));
        }
      });
    } else {
      print("User not logged in, skipping AcceptOrder navigation");
    }
  }

  /// Extract order data from notification payload
  /// Maps various possible key names to standard field names
  static Map<String, String?> _extractOrderData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return {};
    }

    // Helper function to safely get string value from various key names
    String? getValue(List<String> possibleKeys) {
      for (var key in possibleKeys) {
        if (data.containsKey(key) && data[key] != null) {
          return data[key].toString();
        }
      }
      return null;
    }

    // Extract order ID
    final orderId = getValue(['order_id']);

    // Extract request ID
    final requestId = getValue(['request_id']);

    // Extract order number/code
    final orderNumber = getValue(['order_code']);

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
        if (notificationType == 'order_request') {
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
    // Check notification type from data payload
    // Firebase might send data in different formats, so check both payload.data and nested structures
    String? notificationType = payload.data['type']?.toString();

    // If type is not found directly, try nested data structure
    if (notificationType == null || notificationType.isEmpty) {
      if (payload.data.containsKey('data')) {
        final dataValue = payload.data['data'];
        if (dataValue is Map) {
          notificationType = dataValue['type']?.toString();
        } else if (dataValue is String) {
          // Try to parse if it's a JSON string
          try {
            // For now, just log it
            print("Data is string: $dataValue");
          } catch (e) {
            print("Error parsing data string: $e");
          }
        }
      }
    }

    final bool isOrderRequest = notificationType == 'new_order_request';

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
        payload.notification?.title ?? 'New Notification',
        payload.notification?.body ?? '',
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
          payload.notification?.title ?? 'New Notification',
          payload.notification?.body ?? '',
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
