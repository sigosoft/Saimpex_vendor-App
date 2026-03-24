import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/configs/PusherConfig.dart';
import 'package:saimpex_vendor/controller/home_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/model/conversations_model.dart';
import 'package:saimpex_vendor/model/get_conversation_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/view/notifications/notification.dart';
import 'dart:io';

class ChatController extends GetxController {
  // ----- Pusher -----
  PusherChannelsFlutter? pusher;
  int? currentVendorId;
  int? userId;

  // Callback for UI updates (set by ChatDetails screen)
  VoidCallback? onMessageReceived;

  // ----- Chat history (Pusher-driven list) -----
  List<LastMessage> chatHistoryList = [];

  // ----- Loading states -----
  bool isLoading = false;
  bool isLoadingMessages = false;
  bool isLoadMoreConversations = false;
  bool isLoadMoreMessages = false;

  // ----- Conversations -----
  ConversationsModel? conversationsModel;
  List<Conversation> conversations = [];
  Conversation? currentConversation;

  int _conversationsPage = 1;
  bool _hasNextConversations = true;

  int _messagesPage = 1;
  bool _hasNextMessages = true;

  // ----- Scroll & text controllers -----
  final ScrollController conversationsScrollController = ScrollController();
  final ScrollController messagesScrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController customerSearchController =
      TextEditingController();

  // ----- Search -----
  bool isSendingMessage = false;
  bool isLoadingSearch = false;
  List<Customer> customerResults = [];

  // ====================================================
  //  Lifecycle
  // ====================================================

  @override
  void onInit() {
    super.onInit();
    debugPrint("CHAT CONTROLLER INITIALIZED");
    conversationsScrollController.addListener(_conversationsScrollListener);
    messagesScrollController.addListener(_messagesScrollListener);
    _initializePusher();
    _startSilentRefreshTimer();
  }

  Timer? _refreshTimer;

  void _startSilentRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final context = Get.context;
      if (context != null) {
        getAllConversations(context, quiet: true);
        if (currentConversation != null) {
          _refreshChatHistoryFromAPI();
        }
      }
    });
  }

  @override
  void onClose() {
    conversationsScrollController.dispose();
    messagesScrollController.dispose();
    messageController.dispose();
    customerSearchController.dispose();
    _refreshTimer?.cancel();
    _disposePusher();
    super.onClose();
  }

  // ====================================================
  //  Pusher
  // ====================================================

  Future<void> _disposePusher() async {
    try {
      if (pusher != null) {
        if (userId != null) {
          final channelName = PusherConfig.getNotificationChannel(userId!);
          await pusher!.unsubscribe(channelName: channelName);
        }
        await pusher!.disconnect();
        pusher = null;
      }
    } catch (e) {
      debugPrint("Error disposing Pusher: $e");
    }
  }

  /// Reads the persisted vendor id so Pusher can identify the current user.
  Future<void> _fetchUserId() async {
    try {
      final rawVendorId = await getSavedObject("vendorId");
      if (rawVendorId != null && rawVendorId.toString() != "null") {
        currentVendorId = int.tryParse(rawVendorId.toString());
      }
      final rawUserId = await getSavedObject("userId");
      if (rawUserId != null && rawUserId.toString() != "null") {
        userId = int.tryParse(rawUserId.toString());
      }
      debugPrint("Fetched IDs -> VendorID: $currentVendorId, UserID: $userId");
    } catch (e) {
      debugPrint("_fetchUserId error: $e");
    }
  }

  Future<void> _initializePusher() async {
    try {
      final token = await getSavedObject("token");
      if (token == null ||
          token.toString() == "null" ||
          token.toString().isEmpty) {
        return;
      }

      await _fetchUserId();
      if (userId == null) return;

      // Avoid re-initialising if already up
      if (pusher != null) return;

      pusher = PusherConfig.getInstance();

      await pusher!.init(
        apiKey: PusherConfig.pusherAppKey,
        cluster: PusherConfig.pusherCluster,
        onEvent: _onPusherEvent,
      );

      await pusher!.connect();

      final channelName = PusherConfig.getNotificationChannel(userId ?? 0);
      await pusher!.subscribe(channelName: channelName);

      // Initialize local notifications
      try {
        await FCM().setNotifications();
      } catch (e) {
        debugPrint("Error initializing local notifications: $e");
      }

      debugPrint("✅ Pusher connected and subscribed to: $channelName");
    } catch (e) {
      debugPrint("Error initializing Pusher: $e");
    }
  }

  void _showInAppNotification(Map<String, dynamic> data) async {
    try {
      final String? message = data['message']?.toString();
      final String? senderName =
          data['sender_name']?.toString() ?? "New Message";

      final currentContext = Get.overlayContext ?? Get.context;
      if (currentContext == null) {
        debugPrint("Could not find context for notification overlay");
        return;
      }

      final overlay = Overlay.of(currentContext);
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => _NotificationPill(
          senderName: senderName ?? "",
          message: message ?? "",
          onDismiss: () {
            try {
              overlayEntry.remove();
            } catch (e) {
              debugPrint("Error removing overlay entry: $e");
            }
          },
        ),
      );

      overlay.insert(overlayEntry);

      // System notification as well (Heads-up / Peeking)
      const AndroidNotificationDetails
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'saimpex_chat_heads_up_v1', // New channel ID to ensure high importance
        'Real-time Chat',
        channelDescription: 'Notifications for incoming chat messages',
        importance: Importance.max,
        priority: Priority.max,
        ticker: 'ticker',
        playSound: true,
        enableVibration: true,
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await FCM.flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        senderName,
        message ?? "You have received a new message",
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint("Error showing notification: $e");
    }
  }

  void _onPusherEvent(PusherEvent event) {
    if (event.eventName.startsWith('pusher:')) return;

    debugPrint("========================================");
    debugPrint("📨 PUSHER EVENT RECEIVED");
    debugPrint("Event Name: ${event.eventName}");
    debugPrint("Channel: ${event.channelName}");
    debugPrint("Current Vendor ID: $currentVendorId");
    debugPrint("Event Data: ${event.data}");
    debugPrint("Event Data Type: ${event.data.runtimeType}");
    debugPrint("========================================");

    Map<String, dynamic>? eventDataMap;
    if (event.data is String) {
      try {
        eventDataMap =
            jsonDecode(event.data as String) as Map<String, dynamic>?;
      } catch (e) {
        debugPrint("Error parsing event data as JSON: $e");
      }
    } else if (event.data is Map) {
      eventDataMap = Map<String, dynamic>.from(event.data as Map);
    }

    debugPrint("User ID: ${userId.toString()}");
    if (eventDataMap != null) {
      debugPrint("Receiver ID: ${eventDataMap['receiver_id']?.toString()}");
      debugPrint("Receiver Type: ${eventDataMap['receiver_type']?.toString()}");
    }

    final eventNameLower = event.eventName.toLowerCase();
    final isMessageEvent =
        event.eventName == PusherConfig.newChatMessageEvent ||
        event.eventName == 'message.sent' ||
        eventNameLower.contains('message') ||
        eventNameLower.contains('chat');

    if (isMessageEvent) {
      debugPrint("✅ Message event detected!");
      final context = Get.context;
      final receiverType =
          eventDataMap?['receiver_type']?.toString().toLowerCase() ?? "";
      final receiverId = eventDataMap?['receiver_id']?.toString() ?? "";

      debugPrint(
        "Pusher Data -> Type: $receiverType, ID: $receiverId, VendorID: $currentVendorId, UserID: $userId",
      );

      final bool isForMe =
          receiverId == currentVendorId.toString() ||
          receiverId == userId.toString();

      if (eventDataMap != null &&
          (receiverType.contains("vendor")) &&
          isForMe) {
        // Show local notification
        _showInAppNotification(eventDataMap);

        if (context != null) {
          getAllConversations(context, quiet: true);
          _refreshChatHistoryFromAPI();
        }

        // Refresh bottom nav badge
        try {
          final homeController = Get.find<HomeController>();
          homeController.fetchUnreadChatCount();
        } catch (_) {}
      } else {
        debugPrint("Event ignored: receiver mismatch or missing data");
      }
    } else {
      debugPrint("ℹ️ Event is not a message event: ${event.eventName}");
    }
  }

  // ====================================================
  //  Chat history refresh (Pusher-triggered)
  // ====================================================

  Future<void> _refreshChatHistoryFromAPI() async {
    try {
      if (currentConversation?.id == null) {
        debugPrint("No current conversation – cannot refresh chat history");
        return;
      }
      debugPrint("REFRESHING CHAT HISTORY FROM API");
      final context = Get.context;
      if (context != null) {
        await getConversationDetails(
          context,
          currentConversation!.id!,
          quiet: true,
        );
      }
      debugPrint("✅ Chat history refreshed from API");
      if (onMessageReceived != null) {
        onMessageReceived!();
      }
    } catch (e) {
      debugPrint("❌ Error refreshing chat history: $e");
    }
  }

  // ====================================================
  //  Mark messages as read
  // ====================================================

  Future<void> markAsRead(int conversationId) async {
    try {
      // Immediately zero local unreadCount so tile badge disappears instantly
      final idx = conversations.indexWhere((c) => c.id == conversationId);
      if (idx != -1) {
        conversations[idx].unreadCount = 0;
        update();
      }

      final token = await getSavedObject("token");
      DioClient().updateToken(token);
      await DioClient().post(
        ApiEndPoints.markAsRead,
        body: dio.FormData.fromMap({"conversation_id": conversationId}),
      );

      // Refresh bottom nav badge count
      try {
        final homeController = Get.find<HomeController>();
        homeController.fetchUnreadChatCount();
      } catch (_) {
        // HomeController may not be registered yet — safe to ignore
      }
    } catch (e) {
      debugPrint("markAsRead Error: $e");
    }
  }

  // ====================================================
  //  Customer Search
  // ====================================================

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      customerResults = [];
      update();
      return;
    }

    try {
      isLoadingSearch = true;
      update();

      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.customerSearch,
        query: {"search": query},
      );

      if (response.data != null && response.data['status'] == true) {
        final List data = response.data['data'] is List
            ? response.data['data']
            : (response.data['data']['customers'] ?? []);
        customerResults = data.map((v) => Customer.fromJson(v)).toList();
      }
    } catch (error) {
      debugPrint("searchCustomers Error: $error");
    } finally {
      isLoadingSearch = false;
      update();
    }
  }

  // ====================================================
  //  Send message (text)
  // ====================================================

  Future<void> sendMessage(
    BuildContext context, {
    int? conversationId,
    int? customerId,
  }) async {
    final String messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      isSendingMessage = true;
      update();

      final Map<String, dynamic> body = {
        "message": messageText,
        "message_type": "text",
      };

      if (conversationId != null) {
        body["conversation_id"] = conversationId;
      } else if (customerId != null) {
        body["customer_id"] = customerId;
      }

      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().post(
        ApiEndPoints.sendMessage,
        body: dio.FormData.fromMap(body),
      );

      if (response.data != null && response.data['status'] == true) {
        messageController.clear();

        if (conversationId != null &&
            currentConversation != null &&
            currentConversation!.id == conversationId) {
          final newMessageJson = response.data['data']['message'];
          if (newMessageJson != null) {
            final newMessage = LastMessage.fromJson(newMessageJson);
            currentConversation?.messages?.insert(0, newMessage);
            _sortMessages();
          }
        } else if (customerId != null) {
          final newConversationId = response.data['data']['conversation_id'];
          if (newConversationId != null) {
            getConversationDetails(context, newConversationId);
            getAllConversations(context, quiet: true);
          }
        }
      }
    } catch (error) {
      debugPrint("sendMessage Error: $error");
    } finally {
      isSendingMessage = false;
      update();
    }
  }

  // ====================================================
  //  Send image
  // ====================================================

  Future<void> pickAndSendImage(
    BuildContext context, {
    int? conversationId,
    int? customerId,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        await _sendImage(
          context,
          File(image.path),
          conversationId: conversationId,
          customerId: customerId,
        );
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _sendImage(
    BuildContext context,
    File imageFile, {
    int? conversationId,
    int? customerId,
  }) async {
    try {
      isSendingMessage = true;
      update();

      Map<String, dynamic> body = {
        "image": await dio.MultipartFile.fromFile(imageFile.path),
        "message_type": "image",
      };

      if (conversationId != null && conversationId != 0) {
        body["conversation_id"] = conversationId;
      } else if (customerId != null) {
        body["customer_id"] = customerId;
      }

      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().post(
        ApiEndPoints.sendMessage,
        body: dio.FormData.fromMap(body),
      );

      if (response.data != null && response.data['status'] == true) {
        if (conversationId != null &&
            conversationId != 0 &&
            currentConversation != null &&
            currentConversation!.id == conversationId) {
          final newMessageJson = response.data['data']['message'];
          if (newMessageJson != null) {
            final newMessage = LastMessage.fromJson(newMessageJson);
            currentConversation?.messages?.insert(0, newMessage);
            _sortMessages();
          }
        } else {
          final newConversationId = response.data['data']['conversation_id'];
          if (newConversationId != null) {
            getConversationDetails(context, newConversationId);
            getAllConversations(context, quiet: true);
          }
        }
      }
    } catch (error) {
      debugPrint("_sendImage Error: $error");
      if (context.mounted) {
        showToast(context, "Failed to send image");
      }
    } finally {
      isSendingMessage = false;
      update();
    }
  }

  // ====================================================
  //  Scroll listeners
  // ====================================================

  void _conversationsScrollListener() {
    if (_hasNextConversations &&
        !isLoading &&
        !isLoadMoreConversations &&
        conversationsScrollController.position.pixels >=
            conversationsScrollController.position.maxScrollExtent - 200) {
      loadMoreConversations();
    }
  }

  void _messagesScrollListener() {
    if (_hasNextMessages &&
        !isLoadingMessages &&
        !isLoadMoreMessages &&
        messagesScrollController.position.pixels >=
            messagesScrollController.position.maxScrollExtent - 200) {
      loadMoreMessages();
    }
  }

  // ====================================================
  //  Sorting
  // ====================================================

  void _sortMessages() {
    if (currentConversation?.messages != null) {
      currentConversation!.messages!.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
        DateTime dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA); // Latest first (index 0 is latest)
      });
      chatHistoryList = List<LastMessage>.from(currentConversation!.messages!);
    }
  }

  void _sortConversations() {
    conversations.sort((a, b) {
      String? timeA = a.lastMessageAt ?? a.lastMessage?.createdAt;
      String? timeB = b.lastMessageAt ?? b.lastMessage?.createdAt;
      DateTime dateA = DateTime.tryParse(timeA ?? '') ?? DateTime(0);
      DateTime dateB = DateTime.tryParse(timeB ?? '') ?? DateTime(0);
      return dateB.compareTo(dateA); // Latest first (index 0 is latest)
    });
  }

  // ====================================================
  //  Conversations list
  // ====================================================

  Future<void> getAllConversations(
    BuildContext context, {
    bool quiet = false,
  }) async {
    try {
      if (!quiet) {
        isLoading = true;
        _conversationsPage = 1;
        _hasNextConversations = true;
      }
      // We always fetch page 1 for refreshes
      final fetchPage = 1;
      update();
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.allConversations,
        query: {"page": fetchPage},
      );
      if (response.data != null) {
        conversationsModel = ConversationsModel.fromJson(response.data);
        if (conversationsModel?.status == true) {
          final newConvs = conversationsModel?.data?.conversations ?? [];
          if (quiet) {
            for (var c in newConvs) {
              final idx = conversations.indexWhere(
                (existing) => existing.id == c.id,
              );
              if (idx != -1) {
                conversations[idx] = c; // Update existing
              } else {
                conversations.insert(0, c); // Add new
              }
            }
          } else {
            conversations = newConvs;
          }
          _sortConversations();
          if (conversations.length < 10) {
            _hasNextConversations = false;
          }
        }
      }
    } catch (error) {
      debugPrint("getAllConversations Error: $error");
    } finally {
      if (!quiet) {
        isLoading = false;
      }
      update();
    }
  }

  Future<void> loadMoreConversations() async {
    if (isLoadMoreConversations || !_hasNextConversations) return;
    try {
      isLoadMoreConversations = true;
      update();
      _conversationsPage++;
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.allConversations,
        query: {"page": _conversationsPage},
      );
      if (response.data != null) {
        final newModel = ConversationsModel.fromJson(response.data);
        if (newModel.status == true) {
          final newConversations = newModel.data?.conversations ?? [];
          if (newConversations.isEmpty) {
            _hasNextConversations = false;
          } else {
            for (var conv in newConversations) {
              if (!conversations.any((existing) => existing.id == conv.id)) {
                conversations.add(conv);
              }
            }
            _sortConversations();
          }
        }
      }
    } catch (error) {
      debugPrint("loadMoreConversations Error: $error");
      _hasNextConversations = false;
    } finally {
      isLoadMoreConversations = false;
      update();
    }
  }

  // ====================================================
  //  Conversation detail (messages)
  // ====================================================

  Future<void> getConversationDetails(
    BuildContext context,
    int conversationId, {
    bool quiet = false,
  }) async {
    try {
      if (!quiet) {
        isLoadingMessages = true;
        currentConversation = null;
        _messagesPage = 1;
        _hasNextMessages = true;
      }
      // Always fetch page 1 for refresh
      final fetchPage = 1;
      update();
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.getConversation,
        query: {"conversation_id": conversationId, "page": fetchPage},
      );
      if (response.data != null) {
        final model = GetConversationModel.fromJson(response.data);
        if (model.status == true) {
          final newConvo = model.data?.conversation;
          if (quiet && currentConversation != null && newConvo != null) {
            final newMsgs = newConvo.messages ?? [];
            for (var m in newMsgs) {
              if (!(currentConversation!.messages?.any(
                    (existing) => existing.id == m.id,
                  ) ??
                  false)) {
                currentConversation!.messages!.insert(0, m);
              }
            }
            // Update any other fields
            currentConversation!.lastMessage = newConvo.lastMessage;
            currentConversation!.lastMessageAt = newConvo.lastMessageAt;
            currentConversation!.unreadCount = newConvo.unreadCount;
          } else {
            currentConversation = newConvo;
          }
          _sortMessages();
          if ((currentConversation?.messages?.length ?? 0) < 10) {
            _hasNextMessages = false;
          }
        }
      }
    } catch (error) {
      debugPrint("getConversationDetails Error: $error");
    } finally {
      if (!quiet) {
        isLoadingMessages = false;
      }
      update();
    }
  }

  Future<void> loadMoreMessages() async {
    if (isLoadMoreMessages ||
        !_hasNextMessages ||
        currentConversation == null) {
      return;
    }
    try {
      isLoadMoreMessages = true;
      update();
      _messagesPage++;
      var token = await getSavedObject("token");
      DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.getConversation,
        query: {
          "conversation_id": currentConversation!.id,
          "page": _messagesPage,
        },
      );
      if (response.data != null) {
        final model = GetConversationModel.fromJson(response.data);
        if (model.status == true) {
          final newMessages = model.data?.conversation?.messages ?? [];
          if (newMessages.isEmpty) {
            _hasNextMessages = false;
          } else {
            for (var msg in newMessages) {
              if (!(currentConversation?.messages?.any(
                    (existing) => existing.id == msg.id,
                  ) ??
                  false)) {
                currentConversation?.messages?.add(msg);
              }
            }
            _sortMessages();
          }
        }
      }
    } catch (error) {
      debugPrint("loadMoreMessages Error: $error");
      _hasNextMessages = false;
    } finally {
      isLoadMoreMessages = false;
      update();
    }
  }
}

class _NotificationPill extends StatefulWidget {
  final String senderName;
  final String message;
  final VoidCallback onDismiss;

  const _NotificationPill({
    required this.senderName,
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_NotificationPill> createState() => _NotificationPillState();
}

class _NotificationPillState extends State<_NotificationPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -2.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF1E1E1E,
                ), // Dark background matching image
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'lib/assets/images/logo.png',
                      height: 24,
                      width: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      "${widget.senderName} ${widget.message}",
                      style: GoogleFonts.rubik(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
