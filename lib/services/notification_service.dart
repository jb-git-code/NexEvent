import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission();
  }

  Future<void> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();

    print(token);
  }

  Future<void> init() async {
    await requestPermission();

    await getToken();
  }

  
}
