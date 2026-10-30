import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/home_cleaning/view/chat/home_cleaning_conversation_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/home_cleaning_home.dart';

class ConversationThread {
  ConversationThread({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isReadReceipt = false,
    required this.avatar,
    this.isOnline = false,
    this.orderId,
  });

  final String id;
  final String name;
  final String lastMessage;
  final String time;
  int unreadCount;
  final bool isReadReceipt;
  final String avatar;
  final bool isOnline;
  final String? orderId;
}

class HomeCleaningMessagesView extends StatefulWidget {
  const HomeCleaningMessagesView({
    super.key,
    required this.controller,
  });

  final HomeCleaningController controller;

  static const _orange = Color(0xFFFF5722);
  static const _ink = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF757575);

  @override
  State<HomeCleaningMessagesView> createState() =>
      _HomeCleaningMessagesViewState();
}

class _HomeCleaningMessagesViewState extends State<HomeCleaningMessagesView> {
  final TextEditingController _searchController = TextEditingController();

  final List<ConversationThread> _threads = [
    ConversationThread(
      id: '1',
      name: 'Ahmed',
      orderId: '#22789007',
      lastMessage: 'Booking #22789007: Lorem ipsum dolor sit...',
      time: '12:45 PM',
      unreadCount: 1,
      avatar: 'lib/water/Assets/Images/delivery_boy1.png',
      isOnline: true,
    ),
    ConversationThread(
      id: '2',
      name: 'Ali Ahmed',
      lastMessage: 'Etiam cursus velit non eros eleifenddic',
      time: 'Just now',
      isReadReceipt: true,
      avatar: 'lib/water/Assets/Images/delivery_boy2.png',
      isOnline: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ConversationThread> get _filteredThreads {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _threads;
    return _threads.where((t) {
      final nameMatches = t.name.toLowerCase().contains(query);
      final msgMatches = t.lastMessage.toLowerCase().contains(query);
      final orderMatches = t.orderId?.toLowerCase().contains(query) ?? false;
      return nameMatches || msgMatches || orderMatches;
    }).toList();
  }

  void _deleteThread(ConversationThread thread) {
    HapticFeedback.lightImpact();
    setState(() {
      _threads.removeWhere((t) => t.id == thread.id);
    });
  }

  void _openConversation(ConversationThread thread) {
    HapticFeedback.lightImpact();
    setState(() {
      thread.unreadCount = 0;
    });

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HomeCleaningConversationView(
          customerName: thread.name,
          orderId: thread.orderId,
          avatarAsset: thread.avatar,
          isOnline: thread.isOnline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final threads = _filteredThreads;

    return Column(
      children: [
        _buildTopBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: _buildSearchBar(),
        ),
        Expanded(
          child: threads.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: threads.length,
                  separatorBuilder: (_, index) => const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Color(0xFFF1F1F1),
                  ),
                  itemBuilder: (context, index) {
                    final thread = threads[index];
                    return _buildThreadItem(thread);
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
              'Messages',
              style: GoogleFonts.inter(
                color: HomeCleaningMessagesView._ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
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
        style: GoogleFonts.inter(
          fontSize: 13,
          color: HomeCleaningMessagesView._ink,
        ),
        decoration: InputDecoration(
          hintText: 'Search customer name or order ID..',
          hintStyle: GoogleFonts.inter(
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
                  icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
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

  Widget _buildThreadItem(ConversationThread thread) {
    return InkWell(
      onTap: () => _openConversation(thread),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFFFE0D0),
                  backgroundImage: AssetImage(thread.avatar),
                ),
                if (thread.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
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
                  Text(
                    thread.name,
                    style: GoogleFonts.inter(
                      color: HomeCleaningMessagesView._ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
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
                GestureDetector(
                  onTap: () => _deleteThread(thread),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: HomeCleaningMessagesView._orange,
                  ),
                ),
                const SizedBox(height: 6),
                if (thread.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: HomeCleaningMessagesView._orange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    alignment: Alignment.center,
                    child: Text(
                      '${thread.unreadCount}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 1,
                      ),
                    ),
                  )
                else if (thread.isReadReceipt)
                  const Icon(
                    Icons.done_all_rounded,
                    size: 15,
                    color: Color(0xFF9E9E9E),
                  )
                else
                  const SizedBox(height: 18),
                const SizedBox(height: 6),
                Text(
                  thread.time,
                  style: GoogleFonts.inter(
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
            'No messages found',
            style: GoogleFonts.inter(
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
