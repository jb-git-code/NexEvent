import 'package:cloud_firestore/cloud_firestore.dart';

class CreativePostModel {
  final String postId;
  final String title;
  final String description;
  final String coverImage;
  final List<String> mediaUrls;
  final String contentType;
  final String channelId;
  final String channelName;
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
    required this.channelId,
    required this.channelName,
  });

  Map<String, dynamic> toMap() {
    return {
      "postId": postId,
      "title": title,
      "description": description,
      "contentType": contentType,
      "coverImage": coverImage,
      "mediaUrls": mediaUrls,
      "channelId": channelId,
      "channelName": channelName,
      "authorId": authorId,
      "authorName": authorName,
      "createdAt": Timestamp.fromDate(createdAt),
      "likeCount": likeCount,
      "commentCount": commentCount,
      "isPinned": isPinned,
    };
  }

  factory CreativePostModel.fromMap(Map<String, dynamic> map) {
    return CreativePostModel(
      postId: map["postId"] ?? "",
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      contentType: map["contentType"] ?? "",
      coverImage: map["coverImage"] ?? "",
      mediaUrls: List<String>.from(map["mediaUrls"] ?? []),
      channelId: map["channelId"] ?? "",
      channelName: map["channelName"] ?? "",
      authorId: map["authorId"] ?? "",
      authorName: map["authorName"] ?? "",
      createdAt: (map["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      likeCount: map["likeCount"] ?? 0,
      commentCount: map["commentCount"] ?? 0,
      isPinned: map["isPinned"] ?? false,
    );
  }
}
