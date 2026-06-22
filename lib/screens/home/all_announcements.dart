import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/services/firestore_service.dart';

class AllAnnouncements extends ConsumerStatefulWidget {
  const AllAnnouncements({super.key});

  @override
  ConsumerState<AllAnnouncements> createState() => _AllAnnouncementsState();
}

class _AllAnnouncementsState extends ConsumerState<AllAnnouncements> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
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
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [Text(doc["title"]), Text(doc["content"])]),
                  (user!.role == 'admin')
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            onPressed: () {
                              FirestoreService().deleteAnnouncemnt(doc["id"]);
                              final sb = SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('Announcement Created'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(sb);
                            },
                            icon: Icon(color: Colors.red, Icons.delete_forever),
                          ),
                        )
                      : const SizedBox(),
                ],
              );
            }),
          );
        },
      ),
    );
  }
}
