import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../widgets/community_post_card.dart';

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
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
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
        backgroundColor: const Color(0xFF6B46C1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
