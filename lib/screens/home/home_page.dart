import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/screens/admin/create_event_page.dart';
import 'package:nexevent/screens/auth/login_screen.dart';
import 'package:nexevent/screens/home/events_page.dart';
import 'package:nexevent/screens/home/my_events_page.dart';
import 'package:nexevent/screens/home/profile_page.dart';
import 'package:nexevent/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String role = "";
  Future<void> loadRole() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    setState(() {
      role = doc["role"];
    });
  }

  @override
  void initState() {
    super.initState();
    loadRole();
    // print(role);
  }

  List<Widget> pages = [EventsPage(), MyEventsPage(), ProfilePage()];
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final primaryColor = Theme.of(context).primaryColor;

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
        backgroundColor: const Color.fromARGB(255, 201, 236, 194),
        elevation: 0,
        actions: [
          if (role == 'admin')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: primaryColor.withOpacity(0.08),
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
            padding: const EdgeInsets.only(left: 4.0, right: 16.0),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.08),
                foregroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
              ),
              onPressed: () async {
                final authService = AuthService();
                await authService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const loginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 22),
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
            label: 'Explore',
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
          ),
          BottomNavigationBarItem(
            label: 'My Tickets',
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
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
