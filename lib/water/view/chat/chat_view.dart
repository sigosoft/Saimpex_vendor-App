import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

enum ChatMessageType { text, audio }

class ChatMessage {
  const ChatMessage({
    required this.type,
    required this.isOutgoing,
    required this.time,
    this.text,
    this.duration,
    this.isRead = false,
  });

  final ChatMessageType type;
  final bool isOutgoing;
  final String time;
  final String? text;
  final String? duration;
  final bool isRead;
}

class ChatView extends StatelessWidget {
  const ChatView({
    super.key,
    this.customerName = 'Ahmed',
    this.isOnline = true,
  });

  final String customerName;
  final bool isOnline;

  static const messages = [
    ChatMessage(
      type: ChatMessageType.text,
      isOutgoing: false,
      time: '12:42 PM',
      text:
          'Hello Ahmed! Your order #22789000 is being ready. Would you like to add anything else?',
    ),
    ChatMessage(
      type: ChatMessageType.audio,
      isOutgoing: true,
      time: '12:44 PM',
      duration: '0:12',
      isRead: true,
    ),
  ];

  static void open(
    BuildContext context, {
    String customerName = 'Ahmed',
    bool isOnline = true,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatView(
          customerName: customerName,
          isOnline: isOnline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.chatBg,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 6),
              _ChatHeader(
                name: customerName,
                isOnline: isOnline,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    const Center(child: _DatePill(label: 'Today')),
                    const SizedBox(height: 18),
                    for (final message in messages) ...[
                      _MessageItem(message: message),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
              const _ChatInputBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.name,
    required this.isOnline,
    required this.onBack,
  });

  final String name;
  final bool isOnline;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryOrange.withValues(alpha: 0.35),
                ),
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
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.avatarPink,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'A',
              style: const TextStyle(
                color: AppColors.avatarText,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chatDatePill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.chatTimeText,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MessageItem extends StatelessWidget {
  const _MessageItem({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final align =
        message.isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        if (message.type == ChatMessageType.text)
          _TextBubble(
            text: message.text ?? '',
            isOutgoing: message.isOutgoing,
          )
        else
          _AudioBubble(duration: message.duration ?? '0:00'),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.time,
              style: const TextStyle(
                color: AppColors.chatTimeText,
                fontWeight: FontWeight.w400,
                fontSize: 11.5,
              ),
            ),
            if (message.isOutgoing) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.done_all_rounded,
                size: 15,
                color: message.isRead
                    ? AppColors.primaryOrange
                    : AppColors.chatTimeText,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TextBubble extends StatelessWidget {
  const _TextBubble({required this.text, required this.isOutgoing});

  final String text;
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: isOutgoing
              ? AppColors.chatBubbleOutgoing
              : AppColors.chatBubbleIncoming,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isOutgoing ? 18 : 6),
            bottomRight: Radius.circular(isOutgoing ? 6 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isOutgoing ? Colors.white : AppColors.textDark,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _AudioBubble extends StatelessWidget {
  const _AudioBubble({required this.duration});

  final String duration;

  static const _heights = [
    8.0, 14.0, 10.0, 18.0, 12.0, 20.0, 9.0, 16.0, 11.0, 19.0,
    13.0, 8.0, 17.0, 12.0, 21.0, 10.0, 15.0, 9.0, 18.0, 11.0,
    16.0, 8.0, 14.0, 12.0, 19.0, 10.0, 15.0, 9.0, 17.0, 11.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.72,
        padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
        decoration: BoxDecoration(
          color: AppColors.chatBubbleOutgoing,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.chatPlayCircle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.primaryOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (final h in _heights)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.8),
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: h,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              duration,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.chatBg,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.chatInputBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: AppColors.textMeta,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Type a message...',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.chatBubbleOutgoing,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_none_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
