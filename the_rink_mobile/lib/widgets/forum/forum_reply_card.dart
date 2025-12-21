import 'package:flutter/material.dart';
import 'package:the_rink_mobile/theme/app_theme.dart';
import '../../models/forum.dart';

const Color _primaryBlue = Color(0xFF2563EB);
const Color _textDark = Color(0xFF111827);

class ForumReplyCard extends StatelessWidget {
  final Reply reply;
  final bool showDivider;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onReplyTap;

  const ForumReplyCard({
    super.key,
    required this.reply,
    this.showDivider = false,
    this.onLike,
    this.onDislike,
    this.onReplyTap,
  });

  String timeAgoId(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());

    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) return '$weeks minggu yang lalu';

    final months = (diff.inDays / 30).floor();
    if (months < 12) return '$months bulan yang lalu';

    final years = (diff.inDays / 365).floor();
    return '$years tahun yang lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
            StreamBuilder<int>(
              stream: Stream.periodic(const Duration(minutes: 1), (i) => i),
              builder: (_, __) => Text(
                timeAgoId(reply.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
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

        // ROW UPVOTE/DOWNVOTE + REPLY
        Row(
          children: [
            InkWell(
              onTap: onLike,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            ),
            const SizedBox(width: 8),

            // 👎 Dislike
            InkWell(
              onTap: onDislike,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            ),
            const SizedBox(width: 10),

            // Reply 
            GestureDetector(
              onTap: onReplyTap,
              child: const Text(
                'Reply',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.frostPrimary,
                  fontWeight: FontWeight.w500,
                ),
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
