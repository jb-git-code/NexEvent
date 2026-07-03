import 'package:cloud_firestore/cloud_firestore.dart';

class CreativePostModel {
  final String postId;
  final String title;
  final String description;
  final String coverImage;
  final List<String> mediaUrls;
  final String contentType;
  final String clubId;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isPinned;

  CreativePostModel({
    required this.authorId,
    required this.postId,
    required this.title,
    required this.description,
    required this.commentCount,
    required this.coverImage,
    required this.contentType,
    required this.mediaUrls,
    required this.createdAt,
    required this.likeCount,
    required this.isPinned,
    required this.authorName,
    required this.clubId,
  });
}
