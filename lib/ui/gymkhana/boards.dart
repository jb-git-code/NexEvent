import 'package:flutter/material.dart';
import 'package:nexevent/ui/clubs/channel_detail_page.dart';
import 'package:nexevent/ui/comm.dart'
    show ChannelModel, CommunityRepository, iconFor;
import 'package:nexevent/ui/gymkhana/boards_config.dart';

/// ---------------------------------------------------------------------
/// One generic page for every board — pass a different `board` string
/// (e.g. "cultural", "tech", "sports", "academic") and it queries +
/// renders the matching channels, with the banner/label pulled from
/// board_config.dart. Nothing here is hardcoded per board.
/// ---------------------------------------------------------------------
class BoardPage extends StatefulWidget {
  final String board;
  const BoardPage({super.key, required this.board});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final _repo = CommunityRepository();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = boardConfigFor(widget.board);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<List<ChannelModel>>(
        stream: _repo.channelsByBoardStream(widget.board),
        builder: (context, snap) {
          final channels = snap.data ?? [];
          final filtered = channels
              .where(
                (c) =>
                    _query.isEmpty ||
                    c.name.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _BoardBanner(
                  config: config,
                  controller: _searchController,
                  onSearchChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              if (!snap.hasData)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No clubs in ${config.label} yet',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => ClubTile(channel: filtered[i]),
                    childCount: filtered.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// BANNER — board image + back button + search + label + auto tagline
/// ---------------------------------------------------------------------
class _BoardBanner extends StatelessWidget {
  final BoardConfig config;
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const _BoardBanner({
    required this.config,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        height: 300,
        color: const Color(0xFF14202E), // fallback while/if image fails
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (config.assetPath.isNotEmpty)
              Image.asset(
                config.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 44, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  TextField(
                    controller: controller,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Explore Clubs...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    // Auto-generated for now — swap for a real per-board
                    // tagline whenever you're ready, see board_config.dart
                    'Discover ${config.label} clubs',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// FLAT ROW TILE — icon/logo, name, type, member count ("senti")
/// Public so any other list-style page can reuse it too.
/// ---------------------------------------------------------------------
class ClubTile extends StatelessWidget {
  final ChannelModel channel;
  const ClubTile({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChannelDetailPage(channel: channel),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 68,
                height: 68,
                child: channel.logoUrl != null
                    ? Image.network(channel.logoUrl!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF14202E),
                        child: Icon(
                          iconFor(channel.icon),
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Per your call: this comes straight from the channel
                  // doc's `type` field (e.g. "Music Club"), not the
                  // broad `board` category.
                  Text(
                    channel.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${channel.memberCount}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'members',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
