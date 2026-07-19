import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/community/community_detail_page.dart';
import 'package:nexevent/services/firestore_service.dart';

class AllAnnouncements extends ConsumerStatefulWidget {
  const AllAnnouncements({super.key});

  @override
  ConsumerState<AllAnnouncements> createState() => _AllAnnouncementsState();
}

class _AllAnnouncementsState extends ConsumerState<AllAnnouncements> {
  // ---------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------

  Future<void> _confirmDelete(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Announcement'),
        content: const Text('This action cannot be undone. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirestoreService().deleteAnnouncemnt(docId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black87,
          content: Text('Announcement deleted'),
        ),
      );
    }
  }

  Future<void> _togglePin(String announcementId, bool currentState) async {
    await FirebaseFirestore.instance
        .collection('announcements')
        .doc(announcementId)
        .update({'isPinned': !currentState});
  }

  // Kept for whenever you want to wire the heart icon up to actual
  // like/unlike behaviour — not called anywhere right now.
  Future<void> _likeAnnouncement(String announcementId, String uid) async {
    final ref = FirebaseFirestore.instance
        .collection('announcements')
        .doc(announcementId)
        .collection('likes')
        .doc(uid);
    final doc = await ref.get();
    if (doc.exists) return;
    await ref.set({'likedAt': Timestamp.now()});
  }

  Future<void> _unlikeAnnouncement(String announcementId, String uid) async {
    await FirebaseFirestore.instance
        .collection('announcements')
        .doc(announcementId)
        .collection('likes')
        .doc(uid)
        .delete();
  }

  // ---------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = user?.role == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Announcements',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .orderBy('isPinned', descending: true)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return _AnnouncementCard(
                doc: docs[index],
                isAdmin: isAdmin,
                onTogglePin: _togglePin,
                onDelete: _confirmDelete,
              );
            },
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// EMPTY STATE
/// ---------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No Announcements Yet',
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
}

/// ---------------------------------------------------------------------
/// CARD
/// ---------------------------------------------------------------------
class _AnnouncementCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final bool isAdmin;
  final void Function(String id, bool currentState) onTogglePin;
  final void Function(String id) onDelete;

  const _AnnouncementCard({
    required this.doc,
    required this.isAdmin,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final docId = doc.id;
    final title = data['title'] as String? ?? '';
    final content = data['content'] as String? ?? '';
    final isPinned = data['isPinned'] as bool? ?? false;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnouncementDetailPage(
              announcementId: docId,
              title: title,
              content: content,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPinned ? Colors.orange.shade200 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Colors.deepOrange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (isPinned) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.push_pin,
                              size: 14,
                              color: Colors.orange,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        createdAt != null ? _timeAgo(createdAt) : '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                if (isAdmin)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'pin') onTogglePin(docId, isPinned);
                      if (value == 'delete') onDelete(docId);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(
                              isPinned
                                  ? Icons.push_pin_outlined
                                  : Icons.push_pin,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(isPinned ? 'Unpin' : 'Pin'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Delete',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _CountBadge(
                  icon: Icons.favorite,
                  color: Colors.red,
                  stream: FirebaseFirestore.instance
                      .collection('announcements')
                      .doc(docId)
                      .collection('likes')
                      .snapshots(),
                ),
                const SizedBox(width: 20),
                _CountBadge(
                  icon: Icons.mode_comment_outlined,
                  color: Colors.blue,
                  stream: FirebaseFirestore.instance
                      .collection('announcements')
                      .doc(docId)
                      .collection('comments')
                      .snapshots(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// ---------------------------------------------------------------------
/// LIKE / COMMENT COUNT — read-only for now (see _likeAnnouncement /
/// _unlikeAnnouncement in the state class if you want to wire it up).
/// ---------------------------------------------------------------------
class _CountBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  const _CountBadge({
    required this.icon,
    required this.color,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 5),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snap) {
            final count = snap.data?.docs.length ?? 0;
            return Text(
              '$count',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            );
          },
        ),
      ],
    );
  }
}
