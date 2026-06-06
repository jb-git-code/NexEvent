class RegistrationModel {
  final String registrationId;
  final String eventId;
  final String userId;

  RegistrationModel({
    required this.registrationId,
    required this.eventId,
    required this.userId,
  });

  factory RegistrationModel.fromMap(
    Map<String,dynamic> map,
  ){
    return RegistrationModel(
      registrationId:
          map["registrationId"] ?? "",
      eventId:
          map["eventId"] ?? "",
      userId:
          map["userId"] ?? "",
    );
  }

  Map<String,dynamic> toMap(){
    return {
      "registrationId":
          registrationId,
      "eventId":
          eventId,
      "userId":
          userId,
      "registeredAt":
          DateTime.now(),
    };
  }
}