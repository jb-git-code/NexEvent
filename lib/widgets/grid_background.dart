import 'package:flutter/material.dart';

class GridDotBackground extends StatelessWidget {
  final Widget child;

  const GridDotBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid pattern layer
        Positioned.fill(
          child: CustomPaint(
            painter: GridDotPainter(),
          ),
        ),
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

class GridDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.5;

    const double spacing = 22.0;

    for (double x = 11.0; x < size.width; x += spacing) {
      for (double y = 11.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
