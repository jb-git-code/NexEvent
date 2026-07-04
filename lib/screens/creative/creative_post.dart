import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexevent/services/storage_services.dart';
import 'package:nexevent/widgets/content_type_card.dart';

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
  String selectedType = "null";

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

  PlatformFile? selectedDocument;
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

  List<XFile> images = [];

  final mpicker = ImagePicker();

  Future<void> pickImages() async {
    final result = await mpicker.pickMultiImage();

    if (result.isNotEmpty) {
      setState(() {
        images = result;
      });
    }
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
            // //description box
            // TextField(
            //   controller: description,
            //   decoration: InputDecoration(
            //     hintText: 'Description',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            // const SizedBox(height: 20),

            // content type drop down
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                    width: 250,
                    child: ContentTypeCard(
                      icon: Icons.photo_library,
                      title: "Image Gallery",
                      subtitle: "Share multiple photos",
                      isSelected: selectedType == "imageGallery",
                      onTap: () {
                        setState(() {
                          selectedType = "imageGallery";
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 15),

                  SizedBox(
                    width: 250,
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

                  const SizedBox(width: 15),

                  SizedBox(
                    width: 250,
                    child: ContentTypeCard(
                      icon: Icons.edit_note,
                      title: "Writing",
                      subtitle: "Poems, stories & creative writing",
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
            const SizedBox(height: 20),
            (selectedType == 'writing')
                ?
                  //description box
                  Column(
                    children: [
                      TextField(
                        controller: description,
                        decoration: InputDecoration(
                          hintText: 'Write your Content',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //cover image picker
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[300],
                            ),

                            height: 200,
                            width: 340,
                            child: (imageFile == null)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image),
                                      Text('Cover Image (Optional)'),
                                    ],
                                  )
                                : Image.file(fit: BoxFit.cover, imageFile!),
                          ),
                        ),
                      ),
                    ],
                  )
                : (selectedType == 'article')
                ? Column(
                    children: [
                      TextField(
                        controller: description,
                        decoration: InputDecoration(
                          hintText: 'Article Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //cover image picker
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[300],
                            ),

                            height: 150,
                            width: 340,
                            child: (imageFile == null)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image),
                                      Text('Cover Image'),
                                    ],
                                  )
                                : Image.file(fit: BoxFit.cover, imageFile!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: pickDocument,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(
                          selectedDocument == null
                              ? "Select PDF"
                              : selectedDocument!.name,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      TextField(
                        controller: description,
                        decoration: InputDecoration(
                          hintText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //cover image picker
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[300],
                            ),

                            height: 100,
                            width: 340,
                            child: (imageFile == null)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image),
                                      Text('Cover Image'),
                                    ],
                                  )
                                : Image.file(fit: BoxFit.cover, imageFile!),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Select Images"),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
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
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
}
