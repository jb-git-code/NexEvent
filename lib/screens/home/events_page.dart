import 'package:flutter/material.dart';
import 'package:nexevent/screens/home/event_detail_page.dart';
import 'package:nexevent/services/firestore_service.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  Future<void> deleteEv(String eid) async {
    await FirestoreService().deleteEvent(eid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirestoreService().getEvents(),
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
                    IconButton(
                      onPressed: () async {
                        deleteEv(docs[index].id);
                      },
                      icon: Icon(Icons.delete),
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
