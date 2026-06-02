import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/firebase_options.dart';
import 'package:nexevent/screens/auth/auth_gate.dart';
import 'package:nexevent/screens/auth/home_page.dart';
import 'package:nexevent/screens/auth/login_screen.dart';
import 'package:nexevent/screens/auth/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.deepOrange),
      home: AuthGate(),
    );
  }
}
