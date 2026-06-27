import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String name;
  final String description;
  final String venue;
  final String category;
  final String imageUrl;
  final DateTime eventDate;
  final DateTime endDate;
  final bool isCancelled;

  EventModel({
    required this.eventId,
    required this.name,
    required this.description,
    required this.venue,
    required this.category,
    required this.imageUrl,
    required this.eventDate,
    required this.endDate,
    required this.isCancelled,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map["eventId"] ?? "",
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      venue: map["venue"] ?? "",
      category: map["category"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
      eventDate: (map["eventDate"] as Timestamp).toDate(),
      endDate: (map["endDate"] as Timestamp).toDate(),
      isCancelled: map["isCancelled"],
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
      "eventDate": Timestamp.fromDate(eventDate),
      "endDate": Timestamp.fromDate(endDate),
      "isCancelled": isCancelled,
    };
  }
}
