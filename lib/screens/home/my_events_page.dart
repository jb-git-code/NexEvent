import 'package:flutter/material.dart';
import 'package:nexevent/screens/home/event_detail_page.dart';
import 'package:nexevent/services/firestore_service.dart';

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
        stream: FirestoreService().getEvents("registrations"),
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

              final eid = data["eventId"];

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
                        imageUrl: "",
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
                          title: Text('Event ID: $eid'),
                          subtitle: Text(
                            'Registration ID: ${data["registrationId"]}',
                          ),
                        ),
                      ),
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
                                    await FirestoreService().cancelRegistration(
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
      ),
    );
  }
}
