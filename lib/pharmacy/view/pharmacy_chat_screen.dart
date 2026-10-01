import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/pharmacy/controller/pharmacy_chat_controller.dart';

class _MessageThread {
  const _MessageThread({
    required this.name,
    required this.preview,
    required this.time,
    required this.avatar,
    this.unreadCount = 0,
    this.isOnline = false,
    this.showReadReceipt = false,
  });

  final String name;
  final String preview;
  final String time;
  final String avatar;
  final int unreadCount;
  final bool isOnline;
  final bool showReadReceipt;
}

class PharmacyMessagesTab extends StatefulWidget {
  const PharmacyMessagesTab({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<PharmacyMessagesTab> createState() => _PharmacyMessagesTabState();
}

class _PharmacyMessagesTabState extends State<PharmacyMessagesTab> {
  late final PharmacyChatController controller;

  static const _threads = <_MessageThread>[
    _MessageThread(
      name: 'Ahmed',
      preview: 'Order #22789007: Is the prescription ready',
      time: '12:45 PM',
      avatar: 'lib/water/Assets/Images/delivery_boy3.png',
      unreadCount: 1,
    ),
    _MessageThread(
      name: 'Ali Ahmed',
      preview: 'Etiam cursus velit non eros eleifenddic',
      time: 'Just now',
      avatar: 'lib/water/Assets/Images/delivery_boy1.png',
      isOnline: true,
      showReadReceipt: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(PharmacyChatController());
  }

  @override
  void dispose() {
    Get.delete<PharmacyChatController>();
    super.dispose();
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
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                return Column(
                  children: [
                    _MessageTile(
                      thread: thread,
                      onTap: () => PharmacyChatScreen.open(
                        context,
                        customerName: thread.name,
                      ),
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
          const Icon(
            Icons.search_rounded,
            color: Color(0xFFB0B0B0),
            size: 22,
          ),
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
  const _MessageTile({required this.thread, required this.onTap});

  final _MessageThread thread;
  final VoidCallback onTap;

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
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: _orange,
                        size: 22,
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
                            fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
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
  const _ThreadAvatar({required this.asset, required this.isOnline});

  final String asset;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Image.asset(
              asset,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.35),
            ),
          ),
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


class PharmacyChatScreen extends StatelessWidget {
  const PharmacyChatScreen({
    super.key,
    this.customerName = 'Ahmed',
  });

  final String customerName;

  static const _bg = Color(0xFFFBF6F0);
  static const _name = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF9A9A9A);
  static const _time = Color(0xFFA3A3A8);
  static const _orange = Color(0xFFFF5722);
  static const _bubble = Color(0xFF1A1A1A);
  static const _input = Color(0xFFF3EEE6);
  static const _avatar = 'lib/water/Assets/Images/delivery_boy3.png';

  static void open(BuildContext context, {String customerName = 'Ahmed'}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyChatScreen(customerName: customerName),
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
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _Header(
                name: customerName,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  children: const [
                    Center(child: _DatePill(label: 'Today')),
                    SizedBox(height: 18),
                    _IncomingBubble(
                      text:
                          'Hello Ahmed! Your order #22789000 is being ready. Would you like to add anything else?',
                      time: '12:42 PM',
                    ),
                    SizedBox(height: 16),
                    _AudioBubble(duration: '0:12', time: '12:44 PM'),
                    SizedBox(height: 16),
                    _IncomingBubble(
                      text:
                          'Perfect, thank you! How long until the delivery starts?',
                      time: '12:42 PM',
                    ),
                  ],
                ),
              ),
              const _InputBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.onBack});

  final String name;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
          ClipOval(
            child: Image.asset(
              PharmacyChatScreen._avatar,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.25),
            ),
          ),
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

class _AudioBubble extends StatelessWidget {
  const _AudioBubble({required this.duration, required this.time});

  final String duration;
  final String time;

  static const _heights = <double>[
    7, 12, 9, 16, 11, 18, 8, 14, 10, 17,
    12, 7, 15, 11, 19, 9, 13, 8, 16, 10,
    14, 7, 12, 10, 17, 9, 13, 8, 15, 11,
  ];

  @override
  Widget build(BuildContext context) {
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
                            padding: const EdgeInsets.symmetric(horizontal: 0.7),
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
            const Icon(
              Icons.done_all_rounded,
              size: 15,
              color: PharmacyChatScreen._orange,
            ),
          ],
        ),
      ],
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar();

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
                  const Icon(
                    Icons.add,
                    color: Color(0xFF8E8E93),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Type a message...',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFC5C5C5),
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      height: 1,
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
          Container(
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
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
