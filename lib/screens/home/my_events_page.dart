import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/models/registration_model.dart';
import 'package:nexevent/providers/registration_provider.dart';
import 'package:nexevent/screens/home/channel_page.dart';
import 'package:nexevent/screens/home/user_registrations.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/widgets/grid_background.dart';

class MyEventsPage extends ConsumerStatefulWidget {
  const MyEventsPage({super.key});

  @override
  ConsumerState<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends ConsumerState<MyEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: GridDotBackground(
        child: SafeArea(
          child: StreamBuilder(
            stream: FirestoreService().getUserRegistrations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                );
              }
              final docs = snapshot.data!.docs;

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 4. Recommended Section
                  const Text(
                    'Recommended for you',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111111),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildRecommendationCard(
                          icon: Icons.create,
                          title: 'Create',
                          color: const Color(0xFFFFF1F2),
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRecommendationCard(
                          icon: Icons.wifi_channel,
                          title: 'Channels',
                          color: const Color(0xFFECFDF5),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChannelsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 5. Registered Tickets Section Header
                  const Text(
                    'Your Active Passes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111111),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (docs.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFEFF1F4),
                          width: 1.5,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 44,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No registered tickets yet.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...List.generate(docs.length, (index) {
                      final regData =
                          docs[index].data() as Map<String, dynamic>;
                      final eventId = regData["eventId"];
                      final regId = regData["registrationId"] ?? '';

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('events')
                            .doc(eventId)
                            .get(),
                        builder: (context, evSnapshot) {
                          if (!evSnapshot.hasData || !evSnapshot.data!.exists) {
                            return const SizedBox();
                          }
                          final eventData =
                              evSnapshot.data!.data() as Map<String, dynamic>;
                          final eventName =
                              eventData["name"] ?? 'Untitled Event';

                          // Cycle pastel backings
                          final List<Color> ticketBgColors = [
                            const Color(0xFFEEF2FF),
                            const Color(0xFFECFDF5),
                            const Color(0xFFFFF1F2),
                          ];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                ref
                                    .read(currentRegProvider.notifier)
                                    .setUser(
                                      RegistrationModel.fromMap(regData),
                                    );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserRegistrations(
                                      evId: regId,
                                      // map: regData,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color:
                                      ticketBgColors[index %
                                          ticketBgColors.length],
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.04),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            eventName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF111111),
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'tap to reveal pass',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(
                                          0xFFEF4444,
                                        ),
                                        shape: const CircleBorder(),
                                        side: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                          width: 1.5,
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text("Cancel Ticket?"),
                                            content: const Text(
                                              "Are you sure you want to cancel your registration?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("No"),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xFFEF4444,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  await FirestoreService()
                                                      .cancelRegistration(
                                                        regId,
                                                      );
                                                  if (context.mounted)
                                                    Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "Cancel Ticket",
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEFF1F4), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(icon, color: const Color(0xFF111111), size: 20),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
