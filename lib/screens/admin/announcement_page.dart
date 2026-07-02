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
  String? selectedChannel;
  Stream<QuerySnapshot<Map<String, dynamic>>> getChannels() {
    return FirebaseFirestore.instance
        .collection("channels")
        .orderBy("name")
        .snapshots();
  }

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
      channelId: selectedChannel!,
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
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                ),
                onPressed: () async {
                  // if(title.tex == null || content.text ==null){
                  //    ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text("Please select a channel")),
                  //   );
                  //   return;
                  // }
                  if (selectedChannel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a channel")),
                    );
                    return;
                  }
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
