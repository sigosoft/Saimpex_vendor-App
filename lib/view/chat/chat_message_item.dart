import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';

/// A single message bubble in the chat details screen.
/// [isSent] controls alignment and colors (orange/right for sent, gray/left for received).
class ChatMessageItem extends StatelessWidget {
  const ChatMessageItem({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isSent,
    this.showCheckmark = true,
    this.messageType = 'text',
    this.attachmentUrl,
  });

  final String message;
  final String timestamp;
  final bool isSent;
  final bool showCheckmark;
  final String messageType;
  final String? attachmentUrl;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSent ? colorPrimary : chatgrey,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isSent ? 16 : 4),
              bottomRight: Radius.circular(isSent ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (messageType == 'image' && attachmentUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      attachmentUrl!.startsWith('http')
                          ? attachmentUrl!
                          : "${ApiConfigs.IMAGE_URL}${attachmentUrl!.startsWith('/') ? attachmentUrl!.substring(1) : attachmentUrl!}",
                      width: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else if (message.isNotEmpty)
                Text(
                  message,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isSent ? Colors.white : Colors.black,
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    timestamp,
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: isSent ? Colors.white70 : mutedTextColor,
                    ),
                  ),
                  if (isSent && showCheckmark) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
