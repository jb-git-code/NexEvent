import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexevent/screens/community/create_post.dart';
import 'package:nexevent/services/storage_services.dart';

class CollegeFeed extends StatefulWidget {
  const CollegeFeed({super.key});

  @override
  State<CollegeFeed> createState() => _CollegeFeedState();
}

class _CollegeFeedState extends State<CollegeFeed> {
 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextButton(
              
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePost()),
                );
              },
              child: Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}
