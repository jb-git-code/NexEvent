import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/auth/login_screen.dart';
import 'package:nexevent/services/auth_service.dart';
import 'package:nexevent/theme/app_theme.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    final currUser = ref.watch(currentUserProvider);
    final userEmail = currUser!.email;

    final initial = currUser.name.isNotEmpty
        ? currUser.name[0].toUpperCase()
        : (userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U');

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Avatar
            Center(
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: text.h1.copyWith(
                      color: colors.onPrimary,
                      fontSize: 34,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Name
            Text(
              currUser.name.isNotEmpty ? currUser.name : userEmail,
              textAlign: TextAlign.center,
              style: text.h2,
            ),
            const SizedBox(height: 24),

            // Detail Information Card
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Column(
                children: [
                  _detailTile(
                    context,
                    icon: LucideIcons.mail,
                    label: 'EMAIL ADDRESS',
                    value: userEmail,
                  ),
                  _tileDivider(context),
                  _detailTile(
                    context,
                    icon: LucideIcons.idCard,
                    label: 'ROLL NUMBER',
                    value: currUser.roll,
                  ),
                  _tileDivider(context),
                  _detailTile(
                    context,
                    icon: LucideIcons.gitBranch,
                    label: 'BRANCH',
                    value: currUser.branch,
                  ),
                  _tileDivider(context),
                  _detailTile(
                    context,
                    icon: LucideIcons.calendar,
                    label: 'BATCH',
                    value: currUser.batch,
                  ),
                  _tileDivider(context),
                  _detailTile(
                    context,
                    icon: LucideIcons.tag,
                    label: 'TAG',
                    value: currUser.tag,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: colors.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
                icon: const Icon(LucideIcons.logOut, size: 18),
                label: Text(
                  'Logout',
                  style: text.bodyMedium.copyWith(color: colors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primaryMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: text.label.copyWith(fontSize: 10)),
              const SizedBox(height: 2),
              Text(
                value,
                style: text.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tileDivider(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Divider(color: colors.divider, height: 1),
    );
  }
}
