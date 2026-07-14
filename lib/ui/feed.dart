import 'package:flutter/material.dart';

/// NexEvent Feed — Polychrome theme
/// Same palette as the dashboard: white base, indigo primary,
/// each post's channel/category carries its own accent color.
class NexEventFeedPoly extends StatelessWidget {
  const NexEventFeedPoly({super.key});

  static const _text = Color(0xFF14151A);
  static const _muted = Color(0xFF8A8D9A);
  static const _card = Color(0xFFF3F4F7);
  static const _primary = Color(0xFF4361EE);

  static const _posts = [
    _Post(
      channel: 'Unnati Society',
      color: Color(0xFF9B6BFF),
      icon: Icons.theater_comedy_rounded,
      time: '2h ago',
      text:
          'Rehearsals for the annual cultural night kick off this weekend — all performers report to the auditorium by 5 PM.',
      likes: 128,
      comments: 24,
      hasImage: true,
    ),
    _Post(
      channel: 'Tech Club',
      color: Color(0xFF20C997),
      icon: Icons.memory_rounded,
      time: '4h ago',
      text:
          'Registrations for the 24-hour hackathon are now open. Teams of up to 4, prizes worth ₹50k up for grabs.',
      likes: 302,
      comments: 61,
      hasImage: false,
    ),
    _Post(
      channel: 'Sports Committee',
      color: Color(0xFFFF9F43),
      icon: Icons.sports_soccer_rounded,
      time: '6h ago',
      text:
          'Football finals postponed to Thursday due to rain. New venue: Ground B.',
      likes: 89,
      comments: 12,
      hasImage: true,
    ),
    _Post(
      channel: 'Marketplace',
      color: Color(0xFFEE6C9C),
      icon: Icons.storefront_rounded,
      time: '1d ago',
      text:
          'Selling a barely-used study table + chair combo, hostel pickup only. DM for price.',
      likes: 34,
      comments: 9,
      hasImage: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _topBar(),
            ),
            const SizedBox(height: 18),
            _filterChips(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: _posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _postCard(_posts[i]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: const [
        Text(
          'Feed',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _text,
          ),
        ),
        Spacer(),
        _IconCircle(icon: Icons.search_rounded),
        SizedBox(width: 10),
        _IconCircle(icon: Icons.notifications_none_rounded),
      ],
    );
  }

  Widget _filterChips() {
    final chips = const [
      _Chip('All', _primary),
      _Chip('Cultural', Color(0xFF9B6BFF)),
      _Chip('Tech', Color(0xFF20C997)),
      _Chip('Sports', Color(0xFFFF9F43)),
      _Chip('Marketplace', Color(0xFFEE6C9C)),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = chips[i];
          final selected = i == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? c.color : c.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              c.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : c.color,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _postCard(_Post p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: p.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(p.icon, size: 18, color: p.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.channel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _text,
                      ),
                    ),
                    Text(
                      p.time,
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: _muted),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            p.text,
            style: const TextStyle(fontSize: 14, color: _text, height: 1.4),
          ),
          if (p.hasImage) ...[
            const SizedBox(height: 12),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    p.color.withOpacity(0.35),
                    p.color.withOpacity(0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.image_rounded,
                color: p.color.withOpacity(0.6),
                size: 30,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _actionIcon(Icons.favorite_border_rounded, '${p.likes}', p.color),
              const SizedBox(width: 18),
              _actionIcon(Icons.mode_comment_outlined, '${p.comments}', _muted),
              const Spacer(),
              const Icon(Icons.share_outlined, size: 18, color: _muted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

 
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  const _IconCircle({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF3F4F7),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF14151A)),
    );
  }
}

class _Chip {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);
}

class _Post {
  final String channel;
  final Color color;
  final IconData icon;
  final String time;
  final String text;
  final int likes;
  final int comments;
  final bool hasImage;
  const _Post({
    required this.channel,
    required this.color,
    required this.icon,
    required this.time,
    required this.text,
    required this.likes,
    required this.comments,
    required this.hasImage,
  });
}
