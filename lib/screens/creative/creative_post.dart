import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexevent/models/creative_post_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/services/storage_services.dart';
import 'package:nexevent/widgets/content_type_card.dart';
import 'package:uuid/uuid.dart';

class CreativePost extends ConsumerStatefulWidget {
  const CreativePost({super.key});

  @override
  ConsumerState<CreativePost> createState() => _CreativePostState();
}

class _CreativePostState extends ConsumerState<CreativePost> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  String? selectedChannel;
  final pidGlobal = const Uuid().v4();
  File? imageFile;
  final ImagePicker picker = ImagePicker();
  String selectedType = "writing";
  PlatformFile? selectedDocument;
  String img = "";

  bool isPublishing = false;
  bool isUploadingCover = false; // drives the loader shown on the cover box

  List<XFile> images = [];

  final mpicker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imageFile = File(image.path);
      });
      if (context.mounted) {
        const snackbar = SnackBar(content: Text('Image Selected'));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } else {
      if (context.mounted) {
        const snackbar = SnackBar(content: Text('No Image Selected'));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }

    if (imageFile == null) return;

    setState(() => isUploadingCover = true); // show loader while uploading

    String imageUrl = await StorageService().uploadPoster(
      imageFile!,
      pidGlobal,
    );

    if (!mounted) return;
    setState(() {
      img = imageUrl;
      isUploadingCover = false;
    });
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        selectedDocument = result.files.first;
      });
    }
  }

  Future<void> pickImages() async {
    final result = await mpicker.pickMultiImage();

    if (result.isNotEmpty) {
      setState(() {
        images = result;
      });
    }
  }

  void showSnackBar(String s) {
    final snack = SnackBar(content: Text(s));
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  Future<void> publishGallery() async {
    if (images.isEmpty) {
      showSnackBar("Select images");
      return;
    }

    if (imageFile == null) {
      showSnackBar("Select cover image");
      return;
    }

    final user = ref.read(currentUserProvider);

    try {
      // Cover upload
      final coverUrl = await StorageService().uploadPoster(
        imageFile!,
        pidGlobal,
      );

      // Gallery upload — uploaded in parallel instead of one-by-one
      final imageUrls = await Future.wait(
        images.map(
          (image) => StorageService().uploadGalleryImage(
            File(image.path),
            pidGlobal,
            const Uuid().v4(),
          ),
        ),
      );

      await FirebaseFirestore.instance
          .collection("creative_posts")
          .doc(pidGlobal)
          .set(
            CreativePostModel(
              authorId: user!.uid,
              postId: pidGlobal,
              title: title.text.trim(),
              description: description.text.trim(),
              commentCount: 0,
              coverImage: coverUrl,
              contentType: "imageGallery",
              mediaUrls: imageUrls,
              createdAt: DateTime.now(),
              likeCount: 0,
              isPinned: false,
              authorName: user.name,
              channelId: selectedChannel!,
              channelName: selectedChannel!,
            ).toMap(),
          );

      showSnackBar("Gallery published!");

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  Future<void> publishArticle() async {
    if (selectedDocument == null) {
      showSnackBar("Select PDF");
      return;
    }

    if (imageFile == null) {
      showSnackBar("Select cover image");
      return;
    }

    final user = ref.read(currentUserProvider);

    try {
      final coverUrl = await StorageService().uploadPoster(
        imageFile!,
        pidGlobal,
      );

      final pdfFile = File(selectedDocument!.path!);

      final pdfUrl = await StorageService().uploadArticle(pdfFile, pidGlobal);

      await FirebaseFirestore.instance
          .collection("creative_posts")
          .doc(pidGlobal)
          .set(
            CreativePostModel(
              authorId: user!.uid,
              postId: pidGlobal,
              title: title.text.trim(),
              description: description.text.trim(),
              commentCount: 0,
              coverImage: coverUrl,
              contentType: "article",
              mediaUrls: [pdfUrl],
              createdAt: DateTime.now(),
              likeCount: 0,
              isPinned: false,
              authorName: user.name,
              channelId: selectedChannel!,
              channelName: selectedChannel!,
            ).toMap(),
          );

      showSnackBar("Article published!");

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  Future<void> publishWriting() async {
    if (description.text.trim().isEmpty) {
      showSnackBar("Write something");
      return;
    }

    final user = ref.read(currentUserProvider);

    // cover optional

    // firestore

    await FirebaseFirestore.instance
        .collection("creative_posts")
        .doc(pidGlobal)
        .set(
          CreativePostModel(
            authorId: user!.uid,
            postId: pidGlobal,
            title: title.text.trim(),
            description: description.text,
            commentCount: 0,
            coverImage: img,
            contentType: selectedType,
            mediaUrls: [],
            createdAt: DateTime.now(),
            likeCount: 0,
            isPinned: false,
            authorName: user.name,
            channelId: selectedChannel!,
            channelName:
                selectedChannel!, //abhi channel name nahi daal rahe hai
          ).toMap(),
        );

    showSnackBar('posted!');
    Navigator.pop(context);
  }

  Future<void> publishPost() async {
    // Validates the Form (title field) before anything else runs
    final isFormValid = _formKey.currentState?.validate() ?? true;
    if (!isFormValid) return;

    if (title.text.trim().isEmpty) {
      showSnackBar("Enter title");
      return;
    }

    if (selectedChannel == null) {
      showSnackBar("Select a channel");
      return;
    }

    setState(() => isPublishing = true);

    switch (selectedType) {
      case "imageGallery":
        await publishGallery();
        break;

      case "article":
        await publishArticle();
        break;

      case "writing":
        await publishWriting();
        break;
      default:
        showSnackBar("Select content type");
    }

    if (mounted) {
      setState(() => isPublishing = false);
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  // ---------- UI helpers (styling only) ----------

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.8)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
    );
  }

  Widget _coverImagePicker({required double height, required String label}) {
    return GestureDetector(
      onTap: isUploadingCover ? null : pickImage,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: isUploadingCover
            ? const Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : (imageFile == null)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 30,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(imageFile!, fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _contentTypeSelector() {
    return SizedBox(
      height: 132,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            width: 220,
            child: ContentTypeCard(
              icon: Icons.photo_library,
              title: "Image Gallery",
              subtitle: "Share photos",
              isSelected: selectedType == "imageGallery",
              onTap: () {
                setState(() {
                  selectedType = "imageGallery";
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 220,
            child: ContentTypeCard(
              icon: Icons.article,
              title: "Article",
              subtitle: "Upload an article document",
              isSelected: selectedType == "article",
              onTap: () {
                setState(() {
                  selectedType = "article";
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 220,
            child: ContentTypeCard(
              icon: Icons.edit_note,
              title: "Writing",
              subtitle: "show creativity",
              isSelected: selectedType == "writing",
              onTap: () {
                setState(() {
                  selectedType = "writing";
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _channelDropdown() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("channels")
          .orderBy("name")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final channels = snapshot.data!.docs;

        return DropdownButtonFormField<String>(
          value: selectedChannel,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: _fieldDecoration(
            "Select Channel",
            icon: Icons.tag_rounded,
          ).copyWith(hintText: null, labelText: "Select Channel"),
          items: channels.map((doc) {
            final data = doc.data();

            return DropdownMenuItem<String>(
              value: data["channelId"],
              child: Text(data["name"]),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedChannel = value;
            });
          },
        );
      },
    );
  }

  Widget _writingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel("CONTENT"),
        TextField(
          controller: description,
          maxLines: 6,
          decoration: _fieldDecoration('Write your content...'),
        ),
        const SizedBox(height: 24),
        _sectionLabel("COVER IMAGE (OPTIONAL)"),
        _coverImagePicker(height: 180, label: "Add a cover image"),
      ],
    );
  }

  Widget _articleFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel("DESCRIPTION"),
        TextField(
          controller: description,
          maxLines: 4,
          decoration: _fieldDecoration('Article description'),
        ),
        const SizedBox(height: 24),
        _sectionLabel("COVER IMAGE"),
        _coverImagePicker(height: 150, label: "Add a cover image"),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            onPressed: pickDocument,
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
            label: Text(
              selectedDocument == null ? "Select PDF" : selectedDocument!.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _galleryFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel("DESCRIPTION"),
        TextField(
          controller: description,
          maxLines: 4,
          decoration: _fieldDecoration('Description'),
        ),
        const SizedBox(height: 24),
        _sectionLabel("COVER IMAGE"),
        _coverImagePicker(height: 130, label: "Add a cover image"),
        const SizedBox(height: 20),
        _sectionLabel("GALLERY IMAGES"),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            onPressed: pickImages,
            icon: const Icon(Icons.photo_library_outlined, size: 20),
            label: const Text("Select Images"),
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(images[index].path),
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Post',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel("TITLE"),
                TextFormField(
                  controller: title,
                  decoration: _fieldDecoration('Give your post a title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _sectionLabel("CONTENT TYPE"),
                _contentTypeSelector(),
                const SizedBox(height: 24),

                _sectionLabel("CHANNEL"),
                _channelDropdown(),
                const SizedBox(height: 28),

                // Type-specific fields
                if (selectedType == 'writing')
                  _writingFields()
                else if (selectedType == 'article')
                  _articleFields()
                else
                  _galleryFields(),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: isPublishing ? null : publishPost,
                    child: isPublishing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Publish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
