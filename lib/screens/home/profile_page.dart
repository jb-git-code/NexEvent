import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/screens/auth/login_screen.dart';
import 'package:nexevent/ui/app_colors.dart';
import 'package:nexevent/ui/comm.dart' show ChannelModel, CommunityRepository;
import 'package:nexevent/ui/gymkhana/boards.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: uid == null
          ? const Center(child: Text('Sign in to view your profile'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snap) {
                final data = snap.data?.data() ?? {};

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      _TopBar(),
                      const SizedBox(height: 16),
                      _IdCard(
                        name: data['name'] as String? ?? '',
                        roll: data['roll'] as String? ?? '',
                        batch: data['batch'] as String? ?? '',
                        branch: data['branch'] as String? ?? '',
                      ),
                      const SizedBox(height: 20),
                      TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF1F3A5F),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF1F3A5F),
                        tabs: const [
                          Tab(text: 'General'),
                          Tab(text: 'Clubs'),
                        ],
                      ),
                      SizedBox(
                        // TabBarView needs a bounded height inside a ListView
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _GeneralTab(
                              notificationsEnabled: _notificationsEnabled,
                              onNotificationsChanged: (v) =>
                                  setState(() => _notificationsEnabled = v),
                            ),
                            const _ClubsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const Text(
            'Profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.black),
              onPressed: () {
                // profile photo edit function
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IdCard extends StatelessWidget {
  final String name;
  final String roll;
  final String batch;
  final String branch;

  const _IdCard({
    required this.name,
    required this.roll,
    required this.batch,
    required this.branch,
  });

  String _computeValidity() {
    final year = int.parse(batch.substring(5));

    final gradYear = 2000 + year;
    return '31/07/$gradYear';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  height: 64,
                  color: Colors.white24,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white70,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardLabel('Name'),
                    _CardValue(name.isEmpty ? '—' : name),
                    const SizedBox(height: 6),
                    _CardLabel('Roll No.'),
                    _CardValue(roll.isEmpty ? '—' : roll),
                  ],
                ),
              ),
              // institute logo
              const Icon(Icons.school, color: Colors.white54, size: 30),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardLabel('Branch'),
                    _CardValue(branch.isEmpty ? '—' : branch),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardLabel('Batch'),
                    _CardValue(batch.isEmpty ? '—' : batch),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardLabel('Validity'),
                    _CardValue(_computeValidity()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: roll.isEmpty
                ? const SizedBox(height: 60)
                : Column(
                    children: [
                      BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: roll,
                        height: 60,
                        drawText: false,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        roll,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  final String text;
  const _CardLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white54, fontSize: 11),
    );
  }
}

class _CardValue extends StatelessWidget {
  final String text;
  const _CardValue(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _GeneralTab extends StatelessWidget {
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;

  const _GeneralTab({
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 12),
      children: [
        _MenuTile(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          trailing: Switch(
            value: notificationsEnabled,
            onChanged: onNotificationsChanged,
          ),
        ),
        // _MenuTile(
        //   icon: Icons.settings_outlined,
        //   label: 'Settings',
        //   onTap: null,
        //   // onTap: () => Navigator.of(context).push(
        //   //   MaterialPageRoute(
        //   //     builder: (_) => const _PlaceholderPage(title: 'Settings'),
        //   //   ),
        //   // ),
        // ),
        // _MenuTile(
        //   icon: Icons.edit_outlined,
        //   label: 'Edit Profile',
        //   onTap: null,
        //   // onTap: () => Navigator.of(context).push(
        //   //   MaterialPageRoute(
        //   //     builder: (_) => const _PlaceholderPage(title: 'Edit Profile'),
        //   //   ),
        //   // ),
        // ),
        _MenuTile(
          icon: Icons.feedback_outlined,
          label: 'Feedback',
          onTap: null,
          // onTap: () => Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (_) => const _PlaceholderPage(title: 'Feedback'),
          //   ),
          // ),
        ),
        const SizedBox(height: 4),
        _MenuTile(
          icon: Icons.logout,
          label: 'Logout',
          isDestructive: true,
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => loginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : Colors.black87;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right, color: Colors.grey.shade400)
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }
}

class _ClubsTab extends StatelessWidget {
  const _ClubsTab();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, userSnap) {
        final joinedChannels = List<String>.from(
          (userSnap.data?.data()?['joinedChannels'] as List?) ?? [],
        );

        return StreamBuilder<List<ChannelModel>>(
          stream: CommunityRepository().channelsByIdsStream(joinedChannels),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final channels = snap.data!;
            if (channels.isEmpty) {
              return Center(
                child: Text(
                  "You haven't joined any clubs yet",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: channels.length,
              itemBuilder: (context, i) => ClubTile(channel: channels[i]),
            );
          },
        );
      },
    );
  }
}
