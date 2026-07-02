import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission();
  }

  Future<void> getToken(String uid) async {
    String? token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "fcmToken": token,
    });
  }

  Future<void> showRegistrationSuccess(String eventName) async {
    await notifications.show(
      id: 1,
      title: "Registration Successful 🎉",
      body: "Registered for $eventName",
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'events_channel',
          'Events',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await notifications.show(
        id: 0,
        title: message.notification?.title,
        body: message.notification?.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'events_channel',
            'Events',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'events_channel',

    'Events',

    description: 'Event Notifications',

    importance: Importance.high,
  );

  Future<void> subscribeToChannel(String channelId) async {
    await FirebaseMessaging.instance.subscribeToTopic(channelId);
  }

  Future<void> unsubscribeFromChannel(String channelId) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(channelId);
  }

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(settings: settings);

    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await requestPermission();

    listenForegroundMessages();
  }
}
