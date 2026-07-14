import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/community/comment_sheet.dart';
import 'package:nexevent/screens/community/create_post.dart';
import 'package:nexevent/services/firestore_service.dart';

class CollegeFeed extends StatefulWidget {
  const CollegeFeed({super.key});

  @override
  State<CollegeFeed> createState() => _CollegeFeedState();
}

class _CollegeFeedState extends State<CollegeFeed> {
  String _timeAgo(dynamic ts) {
    DateTime? dt;
    if (ts is Timestamp) dt = ts.toDate();
    if (dt == null) return '';

    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

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
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Community',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(width: 20),
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePost()),
          );
        },
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Post',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder(
        stream: FirestoreService().getEvents('posts'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.4),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.4),
            );
          }

          // Filter out soft-deleted posts
          final documents = snapshot.data!.docs.where((doc) {
            final map = doc.data() as Map<String, dynamic>;
            return map["isDeleted"] != true;
          }).toList();

          // Most recent post first
          documents.sort((a, b) {
            final aTs = (a.data() as Map<String, dynamic>)["createdAt"];
            final bTs = (b.data() as Map<String, dynamic>)["createdAt"];
            if (aTs is! Timestamp || bTs is! Timestamp) return 0;
            return bTs.compareTo(aTs);
          });

          if (documents.isEmpty) {
            return Center(
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
                      Icons.photo_camera_back_outlined,
                      size: 40,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No posts yet',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to share something!',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            physics: const BouncingScrollPhysics(),
            itemCount: documents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final postData = documents[index].data() as Map<String, dynamic>;
              final postId = postData["postId"] as String;
              return _PostCard(
                key: ValueKey(postId), // <-- prevents State mismatch on rebuild
                userName: postData["userName"] ?? 'Anonymous',
                caption: postData["caption"] ?? '',
                imageUrl: postData["imageUrl"] ?? '',
                likeCount: postData["likeCount"] ?? 0,
                commentCount: postData["commentCount"] ?? 0,
                timeAgo: _timeAgo(postData["createdAt"]),
                postId: postId,
              );
            },
          );
        },
      ),
    );
  }
}

class _PostCard extends ConsumerStatefulWidget {
  const _PostCard({
    super.key,
    required this.userName,
    required this.caption,
    required this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.timeAgo,
    required this.postId,
  });

  final String userName;
  final String caption;
  final String imageUrl;
  final int likeCount;
  final int commentCount;
  final String timeAgo;
  final String postId;

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
  Future<void> toggleLike(String postId, String uid) async {
    final postRef = FirebaseFirestore.instance.collection("posts").doc(postId);
    final likeRef = postRef.collection("likes").doc(uid);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);

      if (likeSnap.exists) {
        // already liked -> unlike
        tx.delete(likeRef);
        tx.update(postRef, {"likeCount": FieldValue.increment(-1)});
      } else {
        // not liked yet -> like
        tx.set(likeRef, {"likedAt": Timestamp.now()});
        tx.update(postRef, {"likeCount": FieldValue.increment(1)});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final initial = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'U';

    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEFF1F4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header: avatar + name + time ----
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                      ),
                      if (widget.timeAgo.isNotEmpty)
                        Text(
                          widget.timeAgo,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---- Poster image ----
          if (widget.imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: GestureDetector(
                onDoubleTap: uid == null
                    ? null
                    : () => toggleLike(widget.postId, uid),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        size: 32,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ---- Caption ----
          if (widget.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Text(
                widget.caption,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
            ),

          // ---- Like / comment counts ----
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                // ---- Like button: state is derived live from Firestore ----
                if (uid == null)
                  const Icon(
                    Icons.favorite_border,
                    size: 24,
                    color: Color(0xFF94A3B8),
                  )
                else
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postId)
                        .collection('likes')
                        .doc(uid)
                        .snapshots(),
                    builder: (context, likeSnap) {
                      final isLiked = likeSnap.data?.exists ?? false;
                      return GestureDetector(
                        onTap: () => toggleLike(widget.postId, uid),
                        child: Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border,
                          size: 24,
                          color: isLiked
                              ? const Color(0xFFEF0E0E)
                              : const Color(0xFF94A3B8),
                        ),
                      );
                    },
                  ),
                const SizedBox(width: 5),
                Text(
                  '${widget.likeCount}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 18),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) => CommentSheet(postId: widget.postId),
                  ),
                  child: const Icon(Icons.chat_bubble_rounded),
                ),
                const SizedBox(width: 5),
                Text(
                  '${widget.commentCount}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}