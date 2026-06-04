import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexevent/models/event_model.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getEvents() {
    return firestore.collection("events").snapshots();
  }

  Future<void> createEvent(EventModel event) async {
    await FirebaseFirestore.instance
        .collection("events")
        .doc(event.eventId)
        .set(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
  }
}
