import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/models/user_model.dart';
import 'package:nexevent/providers/auth_state_provider.dart';
import 'package:nexevent/providers/registration_provider.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/admin/announcement_page.dart';
import 'package:nexevent/screens/admin/create_event_page.dart';
import 'package:nexevent/screens/auth/login_screen.dart';
import 'package:nexevent/screens/auth/scanner_page.dart';
import 'package:nexevent/screens/community/community_page.dart';
import 'package:nexevent/screens/home/events_page.dart';
import 'package:nexevent/screens/home/my_events_page.dart';
import 'package:nexevent/screens/home/profile_page.dart';
import 'package:nexevent/screens/home/saved_events.dart';
import 'package:nexevent/screens/home/user_registrations.dart';
import 'package:nexevent/services/auth_service.dart';
import 'package:nexevent/services/firestore_service.dart';

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
    AllAnnouncements(),
    ProfilePage(),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final primaryColor = Theme.of(context).primaryColor;
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currUser = ref.watch(currentUserProvider);

    if (currUser == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    final role = currUser.role;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'NexEvent',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.6,
                color: Color(0xFF111827),
              ),
            ),
            if (user != null && user.email != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  user.email!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (!isLoading && role != 'student') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: primaryColor.withValues(alpha: 0.08),
                  foregroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QRScannerPage()),
                  );
                },
                icon: const Icon(Icons.qr_code_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: primaryColor.withValues(alpha: 0.08),
                  foregroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateEventPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.post_add_rounded, size: 22),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: primaryColor.withValues(alpha: 0.08),
                  foregroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnnouncementPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.pending_actions_outlined, size: 22),
              ),
            ),
          ],
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
            icon: Icon(Icons.event),
            activeIcon: Icon(Icons.event_available),
          ),
          BottomNavigationBarItem(
            label: 'Explore',
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_outlined),
          ),
          BottomNavigationBarItem(
            label: 'News',
            icon: Icon(Icons.newspaper),
            activeIcon: Icon(Icons.newspaper_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
          ),
        ],
      ),
    );
  }
}
