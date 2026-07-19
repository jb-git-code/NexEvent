import 'dart:ffi';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexevent/models/event_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/home/event_detail_page.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/ui/app_colors.dart';

/// Insti Feed — big poster-card feed screen (matches the reference design).
/// Each card = full-bleed event poster → colored community strip → meta.
class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {
  static const _bg = Color(0xFFF8FAFC);
  static const _primary = Color(0xFF4361EE);
  static const _text = Color(0xFF14151A);
  static const _muted = Color(0xFF64748B);
  static const _navBg = Color(0xFF232742);

  String _query = '';

  @override
  Widget build(BuildContext context) {
    ref.watch(currentUserProvider); // kept for parity with EventsPage

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _titleBar(),
            const SizedBox(height: 14),
            _searchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: FirestoreService().getEvents("events"),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    );
                  }

                  final docs = snapshot.data!.docs.where((d) {
                    if (_query.isEmpty) return true;
                    final map = d.data() as Map<String, dynamic>;
                    final name = (map['name'] ?? '').toString().toLowerCase();
                    return name.contains(_query.toLowerCase());
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No events found',
                        style: TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final event = EventModel.fromMap(data);
                      final status = FirestoreService().getStatus(event);
                      return _posterCard(context, doc.id, data, status);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Row(
          children: [
            Text(
              'College ',
              style: GoogleFonts.storyScript(
                fontSize: 24,

                fontWeight: FontWeight.bold,

                color: Colors.black,
              ),
            ),
            Text(
              'Feed',
              style: GoogleFonts.storyScript(
                fontSize: 24,

                fontWeight: FontWeight.bold,

                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _text, width: 1.4),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: _text, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search events...',
                  hintStyle: TextStyle(color: AppColors.muted, fontSize: 14),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                style: const TextStyle(fontSize: 14, color: _text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
    String status,
  ) {
    final eventName = data['name'] ?? 'Untitled Event';
    final venue = data['venue'] ?? 'TBD';
    final imageUrl = data['imageUrl'] ?? '';
    final isCancelled = data['isCancelled'] == true;

    // Community/club info — adjust these field names to match your schema.
    final communityName =
        data['organizerName'] ?? data['clubName'] ?? 'Community';
    final communityLogo = data['organizerLogo'] ?? data['clubLogo'] ?? '';

    final dateLabel = _formatDate(data['eventDate']);
    final displayStatus = isCancelled ? 'Cancelled' : status;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 400),

        closedElevation: 0,
        openElevation: 0,

        closedColor: Colors.transparent,
        openColor: Colors.white,

        openBuilder: (context, _) => EventDetailPage(
          name: eventName,
          eventId: data['eventId'] ?? '',
          venue: venue,
          description: data['description'] ?? '',
          did: docId,
          imageUrl: imageUrl,
          status: status,
          isCancelled: isCancelled,
          eventDateText: dateLabel,
          endDateText: '',
          regisCount: data["regisCount"],
        ),

        closedBuilder: (context, openContainer) {
          return GestureDetector(
            onTap: openContainer,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(color: _text),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    color: _primary,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          backgroundImage: communityLogo.isNotEmpty
                              ? CachedNetworkImageProvider(communityLogo)
                              : null,
                          child: communityLogo.isEmpty
                              ? const Icon(
                                  Icons.groups_rounded,
                                  size: 14,
                                  color: _primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          communityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.people, color: Colors.white, size: 24),
                        const SizedBox(width: 4),
                        Text(
                          data["regisCount"].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Meta: date/status + title ─────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$dateLabel | $displayStatus',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isCancelled ? Colors.red : _muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          eventName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _text,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // row can be removed here
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['description'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic ts) {
    DateTime? dt;
    if (ts is Timestamp) {
      dt = ts.toDate();
    } else if (ts is DateTime) {
      dt = ts;
    }
    if (dt == null) return 'Date TBA';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $hour12:$minute $period';
  }
}
