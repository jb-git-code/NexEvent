import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexevent/models/event_model.dart';
import 'package:nexevent/models/registration_model.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getEvents(String eve) {
    return firestore.collection(eve).snapshots();
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

  Future<void> updateEvent(EventModel event, String did) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(did)
        .update(event.toMap());
  }

  Future<void> registerEvent(RegistrationModel registration) async {
    await FirebaseFirestore.instance
        .collection("registrations")
        .doc(registration.registrationId)
        .set(registration.toMap());
  }

  Future<void> cancelRegistration(String registrationId) async {
    await FirebaseFirestore.instance
        .collection("registrations")
        .doc(registrationId)
        .delete();
  }
}
