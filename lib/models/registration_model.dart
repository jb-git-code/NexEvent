class RegistrationModel {
  final String registrationId;
  final String eventId;
  final String userId;
  final bool attented;

  RegistrationModel({
    required this.registrationId,
    required this.eventId,
    required this.userId,
    required this.attented,
  });

  factory RegistrationModel.fromMap(Map<String, dynamic> map) {
    return RegistrationModel(
      registrationId: map["registrationId"] ?? "",
      eventId: map["eventId"] ?? "",
      userId: map["userId"] ?? "",
      attented: false,
      
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "registrationId": registrationId,
      "eventId": eventId,
      "userId": userId,
      // "registeredAt": DateTime.now(),
      "attended": false,
    };
  }
}
