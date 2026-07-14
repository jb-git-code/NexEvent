import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexevent/models/user_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/community/college_feed.dart';
import 'package:nexevent/screens/community/community_page.dart';
import 'package:nexevent/screens/home/events_page.dart';
import 'package:nexevent/screens/home/my_events_page.dart';
import 'package:nexevent/screens/home/profile_page.dart';
import 'package:nexevent/theme/app_theme.dart';
import 'package:nexevent/widgets/drawer_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool isLoading = true;
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

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print('homepage');
    loadUser();
  }

  List<Widget> pages = [
    EventsPage(),
    MyEventsPage(),
    CollegeFeed(),
    AllAnnouncements(),
    ProfilePage(),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final text = AppTextStyles.of(context);

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    final currUser = ref.watch(currentUserProvider);

    if (currUser == null) {
      return Scaffold(
        body: Center(child: Text('User not found', style: text.bodyMedium)),
      );
    }

    final role = currUser.role;
    return Scaffold(
      appBar: AppBar(
        title: Text('Nexus', style: text.h2),
        centerTitle: false,
        actions: [
          if (!isLoading && role != 'student')
            Builder(
              builder: (innerContext) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: colors.primaryMuted,
                    foregroundColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () => Scaffold.of(innerContext).openEndDrawer(),
                  icon: const Icon(LucideIcons.menu, size: 20),
                ),
              ),
            ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 16,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (value) => {
          setState(() {
            _selectedIndex = value;
          }),
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Events',
            icon: Icon(LucideIcons.calendar),
          ),
          BottomNavigationBarItem(
            label: 'Explore',
            icon: Icon(LucideIcons.compass),
          ),
          BottomNavigationBarItem(label: 'Feed', icon: Icon(LucideIcons.rss)),
          BottomNavigationBarItem(
            label: 'News',
            icon: Icon(LucideIcons.newspaper),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(LucideIcons.user),
          ),
        ],
      ),
      endDrawer: buildAdminDrawer(context, role: role),
    );
  }
}
