import 'package:flutter/material.dart';
import '../../models/forum.dart';
import 'forum_reply_card.dart';

class ForumPostCard extends StatefulWidget {
  final Post post;
  final bool isLoggedIn;
  final VoidCallback onLike;

  // 🔹 baru
  final bool canEdit;                 // boleh lihat tombol edit/delete?
  final VoidCallback? onEdit;         // callback edit
  final VoidCallback? onDelete;       // callback delete

  const ForumPostCard({
    super.key,
    required this.post,
    required this.isLoggedIn,
    required this.onLike,
    this.canEdit = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<ForumPostCard>
    with SingleTickerProviderStateMixin {
  bool isLike = false;
  bool showReplies = false;

  late AnimationController repliesController;
  late Animation<double> repliesAnimation;

  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _textDark = Color(0xFF111827);

  @override
  void initState() {
    super.initState();
    repliesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    repliesAnimation = CurvedAnimation(
      parent: repliesController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    repliesController.dispose();
    super.dispose();
  }

  void toggleReplies() {
    setState(() {
      showReplies = !showReplies;
      if (showReplies) {
        repliesController.forward();
      } else {
        repliesController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Card(
      elevation: 4,
      shadowColor: _primaryBlue.withOpacity(0.08),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _formatDate(post.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ===== REPLY + EDIT/DELETE + VOTE =====
            Row(
              children: [
                // Reply
                InkWell(
                  onTap: toggleReplies,
                  borderRadius: BorderRadius.circular(999),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: _primaryBlue,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Reply',
                        style: TextStyle(
                          color: _primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 🔹 Edit & Delete (kalau boleh)
                if (widget.canEdit) ...[
                  _buildSmallAction(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: const Color(0xFF2563EB),
                    background: const Color(0xFFE0EDFF),
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: 8),
                  _buildSmallAction(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: const Color(0xFFEF4444),
                    background: const Color(0xFFFFE6E6),
                    onTap: widget.onDelete,
                  ),
                  const SizedBox(width: 12),
                ],

                // Like / Dislike
                buildVote(
                  icon: Icons.thumb_up,
                  color: const Color(0xFF16A34A),
                  background: const Color(0xFFE6F9ED),
                  count: post.upvotesCount + (isLike ? 1 : 0),
                  onTap: handleVote,
                ),
                const SizedBox(width: 8),
                buildVote(
                  icon: Icons.thumb_down,
                  color: const Color(0xFFEF4444),
                  background: const Color(0xFFFFE6E6),
                  count: post.downvotesCount,
                  onTap: handleVote,
                ),
              ],
            ),

            // ===== REPLIES =====
            ClipRect(
              child: SizeTransition(
                sizeFactor: repliesAnimation,
                axisAlignment: -1.0,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE5F2FF),
                            Colors.white,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: buildRepliesList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final String? url = widget.post.thumbnailUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 80,
        height: 80,
        color: const Color(0xFFF3F4F6),
        child: url != null && url.isNotEmpty
            ? Image.network(url, fit: BoxFit.cover)
            : const Icon(
                Icons.image,
                size: 32,
                color: Colors.grey,
              ),
      ),
    );
  }

  // 🔹 chip kecil untuk Edit / Delete
  Widget _buildSmallAction({
    required IconData icon,
    required String label,
    required Color color,
    required Color background,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        if (!widget.isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please Login First')),
          );
          return;
        }
        if (onTap != null) onTap();
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVote({
    required IconData icon,
    required Color color,
    required Color background,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleVote() {
    if (!widget.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please Login First')),
      );
      return;
    }
    if (isLike) return;

    setState(() {
      isLike = true;
    });
    widget.onLike();
  }

  Widget buildRepliesList() {
    final replies = widget.post.replies;

    if (replies.isEmpty) {
      return const Text(
        'Belum ada reply. Jadilah yang pertama berkomentar',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < replies.length; i++) ...[
          ForumReplyCard(
            reply: replies[i],
            showDivider: i != replies.length - 1,
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final mm = monthNames[d.month - 1];
    return '$mm ${d.day}, ${d.year}';
  }
}
