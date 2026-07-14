import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/auth/login_screen.dart';
import 'package:nexevent/services/auth_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final currUser = ref.watch(currentUserProvider);
    final userEmail = currUser!.email;

    final initial = currUser.name.isNotEmpty
        ? currUser.name[0].toUpperCase()
        : (userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U');

    return Scaffold(
      appBar: AppBar(title: Text('Profile'), centerTitle: true),
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar with primary-secondary gradient
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name
            Text(
              currUser.name.isNotEmpty ? currUser.name : userEmail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),

            // // Branch + Batch pills
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     _pillChip(
            //       icon: Icons.school_outlined,
            //       text: currUser.branch,
            //       color: secondaryColor,
            //     ),
            //     const SizedBox(width: 8),
            //     _pillChip(
            //       icon: Icons.groups_outlined,
            //       text: currUser.batch,
            //       color: primaryColor,
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 32),

            // Detail Information Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Email Tile
                    _detailTile(
                      icon: Icons.email_outlined,
                      iconColor: primaryColor,
                      label: 'EMAIL ADDRESS',
                      value: userEmail,
                    ),
                    _tileDivider(),

                    // Roll Number Tile
                    _detailTile(
                      icon: Icons.badge_outlined,
                      iconColor: Colors.indigo,
                      label: 'ROLL NUMBER',
                      value: currUser.roll,
                    ),
                    _tileDivider(),

                    // Branch Tile
                    _detailTile(
                      icon: Icons.account_tree_outlined,
                      iconColor: Colors.orange,
                      label: 'BRANCH',
                      value: currUser.branch,
                    ),
                    _tileDivider(),

                    // Batch Tile
                    _detailTile(
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.teal,
                      label: 'BATCH',
                      value: currUser.batch,
                    ),
                    _tileDivider(),

                    // Tag Tile
                    _detailTile(
                      icon: Icons.sell_outlined,
                      iconColor: secondaryColor,
                      label: 'TAG',
                      value: currUser.tag,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  final authService = AuthService();
                  await authService.logout();
                  await FirebaseAuth.instance.signOut();
                  ref.read(currentUserProvider.notifier).clearUser();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const loginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[400],
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tileDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: Color(0xFFF3F4F6), height: 1),
    );
  }
}
