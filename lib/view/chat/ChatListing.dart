import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/view/chat/chat_listing_item.dart';
import '../../controller/chat_controller.dart';
import '../../controller/home_controller.dart';
import '../../generated/l10n.dart';
import 'ChatDetails.dart';

import 'search_customer_dialog.dart';

class ChatListing extends StatelessWidget {
  const ChatListing({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = FlutterLocalization.instance;
    final isRtl = localization.currentLocale?.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GetBuilder<ChatController>(
        init: ChatController(),
        builder: (controller) {
          return CommonBackground(
            appBar: _buildAppBar(context, isRtl, controller),
            child: controller.isLoading
                ? const Center(child: AppLoader())
                : controller.conversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "lib/assets/images/nodata.png",
                          height: MediaQuery.of(context).size.height * 0.25,
                          width: MediaQuery.of(context).size.width * 0.6,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          S.of(context).currentlyNoContactsFoundPleaseTryLater,
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: controller.conversationsScrollController,
                    padding: const EdgeInsets.fromLTRB(10, 15, 10, 30),
                    itemCount:
                        controller.conversations.length +
                        (controller.isLoadMoreConversations ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == controller.conversations.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: AppLoader(),
                          ),
                        );
                      }
                      final chat = controller.conversations[index];
                      // Fallback for time
                      final timeStr =
                          chat.lastMessageAt ?? chat.lastMessage?.createdAt;

                      return ChatListingItem(
                        initials:
                            chat.customer?.name
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            "U",
                        name: chat.customer?.name ?? S.of(context).unknown,
                        phone: chat.customer?.mobile ?? "",
                        avatarUrl: chat.customer?.image != null
                            ? "${ApiConfigs.IMAGE_URL}${chat.customer?.image}"
                            : null,
                        lastMessage: chat.lastMessage?.messageType == 'image'
                            ? "📷 Image"
                            : chat.lastMessage?.messageType == 'voice'
                                ? "🎤 Voice message"
                                : chat.lastMessage?.message ?? "",
                        timestamp: formatChatTime(timeStr),
                        unreadCount: chat.unreadCount ?? 0,
                        onTap: () {
                          // Mark messages as read immediately
                          if ((chat.unreadCount ?? 0) > 0) {
                            controller.markAsRead(chat.id!);
                          }
                          Get.to(
                            ChatDetails(
                              contactName:
                                  chat.customer?.name ?? S.of(context).unknown,
                              conversationId: chat.id ?? 0,
                            ),
                          )?.then((value) {
                            controller.getAllConversations(context);
                          });
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  String formatChatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "";
    try {
      DateTime dt = DateTime.tryParse(timeStr) ?? DateTime.now();
      if (timeStr.contains('-') && !timeStr.contains('T')) {
        try {
          dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timeStr);
        } catch (_) {}
      }
      dt = dt.toLocal();
      DateTime now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return DateFormat('hh:mm a').format(dt);
      } else {
        return DateFormat('dd/MM/yyyy').format(dt);
      }
    } catch (e) {
      return "";
    }
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isRtl,
    ChatController controller,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      forceMaterialTransparency: true,
      elevation: 0,
      leading: IconButton(
        icon: Transform.rotate(
          angle: isRtl ? 3.1416 : 0,
          child: Image.asset(
            'lib/assets/images/back.png',
            height: 35,
            width: 35,
          ),
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.find<HomeController>().onTabTapped(0, context);
          }
        },
      ),
      title: Text(
        S.of(context).chat,
        style: GoogleFonts.rubik(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Material(
            color: colorPrimary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                final chatController = Get.find<ChatController>();
                chatController.customerSearchController.clear();
                chatController.customerResults = [];
                chatController.update();
                Get.dialog(const SearchCustomerDialog());
              },
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
