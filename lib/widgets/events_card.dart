import 'package:flutter/material.dart';

class EventsCard extends StatelessWidget {
  const EventsCard({
    super.key,
    required this.name,
    required this.eveId,
    required this.venue,
  });

  final String name;

  final String eveId;

  final String venue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Name: $name', style: TextStyle(fontSize: 12)),
          Text('event ID: $eveId', style: TextStyle(fontSize: 12)),
          Text('Venue: $venue', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
