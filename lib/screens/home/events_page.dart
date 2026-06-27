import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nexevent/models/event_model.dart';
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

  String status = 'Live';

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
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.4),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.4),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_busy_rounded,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Events Available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check back later for exciting updates!',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            physics: const BouncingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              status = FirestoreService().getStatus(EventModel.fromMap(data));
              Color statusColor;

              switch (status) {
                case "Upcoming":
                  statusColor = Colors.blue;

                  break;

                case "Live":
                  statusColor = Colors.green;

                  break;

                case "Completed":
                  statusColor = Colors.grey;

                  break;

                case "Cancelled":
                  statusColor = Colors.red;

                  break;

                default:
                  statusColor = Colors.black;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEFF1F4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Section: Event Image
                          SizedBox(
                            width: 108,
                            child: Container(
                              color: const Color(0xFFF3F4F6),
                              child:
                                  (data["imageUrl"] != null &&
                                      data["imageUrl"].toString().isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: data["imageUrl"] ?? '',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: primaryColor.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                            Icons.broken_image_rounded,
                                            color: Colors.grey[400],
                                          ),
                                    )
                                  : Container(
                                      color: primaryColor.withValues(
                                        alpha: 0.08,
                                      ),
                                      child: Icon(
                                        Icons.event_note_rounded,
                                        color: primaryColor,
                                        size: 28,
                                      ),
                                    ),
                            ),
                          ),

                          // Middle Section: Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                14,
                                10,
                                14,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    data["name"] ?? 'Untitled Event',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 12,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        data["eventDate"] == null
                                            ? "Date not available"
                                            : DateFormat(
                                                "dd MMM yyyy",
                                              ).format(
                                                data["eventDate"].toDate(),
                                              ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Text(
                                  //   status,
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  //   style: const TextStyle(
                                  //     fontSize: 10,
                                  //     fontWeight: FontWeight.normal,
                                  //     color: Color(0xFF111827),
                                  //   ),
                                  // ),
                                  // Color statusColor;
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              status == "Live"
                                                  ? Icons.circle
                                                  : status == "Upcoming"
                                                  ? Icons.schedule
                                                  : status == "Completed"
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: statusColor,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (data["category"] != null &&
                                          data["category"]
                                              .toString()
                                              .isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Text(
                                            data["category"]
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: primaryColor,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
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
                                            fontSize: 12.5,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                    padding: const EdgeInsets.only(
                                      right: 10.0,
                                    ),
                                    child: IconButton(
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red.withValues(
                                          alpha: 0.08,
                                        ),
                                        foregroundColor: Colors.red[600],
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
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: const Text(
                                                "Delete Event?",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 17,
                                                ),
                                              ),
                                              content: Text(
                                                "Are you sure you want to permanently delete this event? This action cannot be undone.",
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13.5,
                                                  height: 1.4,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.grey[700],
                                                  ),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.red[600],
                                                  ),
                                                  onPressed: () {
                                                    deleteEv(docs[index].id);
                                                    StorageService()
                                                        .deletePoster(
                                                          docs[index].id,
                                                        );
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 19,
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