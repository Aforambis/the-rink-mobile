// lib/widgets/forum/forum_reply_card.dart
import 'package:flutter/material.dart';
import '../../models/forum.dart';

const Color _primaryBlue = Color(0xFF2563EB);
const Color _textDark = Color(0xFF111827);

class ForumReplyCard extends StatelessWidget {
  final Reply reply;
  final bool showDivider;

  const ForumReplyCard({
    super.key,
    required this.reply,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER REPLY (avatar + nama + tanggal)
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  (reply.author.isNotEmpty ? reply.author[0] : '?')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reply.author,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _primaryBlue,
                ),
              ),
            ),
            Text(
              reply.createdAt.toString(), // kalau mau bisa diformat cantik
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ISI REPLY
        Text(
          reply.content,
          style: const TextStyle(
            fontSize: 13,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 10),

        // ROW UPVOTE/DOWNVOTE
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F9ED),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(Icons.thumb_up,
                      size: 14, color: Color(0xFF16A34A)),
                  const SizedBox(width: 3),
                  Text(
                    '${reply.upvotesCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE6E6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(Icons.thumb_down,
                      size: 14, color: Color(0xFFEF4444)),
                  const SizedBox(width: 3),
                  Text(
                    '${reply.downvotesCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Reply',
              style: TextStyle(
                fontSize: 12,
                color: _primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
