import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/screens/creative/creative_post.dart';

class CreativePage extends ConsumerStatefulWidget {
  const CreativePage({super.key});

  @override
  ConsumerState<CreativePage> createState() => _CreativePageState();
}

class _CreativePageState extends ConsumerState<CreativePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Creative Corner'), centerTitle: true),
      floatingActionButton: (user!.role == 'admin')
          ? FloatingActionButton(
              child: Icon(Icons.note_alt_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreativePost()),
                );
              },
            )
          : const SizedBox(),
      body: Center(child: Text('Posts')),
    );
  }
}
