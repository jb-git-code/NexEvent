import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    required String roll,
    required String batch,
    required String branch,
    required String tag,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestore.collection("users").doc(credential.user!.uid).set({
      "uid": credential.user!.uid,

      "name": name,

      "email": email,

      "role": role,

      "roll": roll,
      "batch": batch,
      "branch": branch,
      "tag": tag,
      "joinedChannels": ["general"],
    });
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
