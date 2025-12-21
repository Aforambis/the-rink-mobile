import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../models/forum.dart';

class PostFilter {
  Future<List<Post>> fetchPosts(CookieRequest request) async {
    final response = await request.get('https://angga-tri41-therink.pbp.cs.ui.ac.id/forum/json/');

    final List<Post> listPost = [];
    for (final data in response) {
      if (data != null) {
        listPost.add(Post.fromJson(data));
      }
    }
    return listPost;
  }

  List<Post> filterPosts(
    List<Post> posts, {
    required bool filter,
    required int? currentUserId,
    String searchTitle = '',
  }) {
    Iterable<Post> result = posts;

    if (filter && currentUserId != null) {
      result = result.where((post) => post.userId == currentUserId);
    }

    if (searchTitle.isNotEmpty) {
      final title = searchTitle.toLowerCase();
      result = result.where(
        (post) => post.title.toLowerCase().contains(title),
      );
    }

    return result.toList();
  }
}
