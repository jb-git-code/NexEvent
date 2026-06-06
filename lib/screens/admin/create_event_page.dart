import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  File? imageFile;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imageFile = File(image.path);
      });
    }

    imageFile == null
        ? const Text("No Image Selected")
        : Image.file(imageFile!, height: 150);
  }

  Future<void> createEvent() async {
    try {
      final uid = Uuid().v4();
      String imageUrl = await StorageService().uploadPoster(imageFile!, uid);
      await FirebaseFirestore.instance.collection('events').doc(uid).set({
        "eventId": uid,
        "name": _controller1.text.trim(),
        "description": _controller2.text.trim(),
        "venue": _controller3.text.trim(),
        "category": _controller4.text.trim(),
        "imageUrl":imageUrl,
      });
      final snackbar = SnackBar(content: Text('Event Created'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Container(
          // color: Colors.pink[300],
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  controller: _controller1,
                  decoration: InputDecoration(
                    hintText: 'name',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _controller2,
                  decoration: InputDecoration(
                    hintText: 'description',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _controller3,
                  decoration: InputDecoration(
                    hintText: 'venue',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _controller4,
                  decoration: InputDecoration(
                    hintText: 'category',
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.grey),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: pickImage,
                  child: const Text("Choose Poster"),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.black),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: () async {
                    await createEvent();
                    Navigator.pop(context);
                  },
                  child: Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
