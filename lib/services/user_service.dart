import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {

  Future<String> getRole(
      String uid) async {

    final doc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .get();

    return doc["role"];
  }
}