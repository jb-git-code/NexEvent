import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/models/registration_model.dart';
import 'package:nexevent/screens/admin/edit_event_page.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({
    super.key,
    required this.name,
    required this.eventId,
    required this.venue,
    required this.description,
    required this.did,
    required this.imageUrl,
  });

  final String name;

  final String eventId;

  final String description;

  final String venue;

  final String did;

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColorLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Image(fit: BoxFit.cover, image: NetworkImage(imageUrl)),
                height: 250,
                width: 250,
                color: Colors.red,
              ),
              Text(
                'Name: $name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Event ID: $eventId',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                'Description: $description',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'venue: $venue',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditEventPage(docId: did),
                          ),
                        );
                      },
                      child: Text('Update Event'),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () async {
                        String regId = const Uuid().v4();
                        String useId = FirebaseAuth.instance.currentUser!.uid;

                        final query = await FirebaseFirestore.instance
                            .collection("registrations")
                            .where("userId", isEqualTo: useId)
                            .where("eventId", isEqualTo: eventId)
                            .get();
                        if (query.docs.isEmpty) {
                          await FirestoreService().registerEvent(
                            RegistrationModel(
                              registrationId: regId,
                              eventId: eventId,
                              userId: useId,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Registered")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Already Registered")),
                          );
                        }
                      },
                      child: const Text("Register"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
