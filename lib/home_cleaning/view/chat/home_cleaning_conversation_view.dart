import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/chat_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/services_api.dart';
import 'package:saimpex_vendor/home_cleaning/view/chat/home_cleaning_messages_view.dart';
import 'package:saimpex_vendor/model/conversations_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

enum MessageType { text, audio, image }

enum MessageSender { me, customer }

/// One message of vendorapp chat/getConversation.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.sender,
    required this.type,
    this.text,
    this.attachmentUrl,
    this.durationSeconds,
    this.createdAt,
    this.isRead = false,
  });

  final int id;
  final MessageSender sender;
  final MessageType type;
  final String? text;
  final String? attachmentUrl;
  final int? durationSeconds;
  final DateTime? createdAt;
  final bool isRead;

  static ChatMessage? fromJson(dynamic json) {
    if (json is! Map) return null;
    final id = int.tryParse('${json['id']}');
    if (id == null) return null;
    final kind = json['message_type']?.toString().toLowerCase();
    final url = json['attachment_url']?.toString();
    return ChatMessage(
      id: id,
      sender: json['sender_type']?.toString().toLowerCase() == 'vendor'
          ? MessageSender.me
          : MessageSender.customer,
      type: kind == 'voice' || kind == 'audio'
          ? MessageType.audio
          : (kind == 'image' ? MessageType.image : MessageType.text),
      text: json['message']?.toString(),
      attachmentUrl: url == null || url.isEmpty || url == 'null' ? null : url,
      durationSeconds: int.tryParse('${json['attachment_duration'] ?? ''}'),
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}')?.toLocal(),
      isRead:
          json['is_read'] == true ||
          json['is_read']?.toString() == '1' ||
          json['is_read']?.toString() == 'true',
    );
  }
}

/// Chat with one customer. Opened with the [conversationId] when known; from
/// a booking only the customer is known, so the conversation is looked up by
/// [customerId] (or, failing that, by name) and created on the first message
/// when it does not exist yet.
class HomeCleaningConversationView extends StatefulWidget {
  const HomeCleaningConversationView({
    super.key,
    required this.customerName,
    this.orderId,
    this.conversationId,
    this.customerId,
    this.avatarUrl,
  });

  final String customerName;
  final String? orderId;
  final int? conversationId;
  final int? customerId;
  final String? avatarUrl;

  static const _orange = Color(0xFFFF5216);
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
  final AudioPlayer _player = AudioPlayer();
  late final ChatController _chat;

  List<ChatMessage> _messages = [];
  int? _conversationId;
  int? _customerId;
  String? _avatarUrl;
  bool _loading = true;
  bool _sending = false;
  String? _error;
  int? _playingId;

  bool get _canSend =>
      (_conversationId != null && _conversationId! > 0) ||
      (_customerId != null && _customerId! > 0);

  @override
  void initState() {
    super.initState();
    _chat = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    _conversationId = widget.conversationId;
    _customerId = widget.customerId;
    _avatarUrl = widget.avatarUrl;
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingId = null);
    });
    _chat.onMessageReceived = () {
      if (mounted) _fetch(quiet: true);
    };
    _fetch();
  }

  @override
  void dispose() {
    if (_chat.isRecording) _chat.cancelRecording();
    _chat.onMessageReceived = null;
    if (_chat.currentConversation?.id == _conversationId) {
      _chat.currentConversation = null;
    }
    _player.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _ensureToken() async {
    final token = (await getSavedObject('token'))?.toString() ?? '';
    if (token.isNotEmpty && token != 'null') DioClient().updateToken(token);
  }

  /// Finds the existing conversation with this customer, if any.
  Future<void> _resolveConversation() async {
    if (_conversationId != null && _conversationId! > 0) return;
    Conversation? find() {
      Conversation? match;
      if (_customerId != null) {
        match = _chat.conversations.firstWhereOrNull(
          (c) => c.customerId == _customerId || c.customer?.id == _customerId,
        );
      }
      final name = widget.customerName.trim().toLowerCase();
      if (match == null && _customerId == null && name.isNotEmpty) {
        match = _chat.conversations.firstWhereOrNull(
          (c) => c.customer?.name?.trim().toLowerCase() == name,
        );
      }
      return match;
    }

    var match = _chat.conversations.isEmpty ? null : find();
    if (match == null) {
      await _chat.getAllConversations(context, quiet: true);
      match = find();
    }
    if (match != null) {
      _conversationId = match.id;
      _customerId ??= match.customerId ?? match.customer?.id;
      _avatarUrl ??= cleaningChatImageUrl(match.customer?.image ?? match.image);
    }
  }

  Future<void> _fetch({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      await _ensureToken();
      await _resolveConversation();
      if (_conversationId == null || _conversationId! <= 0) {
        _messages = [];
      } else {
        final response = await DioClient().get(
          ApiEndPoints.getConversation,
          query: {'conversation_id': _conversationId, 'page': 1},
        );
        final data = response.data;
        final body = data is Map ? Map<String, dynamic>.from(data) : null;
        if (!CleaningServicesApi.isOk(body)) {
          throw CleaningApiException(CleaningServicesApi.serverMessage(body));
        }
        final convo = body!['data'] is Map
            ? body['data']['conversation']
            : null;
        final raw = convo is Map ? convo['messages'] : null;
        final list = raw is List
            ? raw.map(ChatMessage.fromJson).whereType<ChatMessage>().toList()
            : <ChatMessage>[];
        list.sort(
          (a, b) => (a.createdAt ?? DateTime(0)).compareTo(
            b.createdAt ?? DateTime(0),
          ),
        );
        _messages = list;
        if (convo is Map && convo['customer'] is Map) {
          _customerId ??= int.tryParse('${convo['customer']['id']}');
          _avatarUrl ??= cleaningChatImageUrl(
            convo['customer']['image']?.toString(),
          );
        }
        // Lets ChatController's Pusher handler refresh this screen.
        if (_chat.currentConversation?.id != _conversationId) {
          _chat.currentConversation = Conversation(id: _conversationId);
        }
        _chat.markAsRead(_conversationId!);
      }
      _error = null;
    } on CleaningApiException catch (e) {
      if (!quiet && mounted) {
        _error = e.message ?? S.of(context).cleaningSvcChatLoadError;
      }
    } on String catch (message) {
      if (!quiet) _error = message;
    } catch (_) {
      if (!quiet && mounted) _error = S.of(context).cleaningSvcChatLoadError;
    }
    if (mounted) {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  Map<String, dynamic> _target() =>
      (_conversationId != null && _conversationId! > 0)
      ? {'conversation_id': _conversationId}
      : {'customer_id': _customerId};

  void _cannotSend() {
    showToast(context, S.of(context).cleaningSvcChatUnavailable);
  }

  /// POST chat/sendMessage {message, message_type: text, conversation_id |
  /// customer_id}; the first message creates the conversation.
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;
    if (!_canSend) return _cannotSend();

    HapticFeedback.lightImpact();
    setState(() => _sending = true);
    try {
      await _ensureToken();
      final response = await DioClient().post(
        ApiEndPoints.sendMessage,
        body: dio.FormData.fromMap({
          'message': text,
          'message_type': 'text',
          ..._target(),
        }),
      );
      final data = response.data;
      final body = data is Map ? Map<String, dynamic>.from(data) : null;
      if (!CleaningServicesApi.isOk(body)) {
        throw CleaningApiException(CleaningServicesApi.serverMessage(body));
      }
      _messageController.clear();
      final newId = int.tryParse('${body!['data']?['conversation_id'] ?? ''}');
      if (newId != null) _conversationId = newId;
      await _fetch(quiet: true);
    } on CleaningApiException catch (e) {
      if (mounted) {
        showToast(context, e.message ?? S.of(context).cleaningSvcGenericError);
      }
    } on String catch (message) {
      if (mounted) showToast(context, message);
    } catch (_) {
      if (mounted) showToast(context, S.of(context).cleaningSvcGenericError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// After ChatController sent an image / voice note to a customer without a
  /// conversation yet, pick up the conversation it created.
  void _adoptControllerConversation() {
    final current = _chat.currentConversation;
    if ((_conversationId == null || _conversationId! <= 0) &&
        current?.id != null &&
        (current!.customerId == _customerId ||
            current.customer?.id == _customerId)) {
      _conversationId = current.id;
    }
  }

  Future<void> _pickImage() async {
    if (_sending) return;
    if (!_canSend) return _cannotSend();
    HapticFeedback.lightImpact();
    setState(() => _sending = true);
    try {
      await _chat.pickAndSendImage(
        context,
        conversationId: _conversationId,
        customerId: _conversationId == null ? _customerId : null,
      );
      _adoptControllerConversation();
      await _fetch(quiet: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_sending) return;
    if (!_canSend) return _cannotSend();
    HapticFeedback.lightImpact();
    if (!_chat.isRecording) {
      await _chat.startRecording();
      return;
    }
    final duration = _chat.recordingDuration;
    final path = await _chat.stopRecording();
    if (path == null || path.isEmpty || !mounted) return;
    setState(() => _sending = true);
    try {
      await _chat.sendVoiceMessage(
        context,
        path,
        conversationId: _conversationId,
        customerId: _conversationId == null ? _customerId : null,
        duration: duration < 1 ? 1 : duration,
      );
      _adoptControllerConversation();
      await _fetch(quiet: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleAudio(ChatMessage message) async {
    final url = message.attachmentUrl;
    if (url == null) return;
    HapticFeedback.lightImpact();
    try {
      if (_playingId == message.id) {
        await _player.stop();
        setState(() => _playingId = null);
      } else {
        await _player.stop();
        await _player.play(UrlSource(url));
        setState(() => _playingId = message.id);
      }
    } catch (_) {
      if (mounted) setState(() => _playingId = null);
    }
  }

  String _formatDuration(int? seconds) {
    final s = seconds ?? 0;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  String _dayLabel(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return S.of(context).today;
    if (diff == 1) return S.of(context).yesterday;
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  List<Widget> _buildMessageList() {
    final widgets = <Widget>[];
    String? lastDay;
    for (final message in _messages) {
      final day = _dayLabel(message.createdAt);
      if (day.isNotEmpty && day != lastDay) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 4));
        widgets.add(_buildDatePill(day));
        widgets.add(const SizedBox(height: 16));
        lastDay = day;
      }
      widgets.add(_buildMessageItem(message));
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
        backgroundColor: HomeCleaningConversationView._bgCream,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildBody()),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: HomeCleaningConversationView._orange,
        ),
      );
    }
    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: Color(0xFFBDBDBD),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: appFont('Inter', 
                  color: const Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _fetch,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: HomeCleaningConversationView._orange,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  S.of(context).tryAgain,
                  style: appFont('Inter', 
                    color: HomeCleaningConversationView._orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: HomeCleaningConversationView._orange,
      onRefresh: () => _fetch(quiet: true),
      child: _messages.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      _canSend
                          ? S.of(context).noMessagesYet
                          : S.of(context).cleaningSvcChatUnavailable,
                      textAlign: TextAlign.center,
                      style: appFont('Inter', 
                        color: const Color(0xFF9E9E9E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: _buildMessageList(),
            ),
    );
  }

  Widget _buildTopBar() {
    final orderId = widget.orderId?.trim();
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
          CleaningChatAvatar(
            name: widget.customerName,
            imageUrl: _avatarUrl,
            radius: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appFont('Inter', 
                    color: HomeCleaningConversationView._ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (orderId != null && orderId.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    orderId,
                    style: appFont('Inter', 
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePill(String label) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFEA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: appFont('Inter', 
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
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          switch (message.type) {
            MessageType.audio => _buildAudioBubble(message),
            MessageType.image => _buildImageBubble(message),
            MessageType.text => _buildTextBubble(message, isMe: isMe),
          },
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
        style: appFont('Inter', 
          color: isMe ? Colors.white : HomeCleaningConversationView._ink,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildImageBubble(ChatMessage message) {
    final url = message.attachmentUrl;
    final broken = Container(
      width: 200,
      height: 150,
      color: const Color(0xFFF3EFEA),
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: Color(0xFFBDBDBD)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: url == null
          ? broken
          : Image.network(
              url,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => broken,
            ),
    );
  }

  Widget _buildAudioBubble(ChatMessage message) {
    final playing = _playingId == message.id;
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
            onTap: () => _toggleAudio(message),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
          if (message.durationSeconds != null) ...[
            const SizedBox(width: 12),
            Text(
              _formatDuration(message.durationSeconds),
              style: appFont('Inter', 
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestamp(ChatMessage message, {required bool isMe}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.createdAt == null
              ? ''
              : DateFormat('hh:mm a').format(message.createdAt!),
          style: appFont('Inter', 
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
    return GetBuilder<ChatController>(
      init: _chat,
      builder: (chat) {
        final recording = chat.isRecording;
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
                  child: recording
                      ? Row(
                          children: [
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                chat.cancelRecording();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFF555555),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.fiber_manual_record,
                              color: Colors.red,
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDuration(chat.recordingDuration),
                              style: appFont('Inter', 
                                color: HomeCleaningConversationView._ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            InkWell(
                              onTap: _pickImage,
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
                                style: appFont('Inter', 
                                  color: HomeCleaningConversationView._ink,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: S.of(context).typeAMessage,
                                  hintStyle: appFont('Inter', 
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
                onTap: _toggleRecording,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: recording ? Colors.red : const Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    recording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              if (!recording) ...[
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
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
