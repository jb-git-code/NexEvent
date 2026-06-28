import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/models/event_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/home/event_detail_page.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/services/storage_services.dart';
import 'package:nexevent/widgets/grid_background.dart';

class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {
  String selectedFilter = 'All';

  Future<void> deleteEv(String eid) async {
    await FirestoreService().deleteEvent(eid);
  }

  @override
  Widget build(BuildContext context) {
    final currUser = ref.watch(currentUserProvider);
    // final role = currUser?.role ?? 'student';
    final role = 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: GridDotBackground(
        child: StreamBuilder(
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

            final allDocs = snapshot.data!.docs;

            // Dynamic category count map
            int allCount = allDocs.length;
            int techCount = 0;
            int musicCount = 0;
            int sportsCount = 0;
            int artsCount = 0;

            for (var d in allDocs) {
              final map = d.data() as Map<String, dynamic>;
              final cat = (map["category"] ?? "")
                  .toString()
                  .toLowerCase()
                  .trim();
              if (cat.contains("tech") ||
                  cat.contains("code") ||
                  cat.contains("hack") ||
                  cat.contains("dev")) {
                techCount++;
              } else if (cat.contains("music") ||
                  cat.contains("party") ||
                  cat.contains("concert") ||
                  cat.contains("dance") ||
                  cat.contains("fest")) {
                musicCount++;
              } else if (cat.contains("sport") ||
                  cat.contains("fit") ||
                  cat.contains("gym") ||
                  cat.contains("play") ||
                  cat.contains("health")) {
                sportsCount++;
              } else if (cat.contains("art") ||
                  cat.contains("culture") ||
                  cat.contains("exhibit") ||
                  cat.contains("paint") ||
                  cat.contains("design")) {
                artsCount++;
              }
            }

            // Filter document list based on selection
            final filteredDocs = allDocs.where((d) {
              if (selectedFilter == 'All') return true;
              final map = d.data() as Map<String, dynamic>;
              final cat = (map["category"] ?? "")
                  .toString()
                  .toLowerCase()
                  .trim();

              if (selectedFilter == 'Tech') {
                return cat.contains("tech") ||
                    cat.contains("code") ||
                    cat.contains("hack") ||
                    cat.contains("dev");
              }
              if (selectedFilter == 'Music') {
                return cat.contains("music") ||
                    cat.contains("party") ||
                    cat.contains("concert") ||
                    cat.contains("dance") ||
                    cat.contains("fest");
              }
              if (selectedFilter == 'Sports') {
                return cat.contains("sport") ||
                    cat.contains("fit") ||
                    cat.contains("gym") ||
                    cat.contains("play") ||
                    cat.contains("health");
              }
              if (selectedFilter == 'Arts') {
                return cat.contains("art") ||
                    cat.contains("culture") ||
                    cat.contains("exhibit") ||
                    cat.contains("paint") ||
                    cat.contains("design");
              }
              return true;
            }).toList();

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 3. Category Filter Tabs Row (Pills style)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterPill('All', allCount),
                        _buildFilterPill('Tech', techCount),
                        _buildFilterPill('Music', musicCount),
                        _buildFilterPill('Sports', sportsCount),
                        _buildFilterPill('Arts', artsCount),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Main Event Cards List
                  if (filteredDocs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.event_busy_rounded,
                              size: 40,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No matches found in this category',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...List.generate(filteredDocs.length, (index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final event = EventModel.fromMap(data);
                      final status = FirestoreService().getStatus(event);

                      // Cycle pastel backings
                      final List<Color> cardColors = [
                        const Color(0xFFEEF2FF), // Soft Indigo/Blue
                        const Color(0xFFFFF1F2), // Soft Pink
                        const Color(0xFFECFDF5), // Soft Mint
                        const Color(0xFFFFFBEB), // Soft Yellow
                      ];
                      final Color cardBg =
                          cardColors[index % cardColors.length];

                      return _buildEventCardItem(
                        context,
                        doc.id,
                        data,
                        cardBg,
                        status,
                        role,
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterPill(String filterName, int count) {
    final isSelected = selectedFilter == filterName;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filterName;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? const Color(0xFF111111) : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF111111)
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filterName,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formats a Firestore Timestamp / DateTime into "Jun 27, 2026 • 8:47 PM"
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour12:$minute $period';
  }

  // Color for the status chip (live / upcoming / completed / cancelled)
  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('live') || s.contains('ongoing')) {
      return const Color(0xFF16A34A);
    }
    if (s.contains('upcoming')) return const Color(0xFF4F46E5);
    if (s.contains('cancel')) return const Color(0xFFEF4444);
    return const Color(0xFF64748B); // completed / default
  }

  Widget _buildEventCardItem(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
    Color bg,
    String status,
    String role,
  ) {
    final eventName = data["name"] ?? 'Untitled Event';
    final eventVenue = data["venue"] ?? 'TBD';
    final imageUrl = data["imageUrl"] ?? '';
    final category = (data["category"] ?? 'General').toString();
    final isCancelled = data["isCancelled"] == true;

    final eventDateStr = _formatDate(data["eventDate"]);
    final endDateStr = _formatDate(data["endDate"]);
    final showEndDate = data["endDate"] != null && endDateStr != eventDateStr;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(
                name: eventName,
                eventId: data["eventId"] ?? '',
                venue: eventVenue,
                description: data["description"] ?? '',
                did: docId,
                imageUrl: imageUrl,
                status: status,
                isCancelled: isCancelled,
                eventDateText: eventDateStr,
                endDateText: showEndDate ? endDateStr : '',
              ),
            ),
          );
        },
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.black.withOpacity(0.04),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Poster image with overlaid info ----
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // image / fallback
                    imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.white.withOpacity(0.6),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.white.withOpacity(0.6),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  size: 30,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white.withOpacity(0.6),
                            child: const Center(
                              child: Icon(
                                Icons.bolt,
                                color: Color(0xFF111111),
                                size: 34,
                              ),
                            ),
                          ),

                    // bottom gradient scrim so name/status stay readable
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 26, 12, 10),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xCC000000)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              eventName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCancelled
                                        ? const Color(0xFFEF4444)
                                        : _statusColor(status),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isCancelled ? 'Cancelled' : status,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // category chip
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category.isEmpty
                              ? 'General'
                              : category[0].toUpperCase() +
                                    category.substring(1),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    // delete button (admin only)
                    if (role == 'admin')
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete Event?"),
                                content: const Text(
                                  "Are you sure you want to permanently delete this event?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteEv(docId);
                                      StorageService().deletePoster(docId);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ---- Venue + date, single compact row ----
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        eventVenue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        showEndDate
                            ? '$eventDateStr → $endDateStr'
                            : eventDateStr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
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
