import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminForumManagementScreen extends StatefulWidget {
  const AdminForumManagementScreen({super.key});

  @override
  State<AdminForumManagementScreen> createState() =>
      _AdminForumManagementScreenState();
}

class _AdminForumManagementScreenState extends State<AdminForumManagementScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _replies = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPosts();
    _fetchReplies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/posts/',
      );

      if (mounted && response != null && response['status'] == true) {
        setState(() {
          _posts = List<Map<String, dynamic>>.from(response['posts']);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load posts')));
      }
    }
  }

  Future<void> _fetchReplies() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/replies/',
      );

      if (mounted && response != null && response['status'] == true) {
        setState(() {
          _replies = List<Map<String, dynamic>>.from(response['replies']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load replies')));
      }
    }
  }

  Future<void> _deletePost(int postId, String postTitle) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/posts/$postId/delete/',
        {},
      );

      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
        _fetchPosts();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete post')));
    }
  }

  Future<void> _deleteReply(int replyId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/replies/$replyId/delete/',
        {},
      );

      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply deleted successfully')),
        );
        _fetchReplies();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete reply')));
    }
  }

  void _showDeletePostConfirmation(int postId, String postTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text(
          'Are you sure you want to delete post "$postTitle"? This will also delete all replies to this post.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deletePost(postId, postTitle);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteReplyConfirmation(int replyId, String authorName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply'),
        content: Text(
          'Are you sure you want to delete reply by "$authorName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteReply(replyId);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Management'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Replies'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchPosts();
              _fetchReplies();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  // Posts Tab
                  _buildPostsList(),
                  // Replies Tab
                  _buildRepliesList(),
                ],
              ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (_posts.isEmpty) {
      return const Center(
        child: Text(
          'No posts found',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.forum, color: Colors.white),
            ),
            title: Text(
              post['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('By: ${post['author_username']}'),
                Text(
                  '👍 ${post['total_upvotes']} | 👎 ${post['total_downvotes']} | 💬 ${post['replies_count']}',
                ),
                Text(
                  post['content'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeletePostConfirmation(post['id'], post['title']);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRepliesList() {
    if (_replies.isEmpty) {
      return const Center(
        child: Text(
          'No replies found',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _replies.length,
      itemBuilder: (context, index) {
        final reply = _replies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.reply, color: Colors.white),
            ),
            title: Text(
              'Reply to: ${reply['post_title']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('By: ${reply['author_username']}'),
                Text(
                  '👍 ${reply['total_upvotes']} | 👎 ${reply['total_downvotes']}',
                ),
                Text(
                  reply['content'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteReplyConfirmation(
                    reply['id'],
                    reply['author_username'],
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
