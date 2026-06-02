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
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,

        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().logout();
            },

            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text('Home Page')),
    );
  }
}
