import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/services/storage_services.dart';
import 'package:uuid/uuid.dart';

class CreativePost extends ConsumerStatefulWidget {
  const CreativePost({super.key});

  @override
  ConsumerState<CreativePost> createState() => _CreativePostState();
}

class _CreativePostState extends ConsumerState<CreativePost> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  String? selectedContent;
  String? selectedChannel;

  File? imageFile;
  final ImagePicker picker = ImagePicker();

  String img = "";
  String generateFix8DigitNumber() {
    final Random random = Random.secure();
    String result = '';

    // Loop hamesha 8 baar chalega
    for (int i = 0; i < 8; i++) {
      result += random.nextInt(10).toString(); // 0 se 9 tak ka random number
    }

    return result;
  }

  String? pidGlobal;

  Future<void> pickImage() async {
    // setState(() {
    //   isUploading = true;
    // });
    String pid = generateFix8DigitNumber();
    final user = ref.read(currentUserProvider);
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
    String imageUrl = await StorageService().uploadPoster(imageFile!, pid);
    setState(() {
      img = imageUrl;
      pidGlobal = pid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            //title box
            TextField(
              controller: title,
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            //description box
            TextField(
              controller: description,
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // content type drop down
            DropdownButtonFormField<String>(
              value: selectedContent,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8),
              ),
              decoration: InputDecoration(
                hintText: 'Select content type...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13.5,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF111111),
                    width: 1.5,
                  ),
                ),
              ),
              items: [
                _contentItem(
                  'imageGallery',
                  'Image Gallery',
                  Icons.photo_library_outlined,
                ),
                _contentItem('article', 'Article', Icons.article_outlined),
                _contentItem(
                  'newsletter',
                  'Newsletter',
                  Icons.mark_email_read_outlined,
                ),
              ],
              onChanged: (value) => setState(() => selectedContent = value),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("channels")
                  .orderBy("name")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final channels = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedChannel,
                  decoration: InputDecoration(
                    labelText: "Select Channel",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: GestureDetector(
                onTap: pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.green[100],
                  ),

                  height: 200,
                  width: 340,
                  child: (imageFile == null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image),
                            Text('Add Cover Image'),
                          ],
                        )
                      : Image.file(fit: BoxFit.cover, imageFile!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                backgroundColor: WidgetStatePropertyAll(Colors.black),
              ),
              onPressed: () {},
              child: Text('Publish'),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _contentItem(
    String value,
    String title,
    IconData icon,
  ) {
    return DropdownMenuItem(
      value: value,
      child: Row(children: [Icon(icon), SizedBox(width: 10), Text(title)]),
    );
  }
}
