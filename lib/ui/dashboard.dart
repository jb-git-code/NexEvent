import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexevent/lost&found/lost_found_page.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/quick_links/quick_links.dart';
import 'package:nexevent/screens/admin/announcement_page.dart';
import 'package:nexevent/screens/admin/create_event_page.dart';
import 'package:nexevent/screens/auth/scanner_page.dart';
import 'package:nexevent/screens/community/community_page.dart';
import 'package:nexevent/screens/creative/creative_page.dart';
import 'package:nexevent/screens/home/my_events_page.dart';
import 'package:nexevent/screens/home/profile_page.dart';
import 'package:nexevent/ui/app_colors.dart';
import 'package:nexevent/ui/mess_menu_card.dart';

class NexEventDashboardPoly extends ConsumerStatefulWidget {
  const NexEventDashboardPoly({super.key});

  @override
  ConsumerState<NexEventDashboardPoly> createState() =>
      _NexEventDashboardPolyState();
}

class _NexEventDashboardPolyState extends ConsumerState<NexEventDashboardPoly> {
  static const _text = Color(0xFF14151A);
  static const _muted = Color(0xFF8A8D9A);
  static const _primary = Color(0xFF4361EE); // indigo-blue, main accent
  static const _bg = Colors.white;

  @override
  Widget build(BuildContext context) {
    final cu = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            _topBar(ref),
            const SizedBox(height: 28),

            MessMenuCard(),
            const SizedBox(height: 14),
            _divider(),
            const SizedBox(height: 24),
            _passBanner(),
            // WaveRingsPassCard(),
            const SizedBox(height: 28),
            _divider(),
            const SizedBox(height: 24),
            (cu == null)
                ? Center(child: CircularProgressIndicator())
                : (cu.role == 'admin')
                ? _adminDashboard()
                : const SizedBox(),
            const SizedBox(height: 24),
            const Text(
              'Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 16),
            _servicesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _topBar(WidgetRef ref) {
    final cu = ref.watch(currentUserProvider);
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.white38,
                  child: Icon(size: 14, Icons.arrow_back),
                ),
                SizedBox(width: 8),
                Text(
                  cu?.name ?? "Guest",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),

        // yaha app logo aayega
        const Spacer(),

        // yaha app logo aayega
      ],
    );
  }

  Widget _passBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyEventsPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          // gradient: const LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   // colors: [AppColors.primary, AppColors.primaryDark],
          // ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // pattern layer — sits behind content
              Positioned.fill(
                child: Opacity(
                  opacity: 1,

                  child: SvgPicture.asset(
                    "assets/bg/blob-scene-haikei.svg",

                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // actual card content on top
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Pass',
                          style: GoogleFonts.storyScript(
                            fontSize: 24,

                            fontWeight: FontWeight.bold,

                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Entry • Workshops & more',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        LucideIcons.qrCode,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminDashboard() {
    return Column(
      children: [
        Text('Admin Dashboard', style: TextStyle(fontSize: 22)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScannerPage()),
                  );
                },
                child: Padding(
                  padding: EdgeInsetsGeometry.all(10.0),
                  child: _adminCard('Sacnner', Icons.scanner),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateEventPage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _adminCard('Event', Icons.post_add),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnnouncementPage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _adminCard('Announce', Icons.announcement),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _adminCard(String title, IconData icon) {
    return Container(
      width: 140,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF312E81)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(width: 8),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 17),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _servicesGrid() {
    final items = [
      _ServiceItem(
        'Lost & Found',
        'Look for things',
        Icons.data_object,
        Color.fromARGB(255, 232, 47, 6),
        true,
        (context) => LostFoundPage(),
      ),

      _ServiceItem(
        'Quick Links',
        'Navigate easily',
        Icons.link_sharp,
        Color(0xFF20C997),
        false,
        (context) => QuickLinksPage(),
      ),
      _ServiceItem(
        'Announcements',
        'Updates',
        Icons.campaign_rounded,
        Color.fromARGB(255, 248, 7, 96),
        false,
        (context) => AllAnnouncements(),
      ),

      _ServiceItem(
        'Creative Corner',
        'Create something',
        Icons.create,
        Color.fromARGB(255, 33, 212, 232),
        false,
        (context) => CreativeCornerPage(),
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.9,
      children: items.map((it) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: it.builder));
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: it.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      it.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      it.subtitle,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                    if (it.badge) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: it.color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'New!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(it.icon, size: 26, color: it.color),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _divider() =>
      const Divider(color: Color(0xFFEDEEF2), thickness: 1.2, height: 1);
}

class _ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool badge;
  final WidgetBuilder builder;
  const _ServiceItem(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.badge,
    this.builder,
  );
}

class PassPatternPainter extends CustomPainter {
  const PassPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Semi circles
    for (double x = -20; x < size.width + 40; x += 70) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(x, 15), radius: 18),
        0,
        3.14,
        false,
        paint,
      );
    }

    // Vertical Capsules
    for (double x = 20; x < size.width; x += 80) {
      final path = Path();

      path.moveTo(x, 35);
      path.quadraticBezierTo(x + 10, 45, x, 55);
      path.quadraticBezierTo(x - 10, 65, x, 75);

      canvas.drawPath(path, paint);
    }

    // Random Curves
    for (double x = -40; x < size.width + 50; x += 60) {
      final path = Path();

      path.moveTo(x, size.height);

      path.cubicTo(
        x + 20,
        size.height - 20,
        x + 35,
        size.height - 45,
        x + 15,
        size.height - 65,
      );

      canvas.drawPath(path, paint);
    }

    // Little circles
    final fill = Paint()..color = Colors.white.withOpacity(.04);

    for (double x = 35; x < size.width; x += 85) {
      canvas.drawCircle(Offset(x, size.height * .55), 7, fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
