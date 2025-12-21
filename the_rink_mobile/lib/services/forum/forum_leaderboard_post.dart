import 'package:flutter/material.dart';
import 'package:the_rink_mobile/widgets/forum/forum_replies_panel.dart';
import '../../models/forum.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ForumLeaderboardPost extends StatelessWidget {
  final List<Post> topPosts;
  final bool isLoggedIn;
  final Future<void> Function(Post post, bool isUpvote) onVote;

  final Future<void> Function(Reply reply, bool isUpvote) onReplyVote;
  final VoidCallback onRequireAuth;
  final String baseUrl;
  final VoidCallback? onAfterAction;

  const ForumLeaderboardPost({
    super.key,
    required this.topPosts,
    required this.isLoggedIn,
    required this.onVote,
    required this.onReplyVote,
    required this.onRequireAuth,
    required this.baseUrl,
    required this.onAfterAction,
  });

  @override
  Widget build(BuildContext context) {
    if (topPosts.isEmpty) return const SizedBox.shrink();

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
              for (int i = 0; i < topPosts.length; i++) ...[
                _LeaderboardPostTile(
                  rank: i + 1,
                  post: topPosts[i],
                  isLoggedIn: isLoggedIn,
                  onVote: onVote,
                  onReplyVote: onReplyVote,
                  onRequireAuth: onRequireAuth,
                  baseUrl: baseUrl,
                  onAfterAction: onAfterAction,
                ),
                if (i != topPosts.length - 1) const SizedBox(height: 12),
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

  final Future<void> Function(Reply reply, bool isUpvote) onReplyVote;
  final VoidCallback onRequireAuth;
  final String baseUrl;
  final VoidCallback? onAfterAction;

  const _LeaderboardPostTile({
    required this.rank,
    required this.post,
    required this.isLoggedIn,
    required this.onVote,
    required this.onReplyVote,
    required this.onRequireAuth,
    required this.baseUrl,
    required this.onAfterAction,
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

  Future<void> votePost(bool isUpvote) async {
    if (!widget.isLoggedIn) {
      widget.onRequireAuth(); // <-- wajib ada ()
      return;
    }
    if (isVoting) return;

    setState(() => isVoting = true);

    try {
      final request = context.read<CookieRequest>();
      final resp = await request.postJson(
        '${widget.baseUrl}/forum/toggle-vote-flutter/',
        jsonEncode({
          'type': 'post',
          'id': widget.post.id,
          'is_upvote': isUpvote,
        }),
      ) as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        widget.post.upvotesCount =
            (resp['upvotes'] ?? widget.post.upvotesCount) as int;
        widget.post.downvotesCount =
            (resp['downvotes'] ?? widget.post.downvotesCount) as int;
      });

      // OPTIONAL: kalau kamu masih mau parent rebuild tanpa refetch:
      // widget.onAfterAction?.call();  <-- tapi pastikan ini "soft refresh", bukan reloadPost
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to vote: $e')),
      );
    } finally {
      if (mounted) setState(() => isVoting = false);
    }
  }


  String _proxyUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.contains('/forum/proxy-image/')) return imageUrl;

    final encoded = Uri.encodeComponent(imageUrl);
    return 'http://localhost:8000/forum/proxy-image/?url=$encoded';
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
                  ? Image.network(
                    _proxyUrl(post.thumbnailUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 26, color: Colors.grey);
                    },
                  )
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
                      buildStat(
                        icon: Icons.thumb_up,
                        color: const Color(0xFF16A34A),
                        value: post.upvotesCount,
                        isUpvote: true,
                      ),
                      const SizedBox(width: 8),
                      buildStat(
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
              child: ForumRepliesPanel(
                post: widget.post,
                isLoggedIn: widget.isLoggedIn,
                onReplyVote: widget.onReplyVote,
                onRequireAuth: widget.onRequireAuth,
                baseUrl: widget.baseUrl,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStat({
    required IconData icon,
    required Color color,
    required int value,
    required bool isUpvote,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () async {
        await votePost(isUpvote);
      },
      child: 
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withOpacity(0.08),
        ),
        child: 
        Row(
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

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

