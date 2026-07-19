import 'package:flutter/material.dart';

class Cultural extends StatefulWidget {
  const Cultural({super.key});

  @override
  State<Cultural> createState() => _CulturalState();
}

class _CulturalState extends State<Cultural> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cultural')),
      body: Center(child: Text('Coming Soon...')),
    );
  }
}
