import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NexEventCommunitiesPoly extends StatelessWidget {
  const NexEventCommunitiesPoly({super.key});

  static const _text = Color(0xFF14151A);
  static const _muted = Color(0xFF8A8D9A);
  static const _card = Color(0xFFF3F4F7);
  static const _primary = Color(0xFF4361EE);

  static const _joined = [
    _Channel(
      'Unnati Society',
      '2.4k members',
      Icons.theater_comedy_rounded,
      Color(0xFF9B6BFF),
      true,
    ),
    _Channel(
      'Tech Club',
      '1.8k members',
      Icons.memory_rounded,
      Color(0xFF20C997),
      true,
    ),
  ];

  static const _discover = [
    _Channel(
      'Sports Committee',
      '960 members',
      Icons.sports_soccer_rounded,
      Color(0xFFFF9F43),
      false,
    ),
    _Channel(
      'Marketplace',
      '3.1k members',
      Icons.storefront_rounded,
      Color(0xFFEE6C9C),
      false,
    ),
    _Channel(
      'Photography Club',
      '1.2k members',
      Icons.camera_alt_rounded,
      Color(0xFF4361EE),
      false,
    ),
    _Channel(
      'Debate Circle',
      '540 members',
      Icons.record_voice_over_rounded,
      Color(0xFF9B6BFF),
      false,
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
              'Community',
              style: GoogleFonts.storyScript(
                fontSize: 24,

                fontWeight: FontWeight.bold,

                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _sectionHeader('My Communities'),
            const SizedBox(height: 14),
            ..._joined.map(_channelTile),
            const SizedBox(height: 26),
            _sectionHeader('Discover More'),
            const SizedBox(height: 14),
            ..._discover.map(_channelTile),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: _text,
      ),
    );
  }

  Widget _channelTile(_Channel c) {
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: c.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(c.icon, color: c.color, size: 21),
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
              color: c.joined ? Colors.white : c.color,
              borderRadius: BorderRadius.circular(14),
              border: c.joined ? Border.all(color: c.color, width: 1.4) : null,
            ),
            child: Text(
              c.joined ? 'Joined' : 'Join',
              style: TextStyle(
                color: c.joined ? c.color : Colors.white,
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

class _Channel {
  final String name;
  final String members;
  final IconData icon;
  final Color color;
  final bool joined;
  const _Channel(this.name, this.members, this.icon, this.color, this.joined);
}
