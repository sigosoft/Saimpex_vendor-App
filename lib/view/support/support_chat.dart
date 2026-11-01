import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../controller/support_messages_controller.dart';
import '../../generated/l10n.dart';
import '../../resources/colors.dart';
import '../../utils/vendor_app_router.dart';
import '../../utils/vendor_app_type.dart';
import '../../utils/utils.dart';
import '../home/vendor_order_details.dart';

// One order's messages with SAIMPEX (task V17). No vendor Figma frame; same
// layout as the delivery app's Support Messages (Figma node 10885:12518).
const Color _pageBg = Color(0xffFDF9F0);
const Color _orderBg = Color(0xffFFF1E6);
const Color _inputBg = Color(0xffF3F4F6);
const Color _text = Color(0xff111827);
const Color _muted = Color(0xff6B7280);

class SupportChat extends StatefulWidget {
  const SupportChat({super.key, required this.orderId, this.orderCode});

  final String orderId;
  final String? orderCode;

  /// Opens the thread for [orderId] (from the list or an `admin_message` push).
  static void open(String orderId, {String? orderCode}) =>
      Get.to(() => SupportChat(orderId: orderId, orderCode: orderCode));

  @override
  State<SupportChat> createState() => _SupportChatState();
}

class _SupportChatState extends State<SupportChat> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final SupportMessagesController _c = Get.isRegistered<SupportMessagesController>()
      ? Get.find<SupportMessagesController>()
      : Get.put(SupportMessagesController());

  TextStyle _style(double size, FontWeight weight, Color color) =>
      appFont('Rubik', fontSize: size, fontWeight: weight, color: color);

  /// "Open order" only where an order screen opens from an id alone
  /// (grocery / restaurant / local store); other sections show the code only.
  bool _canOpenOrder = false;

  @override
  void initState() {
    super.initState();
    getSavedObject(VendorAppRouter.storageKey).then((v) {
      final type = VendorAppTypeX.fromStorage(v?.toString());
      if (mounted) setState(() => _canOpenOrder = type == VendorAppType.groceryRestaurant);
    });
    _c.messages = [];
    _c.loadMessages(widget.orderId).then((_) => _toBottom());
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    // The thread is read now; refresh the list badge.
    _c.loadThreads();
    super.dispose();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  String _time(dynamic at) {
    final d = DateTime.tryParse(at?.toString() ?? '')?.toLocal();
    return d == null ? '' : DateFormat('HH:mm', 'en').format(d);
  }

  Future<void> _send() async {
    final ok = await _c.reply(context, widget.orderId, _input.text);
    if (ok) {
      _input.clear();
      _toBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rtl = LocalizationService.currentLanguageCode == 'ar';
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _pageBg,
        body: SafeArea(
          child: GetBuilder<SupportMessagesController>(
            builder: (c) {
              final code = c.openOrderCode ?? widget.orderCode ?? widget.orderId;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          elevation: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => Get.back(),
                            child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, color: colorPrimary)),
                          ),
                        ),
                        Expanded(child: Text(s.saimpexSupport, textAlign: TextAlign.center, style: _style(18, FontWeight.w600, _text))),
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: _orderBg, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(child: Text(s.supportOrderCode(code), style: _style(14, FontWeight.w600, _text))),
                        if (_canOpenOrder)
                        InkWell(
                          onTap: () => Get.to(() => VendorOrderDetails(orderId: widget.orderId)),
                          child: Text(s.openOrder, style: _style(13, FontWeight.w600, colorPrimary)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: c.loadingMessages && c.messages.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: colorPrimary))
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: c.messages.length,
                            itemBuilder: (context, i) => _bubble(context, c.messages[i]),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Container(
                      padding: const EdgeInsetsDirectional.only(start: 14, end: 6),
                      decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _input,
                              minLines: 1,
                              maxLines: 4,
                              maxLength: 2000,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                              style: _style(14, FontWeight.w400, _text),
                              decoration: InputDecoration(
                                hintText: s.replyToSaimpex,
                                hintStyle: _style(14, FontWeight.w400, _muted),
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: c.sending ? null : _send,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: colorPrimary,
                              child: c.sending
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Icon(rtl ? Icons.arrow_back : Icons.send, size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _bubble(BuildContext context, Map<String, dynamic> m) {
    final mine = m['from']?.toString() == 'vendor';
    final time = _time(m['at']);
    final meta = mine ? time : [S.of(context).saimpexSupport, if (time.isNotEmpty) time].join(' • ');
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: mine ? colorPrimary : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m['text']?.toString() ?? '', style: _style(14, FontWeight.w400, mine ? Colors.white : _text)),
            const SizedBox(height: 4),
            Text(meta, style: _style(11, FontWeight.w400, mine ? Colors.white70 : _muted)),
          ],
        ),
      ),
    );
  }
}
