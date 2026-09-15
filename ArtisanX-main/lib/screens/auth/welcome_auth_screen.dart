import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/decorative_background.dart';
import '../artisan/artisan_dashboard_screen.dart';
import '../customer/customer_home_screen.dart';

class WelcomeAuthScreen extends StatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen> {
  final TextEditingController _phoneController = TextEditingController(
    text: '98765 43210',
  );
  final TextEditingController _otpController = TextEditingController(
    text: '123456',
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    final appState = Provider.of<AppState>(context, listen: false);

    setState(() => _isLoading = true);

    await appState.loginWithOtp(
      '+91 ${_phoneController.text.trim()}',
      _otpController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (appState.isArtisan) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ArtisanDashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isArtisanSelected = appState.currentRole == UserRoleType.artisan;

    return Scaffold(
      body: DecorativeBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Logo: Terracotta Pot in rounded container
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.terracotta,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.terracotta.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.soup_kitchen, // Decorative handicraft vase silhouette
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Brand Title
              const Text(
                'Kalasetu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 6),

              // Tagline
              const Text(
                'Crafted by hands. Discovered by hearts.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 36),

              // "I'm joining as"
              const Text(
                "I'm joining as",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 18),

              // Big Circular Role Selection Cards (Artisan vs Customer)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ARTISAN BUTTON
                  _buildRoleCircle(
                    title: 'ARTISAN',
                    icon: Icons.gavel_rounded,
                    isSelected: isArtisanSelected,
                    onTap: () => appState.setRole(UserRoleType.artisan),
                  ),
                  const SizedBox(width: 24),
                  // CUSTOMER BUTTON
                  _buildRoleCircle(
                    title: 'CUSTOMER',
                    icon: Icons.shopping_cart_outlined,
                    isSelected: !isArtisanSelected,
                    onTap: () => appState.setRole(UserRoleType.customer),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Mobile Number Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mobile number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.borderLight,
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.smartphone_outlined,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '+91 ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: '98765 43210',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // One-Time Password (OTP) Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'One-time password',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.borderLight,
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _otpController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 4.0,
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: '••••••',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('OTP resent: 123456 (demo code)'),
                                duration: Duration(milliseconds: 1500),
                              ),
                            );
                          },
                          child: const Text(
                            'Resend',
                            style: TextStyle(
                              color: AppTheme.terracotta,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Primary "Continue securely" button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.terracotta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Text(
                          'Continue securely',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Terms & Privacy Policy footer
              const Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCircle({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.terracotta : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.terracotta : AppTheme.borderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.terracotta.withOpacity(0.35)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppTheme.textDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : AppTheme.textDark,
            ),
          ],
        ),
      ),
    );
  }
}
