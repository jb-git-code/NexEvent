import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexevent/models/registration_model.dart';
import 'package:nexevent/providers/registration_provider.dart';
import 'package:nexevent/screens/home/user_registrations.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/ui/app_colors.dart';

/// Small local text-style set so this screen doesn't depend on a
/// separate typography file. Feel free to move these into AppColors'
/// sibling file (e.g. app_text_styles.dart) later if more screens need them.
class _Text {
  _Text._();

  static const h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.2,
  );

  static const h3 = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.3,
  );

  static const bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.35,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static const caption = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );
}

/// Not part of the shared palette yet — add this to AppColors if other
/// screens need a destructive/error color too.
const _kError = Color(0xFFE5484D);

class MyEventsPage extends ConsumerStatefulWidget {
  const MyEventsPage({super.key});

  @override
  ConsumerState<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends ConsumerState<MyEventsPage> {
  /// Picks the category accent color for a ticket. Falls back to primary
  /// so every card still looks intentional even without a category tag.
  Color _categoryColor(String? category) {
    if (category == null) return AppColors.primary;
    return AppColors.categoryColors[category] ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Passes')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder(
          stream: FirestoreService().getUserRegistrations(),
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final docs = snapshot.data?.docs ?? [];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // SliverToBoxAdapter(child: _buildHeader(docs.length)),
                if (isLoading || !snapshot.hasData)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (docs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final regData =
                            docs[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: _TicketFuture(
                            regData: regData,
                            categoryColor: _categoryColor,
                            onCancel: _confirmCancel,
                          ),
                        );
                      }, childCount: docs.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryTint,
              ),
              child: const Icon(
                LucideIcons.ticketX,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No registered tickets yet',
              textAlign: TextAlign.center,
              style: _Text.h3,
            ),
            const SizedBox(height: 8),
            const Text(
              'Once you register for an event, your pass will\nshow up here, ready to scan at the gate.',
              textAlign: TextAlign.center,
              style: _Text.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ── Cancel confirmation ─────────────────────────────────
  static void _confirmCancel(
    BuildContext context,
    String regId,
    String eventId,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kError.withOpacity(0.12),
                ),
                child: const Icon(
                  LucideIcons.triangleAlert,
                  color: _kError,
                  size: 22,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Cancel Ticket?', style: _Text.h3),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to cancel your registration? This can\'t be undone.',
                style: _Text.bodySecondary,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Keep it',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kError,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await FirestoreService().cancelRegistration(
                          regId,
                          eventId,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel Ticket',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ticket card for a user's registrations list.
/// Redesigned to actually read as a "ticket" — accent rail, a torn/dashed
/// divider with punch-hole notches, and a distinct QR stub on the right
/// instead of a plain icon-button-in-a-row layout.
class _TicketFuture extends ConsumerWidget {
  const _TicketFuture({
    required this.regData,
    required this.categoryColor,
    required this.onCancel,
  });

  final Map<String, dynamic> regData;
  final Color Function(String?) categoryColor;
  final void Function(BuildContext, String, String) onCancel;

  // Matches the off-white scaffold background this card sits on —
  // used to fake the punched-hole notches in the tear-line.
  static const _pageBg = Color(0xFFF8FAFC);
  static const _stubWidth = 68.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        final eventData = evSnapshot.data!.data() as Map<String, dynamic>;
        final eventName = eventData["name"] ?? 'Untitled Event';
        final category = eventData["category"] as String?;
        final venue = eventData["venue"] as String?;
        final accent = categoryColor(category);

        return Padding(
          padding: const EdgeInsets.only(top: 8, right: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(currentRegProvider.notifier)
                      .setUser(RegistrationModel.fromMap(regData));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserRegistrations(evId: regId),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.text.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Main info
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accent.withOpacity(0.14),
                                  ),
                                  child: Icon(
                                    LucideIcons.ticket,
                                    size: 19,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (category != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accent.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            category,
                                            style: _Text.caption.copyWith(
                                              color: accent,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                      Text(
                                        eventName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: _Text.h3,
                                      ),
                                      if (venue != null) ...[
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.mapPin,
                                              size: 12,
                                              color: AppColors.muted,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                venue,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: _Text.caption,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tear-line
                        SizedBox(
                          width: 1,
                          child: CustomPaint(
                            size: const Size(1, double.infinity),
                            painter: _DashedLinePainter(
                              color: AppColors.border,
                            ),
                          ),
                        ),

                        // QR stub
                        Stack(
                          children: [
                            Positioned.fill(
                              child: Opacity(
                                opacity: 1,

                                child: SvgPicture.asset(
                                  "assets/bg/blob-scene-haikei.svg",

                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: _stubWidth,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.qrCode,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'View\npass',
                                    textAlign: TextAlign.center,
                                    style: _Text.caption.copyWith(
                                      fontSize: 10,
                                      height: 1.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Punch-hole notches on the tear-line
              Positioned(top: -7, right: _stubWidth - 7, child: _notch()),
              Positioned(bottom: -7, right: _stubWidth - 7, child: _notch()),

              // Cancel button — floats at the top-right corner
              Positioned(
                top: -8,
                right: -6,
                child: GestureDetector(
                  onTap: () => onCancel(context, regId, eventId),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.x, size: 13, color: _kError),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _notch() {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(color: _pageBg, shape: BoxShape.circle),
    );
  }
}

/// Simple vertical dashed line for the ticket tear-line.
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4;
    const dashHeight = 5.0;
    const dashSpace = 4.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
