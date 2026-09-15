import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../screens/common/kalasathi_assistant_screen.dart';

class CraftFloatingButtons extends StatelessWidget {
  final VoidCallback? onCraftAction;

  const CraftFloatingButtons({super.key, this.onCraftAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left craft tool button (Deep forest green)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap:
                  onCraftAction ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('KalaSetu Craft Heritage Studio active'),
                        duration: Duration(milliseconds: 1200),
                      ),
                    );
                  },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestGreen.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.handyman_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

          // Right AI sparkle button (Mustard Gold) -> Launches KalaSathi
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const KalaSathiAssistantScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.mustardGold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mustardGold.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
