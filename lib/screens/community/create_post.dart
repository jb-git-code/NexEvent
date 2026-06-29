import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/services/post_service.dart';
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
  bool isLoading = false;
  Future<void> pickImage(String pid) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
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

    setState(() async {
      img = await PostService().uploadImage(selectedImage!, pid);
    });
  }

  final pid = Uuid().v4();
  final TextEditingController captionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Create New Post'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                await pickImage(pid);
              },
              child: Container(height: 200, width: 250, color: Colors.lime),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: captionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Caption',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                PostService().createPost(
                  img: img!,
                  user: currentUser!,
                  cap: captionController.text,
                );
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
