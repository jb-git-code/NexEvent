import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/services/firestore_service.dart';

class AllAnnouncements extends StatefulWidget {
  const AllAnnouncements({super.key});

  @override
  State<AllAnnouncements> createState() => _AllAnnouncementsState();
}

class _AllAnnouncementsState extends State<AllAnnouncements> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirestoreService().getEvents('announcements'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Events Available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Check back later for exciting updates!',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          final allDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: allDocs.length,
            itemBuilder: ((context, index) {
              final doc = allDocs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(doc["title"]),
                subtitle: Text(doc["content"]),
              );
            }),
          );
        },
      ),
    );
  }
}
