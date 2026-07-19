import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/screens/community/create_post.dart';
import 'package:nexevent/screens/creative/creative_post.dart';
import 'package:nexevent/ui/app_colors.dart';
import 'package:nexevent/ui/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexevent/models/creative_post_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/creative/creative_detail_page.dart';

/// Creative Corner — themed + embeddable.
///
/// `CreativeFeed` is the reusable widget: drop it straight inside the
/// Explore page's ListView (set `embedded: true`, optionally `limit: 3`
/// for a preview + "See all"). `CreativeCornerPage` is the full standalone
/// screen it links out to.
class CreativeFeed extends ConsumerStatefulWidget {
  /// Cap how many posts to show. Null = show everything (full page use).
  final int? limit;

  /// When true: no internal scrolling (shrinkWrap + no physics) so this
  /// can sit inside another scrollable, e.g. the Explore page's ListView.
  final bool embedded;

  /// Shown above the list when embedded, with a "See all" link.
  final String sectionTitle;

  const CreativeFeed({
    super.key,
    this.limit,
    this.embedded = false,
    this.sectionTitle = 'Creative Corner',
  });

  @override
  ConsumerState<CreativeFeed> createState() => _CreativeFeedState();
}

class _CreativeFeedState extends ConsumerState<CreativeFeed> {
  @override
  Widget build(BuildContext context) {
    ref.watch(currentUserProvider); // kept for parity with original page

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("creative_posts")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _stateMessage(
            Icons.error_outline_rounded,
            "Something went wrong",
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.primary,
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _stateMessage(Icons.auto_stories_outlined, "No posts yet");
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
          return _stateMessage(
            Icons.auto_stories_outlined,
            "Couldn't load posts",
          );
        }

        final shown = widget.limit != null
            ? posts.take(widget.limit!).toList()
            : posts;

        final list = ListView.builder(
          shrinkWrap: widget.embedded,
          physics: widget.embedded
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: widget.embedded ? 0 : 8,
            bottom: widget.embedded ? 0 : 90,
          ),
          itemCount: shown.length,
          itemBuilder: (context, index) => CreativePostCard(post: shown[index]),
        );

        if (!widget.embedded) return list;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(widget.sectionTitle, style: AppTextStyles.h2),
                  const Spacer(),
                  if (widget.limit != null && posts.length > widget.limit!)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreativeCornerPage(),
                        ),
                      ),
                      child: Text(
                        'See all',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            list,
          ],
        );
      },
    );
  }

  Widget _stateMessage(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(text, style: AppTextStyles.bodyMuted),
          ],
        ),
      ),
    );
  }
}

/// Full standalone screen — what "See all" navigates to.
class CreativeCornerPage extends StatelessWidget {
  const CreativeCornerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Creative Corner', style: AppTextStyles.h2),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      body: const CreativeFeed(),
      floatingActionButton: TextButton.icon(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.accentGreen),
          foregroundColor: WidgetStatePropertyAll(AppColors.card),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreativePost()),
          );
        },
        label: Text('create'),
        icon: Icon(Icons.create),
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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.04),
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
      color: AppColors.card,
      child: const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    ),
    errorWidget: (context, _, __) => Container(
      height: height,
      color: AppColors.card,
      child: const Icon(Icons.broken_image_outlined, color: AppColors.muted),
    ),
  );
}

Widget _titleText(String title) {
  return Text(
    title,
    style: AppTextStyles.h3.copyWith(fontSize: 17, height: 1.2),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

Widget _descText(String text, int maxLines) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    style: AppTextStyles.bodyMuted,
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CreativeDetailPage(post: post, contentType: 'writing'),
        ),
      ),
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
            _descText(post.description, 4),
            const SizedBox(height: 14),
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CreativeDetailPage(post: post, contentType: 'article'),
        ),
      ),
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
                _descText(post.description, 3),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
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
                const SizedBox(height: 4),
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CreativeDetailPage(post: post, contentType: 'imageGallery'),
        ),
      ),
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
                _descText(post.description, 2),
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
                                color: AppColors.card,
                                width: 90,
                                height: 90,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
