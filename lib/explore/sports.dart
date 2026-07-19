import 'package:flutter/material.dart';

class Sports extends StatefulWidget {
  const Sports({super.key});

  @override
  State<Sports> createState() => _SportsState();
}

class _SportsState extends State<Sports> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Sports'),
      ),
      body: Center(
        child: Text('Coming Soon...'),
      ),
    );
  }
}