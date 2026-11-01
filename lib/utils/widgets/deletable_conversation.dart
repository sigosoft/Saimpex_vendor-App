import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/model/conversations_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// "Booking #code · last message" when the chat is about a booking
/// (`order_code`, API doc §6.43).
String conversationPreview(BuildContext context, Conversation conv, String preview) {
  final code = conv.orderCode?.trim() ?? '';
  if (code.isEmpty || code == 'null') return preview;
  return preview.isEmpty ? S.of(context).bookingHash(code) : '${S.of(context).bookingHash(code)} · $preview';
}

/// Swipe a conversation away to delete it for the vendor (API doc §6.43,
/// task V18): `POST vendorapp/chat/deleteConversation`. It comes back when
/// the customer writes again. Asks first; [onDeleted] refreshes the list.
class DeletableConversation extends StatelessWidget {
  const DeletableConversation({super.key, required this.conversationId, required this.onDeleted, required this.child});

  final int? conversationId;
  final VoidCallback onDeleted;
  final Widget child;

  Future<bool> _confirmAndDelete(BuildContext context) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteConversationTitle),
        content: Text(s.deleteConversationBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(s.cancel)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.delete, style: const TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
    if (ok != true) return false;
    try {
      final token = (await getSavedObject('token'))?.toString() ?? '';
      if (token.isNotEmpty) DioClient().updateToken(token);
      final res = await DioClient().post(ApiEndPoints.deleteConversation, body: {'conversation_id': conversationId});
      final done = res.data is Map && res.data['status'] == true;
      if (!done) Fluttertoast.showToast(msg: s.somethingWentWrong);
      return done;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (conversationId == null) return child;
    return Dismissible(
      key: ValueKey('conversation-$conversationId'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmAndDelete(context),
      onDismissed: (_) => onDeleted(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: const Color(0xFFFFEBEE),
        child: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
      ),
      child: child,
    );
  }
}
