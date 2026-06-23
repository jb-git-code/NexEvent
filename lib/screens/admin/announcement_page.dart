import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/models/announcement_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:uuid/uuid.dart';

class AnnouncementPage extends ConsumerStatefulWidget {
  const AnnouncementPage({super.key});

  @override
  ConsumerState<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends ConsumerState<AnnouncementPage> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();

  Future<void> createAnnouncement() async {
    final user = ref.read(currentUserProvider);
    final id = Uuid().v4();
    AnnouncementModel ann = AnnouncementModel(
      id: id,
      title: title.text,
      content: content.text,
      author: (user == null) ? 'admin' : user.name,
      createdAt: DateTime.now(),
      isPinned: false,
    );

    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(id)
          .set(ann.toMap());
      final sb = SnackBar(content: Text('Announcement Created'));
      ScaffoldMessenger.of(context).showSnackBar(sb);
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Announcement'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: content,
                decoration: InputDecoration(
                  hintText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                ),
                onPressed: () async {
                  await createAnnouncement();
                },
                child: Text(
                  'Create Announcement',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
