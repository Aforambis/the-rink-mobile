class CommunityPost {
  final String id;
  final String username;
  final String content;
  final int likes;
  final String timeAgo;
  final String avatarColor;

  CommunityPost({
    required this.id,
    required this.username,
    required this.content,
    required this.likes,
    required this.timeAgo,
    required this.avatarColor,
  });
}
