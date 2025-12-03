import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../theme/app_theme.dart';

class CommunityPostCard extends StatefulWidget {
  final CommunityPost post;
  final bool isLoggedIn;
  final VoidCallback onLike;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.isLoggedIn,
    required this.onLike,
  });

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  bool _isLiked = false;

  Color _getAvatarColor() {
    switch (widget.post.avatarColor) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'purple':
        return AppColors.frostPrimary;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: WinterTheme.frostedCard(),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getAvatarColor(),
                  child: Text(
                    widget.post.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.post.timeAgo,
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.post.content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    widget.onLike();
                    if (widget.isLoggedIn) {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                    }
                  },
                ),
                Text(
                  '${widget.post.likes + (_isLiked ? 1 : 0)}',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: widget.onLike,
                ),
                Text('Comment', style: TextStyle(color: AppColors.mutedText)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
