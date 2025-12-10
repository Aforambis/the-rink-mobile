import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:the_rink_mobile/widgets/auth_modal_sheet.dart';
import '../../models/forum.dart';
import 'forum_reply_card.dart';

class ForumPostCard extends StatefulWidget {
  final Post post;
  final bool isLoggedIn;
  final bool canEdit;    
  final VoidCallback onActionRequired;
  final VoidCallback? onEdit;    
  final VoidCallback? onDelete;     
  final Future<void> Function(Reply reply, bool isUpvote) onReplyVote;

  const ForumPostCard({
    super.key,
    required this.post,
    required this.isLoggedIn,
    this.canEdit = false,
    required this.onActionRequired,
    this.onEdit,
    this.onDelete,
    required this.onReplyVote,
  });

  @override
  State<ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<ForumPostCard>
    with SingleTickerProviderStateMixin {
  bool isVoting = false;
  bool showReplies = false;

   // ⬇️ baru
  late TextEditingController _replyController;
  late FocusNode _replyFocusNode;
  bool _isSendingReply = false;

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

     _replyController = TextEditingController();
    _replyFocusNode = FocusNode();
  }

  @override
  void dispose() {
    repliesController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
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

  void _mentionUserFromReply(Reply reply) {
    final mention = '@${reply.author} ';
    setState(() {
      _replyController.text = mention;
      _replyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _replyController.text.length),
      );
    });
    _replyFocusNode.requestFocus();
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    if (!widget.isLoggedIn) {
      _showAuthModal();
      return;
    }

    setState(() => _isSendingReply = true);

    try {
      final request = context.read<CookieRequest>();

      final response = await request.postJson(
        'http://localhost:8000/forum/add-reply-flutter/${widget.post.id}/',
        {
          'content': text,
        },
      ) as Map<String, dynamic>;

      // backend balikin { success: true, reply: {...} }
      final newReply = Reply.fromJson(response['reply']);

      setState(() {
        widget.post.replies.add(newReply);
        widget.post.repliesCount = widget.post.replies.length;
        _replyController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reply: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSendingReply = false);
    }
  }


    Widget buildThumbnail() {
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

  // Tombol kecil untuk Edit / Delete
  Widget _buildSmallAction({
    required IconData icon,
    required String label,
    required Color color,
    required Color background,
    required VoidCallback? onTap,
  }) {
    return InkWell(
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

  Widget buildVote(
    {
    required IconData icon,
    required Color color,
    required Color background,
    required int count,
    required VoidCallback onTap,
    }) 
    {
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
  
  bool get isLoggedIn {
    final request = context.read<CookieRequest>();
    return request.jsonData['status'] == true;
  }

  Future<void> handleVote(Post post, bool isUpvote) async {
    if (isVoting) return; 

    if (!isLoggedIn) {
      _showAuthModal();
      return;
    }

    setState(() {
      isVoting = true;         
    });

    try {
      final request = context.read<CookieRequest>();
      final response = await request.postJson(
        'http://localhost:8000/forum/toggle-vote-flutter/',
        jsonEncode({
          'type': 'post',
          'id': post.id,
          'is_upvote': isUpvote,
        }),
      ) as Map<String, dynamic>;

      setState(() {
        post.upvotesCount  = (response['upvotes']  ?? post.upvotesCount)  as int;
        post.downvotesCount = (response['downvotes'] ?? post.downvotesCount) as int;
      });
    } 
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to vote: $e')),
      );
    }
    finally {
    if (mounted) {
      setState(() {
        isVoting = false;      
      });
    }
  }
  }

  void _showAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AuthModalSheet(

          // Google
          onGoogleSignIn: () {
            Navigator.of(sheetContext).pop();
            widget.onActionRequired(); 
          },

          // Login/Register Biasa
          onUsernamePasswordSignIn: () {
            Navigator.of(sheetContext).pop();
            widget.onActionRequired(); 
          },

          // Guest Access
          onContinueAsGuest: () {
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

    Widget buildRepliesList() {
    final replies = widget.post.replies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (replies.isEmpty)
          const Text(
            'Belum ada reply. Jadilah yang pertama berkomentar',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          )
        else
          for (int i = 0; i < replies.length; i++) ...[
            ForumReplyCard(
              reply: replies[i],
              showDivider: i != replies.length - 1,
              // ⬇️ like/dislike reply → panggil endpoint vote reply
              onLike: () => widget.onReplyVote(replies[i], true),
              onDislike: () => widget.onReplyVote(replies[i], false),
              // ⬇️ klik "Reply" → auto mention
              onReplyTap: () => _mentionUserFromReply(replies[i]),
            ),
          ],

        const SizedBox(height: 12),

        // ====== INPUT BALASAN DI BAWAHNYA ======
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                focusNode: _replyFocusNode,
                decoration: InputDecoration(
                  hintText: 'Tulis balasan...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: _primaryBlue),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: _isSendingReply ? null : _sendReply,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: _isSendingReply
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Send',
                        style: TextStyle(fontSize: 13),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  String formatDate(DateTime dt) {
    final d = dt.toLocal();
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final mm = monthNames[d.month - 1];
    return '$mm ${d.day}, ${d.year}';
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
                buildThumbnail(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Tanggal Rilis Post
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatDate(post.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),

                      // Title
                      const SizedBox(height: 6),
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),

                      // Content
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

                // Edit & Delete (kalau punya user)
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

                // Like / DisVoting
                buildVote(
                  icon: Icons.thumb_up,
                  color: const Color(0xFF16A34A),
                  background: const Color(0xFFE6F9ED),
                  count: post.upvotesCount,
                  onTap: () => handleVote(post, true),
                ),
                const SizedBox(width: 8),
                buildVote(
                  icon: Icons.thumb_down,
                  color: const Color(0xFFEF4444),
                  background: const Color(0xFFFFE6E6),
                  count: post.downvotesCount,
                  onTap: () => handleVote(post, false),
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
}
