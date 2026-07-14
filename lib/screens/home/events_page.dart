import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexevent/models/event_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/home/event_detail_page.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/services/storage_services.dart';
import 'package:nexevent/theme/app_theme.dart';

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
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);
    final currUser = ref.watch(currentUserProvider);
    // final role = currUser?.role ?? 'student';
    // final role = 'admin';

    return Scaffold(
      backgroundColor: colors.background,
      body: StreamBuilder(
        stream: FirestoreService().getEvents("events"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: colors.primary,
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: colors.primary,
              ),
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
            final cat = (map["category"] ?? "").toString().toLowerCase().trim();
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
            final cat = (map["category"] ?? "").toString().toLowerCase().trim();

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // Category filter pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterPill(context, 'All', allCount),
                      _buildFilterPill(context, 'Tech', techCount),
                      _buildFilterPill(context, 'Music', musicCount),
                      _buildFilterPill(context, 'Sports', sportsCount),
                      _buildFilterPill(context, 'Arts', artsCount),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (filteredDocs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.surfaceAlt,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.calendarOff,
                            size: 32,
                            color: colors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No matches found in this category',
                          style: text.bodySecondary,
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

                    return _buildEventCardItem(
                      context,
                      doc.id,
                      data,
                      status,
                      currUser!.role,
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterPill(BuildContext context, String filterName, int count) {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);
    final isSelected = selectedFilter == filterName;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filterName;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isSelected ? colors.primary : colors.surface,
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filterName,
              style: text.bodyMedium.copyWith(
                color: isSelected ? colors.onPrimary : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: text.caption.copyWith(
                color: isSelected
                    ? colors.onPrimary.withValues(alpha: 0.75)
                    : colors.textTertiary,
                fontWeight: FontWeight.w600,
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
  Color _statusColor(BuildContext context, String status) {
    final colors = AppColors.of(context);
    final s = status.toLowerCase();
    if (s.contains('live') || s.contains('ongoing')) return colors.success;
    if (s.contains('upcoming')) return colors.primary;
    if (s.contains('cancel')) return colors.error;
    return colors.textTertiary; // completed / default
  }

  Widget _buildEventCardItem(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
    String status,
    String role,
  ) {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    final eventName = data["name"] ?? 'Untitled Event';
    final eventVenue = data["venue"] ?? 'TBD';
    final imageUrl = data["imageUrl"] ?? '';
    final category = (data["category"] ?? 'General').toString();
    final isCancelled = data["isCancelled"] == true;

    final eventDateStr = _formatDate(data["eventDate"]);
    final endDateStr = _formatDate(data["endDate"]);
    final showEndDate = data["endDate"] != null && endDateStr != eventDateStr;
    final statusColor = isCancelled
        ? colors.error
        : _statusColor(context, status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            eventName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.h3,
                          ),
                        ),
                        if (role == 'admin') ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _confirmDelete(context, docId),
                            child: Icon(
                              LucideIcons.trash2,
                              size: 24,
                              color: Colors.red[300],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isCancelled ? 'Cancelled' : status,
                          style: text.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.info,
                          size: 13,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Tap the card for more info',
                            style: text.caption.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('Delete Event?', style: text.h3),
        content: Text(
          'Are you sure you want to permanently delete this event?',
          style: text.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: text.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              deleteEv(docId);
              StorageService().deletePoster(docId);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: text.bodyMedium.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}
