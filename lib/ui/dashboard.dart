import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/food/foods.dart';
import 'package:nexevent/map/campus_map.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/community/community_page.dart';
import 'package:nexevent/screens/home/channel_page.dart';
import 'package:nexevent/screens/home/my_events_page.dart';
import 'package:nexevent/screens/home/profile_page.dart';

class NexEventDashboardPoly extends ConsumerStatefulWidget {
  const NexEventDashboardPoly({super.key});

  @override
  ConsumerState<NexEventDashboardPoly> createState() =>
      _NexEventDashboardPolyState();
}

class _NexEventDashboardPolyState extends ConsumerState<NexEventDashboardPoly> {
  int _sessionTab = 0;

  static const _text = Color(0xFF14151A);
  static const _muted = Color(0xFF8A8D9A);
  static const _card = Color(0xFFF3F4F7);
  static const _primary = Color(0xFF4361EE); // indigo-blue, main accent
  static const _primaryDark = Color(0xFF2F49C9);
  static const _bg = Colors.white;

  final _sessions = const ['Keynote', 'Workshops', 'Cultural', 'Sports'];
  final _sessionColors = const [
    _primary,
    Color(0xFF20C997),
    Color(0xFF9B6BFF),
    Color(0xFFFF9F43),
  ];
  final _sessionContent = const [
    _SessionInfo('Opening Keynote — Main Auditorium', '9:00 AM – 10:00 AM'),
    _SessionInfo('No workshop slot uploaded yet', ''),
    _SessionInfo('No cultural event uploaded yet', ''),
    _SessionInfo('No sports fixture uploaded yet', ''),
  ];

  @override
  Widget build(BuildContext context) {
    final s = _sessionContent[_sessionTab];
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            _topBar(ref),
            const SizedBox(height: 28),
            _scheduleHeader(),
            const SizedBox(height: 16),
            _sessionTabs(),
            const SizedBox(height: 14),
            _scheduleCard(s),
            const SizedBox(height: 28),
            _divider(),
            const SizedBox(height: 24),
            _passBanner(),
            const SizedBox(height: 28),
            _divider(),
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
            const SizedBox(height: 90),
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
                CircleAvatar(radius: 11, backgroundColor: Colors.white38),
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
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: _card),
          child: const Icon(
            Icons.notifications_none_rounded,
            size: 20,
            color: _text,
          ),
        ),
      ],
    );
  }

  Widget _scheduleHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Today's Schedule",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tue, Day 1',
                style: TextStyle(fontWeight: FontWeight.w600, color: _text),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _text),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sessionTabs() {
    final selectedColor = _sessionColors[_sessionTab];
    return PopupMenuButton<int>(
      onSelected: (i) => setState(() => _sessionTab = i),
      offset: const Offset(0, 8),
      elevation: 6,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      constraints: const BoxConstraints(minWidth: 260),
      itemBuilder: (context) => List.generate(_sessions.length, (i) {
        final selected = i == _sessionTab;
        final color = _sessionColors[i];
        return PopupMenuItem<int>(
          value: i,
          height: 46,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(
                _sessions[i],
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                  color: selected ? color : _text,
                ),
              ),
              if (selected) ...[
                const Spacer(),
                Icon(Icons.check_rounded, size: 16, color: color),
              ],
            ],
          ),
        );
      }),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: selectedColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selectedColor, width: 1.4),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: selectedColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _sessions[_sessionTab],
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: selectedColor,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: selectedColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleCard(_SessionInfo s) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primary, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  s.title,
                  style: const TextStyle(fontSize: 16, color: _text),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primary, _primaryDark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    s.time.isEmpty ? '—' : s.time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: const Icon(
                    Icons.wifi_tethering_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primary, Color(0xFF7B61FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'My Pass',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Entry • Workshops & more',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_rounded,
                color: _primary,
                size: 32,
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
        'Marketplace',
        'Buy & sell',
        Icons.storefront_rounded,
        Color(0xFFFF9F43),
        true,
        (context) => FoodsScreen(),
      ),
      _ServiceItem(
        'Campus Map',
        'Navigate venues',
        Icons.map_rounded,
        Color(0xFF20C997),
        false,
        (context) => CampusMapPage(),
      ),
      _ServiceItem(
        'Announcements',
        'Updates',
        Icons.campaign_rounded,
        Color(0xFFEE6C9C),
        false,
        (context) => AllAnnouncements(),
      ),
      _ServiceItem(
        'Clubs',
        'Communities',
        Icons.hub_rounded,
        Color(0xFF9B6BFF),
        false,
        (context) => ChannelsPage(),
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

class _SessionInfo {
  final String title;
  final String time;
  const _SessionInfo(this.title, this.time);
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
