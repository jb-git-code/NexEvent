import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NexEventExplorePoly extends StatelessWidget {
  const NexEventExplorePoly({super.key});

  static const _text = Color(0xFF14151A);
  static const _muted = Color(0xFF8A8D9A);
  static const _card = Color(0xFFF3F4F7);
  static const _primary = Color(0xFF4361EE);

  static const _categories = [
    _Category('Workshops', Icons.build_rounded, Color(0xFF4361EE)),
    _Category('Cultural', Icons.theater_comedy_rounded, Color(0xFF9B6BFF)),
    _Category('Tech', Icons.memory_rounded, Color(0xFF20C997)),
    _Category('Sports', Icons.sports_soccer_rounded, Color(0xFFFF9F43)),
    _Category('Market', Icons.storefront_rounded, Color(0xFFEE6C9C)),
  ];

  static const _trending = [
    _Trending('Hackathon 24hr', 'Tech Club', Color(0xFF20C997)),
    _Trending('Cultural Night', 'Unnati Society', Color(0xFF9B6BFF)),
    _Trending('Football Finals', 'Sports Committee', Color(0xFFFF9F43)),
  ];

  static const _clubs = [
    _Club(
      'Photography Club',
      '1.2k members',
      Icons.camera_alt_rounded,
      Color(0xFFEE6C9C),
    ),
    _Club(
      'Robotics Society',
      '860 members',
      Icons.smart_toy_rounded,
      Color(0xFF20C997),
    ),
    _Club(
      'Debate Circle',
      '540 members',
      Icons.record_voice_over_rounded,
      Color(0xFF4361EE),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            Text(
              'Explore',
              style: GoogleFonts.storyScript(
                fontSize: 24,

                fontWeight: FontWeight.bold,

                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _searchBar(),
            const SizedBox(height: 22),
            _categoryRow(),
            const SizedBox(height: 28),
            _sectionHeader('Trending Now'),
            const SizedBox(height: 14),
            _trendingRail(),
            const SizedBox(height: 28),
            _sectionHeader('Clubs for You'),
            const SizedBox(height: 14),
            ..._clubs.map(_clubTile),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: const [
          Icon(Icons.search_rounded, color: _muted, size: 20),
          SizedBox(width: 10),
          Text(
            'Search events, clubs, people…',
            style: TextStyle(color: _muted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final c = _categories[i];
          return Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: c.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(c.icon, color: c.color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                c.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: _text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _text,
          ),
        ),
        const Spacer(),
        const Text(
          'See all',
          style: TextStyle(
            fontSize: 13,
            color: _primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _trendingRail() {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _trending.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final t = _trending[i];
          return Container(
            width: 190,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [t.color, t.color.withOpacity(0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Trending',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  t.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  t.host,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _clubTile(_Club c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(c.icon, color: c.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _text,
                  ),
                ),
                Text(
                  c.members,
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: c.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Join',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  const _Category(this.label, this.icon, this.color);
}

class _Trending {
  final String title;
  final String host;
  final Color color;
  const _Trending(this.title, this.host, this.color);
}

class _Club {
  final String name;
  final String members;
  final IconData icon;
  final Color color;
  const _Club(this.name, this.members, this.icon, this.color);
}
