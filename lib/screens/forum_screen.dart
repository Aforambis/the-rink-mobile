import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../theme/app_theme.dart';
import '../models/forum.dart';
import '../auth/login.dart';
import '../widgets/forum/forum_post_card.dart';
import '../widgets/forum/forum_post_search_bar.dart';
import '../widgets/auth_modal_sheet.dart';

import '../services/forum/forum_create_post.dart';
import '../services/forum/forum_edit_post.dart';
import '../services/forum/forum_delete_post.dart';
import '../services/forum/forum_filter_post.dart';
import '../services/forum/forum_leaderboard_post.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final filterPost = PostFilter();
  final TextEditingController _searchController = TextEditingController();
  final int pageSize = 10;
  int currentPage = 0;
  bool myPost = false;
  bool initialized = false;
  String searchTitle = '';
  String draftSearchTitle = '';

  late Future<List<Post>> futureTopPosts;
  int? userId;

  Future<void> authUser() async {
    final request = context.read<CookieRequest>();
    final auth = await request.get(
      'https://angga-tri41-therink.pbp.cs.ui.ac.id/forum/auth-person-forum/',
    );
    setState(() {
      userId = auth['user_id'];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  late Future<List<Post>> futurePosts;

  Future<List<Post>> fetchPosts(CookieRequest request) async {
    final response = await request.get(
      'https://angga-tri41-therink.pbp.cs.ui.ac.id/forum/json/',
    );
    List<Post> listPost = [];
    for (var data in response) {
      if (data != null) {
        listPost.add(Post.fromJson(data));
      }
    }
    return listPost;
  }

  Future<List<Post>> fetchTopPosts(CookieRequest request) async {
    final response = await request.get(
      'https://angga-tri41-therink.pbp.cs.ui.ac.id/forum/get-top-posts-json-flutter/',
    );
    List<Post> listPost = [];
    for (var data in response) {
      if (data != null) listPost.add(Post.fromJson(data));
    }
    return listPost;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final request = context.read<CookieRequest>();
      futurePosts = fetchPosts(request);
      futureTopPosts = fetchTopPosts(request);
      authUser();
      initialized = true;
    }
  }

  void reloadPost() {
    final request = context.read<CookieRequest>();
    setState(() {
      futurePosts = fetchPosts(request);
      futureTopPosts = fetchTopPosts(request);
      currentPage = 0;
    });
  }

  bool get _isLoggedInNow {
    final request = context.read<CookieRequest>();
    return request.loggedIn;
  }

  void openCreatePostSnackbar() {
    if (!_isLoggedInNow) {
      _showAuthModal();
      return;
    }
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Create a New Post',
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
                child: ForumCreatePostCard(
                  isLoggedIn: _isLoggedInNow,
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
            scale: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }

  void _showAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthModalSheet(
        onUsernamePasswordSignIn: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        onContinueAsGuest: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _handleVote(Post post, bool isUpvote) async {
    if (!_isLoggedInNow) {
      _showAuthModal();
      return;
    }

    try {
      final request = context.read<CookieRequest>();
      final response =
          await request.postJson(
                'https://angga-tri41-therink.pbp.cs.ui.ac.id/forum/toggle-vote-flutter/',
                jsonEncode({
                  'type': 'post',
                  'id': post.id,
                  'is_upvote': isUpvote,
                }),
              )
              as Map<String, dynamic>;

      setState(() {
        post.upvotesCount = (response['upvotes'] ?? post.upvotesCount) as int;
        post.downvotesCount =
            (response['downvotes'] ?? post.downvotesCount) as int;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to vote: $e')));
    }
  }

  Future<void> _handleReplyVote(Reply reply, bool isUpvote) async {
    if (!_isLoggedInNow) {
      _showAuthModal();
      return;
    }

    try {
      final request = context.read<CookieRequest>();
      final response =
          await request.postJson(
                'https://angga-tri41-therink.pbp.cs.ui.ac.id/forum/toggle-vote-flutter/',
                jsonEncode({
                  'type': 'reply',
                  'id': reply.id,
                  'is_upvote': isUpvote,
                }),
              )
              as Map<String, dynamic>;

      setState(() {
        reply.upvotesCount = (response['upvotes'] ?? reply.upvotesCount) as int;
        reply.downvotesCount =
            (response['downvotes'] ?? reply.downvotesCount) as int;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to vote: $e')));
    }
  }

  // Forum Screen
  @override
  Widget build(BuildContext context) {
    final int? currentUserId = userId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2FF), Color(0xFFBFDFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Post>>(
          future: futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == null) {
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
                ? 1
                : ((totalItems - 1) ~/ pageSize) + 1;

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
                          onCreatePressed: openCreatePostSnackbar,
                          searchController: _searchController,
                          onSearchChanged: (value) {
                            draftSearchTitle = value;
                          },
                          onSearchPressed: () {
                            setState(() {
                              searchTitle = _searchController.text.trim();
                              currentPage = 0;
                            });
                          },
                        ),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final bool isWide = constraints.maxWidth >= 900;
                            final Widget mainList = Column(
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 600,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.03,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Tombol All Post
                                          ChoiceChip(
                                            label: const Text('All Posts'),
                                            selected: !myPost,
                                            backgroundColor: Colors.white,
                                            selectedColor:
                                                AppColors.frostPrimary,
                                            showCheckmark: false,
                                            labelStyle: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: !myPost
                                                  ? Colors.white
                                                  : AppColors.frostPrimary,
                                            ),
                                            side: BorderSide(
                                              color: AppColors.frostPrimary,
                                              width: 1,
                                            ),
                                            onSelected: (_) {
                                              setState(() {
                                                myPost = false;
                                                currentPage = 0;
                                              });
                                            },
                                          ),

                                          const SizedBox(width: 8),

                                          // Tombol My Post
                                          ChoiceChip(
                                            label: const Text('My Posts'),
                                            selected: myPost,
                                            backgroundColor: Colors.white,
                                            selectedColor:
                                                AppColors.frostPrimary,
                                            showCheckmark: false,
                                            labelStyle: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: myPost
                                                  ? Colors.white
                                                  : AppColors.frostPrimary,
                                            ),
                                            side: BorderSide(
                                              color: AppColors.frostPrimary,
                                              width: 1,
                                            ),
                                            onSelected: (_) {
                                              if (!_isLoggedInNow ||
                                                  currentUserId == null) {
                                                _showAuthModal();
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

                                // Post Empty Analyze
                                if (pagePosts.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Text(
                                      'No posts yet in the community.',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  )
                                else
                                  // Post Card
                                  ListView.builder(
                                    itemCount: pagePosts.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final post = pagePosts[index];
                                      return Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 600,
                                          ),
                                          child: ForumPostCard(
                                            post: post,
                                            isLoggedIn: _isLoggedInNow,
                                            canEdit:
                                                _isLoggedInNow &&
                                                myPost &&
                                                currentUserId == post.userId,
                                            onEdit: () async {
                                              final changed =
                                                  await showEditPostDialog(
                                                    context,
                                                    post,
                                                  );
                                              if (changed) reloadPost();
                                            },
                                            onDelete: () async {
                                              final deleted =
                                                  await showDeletePostDialog(
                                                    context,
                                                    post,
                                                  );
                                              if (deleted) reloadPost();
                                            },
                                            onReplyVote: _handleReplyVote,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                const SizedBox(height: 24),
                              ],
                            );
                            // Leaderboard Post
                            final Widget
                            leaderboard = FutureBuilder<List<Post>>(
                              future: futureTopPosts,
                              builder: (context, topSnap) {
                                if (topSnap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 140,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (topSnap.hasError) {
                                  return Text(
                                    'Leaderboard error: ${topSnap.error}',
                                  );
                                }

                                final topFromApi = topSnap.data ?? <Post>[];
                                final byId = {for (final p in allPost) p.id: p};
                                final mergedTop = topFromApi
                                    .map((tp) => byId[tp.id] ?? tp)
                                    .toList();

                                return ForumLeaderboardPost(
                                  topPosts: mergedTop,
                                  isLoggedIn: _isLoggedInNow,
                                  onVote: _handleVote,
                                  onReplyVote: _handleReplyVote,
                                  onRequireAuth: _showAuthModal,
                                  baseUrl:
                                      "https://angga-tri41-therink.pbp.cs.ui.ac.id",
                                  onAfterAction: reloadPost,
                                );
                              },
                            );

                            if (!isWide) {
                              return Column(children: [leaderboard, mainList]);
                            } else {
                              return Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1240,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Kolom kiri: Leaderboard post
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: leaderboard,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      // Kolom kanan: Post list
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
                  onPrev: currentPage > 0
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
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
      ),
    );
  }
}

class _ForumHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onCreatePressed;

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchPressed;

  const _ForumHeader({
    required this.onRefresh,
    required this.onCreatePressed,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchPressed,
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

          const Text(
            'Forum Community',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(height: 4),

          const Text(
            'Where ideas grow, and connections come alive',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 16),

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
                backgroundColor: AppColors.frostPrimary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Refresh',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: onCreatePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.frostPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Create a New Post',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Post Box
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ForumPostSearchBar(
                controller: searchController,
                onChanged: onSearchChanged,
                onSearchPressed: onSearchPressed,
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
          constraints: const BoxConstraints(maxWidth: 600),
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
                ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                Text(
                  totalItems == 0
                      ? '0 of 0'
                      : '${startIndex + 1} – $endIndex of $totalItems',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
