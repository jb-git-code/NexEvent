import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/community/community_detail_page.dart';
import 'package:nexevent/screens/home/profile_page.dart';
import 'package:nexevent/services/firestore_service.dart';

// final likeProvider = StateProvider<bool> ((ref){

// });

class AllAnnouncements extends ConsumerStatefulWidget {
  const AllAnnouncements({super.key});

  @override
  ConsumerState<AllAnnouncements> createState() => _AllAnnouncementsState();
}

class _AllAnnouncementsState extends ConsumerState<AllAnnouncements> {
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

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
      body: StreamBuilder(
        stream: FirestoreService().getEvents('announcements'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 64,
                    color: Colors.grey[300],
                  ),
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

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
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
                            Text(
                              doc["title"] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doc["content"] ?? '',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Icon(Icons.favorite, color: Colors.red),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("announcements")
                                .doc(doc["id"])
                                .collection("likes")
                                .snapshots(),

                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text("0");
                              }

                              return Text(
                                snapshot.data!.docs.length.toString(),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 25),
                      Column(
                        children: [
                          Icon(Icons.messenger, color: Colors.blue),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("announcements")
                                .doc(doc["id"])
                                .collection("comments")
                                .snapshots(),

                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text("0");
                              }

                              return Text(
                                snapshot.data!.docs.length.toString(),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(width: 25),
                      if (user?.role == 'admin')
                        InkWell(
                          onTap: () => _confirmDelete(docId),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                          ),
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
