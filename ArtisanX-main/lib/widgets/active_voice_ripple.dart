import 'package:flutter/material.dart';

/// Reusable ActiveVoiceRipple widget.
///
/// When [isActive] is true:
/// - Staggered concentric circular rings expand outward from the stationary central child.
/// - Rings gradually fade as they expand.
/// - Animation continuously loops smoothly.
/// When [isActive] is false:
/// - The animation stops and rings disappear immediately.
/// - Respects system accessibility reduced-motion settings.
class ActiveVoiceRipple extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color ringColor;
  final double minRadius;
  final double maxRadius;
  final int ringCount;
  final Duration duration;

  const ActiveVoiceRipple({
    super.key,
    required this.child,
    required this.isActive,
    this.ringColor = const Color(0xFFD4A373),
    this.minRadius = 28.0,
    this.maxRadius = 58.0,
    this.ringCount = 3,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<ActiveVoiceRipple> createState() => _ActiveVoiceRippleState();
}

class _ActiveVoiceRippleState extends State<ActiveVoiceRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ActiveVoiceRipple oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    if (!widget.isActive || disableAnimations) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RipplePainter(
            progress: _controller.value,
            color: widget.ringColor,
            minRadius: widget.minRadius,
            maxRadius: widget.maxRadius,
            ringCount: widget.ringCount,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double minRadius;
  final double maxRadius;
  final int ringCount;

  _RipplePainter({
    required this.progress,
    required this.color,
    required this.minRadius,
    required this.maxRadius,
    required this.ringCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < ringCount; i++) {
      // Stagger the ring progress
      final ringProgress = (progress + (i / ringCount)) % 1.0;
      final radius = minRadius + (maxRadius - minRadius) * ringProgress;

      // Opacity fades out towards the perimeter
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0);
      final alpha = (opacity * 0.45).clamp(0.0, 1.0);

      // Ring stroke
      final strokePaint = Paint()
        ..color = color.withOpacity(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (2.0 * (1.0 - ringProgress * 0.4)).clamp(1.0, 2.5);

      canvas.drawCircle(center, radius, strokePaint);

      // Subtle translucent fill
      final fillPaint = Paint()
        ..color = color.withOpacity(alpha * 0.15)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.minRadius != minRadius ||
        oldDelegate.maxRadius != maxRadius ||
        oldDelegate.ringCount != ringCount;
  }
}
