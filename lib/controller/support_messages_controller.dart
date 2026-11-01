import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../configs/ApiConfigs.dart';
import '../configs/Dioclient.dart';
import '../utils/utils.dart';

/// Messages from SAIMPEX (Admin) about the vendor's orders, API doc §6.37
/// (task V17): `GET vendorapp/supportMessages` (threads + `unread_total`, or
/// one order's messages) and `POST vendorapp/replySupportMessage`.
class SupportMessagesController extends GetxController {
  bool loadingThreads = false;
  List<Map<String, dynamic>> threads = [];
  int unreadTotal = 0;

  bool loadingMessages = false;
  bool sending = false;
  String? openOrderCode;
  List<Map<String, dynamic>> messages = [];

  Future<void> _auth() async => DioClient().updateToken((await getSavedObject("token"))?.toString() ?? "");

  Future<void> loadThreads() async {
    loadingThreads = true;
    update();
    try {
      await _auth();
      final res = await DioClient().get(ApiEndPoints.supportMessages);
      final data = res.data is Map ? res.data['data'] : null;
      if (data is Map) {
        final list = data['threads'];
        threads = list is List ? list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : [];
        unreadTotal = int.tryParse(data['unread_total']?.toString() ?? '') ?? 0;
      }
    } catch (e) {
      debugPrint('supportMessages: $e');
    } finally {
      loadingThreads = false;
      update();
    }
  }

  /// Loads one order's messages; the backend marks SAIMPEX's as read.
  Future<void> loadMessages(String orderId) async {
    loadingMessages = true;
    update();
    try {
      await _auth();
      final res = await DioClient().get(ApiEndPoints.supportMessages, query: {'order_id': orderId});
      final data = res.data is Map ? res.data['data'] : null;
      if (data is Map) {
        openOrderCode = data['order_code']?.toString();
        final list = data['messages'];
        messages = list is List ? list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : [];
      }
    } catch (e) {
      debugPrint('supportMessages(order): $e');
    } finally {
      loadingMessages = false;
      update();
    }
  }

  /// Returns true when sent; the new message is added to the thread.
  Future<bool> reply(BuildContext context, String orderId, String text) async {
    final message = text.trim();
    if (message.isEmpty || sending) return false;
    sending = true;
    update();
    try {
      await _auth();
      final res = await DioClient().post(
        ApiEndPoints.replySupportMessage,
        body: {'order_id': orderId, 'message': message},
      );
      final data = res.data is Map ? res.data['data'] : null;
      final sent = data is Map ? data['message'] : null;
      if (sent is Map) messages.add(Map<String, dynamic>.from(sent));
      return res.data is Map && res.data['status'] == true;
    } catch (e) {
      if (context.mounted) showToast(context, e.toString());
      return false;
    } finally {
      sending = false;
      update();
    }
  }
}
