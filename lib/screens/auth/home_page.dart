import 'package:flutter/material.dart';
import 'package:nexevent/screens/auth/login_screen.dart';

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
            onPressed: () {
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
