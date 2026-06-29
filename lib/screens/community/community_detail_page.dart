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
          "branch": user.branch,
          "batch": user.batch,
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
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 0.8,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  child: Text(
                                    data["userName"][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data["userName"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        "${data["branch"]} • ${data["batch"]}",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (data["userId"] == currentUser!.uid ||
                                    currentUser.role == "admin")
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      splashRadius: 18,
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text(
                                              "Delete Comment?",
                                            ),
                                            content: const Text(
                                              "Are you sure you want to permanently delete this comment?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                        "announcements",
                                                      )
                                                      .doc(
                                                        widget.announcementId,
                                                      )
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

                                        // Navigator.pop(context);
                                      },
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              data["comment"],
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.35,
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
