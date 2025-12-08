import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../models/forum.dart';

Future<bool> showEditPostDialog(BuildContext context, Post post) async {
  final titleController = TextEditingController(text: post.title);
  final contentController = TextEditingController(text: post.content);
  final thumbController = TextEditingController(text: post.thumbnailUrl);

  final request = context.read<CookieRequest>();
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      bool isSaving = false;

      return StatefulBuilder(
        builder: (ctx, setState) {
          Future<void> submit() async {
            final title = titleController.text.trim();
            final content = contentController.text.trim();
            final thumb = thumbController.text.trim();

            if (title.isEmpty || content.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('The title and content cannot be empty.'),
                ),
              );
              return;
            }

            setState(() => isSaving = true);

            try {
              final response = await request.postJson(
                'http://localhost:8000/forum/edit-post-flutter/${post.id}/',
                {
                  'title': title,
                  'content': content,
                  'thumbnail_url': thumb,
                },
              );

              if (response['status'] == 'success') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post updated')),
                );
                Navigator.of(ctx).pop(true); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      response['message'] ?? 'Failed to update post',
                    ),
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            } finally {
              setState(() => isSaving = false);
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Edit Post'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: thumbController,
                    decoration: const InputDecoration(
                      labelText: 'Thumbnail URL',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () {
                  Navigator.of(ctx).pop(false);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSaving ? null : submit,
                child: isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  titleController.dispose();
  contentController.dispose();
  thumbController.dispose();

  return result ?? false;
}
