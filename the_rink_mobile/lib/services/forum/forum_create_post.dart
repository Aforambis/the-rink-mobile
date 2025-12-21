import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:the_rink_mobile/theme/app_theme.dart';

class ForumCreatePostCard extends StatefulWidget {
  final bool isLoggedIn;
  final VoidCallback? onPostCreated;

  const ForumCreatePostCard({
    super.key,
    required this.isLoggedIn,
    this.onPostCreated,
  });

  @override
  State<ForumCreatePostCard> createState() => _ForumCreatePostCardState();
}

class _ForumCreatePostCardState extends State<ForumCreatePostCard> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _thumbnailController = TextEditingController();

  bool hasSubmitted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    // Make Form
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final thumbnail = _thumbnailController.text.trim();

    if (title.isEmpty || content.isEmpty || thumbnail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The title, thumbnail, and content cannot be empty!')),
      );
      return;
    }

    if (content.length > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'The maximum content consists of only 300 characters (currently ${content.length}).',
          ),
        ),
      );
      return;
    }

    if (hasSubmitted) return;

    setState(() {
      hasSubmitted = true;
    });

    try {
      final request = context.read<CookieRequest>();
      final response = await request.postJson(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/forum/add-post-flutter/',
        jsonEncode({
          'title': title,
          'content': content,
          'thumbnail_url': thumbnail,
        }),
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Unknown error');
      }

      // Clear form
      _titleController.clear();
      _contentController.clear();
      _thumbnailController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );
      widget.onPostCreated?.call();
    } 
    catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $error')),
      );
    } 
    finally {
      if (mounted) {
        setState(() {
          hasSubmitted = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    Center(
      child: 
      ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,  
        ),
        child: 
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: 
            BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE0F2FF),
                Color(0xFFBFDFFF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            ),
          child: 
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: 
            BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: 
            Column(
              mainAxisSize: MainAxisSize.min,         
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header
                const Text(
                  'What do you think?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter post title...',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Content
                TextField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Insert a Content in here...',
                    alignLabelWithHint: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Footer : Thumbnail URL + Post button
                Row(
                  children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: 
                      Row(
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            size: 18,
                            color: Color(0xFF22B8CF),
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: 
                            TextField(
                              controller: _thumbnailController,
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
                    child: 
                    ElevatedButton(
                      onPressed: hasSubmitted ? null : handleSubmit,
                      style: 
                      ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: 
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        backgroundColor: AppColors.frostPrimary,
                        foregroundColor: Colors.white,
                      ),
                      child: hasSubmitted ? 
                        const SizedBox(
                        width: 18,
                        height: 18,
                        child: 
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: 
                            AlwaysStoppedAnimation<Color>(
                            Colors.white,
                            ),
                          ),
                        )
                        : 
                        const Text(
                          'Post',
                          style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          ),
                        ),
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
