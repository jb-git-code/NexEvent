import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelModel {
  final String channelId;
  final String name;
  final String description;
  final String icon;
  final String type;
  final bool isMandatory;
  final int memberCount;
  final DateTime createdAt;

  ChannelModel({
    required this.channelId,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.isMandatory,
    required this.memberCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "channelId": channelId,
      "name": name,
      "description": description,
      "icon": icon,
      "type": type,
      "isMandatory": isMandatory,
      "memberCount": memberCount,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    return ChannelModel(
      channelId: map["channelId"] ?? "",
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      icon: map["icon"] ?? "",
      type: map["type"] ?? "",
      isMandatory: map["isMandatory"] ?? false,
      memberCount: map["memberCount"] ?? 0,
      createdAt: (map["createdAt"] as Timestamp).toDate(),
    );
  }
}
