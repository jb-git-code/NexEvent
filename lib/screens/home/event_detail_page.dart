import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/models/registration_model.dart';
import 'package:nexevent/screens/admin/edit_event_page.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:nexevent/widgets/grid_background.dart';

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
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final map = doc.data() as Map<String, dynamic>;
        setState(() {
          role = map["role"] ?? "student";
        });
      }
    } catch (e) {
      print("Error loading role: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: GridDotBackground(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Poster Image Card (Dashed or Outlined layout)
                            Container(
                              width: double.infinity,
                              height: 220,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: const Color(0xFFEFF1F4),
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x05000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: (widget.imageUrl.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111111)),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.broken_image_rounded, size: 28),
                                    )
                                  : Container(
                                      color: const Color(0xFFEEF2FF),
                                      child: const Icon(
                                        Icons.event_note_rounded,
                                        color: Color(0xFF7C4DFF),
                                        size: 48,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 24),

                            // Event Title & ID Badge
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111111),
                                letterSpacing: -0.6,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                              ),
                              child: Text(
                                'EVENT ID: ${widget.eventId}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Color(0xFFE2E8F0), height: 1),
                            const SizedBox(height: 24),

                            // Venue Checklist Node (Outline style)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: const Color(0xFFEFF1F4),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFEEF2FF),
                                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Color(0xFF7C4DFF),
                                      size: 20,
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
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF94A3B8),
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.venue,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF111111),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // About Node (Outline style)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: const Color(0xFFEFF1F4),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ABOUT THIS EVENT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF94A3B8),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.description.isNotEmpty
                                        ? widget.description
                                        : 'No description available for this event.',
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      height: 1.6,
                                      color: Color(0xFF475569),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Action Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 18.0,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFEFF1F4), width: 1.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (role == 'admin') ...[
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditEventPage(docId: widget.did),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Update',
                                  style: TextStyle(
                                    color: Color(0xFF111111),
                                    fontWeight: FontWeight.w800,
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
                                backgroundColor: const Color(0xFF111111),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () async {
                                final uid = FirebaseAuth.instance.currentUser!.uid;

                                final query = await FirebaseFirestore.instance
                                    .collection("registrations")
                                    .where("userId", isEqualTo: uid)
                                    .where("eventId", isEqualTo: widget.eventId)
                                    .get();

                                if (query.docs.isEmpty) {
                                  final regId = const Uuid().v4();
                                  await FirestoreService().registerEvent(
                                    RegistrationModel(
                                      registrationId: regId,
                                      eventId: widget.eventId,
                                      userId: uid,
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
                                  fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
