import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/models/event_model.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/services/storage_services.dart';
import 'package:uuid/uuid.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();
  // bool isUploading = false;

  final uid = const Uuid().v4();

  File? imageFile;
  final ImagePicker picker = ImagePicker();

  String img = "";

  Future<void> pickImage() async {
    // setState(() {
    //   isUploading = true;
    // });
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
    String imageUrl = await StorageService().uploadPoster(imageFile!, uid);
    setState(() {
      img = imageUrl;
    });
  }

  Future<void> createEvent() async {
    try {
      await FirestoreService().createEvent(
        EventModel(
          eventId: uid,
          name: _controller1.text.trim(),
          description: _controller2.text.trim(),
          venue: _controller3.text.trim(),
          category: _controller4.text.trim(),
          imageUrl: img,
        ),
      );
      if (context.mounted) {
        const snackbar = SnackBar(content: Text('Event Created'));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } catch (e) {
      if (context.mounted) {
        final snackbar = SnackBar(content: Text(e.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Event'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Styled Image Picker Box
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                  ),
                  child: imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(imageFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 44,
                              color: primaryColor,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Upload Event Poster',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to browse gallery',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Event Name Input
              TextField(
                controller: _controller1,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Enter event name',
                  labelText: 'Event Name',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Event Description Input
              TextField(
                controller: _controller2,
                textInputAction: TextInputAction.next,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter event details and info',
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Venue Input
              TextField(
                controller: _controller3,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Enter event location',
                  labelText: 'Venue',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Category Input
              TextField(
                controller: _controller4,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'e.g. Music, Tech, Sports',
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shadowColor: primaryColor.withValues(alpha: 0.3),
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  await createEvent();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Create Event',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
