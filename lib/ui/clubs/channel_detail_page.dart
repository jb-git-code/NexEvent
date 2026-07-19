import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexevent/models/event_model.dart';
import 'package:nexevent/ui/comm.dart'
    show ChannelModel, AnnouncementModel, iconFor;

/// ---------------------------------------------------------------------
/// NOTE ON SCHEMA
/// ---------------------------------------------------------------------
/// This page assumes you've added `bannerUrl` and `logoUrl` (String,
/// nullable) to the `channels` doc, as agreed. It skips the "Senti"
/// counter and the "ICC" affiliation badge from your screenshot, and
/// skips the Events tab — none of those have a confirmed field/collection
/// yet. Search "TODO" below for exactly where to wire them in once you
/// decide the schema.
/// ---------------------------------------------------------------------

class ChannelDetailPage extends StatefulWidget {
  final ChannelModel channel;
  const ChannelDetailPage({super.key, required this.channel});

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> {
  final _db = FirebaseFirestore.instance;
  bool _isJoining = false;

  Future<void> _toggleJoin(bool currentlyJoined) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isJoining = true);

    final userRef = _db.collection('users').doc(uid);
    final channelRef = _db.collection('channels').doc(widget.channel.channelId);

    try {
      await _db.runTransaction((tx) async {
        if (currentlyJoined) {
          tx.update(userRef, {
            'joinedChannels': FieldValue.arrayRemove([
              widget.channel.channelId,
            ]),
          });
          tx.update(channelRef, {'memberCount': FieldValue.increment(-1)});
        } else {
          tx.update(userRef, {
            'joinedChannels': FieldValue.arrayUnion([widget.channel.channelId]),
          });
          tx.update(channelRef, {'memberCount': FieldValue.increment(1)});
        }
      });
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final channel = widget.channel;
    print('channel -> ${channel.channelId}');

    return DefaultTabController(
      length: 3, // About, People — Events skipped for now (see TODO above)
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: uid == null
            ? const Center(child: Text('Sign in to view this channel'))
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _db.collection('users').doc(uid).snapshots(),
                builder: (context, userSnap) {
                  final joinedChannels = List<String>.from(
                    (userSnap.data?.data()?['joinedChannels'] as List?) ?? [],
                  );
                  final isJoined = joinedChannels.contains(channel.channelId);

                  return NestedScrollView(
                    headerSliverBuilder: (context, _) => [
                      SliverToBoxAdapter(child: _Header(channel: channel)),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabBarDelegate(
                          const TabBar(
                            labelColor: Color(0xFF1F3A5F),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Color(0xFF1F3A5F),
                            tabs: [
                              Tab(text: 'About'),
                              Tab(text: 'People'),
                              Tab(text: 'Events'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    body: TabBarView(
                      children: [
                        _AboutTab(channel: channel),
                        _PeopleTab(channelId: channel.channelId),
                        _EventsTab(channelId: channel.channelId),
                      ],
                    ),
                  );
                },
              ),
        bottomNavigationBar: uid == null
            ? null
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _db.collection('users').doc(uid).snapshots(),
                builder: (context, userSnap) {
                  final joinedChannels = List<String>.from(
                    (userSnap.data?.data()?['joinedChannels'] as List?) ?? [],
                  );
                  final isJoined = joinedChannels.contains(channel.channelId);
                  return _BottomBar(
                    isJoined: isJoined,
                    isLoading: _isJoining,
                    onTap: () => _toggleJoin(isJoined),
                  );
                },
              ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// HEADER — banner + avatar + name + type + member count
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final ChannelModel channel;
  const _Header({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          color: Colors.black,
          child: channel.bannerUrl != null
              ? Image.network(channel.bannerUrl!, fit: BoxFit.cover)
              : Center(
                  child: Icon(
                    iconFor(channel.icon),
                    size: 90,
                    color: Colors.white24,
                  ),
                ),
        ),
        Positioned(
          top: 44,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.black38,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 190),
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
          decoration: const BoxDecoration(
            color: Color(0xFF14202E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 84), // space for the overlapping avatar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel.category,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${channel.memberCount} members',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // TODO: "Senti" counter goes here once you confirm the
                    // field name — same style as memberCount above.
                  ],
                ),
              ),
              // TODO: "ICC" affiliation badge goes here once you confirm
              // where it's stored (own field on channel doc, or a
              // separate `organizations` collection referenced by id).
            ],
          ),
        ),
        Positioned(
          top: 156,
          left: 16,
          child: CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 39,
              backgroundColor: const Color(0xFF14202E),
              backgroundImage: channel.logoUrl != null
                  ? NetworkImage(channel.logoUrl!)
                  : null,
              child: channel.logoUrl == null
                  ? Icon(iconFor(channel.icon), color: Colors.white, size: 32)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFF5F5F5), child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

/// ---------------------------------------------------------------------
/// ABOUT TAB — description + latest announcements
/// ---------------------------------------------------------------------
class _AboutTab extends StatelessWidget {
  final ChannelModel channel;
  const _AboutTab({required this.channel});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          channel.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Announcements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F3A5F),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('announcements')
              .where('channelId', isEqualTo: channel.channelId)
              .orderBy('createdAt', descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final announcements = snap.data!.docs
                .map(AnnouncementModel.fromDoc)
                .toList();
            if (announcements.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No announcements yet',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              );
            }
            return Column(
              children: [
                for (final a in announcements)
                  _AnnouncementCard(announcement: a),
              ],
            );
          },
        ),
        // TODO: Photo Album section goes here once you confirm where
        // photo URLs are stored (e.g. a `photos: List<String>` field,
        // or a `channels/{id}/photos` subcollection).
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: announcement.isPinned
            ? Border.all(color: const Color(0xFF1F3A5F), width: 1.2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (announcement.isPinned) ...[
                const Icon(Icons.push_pin, size: 14, color: Color(0xFF1F3A5F)),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  announcement.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            announcement.content,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            '${announcement.author} • ${_formatDate(announcement.createdAt)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// ---------------------------------------------------------------------
/// PEOPLE TAB — users whose joinedChannels contains this channelId
/// ---------------------------------------------------------------------
class _PeopleTab extends StatelessWidget {
  final String channelId;
  const _PeopleTab({required this.channelId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('joinedChannels', arrayContains: channelId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final members = snap.data!.docs;
        if (members.isEmpty) {
          return Center(
            child: Text(
              'No members yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final data = members[i].data();
            final name =
                data['name'] as String? ??
                data['email'] as String? ??
                'Unknown';
            final photoUrl = data['photoUrl'] as String?;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(name),
              subtitle: data['role'] != null
                  ? Text(data['role'] as String)
                  : null,
            );
          },
        );
      },
    );
  }
}

// Events Tab

class _EventsTab extends StatelessWidget {
  const _EventsTab({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('channelId', isEqualTo: channelId)
          // .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final channelEvents = snap.data!.docs.map(EventModel.fromDoc).toList();
        if (channelEvents.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No events yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }
        return Column(
          children: [
            for (final a in channelEvents) EventHorizontalCard(event: a),
          ],
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// BOTTOM BAR — share + join/leave
/// ---------------------------------------------------------------------
class _BottomBar extends StatelessWidget {
  final bool isJoined;
  final bool isLoading;
  final VoidCallback onTap;

  const _BottomBar({
    required this.isJoined,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF14202E),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.white, size: 20),
                onPressed: () {
                  // TODO: hook up share (e.g. share_plus package)
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isJoined
                      ? Colors.grey.shade300
                      : const Color(0xFF3D5AFE),
                  foregroundColor: isJoined ? Colors.black87 : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isJoined ? 'Joined' : 'Join',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// club events ka card
class EventHorizontalCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventHorizontalCard({super.key, required this.event, this.onTap});

  String getStatus() {
    if (event.isCancelled) return "Cancelled";

    final now = DateTime.now();

    if (now.isBefore(event.eventDate)) {
      return "Upcoming";
    } else if (now.isAfter(event.endDate)) {
      return "Ended";
    } else {
      return "Ongoing";
    }
  }

  Color getStatusColor() {
    switch (getStatus()) {
      case "Upcoming":
        return Colors.blue;
      case "Ongoing":
        return Colors.green;
      case "Ended":
        return Colors.grey;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,

      child: Container(
        height: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(.08),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                width: 95,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => Container(
                  width: 95,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image),
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    event.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      getStatus(),
                      style: TextStyle(
                        color: getStatusColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // const Spacer(),

                  /// Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 15,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          DateFormat(
                            "dd MMM • hh:mm a",
                          ).format(event.eventDate),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  /// Venue
                  /// Registrations
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
