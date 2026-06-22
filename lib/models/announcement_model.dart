class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "content": content,
      "author": author,
      "createdAt": createdAt,
    };
  }

  factory AnnouncementModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AnnouncementModel(
      id: map["id"],
      title: map["title"],
      content: map["content"],
      author: map["author"],
      createdAt: map["createdAt"].toDate(),
    );
  }
}