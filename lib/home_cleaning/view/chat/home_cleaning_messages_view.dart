import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/controller/chat_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/services_api.dart';
import 'package:saimpex_vendor/home_cleaning/view/chat/home_cleaning_conversation_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/home_cleaning_home.dart';
import 'package:saimpex_vendor/model/conversations_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// Formats a chat timestamp: time today, "Yesterday", else the date.
String cleaningChatTime(BuildContext context, String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return '';
  final dt = parsed.toLocal();
  final now = DateTime.now();
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
    return DateFormat('hh:mm a').format(dt);
  }
  final yesterday = now.subtract(const Duration(days: 1));
  if (dt.year == yesterday.year &&
      dt.month == yesterday.month &&
      dt.day == yesterday.day) {
    return S.of(context).yesterday;
  }
  return DateFormat('dd/MM/yyyy').format(dt);
}

/// Absolute URL for a chat image path (customer avatar).
String? cleaningChatImageUrl(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty || value == 'null') return null;
  return value.startsWith('http') ? value : '${ApiConfigs.IMAGE_URL}$value';
}

/// Customer conversations of this vendor (vendorapp chat/allConversations),
/// shared with the other verticals through [ChatController].
class HomeCleaningMessagesView extends StatefulWidget {
  const HomeCleaningMessagesView({super.key, required this.controller});

  final HomeCleaningController controller;

  static const _orange = Color(0xFFFF5216);
  static const _ink = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF757575);

  @override
  State<HomeCleaningMessagesView> createState() =>
      _HomeCleaningMessagesViewState();
}

class _HomeCleaningMessagesViewState extends State<HomeCleaningMessagesView> {
  final TextEditingController _searchController = TextEditingController();
  late final ChatController _chat;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _chat = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    _loading = _chat.conversations.isEmpty;
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads the list here (rather than through ChatController, which swallows
  /// errors) so a failure can show an error state, then hands the result to
  /// the shared controller so Pusher updates keep it fresh.
  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final token = (await getSavedObject('token'))?.toString() ?? '';
      if (token.isNotEmpty && token != 'null') DioClient().updateToken(token);
      final response = await DioClient().get(
        ApiEndPoints.allConversations,
        query: {'page': 1},
      );
      final data = response.data;
      if (data is! Map) throw const CleaningApiException(null);
      final body = Map<String, dynamic>.from(data);
      if (!CleaningServicesApi.isOk(body)) {
        throw CleaningApiException(CleaningServicesApi.serverMessage(body));
      }
      final model = ConversationsModel.fromJson(body);
      final list = model.data?.conversations ?? <Conversation>[];
      list.sort((a, b) {
        final ta =
            DateTime.tryParse(
              a.lastMessageAt ?? a.lastMessage?.createdAt ?? '',
            ) ??
            DateTime(0);
        final tb =
            DateTime.tryParse(
              b.lastMessageAt ?? b.lastMessage?.createdAt ?? '',
            ) ??
            DateTime(0);
        return tb.compareTo(ta);
      });
      _chat.conversations = list;
      _chat.update();
    } on CleaningApiException catch (e) {
      if (mounted) _error = e.message ?? S.of(context).cleaningSvcChatLoadError;
    } on String catch (message) {
      if (mounted) _error = message;
    } catch (_) {
      if (mounted) _error = S.of(context).cleaningSvcChatLoadError;
    }
    if (mounted) setState(() => _loading = false);
  }

  String _name(Conversation c) {
    final name = c.customer?.name?.trim();
    return name == null || name.isEmpty ? S.of(context).waterCustomer : name;
  }

  String _preview(Conversation c) {
    final last = c.lastMessage;
    if (last == null) return '';
    switch (last.messageType?.toLowerCase()) {
      case 'image':
        return '📷 ${S.of(context).waterImage}';
      case 'voice':
      case 'audio':
        return '🎤 ${S.of(context).waterVoiceMessage}';
      default:
        return last.message ?? '';
    }
  }

  List<Conversation> _filtered(List<Conversation> all) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return all;
    return all.where((c) {
      return _name(c).toLowerCase().contains(query) ||
          _preview(c).toLowerCase().contains(query) ||
          (c.orderId?.toString().contains(query) ?? false);
    }).toList();
  }

  Future<void> _openConversation(Conversation c) async {
    HapticFeedback.lightImpact();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HomeCleaningConversationView(
          customerName: _name(c),
          orderId: c.orderId?.toString(),
          conversationId: c.id,
          customerId: c.customerId ?? c.customer?.id,
          avatarUrl: cleaningChatImageUrl(c.customer?.image ?? c.image),
        ),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: _buildSearchBar(),
        ),
        Expanded(
          child: GetBuilder<ChatController>(
            init: _chat,
            builder: (chat) {
              if (_loading && chat.conversations.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: HomeCleaningMessagesView._orange,
                  ),
                );
              }
              if (_error != null && chat.conversations.isEmpty) {
                return _buildErrorState();
              }
              final threads = _filtered(chat.conversations);
              return RefreshIndicator(
                color: HomeCleaningMessagesView._orange,
                onRefresh: _load,
                child: threads.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 320, child: _buildEmptyState()),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: threads.length,
                        separatorBuilder: (_, index) => const Divider(
                          height: 1,
                          thickness: 0.8,
                          color: Color(0xFFF1F1F1),
                        ),
                        itemBuilder: (context, index) =>
                            _buildThreadItem(threads[index]),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              S.of(context).cleaningMessages,
              style: appFont('Inter', 
                color: HomeCleaningMessagesView._ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.controller.setNavIndex(0);
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
                    color: HomeCleaningMessagesView._orange,
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

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: appFont('Inter', 
          fontSize: 13,
          color: HomeCleaningMessagesView._ink,
        ),
        decoration: InputDecoration(
          hintText: S.of(context).cleaningSearchCustomerOrOrderId,
          hintStyle: appFont('Inter', 
            color: const Color(0xFF94A3B8),
            fontSize: 12.5,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: false,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildThreadItem(Conversation thread) {
    final name = _name(thread);
    final avatarUrl = cleaningChatImageUrl(
      thread.customer?.image ?? thread.image,
    );
    final unread = thread.unreadCount ?? 0;
    final last = thread.lastMessage;
    final sentByMe = last?.senderType?.toLowerCase() == 'vendor';
    final readByCustomer = sentByMe && last?.isRead == true;
    return InkWell(
      onTap: () => _openConversation(thread),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CleaningChatAvatar(name: name, imageUrl: avatarUrl, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: appFont('Inter', 
                      color: HomeCleaningMessagesView._ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _preview(thread),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appFont('Inter', 
                      color: HomeCleaningMessagesView._muted,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (unread > 0)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: HomeCleaningMessagesView._orange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$unread',
                      style: appFont('Inter', 
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 1,
                      ),
                    ),
                  )
                else if (readByCustomer)
                  const Icon(
                    Icons.done_all_rounded,
                    size: 15,
                    color: Color(0xFF9E9E9E),
                  )
                else
                  const SizedBox(height: 18),
                const SizedBox(height: 6),
                Text(
                  cleaningChatTime(
                    context,
                    thread.lastMessageAt ?? last?.createdAt,
                  ),
                  style: appFont('Inter', 
                    color: const Color(0xFF9E9E9E),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      color: HomeCleaningMessagesView._orange,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: Color(0xFFBDBDBD),
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: appFont('Inter', 
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: OutlinedButton(
              onPressed: () {
                setState(() => _loading = true);
                _load();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: HomeCleaningMessagesView._orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                S.of(context).tryAgain,
                style: appFont('Inter', 
                  color: HomeCleaningMessagesView._orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            S.of(context).cleaningNoMessagesFound,
            style: appFont('Inter', 
              color: const Color(0xFF9E9E9E),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Customer avatar: network photo, or the name's first letter.
class CleaningChatAvatar extends StatelessWidget {
  const CleaningChatAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
  });

  final String name;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final fallback = Text(
      initial,
      style: appFont('Inter', 
        color: const Color(0xFFFF5216),
        fontWeight: FontWeight.w700,
        fontSize: radius * 0.75,
      ),
    );
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFFFE0D0),
      child: imageUrl == null
          ? fallback
          : ClipOval(
              child: Image.network(
                imageUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
            ),
    );
  }
}
