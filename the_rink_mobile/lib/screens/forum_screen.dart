import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/forum.dart';
import '../widgets/forum/forum_post_card.dart';
import '../widgets/forum/forum_post_search_bar.dart';
import '../services/forum/forum_create_post.dart'; 
import '../services/forum/forum_edit_post.dart';
import '../services/forum/forum_delete_post.dart';
import '../services/forum/forum_filter_post.dart';
import '../services/forum/forum_leaderboard_post.dart';

class ForumScreen extends StatefulWidget {
  final bool isLoggedIn;
  final VoidCallback onActionRequired;

  const ForumScreen({
    super.key,
    required this.isLoggedIn,
    required this.onActionRequired,
  });

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final filterPost = PostFilter();
  final int pageSize = 10;
  int currentPage = 0;
  bool myPost = false;
  bool initialized = false;
  String searchTitle = '';
  late Future<List<Post>> futurePosts;

  Future<List<Post>> fetchPosts(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/forum/json/');
    List<Post> listPost = [];
    for (var data in response) {
      if (data != null) {
        listPost.add(Post.fromJson(data));
      }
    }
    return listPost;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final request = context.read<CookieRequest>();
      futurePosts = fetchPosts(request);
      initialized = true;
    }
  }

  void reloadPost() {
    final request = context.read<CookieRequest>();
    setState(() {
      futurePosts = fetchPosts(request);
      currentPage = 0;
    });
  }

  void openCreatePostSnackbar() {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Create Post',
        barrierColor: Colors.black54, 
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, anim1, anim2) {
        return Center(
          child: SingleChildScrollView(                     
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 40,                                
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Material(
                color: Colors.transparent,
                child: ForumCreatePostCard(
                  isLoggedIn: widget.isLoggedIn,
                  onPostCreated: () {
                    Navigator.of(context).pop();
                    reloadPost();
                  },
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
  }

  Future<void> _handleVote(Post post, bool isUpvote) async {
  if (!widget.isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please Login First')),
    );
    return;
  }

  try {
    final request = context.read<CookieRequest>();

    // SESUAIKAN endpoint & payload dengan Django-mu
    await request.postJson(
      'http://localhost:8000/forum/vote-flutter/',
      {
        'post_id': post.id,
        'direction': isUpvote ? 'up' : 'down',
      },
    );

    // supaya leaderboard + list ke-refresh
    reloadPost();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to vote: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final int? currentUserId = request.jsonData['user_id'] is int
    ? request.jsonData['user_id'] as int
    : int.tryParse(request.jsonData['user_id']?.toString() ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container (
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F2FF),
              Color(0xFFBFDFFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child : FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allPost = snapshot.data ?? [];
          final filteredPost = filterPost.filterPosts(
            allPost,
            filter: myPost,
            currentUserId: currentUserId,
            searchTitle: searchTitle,
          );

          // Pagination
          final int totalItems = filteredPost.length;
          final int totalPages = totalItems == 0 
          ? 1 : ((totalItems - 1) ~/ pageSize) + 1;

          if (currentPage >= totalPages) currentPage = totalPages - 1;
          if (currentPage < 0) currentPage = 0;

          final int startIndex = currentPage * pageSize;
          int endIndex = startIndex + pageSize;
          if (endIndex > totalItems) endIndex = totalItems;

          final List<Post> pagePosts = 
          (totalItems == 0 || startIndex >= totalItems)
          ? <Post>[]
          : filteredPost.sublist(startIndex, endIndex);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [

                      // Header
                      _ForumHeader(
                        onRefresh: reloadPost,
                        onSearchChanged: (value) {
                          setState(() {
                            searchTitle = value;
                            currentPage = 0;
                          });
                        },
                        onCreatePressed: openCreatePostSnackbar,
                      ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth >= 900;
                      final Widget mainList = Column(
                        children: [
                          // Tombol All / My post
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ChoiceChip(
                                          label: const Text('All Posts'),
                                          selected: !myPost,
                                          onSelected: (_) {
                                            setState(() {
                                              myPost = false;
                                              currentPage = 0;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ChoiceChip(
                                          label: const Text('My Posts'),
                                          selected: myPost,
                                          onSelected: (_) {
                                            if (!widget.isLoggedIn || currentUserId == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please login first to see your posts'),
                                                ),
                                              );
                                              return;
                                            }
                                            setState(() {
                                              myPost = true;
                                              currentPage = 0;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // List Post
                              if (pagePosts.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Text(
                                    'No posts yet in the community.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                )
                              else
                                ListView.builder(
                                  itemCount: pagePosts.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final post = pagePosts[index];
                                    return Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 600),
                                        child: ForumPostCard(
                                          post: post,
                                          isLoggedIn: widget.isLoggedIn,
                                          onLike: () {
                                            if (!widget.isLoggedIn) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Please Login First')),
                                              );
                                              return;
                                            }
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Post liked!'),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                          canEdit: widget.isLoggedIn && currentUserId == post.userId,
                                          onEdit: () async {
                                            final changed =
                                                await showEditPostDialog(context, post);
                                            if (changed) reloadPost();
                                          },
                                          onDelete: () async {
                                            final deleted =
                                                await showDeletePostDialog(context, post);
                                            if (deleted) reloadPost();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),

                              const SizedBox(height: 24),
                            ],
                          );

                          // Leaderboard Post
                          final Widget leaderboard = ForumLeaderboardPost(
                            allPosts: allPost, 
                            isLoggedIn: widget.isLoggedIn, 
                            onVote: _handleVote,
                          );

                          if (!isWide) {
                            return Column(
                              children: [
                                leaderboard,
                                mainList,
                              ],
                            );
                          } 
                          else {
                            return Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1240),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kolom kiri: leaderboard
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: leaderboard,
                                      ),
                                    ),
                                    const SizedBox(width: 24), 
                                    // Kolom kanan: main list
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: mainList,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Pagination
              _PaginationBar(
                currentPage: currentPage,
                totalPages: totalPages,
                totalItems: totalItems,
                startIndex: startIndex,
                endIndex: endIndex,
                onPrev: currentPage > 0? () {setState(() {currentPage--;});} : null,
                onNext: currentPage < totalPages - 1
                            ? () {
                                setState(() {
                                  currentPage++;
                                  });
                                }
                              : null,
                            ),
                          ],
                        );
                      },
                    ),
                  )
                );
              }
            }

class _ForumHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onCreatePressed;
  final ValueChanged<String> onSearchChanged;

  const _ForumHeader({
    required this.onRefresh,
    required this.onSearchChanged,
    required this.onCreatePressed,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_rounded,
              size: 30,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          const Text(
            'Forum Community',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(height: 4),

          // Hastag
          const Text(
            'Where ideas grow, and connections come alive',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 16),

          // Refresh Button
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 0,
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Refresh',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Create Post Button
          SizedBox(
            height: 36,
            child: OutlinedButton.icon(
              onPressed: onCreatePressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2563EB)),
                foregroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Create a New Post',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 16),

         // Search Post Box
         Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ForumPostSearchBar(
                onChanged: onSearchChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int startIndex;
  final int endIndex;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.startIndex,
    required this.endIndex,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600, 
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onPrev,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Prev'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                Text(
                  totalItems == 0
                      ? '0 of 0'
                      : '${startIndex + 1}–$endIndex of $totalItems',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B5563),
                  ),
                ),
                TextButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Next'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


