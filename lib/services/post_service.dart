import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nexevent/models/post_model.dart';
import 'package:nexevent/models/user_model.dart';

class PostService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image, String postId) async {
    final ref = storage.ref().child("posts").child("$postId.jpg");

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  Future<void> createPost({
    required  String img,
    required UserModel user,
    required String cap,
  }) async {
    final postId = FirebaseFirestore.instance.collection("posts").doc().id;
  

    final newPost = PostModel(
      postId: postId,
      userId: user.uid,
      userName: user.name,
      caption: cap,
      imageUrl: img,
      createdAt: DateTime.now(),
      likeCount: 0,
      commentCount: 0,
      isDeleted: false,
    );

    await firestore.collection("posts").doc(postId).set(newPost.toMap());
  }
}
