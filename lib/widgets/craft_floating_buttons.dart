import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../screens/common/kalasathi_assistant_screen.dart';
import 'active_voice_ripple.dart';

/// Prominent Floating KalaSathi AI Voice Assistant widget.
///
/// Refactored to:
/// 1. Completely remove the bottom-left green tools icon.
/// 2. Make the KalaSathi AI assistant prominently featured throughout the app.
/// 3. Provide smooth concentric ripple wave animation during active/listening state.
/// 4. Maintain responsive spacing on desktop and mobile without covering navigation.
class CraftFloatingButtons extends StatelessWidget {
  const CraftFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isListening = appState.isVoiceAssistantActive;

    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 12),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Semantics(
          label: isListening
              ? 'KalaSathi AI Voice Assistant is actively listening'
              : 'Open KalaSathi AI Voice Assistant',
          button: true,
          child: ActiveVoiceRipple(
            isActive: isListening,
            ringColor: AppTheme.mustardGold,
            minRadius: 30.0,
            maxRadius: 65.0,
            ringCount: 3,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const KalaSathiAssistantScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE08D45), // Warm Mustard Terracotta
                        Color(0xFFC85A32), // KalaSetu Terracotta
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC85A32).withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Active indicator / Sparkle icon
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isListening ? Icons.mic : Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KalaSathi AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            isListening ? 'Listening...' : 'Voice Assistant',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
