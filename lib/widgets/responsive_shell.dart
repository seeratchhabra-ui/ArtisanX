import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/user_model.dart';
import '../screens/artisan/artisan_dashboard_screen.dart';
import '../screens/customer/customer_home_screen.dart';
import '../screens/common/kalasathi_assistant_screen.dart';

class ResponsiveShell extends StatelessWidget {
  final Widget child;

  const ResponsiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width > 550;

    if (!isDesktop) {
      return child;
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFFEFE9E0,
      ), // Elegant neutral exhibition backdrop
      body: Stack(
        children: [
          // Background title & branding for Desktop Presenters
          Positioned(
            top: 24,
            left: 36,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.terracotta,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.soup_kitchen,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KalaSetu (ArtisanX)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Interactive Prototype • Figma 390×844 Mobile View',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Navigation Pills (Top Right)
          Positioned(
            top: 24,
            right: 36,
            child: Consumer<AppState>(
              builder: (context, appState, _) {
                return Row(
                  children: [
                    _buildPillButton(
                      context,
                      label: 'Artisan Workshop',
                      icon: Icons.gavel,
                      isActive: appState.isArtisan,
                      onTap: () {
                        appState.setRole(UserRoleType.artisan);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                const ArtisanDashboardScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildPillButton(
                      context,
                      label: 'Customer Store',
                      icon: Icons.shopping_bag_outlined,
                      isActive: appState.isCustomer,
                      onTap: () {
                        appState.setRole(UserRoleType.customer);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const CustomerHomeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildPillButton(
                      context,
                      label: 'KalaSathi AI',
                      icon: Icons.auto_awesome,
                      isActive: false,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const KalaSathiAssistantScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // Centered Smartphone Mockup Frame (390 x 844 exact Figma dimensions)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Container(
                width: 390,
                height: 844,
                decoration: BoxDecoration(
                  color: AppTheme.creamBg,
                  borderRadius: BorderRadius.circular(42),
                  border: Border.all(color: const Color(0xFF282522), width: 10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 36,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      child,

                      // Top Phone Status Bar (9:41, WiFi, Battery) matching Figma
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '9:41',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.wifi,
                                    size: 14,
                                    color: AppTheme.textDark,
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.battery_full,
                                    size: 14,
                                    color: AppTheme.textDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.terracotta : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.terracotta : AppTheme.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppTheme.textDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
