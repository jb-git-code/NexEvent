import 'package:flutter/material.dart';

class Workshops extends StatefulWidget {
  const Workshops({super.key});

  @override
  State<Workshops> createState() => _WorkshopsState();
}

class _WorkshopsState extends State<Workshops> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Workshops'),
      ),
      body: Center(
        child: Text('Coming Soon...'),
      ),
    );
  }
}