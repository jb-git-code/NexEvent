import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/community/community_detail_page.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/theme/app_theme.dart';

// final likeProvider = StateProvider<bool> ((ref){

// });

class AllAnnouncements extends ConsumerStatefulWidget {
  const AllAnnouncements({super.key});

  @override
  ConsumerState<AllAnnouncements> createState() => _AllAnnouncementsState();
}

class _AllAnnouncementsState extends ConsumerState<AllAnnouncements> {
  bool isPinned = false;
  Future<void> _confirmDelete(String docId) async {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Announcement', style: text.h3),
        content: Text(
          'This action cannot be undone. Continue?',
          style: text.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: text.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: text.bodyMedium.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirestoreService().deleteAnnouncemnt(docId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.textPrimary,
          content: Text(
            'Announcement deleted',
            style: TextStyle(color: colors.background),
          ),
        ),
      );
    }
  }

  Future<void> likeAnnouncement(String announcementId, String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection("announcements")
        .doc(announcementId)
        .collection("likes")
        .doc(uid)
        .get();

    if (doc.exists) return;

    await FirebaseFirestore.instance
        .collection("announcements")
        .doc(announcementId)
        .collection("likes")
        .doc(uid)
        .set({"likedAt": Timestamp.now()});
  }

  Future<void> unlikeAnnouncement(String announcementId, String uid) async {
    await FirebaseFirestore.instance
        .collection("announcements")
        .doc(announcementId)
        .collection("likes")
        .doc(uid)
        .delete();
  }

  Future<void> togglePin(String announcementId, bool currentState) async {
    await FirebaseFirestore.instance
        .collection("announcements")
        .doc(announcementId)
        .update({"isPinned": !currentState});
  }

  @override
  Widget build(BuildContext context) {
    print('current user -> ${FirebaseAuth.instance.currentUser}');
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Announcements')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            // .where("channelId", isEqualTo: "photography_club")
            .orderBy("isPinned", descending: true)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.calendarOff,
                    size: 48,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(height: 14),
                  Text('No Announcements Yet', style: text.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Check back later for exciting updates!',
                    style: text.caption,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index].data();
              final docId = docs[index].id;
              final bool pinned = doc["isPinned"] ?? false;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementDetailPage(
                        announcementId: doc["id"],
                        title: doc["title"],
                        content: doc["content"],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.megaphone,
                          color: colors.warning,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc["title"] ?? '',
                              style: text.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doc["content"] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySecondary.copyWith(height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => togglePin(doc["id"], pinned),
                            child: Icon(
                              LucideIcons.pin,
                              size: 18,
                              color: pinned
                                  ? colors.warning
                                  : colors.textTertiary,
                            ),
                          ),
                          if (user?.role == 'admin') ...[
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () => _confirmDelete(docId),
                              child: Icon(
                                LucideIcons.trash2,
                                size: 18,
                                color: colors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
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
