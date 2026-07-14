import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/firebase_options.dart';
import 'package:nexevent/screens/auth/auth_gate.dart';
import 'package:nexevent/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // All colors, typography, and spacing come from lib/theme/.
      // Once dark mode is ready: add AppTheme.dark, wire `darkTheme:`
      // here, and set `themeMode:` — no page code needs to change,
      // since pages read AppColors.of(context) / AppTextStyles.of(context).
      home: const AuthGate(),
    );
  }
}
