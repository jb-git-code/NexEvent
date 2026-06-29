import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String userName;

  final String caption;
  final String imageUrl;

  final DateTime createdAt;
  // final DateTime updatedAt;

  final int likeCount;
  final int commentCount;

  final bool isDeleted;

  // final List<String> tags;

  PostModel({
    required this.postId,
    required this.userId,
    required this.userName,

    required this.caption,
    required this.imageUrl,
    required this.createdAt,
    // required this.updatedAt,
    required this.likeCount,
    required this.commentCount,
    required this.isDeleted,
    // required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      "postId": postId,
      "userId": userId,
      "userName": userName,

      "caption": caption,
      "imageUrl": imageUrl,
      "createdAt": Timestamp.fromDate(createdAt),

      "likeCount": likeCount,
      "commentCount": commentCount,
      "isDeleted": isDeleted,
      // "tags": tags,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map["postId"] ?? "",
      userId: map["userId"] ?? "",
      userName: map["userName"] ?? "",

      caption: map["caption"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
      createdAt: (map["createdAt"] as Timestamp).toDate(),

      likeCount: map["likeCount"] ?? 0,
      commentCount: map["commentCount"] ?? 0,
      isDeleted: map["isDeleted"] ?? false,
      // tags: List<String>.from(map["tags"] ?? []),
    );
  }
}
