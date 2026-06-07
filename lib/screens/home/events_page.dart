import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/screens/home/event_detail_page.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/services/storage_services.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  Future<void> deleteEv(String eid) async {
    await FirestoreService().deleteEvent(eid);
  }

  String role = "";

  Future<void> loadRole() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    setState(() {
      role = doc["role"];
    });
  }

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirestoreService().getEvents("events"),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final docs = snapshot.data!.docs;

          print('success');

          return ListView.builder(
            padding: EdgeInsets.all(16),

            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

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
                        did: docs[index].id,
                        imageUrl: data["imageUrl"],
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.grey[400],
                        child: ListTile(
                          title: Text(data["name"]),
                          subtitle: Text(data["venue"]),
                        ),
                      ),
                    ),
                    (role == 'admin')
                        ? IconButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          deleteEv(docs[index].id);
                                          StorageService().deletePoster(
                                            docs[index].id,
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
                            icon: Icon(Icons.delete),
                          )
                        : const SizedBox(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
