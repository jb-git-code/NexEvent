import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/services/post_service.dart';
import 'package:nexevent/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class CreatePost extends ConsumerStatefulWidget {
  const CreatePost({super.key});

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  File? selectedImage;
  String? img;
  final ImagePicker picker = ImagePicker();

  bool isUploadingImage = false;
  bool isPosting = false;

  final String pid = const Uuid().v4();
  final TextEditingController captionController = TextEditingController();

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
      isUploadingImage = true;
      img = null;
    });

    try {
      final url = await PostService().uploadImage(selectedImage!, pid);
      if (!mounted) return;
      setState(() {
        img = url;
        isUploadingImage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isUploadingImage = false;
        selectedImage = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
    }
  }

  Future<void> submitPost() async {
    final currentUser = ref.read(currentUserProvider);
    final caption = captionController.text.trim();

    if (selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }
    if (img == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for the image to finish uploading'),
        ),
      );
      return;
    }
    if (caption.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please write a caption')));
      return;
    }
    if (currentUser == null) return;

    setState(() => isPosting = true);

    try {
      await PostService().createPost(
        img: img!,
        user: currentUser,
        cap: caption,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Post Created'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => isPosting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not create post: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    final canPost =
        !isUploadingImage && !isPosting && selectedImage != null && img != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Create Post'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Image picker ----
              GestureDetector(
                onTap: isUploadingImage ? null : pickImage,
                child: Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (selectedImage != null)
                        Image.file(selectedImage!, fit: BoxFit.cover)
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.primaryMuted,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.imagePlus,
                                color: colors.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Tap to add a photo',
                              style: text.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'JPG or PNG from your gallery',
                              style: text.caption,
                            ),
                          ],
                        ),

                      // upload progress overlay
                      if (isUploadingImage)
                        Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.6,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Uploading...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // change-photo affordance when an image is set
                      if (selectedImage != null && !isUploadingImage)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.refreshCw,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Change',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ---- Caption ----
              Text('CAPTION', style: text.label),
              const SizedBox(height: 8),
              TextField(
                controller: captionController,
                maxLines: 4,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: text.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Share something about this moment...',
                ),
              ),
              const SizedBox(height: 28),

              // ---- Submit ----
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canPost ? submitPost : null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: colors.surfaceAlt,
                    disabledForegroundColor: colors.textTertiary,
                  ),
                  child: isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text('Share Post', style: text.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
