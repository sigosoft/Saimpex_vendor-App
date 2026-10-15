import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/model/conversations_model.dart';
import 'package:saimpex_vendor/pharmacy/controller/pharmacy_chat_controller.dart';
import 'package:saimpex_vendor/utils/widgets/no_data_widget.dart';

String _formatAvatarUrl(String path) {
  final clean = path.trim();
  if (clean.isEmpty) return '';
  if (clean.startsWith('http://') || clean.startsWith('https://')) {
    return clean;
  }
  final base = ApiConfigs.IMAGE_URL.trim();
  final cleanBase = base.endsWith('/') ? base : '$base/';
  var cleanPath = clean.startsWith('/') ? clean.substring(1) : clean;
  if (cleanPath.startsWith('storage/')) {
    cleanPath = cleanPath.substring(8);
  }
  return '$cleanBase$cleanPath';
}

class _MessageThread {
  const _MessageThread({
    required this.name,
    required this.preview,
    required this.time,
    required this.avatar,
    this.unreadCount = 0,
    this.isOnline = false,
    this.showReadReceipt = false,
    this.conversationId = 1,
    this.customerId = 1,
  });

  final String name;
  final String preview;
  final String time;
  final String avatar;
  final int unreadCount;
  final bool isOnline;
  final bool showReadReceipt;
  final int conversationId;
  final int customerId;

  _MessageThread copyWith({
    String? name,
    String? preview,
    String? time,
    String? avatar,
    int? unreadCount,
    bool? isOnline,
    bool? showReadReceipt,
    int? conversationId,
    int? customerId,
  }) {
    return _MessageThread(
      name: name ?? this.name,
      preview: preview ?? this.preview,
      time: time ?? this.time,
      avatar: avatar ?? this.avatar,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      showReadReceipt: showReadReceipt ?? this.showReadReceipt,
      conversationId: conversationId ?? this.conversationId,
      customerId: customerId ?? this.customerId,
    );
  }
}

class PharmacyMessagesTab extends StatefulWidget {
  const PharmacyMessagesTab({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<PharmacyMessagesTab> createState() => _PharmacyMessagesTabState();
}

class _PharmacyMessagesTabState extends State<PharmacyMessagesTab> {
  late final PharmacyChatController controller;

  final List<_MessageThread> _threads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PharmacyChatController());
    _fetchThreads();
  }

  Future<void> _fetchThreads() async {
    try {
      if (_threads.isEmpty) {
        setState(() => _isLoading = true);
      }
      await controller.fetchConversations();
      if (!mounted) return;
      _populateThreadsFromController();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateThreadsFromController() {
    final list = <_MessageThread>[];
    for (final conv in controller.conversations) {
      final name = conv.customer?.name?.trim();
      final displayName = (name != null && name.isNotEmpty)
          ? name
          : (conv.orderId != null ? 'Order #${conv.orderId}' : 'Customer');

      String preview = '';
      if (conv.lastMessage != null) {
        if (conv.lastMessage?.messageType == 'image') {
          preview = '📷 Image';
        } else if (conv.lastMessage?.messageType == 'voice') {
          preview = '🎤 Voice message';
        } else {
          preview = conv.lastMessage?.message ?? '';
        }
      } else if (conv.orderId != null) {
        preview = 'Order #${conv.orderId}';
      }

      String avatar = '';
      final custImage = conv.customer?.image?.trim() ?? conv.image?.trim();
      if (custImage != null && custImage.isNotEmpty) {
        avatar = _formatAvatarUrl(custImage);
      }

      final timeStr =
          conv.lastMessageAt ??
          conv.lastMessage?.createdAt ??
          conv.updatedAt ??
          conv.createdAt;

      list.add(
        _MessageThread(
          name: displayName,
          preview: preview,
          time: _formatChatTime(timeStr),
          avatar: avatar,
          unreadCount: conv.unreadCount ?? 0,
          isOnline: false,
          showReadReceipt: conv.lastMessage?.isRead ?? false,
          conversationId: conv.id ?? 1,
          customerId: conv.customerId ?? conv.customer?.id ?? 1,
        ),
      );
    }
    setState(() {
      _threads
        ..clear()
        ..addAll(list);
      _isLoading = false;
    });
  }

  String _formatChatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '';
    try {
      DateTime dt = DateTime.tryParse(timeStr) ?? DateTime.now();
      if (timeStr.contains('-') && !timeStr.contains('T')) {
        try {
          dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timeStr);
        } catch (_) {}
      }
      dt = dt.toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return DateFormat('hh:mm a').format(dt);
      } else {
        return DateFormat('dd/MM/yyyy').format(dt);
      }
    } catch (_) {
      return timeStr ?? '';
    }
  }

  @override
  void dispose() {
    Get.delete<PharmacyChatController>();
    super.dispose();
  }

  Future<void> _confirmDelete(_MessageThread thread) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteChatDialog(name: thread.name),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _threads.remove(thread));
  }

  List<_MessageThread> get _visibleThreads {
    final query = controller.query.trim().toLowerCase();
    if (query.isEmpty) return _threads;
    return _threads
        .where(
          (thread) =>
              thread.name.toLowerCase().contains(query) ||
              thread.preview.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PharmacyChatController>(
      builder: (_) {
        final threads = _visibleThreads;
        return ColoredBox(
          color: const Color(0xFFFFFFFF),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 6),
              _MessagesHeader(
                onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MessagesSearchField(
                  controller: controller.searchController,
                  onChanged: controller.onQueryChanged,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child:
                    (_isLoading || controller.isLoadingConversations) &&
                        _threads.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF5722),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFFFF5722),
                        onRefresh: _fetchThreads,
                        child: threads.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: NoDataWidget(
                                      context,
                                      'No messages found',
                                      '',
                                      'lib/assets/images/nodata.png',
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  16,
                                ),
                                itemCount: threads.length,
                                itemBuilder: (context, index) {
                                  final thread = threads[index];
                                  return Column(
                                    children: [
                                      _MessageTile(
                                        thread: thread,
                                        onTap: () async {
                                          if (thread.conversationId > 0) {
                                            controller.markAsRead(
                                              conversationId:
                                                  thread.conversationId,
                                            );
                                          }
                                          await PharmacyChatScreen.open(
                                            context,
                                            customerName: thread.name,
                                            conversationId:
                                                thread.conversationId,
                                            customerId: thread.customerId,
                                            avatar: thread.avatar,
                                            onMessageSent: (newMessage) {
                                              setState(() {
                                                final idx = _threads.indexOf(
                                                  thread,
                                                );
                                                if (idx != -1) {
                                                  _threads[idx] = _threads[idx]
                                                      .copyWith(
                                                        preview: newMessage,
                                                        time: 'Just now',
                                                      );
                                                }
                                              });
                                            },
                                          );
                                          _fetchThreads();
                                        },
                                        onDelete: () => _confirmDelete(thread),
                                      ),
                                      const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Color(0xFFF0F0F0),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessagesHeader extends StatelessWidget {
  const _MessagesHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Messages',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.1,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
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
                    color: Color(0xFFFF5722),
                    size: 26,
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

class _MessagesSearchField extends StatelessWidget {
  const _MessagesSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFFB0B0B0), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
                height: 1.2,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: 'Search customer name or order ID...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w400,
                  fontSize: 13.5,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.thread,
    required this.onTap,
    required this.onDelete,
  });

  final _MessageThread thread;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static const _name = Color(0xFF1A1A1A);
  static const _previewRead = Color(0xFF9CA3AF);
  static const _time = Color(0xFF9CA3AF);
  static const _orange = Color(0xFFFF5722);

  @override
  Widget build(BuildContext context) {
    final unread = thread.unreadCount > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ThreadAvatar(
              asset: thread.avatar,
              isOnline: thread.isOnline,
              name: thread.name,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: _name,
                            fontWeight: FontWeight.w700,
                            fontSize: 15.5,
                            height: 1.15,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: _orange,
                            size: 22,
                          ),
                        ),
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
                          style: GoogleFonts.inter(
                            color: unread ? _name : _previewRead,
                            fontWeight: unread
                                ? FontWeight.w500
                                : FontWeight.w400,
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (unread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 18,
                          height: 18,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: _orange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              height: 1,
                            ),
                          ),
                        ),
                      ] else if (thread.showReadReceipt) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: Color(0xFFC5C5C5),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      thread.time,
                      style: GoogleFonts.inter(
                        color: _time,
                        fontWeight: FontWeight.w400,
                        fontSize: 11.5,
                        height: 1,
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

class _ThreadAvatar extends StatelessWidget {
  const _ThreadAvatar({
    required this.asset,
    required this.isOnline,
    this.name = '',
  });

  final String asset;
  final bool isOnline;
  final String name;

  @override
  Widget build(BuildContext context) {
    final cleanAsset = asset.trim();
    final initial = name.trim().isNotEmpty
        ? name.trim().substring(0, 1).toUpperCase()
        : 'C';

    final fallbackWidget = Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F0),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: GoogleFonts.inter(
          color: const Color(0xFFFF5722),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );

    String resolved = cleanAsset;
    if (resolved.isNotEmpty &&
        !resolved.startsWith('http://') &&
        !resolved.startsWith('https://') &&
        !resolved.startsWith('lib/') &&
        !resolved.startsWith('assets/')) {
      resolved = _formatAvatarUrl(resolved);
    }

    Widget avatarWidget;
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      avatarWidget = ClipOval(
        child: Image.network(
          resolved,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.35),
          errorBuilder: (context, error, stackTrace) => fallbackWidget,
        ),
      );
    } else if (resolved.isNotEmpty &&
        (resolved.startsWith('lib/') || resolved.startsWith('assets/'))) {
      avatarWidget = ClipOval(
        child: Image.asset(
          resolved,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.35),
          errorBuilder: (context, error, stackTrace) => fallbackWidget,
        ),
      );
    } else {
      avatarWidget = fallbackWidget;
    }

    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatItem {
  final String? text;
  final String time;
  final bool isIncoming;
  final bool isAudio;
  final String? audioDuration;
  final bool isRead;
  final bool isDelivered;
  final int? id;
  final int? conversationId;

  const _ChatItem.incoming({
    required this.text,
    required this.time,
    this.id,
    this.conversationId,
  }) : isIncoming = true,
       isAudio = false,
       audioDuration = null,
       isRead = false,
       isDelivered = true;

  const _ChatItem.outgoing({
    required this.text,
    required this.time,
    this.isRead = false,
    this.isDelivered = true,
    this.id,
    this.conversationId,
  }) : isIncoming = false,
       isAudio = false,
       audioDuration = null;

  const _ChatItem.audio({
    required String duration,
    required this.time,
    this.isRead = false,
    this.isDelivered = true,
    this.id,
    this.conversationId,
  }) : isIncoming = false,
       isAudio = true,
       audioDuration = duration,
       text = null;
}

class PharmacyChatScreen extends StatefulWidget {
  const PharmacyChatScreen({
    super.key,
    this.customerName = 'Ahmed',
    this.conversationId = 0,
    this.customerId = 1,
    this.avatar = _avatar,
    this.onMessageSent,
  });

  final String customerName;
  final int conversationId;
  final int customerId;
  final String avatar;
  final ValueChanged<String>? onMessageSent;

  static const _bg = Color(0xFFFBF6F0);
  static const _name = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF9A9A9A);
  static const _time = Color(0xFFA3A3A8);
  static const _orange = Color(0xFFFF5722);
  static const _bubble = Color(0xFF1A1A1A);
  static const _input = Color(0xFFF3EEE6);
  static const _avatar = '';

  static Future<void> open(
    BuildContext context, {
    String customerName = 'Ahmed',
    int conversationId = 0,
    int customerId = 1,
    String avatar = _avatar,
    ValueChanged<String>? onMessageSent,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyChatScreen(
          customerName: customerName,
          conversationId: conversationId,
          customerId: customerId,
          avatar: avatar,
          onMessageSent: onMessageSent,
        ),
      ),
    );
  }

  @override
  State<PharmacyChatScreen> createState() => _PharmacyChatScreenState();
}

class _PharmacyChatScreenState extends State<PharmacyChatScreen> {
  late final PharmacyChatController _chatController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _isLoading = true;
  int _activeConversationId = 0;
  String? _customerAvatar;
  String? _customerName;

  final List<_ChatItem> _messages = [];
  final Set<int> _markedMessageIds = {};

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    _customerName = widget.customerName;
    _customerAvatar = widget.avatar;
    _isLoading = true;
    _chatController = Get.isRegistered<PharmacyChatController>()
        ? Get.find<PharmacyChatController>()
        : Get.put(PharmacyChatController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchConversationMessages();
      }
    });
  }

  Future<void> _fetchConversationMessages() async {
    try {
      if (_messages.isEmpty) {
        setState(() => _isLoading = true);
      }
      if (_activeConversationId <= 0 && widget.customerId > 0) {
        if (_chatController.conversations.isEmpty) {
          await _chatController.fetchConversations(quiet: true);
        }
        for (final c in _chatController.conversations) {
          if (c.customerId == widget.customerId ||
              c.customer?.id == widget.customerId) {
            if (c.id != null && c.id! > 0) {
              _activeConversationId = c.id!;
            }
            final cImage = c.customer?.image?.trim() ?? c.image?.trim();
            if (cImage != null && cImage.isNotEmpty) {
              _customerAvatar = _formatAvatarUrl(cImage);
            }
            final cName = c.customer?.name?.trim();
            if (cName != null && cName.isNotEmpty) {
              _customerName = cName;
            }
            break;
          }
        }
      }

      if (_activeConversationId > 0) {
        await _chatController.getConversationDetails(
          _activeConversationId,
          quiet: true,
        );
        if (!mounted) return;
        _populateMessagesFromController();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateMessagesFromController() {
    final conv =
        _chatController.currentConversation ??
        _chatController.currentConversationModel?.data?.conversation;
    final customer = conv?.customer;

    final img = customer?.image?.trim() ?? conv?.image?.trim();
    if (img != null && img.isNotEmpty) {
      _customerAvatar = _formatAvatarUrl(img);
    }
    final name = customer?.name?.trim();
    if (name != null && name.isNotEmpty) {
      _customerName = name;
    }

    final rawMessages = List<LastMessage>.from(
      _chatController.conversationMessages,
    );
    rawMessages.sort((a, b) {
      final aTime = _parseDateTime(a.createdAt);
      final bTime = _parseDateTime(b.createdAt);
      if (aTime != null && bTime != null) {
        return aTime.compareTo(bTime);
      }
      return (a.id ?? 0).compareTo(b.id ?? 0);
    });

    final list = <_ChatItem>[];
    for (final msg in rawMessages) {
      list.add(_mapMessageToChatItem(msg));
    }

    // Use 'markAsRead' api to mark incoming messages as read
    for (final msg in rawMessages) {
      final msgId = msg.id;
      final convId = msg.conversationId ?? _activeConversationId;
      if (msg.senderType != 'vendor') {
        if (msgId != null && msgId > 0 && !_markedMessageIds.contains(msgId)) {
          _markedMessageIds.add(msgId);
          _chatController.markAsRead(conversationId: convId, messageId: msgId);
        }
      }
    }
    if (_activeConversationId > 0) {
      _chatController.markAsRead(conversationId: _activeConversationId);
    }

    setState(() {
      _messages
        ..clear()
        ..addAll(list);
      _isLoading = false;
    });
    _scrollToBottom();
  }

  _ChatItem _mapMessageToChatItem(LastMessage msg) {
    final isVendor = msg.senderType == 'vendor';
    final isAudio = msg.messageType == 'voice' || msg.messageType == 'audio';
    final timeStr = _formatMessageTime(msg.createdAt);
    final isRead = msg.isRead == true;
    final isDelivered = msg.id != null && msg.id! > 0;

    if (isAudio) {
      return _ChatItem.audio(
        duration: '0:12',
        time: timeStr,
        isRead: isRead,
        isDelivered: isDelivered,
        id: msg.id,
        conversationId: msg.conversationId,
      );
    } else if (isVendor) {
      return _ChatItem.outgoing(
        text: msg.message ?? '',
        time: timeStr,
        isRead: isRead,
        isDelivered: isDelivered,
        id: msg.id,
        conversationId: msg.conversationId,
      );
    } else {
      return _ChatItem.incoming(
        text: msg.message ?? '',
        time: timeStr,
        id: msg.id,
        conversationId: msg.conversationId,
      );
    }
  }

  DateTime? _parseDateTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    try {
      if (timeStr.contains('-') && !timeStr.contains('T')) {
        try {
          return DateFormat("yyyy-MM-dd HH:mm:ss").parse(timeStr).toLocal();
        } catch (_) {}
      }
      return DateTime.tryParse(timeStr)?.toLocal();
    } catch (_) {
      return null;
    }
  }

  String _formatMessageTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '';
    try {
      final dt = _parseDateTime(timeStr);
      if (dt != null) {
        return DateFormat('hh:mm a').format(dt);
      }
      return timeStr;
    } catch (_) {
      return timeStr ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
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

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    final success = await _chatController.sendChatMessage(
      text: text,
      conversationId: _activeConversationId > 0 ? _activeConversationId : null,
      customerId: widget.customerId,
    );

    if (!mounted) return;

    setState(() => _isSending = false);

    if (success) {
      _textController.clear();
      final timeStr = _formatCurrentTime();
      setState(() {
        _messages.add(
          _ChatItem.outgoing(
            text: text,
            time: timeStr,
            isRead: false,
            isDelivered: false,
          ),
        );
      });
      widget.onMessageSent?.call(text);
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: PharmacyChatScreen._bg,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _Header(
                name: _customerName ?? widget.customerName,
                avatar: _customerAvatar ?? widget.avatar,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: _isLoading && _messages.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: PharmacyChatScreen._orange,
                        ),
                      )
                    : RefreshIndicator(
                        color: PharmacyChatScreen._orange,
                        onRefresh: _fetchConversationMessages,
                        child: _messages.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: NoDataWidget(
                                      context,
                                      'No messages found',
                                      '',
                                      'lib/assets/images/nodata.png',
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  18,
                                  16,
                                  12,
                                ),
                                itemCount: _messages.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return const Padding(
                                      padding: EdgeInsets.only(bottom: 18),
                                      child: Center(
                                        child: _DatePill(label: 'Today'),
                                      ),
                                    );
                                  }
                                  final msg = _messages[index - 1];
                                  if (msg.isIncoming &&
                                      msg.id != null &&
                                      msg.id! > 0 &&
                                      !_markedMessageIds.contains(msg.id!)) {
                                    _markedMessageIds.add(msg.id!);
                                    final convId =
                                        msg.conversationId ??
                                        _activeConversationId;
                                    if (convId > 0) {
                                      _chatController.markAsRead(
                                        conversationId: convId,
                                        messageId: msg.id!,
                                      );
                                    }
                                  }
                                  Widget bubble;
                                  if (msg.isAudio) {
                                    bubble = _AudioBubble(
                                      duration: msg.audioDuration ?? '0:12',
                                      time: msg.time,
                                      isRead: msg.isRead,
                                      isDelivered: msg.isDelivered,
                                    );
                                  } else if (msg.isIncoming) {
                                    bubble = _IncomingBubble(
                                      text: msg.text ?? '',
                                      time: msg.time,
                                    );
                                  } else {
                                    bubble = _OutgoingBubble(
                                      text: msg.text ?? '',
                                      time: msg.time,
                                      isRead: msg.isRead,
                                      isDelivered: msg.isDelivered,
                                    );
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: bubble,
                                  );
                                },
                              ),
                      ),
              ),
              _InputBar(
                controller: _textController,
                onSend: _handleSend,
                isSending: _isSending,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.onBack,
    this.avatar = PharmacyChatScreen._avatar,
  });

  final String name;
  final VoidCallback onBack;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    final cleanAvatar = avatar.trim();
    final initial = name.trim().isNotEmpty
        ? name.trim().substring(0, 1).toUpperCase()
        : 'C';

    final fallbackWidget = Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F0),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: GoogleFonts.inter(
          color: PharmacyChatScreen._orange,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );

    String resolved = cleanAvatar;
    if (resolved.isNotEmpty &&
        !resolved.startsWith('http://') &&
        !resolved.startsWith('https://') &&
        !resolved.startsWith('lib/') &&
        !resolved.startsWith('assets/')) {
      resolved = _formatAvatarUrl(resolved);
    }

    Widget avatarWidget;
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      avatarWidget = ClipOval(
        child: Image.network(
          resolved,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.25),
          errorBuilder: (context, error, stackTrace) => fallbackWidget,
        ),
      );
    } else if (resolved.isNotEmpty &&
        (resolved.startsWith('lib/') || resolved.startsWith('assets/')) &&
        resolved != PharmacyChatScreen._avatar) {
      avatarWidget = ClipOval(
        child: Image.asset(
          resolved,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.25),
          errorBuilder: (context, error, stackTrace) => fallbackWidget,
        ),
      );
    } else {
      avatarWidget = fallbackWidget;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: PharmacyChatScreen._orange,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          avatarWidget,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    color: PharmacyChatScreen._name,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Online',
                  style: GoogleFonts.inter(
                    color: PharmacyChatScreen._muted,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.5,
                    height: 1.2,
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
        color: const Color(0xFFF0EBE3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: PharmacyChatScreen._muted,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          height: 1.1,
        ),
      ),
    );
  }
}

class _IncomingBubble extends StatelessWidget {
  const _IncomingBubble({required this.text, required this.time});

  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
            style: GoogleFonts.inter(
              color: const Color(0xFF3A3A3A),
              fontWeight: FontWeight.w400,
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: GoogleFonts.inter(
            color: PharmacyChatScreen._time,
            fontWeight: FontWeight.w400,
            fontSize: 11.5,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _OutgoingBubble extends StatelessWidget {
  const _OutgoingBubble({
    required this.text,
    required this.time,
    this.isRead = false,
    this.isDelivered = false,
  });

  final String text;
  final String time;
  final bool isRead;
  final bool isDelivered;

  @override
  Widget build(BuildContext context) {
    final IconData tickIcon = (isRead || isDelivered)
        ? Icons.done_all_rounded
        : Icons.check_rounded;
    final Color tickColor = isRead
        ? PharmacyChatScreen._orange
        : PharmacyChatScreen._time;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: PharmacyChatScreen._bubble,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: GoogleFonts.inter(
                color: PharmacyChatScreen._time,
                fontWeight: FontWeight.w400,
                fontSize: 11.5,
                height: 1,
              ),
            ),
            const SizedBox(width: 3),
            Icon(tickIcon, size: 15, color: tickColor),
          ],
        ),
      ],
    );
  }
}

class _AudioBubble extends StatelessWidget {
  const _AudioBubble({
    required this.duration,
    required this.time,
    this.isRead = false,
    this.isDelivered = false,
  });

  final String duration;
  final String time;
  final bool isRead;
  final bool isDelivered;

  static const _heights = <double>[
    7,
    12,
    9,
    16,
    11,
    18,
    8,
    14,
    10,
    17,
    12,
    7,
    15,
    11,
    19,
    9,
    13,
    8,
    16,
    10,
    14,
    7,
    12,
    10,
    17,
    9,
    13,
    8,
    15,
    11,
  ];

  @override
  Widget build(BuildContext context) {
    final IconData tickIcon = (isRead || isDelivered)
        ? Icons.done_all_rounded
        : Icons.check_rounded;
    final Color tickColor = isRead
        ? PharmacyChatScreen._orange
        : PharmacyChatScreen._time;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width * 0.72,
          padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
          decoration: BoxDecoration(
            color: PharmacyChatScreen._bubble,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: PharmacyChatScreen._orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF1A1A1A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 22,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (final height in _heights)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0.7,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: height,
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: GoogleFonts.inter(
                color: PharmacyChatScreen._time,
                fontWeight: FontWeight.w400,
                fontSize: 11.5,
                height: 1,
              ),
            ),
            const SizedBox(width: 3),
            Icon(tickIcon, size: 15, color: tickColor),
          ],
        ),
      ],
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    this.isSending = false,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: PharmacyChatScreen._input,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: Color(0xFF8E8E93), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFFC5C5C5),
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          height: 1,
                        ),
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
              color: Color(0xFF1A1A1A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic_none_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PharmacyChatScreen._orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PharmacyChatScreen._orange.withValues(alpha: 0.35),
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
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteChatDialog extends StatelessWidget {
  const _DeleteChatDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F3),
                shape: BoxShape.circle,
              ),
              child: const _ChatTrashDropIcon(),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete chat?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete the chat with $name?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTrashDropIcon extends StatefulWidget {
  const _ChatTrashDropIcon();

  @override
  State<_ChatTrashDropIcon> createState() => _ChatTrashDropIconState();
}

class _ChatTrashDropIconState extends State<_ChatTrashDropIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _lidOpen(double t) {
    if (t < 0.22) return Curves.easeOut.transform(t / 0.22);
    if (t < 0.62) return 1;
    if (t < 0.82) {
      return 1 - Curves.easeIn.transform((t - 0.62) / 0.20);
    }
    return 0;
  }

  double _wasteDrop(double t) {
    if (t < 0.24 || t > 0.60) return -1;
    return Curves.easeIn.transform((t - 0.24) / 0.36);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ChatTrashDropPainter(
              lidOpen: _lidOpen(_controller.value),
              wasteDrop: _wasteDrop(_controller.value),
            ),
          );
        },
      ),
    );
  }
}

class _ChatTrashDropPainter extends CustomPainter {
  const _ChatTrashDropPainter({required this.lidOpen, required this.wasteDrop});

  final double lidOpen;
  final double wasteDrop;

  @override
  void paint(Canvas canvas, Size size) {
    const red = Color(0xFFE53935);
    final binPaint = Paint()
      ..color = red
      ..style = PaintingStyle.fill;

    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.20,
        size.height * 0.36,
        size.width * 0.60,
        size.height * 0.56,
      ),
      bottomLeft: const Radius.circular(3.5),
      bottomRight: const Radius.circular(3.5),
    );
    canvas.drawRRect(body, binPaint);

    final slotPaint = Paint()..color = Colors.white;
    final slotTop = body.top + body.height * 0.16;
    final slotHeight = body.height * 0.58;
    final slotWidth = size.width * 0.075;
    for (final left in [
      body.left + body.width * 0.30,
      body.left + body.width * 0.58,
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, slotTop, slotWidth, slotHeight),
          const Radius.circular(2),
        ),
        slotPaint,
      );
    }

    _paintWaste(canvas, size, body.outerRect);

    final lid = Rect.fromLTWH(
      size.width * 0.10,
      size.height * 0.26,
      size.width * 0.80,
      size.height * 0.10,
    );
    final hinge = Offset(lid.left, lid.bottom);
    canvas.save();
    canvas.translate(hinge.dx, hinge.dy);
    canvas.rotate(-0.85 * lidOpen);
    canvas.translate(-hinge.dx, -hinge.dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(lid, const Radius.circular(1.5)),
      binPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.36,
          size.height * 0.15,
          size.width * 0.28,
          size.height * 0.11,
        ),
        const Radius.circular(2),
      ),
      binPaint,
    );
    canvas.restore();
  }

  void _paintWaste(Canvas canvas, Size size, Rect bin) {
    if (wasteDrop < 0) return;
    final width = size.width * 0.22;
    final height = size.height * 0.14;
    final left = (size.width - width) / 2;
    final startY = size.height * 0.02;
    final endY = bin.top + bin.height * 0.42;
    final top = startY + (endY - startY) * wasteDrop;
    final scrap = Rect.fromLTWH(left, top, width, height);
    final scrapRadius = RRect.fromRectAndRadius(
      scrap,
      const Radius.circular(2),
    );
    final rim = bin.top + 1;

    if (scrap.bottom <= rim) {
      canvas.drawRRect(scrapRadius, Paint()..color = const Color(0xFFFFE4C8));
      return;
    }

    if (scrap.top < rim) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, rim));
      canvas.drawRRect(scrapRadius, Paint()..color = const Color(0xFFFFE4C8));
      canvas.restore();
    }

    final fade = ((scrap.top - rim) / (bin.height * 0.4)).clamp(0.0, 1.0);
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(bin.left + 2, rim, bin.width - 4, bin.height),
    );
    canvas.drawRRect(
      scrapRadius,
      Paint()..color = const Color(0xFFFFE4C8).withValues(alpha: 1 - fade),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChatTrashDropPainter oldDelegate) {
    return oldDelegate.lidOpen != lidOpen || oldDelegate.wasteDrop != wasteDrop;
  }
}
