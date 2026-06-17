import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/keys.dart';
import 'package:nexevent/screens/home/event_detail_page.dart';

class DeepLinkService {
  Map<String, dynamic>? map;

  final AppLinks appLinks = AppLinks();

  void init() {
    appLinks.uriLinkStream.listen((Uri uri) async {
      if (uri.host == "event") {
        String eventId = uri.pathSegments.first;

        final doc = await FirebaseFirestore.instance
            .collection("events")
            .doc(eventId)
            .get();

        if (!doc.exists) return;

        final event = doc.data()!;

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => EventDetailPage(
              name: event["name"] ?? "",
              eventId: eventId,
              venue: event["venue"] ?? "",
              description: event["description"] ?? "",
              imageUrl: event["imageUrl"] ?? "",
              did: eventId,
            ),
          ),
        );
      }
    });
  }
}
