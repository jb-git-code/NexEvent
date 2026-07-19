import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/screens/auth/auth_gate.dart';
import 'package:nexevent/screens/auth/login_screen.dart';

// TODO: point these at your real screens once you tell me the class

import 'package:nexevent/ui/new_home_page.dart';

/// ---------------------------------------------------------------------
/// SPLASH SCREEN
///
/// Logo + app name fade in, then after a short beat we check auth state:
///   - signed in  -> HomePage
///   - not signed in -> LoginPage (adjust to your onboarding flow if
///     first-time users should see something else first)
///
/// TODO: update the asset path below to your real logo.
/// ---------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  static const _logoAssetPath =
      'assets/images/app_logo.png'; // TODO: swap in real path
  static const _appName = 'NexEvent'; // TODO: confirm this is the right name

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    print('enter navigate next');
    // Small delay so the fade-in is actually visible before we leave.
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => AuthGate()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  _logoAssetPath,
                  width: 96,
                  height: 96,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECECEC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Color(0xFF1F3A5F),
                      size: 44,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                _appName,
                style: TextStyle(
                  color: Color(0xFF1F3A5F),
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
