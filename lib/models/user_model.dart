class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String roll;
  final String batch;
  final String branch;
  final String tag;
  // final String profileImg;
  // final String createdAt
  final List joinedChannels;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.roll,
    required this.batch,
    required this.branch,
    required this.tag,
    required this.joinedChannels,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "role": role,
      "roll": roll,
      "batch": batch,
      "branch": branch,
      "tag": tag,
      "joinedChannels": joinedChannels,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"],
      name: map["name"],
      email: map["email"],
      role: map["role"],
      roll: map["roll"],
      batch: map["batch"],
      branch: map["branch"],
      tag: map["tag"],
      joinedChannels:
          (map["joinedChannels"] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? roll,
     String? batch,
      String? branch,
       String? tag,
    List<String>? joinedChannels,
    // baaki fields bhi add kar dena jo UserModel me hain
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      roll: roll ?? this.roll,
      batch: batch ?? this.batch,
      branch: branch ?? this.branch,
      tag: tag ?? this.tag,
      joinedChannels: joinedChannels ?? this.joinedChannels,
      // baaki fields
    );
  }
}
