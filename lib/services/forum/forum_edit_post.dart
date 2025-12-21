import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:the_rink_mobile/models/forum.dart';
import 'package:the_rink_mobile/theme/app_theme.dart';

Future<bool> showEditPostDialog(BuildContext parentContext, Post post) async {
  final titleController = TextEditingController(text: post.title);
  final contentController = TextEditingController(text: post.content);
  final thumbController = TextEditingController(text: post.thumbnailUrl);

  try {
    final result = await showGeneralDialog<bool>(
      context: parentContext,
      useRootNavigator: true, 
      barrierDismissible: true,
      barrierLabel: 'Edit Post',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Material(
                color: Colors.transparent,
                child: _EditPostCard(
                  parentContext: parentContext,
                  postId: post.id,
                  titleController: titleController,
                  contentController: contentController,
                  thumbController: thumbController,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
    if (result == true) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(content: Text('Post updated successfully')),
      );
    }
    return result ?? false;
  } 
  finally {
    titleController.dispose();
    contentController.dispose();
    thumbController.dispose();
  }
}

class _EditPostCard extends StatefulWidget {
  final BuildContext parentContext;
  final int postId;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController thumbController;

  const _EditPostCard({
    required this.parentContext,
    required this.postId,
    required this.titleController,
    required this.contentController,
    required this.thumbController,
  });

  @override
  State<_EditPostCard> createState() => _EditPostCardState();
}

class _EditPostCardState extends State<_EditPostCard> {
  bool hasSaved = false;

  Future<void> _submit() async {
    final title = widget.titleController.text.trim();
    final content = widget.contentController.text.trim();
    final thumbnail = widget.thumbController.text.trim();

    if (title.isEmpty || content.isEmpty || thumbnail.isEmpty) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(content: Text('The title, thumbnail, and content cannot be empty!')),
      );
      return;
    }

    if (content.length > 300) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text('Max 300 chars (currently ${content.length}).')),
      );
      return;
    }

    if (hasSaved) return;
    setState(() => hasSaved = true);

    try {
      final request = context.read<CookieRequest>(); 
      final response = await request.postJson(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/forum/edit-post-flutter/${widget.postId}/',
        jsonEncode({
          'title': title,
          'content': content,
          'thumbnail_url': thumbnail,
        }),
      );

      if (response is Map && response['status'] == 'success') {
        if (!mounted) return;

        // ✅ pop dialog yang bener
        Navigator.of(context, rootNavigator: true).pop(true);
        return;
      }

      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(response['message']?.toString() ?? 'Failed to update post')),
      );
    } catch (e) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text('Failed to update post: $e')),
      );
    } finally {
      if (mounted) setState(() => hasSaved = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE0F2FF), Color(0xFFBFDFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit your post',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: widget.titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter post title...',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: widget.contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Insert a Content in here...',
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.image_outlined, size: 18, color: Color(0xFF22B8CF)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextField(
                                controller: widget.thumbController,
                                decoration: const InputDecoration(
                                  hintText: 'Paste image URL here',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: hasSaved
                            ? null
                            : () => Navigator.of(context, rootNavigator: true).pop(false), 
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          side: BorderSide(color: AppColors.frostPrimary.withOpacity(0.4)),
                          foregroundColor: AppColors.frostPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 10),

                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: hasSaved ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          backgroundColor: AppColors.frostPrimary,
                          foregroundColor: Colors.white,
                        ),
                        child: hasSaved
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Save', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
