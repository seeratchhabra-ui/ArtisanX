import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isArtisan;
  final int cartCount;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isArtisan = false,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderLight.withOpacity(0.8),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: isArtisan ? _buildArtisanItems() : _buildCustomerItems(),
        ),
      ),
    );
  }

  List<Widget> _buildArtisanItems() {
    return [
      _buildNavItem(
        index: 0,
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
      ),
      _buildNavItem(
        index: 1,
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        label: 'Products',
      ),
      _buildNavItem(
        index: 2,
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: 'Add',
      ),
      _buildNavItem(
        index: 3,
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Orders',
      ),
      _buildNavItem(
        index: 4,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
    ];
  }

  List<Widget> _buildCustomerItems() {
    return [
      _buildNavItem(
        index: 0,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      _buildNavItem(
        index: 1,
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: 'Search',
      ),
      _buildNavItem(
        index: 2,
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag,
        label: 'Cart',
        badgeCount: cartCount,
      ),
      _buildNavItem(
        index: 3,
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Orders',
      ),
      _buildNavItem(
        index: 4,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
    ];
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppTheme.terracotta : AppTheme.textMuted;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(isSelected ? activeIcon : icon, color: color, size: 22),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.terracotta,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
