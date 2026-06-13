import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/screens/home/home_page.dart';
import 'login_screen.dart';

final authStateProvider = StreamProvider(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return HomePage();
        }

        return loginScreen();
      },

      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (error, stack) =>
          Scaffold(body: Center(child: Text(error.toString()))),
    );
  }
}
