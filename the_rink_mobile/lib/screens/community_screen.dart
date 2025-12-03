import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';
import '../theme/app_theme.dart';

class CommunityScreen extends StatelessWidget {
  final List<CommunityPost> posts;
  final bool isLoggedIn;
  final VoidCallback onActionRequired;

  const CommunityScreen({
    super.key,
    required this.posts,
    required this.isLoggedIn,
    required this.onActionRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Community'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.auroraGradient),
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Container(
        decoration: WinterTheme.pageBackground(),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 100),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return CommunityPostCard(
              post: post,
              isLoggedIn: isLoggedIn,
              onLike: () {
                if (!isLoggedIn) {
                  onActionRequired();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post liked!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!isLoggedIn) {
            onActionRequired();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create post feature coming soon!')),
            );
          }
        },
        backgroundColor: AppColors.frostPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
