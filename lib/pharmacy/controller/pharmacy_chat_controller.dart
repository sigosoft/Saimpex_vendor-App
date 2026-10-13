import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/conversations_model.dart';
import 'package:saimpex_vendor/model/get_conversation_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class PharmacyChatController extends GetxController {
  final searchController = TextEditingController();
  final messageInputController = TextEditingController();
  String query = '';
  bool isSendingMessage = false;
  bool isLoadingConversations = false;
  ConversationsModel? conversationsModel;
  List<Conversation> conversations = [];
  bool isLoadingConversationDetails = false;
  GetConversationModel? currentConversationModel;
  Conversation? currentConversation;
  List<LastMessage> conversationMessages = [];

  void onQueryChanged(String value) {
    query = value;
    update();
  }

  Future<void> getConversationDetails(
    int conversationId, {
    bool quiet = false,
  }) async {
    try {
      if (!quiet) {
        isLoadingConversationDetails = true;
        update();
      }

      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        debugPrint("⚠️ No auth token found. Skipping getConversationDetails.");
      }

      String base = ApiConfigs.BASE_URL.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      final cleanEndpoint = ApiEndPoints.getConversation.replaceFirst(
        RegExp(r'^/'),
        '',
      );
      final fullUrl = cleanEndpoint.startsWith('vendorapp/')
          ? "$base/$cleanEndpoint"
          : "$base/vendorapp/$cleanEndpoint";

      final headers = <String, dynamic>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      final queryParams = <String, dynamic>{"conversation_id": conversationId};

      debugPrint(
        "==================== GET VENDOR CHAT GET CONVERSATION ====================",
      );
      debugPrint("API Call: GET $fullUrl");
      debugPrint("Header: $headers");
      debugPrint("Query Parameters: $queryParams");

      print(
        "==================== GET VENDOR CHAT GET CONVERSATION ====================",
      );
      print("API Call: GET $fullUrl");
      print("Header: $headers");
      print("Query Parameters: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.getConversation,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "==========================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "==========================================================================",
      );

      List<LastMessage> loadedMessages = [];
      if (response.data != null && response.data is Map) {
        final mapData = Map<String, dynamic>.from(response.data as Map);
        currentConversationModel = GetConversationModel.fromJson(mapData);
        final conv = currentConversationModel?.data?.conversation;
        if (conv != null) {
          currentConversation = conv;
          loadedMessages = conv.messages ?? [];
        } else if (mapData['data'] is Map &&
            (mapData['data']['messages'] is List)) {
          loadedMessages = (mapData['data']['messages'] as List)
              .map(
                (e) =>
                    LastMessage.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
        } else if (mapData['messages'] is List) {
          loadedMessages = (mapData['messages'] as List)
              .map(
                (e) =>
                    LastMessage.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
        }
      }
      conversationMessages = loadedMessages;
    } catch (e) {
      debugPrint(
        "==================== GET VENDOR CHAT GET CONVERSATION ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "================================================================================",
      );

      print(
        "==================== GET VENDOR CHAT GET CONVERSATION ERROR ====================",
      );
      print("Error: $e");
      print(
        "================================================================================",
      );
      conversationMessages = [];
    } finally {
      if (!quiet) {
        isLoadingConversationDetails = false;
      }
      update();
    }
  }

  Future<void> fetchConversations({bool quiet = false}) async {
    try {
      if (!quiet) {
        isLoadingConversations = true;
        update();
      }

      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        debugPrint("⚠️ No auth token found. Skipping fetchConversations.");
      }

      String base = ApiConfigs.BASE_URL.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      final cleanEndpoint = ApiEndPoints.allConversations.replaceFirst(
        RegExp(r'^/'),
        '',
      );
      final fullUrl = cleanEndpoint.startsWith('vendorapp/')
          ? "$base/$cleanEndpoint"
          : "$base/vendorapp/$cleanEndpoint";

      final headers = <String, dynamic>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      debugPrint(
        "==================== GET VENDOR CHAT ALL CONVERSATIONS ====================",
      );
      debugPrint("API Call: GET $fullUrl");
      debugPrint("Header: $headers");

      print(
        "==================== GET VENDOR CHAT ALL CONVERSATIONS ====================",
      );
      print("API Call: GET $fullUrl");
      print("Header: $headers");

      final response = await DioClient().get(ApiEndPoints.allConversations);

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "===========================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "===========================================================================",
      );

      List<Conversation> loadedConversations = [];
      if (response.data != null && response.data is Map) {
        final mapData = Map<String, dynamic>.from(response.data as Map);
        if (mapData['data'] is Map &&
            (mapData['data']['conversations'] is List)) {
          conversationsModel = ConversationsModel.fromJson(mapData);
          loadedConversations = conversationsModel?.data?.conversations ?? [];
        } else if (mapData['data'] is List) {
          loadedConversations = (mapData['data'] as List)
              .map(
                (e) =>
                    Conversation.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
        } else if (mapData['conversations'] is List) {
          loadedConversations = (mapData['conversations'] as List)
              .map(
                (e) =>
                    Conversation.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
        }
      }
      conversations = loadedConversations;
    } catch (e) {
      debugPrint(
        "==================== GET VENDOR CHAT ALL CONVERSATIONS ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "================================================================================",
      );

      print(
        "==================== GET VENDOR CHAT ALL CONVERSATIONS ERROR ====================",
      );
      print("Error: $e");
      print(
        "================================================================================",
      );
      conversations = [];
    } finally {
      if (!quiet) {
        isLoadingConversations = false;
      }
      update();
    }
  }

  Future<bool> sendChatMessage({
    required String text,
    int? conversationId,
    int? customerId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    isSendingMessage = true;
    update();

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        debugPrint("⚠️ No auth token found. Skipping sendChatMessage.");
      }

      final convId = (conversationId != null && conversationId > 0)
          ? conversationId.toString()
          : null;
      final custId = (customerId != null && customerId > 0)
          ? customerId.toString()
          : "1";

      final bodyMap = <String, dynamic>{
        if (convId != null) "conversation_id": convId,
        "customer_id": custId,
        "message": trimmed,
        "message_type": "text",
      };

      final formData = dio.FormData.fromMap(bodyMap);

      String base = ApiConfigs.BASE_URL.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      final cleanEndpoint = ApiEndPoints.sendMessage.replaceFirst(
        RegExp(r'^/'),
        '',
      );
      final fullUrl = "$base/$cleanEndpoint";

      final headers = <String, dynamic>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      debugPrint(
        "==================== POST VENDOR CHAT SEND MESSAGE ====================",
      );
      debugPrint("API Call: POST $fullUrl");
      debugPrint("Header: $headers");
      debugPrint("Request Body: $bodyMap");

      print(
        "==================== POST VENDOR CHAT SEND MESSAGE ====================",
      );
      print("API Call: POST $fullUrl");
      print("Header: $headers");
      print("Request Body: $bodyMap");

      final response = await DioClient().post(
        ApiEndPoints.sendMessage,
        body: formData,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "=======================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "=======================================================================",
      );

      if (response.data is Map) {
        final status = response.data['status'];
        if (status == true ||
            status == 1 ||
            status == '1' ||
            status == 'success') {
          return true;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map && response.data['status'] == false) {
          return false;
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint(
        "==================== POST VENDOR CHAT SEND MESSAGE ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "=============================================================================",
      );

      print(
        "==================== POST VENDOR CHAT SEND MESSAGE ERROR ====================",
      );
      print("Error: $e");
      print(
        "=============================================================================",
      );
      return false;
    } finally {
      isSendingMessage = false;
      update();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    messageInputController.dispose();
    super.onClose();
  }
}
