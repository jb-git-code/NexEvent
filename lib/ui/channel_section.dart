import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexevent/ui/app_colors.dart';
import 'package:nexevent/ui/app_theme.dart';

/// Maps a channel's `channels/{id}` doc into a typed model.
class ChannelModel {
  final String id; // == channelId field / doc id
  final String name;
  final String description;
  final String icon; // raw string from Firestore, e.g. "school"
  final String type; // "official" | "student" | ...
  final bool isMandatory;
  final int memberCount;

  ChannelModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.isMandatory,
    required this.memberCount,
  });

  factory ChannelModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChannelModel(
      id: d['channelId'] ?? doc.id,
      name: d['name'] ?? 'Channel',
      description: d['description'] ?? '',
      icon: d['icon'] ?? 'hash',
      type: d['type'] ?? 'student',
      isMandatory: d['isMandatory'] == true,
      memberCount: (d['memberCount'] ?? 0) as int,
    );
  }
}

class ChannelsSection extends StatefulWidget {
  final String uid;
  const ChannelsSection({super.key, required this.uid});

  @override
  State<ChannelsSection> createState() => _ChannelsSectionState();
}

class _ChannelsSectionState extends State<ChannelsSection> {
  final Set<String> _justJoined = {};

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  Timer? _debounce;

  // Fetched ONCE and cached — typing in search no longer re-hits Firestore.
  late final Future<DocumentSnapshot> _userFuture;
  late final Future<QuerySnapshot> _channelsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture =
        FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    _channelsFuture =
        FirebaseFirestore.instance.collection('channels').get();

    _searchFocus.addListener(() => setState(() {})); // repaint border on focus
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    setState(() => _query = '');
  }

  Future<void> _joinChannel(String channelId) async {
    setState(() => _justJoined.add(channelId));

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.uid);
    final channelRef =
        FirebaseFirestore.instance.collection('channels').doc(channelId);

    await Future.wait([
      userRef.update({
        'joinedChannels': FieldValue.arrayUnion([channelId]),
      }),
      channelRef.update({'memberCount': FieldValue.increment(1)}),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _searchBar(),
        const SizedBox(height: 10),
        FutureBuilder<DocumentSnapshot>(
          future: _userFuture,
          builder: (context, userSnap) {
            if (!userSnap.hasData) return _loadingSpinner();

            final userData = userSnap.data!.data() as Map<String, dynamic>?;
            final joined =
                List<String>.from(userData?['joinedChannels'] ?? []);
            final joinedSet = {...joined, ..._justJoined};

            return FutureBuilder<QuerySnapshot>(
              future: _channelsFuture,
              builder: (context, chSnap) {
                if (!chSnap.hasData) return _loadingSpinner();

                final all =
                    chSnap.data!.docs.map(ChannelModel.fromDoc).toList();

                final isSearching = _query.isNotEmpty;
                final results = isSearching
                    ? all
                        .where((c) =>
                            c.name.toLowerCase().contains(_query.toLowerCase()))
                        .toList()
                    : <ChannelModel>[];

                final yourChannels =
                    all.where((c) => joinedSet.contains(c.id)).toList();
                final suggestions = all
                    .where((c) => !joinedSet.contains(c.id))
                    .take(5)
                    .toList();

                // While searching, show ONLY search results — avoids the
                // confusing "results + Your Channels + Suggested" pile-up.
                if (isSearching) {
                  return _searchResults(results, joinedSet);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (yourChannels.isNotEmpty) ...[
                      _header('Your Channels'),
                      const SizedBox(height: 12),
                      _rail(yourChannels, joined: true),
                      const SizedBox(height: 22),
                    ],
                    if (suggestions.isNotEmpty) ...[
                      _header('Suggested for You'),
                      const SizedBox(height: 12),
                      _rail(suggestions, joined: false),
                      const SizedBox(height: 22),
                    ],
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 18),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _loadingSpinner() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────
  Widget _searchBar() {
    final focused = _searchFocus.hasFocus;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: focused ? AppColors.primary : AppColors.border,
            width: focused ? 1.4 : 1,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: focused ? AppColors.primary : AppColors.muted,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search clubs...',
                  hintStyle: TextStyle(color: AppColors.muted, fontSize: 14),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.text),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: _clearSearch,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.muted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Search results ──────────────────────────────────────
  Widget _searchResults(List<ChannelModel> results, Set<String> joinedSet) {
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            const Icon(LucideIcons.searchX, size: 30, color: AppColors.muted),
            const SizedBox(height: 10),
            Text(
              'No clubs found for "$_query"',
              style: AppTextStyles.caption.copyWith(fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final c = results[i];
        final color = _channelColor(c.id);
        final isJoined = joinedSet.contains(c.id);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconFor(c.icon), size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h3.copyWith(fontSize: 14),
                    ),
                    Text(
                      '${c.memberCount} members',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: isJoined ? null : () => _joinChannel(c.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isJoined ? Colors.white : color,
                    borderRadius: BorderRadius.circular(10),
                    border: isJoined
                        ? Border.all(color: color, width: 1.3)
                        : null,
                  ),
                  child: Text(
                    isJoined ? 'Joined' : 'Join',
                    style: AppTextStyles.chip.copyWith(
                      color: isJoined ? color : Colors.white,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title, style: AppTextStyles.h2),
    );
  }

  Widget _rail(List<ChannelModel> channels, {required bool joined}) {
    return SizedBox(
      height: joined ? 92 : 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: channels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final c = channels[i];
          return joined ? _joinedChip(c) : _suggestionCard(c);
        },
      ),
    );
  }

  Widget _joinedChip(ChannelModel c) {
    final color = _channelColor(c.id);
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: c.isMandatory
                  ? Border.all(color: color, width: 1.6)
                  : null,
            ),
            child: Icon(_iconFor(c.icon), color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            c.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionCard(ChannelModel c) {
    final color = _channelColor(c.id);
    final alreadyJoined = _justJoined.contains(c.id);
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconFor(c.icon), size: 17, color: color),
              ),
              const Spacer(),
              Text(
                '${c.memberCount}',
                style: AppTextStyles.caption.copyWith(fontSize: 10.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            c.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h3.copyWith(fontSize: 13.5),
          ),
          const Spacer(),
          GestureDetector(
            onTap: alreadyJoined ? null : () => _joinChannel(c.id),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: alreadyJoined ? Colors.white : color,
                borderRadius: BorderRadius.circular(10),
                border: alreadyJoined
                    ? Border.all(color: color, width: 1.3)
                    : null,
              ),
              child: Text(
                alreadyJoined ? 'Joined' : 'Join',
                style: AppTextStyles.chip.copyWith(
                  color: alreadyJoined ? color : Colors.white,
                  fontSize: 11.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Deterministic accent color per channel so the same channel always
  // reads the same color across screens (Feed, Communities, here).
  Color _channelColor(String id) {
    const palette = [
      AppColors.primary,
      AppColors.accentGreen,
      AppColors.accentPurple,
      AppColors.accentOrange,
      AppColors.accentPink,
    ];
    return palette[id.hashCode.abs() % palette.length];
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'school':
        return LucideIcons.graduationCap;
      case 'code':
        return LucideIcons.code2;
      case 'sports':
      case 'trophy':
        return LucideIcons.trophy;
      case 'music':
        return LucideIcons.music;
      case 'art':
      case 'palette':
        return LucideIcons.palette;
      case 'camera':
        return LucideIcons.camera;
      case 'megaphone':
      case 'announcement':
        return LucideIcons.megaphone;
      case 'book':
        return LucideIcons.bookOpen;
      case 'briefcase':
        return LucideIcons.briefcase;
      case 'calendar':
        return LucideIcons.calendar;
      case 'gamepad':
      case 'gaming':
        return LucideIcons.gamepad2;
      case 'users':
      case 'group':
        return LucideIcons.users;
      default:
        return LucideIcons.hash;
    }
  }
}