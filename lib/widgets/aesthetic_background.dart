import 'dart:ui';
import 'package:flutter/material.dart';

class AestheticBackground extends StatelessWidget {
  final Widget child;

  const AestheticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Stack(
      children: [
        // Solid background base (slate 50)
        Container(
          color: const Color(0xFFF8FAFC),
        ),
        // Glowing overlay circle top right
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.12),
            ),
          ),
        ),
        // Glowing overlay circle bottom left
        Positioned(
          bottom: -120,
          left: -80,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondaryColor.withValues(alpha: 0.10),
            ),
          ),
        ),
        // Glowing overlay circle middle left
        Positioned(
          top: 280,
          left: -120,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
            ),
          ),
        ),
        // High sigma blur to create the fluid mesh gradient effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
