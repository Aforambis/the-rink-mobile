import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../../models/forum.dart';
import '../../theme/app_theme.dart';
import 'forum_reply_card.dart';

class ForumRepliesPanel extends StatefulWidget {
  final Post post;
  final bool isLoggedIn;
  final Future<void> Function(Reply reply, bool isUpvote) onReplyVote;
  final VoidCallback onRequireAuth;
  final String baseUrl;
  final VoidCallback? onAfterReply;

  const ForumRepliesPanel({
    super.key,
    required this.post,
    required this.isLoggedIn,
    required this.onReplyVote,
    required this.onRequireAuth,
    required this.baseUrl,
    this.onAfterReply,
  });

  @override
  State<ForumRepliesPanel> createState() => _ForumRepliesPanelState();
}

class _ForumRepliesPanelState extends State<ForumRepliesPanel> {
  late final TextEditingController _replyController;
  late final FocusNode _replyFocusNode;
  bool _isSendingReply = false;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
    _replyFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
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
      widget.onRequireAuth();
      return;
    }

    setState(() => _isSendingReply = true);

    try {
      final request = context.read<CookieRequest>();
      final url = '${widget.baseUrl}/forum/add-reply-flutter/${widget.post.id}/';

      final response = await request.postJson(
        url,
        jsonEncode({"content": text}),
      ) as Map<String, dynamic>;

      final newReply = Reply.fromJson(response);

      setState(() {
        widget.post.replies.add(newReply);
        widget.post.repliesCount = widget.post.replies.length;
        _replyController.clear();
      });

      widget.onAfterReply?.call(); // optional refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reply: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSendingReply = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final replies = widget.post.replies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (replies.isEmpty)
          const Text(
            'Belum ada reply. Jadilah yang pertama berkomentar',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          )
        else
          for (int i = 0; i < replies.length; i++) ...[
            ForumReplyCard(
              reply: replies[i],
              showDivider: i != replies.length - 1,
              onLike: () => widget.onReplyVote(replies[i], true),
              onDislike: () => widget.onReplyVote(replies[i], false),
              onReplyTap: () => _mentionUserFromReply(replies[i]),
            ),
          ],

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                focusNode: _replyFocusNode,
                decoration: InputDecoration(
                  hintText: 'Create Your Reply',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide:
                        const BorderSide(color: AppColors.frostPrimary),
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
                  backgroundColor: AppColors.frostPrimary,
                  foregroundColor: Colors.white,
                ),
                child: _isSendingReply
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
