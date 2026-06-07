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
  }

  List<Widget> pages = [EventsPage(), MyEventsPage(), ProfilePage()];
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: (user != null) ? Text('${user.email}') : Text('Home Page'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,

        actions: [
          (role == 'admin')
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEventPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.post_add_rounded),
                )
              : const SizedBox(),
          IconButton(
            onPressed: () async {
              final authService = AuthService();
              await authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => loginScreen()),
                (route) => false,
              );
            },

            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // showElevation: true,
        // selectedIndex: _currentIndex,
        // onItemSelected: (index) {
        //   setState(() => _currentIndex = index);
        // },
        currentIndex: _selectedIndex,
        onTap: (value) => {
          setState(() {
            _selectedIndex = value;
          }),
        },
        items: [
          BottomNavigationBarItem(label: 'Events', icon: Icon(Icons.event)),
          BottomNavigationBarItem(
            label: 'My Events',
            icon: Icon(Icons.event_note_outlined),
          ),
          BottomNavigationBarItem(label: 'Profile', icon: Icon(Icons.settings)),
        ],
      ),
    );
  }
}
