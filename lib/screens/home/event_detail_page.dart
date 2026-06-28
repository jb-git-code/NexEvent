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
    this.status = '',
    this.isCancelled = false,
    this.eventDateText = '',
    this.endDateText = '',
  });

  final String name;
  final String eventId;
  final String description;
  final String venue;
  final String did;
  final String imageUrl;
  final String status;
  final bool isCancelled;
  final String eventDateText;
  final String endDateText;

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

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('live') || s.contains('ongoing')) {
      return const Color(0xFF16A34A);
    }
    if (s.contains('upcoming')) return const Color(0xFF4F46E5);
    if (s.contains('cancel')) return const Color(0xFFEF4444);
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.isCancelled
        ? const Color(0xFFEF4444)
        : _statusColor(widget.status);
    final statusLabel = widget.isCancelled ? 'Cancelled' : widget.status;
    final dateText = widget.endDateText.isNotEmpty
        ? '${widget.eventDateText} → ${widget.endDateText}'
        : widget.eventDateText;

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
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2.4))
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ---- Poster image with status overlay ----
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFEFF1F4),
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x08000000),
                                    blurRadius: 14,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  (widget.imageUrl.isNotEmpty)
                                      ? CachedNetworkImage(
                                          imageUrl: widget.imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Color(0xFF111111),
                                                    ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons.broken_image_rounded,
                                                size: 28,
                                              ),
                                        )
                                      : Container(
                                          color: const Color(0xFFEEF2FF),
                                          child: const Icon(
                                            Icons.event_note_rounded,
                                            color: Color(0xFF7C4DFF),
                                            size: 48,
                                          ),
                                        ),

                                  // status chip
                                  if (statusLabel.isNotEmpty)
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 11,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x14000000),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: statusColor,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              statusLabel,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w800,
                                                color: statusColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // ---- Title ----
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111111),
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ---- Location + Date info strip ----
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _infoTile(
                                    icon: Icons.place_outlined,
                                    label: 'LOCATION',
                                    value: widget.venue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _infoTile(
                                    icon: Icons.calendar_today_rounded,
                                    label: 'DATE',
                                    value: dateText.isNotEmpty
                                        ? dateText
                                        : 'TBA',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),
                            const Divider(color: Color(0xFFE2E8F0), height: 1),
                            const SizedBox(height: 18),

                            // ---- About ----
                            const Text(
                              'ABOUT THIS EVENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.description.isNotEmpty
                                  ? widget.description
                                  : 'No description available for this event.',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.55,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Action Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 14.0,
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFD1D5DB),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
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
                                    color: Color(0xFF111111),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () async {
                                final uid =
                                    FirebaseAuth.instance.currentUser!.uid;

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
                                        content: Text(
                                          "Registered Successfully!",
                                        ),
                                      ),
                                    );
                                  }
                                  await NotificationService()
                                      .showRegistrationSuccess(widget.name);
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
                                  fontSize: 15,
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

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFF1F4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEEF2FF),
            ),
            child: Icon(icon, color: const Color(0xFF7C4DFF), size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
