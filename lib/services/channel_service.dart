import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getChannels() {
    return firestore.collection("channels").orderBy("name").snapshots();
  }

  Future<void> joinChannel({
    required String uid,
    required String channelId,
  }) async {
    final batch = firestore.batch();

    batch.update(firestore.collection("users").doc(uid), {
      "joinedChannels": FieldValue.arrayUnion([channelId]),
    });

    batch.update(firestore.collection("channels").doc(channelId), {
      "memberCount": FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> leaveChannel({
    required String uid,
    required String channelId,
  }) async {
    final batch = firestore.batch();

    batch.update(firestore.collection("users").doc(uid), {
      "joinedChannels": FieldValue.arrayRemove([channelId]),
    });

    batch.update(firestore.collection("channels").doc(channelId), {
      "memberCount": FieldValue.increment(-1),
    });

    await batch.commit();
  }
}
