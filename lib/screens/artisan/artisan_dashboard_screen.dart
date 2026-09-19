import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/camera_picker_service.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/craft_floating_buttons.dart';
import '../../widgets/accessible_speaker_button.dart';
import 'ai_product_upload_screen.dart';
import '../customer/customer_home_screen.dart';

class ArtisanDashboardScreen extends StatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  State<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends State<ArtisanDashboardScreen> {
  int _navIndex = 0;
  Map<String, dynamic>? _liveStats;

  @override
  void initState() {
    super.initState();
    _loadLiveStats();
  }

  void _loadLiveStats() async {
    final stats = await ApiService.fetchArtisanStats();
    if (mounted && stats != null) {
      setState(() => _liveStats = stats);
    }
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    if (index == 2) {
      // Add (+) button -> navigate to AI Product Upload
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AiProductUploadScreen()),
      );
    } else if (index == 4) {
      // Profile / Switch to Customer store
      _showSwitchRoleDialog();
    }
  }

  void _showSwitchRoleDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final appState = Provider.of<AppState>(context, listen: false);
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.forestGreen,
                    child: const Text(
                      'A',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.currentUser?.name ?? 'Asha Devi',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Master Potter • Sanganer, Jaipur',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppTheme.forestGreen,
                ),
                title: const Text('Update Profile Picture'),
                subtitle: const Text('Take photo with camera or choose from gallery'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  Navigator.of(context).pop();
                  final result = await CameraPickerService.pickOrCaptureImage(
                    context,
                    title: 'Update Artisan Profile Photo',
                  );
                  if (result != null) {
                    await ApiService.updateArtisanAvatar(result.imageUrl);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile photo updated successfully!'),
                          backgroundColor: AppTheme.forestGreen,
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.storefront_outlined,
                  color: AppTheme.terracotta,
                ),
                title: const Text('Switch to Customer Marketplace'),
                subtitle: const Text('Browse craft collections as a buyer'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  appState.setRole(UserRoleType.customer);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const CustomerHomeScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.language,
                  color: AppTheme.forestGreen,
                ),
                title: const Text('Bhashini Language: हिन्दी'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final orders = appState.orders;

    return Scaffold(
      body: DecorativeBackground(
        child: Column(
          children: [
            // Top App Bar matching Figma
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar 'A'
                  GestureDetector(
                    onTap: _showSwitchRoleDialog,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppTheme.forestGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Title: My Workshop
                  const Text(
                    'My Workshop',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreenDark,
                    ),
                  ),

                  // Actions: Accessible Speaker Button + Notification Bell with Badge
                  Row(
                    children: [
                      AccessibleSpeakerButton(
                        textToRead:
                            'नमस्ते आशा जी! आपके कुल ${appState.allProducts.length} उत्पाद हैं, ${orders.length} ऑर्डर मिले हैं और ₹42,800 की कमाई हुई है।',
                        tooltip: 'Listen to workshop overview via Bhashini',
                        size: 38,
                        glowColor: AppTheme.forestGreen,
                      ),
                      const SizedBox(width: 8),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              size: 24,
                            ),
                            color: AppTheme.textDark,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You have ${orders.length} orders in your workshop dashboard!',
                                  ),
                                  duration: const Duration(milliseconds: 1500),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            right: 12,
                            top: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.terracotta,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Scrollable Dashboard Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    // Greeting
                    const Text(
                      'Namaste, Asha ji',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.forestGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Heading: Your craft is growing!!
                    const Text(
                      'Your craft is growing!!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forestGreenDark,
                        letterSpacing: 0.1,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 3 Metric Cards Row (Total products, Orders, Earnings)
                    Row(
                      children: [
                        // Card 1: Total products
                        Expanded(
                          child: _buildMetricCard(
                            value: _liveStats?['total_products']?.toString() ??
                                '${appState.allProducts.length}',
                            label: 'Total products',
                            icon: Icons.soup_kitchen_outlined,
                            iconColor: AppTheme.terracotta,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Card 2: Orders
                        Expanded(
                          child: _buildMetricCard(
                            value: _liveStats?['total_orders']?.toString() ??
                                '${orders.length}',
                            label: 'Orders',
                            icon: Icons.inventory_2_outlined,
                            iconColor: AppTheme.forestGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Card 3: Earnings
                        Expanded(
                          child: _buildMetricCard(
                            value: _liveStats != null
                                ? '₹${(_liveStats!['total_revenue'] as num).toStringAsFixed(0)}'
                                : '₹42.8k',
                            label: 'Earnings',
                            icon: Icons.currency_rupee,
                            iconColor: AppTheme.mustardGold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Primary Action Bar: [+ Add new product] (Clean CTA without speaker icon)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AiProductUploadScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.forestGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 1,
                        ),
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 20,
                        ),
                        label: const Text(
                          'Add new product',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Recent Orders Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent orders',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Showing all 18 fulfilled & pending orders',
                                ),
                                duration: Duration(milliseconds: 1200),
                              ),
                            );
                          },
                          child: const Text(
                            'View all',
                            style: TextStyle(
                              color: AppTheme.terracotta,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Order Cards List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.productName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order.orderCode} • ₹${order.totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              StatusBadge(status: order.status),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Craft & AI Floating Action Buttons
            const CraftFloatingButtons(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        isArtisan: true,
      ),
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
