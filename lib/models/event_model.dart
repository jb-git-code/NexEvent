class EventModel {
  final String eventId;
  final String title;
  final String description;
  final String venue;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.venue,
  });

  factory EventModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return EventModel(
      eventId: map['eventId'],
      title: map['title'],
      description: map['description'],
      venue: map['venue'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'venue': venue,
    };
  }
}