// forum_leaderboard_post.dart
import 'package:flutter/material.dart';
import '../../models/forum.dart';
import '../../widgets/forum/forum_reply_card.dart';

class ForumLeaderboardPost extends StatelessWidget {
  final List<Post> allPosts;
  final bool isLoggedIn;
  final Future<void> Function(Post post, bool isUpvote) onVote;

  const ForumLeaderboardPost({
    super.key,
    required this.allPosts,
    required this.isLoggedIn,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    if (allPosts.isEmpty) return const SizedBox.shrink();

    final sorted = [...allPosts];
    sorted.sort((a, b) {
      final scoreA = a.upvotesCount - a.downvotesCount + a.repliesCount;
      final scoreB = b.upvotesCount - b.downvotesCount + b.repliesCount;
      return scoreB.compareTo(scoreA);
    });
    final top5 = sorted.take(5).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE0F2FF),
              Color(0xFFCCE4FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '❄ Top Posts This Week',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < top5.length; i++) ...[
                _LeaderboardPostTile(
                  rank: i + 1,
                  post: top5[i],
                  isLoggedIn: isLoggedIn,
                  onVote: onVote,
                ),
                if (i != top5.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardPostTile extends StatefulWidget {
  final int rank;
  final Post post;
  final bool isLoggedIn;
  final Future<void> Function(Post post, bool isUpvote) onVote;

  const _LeaderboardPostTile({
    required this.rank,
    required this.post,
    required this.isLoggedIn,
    required this.onVote,
  });

  @override
  State<_LeaderboardPostTile> createState() => _LeaderboardPostTileState();
}

class _LeaderboardPostTileState extends State<_LeaderboardPostTile>
    with SingleTickerProviderStateMixin {
  bool showReplies = false;
  bool isVoting = false;  
  late final AnimationController _controller;
  late final Animation<double> _sizeAnimation;

  static const Color _primaryBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleReplies() {
    setState(() {
      showReplies = !showReplies;
      if (showReplies) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Badge rank
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                '${widget.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                color: const Color(0xFFF3F4F6),
                child: (post.thumbnailUrl.isNotEmpty)
                    ? Image.network(post.thumbnailUrl, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 26, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),

            // Isi Post
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(post.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Title
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Content
                  Text(
                    post.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Like/Dislike + Reply button
                  Row(
                    children: [
                      InkWell(
                        onTap: _toggleReplies,
                        borderRadius: BorderRadius.circular(999),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                              color: _primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reply (${post.repliesCount})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStat(
                        icon: Icons.thumb_up,
                        color: const Color(0xFF16A34A),
                        value: post.upvotesCount,
                        isUpvote: true,
                      ),
                      const SizedBox(width: 8),
                      _buildStat(
                        icon: Icons.thumb_down,
                        color: const Color(0xFFEF4444),
                        value: post.downvotesCount,
                        isUpvote: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        // Replies
        ClipRect(
          child: SizeTransition(
            sizeFactor: _sizeAnimation,
            axisAlignment: -1.0,
            child: Container(
              margin: const EdgeInsets.only(top: 10, left: 40),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: _buildRepliesList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat({
    required IconData icon,
    required Color color,
    required int value,
    required bool isUpvote,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () async {
        if (isVoting) return;

        setState(() {
          isVoting = true;
        });

        
        try {
          await widget.onVote(widget.post, isUpvote);
        } 
        finally {
          if (mounted) {
            setState(() {
              isVoting = false;  
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withOpacity(0.08),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 3),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesList() {
    final replies = widget.post.replies;

    if (replies.isEmpty) {
      return const Text(
        'No replies yet. Be the first to comment.',
        style: TextStyle(
          fontSize: 12,
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
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

