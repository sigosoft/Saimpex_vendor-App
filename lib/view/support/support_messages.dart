import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';

import '../../controller/support_messages_controller.dart';
import '../../generated/l10n.dart';
import '../../resources/colors.dart';
import 'support_chat.dart';

// List of order threads with SAIMPEX (task V17, all vendor types). No Figma
// frame for the vendor app; built in the style of the delivery app's
// support messages (Figma node 10885:12518).
const Color _pageBg = Color(0xffFDF9F0);
const Color _cardBorder = Color(0xffF0ECE4);
const Color _text = Color(0xff111827);
const Color _muted = Color(0xff6B7280);

class SupportMessages extends StatelessWidget {
  const SupportMessages({super.key});

  TextStyle _style(double size, FontWeight weight, Color color) =>
      appFont('Rubik', fontSize: size, fontWeight: weight, color: color);

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
            init: Get.isRegistered<SupportMessagesController>() ? Get.find<SupportMessagesController>() : SupportMessagesController(),
            initState: (_) => Get.find<SupportMessagesController>().loadThreads(),
            builder: (c) => Column(
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
                      Expanded(child: Text(s.supportMessages, textAlign: TextAlign.center, style: _style(18, FontWeight.w600, _text))),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: colorPrimary,
                    onRefresh: c.loadThreads,
                    child: c.loadingThreads && c.threads.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: colorPrimary))
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              if (c.threads.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 80),
                                  child: Text(s.noSupportMessages, textAlign: TextAlign.center, style: _style(15, FontWeight.w400, _muted)),
                                ),
                              for (final t in c.threads) ...[
                                _thread(context, t),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thread(BuildContext context, Map<String, dynamic> t) {
    final unread = int.tryParse(t['unread']?.toString() ?? '') ?? 0;
    final last = t['last_message'];
    final text = last is Map ? (last['text'] ?? '').toString() : (last ?? '').toString();
    final code = (t['order_code'] ?? t['order_id']).toString();
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => SupportChat.open(t['order_id'].toString(), orderCode: code),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 18, backgroundColor: Color(0xffFFF7ED), child: Icon(Icons.support_agent, size: 18, color: colorPrimary)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).supportOrderCode(code), style: _style(14, FontWeight.w600, _text)),
                  if (text.isNotEmpty)
                    Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: _style(12, FontWeight.w400, _muted)),
                ],
              ),
            ),
            if (unread > 0)
              CircleAvatar(radius: 11, backgroundColor: colorPrimary, child: Text('$unread', style: _style(11, FontWeight.w700, Colors.white))),
          ],
        ),
      ),
    );
  }
}
