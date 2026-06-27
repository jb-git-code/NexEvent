import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nexevent/widgets/grid_background.dart';

class UserRegistrations extends ConsumerStatefulWidget {
  const UserRegistrations({super.key, required this.evId});

  final String evId; // This is the registrationId

  @override
  ConsumerState<UserRegistrations> createState() => _UserRegistrationsState();
}

class _UserRegistrationsState extends ConsumerState<UserRegistrations> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Digital Pass',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: GridDotBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(28.0),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('registrations').doc(widget.evId).get(),
                builder: (context, regSnapshot) {
                  if (regSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(strokeWidth: 2.4);
                  }
                  if (!regSnapshot.hasData || !regSnapshot.data!.exists) {
                    return const Text("Registration data not found.");
                  }
                  final regMap = regSnapshot.data!.data() as Map<String, dynamic>;
                  final eventId = regMap["eventId"] ?? '';
                  final isAttended = regMap["attented"] ?? false;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
                    builder: (context, evSnapshot) {
                      if (evSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(strokeWidth: 2.4);
                      }
                      if (!evSnapshot.hasData || !evSnapshot.data!.exists) {
                        return const Text("Event details not found.");
                      }
                      final evMap = evSnapshot.data!.data() as Map<String, dynamic>;
                      final eventName = evMap["name"] ?? 'Untitled Event';
                      final eventVenue = evMap["venue"] ?? 'TBD';

                      return Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 380),
                        padding: const EdgeInsets.all(28.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF), // Soft lavender blue
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.black.withOpacity(0.04), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Node
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111111),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isAttended ? 'ATTENDED' : 'ACTIVE PASS',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(Icons.qr_code_2_rounded, size: 18, color: Color(0xFF111111)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Ticket Main Info
                            Text(
                              eventName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111111),
                                letterSpacing: -0.5,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              eventVenue,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Tear-off dashed divider line
                            Row(
                              children: List.generate(15, (index) {
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    height: 1.5,
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 24),

                            // Frame container for QR
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                              ),
                              child: QrImageView(
                                size: 180,
                                data: widget.evId,
                                version: QrVersions.auto,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Color(0xFF111111),
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Color(0xFF111111),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // User Profile Node
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Text(
                                  currentUser?.name ?? 'User Pass',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
