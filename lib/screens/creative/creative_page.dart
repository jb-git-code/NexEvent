import 'package:flutter/material.dart';

class CreativePage extends StatefulWidget {
  const CreativePage({super.key});

  @override
  State<CreativePage> createState() => _CreativePageState();
}

class _CreativePageState extends State<CreativePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Creative Corner'), centerTitle: true),
    );
  }
}
