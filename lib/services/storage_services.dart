import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadPoster(File image, String eventId) async {
    final ref = storage.ref().child("event_posters/$eventId.jpg");

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  Future<void> deletePoster(String id) async {
    final ref = storage.ref().child("event_posters/$id.jpg");

    await ref.delete();
  }
}
