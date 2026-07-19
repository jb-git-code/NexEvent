import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/ui/app_colors.dart';
import 'package:nexevent/ui/clubs/channel_detail_page.dart';

/// ---------------------------------------------------------------------
/// DATA MODELS — mapped to your existing Firestore schema
/// ---------------------------------------------------------------------

class ChannelModel {
  final String channelId;
  final String name;
  final String description;
  final String icon; // e.g. "sports_soccer" -> maps to a Material icon
  final bool isMandatory;
  final int memberCount;
  final String type; // raw firestore value, currently always "community"
  final String
  board; // new field — e.g. "cultural", "tech", "sports", "academic", "official"
  final DateTime? createdAt;
  final String? bannerUrl; // new field — add to channel doc in Firestore
  final String? logoUrl; // new field — add to channel doc in Firestore

  const ChannelModel({
    required this.channelId,
    required this.name,
    required this.description,
    required this.icon,
    required this.isMandatory,
    required this.memberCount,
    required this.type,
    required this.board,
    this.createdAt,
    this.bannerUrl,
    this.logoUrl,
  });

  factory ChannelModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChannelModel(
      channelId: data['channelId'] as String? ?? doc.id,
      name: data['name'] as String? ?? doc.id,
      description: data['description'] as String? ?? '',
      icon: data['icon'] as String? ?? 'groups',
      isMandatory: data['isMandatory'] as bool? ?? false,
      memberCount: data['memberCount'] as int? ?? 0,
      type: data['type'] as String? ?? 'community',
      board: data['board'] as String? ?? 'other',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      bannerUrl: data['bannerUrl'] as String?,
      logoUrl: data['logoUrl'] as String?,
    );
  }

  /// Display label for the board, e.g. "cultural" -> "Cultural".
  String get category => board.isEmpty
      ? 'Other'
      : '${board[0].toUpperCase()}${board.substring(1)}';
}

class AnnouncementModel {
  final String id;
  final String channelId;
  final String title;
  final String content;
  final String author;
  final bool isPinned;
  final DateTime? createdAt;

  const AnnouncementModel({
    required this.id,
    required this.channelId,
    required this.title,
    required this.content,
    required this.author,
    required this.isPinned,
    this.createdAt,
  });

  factory AnnouncementModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AnnouncementModel(
      id: data['id'] as String? ?? doc.id,
      channelId: data['channelId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      author: data['author'] as String? ?? '',
      isPinned: data['isPinned'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Board values used across the app. Keep this in sync with whatever
/// values you actually write into the `board` field on channel docs
/// (lowercase, e.g. "cultural", "tech", "sports", "academic", "official").
const List<String> categoryFilters = [
  'All',
  'Official',
  'Academic',
  'Tech',
  'Cultural',
  'Sports',
];

const Map<String, IconData> _iconMap = {
  'sports_soccer': Icons.sports_soccer,
  'code': Icons.code,
  'music_note': Icons.music_note,
  'theater_comedy': Icons.theater_comedy,
  'camera_alt': Icons.camera_alt,
  'school': Icons.school,
  'work': Icons.work,
  'event': Icons.event,
  'chess': Icons.grid_on,
  'groups': Icons.groups,
};

IconData iconFor(String name) => _iconMap[name] ?? Icons.groups;

/// ---------------------------------------------------------------------
/// FIRESTORE ACCESS
/// ---------------------------------------------------------------------

class CommunityRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<ChannelModel>> channelsStream() {
    return _db
        .collection('channels')
        .snapshots()
        .map((snap) => snap.docs.map(ChannelModel.fromDoc).toList());
  }

  /// Channels belonging to a single board (e.g. "cultural", "tech").
  /// Used by BoardPage — one generic query, works for any board value.
  Stream<List<ChannelModel>> channelsByBoardStream(String board) {
    return _db
        .collection('channels')
        .where('board', isEqualTo: board.toLowerCase())
        .snapshots()
        .map((snap) => snap.docs.map(ChannelModel.fromDoc).toList());
  }

  /// Channels matching a specific list of channelIds — used for "my
  /// joined clubs" on the profile page. Firestore's whereIn caps at 30
  /// values; fine for a personal joined-clubs list.
  Stream<List<ChannelModel>> channelsByIdsStream(List<String> channelIds) {
    if (channelIds.isEmpty) return Stream.value([]);
    return _db
        .collection('channels')
        .where('channelId', whereIn: channelIds)
        .snapshots()
        .map((snap) => snap.docs.map(ChannelModel.fromDoc).toList());
  }

  /// users/{uid} doc stream — gives us joinedChannels + role in one go.
  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Latest announcement per channelId, batched with a single `whereIn`
  /// query (Firestore allows up to 30 values per whereIn as of now).
  Future<Map<String, AnnouncementModel>> latestAnnouncementsFor(
    List<String> channelIds,
  ) async {
    if (channelIds.isEmpty) return {};
    final snap = await _db
        .collection('announcements')
        .where('channelId', whereIn: channelIds)
        .orderBy('createdAt', descending: true)
        .get();

    final latestByChannel = <String, AnnouncementModel>{};
    for (final doc in snap.docs) {
      final a = AnnouncementModel.fromDoc(doc);
      // docs already sorted newest-first, so first hit per channel wins
      latestByChannel.putIfAbsent(a.channelId, () => a);
    }
    return latestByChannel;
  }

  /// Count of announcements posted today across a set of channels —
  /// used as an "activity" proxy since there's no unread tracking yet.
  Future<int> todaysAnnouncementCount(List<String> channelIds) async {
    if (channelIds.isEmpty) return 0;
    final startOfDay = DateTime.now().let(
      (now) => DateTime(now.year, now.month, now.day),
    );
    final snap = await _db
        .collection('announcements')
        .where('channelId', whereIn: channelIds)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .get();
    return snap.docs.length;
  }

  /// Today's announcement count PER channel, across every channel (not
  /// just joined ones) — used to rank "Trending Clubs".
  Future<Map<String, int>> todaysAnnouncementCountByChannel() async {
    final startOfDay = DateTime.now().let(
      (now) => DateTime(now.year, now.month, now.day),
    );
    final snap = await _db
        .collection('announcements')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .get();
    final counts = <String, int>{};
    for (final doc in snap.docs) {
      final channelId = doc.data()['channelId'] as String? ?? '';
      if (channelId.isEmpty) continue;
      counts[channelId] = (counts[channelId] ?? 0) + 1;
    }
    return counts;
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

/// ---------------------------------------------------------------------
/// PAGE
/// ---------------------------------------------------------------------

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _repo = CommunityRepository();
  final _searchController = TextEditingController();

  String _query = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text(
          'Community',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: uid == null
          ? const Center(child: Text('Sign in to view your community'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _repo.userDocStream(uid),
              builder: (context, userSnap) {
                if (!userSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final userData = userSnap.data!.data() ?? {};
                final joinedChannels = List<String>.from(
                  userData['joinedChannels'] as List? ?? [],
                );
                final role = userData['role'] as String? ?? 'student';

                return StreamBuilder<List<ChannelModel>>(
                  stream: _repo.channelsStream(),
                  builder: (context, channelSnap) {
                    if (!channelSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final allChannels = channelSnap.data!;
                    return _CommunityBody(
                      allChannels: allChannels,
                      joinedChannels: joinedChannels,
                      isAdmin: role == 'admin',
                      repo: _repo,
                      searchController: _searchController,
                      query: _query,
                      onQueryChanged: (v) => setState(() => _query = v),
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (c) =>
                          setState(() => _selectedCategory = c),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _CommunityBody extends StatelessWidget {
  final List<ChannelModel> allChannels;
  final List<String> joinedChannels;
  final bool isAdmin;
  final CommunityRepository repo;
  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _CommunityBody({
    required this.allChannels,
    required this.joinedChannels,
    required this.isAdmin,
    required this.repo,
    required this.searchController,
    required this.query,
    required this.onQueryChanged,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final mandatoryChannels = allChannels.where((c) => c.isMandatory).toList();

    final filtered = allChannels.where((c) {
      final matchesSearch =
          query.isEmpty || c.name.toLowerCase().contains(query.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' || c.category == selectedCategory;
      return matchesSearch && matchesCategory && !c.isMandatory;
    }).toList();

    // Which boards the user is already into, based on joined clubs —
    // used to power the "Recommended" section below.
    final joinedBoards = allChannels
        .where((c) => joinedChannels.contains(c.channelId))
        .map((c) => c.board)
        .toSet();

    return FutureBuilder<_ActivityData>(
      future: _loadActivity(
        allChannels.map((c) => c.channelId).toList(),
        joinedChannels,
      ),
      builder: (context, activitySnap) {
        final latestByChannel = activitySnap.data?.latestByChannel ?? {};
        final todaysCount = activitySnap.data?.todaysCount ?? 0;
        final todaysCountByChannel =
            activitySnap.data?.todaysCountByChannel ?? {};

        // Trending: today's activity first, memberCount as tiebreak/fallback.
        final trending = List<ChannelModel>.from(allChannels)
          ..sort((a, b) {
            final countA = todaysCountByChannel[a.channelId] ?? 0;
            final countB = todaysCountByChannel[b.channelId] ?? 0;
            if (countA != countB) return countB.compareTo(countA);
            return b.memberCount.compareTo(a.memberCount);
          });
        final trendingTop = trending.take(6).toList();

        // Recommended: unjoined clubs sharing a board with something the
        // user already joined; falls back to popular unjoined clubs if
        // the user hasn't joined anything yet (or has no board overlap).
        final unjoined = allChannels
            .where((c) => !joinedChannels.contains(c.channelId))
            .toList();
        var recommended = unjoined
            .where((c) => joinedBoards.contains(c.board))
            .toList();
        if (recommended.isEmpty) {
          recommended = List<ChannelModel>.from(unjoined);
        }
        recommended.sort((a, b) => b.memberCount.compareTo(a.memberCount));
        final recommendedTop = recommended.take(6).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _StatsStrip(
              joinedCount: joinedChannels.length,
              activeTodayCount: todaysCount,
            ),

            const SizedBox(height: 20),
            if (trendingTop.isNotEmpty) ...[
              const _SectionHeading(text: 'Trending Clubs'),
              const SizedBox(height: 10),
              _HorizontalClubRow(channels: trendingTop),
              const SizedBox(height: 20),
            ],
            if (recommendedTop.isNotEmpty) ...[
              const _SectionHeading(text: 'Recommended For You'),
              const SizedBox(height: 10),
              _HorizontalClubRow(channels: recommendedTop),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 24),
            const _SectionHeading(text: 'Blogs'),
            const SizedBox(height: 10),
            const _BlogSection(),
          ],
        );
      },
    );
  }

  Future<_ActivityData> _loadActivity(
    List<String> allChannelIds,
    List<String> joinedChannelIds,
  ) async {
    final latest = await repo.latestAnnouncementsFor(allChannelIds);
    final todaysCount = await repo.todaysAnnouncementCount(joinedChannelIds);
    final todaysByChannel = await repo.todaysAnnouncementCountByChannel();
    return _ActivityData(
      latestByChannel: latest,
      todaysCount: todaysCount,
      todaysCountByChannel: todaysByChannel,
    );
  }
}

class _ActivityData {
  final Map<String, AnnouncementModel> latestByChannel;
  final int todaysCount;
  final Map<String, int> todaysCountByChannel;
  _ActivityData({
    required this.latestByChannel,
    required this.todaysCount,
    required this.todaysCountByChannel,
  });
}

/// ---------------------------------------------------------------------
/// WIDGETS
/// ---------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search channels',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final int joinedCount;
  final int activeTodayCount;
  const _StatsStrip({
    required this.joinedCount,
    required this.activeTodayCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.groups, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$joinedCount channels joined',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Spacer(),
        Icon(Icons.bolt, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '$activeTodayCount new today',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Horizontal scrolling row of small club cards — used by both the
/// "Trending Clubs" and "Recommended For You" sections.
/// ---------------------------------------------------------------------
class _HorizontalClubRow extends StatelessWidget {
  final List<ChannelModel> channels;
  const _HorizontalClubRow({required this.channels});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: channels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _ClubMiniCard(channel: channels[i]),
      ),
    );
  }
}

class _ClubMiniCard extends StatelessWidget {
  final ChannelModel channel;
  const _ClubMiniCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChannelDetailPage(channel: channel),
          ),
        );
      },
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.mapTrack,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 44,
                height: 44,
                child: channel.logoUrl != null
                    ? Image.network(channel.logoUrl!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF14202E),
                        child: Icon(
                          iconFor(channel.icon),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              channel.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.people_alt, size: 13, color: Colors.black),
                const SizedBox(width: 3),
                Text(
                  '${channel.memberCount}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F3A5F),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// BLOGS SECTION — DUMMY DATA for now.
///
/// Intended Firestore schema once you're ready to wire it up:
///   blogs/{autoId}
///   ├── title: string
///   ├── excerpt: string          (short 1-2 line summary)
///   ├── content: string          (full body, if read-in-app)
///   ├── imageUrl: string?
///   ├── author: string
///   └── createdAt: timestamp
///
/// Swap `_dummyBlogs` below for a StreamBuilder on `blogs`, ordered by
/// createdAt desc, and reuse `_BlogCard` as-is — it already takes a
/// `BlogPost` object, nothing else needs to change.
/// ---------------------------------------------------------------------

class BlogPost {
  final String title;
  final String excerpt;
  final String author;
  final String? imageUrl;
  final DateTime? createdAt;

  const BlogPost({
    required this.title,
    required this.excerpt,
    required this.author,
    this.imageUrl,
    this.createdAt,
  });
}

final List<BlogPost> _dummyBlogs = [
  BlogPost(
    title: 'How Symphony Prepped for Mood Indigo',
    excerpt:
        'Behind the scenes with the Music Club\'s biggest set of the year.',
    author: 'Symphony',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  BlogPost(
    title: '5 Tips to Nail Your First Hackathon',
    excerpt: 'Coding Club shares what actually matters in the first 6 hours.',
    author: 'Coding Club',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  BlogPost(
    title: 'Through the Lens: Campus in Monsoon',
    excerpt: 'Pixels\' favourite shots from this year\'s rains.',
    author: 'Pixels',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
  ),
];

class _BlogSection extends StatelessWidget {
  const _BlogSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dummyBlogs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _BlogCard(post: _dummyBlogs[i]),
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final BlogPost post;
  const _BlogCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // TODO: navigate to a blog detail page once that exists
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: post.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(post.imageUrl!, fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.article_outlined,
                      color: Color(0xFF1F3A5F),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              post.author,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
