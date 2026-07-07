import 'package:flutter/material.dart';
import 'package:nexevent/models/creative_post_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CreativeDetailPage extends StatefulWidget {
  final CreativePostModel post;
  final String contentType;

  const CreativeDetailPage({
    super.key,
    required this.post,
    required this.contentType,
  });

  @override
  State<CreativeDetailPage> createState() => _CreativeDetailPageState();
}

class _CreativeDetailPageState extends State<CreativeDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((widget.post.coverImage ?? "").isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.post.coverImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            Text(
              widget.post.title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 5),
                Text(widget.post.authorName),

                const Spacer(),

                Text(widget.post.channelName),
              ],
            ),

            const SizedBox(height: 20),

            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.contentType) {
      case "writing":
        return _writing();

      case "article":
        return _article(context);

      case "imageGallery":
        return _gallery(context);

      default:
        return const SizedBox();
    }
  }

  Widget _writing() {
    return Text(
      widget.post.description,
      style: const TextStyle(fontSize: 17, height: 1.6),
    );
  }

  Widget _article(BuildContext context) {
    final pdfUrl = widget.post.mediaUrls[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(widget.post.description, style: const TextStyle(fontSize: 16)),

        const SizedBox(height: 25),

        FilledButton.icon(
          onPressed: () {
            launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.externalApplication);
          },

          icon: const Icon(Icons.picture_as_pdf),

          label: const Text("Open Article"),
        ),
      ],
    );
  }

  Widget _gallery(BuildContext context) {
    final List media = widget.post.mediaUrls;

    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: media.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        crossAxisSpacing: 10,

        mainAxisSpacing: 10,
      ),

      itemBuilder: (_, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),

          child: Image.network(media[index], fit: BoxFit.cover),
        );
      },
    );
  }
}
