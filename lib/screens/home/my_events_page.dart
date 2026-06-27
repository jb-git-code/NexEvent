import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/screens/community/community_page.dart';
import 'package:nexevent/screens/home/saved_events.dart';
import 'package:nexevent/screens/home/user_registrations.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/widgets/grid_background.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
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
                  // // 2. Statistics Title & Year Selector Pill
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text(
                  //       'Statistics',
                  //       style: TextStyle(
                  //         fontSize: 26,
                  //         fontWeight: FontWeight.w900,
                  //         color: Color(0xFF111111),
                  //         letterSpacing: -0.6,
                  //       ),
                  //     ),
                  //     Container(
                  //       padding: const EdgeInsets.symmetric(
                  //         horizontal: 12,
                  //         vertical: 6,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(16),
                  //         border: Border.all(
                  //           color: const Color(0xFFE2E8F0),
                  //           width: 1.5,
                  //         ),
                  //         color: Colors.white,
                  //       ),
                  //       child: const Row(
                  //         children: [
                  //           Text(
                  //             '2026',
                  //             style: TextStyle(
                  //               fontSize: 13,
                  //               fontWeight: FontWeight.w800,
                  //               color: Color(0xFF111111),
                  //             ),
                  //           ),
                  //           SizedBox(width: 4),
                  //           Icon(
                  //             Icons.keyboard_arrow_down_rounded,
                  //             size: 16,
                  //             color: Color(0xFF111111),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 20),

                  // 3. Static Decorative Chart Aesthetic Cards
                  // Container(
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(28),
                  //     border: Border.all(
                  //       color: const Color(0xFFEFF1F4),
                  //       width: 1.5,
                  //     ),
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       // Stacked layout replicating columns from the image
                  //       SizedBox(
                  //         height: 220,
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //           crossAxisAlignment: CrossAxisAlignment.end,
                  //           children: [
                  //             _buildChartColumn('27 Jun', [
                  //               _buildChartPill(50, const Color(0xFFB3C5D7)),
                  //               _buildChartPill(70, const Color(0xFFFFF1F2)),
                  //               _buildChartPillOutline(40),
                  //             ]),
                  //             _buildChartColumn('28 Jun', [
                  //               _buildChartPill(40, const Color(0xFFB3C5D7)),
                  //               _buildChartPill(50, const Color(0xFFFFF1F2)),
                  //               _buildChartPillOutline(60),
                  //             ]),
                  //             _buildChartColumn('29 Jun', [
                  //               _buildChartPill(
                  //                 60,
                  //                 const Color(0xFFB3C5D7),
                  //                 badgeText: '37%',
                  //               ),
                  //               _buildChartPill(
                  //                 40,
                  //                 const Color(0xFFFFF1F2),
                  //                 badgeText: '87%',
                  //               ),
                  //               _buildChartPillOutline(50),
                  //             ]),
                  //             _buildChartColumn('30 Jun', [
                  //               _buildChartPill(50, const Color(0xFFB3C5D7)),
                  //               _buildChartPill(60, const Color(0xFFFFF1F2)),
                  //               _buildChartPillOutline(40),
                  //             ]),
                  //           ],
                  //         ),
                  //       ),
                  //       const SizedBox(height: 20),

                  //       // Legend dots
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           _buildLegendItem(
                  //             const Color(0xFFB3C5D7),
                  //             'Registered',
                  //           ),
                  //           const SizedBox(width: 24),
                  //           _buildLegendItem(
                  //             const Color(0xFFFFF1F2),
                  //             'Attended',
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 28),

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
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Community',
                          color: const Color(0xFFFFF1F2),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllAnnouncements(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRecommendationCard(
                          icon: Icons.school_outlined,
                          title: 'Saved',
                          color: const Color(0xFFECFDF5),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SavedEvents(),
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
                          final eventVenue = eventData["venue"] ?? 'TBD';

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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserRegistrations(evId: regId),
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
                                            eventVenue,
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

  Widget _buildChartColumn(String label, List<Widget> segments) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: segments,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildChartPill(double height, Color color, {String? badgeText}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      width: 44,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: badgeText != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildChartPillOutline(double height) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      width: 44,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
      ],
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
