import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';

class AnnouncementDetailPage extends ConsumerStatefulWidget {
  const AnnouncementDetailPage({
    super.key,
    required this.announcementId,
    required this.title,
    required this.content,
  });

  final String announcementId;
  final String title;
  final String content;

  @override
  ConsumerState<AnnouncementDetailPage> createState() =>
      _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState
    extends ConsumerState<AnnouncementDetailPage> {
  final TextEditingController commentController = TextEditingController();

  Future<void> addComment() async {
    if (commentController.text.trim().isEmpty) {
      return;
    }
    final user = ref.read(currentUserProvider);
    final commentId = FirebaseFirestore.instance
        .collection("announcements")
        .doc(widget.announcementId)
        .collection("comments")
        .doc()
        .id;

    await FirebaseFirestore.instance
        .collection("announcements")
        .doc(widget.announcementId)
        .collection("comments")
        .doc(commentId)
        .set({
          "id": commentId,
          "userName": user!.name, // later currentUser.name
          "userId": user.uid, // later currentUser.uid
          "comment": commentController.text.trim(),
          "createdAt": Timestamp.now(),
        });

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Announcement")),

      body: Column(
        children: [
          // Announcement Card
          Card(
            margin: const EdgeInsets.all(12),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(widget.content),
                ],
              ),
            ),
          ),

          const Divider(),

          const Text(
            "Comments",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // Comments List
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("announcements")
                  .doc(widget.announcementId)
                  .collection("comments")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No comments yet"));
                }

                return ListView.builder(
                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    final data = docs[index].data();

                    return ListTile(
                      title: Text(data["userName"]),

                      subtitle: Text(data["comment"]),
                    );
                  },
                );
              },
            ),
          ),

          // Comment Box
          Padding(
            padding: const EdgeInsets.all(10),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,

                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                IconButton(onPressed: addComment, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
