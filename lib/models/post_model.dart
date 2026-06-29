class PostModel {
  final String postId;
  final String userId;
  final String userName;
  // final String profileImage;

  final String caption;
  final String imageUrl;

  final DateTime createdAt;

  final int likeCount;
  final int commentCount;

  final bool isDeleted;

  final List<String> tags;

  PostModel({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.caption,
    required this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isDeleted,
    required this.tags,
  });
}
