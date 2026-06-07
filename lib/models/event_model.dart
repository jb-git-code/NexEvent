class EventModel {
  final String eventId;
  final String name;
  final String description;
  final String venue;
  final String category;
  final String imageUrl;

  EventModel({
    required this.eventId,
    required this.name,
    required this.description,
    required this.venue,
    required this.category,
    required this.imageUrl,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map["eventId"] ?? "",
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      venue: map["venue"] ?? "",
      category: map["category"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "eventId": eventId,
      "name": name,
      "description": description,
      "venue": venue,
      "category": category,
      "imageUrl": imageUrl,
    };
  }
}
