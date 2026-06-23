import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/services/firestore_service.dart';

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

  bool isliked = false;

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

  Future<void> isLiked() async {
    final currentUser = ref.read(currentUserProvider);

    final doc = await FirebaseFirestore.instance
        .collection("announcements")
        .doc(widget.announcementId)
        .collection("likes")
        .doc(currentUser!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        isliked = true;
      });
    }
  }

  Future<void> toggleLike() async {
    final currentUser = ref.read(currentUserProvider);

    if (isliked) {
      await FirestoreService().unlikeAnnouncement(
        widget.announcementId,
        currentUser!.uid,
      );
    } else {
      await FirestoreService().likeAnnouncement(
        widget.announcementId,
        currentUser!.uid,
      );
    }

    setState(() {
      isliked = !isliked;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLiked();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Announcement")),

      body: Column(
        children: [
          // Announcement Card
          Card(
            margin: const EdgeInsets.all(12),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: toggleLike,

                        icon: Icon(
                          isliked ? Icons.favorite : Icons.favorite_border,

                          color: isliked ? Colors.red : null,
                        ),
                      ),

                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("announcements")
                            .doc(widget.announcementId)
                            .collection("likes")
                            .snapshots(),

                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text("0");
                          }

                          return Text(snapshot.data!.docs.length.toString());
                        },
                      ),
                    ],
                  ),
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
                      trailing: data["userId"] == currentUser!.uid
                          ? IconButton(
                              icon: const Icon(Icons.delete),

                              onPressed: () async {

                                showDialog(
                                  context: context,

                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete Comment?"),

                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },

                                        child: const Text("Cancel"),
                                      ),

                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection("announcements")
                                              .doc(widget.announcementId)
                                              .collection("comments")
                                              .doc(data["id"])
                                              .delete();

                                          Navigator.pop(context);
                                        },

                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : null,
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
