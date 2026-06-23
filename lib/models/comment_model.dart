class CommentModel {
  CommentModel({
    required this.id,
    required this.userId,
    required this.comment,
    required this.userName,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String comment;
  final String userName;
  final DateTime createdAt;

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map["id"] ?? "",
      userId: map["userId"] ?? "",
      comment: map["comment"] ?? "",
      userName: map["userName"] ?? "",
      createdAt: map["createdAt"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "comment": comment,
      "userName": userName,
      "createdAt": createdAt,
    };
  }
}
