import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/models/creative_post_model.dart';

class CreativePreviewCard extends StatelessWidget {
  final CreativePostModel post;
  final VoidCallback onTap;

  const CreativePreviewCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  Color get badgeColor {
    switch (post.contentType) {
      case "writing":
        return Colors.deepPurple;
      case "article":
        return Colors.blue;
      case "imageGallery":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData get badgeIcon {
    switch (post.contentType) {
      case "writing":
        return Icons.edit_note;
      case "article":
        return Icons.article;
      case "imageGallery":
        return Icons.photo_library;
      default:
        return Icons.description;
    }
  }

  String get badgeTitle {
    switch (post.contentType) {
      case "writing":
        return "Writing";
      case "article":
        return "Article";
      case "imageGallery":
        return "Gallery";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(.05),
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: post.coverImage,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            post.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Icon(
                            badgeIcon,
                            size: 14,
                            color: badgeColor,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            badgeTitle,
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      post.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}