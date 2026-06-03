import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/screens/auth/login_screen.dart';
import 'package:nexevent/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: (user != null) ? Text('${user.email}') : Text('Home Page'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,

        actions: [
          IconButton(
            onPressed: () async {
              final authService = new AuthService();
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
      body: Center(child: Text('Home Page')),
    );
  }
}
