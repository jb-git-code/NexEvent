import 'package:flutter/material.dart';

class QuickLinks extends StatefulWidget {
  const QuickLinks({super.key});

  @override
  State<QuickLinks> createState() => _QuickLinksState();
}

class _QuickLinksState extends State<QuickLinks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quick Links'), centerTitle: true),
      body: Center(child: Text('Quick Links')),
    );
  }
}
