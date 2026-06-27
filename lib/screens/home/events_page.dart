import 'package:cached_network_image/cached_network_image.dart';
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
                              color: const Color(0xFF475569),
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
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

    // Mock segment slots calculation for capacity indicator
    // E.g. we use the event name hash code to create varied segment counts for UI representation
    final int totalSegments = 8;
    final int usedSegments =
        (eventName.hashCode.abs() % (totalSegments - 1)) + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
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
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // White circle icon box
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF111111),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image_rounded,
                              size: 20,
                            ),
                          )
                        : const Icon(
                            Icons.bolt,
                            color: Color(0xFF111111),
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 16),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111111),
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          eventVenue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Segmented progress indicator row
              Row(
                children: List.generate(totalSegments, (idx) {
                  final isFilled = idx < usedSegments;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 16,
                      decoration: BoxDecoration(
                        color: isFilled
                            ? const Color(0xFF7C4DFF).withOpacity(0.4)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isFilled
                              ? Colors.transparent
                              : const Color(0xFFD1D5DB),
                          style: isFilled
                              ? BorderStyle.none
                              : BorderStyle.solid,
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Bottom controls row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // // Outline Capacity label badge
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(16),
                  //     border: Border.all(
                  //       color: const Color(0xFFD1D5DB),
                  //       width: 1.5,
                  //     ),
                  //   ),
                  //   child: Text(
                  //     'Used ${usedSegments * 100} / 800',
                  //     style: const TextStyle(
                  //       fontSize: 11.5,
                  //       fontWeight: FontWeight.w800,
                  //       color: Color(0xFF475569),
                  //     ),
                  //   ),
                  // ),

                  // Trigger Button Details
                  Row(
                    children: [
                      if (role == 'admin') ...[
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFEF4444),
                            shape: const CircleBorder(),
                            side: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          onPressed: () {
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
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => EventDetailPage(
                      //           name: eventName,
                      //           eventId: data["eventId"] ?? '',
                      //           venue: eventVenue,
                      //           description: data["description"] ?? '',
                      //           did: docId,
                      //           imageUrl: imageUrl,
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 16,
                      //       vertical: 10,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(20),
                      //       color: Colors.white,
                      //       boxShadow: const [
                      //         BoxShadow(
                      //           color: Color(0x0A000000),
                      //           blurRadius: 8,
                      //           offset: Offset(0, 4),
                      //         ),
                      //       ],
                      //     ),
                      //     child: const Row(
                      //       children: [
                      //         Text(
                      //           'Start',
                      //           style: TextStyle(
                      //             fontSize: 13,
                      //             fontWeight: FontWeight.w800,
                      //             color: Color(0xFF111111),
                      //           ),
                      //         ),
                      //         SizedBox(width: 6),
                      //         Icon(
                      //           Icons.play_arrow_rounded,
                      //           size: 14,
                      //           color: Color(0xFF111111),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
