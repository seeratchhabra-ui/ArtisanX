import 'package:flutter/material.dart';

/// Renders a subtle organic craft background with delicate botanical / watermark patterns
class DecorativeBackground extends StatelessWidget {
  final Widget child;

  const DecorativeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid base color
        Container(color: const Color(0xFFFAF7F2)),

        // Custom painter for subtle botanical curves and Rangoli watermark motifs
        Positioned.fill(
          child: CustomPaint(painter: _ArtisanWatermarkPainter()),
        ),

        // Foreground content
        SafeArea(child: child),
      ],
    );
  }
}

class _ArtisanWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E0D2).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Top-right botanical spray
    final path1 = Path();
    path1.moveTo(size.width * 0.75, 0);
    path1.quadraticBezierTo(size.width * 0.85, 80, size.width, 120);
    path1.moveTo(size.width * 0.82, 40);
    path1.quadraticBezierTo(size.width * 0.95, 50, size.width, 30);
    path1.moveTo(size.width * 0.78, 20);
    path1.quadraticBezierTo(size.width * 0.90, 15, size.width, 10);
    canvas.drawPath(path1, paint);

    // Bottom-left earthy clay vase motif outline
    final path2 = Path();
    path2.moveTo(0, size.height * 0.70);
    path2.cubicTo(
      size.width * 0.35,
      size.height * 0.75,
      size.width * 0.25,
      size.height * 0.90,
      0,
      size.height * 0.95,
    );
    canvas.drawPath(path2, paint);

    // Subtle rangoli circle accents
    final dotPaint = Paint()
      ..color = const Color(0xFFDED5C3).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.18),
      3,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.45),
      2.5,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.65),
      3,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
