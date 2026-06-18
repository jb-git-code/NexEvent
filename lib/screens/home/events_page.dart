import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/models/user_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/home/event_detail_page.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/services/storage_services.dart';
import 'package:share_plus/share_plus.dart';

class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {
  Future<void> deleteEv(String eid) async {
    await FirestoreService().deleteEvent(eid);
  }

  // String role = "student";
  // bool isLoading = true;
  // Future<void> loadRole() async {
  //   String uid = FirebaseAuth.instance.currentUser!.uid;

  //   final doc = await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(uid)
  //       .get();
  //   final map = doc.data() as Map<String, dynamic>;
  //   setState(() {
  //     isLoading = false;
  //     role = map["role"];
  //     print(map["role"]);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // loadRole();
    // print(role);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    final currUser = ref.watch(currentUserProvider);

    final role = currUser!.role;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: StreamBuilder(
        stream: FirestoreService().getEvents("events"),
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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(
                          name: data["name"] ?? '',
                          eventId: data["eventId"] ?? '',
                          venue: data["venue"] ?? '',
                          description: data["description"] ?? '',
                          did: docs[index].id,
                          imageUrl: data["imageUrl"] ?? '',
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Section: Rounded Event Image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: Container(
                              width: 100,
                              height: 100,
                              color: const Color(0xFFF3F4F6),
                              child:
                                  (data["imageUrl"] != null &&
                                      data["imageUrl"].toString().isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: data["imageUrl"] ?? '',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )
                                  : Container(
                                      color: primaryColor.withValues(
                                        alpha: 0.08,
                                      ),
                                      child: Icon(
                                        Icons.event_note_rounded,
                                        color: primaryColor,
                                      ),
                                    ),
                            ),
                          ),

                          // Middle Section: Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    data["name"] ?? 'Untitled Event',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          data["venue"] ?? 'TBD',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (data["category"] != null &&
                                      data["category"]
                                          .toString()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        data["category"]
                                            .toString()
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: primaryColor,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: IconButton(
                          //     onPressed: () {
                          //       SharePlus.instance.share(
                          //         ShareParams(
                          //           text:
                          //               '''🎉 ${data["name"] ?? ''}

                          //             📍 Venue: ${data["venue"] ?? ''}

                          //             📝 ${data["description"] ?? ''}

                          //           ''',
                          //         ),
                          //       );
                          //     },

                          //     icon: const Icon(Icons.share),
                          //   ),
                          // ),
                          // Right Section: Admin Actions
                          (role == 'admin')
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: IconButton(
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red.withValues(
                                          alpha: 0.08,
                                        ),
                                        foregroundColor: Colors.red[700],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (_) {
                                            return AlertDialog(
                                              title: const Text(
                                                "Delete Event?",
                                              ),
                                              content: const Text(
                                                "Are you sure you want to permanently delete this event? This action cannot be undone.",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.red[700],
                                                  ),
                                                  onPressed: () {
                                                    deleteEv(docs[index].id);
                                                    StorageService()
                                                        .deletePoster(
                                                          docs[index].id,
                                                        );
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
