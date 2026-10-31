import 'package:saimpex_vendor/generated/l10n.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/chat_controller.dart';
import 'package:saimpex_vendor/model/conversations_model.dart';
import 'package:saimpex_vendor/model/get_conversation_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

enum ChatMessageType { text, audio, image }

class ChatMessage {
  const ChatMessage({
    required this.type,
    required this.isOutgoing,
    required this.time,
    this.text,
    this.duration,
    this.attachmentUrl,
    this.createdAt,
    this.isRead = false,
  });

  final ChatMessageType type;
  final bool isOutgoing;
  final String time;
  final String? text;
  final String? duration;
  final String? attachmentUrl;
  final String? createdAt;
  final bool isRead;
}

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    this.customerName = '',
    this.isOnline = true,
    this.conversationId,
    this.customerId,
    this.orderId,
    this.avatarUrl,
  });

  final String customerName;
  final bool isOnline;
  final int? conversationId;
  final int? customerId;
  final dynamic orderId;
  final String? avatarUrl;

  static Future<void> open(
    BuildContext context, {
    String customerName = '',
    bool isOnline = true,
    int? conversationId,
    int? customerId,
    dynamic orderId,
    String? avatarUrl,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatView(
          customerName: customerName,
          isOnline: isOnline,
          conversationId: conversationId,
          customerId: customerId,
          orderId: orderId,
          avatarUrl: avatarUrl,
        ),
      ),
    );
  }

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  int? _activeConversationId;
  String _displayName = '';
  String? _avatarUrl;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    _displayName = widget.customerName.trim().isNotEmpty
        ? widget.customerName.trim()
        : '';
    if (widget.avatarUrl != null && widget.avatarUrl!.trim().isNotEmpty) {
      _avatarUrl = _formatImageUrl(widget.avatarUrl!);
    }
    _fetchConversation();
  }

  @override
  void dispose() {
    if (Get.isRegistered<ChatController>()) {
      final chatCtrl = Get.find<ChatController>();
      if (chatCtrl.isRecording) {
        chatCtrl.cancelRecording();
      }
    }
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchConversation({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      }

      final chatCtrl = Get.isRegistered<ChatController>()
          ? Get.find<ChatController>()
          : Get.put(ChatController());

      // If active conversation ID is not known, lookup by customerId or customerName
      if (_activeConversationId == null || _activeConversationId! <= 0) {
        if (chatCtrl.conversations.isEmpty) {
          try {
            await chatCtrl.getAllConversations(context, quiet: true);
          } catch (_) {}
        }

        if (widget.customerId != null && widget.customerId! > 0) {
          for (final c in chatCtrl.conversations) {
            if (c.customerId == widget.customerId ||
                c.customer?.id == widget.customerId) {
              if (c.id != null && c.id! > 0) {
                _activeConversationId = c.id;
              }
              final cImg = c.customer?.image?.trim() ?? c.image?.trim();
              if (cImg != null && cImg.isNotEmpty && cImg != 'null') {
                _avatarUrl ??= _formatImageUrl(cImg);
              }
              break;
            }
          }
        }

        if ((_activeConversationId == null || _activeConversationId! <= 0) &&
            _displayName.isNotEmpty &&
            _displayName.toLowerCase() != 'customer') {
          for (final c in chatCtrl.conversations) {
            final cName = c.customer?.name?.trim();
            if (cName != null &&
                cName.toLowerCase() == _displayName.toLowerCase()) {
              if (c.id != null && c.id! > 0) {
                _activeConversationId = c.id;
                break;
              }
            }
          }
        }
      }

      // If we have an active conversation ID, call getConversation API
      if (_activeConversationId != null && _activeConversationId! > 0) {
        final queryParams = <String, dynamic>{
          'conversation_id': _activeConversationId,
          'page': 1,
        };

        debugPrint(
          "==================== GET VENDOR CHAT GET CONVERSATION ====================",
        );
        debugPrint("Endpoint: ${ApiEndPoints.getConversation}");
        debugPrint("Query: $queryParams");
        print(
          "==================== GET VENDOR CHAT GET CONVERSATION ====================",
        );
        print("Endpoint: ${ApiEndPoints.getConversation}");
        print("Query: $queryParams");

        final response = await DioClient().get(
          ApiEndPoints.getConversation,
          query: queryParams,
        );

        debugPrint("Response Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.data}");
        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.data}");

        Map<String, dynamic>? rawData;
        if (response.data is Map<String, dynamic>) {
          rawData = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          rawData = Map<String, dynamic>.from(response.data as Map);
        } else if (response.data is String) {
          try {
            final decoded = jsonDecode(response.data as String);
            if (decoded is Map) rawData = Map<String, dynamic>.from(decoded);
          } catch (_) {}
        }

        if (rawData != null) {
          final model = GetConversationModel.fromJson(rawData);
          if (model.status == true && model.data?.conversation != null) {
            final convo = model.data!.conversation!;
            chatCtrl.currentConversation = convo;

            final customerName = convo.customer?.name?.trim();
            if (customerName != null && customerName.isNotEmpty) {
              _displayName = customerName;
            }

            final rawConvoMap =
                (rawData['data'] is Map &&
                    rawData['data']['conversation'] is Map)
                ? rawData['data']['conversation'] as Map
                : null;
            final rawCustomerMap =
                (rawConvoMap != null && rawConvoMap['customer'] is Map)
                ? rawConvoMap['customer'] as Map
                : null;
            final rawUserMap =
                (rawConvoMap != null && rawConvoMap['user'] is Map)
                ? rawConvoMap['user'] as Map
                : null;

            final imgCandidate =
                convo.customer?.image?.trim() ??
                convo.image?.trim() ??
                rawCustomerMap?['image']?.toString().trim() ??
                rawCustomerMap?['avatar']?.toString().trim() ??
                rawCustomerMap?['profile_image']?.toString().trim() ??
                rawCustomerMap?['profile_pic']?.toString().trim() ??
                rawUserMap?['image']?.toString().trim() ??
                rawUserMap?['avatar']?.toString().trim() ??
                rawConvoMap?['image']?.toString().trim() ??
                rawConvoMap?['customer_image']?.toString().trim() ??
                rawConvoMap?['avatar']?.toString().trim();

            if (imgCandidate != null &&
                imgCandidate.isNotEmpty &&
                imgCandidate != 'null') {
              _avatarUrl = _formatImageUrl(imgCandidate);
            }

            final rawList = convo.messages ?? [];
            final converted = rawList.map(_convertLastMessage).toList();
            // Sort chronologically (oldest first so newest is at the bottom)
            converted.sort((a, b) {
              final dA = a.createdAt != null
                  ? DateTime.tryParse(a.createdAt!) ?? DateTime(0)
                  : DateTime(0);
              final dB = b.createdAt != null
                  ? DateTime.tryParse(b.createdAt!) ?? DateTime(0)
                  : DateTime(0);
              return dA.compareTo(dB);
            });
            _messages = converted;
          }
        }

        try {
          chatCtrl.markAsRead(_activeConversationId!);
        } catch (_) {}
      } else {
        _messages = [];
      }
    } catch (e) {
      debugPrint(
        "==================== GET CONVERSATION ERROR ====================",
      );
      debugPrint("Error: $e");
      print("==================== GET CONVERSATION ERROR ====================");
      print("Error: $e");
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      final chatCtrl = Get.isRegistered<ChatController>()
          ? Get.find<ChatController>()
          : Get.put(ChatController());

      chatCtrl.messageController.text = text;
      await chatCtrl.sendMessage(
        context,
        conversationId:
            (_activeConversationId != null && _activeConversationId! > 0)
            ? _activeConversationId
            : null,
        customerId: widget.customerId,
      );

      _textController.clear();

      if (chatCtrl.currentConversation?.id != null &&
          chatCtrl.currentConversation!.id! > 0) {
        _activeConversationId = chatCtrl.currentConversation!.id;
      }
      await _fetchConversation(quiet: true);
    } catch (e) {
      debugPrint("Error sending message: $e");
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _startRecording() async {
    final chatCtrl = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    await chatCtrl.startRecording();
    if (mounted) setState(() {});
  }

  Future<void> _stopAndSendRecording() async {
    final chatCtrl = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    final duration = chatCtrl.recordingDuration;
    final path = await chatCtrl.stopRecording();
    if (path == null || path.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await chatCtrl.sendVoiceMessage(
        context,
        path,
        conversationId:
            (_activeConversationId != null && _activeConversationId! > 0)
                ? _activeConversationId
                : null,
        customerId: widget.customerId,
        duration: duration,
      );

      if (chatCtrl.currentConversation?.id != null &&
          chatCtrl.currentConversation!.id! > 0) {
        _activeConversationId = chatCtrl.currentConversation!.id;
      }
      await _fetchConversation(quiet: true);
    } catch (e) {
      debugPrint("Error sending voice message: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _cancelRecording() {
    final chatCtrl = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    chatCtrl.cancelRecording();
    if (mounted) setState(() {});
  }

  void _togglePauseRecording() {
    final chatCtrl = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    if (chatCtrl.isPaused) {
      chatCtrl.resumeRecording();
    } else {
      chatCtrl.pauseRecording();
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickImage() async {
    final chatCtrl = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());

    setState(() {
      _isSending = true;
    });

    try {
      await chatCtrl.pickAndSendImage(
        context,
        conversationId:
            (_activeConversationId != null && _activeConversationId! > 0)
            ? _activeConversationId
            : null,
        customerId: widget.customerId,
      );

      if (chatCtrl.currentConversation?.id != null &&
          chatCtrl.currentConversation!.id! > 0) {
        _activeConversationId = chatCtrl.currentConversation!.id;
      }
      await _fetchConversation(quiet: true);
    } catch (e) {
      debugPrint("Error picking/sending image: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  static String _formatImageUrl(String raw) {
    final str = raw.trim();
    if (str.isEmpty || str == 'null') return '';
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    final base = ApiConfigs.IMAGE_URL.trim();
    if (base.endsWith('/')) {
      return str.startsWith('/') ? '$base${str.substring(1)}' : '$base$str';
    } else {
      return str.startsWith('/') ? '$base$str' : '$base/$str';
    }
  }

  static ChatMessage _convertLastMessage(LastMessage m) {
    final isOutgoing = m.senderType?.toLowerCase() == 'vendor';

    ChatMessageType type = ChatMessageType.text;
    final mType = m.messageType?.toLowerCase();
    if (mType == 'voice' || mType == 'audio') {
      type = ChatMessageType.audio;
    } else if (mType == 'image') {
      type = ChatMessageType.image;
    }

    String time = '';
    if (m.createdAt != null && m.createdAt!.isNotEmpty) {
      try {
        final dt = DateTime.parse(m.createdAt!).toLocal();
        time = DateFormat('hh:mm a').format(dt);
      } catch (_) {
        time = m.createdAt!;
      }
    }

    String? duration;
    if (type == ChatMessageType.audio) {
      duration = '0:12';
    }

    String? attachment = m.attachmentUrl;
    if ((attachment == null || attachment.isEmpty) &&
        (type == ChatMessageType.image || type == ChatMessageType.audio)) {
      attachment = m.message;
    }

    return ChatMessage(
      type: type,
      isOutgoing: isOutgoing,
      time: time,
      text: m.message,
      duration: duration,
      attachmentUrl: attachment,
      createdAt: m.createdAt,
      isRead: m.isRead == true,
    );
  }

  String _getDateLabel(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return S.of(context).today;
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return S.of(context).today;
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year &&
          dt.month == yesterday.month &&
          dt.day == yesterday.day) {
        return S.of(context).yesterday;
      }
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return S.of(context).today;
    }
  }

  List<Widget> _buildMessagesWithDatePills() {
    final List<Widget> widgets = [];
    String? lastDate;

    for (final message in _messages) {
      final dateLabel = _getDateLabel(message.createdAt);
      if (dateLabel != lastDate) {
        lastDate = dateLabel;
        widgets.add(Center(child: _DatePill(label: dateLabel)));
        widgets.add(const SizedBox(height: 18));
      }
      widgets.add(_MessageItem(message: message));
      widgets.add(const SizedBox(height: 14));
    }

    return widgets;
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
                name: _displayName,
                isOnline: widget.isOnline,
                avatarUrl: _avatarUrl,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody()),
              GetBuilder<ChatController>(
                builder: (chatCtrl) {
                  return _ChatInputBar(
                    controller: _textController,
                    onSend: _sendMessage,
                    onPickImage: _pickImage,
                    onStartRecording: _startRecording,
                    onStopAndSendRecording: _stopAndSendRecording,
                    onCancelRecording: _cancelRecording,
                    onTogglePauseRecording: _togglePauseRecording,
                    isRecording: chatCtrl.isRecording,
                    isPaused: chatCtrl.isPaused,
                    recordingDuration: chatCtrl.recordingDuration,
                    isSending: _isSending || chatCtrl.isSendingMessage,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    if (_errorMessage != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _fetchConversation(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                  side: const BorderSide(color: AppColors.primaryOrange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(S.of(context).tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Text(
          S.of(context).noMessagesYet,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: _buildMessagesWithDatePills(),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.name,
    required this.isOnline,
    required this.onBack,
    this.avatarUrl,
  });

  final String name;
  final bool isOnline;
  final VoidCallback onBack;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final displayName =
        name.trim().isNotEmpty ? name.trim() : S.of(context).waterCustomer;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C';

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
            child: ClipOval(
              child: (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
                  ? Image.network(
                      avatarUrl!.trim(),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: AppColors.avatarText,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: AppColors.avatarText,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline ? S.of(context).waterOnline : S.of(context).waterOffline,
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
    final align = message.isOutgoing
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        if (message.type == ChatMessageType.text)
          _TextBubble(text: message.text ?? '', isOutgoing: message.isOutgoing)
        else if (message.type == ChatMessageType.audio)
          _AudioBubble(
            duration: message.duration ?? '0:00',
            audioUrl: message.attachmentUrl,
            isOutgoing: message.isOutgoing,
          )
        else if (message.type == ChatMessageType.image ||
            (message.attachmentUrl != null &&
                message.attachmentUrl!.isNotEmpty))
          _ImageBubble(
            imageUrl: (message.attachmentUrl != null &&
                    message.attachmentUrl!.isNotEmpty)
                ? message.attachmentUrl!
                : (message.text ?? ''),
            isOutgoing: message.isOutgoing,
          ),
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
      alignment: isOutgoing
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: isOutgoing
              ? AppColors.chatBubbleOutgoing
              : AppColors.chatBubbleIncoming,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(18),
            topEnd: const Radius.circular(18),
            bottomStart: Radius.circular(isOutgoing ? 18 : 6),
            bottomEnd: Radius.circular(isOutgoing ? 6 : 18),
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

class _AudioBubble extends StatefulWidget {
  const _AudioBubble({
    required this.duration,
    this.audioUrl,
    this.isOutgoing = true,
  });

  final String duration;
  final String? audioUrl;
  final bool isOutgoing;

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  static const _heights = [
    8.0, 14.0, 10.0, 18.0, 12.0, 20.0, 9.0, 16.0, 11.0, 19.0,
    13.0, 8.0, 17.0, 12.0, 21.0, 10.0, 15.0, 9.0, 18.0, 11.0,
    16.0, 8.0, 14.0, 12.0, 19.0, 10.0, 15.0, 9.0, 17.0, 11.0,
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayback() async {
    final rawUrl = widget.audioUrl?.trim();
    if (rawUrl == null || rawUrl.isEmpty) return;

    String fullUrl = rawUrl;
    if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
      final base = ApiConfigs.IMAGE_URL.trim();
      fullUrl = base.endsWith('/')
          ? (fullUrl.startsWith('/') ? '$base${fullUrl.substring(1)}' : '$base$fullUrl')
          : (fullUrl.startsWith('/') ? '$base$fullUrl' : '$base/$fullUrl');
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(fullUrl));
      }
    } catch (e) {
      debugPrint("Audio playback error: $e");
    }
  }

  String get _displayDuration {
    if (_isPlaying || _position > Duration.zero) {
      final m = _position.inMinutes;
      final s = _position.inSeconds % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    if (_duration > Duration.zero) {
      final m = _duration.inMinutes;
      final s = _duration.inSeconds % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    return widget.duration;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isOutgoing
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.72,
        padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
        decoration: BoxDecoration(
          color: widget.isOutgoing ? AppColors.chatBubbleOutgoing : AppColors.softGrayAlt,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: _togglePlayback,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isOutgoing ? AppColors.chatPlayCircle : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.primaryOrange,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _heights.length; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.8),
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: _heights[i],
                              decoration: BoxDecoration(
                                color: widget.isOutgoing
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.textDark.withValues(alpha: 0.6),
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
              _displayDuration,
              style: TextStyle(
                color: widget.isOutgoing ? Colors.white : AppColors.textDark,
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

class _ImageBubble extends StatelessWidget {
  const _ImageBubble({required this.imageUrl, required this.isOutgoing});

  final String imageUrl;
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    final fullUrl = _ChatViewState._formatImageUrl(imageUrl);
    final isLocal = !imageUrl.startsWith('http') && File(imageUrl).existsSync();

    return Align(
      alignment: isOutgoing
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ClipRRect(
        borderRadius: BorderRadiusDirectional.only(
          topStart: const Radius.circular(18),
          topEnd: const Radius.circular(18),
          bottomStart: Radius.circular(isOutgoing ? 18 : 6),
          bottomEnd: Radius.circular(isOutgoing ? 6 : 18),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.70,
            maxHeight: 220,
          ),
          decoration: BoxDecoration(
            color: isOutgoing
                ? AppColors.chatBubbleOutgoing
                : AppColors.chatBubbleIncoming,
          ),
          child: isLocal
              ? Image.file(
                  File(imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
              : Image.network(
                  fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    this.onPickImage,
    this.onStartRecording,
    this.onStopAndSendRecording,
    this.onCancelRecording,
    this.onTogglePauseRecording,
    this.isRecording = false,
    this.isPaused = false,
    this.recordingDuration = 0,
    this.isSending = false,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onPickImage;
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopAndSendRecording;
  final VoidCallback? onCancelRecording;
  final VoidCallback? onTogglePauseRecording;
  final bool isRecording;
  final bool isPaused;
  final int recordingDuration;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final timerText =
        "${(recordingDuration ~/ 60).toString().padLeft(1, '0')}:${(recordingDuration % 60).toString().padLeft(2, '0')}";

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
                child: isRecording
                    ? Row(
                        children: [
                          InkWell(
                            onTap: onCancelRecording,
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timerText,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: onTogglePauseRecording,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isPaused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                color: AppColors.textMeta,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          InkWell(
                            onTap: onPickImage,
                            borderRadius: BorderRadius.circular(20),
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppColors.textMeta,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              cursorColor: AppColors.primaryOrange,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: S.of(context).typeAMessage,
                                hintStyle: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => onSend(),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: isRecording
                  ? onStopAndSendRecording
                  : onStartRecording,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isRecording
                      ? Colors.redAccent
                      : AppColors.chatBubbleOutgoing,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRecording ? Icons.mic : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: isSending
                  ? null
                  : (isRecording ? onStopAndSendRecording : onSend),
              borderRadius: BorderRadius.circular(24),
              child: Container(
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
                child: isSending
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
