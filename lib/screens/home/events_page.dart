import 'package:flutter/material.dart';
import 'package:nexevent/services/firestore_service.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
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

              return Card(
                color: Colors.teal,
                child: ListTile(
                  title: Text(data["name"]),
                  subtitle: Text(data["venue"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
