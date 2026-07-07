import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexevent/models/creative_post_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/creative/creative_detail_page.dart';
import 'package:nexevent/screens/creative/creative_post.dart';

class CreativePage extends ConsumerStatefulWidget {
  const CreativePage({super.key});

  @override
  ConsumerState<CreativePage> createState() => _CreativePageState();
}

class _CreativePageState extends ConsumerState<CreativePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Creative Corner',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: (user!.role == 'admin')
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreativePost()),
                );
              },
              icon: const Icon(Icons.note_alt_outlined),
              label: const Text('New Post'),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 2,
            )
          : const SizedBox(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("creative_posts")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No posts yet",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

     
          final posts = <CreativePostModel>[];
          for (final doc in docs) {
            try {
              posts.add(
                CreativePostModel.fromMap(doc.data() as Map<String, dynamic>),
              );
            } catch (_) {
              continue;
            }
          }

          if (posts.isEmpty) {
            return Center(
              child: Text(
                "Couldn't load posts",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 90),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return CreativePostCard(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}

class CreativePostCard extends StatelessWidget {
  final CreativePostModel post;

  const CreativePostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    switch (post.contentType) {
      case "writing":
        return _WritingCard(post);

      case "article":
        return _ArticleCard(post);

      case "imageGallery":
        return _GalleryCard(post);

      default:
        return const SizedBox();
    }
  }
}


Widget _cardWrapper({required Widget child, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    ),
  );
}

Widget _networkImage(String url, {double? height, BoxFit fit = BoxFit.cover}) {
  return CachedNetworkImage(
    imageUrl: url,
    height: height,
    width: double.infinity,
    fit: fit,
    placeholder: (context, _) => Container(
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
    errorWidget: (context, _, __) => Container(
      height: height,
      color: Colors.grey.shade200,
      child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400),
    ),
  );
}

// Widget _engagementRow(CreativePostModel post) {
//   return Row(
//     children: [
//       Icon(Icons.favorite_border, size: 18, color: Colors.grey.shade600),
//       const SizedBox(width: 5),
//       Text(
//         "${post.likeCount}",
//         style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
//       ),
//       const SizedBox(width: 18),
//       Icon(Icons.comment_outlined, size: 18, color: Colors.grey.shade600),
//       const SizedBox(width: 5),
//       Text(
//         "${post.commentCount}",
//         style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
//       ),
//     ],
//   );
// }

Widget _titleText(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.2,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

Future<void> _openArticlePdf(
  BuildContext context,
  CreativePostModel post,
) async {
  if (post.mediaUrls.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No PDF attached to this article")),
    );
    return;
  }

  final uri = Uri.tryParse(post.mediaUrls.first);
  if (uri == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Invalid PDF link")));
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Couldn't open the PDF")));
  }
}


class _WritingCard extends StatelessWidget {
  final CreativePostModel post;

  const _WritingCard(this.post);

  @override
  Widget build(BuildContext context) {
    return _cardWrapper(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CreativeDetailPage(post: post, contentType: 'writing'),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.coverImage.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _networkImage(post.coverImage, height: 160),
              ),
              const SizedBox(height: 14),
            ],

            _titleText(post.title),
            const SizedBox(height: 6),

            Text(
              post.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),

            const SizedBox(height: 14),
            // _engagementRow(post),
          ],
        ),
      ),
    );
  }
}
class _ArticleCard extends StatelessWidget {
  final CreativePostModel post;

  const _ArticleCard(this.post);

  @override
  Widget build(BuildContext context) {
    return _cardWrapper(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CreativeDetailPage(post: post, contentType: 'article'),
          ),
        );
      },
      child: Column(
        children: [
          _networkImage(post.coverImage, height: 170),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleText(post.title),
                const SizedBox(height: 6),

                Text(
                  post.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _openArticlePdf(context, post),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: const Text("Read Article"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                // _engagementRow(post),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _GalleryCard extends StatelessWidget {
  final CreativePostModel post;

  const _GalleryCard(this.post);

  @override
  Widget build(BuildContext context) {
    return _cardWrapper(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CreativeDetailPage(post: post, contentType: 'imageGallery'),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _networkImage(post.coverImage, height: 170),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleText(post.title),
                const SizedBox(height: 6),

                Text(
                  post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),

                const SizedBox(height: 14),

                if (post.mediaUrls.isNotEmpty)
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: post.mediaUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              width: 90,
                              height: 90,
                              imageUrl: post.mediaUrls[index],
                              placeholder: (context, _) => Container(
                                color: Colors.grey.shade200,
                                width: 90,
                                height: 90,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),
                // _engagementRow(post),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
