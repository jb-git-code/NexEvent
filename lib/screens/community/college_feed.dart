import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/community/comment_sheet.dart';
import 'package:nexevent/screens/community/create_post.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/theme/app_theme.dart';

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
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Community', style: text.h3),
            const SizedBox(width: 16),
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: text.bodySecondary,
            ),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePost()),
          );
        },
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        icon: const Icon(LucideIcons.plus),
        label: Text('New Post', style: text.button),
      ),
      body: StreamBuilder(
        stream: FirestoreService().getEvents('posts'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: colors.primary,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString(), style: text.bodySecondary),
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
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.camera,
                      size: 32,
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('No posts yet', style: text.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Be the first to share something!', style: text.caption),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 90),
            physics: const BouncingScrollPhysics(),
            itemCount: documents.length,
            separatorBuilder: (context, index) =>
                Divider(color: colors.divider, height: 1, thickness: 1),
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
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    final initial = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'U';

    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Header: avatar + name + time ----
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: text.bodyMedium.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (widget.timeAgo.isNotEmpty)
                Text(widget.timeAgo, style: text.caption),
            ],
          ),
        ),

        // ---- Post image, full-bleed like Instagram ----
        if (widget.imageUrl.isNotEmpty)
          AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onDoubleTap: uid == null
                  ? null
                  : () => toggleLike(widget.postId, uid),
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: colors.surfaceAlt,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colors.surfaceAlt,
                  child: Center(
                    child: Icon(
                      LucideIcons.imageOff,
                      size: 28,
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // ---- Action row: like / comment ----
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
          child: Row(
            children: [
              if (uid == null)
                Icon(LucideIcons.heart, size: 24, color: colors.textTertiary)
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
                        LucideIcons.heart,
                        size: 24,
                        color: isLiked ? colors.error : colors.textPrimary,
                      ),
                    );
                  },
                ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => CommentSheet(postId: widget.postId),
                ),
                child: Icon(
                  LucideIcons.messageCircle,
                  size: 23,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // ---- Likes count ----
        if (widget.likeCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(
              '${widget.likeCount} ${widget.likeCount == 1 ? 'like' : 'likes'}',
              style: text.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

        // ---- Caption, username inline like Instagram ----
        if (widget.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${widget.userName} ',
                    style: text.bodySecondary.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: widget.caption,
                    style: text.bodySecondary.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ---- Comment count link ----
        if (widget.commentCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => CommentSheet(postId: widget.postId),
              ),
              child: Text(
                'View ${widget.commentCount == 1 ? '1 comment' : '${widget.commentCount} comments'}',
                style: text.caption,
              ),
            ),
          ),

        const SizedBox(height: 14),
      ],
    );
  }
}
