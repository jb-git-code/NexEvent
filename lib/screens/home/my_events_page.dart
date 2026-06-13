import 'package:cloud_firestore/cloud_firestore.dart';
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
      backgroundColor: const Color(0xFFF9FAFB),
      body: StreamBuilder(
        stream: FirestoreService().getUserRegistrations(),
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
                    Icons.confirmation_number_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Registered Tickets',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore events and get tickets now!',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            physics: const BouncingScrollPhysics(),
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
                  if (eventSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!eventSnapshot.hasData || !eventSnapshot.data!.exists) {
                    return const SizedBox();
                  }

                  final dd = eventSnapshot.data!.data() as Map<String, dynamic>;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailPage(
                              name: dd["name"] ?? '',
                              eventId: dd["eventId"] ?? '',
                              venue: dd["venue"] ?? '',
                              description: dd["description"] ?? '',
                              did: dd["eventId"] ?? '',
                              imageUrl: dd["imageUrl"] ?? '',
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: EventsCard(
                              name: dd["name"] ?? '',
                              eveId: dd["eventId"] ?? '',
                              venue: dd["venue"] ?? '',
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.08),
                              foregroundColor: Colors.red[700],
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    title: const Text("Cancel Ticket?"),
                                    content: const Text(
                                      "Are you sure you want to cancel your registration for this event?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red[700],
                                        ),
                                        onPressed: () async {
                                          await FirestoreService()
                                              .cancelRegistration(
                                                data["registrationId"],
                                              );
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          } else {
                                            CircularProgressIndicator();
                                          }
                                        },
                                        child: const Text('Cancel Ticket'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.cancel_outlined, size: 22),
                          ),
                        ],
                      ),
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
