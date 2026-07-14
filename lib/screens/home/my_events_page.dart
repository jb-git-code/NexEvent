import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexevent/models/registration_model.dart';
import 'package:nexevent/providers/registration_provider.dart';
import 'package:nexevent/screens/home/user_registrations.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/theme/app_theme.dart';

class MyEventsPage extends ConsumerStatefulWidget {
  const MyEventsPage({super.key});

  @override
  ConsumerState<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends ConsumerState<MyEventsPage> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: StreamBuilder(
          stream: FirestoreService().getUserRegistrations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: colors.primary,
                ),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: colors.primary,
                ),
              );
            }
            final docs = snapshot.data!.docs;

            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              physics: const BouncingScrollPhysics(),
              children: [
                Text('Your Active Passes', style: text.h3),
                const SizedBox(height: 16),

                if (docs.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border, width: 1),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.ticket,
                          size: 36,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No registered tickets yet.',
                          style: text.bodySecondary.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(docs.length, (index) {
                    final regData = docs[index].data() as Map<String, dynamic>;
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
                        final eventName = eventData["name"] ?? 'Untitled Event';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(currentRegProvider.notifier)
                                  .setUser(RegistrationModel.fromMap(regData));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserRegistrations(evId: regId),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors.primaryMuted,
                                    ),
                                    child: Icon(
                                      LucideIcons.ticket,
                                      size: 18,
                                      color: colors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eventName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: text.h3,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Tap to reveal pass',
                                          style: text.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: colors.surfaceAlt,
                                      foregroundColor: colors.error,
                                      shape: const CircleBorder(),
                                    ),
                                    onPressed: () =>
                                        _confirmCancel(context, regId),
                                    icon: const Icon(LucideIcons.x, size: 16),
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
    );
  }

  void _confirmCancel(BuildContext context, String regId) {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('Cancel Ticket?', style: text.h3),
        content: Text(
          'Are you sure you want to cancel your registration?',
          style: text.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: text.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await FirestoreService().cancelRegistration(regId);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              'Cancel Ticket',
              style: text.bodyMedium.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryMuted,
              ),
              child: Icon(icon, color: colors.primary, size: 18),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: text.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
