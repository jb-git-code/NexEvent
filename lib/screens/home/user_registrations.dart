import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserRegistrations extends ConsumerStatefulWidget {
  const UserRegistrations({super.key, required this.evId});

  final String evId;

  @override
  ConsumerState<UserRegistrations> createState() => _UserRegistrationsState();
}

class _UserRegistrationsState extends ConsumerState<UserRegistrations> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.read(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Qr Code'), centerTitle: true),
      body: Center(
        child: Container(child: QrImageView(size: 250, data: widget.evId)),
      ),
    );
  }
}
