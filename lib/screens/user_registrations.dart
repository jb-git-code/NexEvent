import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserRegistrations extends ConsumerStatefulWidget {
  const UserRegistrations({super.key});

  @override
  ConsumerState<UserRegistrations> createState() => _UserRegistrationsState();
}

class _UserRegistrationsState extends ConsumerState<UserRegistrations> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  String regisId = '';

  void loadData() async {
    final currentUser = ref.read(currentUserProvider);
    final registration = await FirebaseFirestore.instance
        .collection("registrations")
        .where("userId", isEqualTo: currentUser!.uid)
        .get();

    if (registration.docs.isEmpty) {
      print('No data ');
      return;
    }
    final data = registration.docs.first.data();

    print(data["userId"]);
    print('data fetched');
    setState(() {
      regisId = data["registrationId"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My registrations'), centerTitle: true),
      body: Center(
        child: Container(
          width: 300,
          height: 250,
          child: QrImageView(data: regisId),
        ),
      ),
    );
  }
}
