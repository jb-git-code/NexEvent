import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/screens/home/event_detail_page.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/widgets/events_card.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirestoreService().getUserRegistrations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final eid = data["eventId"];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('events')
                    .doc(eid)
                    .get(),
                builder: (context, eventSnapshot) {
                  if (!eventSnapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final dd = eventSnapshot.data!.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(
                            name: data["name"],
                            eventId: data["eventId"],
                            venue: data["venue"],
                            description: data["description"],
                            did: data["eventId"],
                            imageUrl: data["imageUrl"],
                          ),
                        ),
                      );
                    },
                    // child: Text('data'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        EventsCard(
                          name: dd["name"],
                          eveId: dd["eventId"],
                          venue: dd["venue"],
                        ),
                        IconButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        await FirestoreService()
                                            .cancelRegistration(
                                              data["registrationId"],
                                            );
                                        Navigator.pop(context);
                                      },
                                      child: Text('Yes'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('No'),
                                    ),
                                  ],
                                  title: Text("Delete Event?"),
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.cancel_sharp),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
