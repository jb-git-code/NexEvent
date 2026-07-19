import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/services/channel_service.dart';
import 'package:nexevent/services/notification_service.dart';

class ChannelCard extends ConsumerStatefulWidget {
  const ChannelCard({
    super.key,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.memberCount,
    required this.isMandatory,
    required this.channelId,
    // this.onJoin,
  });

  final String name;
  final String description;
  final String icon;
  final String type;
  final int memberCount;
  final bool isMandatory;
  // final VoidCallback? onJoin;
  final String channelId;

  // Maps Firestore icon string → Flutter IconData
  static IconData _iconFromString(String iconStr) {
    const map = {
      'sports_soccer': Icons.sports_soccer,
      'music_note': Icons.music_note_rounded,
      'code': Icons.code_rounded,
      'brush': Icons.brush_rounded,
      'camera_alt': Icons.camera_alt_rounded,
      'book': Icons.book_rounded,
      'science': Icons.science_rounded,
      'diversity_3': Icons.diversity_3,
      'announcement': Icons.announcement_rounded,
      'star': Icons.star_rounded,
      'event': Icons.event_rounded,
      'fitness_center': Icons.fitness_center_rounded,
      'palette': Icons.palette_rounded,
      'theater_comedy': Icons.theater_comedy_rounded,
    };
    return map[iconStr] ?? Icons.group_rounded;
  }

  // Pastel background per type
  static Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'community':
        return const Color(0xFFEEF2FF);
      case 'club':
        return const Color(0xFFFFF1F2);
      case 'academic':
        return const Color(0xFFECFDF5);
      case 'announcement':
        return const Color(0xFFFFFBEB);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  static Color _typeAccent(String type) {
    switch (type.toLowerCase()) {
      case 'community':
        return const Color(0xFF4F46E5);
      case 'club':
        return const Color(0xFFE11D48);
      case 'academic':
        return const Color(0xFF16A34A);
      case 'announcement':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  ConsumerState<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends ConsumerState<ChannelCard> {
  // Future<void> toggleJoin() async{
  //   if(isJ)
  // }
  @override
  Widget build(BuildContext context) {
    final accent = ChannelCard._typeAccent(widget.type);
    final bg = ChannelCard._typeColor(widget.type);
    final iconData = ChannelCard._iconFromString(widget.icon);
    final isJoined = ref.watch(
      currentUserProvider.select(
        (user) => user?.joinedChannels.contains(widget.channelId) ?? false,
      ),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEFF1F4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Icon box ----
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(iconData, color: accent, size: 26),
          ),
          const SizedBox(width: 14),

          // ---- Details ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // name + mandatory badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111111),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (widget.isMandatory) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Mandatory',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),

                // description
                Text(
                  widget.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),

                // type chip + member count + join button
                Row(
                  children: [
                    // type pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.type[0].toUpperCase() + widget.type.substring(1),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // member count
                    Icon(
                      Icons.people_alt_outlined,
                      size: 13,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${widget.memberCount}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                      ),
                    ),

                    const Spacer(),
                    GestureDetector(
                      onTap: widget.isMandatory
                          ? null
                          : () async {
                              final user = ref.read(currentUserProvider)!;
                              final isJoin = user.joinedChannels.contains(
                                widget.channelId,
                              );

                              if (isJoin) {
                                await ChannelService().leaveChannel(
                                  uid: user.uid,
                                  channelId: widget.channelId,
                                );
                                final updatedUser = user.copyWith(
                                  joinedChannels: user.joinedChannels
                                      .cast<String>()
                                      .where((id) => id != widget.channelId)
                                      .toList(),
                                );
                                ref
                                    .read(currentUserProvider.notifier)
                                    .setUser(updatedUser);
                                await NotificationService()
                                    .unsubscribeFromChannel(widget.channelId);
                              } else {
                                await ChannelService().joinChannel(
                                  uid: user.uid,
                                  channelId: widget.channelId,
                                );
                                final updatedUser = user.copyWith(
                                  joinedChannels: [
                                    ...user.joinedChannels,
                                    widget.channelId,
                                  ],
                                );
                                ref
                                    .read(currentUserProvider.notifier)
                                    .setUser(updatedUser);
                                await NotificationService().subscribeToChannel(
                                  widget.channelId,
                                );
                              }
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isJoined || widget.isMandatory
                              ? const Color.fromARGB(255, 230, 60, 30)
                              : const Color.fromARGB(255, 38, 162, 26),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          widget.isMandatory
                              ? 'Auto-joined'
                              : isJoined
                              ? 'Leave'
                              : 'Join',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
