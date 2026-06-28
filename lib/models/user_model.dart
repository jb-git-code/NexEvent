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

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.roll,
    required this.batch,
    required this.branch,
    required this.tag,
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
      "tag":tag,
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
    );
  }
}
