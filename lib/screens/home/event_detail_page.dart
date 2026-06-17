import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/models/registration_model.dart';
import 'package:nexevent/models/user_model.dart';
import 'package:nexevent/screens/admin/edit_event_page.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/services/notification_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({
    super.key,
    required this.name,
    required this.eventId,
    required this.venue,
    required this.description,
    required this.did,
    required this.imageUrl,
  });

  final String name;

  final String eventId;

  final String description;

  final String venue;

  final String did;

  final String imageUrl;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  String role = "student";
  bool isLoading = true;
  Future<void> loadRole() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    final map = doc.data() as Map<String, dynamic>;
    setState(() {
      role = map["role"];
      print(map["role"]);
    });
  }

  @override
  void initState() {
    super.initState();
    loadRole();
    setState(() {
      isLoading = false;
    });
    // print(role);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Poster Image Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: (widget.imageUrl.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: widget.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : Container(
                                color: primaryColor.withValues(alpha: 0.08),
                                child: Icon(
                                  Icons.event_rounded,
                                  color: primaryColor,
                                  size: 48,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Event Title & Badge
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ID: ${widget.eventId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFF3F4F6), height: 1),
                    const SizedBox(height: 24),

                    // Venue Info Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'LOCATION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.venue,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Description Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ABOUT THIS EVENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description.isNotEmpty
                              ? widget.description
                              : 'No description available for this event.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     Text(
            //       'Share this event with friends',
            //       style: TextStyle(fontSize: 20),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: IconButton(
            //         onPressed: () {
            //           print('shared');
            //           SharePlus.instance.share(
            //             ShareParams(
            //               text:
            //                   '''🎉 ${widget.name}

            //                           📍 Venue: ${widget.venue}

            //                           📝 ${widget.description}

            //                           🔗 Open in NexEvent:nexevent://event/${widget.eventId}

            //                         ''',
            //             ),
            //           );
            //         },

            //         icon: const Icon(Icons.share),
            //       ),
            //     ),
            //   ],
            // ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (role == 'admin') ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditEventPage(docId: widget.did),
                            ),
                          );
                        },
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shadowColor: primaryColor.withValues(alpha: 0.3),
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        String regId = const Uuid().v4();
                        String useId = FirebaseAuth.instance.currentUser!.uid;

                        final query = await FirebaseFirestore.instance
                            .collection("registrations")
                            .where("userId", isEqualTo: useId)
                            .where("eventId", isEqualTo: widget.eventId)
                            .get();

                        if (query.docs.isEmpty) {
                          await FirestoreService().registerEvent(
                            RegistrationModel(
                              registrationId: regId,
                              eventId: widget.eventId,
                              userId: useId,
                              attented: false,
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Registered Successfully!"),
                              ),
                            );
                          }
                          await NotificationService().showRegistrationSuccess(
                            widget.name,
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Already Registered"),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
