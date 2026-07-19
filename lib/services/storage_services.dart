import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadPfp(File image, String id) async {
    final ref = storage.ref().child("profile_pics/$id.jpg");

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  Future<String> uploadPoster(File image, String eventId) async {
    final ref = storage.ref().child("event_posters/$eventId.jpg");

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  Future<String> uploadCreativePoster(File image, String eventId) async {
    final ref = storage.ref().child("creative_event_posters/$eventId.jpg");

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  Future<void> deletePoster(String id) async {
    final ref = storage.ref().child("event_posters/$id.jpg");

    await ref.delete();
  }

  Future<void> deleteCreativePoster(String id) async {
    final ref = storage.ref().child("creative_event_posters/$id.jpg");

    await ref.delete();
  }

  Future<String> uploadGalleryImage(
    File file,
    String postId,
    String imageId,
  ) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child("creative_posts")
        .child(postId)
        .child("gallery")
        .child("$imageId.jpg");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  Future<String> uploadArticle(File file, String postId) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child("creative_posts")
        .child(postId)
        .child("article.pdf");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}
