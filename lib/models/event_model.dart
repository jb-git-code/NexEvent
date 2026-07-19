import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String name;
  final String description;
  final String venue;
  final String channelId;
  final String imageUrl;
  final DateTime eventDate;
  final DateTime endDate;
  final bool isCancelled;
  final int regisCount;

  EventModel({
    required this.eventId,
    required this.name,
    required this.description,
    required this.venue,
    required this.channelId,
    required this.imageUrl,
    required this.eventDate,
    required this.endDate,
    required this.isCancelled,
    required this.regisCount,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map["eventId"] ?? "",
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      venue: map["venue"] ?? "",
      channelId: map["channelId"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
      eventDate: (map["eventDate"] as Timestamp).toDate(),
      endDate: (map["endDate"] as Timestamp).toDate(),
      isCancelled: map["isCancelled"],
      regisCount: map["regisCount"] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "eventId": eventId,
      "name": name,
      "description": description,
      "venue": venue,
      "channelId": channelId,
      "imageUrl": imageUrl,
      "eventDate": Timestamp.fromDate(eventDate),
      "endDate": Timestamp.fromDate(endDate),
      "isCancelled": isCancelled,
      "regisCount": regisCount,
    };
  }

  factory EventModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EventModel(
      eventId: data["eventId"] ?? "",
      name: data["name"] ?? "",
      description: data["description"] ?? "",
      venue: data["venue"] ?? "",
      channelId: data["channelId"] ?? "",
      imageUrl: data["imageUrl"] ?? "",
      eventDate: (data["eventDate"] as Timestamp).toDate(),
      endDate: (data["endDate"] as Timestamp).toDate(),
      isCancelled: data["isCancelled"],
      regisCount: data["regisCount"] ?? 0,
    );
  }
}
