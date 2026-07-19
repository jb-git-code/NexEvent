import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/models/user_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/ui/feed.dart';
import 'package:nexevent/ui/comm.dart';
import 'package:nexevent/ui/explore.dart';
import 'package:nexevent/ui/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewHomePage extends ConsumerStatefulWidget {
  const NewHomePage({super.key});

  @override
  ConsumerState<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends ConsumerState<NewHomePage> {
  int _index = 0;
  final _pages = const [
    NexEventDashboardPoly(),
    EventsPage(),
    ExplorePage(),
    CommunityPage(),
  ];

  Future<void> loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return;
    }

    final uid = firebaseUser.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (!doc.exists || doc.data() == null) {
      return;
    }

    final user = UserModel.fromMap(doc.data()!);

    ref.read(currentUserProvider.notifier).setUser(user);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    print('enter homepage');
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NexEventBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() {
          _index = i;
        }),
      ),
    );
  }
}

class NexEventBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NexEventBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _text = Color(0xFF14151A);
  static const _primary = Color(0xFF4361EE);

  static const _items = [
    _NavItem('Home', Icons.home_rounded),
    _NavItem('Feed', Icons.dynamic_feed_rounded),
    _NavItem('Explore', Icons.search_rounded),
    _NavItem('Community', Icons.forum_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _text,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_items.length, (i) {
          final it = _items[i];
          final active = i == currentIndex;
          final color = active ? _primary : Colors.white38;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: active ? const EdgeInsets.all(6) : EdgeInsets.zero,
                    decoration: active
                        ? BoxDecoration(
                            color: _primary.withOpacity(0.18),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Icon(it.icon, size: 20, color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    it.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}
