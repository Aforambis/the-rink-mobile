import 'dart:convert';

List<Post> PostFromJson(String str) => List<Post>.from(json.decode(str).map((x) => Post.fromJson(x)));

String PostToJson(List<Post> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Post {
    int id;
    String author;
    String title;
    String content;
    DateTime createdAt;
    DateTime updatedAt;
    String thumbnailUrl;
    int userId;
    int upvotesCount;
    int downvotesCount;
    List<Reply> replies;
    int repliesCount;

    Post({
        required this.id,
        required this.author,
        required this.title,
        required this.content,
        required this.createdAt,
        required this.updatedAt,
        required this.thumbnailUrl,
        required this.userId,
        required this.upvotesCount,
        required this.downvotesCount,
        required this.replies,
        required this.repliesCount,
    });

    factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"],
        author: json["author"],
        title: json["title"],
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        thumbnailUrl: json["thumbnail_url"],
        userId: json["user_id"],
        upvotesCount: json["upvotes_count"],
        downvotesCount: json["downvotes_count"],
        replies: List<Reply>.from(json["replies"].map((x) => Reply.fromJson(x))),
        repliesCount: json["replies_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "author": author,
        "title": title,
        "content": content,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "thumbnail_url": thumbnailUrl,
        "user_id": userId,
        "upvotes_count": upvotesCount,
        "downvotes_count": downvotesCount,
        "replies": List<dynamic>.from(replies.map((x) => x.toJson())),
        "replies_count": repliesCount,
    };
}

class Reply {
    int id;
    String author;
    String content;
    DateTime createdAt;
    DateTime updatedAt;
    int upvotesCount;
    int downvotesCount;

    Reply({
        required this.id,
        required this.author,
        required this.content,
        required this.createdAt,
        required this.updatedAt,
        required this.upvotesCount,
        required this.downvotesCount,
    });

    factory Reply.fromJson(Map<String, dynamic> json) => Reply(
        id: json["id"],
        author: json["author"],
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        upvotesCount: json["upvotes_count"],
        downvotesCount: json["downvotes_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "author": author,
        "content": content,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "upvotes_count": upvotesCount,
        "downvotes_count": downvotesCount,
    };
}
