import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';

enum MessageType { text, audio }

enum MessageSender { me, customer }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.sender,
    required this.type,
    this.text,
    this.audioDuration,
    required this.time,
    this.isRead = false,
  });

  final String id;
  final MessageSender sender;
  final MessageType type;
  final String? text;
  final String? audioDuration;
  final String time;
  final bool isRead;
}

class HomeCleaningConversationView extends StatefulWidget {
  const HomeCleaningConversationView({
    super.key,
    required this.customerName,
    this.orderId,
    this.avatarAsset = 'lib/water/Assets/Images/delivery_boy1.png',
    this.isOnline = true,
  });

  final String customerName;
  final String? orderId;
  final String avatarAsset;
  final bool isOnline;

  static const _orange = Color(0xFFFF5722);
  static const _ink = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF9E9E9E);
  static const _bgCream = Color(0xFFFDF9F0);

  @override
  State<HomeCleaningConversationView> createState() =>
      _HomeCleaningConversationViewState();
}

class _HomeCleaningConversationViewState
    extends State<HomeCleaningConversationView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isPlayingAudio = false;

  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      ChatMessage(
        id: '1',
        sender: MessageSender.customer,
        type: MessageType.text,
        text:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras elementum gravida ultricies.',
        time: '12:42 PM',
      ),
      ChatMessage(
        id: '2',
        sender: MessageSender.me,
        type: MessageType.audio,
        audioDuration: '0:12',
        time: '12:44 PM',
        isRead: true,
      ),
      ChatMessage(
        id: '3',
        sender: MessageSender.customer,
        type: MessageType.text,
        text:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras elementum gravida ultricies?',
        time: '12:42 PM',
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: MessageSender.me,
          type: MessageType.text,
          text: text,
          time: S.of(context).cleaningJustNow,
          isRead: false,
        ),
      );
    });
    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: HomeCleaningConversationView._bgCream,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: [
                    _buildDatePill(),
                    const SizedBox(height: 16),
                    ..._messages.map(_buildMessageItem),
                  ],
                ),
              ),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.maybePop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE0D0)),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: HomeCleaningConversationView._orange,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFFE0D0),
            backgroundImage: AssetImage(widget.avatarAsset),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.customerName,
                style: GoogleFonts.inter(
                  color: HomeCleaningConversationView._ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.isOnline
                    ? S.of(context).cleaningOnline
                    : S.of(context).cleaningOffline,
                style: GoogleFonts.inter(
                  color: const Color(0xFF757575),
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFEA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          S.of(context).today,
          style: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isMe = message.sender == MessageSender.me;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.type == MessageType.audio)
            _buildAudioBubble(message)
          else
            _buildTextBubble(message, isMe: isMe),
          const SizedBox(height: 4),
          _buildTimestamp(message, isMe: isMe),
        ],
      ),
    );
  }

  Widget _buildTextBubble(ChatMessage message, {required bool isMe}) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.76,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? HomeCleaningConversationView._orange : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.text ?? '',
        style: GoogleFonts.inter(
          color: isMe ? Colors.white : HomeCleaningConversationView._ink,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAudioBubble(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: HomeCleaningConversationView._ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isPlayingAudio = !_isPlayingAudio);
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                _isPlayingAudio
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: HomeCleaningConversationView._orange,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _WaveBar(height: 10),
              _WaveBar(height: 18),
              _WaveBar(height: 8),
              _WaveBar(height: 20),
              _WaveBar(height: 14),
              _WaveBar(height: 22),
              _WaveBar(height: 12),
              _WaveBar(height: 18),
              _WaveBar(height: 22),
              _WaveBar(height: 15),
              _WaveBar(height: 8),
            ],
          ),
          const SizedBox(width: 12),
          Text(
            message.audioDuration ?? '0:12',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(ChatMessage message, {required bool isMe}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.time,
          style: GoogleFonts.inter(
            color: HomeCleaningConversationView._muted,
            fontSize: 10.5,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.done_all_rounded,
            size: 14,
            color: message.isRead
                ? HomeCleaningConversationView._orange
                : HomeCleaningConversationView._muted,
          ),
        ],
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: HomeCleaningConversationView._bgCream,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EFE6),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF555555),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.inter(
                        color: HomeCleaningConversationView._ink,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: S.of(context).typeAMessage,
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: HomeCleaningConversationView._orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: HomeCleaningConversationView._orange
                        .withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveBar extends StatelessWidget {
  const _WaveBar({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2.5,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

