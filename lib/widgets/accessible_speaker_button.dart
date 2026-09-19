import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Standard AccessibleSpeakerButton with subtle "GLOW PULSE" animation.
///
/// Features:
/// - Bold, prominent speaker icon ([Icons.volume_up_rounded]).
/// - Continuously pulsing radial glow around the container without moving the icon.
/// - Clear, high-contrast visual styling matching the KalaSetu design system.
/// - Screen-reader / keyboard accessibility support via [Semantics] and [Tooltip].
/// - Displays Bhashini Voice TTS feedback when clicked, or triggers [onSpeak].
class AccessibleSpeakerButton extends StatefulWidget {
  final String textToRead;
  final String? tooltip;
  final VoidCallback? onSpeak;
  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final Color glowColor;

  const AccessibleSpeakerButton({
    super.key,
    required this.textToRead,
    this.tooltip = 'Listen via Bhashini Voice TTS',
    this.onSpeak,
    this.size = 44.0,
    this.iconColor = AppTheme.terracotta,
    this.backgroundColor = Colors.white,
    this.glowColor = const Color(0xFFC85A32),
  });

  @override
  State<AccessibleSpeakerButton> createState() =>
      _AccessibleSpeakerButtonState();
}

class _AccessibleSpeakerButtonState extends State<AccessibleSpeakerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onSpeak != null) {
      widget.onSpeak!();
      return;
    }

    setState(() => _isSpeaking = true);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppTheme.forestGreen,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bhashini Text-to-Speech (Hindi/English)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.textToRead,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: widget.tooltip ?? 'Read content aloud',
      button: true,
      child: Tooltip(
        message: widget.tooltip ?? 'Read content aloud',
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            final glowValue =
                disableAnimations ? 0.4 : _glowAnimation.value;
            final spread = 2.0 + (glowValue * 6.0);
            final blur = 6.0 + (glowValue * 10.0);
            final glowOpacity = (0.2 + (glowValue * 0.45)).clamp(0.0, 1.0);

            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.backgroundColor,
                boxShadow: [
                  // Subtle ambient shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                  // Gentle pulsing accessibility glow
                  BoxShadow(
                    color: widget.glowColor.withOpacity(glowOpacity),
                    blurRadius: blur,
                    spreadRadius: spread,
                  ),
                ],
                border: Border.all(
                  color: widget.glowColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _handleTap,
                  child: Center(
                    child: Icon(
                      _isSpeaking
                          ? Icons.volume_up_rounded
                          : Icons.volume_up_outlined,
                      color: widget.iconColor,
                      size: widget.size * 0.54,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
