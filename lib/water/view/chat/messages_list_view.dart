import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/chat_controller.dart';
import 'package:saimpex_vendor/model/conversations_model.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/controller/home_controller.dart';
import 'package:saimpex_vendor/water/view/chat/chat_view.dart';

class ChatThread {
  const ChatThread({
    required this.name,
    required this.preview,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.showReadReceipt = false,
    this.previewIsUnread = false,
    this.conversationId,
    this.avatarUrl,
  });

  final String name;
  final String preview;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool showReadReceipt;
  final bool previewIsUnread;
  final int? conversationId;
  final String? avatarUrl;
}

class MessagesListView extends StatefulWidget {
  const MessagesListView({super.key, this.embedded = false});

  /// When true, used as a bottom-nav tab (no own bottom nav / back button).
  final bool embedded;

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MessagesListView(),
      ),
    );
  }

  @override
  State<MessagesListView> createState() => _MessagesListViewState();
}

class _MessagesListViewState extends State<MessagesListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    final controller = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    _isFirstLoad = controller.conversations.isEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<WaterHomeController>()) {
        Get.find<WaterHomeController>().fetchUnreadChatCount();
      }
      controller.getAllConversations(context).then((_) {
        if (mounted) {
          setState(() {
            _isFirstLoad = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ChatThread _threadFromConversation(Conversation conv) {
    final customerName = conv.customer?.name?.trim();
    final name = (customerName != null && customerName.isNotEmpty)
        ? customerName
        : 'Customer';

    String preview = '';
    if (conv.lastMessage != null) {
      if (conv.lastMessage?.messageType == 'image') {
        preview = '📷 Image';
      } else if (conv.lastMessage?.messageType == 'voice') {
        preview = '🎤 Voice message';
      } else {
        preview = conv.lastMessage?.message ?? '';
      }
    }

    final timeStr = conv.lastMessageAt ?? conv.lastMessage?.createdAt;
    final time = _formatChatTime(timeStr);
    final unreadCount = conv.unreadCount ?? 0;
    final isRead =
        conv.lastMessage?.isRead == 1 || conv.lastMessage?.isRead == true;

    String? avatar;
    if (conv.image != null && conv.image!.isNotEmpty) {
      avatar = conv.image!.startsWith('http')
          ? conv.image
          : '${ApiConfigs.IMAGE_URL}${conv.image}';
    } else if (conv.customer?.image != null &&
        conv.customer!.image!.isNotEmpty) {
      avatar = conv.customer!.image!.startsWith('http')
          ? conv.customer!.image
          : '${ApiConfigs.IMAGE_URL}${conv.customer!.image}';
    }

    return ChatThread(
      name: name,
      preview: preview,
      time: time,
      unreadCount: unreadCount,
      isOnline: false,
      showReadReceipt: unreadCount == 0 && isRead,
      previewIsUnread: unreadCount > 0,
      conversationId: conv.id,
      avatarUrl: avatar,
    );
  }

  String _formatChatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      DateTime dt = DateTime.tryParse(timeStr) ?? DateTime.now();
      if (timeStr.contains('-') && !timeStr.contains('T')) {
        try {
          dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timeStr);
        } catch (_) {}
      }
      dt = dt.toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return DateFormat('hh:mm a').format(dt);
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year &&
          dt.month == yesterday.month &&
          dt.day == yesterday.day) {
        return 'Yesterday';
      }
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      init: Get.isRegistered<ChatController>()
          ? Get.find<ChatController>()
          : Get.put(ChatController()),
      builder: (controller) {
        final isLoading = controller.isLoading ||
            (_isFirstLoad && controller.conversations.isEmpty);

        final List<ChatThread> threads = controller.conversations
            .map(_threadFromConversation)
            .where((t) {
              if (_searchQuery.isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return t.name.toLowerCase().contains(q) ||
                  t.preview.toLowerCase().contains(q);
            })
            .toList();

        final body = Column(
          children: [
            SizedBox(
              height: widget.embedded
                  ? MediaQuery.paddingOf(context).top + 8
                  : 8,
            ),
            _Header(
              showBack: !widget.embedded,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    )
                  : threads.isEmpty
                      ? RefreshIndicator(
                          color: AppColors.primaryOrange,
                          onRefresh: () async {
                            if (Get.isRegistered<WaterHomeController>()) {
                              Get.find<WaterHomeController>()
                                  .fetchUnreadChatCount();
                            }
                            await controller.getAllConversations(context);
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.45,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'lib/assets/images/nodata.png',
                                          height: 120,
                                          width: 140,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No messages yet',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Customer messages will appear here',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primaryOrange,
                          onRefresh: () async {
                            if (Get.isRegistered<WaterHomeController>()) {
                              Get.find<WaterHomeController>()
                                  .fetchUnreadChatCount();
                            }
                            await controller.getAllConversations(context);
                          },
                          child: ListView.separated(
                            controller:
                                controller.conversationsScrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            itemCount: threads.length +
                                (controller.isLoadMoreConversations ? 1 : 0),
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              color: AppColors.divider,
                            ),
                            itemBuilder: (context, index) {
                              if (index == threads.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryOrange,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final thread = threads[index];
                              return _ChatListTile(
                                thread: thread,
                                onTap: () async {
                                  if (thread.unreadCount > 0 &&
                                      thread.conversationId != null) {
                                    controller
                                        .markAsRead(thread.conversationId!);
                                    if (Get.isRegistered<WaterHomeController>()) {
                                      Get.find<WaterHomeController>()
                                          .fetchUnreadChatCount();
                                    }
                                  }
                                  await ChatView.open(
                                    context,
                                    customerName: thread.name,
                                    isOnline: thread.isOnline,
                                    conversationId: thread.conversationId,
                                    avatarUrl: thread.avatarUrl,
                                  );
                                  if (Get.isRegistered<WaterHomeController>()) {
                                    Get.find<WaterHomeController>()
                                        .fetchUnreadChatCount();
                                  }
                                },
                              );
                            },
                          ),
                        ),
            ),
            if (!widget.embedded)
              _MessagesBottomNav(
                unreadChatCount: Get.isRegistered<WaterHomeController>()
                    ? Get.find<WaterHomeController>().unreadChatCount
                    : 0,
                onSelect: (index) {
                  if (index == 2) return;
                  Navigator.of(context).maybePop();
                },
              ),
          ],
        );

        if (widget.embedded) {
          return ColoredBox(color: Colors.white, child: body);
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(child: body),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, this.showBack = true});

  final VoidCallback onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'Messages',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.fieldBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.primaryOrange,
                      size: 28,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({this.controller, this.onChanged});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.textMeta,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
              ),
              cursorColor: AppColors.primaryOrange,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'Search customer name or order ID...',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller!.clear();
                onChanged?.call('');
              },
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textMeta,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({
    required this.thread,
    required this.onTap,
  });

  final ChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.avatarPink,
                  backgroundImage: thread.avatarUrl != null &&
                          thread.avatarUrl!.isNotEmpty
                      ? NetworkImage(thread.avatarUrl!)
                      : null,
                  child: thread.avatarUrl != null && thread.avatarUrl!.isNotEmpty
                      ? null
                      : Text(
                          thread.name.isNotEmpty
                              ? thread.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: AppColors.avatarText,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                ),
                if (thread.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.activeGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.name,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: thread.previewIsUnread
                                ? AppColors.textDark
                                : AppColors.textSecondary,
                            fontWeight: thread.previewIsUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (thread.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ] else if (thread.showReadReceipt) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      thread.time,
                      style: const TextStyle(
                        color: AppColors.chatTimeText,
                        fontWeight: FontWeight.w400,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesBottomNav extends StatelessWidget {
  const _MessagesBottomNav({
    required this.onSelect,
    this.unreadChatCount = 0,
  });

  final ValueChanged<int> onSelect;
  final int unreadChatCount;

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Orders', 'Chat', 'Inventory', 'Account'];
    const icons = [
      Icons.home_rounded,
      Icons.assignment_outlined,
      Icons.chat_bubble_outline_rounded,
      Icons.shopping_cart_outlined,
      Icons.person_outline_rounded,
    ];

    return Container(
      color: AppColors.messagesNavBg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(5, (index) {
              final selected = index == 2;
              return Expanded(
                child: InkWell(
                  onTap: () => onSelect(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryOrange
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chat_bubble_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            if (unreadChatCount > 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    unreadChatCount > 99
                                        ? '99+'
                                        : unreadChatCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        )
                      else
                        Icon(
                          icons[index],
                          color: AppColors.navInactive,
                          size: 24,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? AppColors.primaryOrange
                              : AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
