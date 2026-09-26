import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/views/chat/chat_view.dart';

class ChatThread {
  const ChatThread({
    required this.name,
    required this.preview,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.showReadReceipt = false,
    this.previewIsUnread = false,
  });

  final String name;
  final String preview;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool showReadReceipt;
  final bool previewIsUnread;
}

class MessagesListView extends StatelessWidget {
  const MessagesListView({super.key, this.embedded = false});

  /// When true, used as a bottom-nav tab (no own bottom nav / back button).
  final bool embedded;

  static const threads = [
    ChatThread(
      name: 'Ahmed',
      preview: 'Order #22789007 is ready for pickup?',
      time: '12:45 PM',
      unreadCount: 1,
      previewIsUnread: true,
    ),
    ChatThread(
      name: 'Ali Ahmed',
      preview: 'Etiam cursus velit non eros eleifenddic',
      time: 'Just now',
      isOnline: true,
      showReadReceipt: true,
    ),
  ];

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MessagesListView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        SizedBox(height: embedded ? MediaQuery.paddingOf(context).top + 8 : 8),
        _Header(
          showBack: !embedded,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _SearchField(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: threads.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              color: AppColors.divider,
            ),
            itemBuilder: (context, index) {
              final thread = threads[index];
              return _ChatListTile(
                thread: thread,
                onTap: () => ChatView.open(
                  context,
                  customerName: thread.name,
                  isOnline: thread.isOnline,
                ),
              );
            },
          ),
        ),
        if (!embedded)
          _MessagesBottomNav(
            onSelect: (index) {
              if (index == 2) return;
              Navigator.of(context).maybePop();
            },
          ),
      ],
    );

    if (embedded) {
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
  const _SearchField();

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
      child: const Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppColors.textMeta,
            size: 22,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search customer name or order ID...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
              ),
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
                  child: Text(
                    thread.name[0].toUpperCase(),
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
  const _MessagesBottomNav({required this.onSelect});

  final ValueChanged<int> onSelect;

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
