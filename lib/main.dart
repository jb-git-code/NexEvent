import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/firebase_options.dart';
import 'package:nexevent/screens/auth/auth_gate.dart';
import 'package:nexevent/screens/home/dashborad_screen.dart';
import 'package:nexevent/services/notification_service.dart';
import 'package:nexevent/theme/app_theme.dart';
import 'package:nexevent/ui/explore.dart';
import 'package:nexevent/ui/feed.dart';
import 'package:nexevent/ui/new_home_page.dart';
import 'package:nexevent/ui/dashboard.dart';

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
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}
