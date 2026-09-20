import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../services/camera_picker_service.dart';
import '../../services/ai_simulation_service.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/accessible_speaker_button.dart';
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
  bool _isSendingOtp = false;

  bool _isPehchanVerified = false;
  String? _pehchanIdCode;
  String? _pehchanDocUrl;
  bool _isVerifyingPehchan = false;

  // ============================================================
  // LOCAL UI ROLE SELECTION
  // ============================================================
  //
  // IMPORTANT:
  // This is ONLY used to control the UI before login.
  //
  // It is NOT used to determine the authenticated user's role.
  //
  // After login, the backend's user.role is authoritative.
  UserRoleType _selectedRole = UserRoleType.artisan;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND OTP
  // ============================================================

  void _handleSendOtp() async {
    final phoneText = _phoneController.text.trim();

    if (phoneText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your mobile number'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      final phone = '+91 $phoneText';

      final res = await ApiService.requestOtp(phone);

      final otpCode = res['debug_otp']?.toString();
      final isSms = res['sms_sent'] == true;

      if (!mounted) return;

      setState(() {
        _isSendingOtp = false;

        // Only auto-fill if backend actually provided
        // a debug OTP.
        if (otpCode != null && otpCode.isNotEmpty) {
          _otpController.text = otpCode;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSms
                ? 'SMS OTP dispatched to $phone via ${res["provider"] ?? "SMS provider"}'
                : otpCode != null
                    ? 'OTP sent to $phone: $otpCode'
                    : 'OTP sent to $phone',
          ),
          backgroundColor: AppTheme.forestGreen,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSendingOtp = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to send OTP: ${e.toString()}',
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ============================================================
  // PEHCHAN ID
  // ============================================================

  void _handleScanPehchanId() async {
    final result = await CameraPickerService.pickOrCaptureImage(
      context,
      title: 'Scan Artisan Pehchan ID',
      isDocumentScan: true,
    );

    if (result == null || !mounted) return;

    setState(() {
      _isVerifyingPehchan = true;
      _pehchanDocUrl = result.imageUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Document captured (${result.sourceDescription ?? "Card"}). '
          'Verifying with Ministry of Textiles...',
        ),
        backgroundColor: AppTheme.forestGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final verifyRes = await ApiService.verifyPehchanId(
        documentUrl: result.imageUrl,
        pehchanId: result.documentId ?? 'ID-ART-8821',
        artisanName: 'Asha Devi',
        phone: '+91 ${_phoneController.text.trim()}',
      );

      if (!mounted) return;

      setState(() {
        _isVerifyingPehchan = false;
        _isPehchanVerified = true;
        _pehchanIdCode =
            verifyRes['pehchan_id']?.toString() ?? 'ID-ART-8821';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.verified,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pehchan Card ($_pehchanIdCode) Verified! '
                  'Craft: Traditional Pottery',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.forestGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isVerifyingPehchan = false;
        _isPehchanVerified = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pehchan ID verification failed: ${e.toString()}',
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ============================================================
  // VOICE HELP
  // ============================================================

  void _handleVoiceHelp() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bhashini Voice Assistant: Listening... '
          'Speak your mobile number.',
        ),
        backgroundColor: AppTheme.forestGreen,
        duration: Duration(seconds: 2),
      ),
    );

    final transcript =
        await AiSimulationService.transcribeVoice(
      languageCode: 'hi',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bhashini Recognized: $transcript',
          ),
          backgroundColor: AppTheme.forestGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ============================================================
  // CONTINUE / LOGIN
  // ============================================================

  Future<void> _handleContinue() async {
    final phone = '+91 ${_phoneController.text.trim()}';
    final otp = _otpController.text.trim();

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your mobile number'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the OTP'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final appState = Provider.of<AppState>(
      context,
      listen: false,
    );

    // ==========================================================
    // IMPORTANT:
    //
    // We DO NOT send _selectedRole to the backend.
    //
    // The backend determines the user's actual role.
    // ==========================================================

    final loginSuccessful = await appState.loginWithOtp(
      phone,
      otp,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    // ==========================================================
    // LOGIN FAILED
    // ==========================================================

    if (!loginSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.authError ?? 'Login failed. Please try again.',
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );

      return;
    }

    // ==========================================================
    // BACKEND ROLE IS NOW AUTHORITATIVE
    // ==========================================================

    final user = appState.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login succeeded but no user information was returned.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );

      return;
    }

    // ==========================================================
    // NAVIGATE USING BACKEND USER ROLE
    // ==========================================================

    switch (user.role) {
      case UserRoleType.artisan:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const ArtisanDashboardScreen(),
          ),
        );
        break;

      case UserRoleType.customer:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const CustomerHomeScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT:
    //
    // We no longer read currentRole from AppState for the
    // pre-login role-selection UI.
    //
    // AppState.currentRole is now the backend-authenticated role.
    final isArtisanSelected =
        _selectedRole == UserRoleType.artisan;

    return Scaffold(
      body: DecorativeBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // ==================================================
              // TOP ROW / ACCESSIBILITY
              // ==================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AccessibleSpeakerButton(
                    textToRead:
                        'कलासेतु में आपका स्वागत है। '
                        'कारीगर या ग्राहक चुनें, अपना मोबाइल नंबर दर्ज करें '
                        'और ओटीपी के माध्यम से सुरक्षित लॉगिन करें।',
                    tooltip:
                        'Listen to welcome instructions via Bhashini',
                    size: 38,
                    glowColor: AppTheme.terracotta,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ==================================================
              // LOGO
              // ==================================================

              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.terracotta,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.terracotta.withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.soup_kitchen,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // BRAND
              // ==================================================

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

              const Text(
                'Crafted by hands. Discovered by hearts.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 32),

              // ==================================================
              // ROLE SELECTION
              // ==================================================

              const Text(
                "I'm joining as",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ARTISAN
                  _buildRoleCircle(
                    title: 'ARTISAN',
                    icon: Icons.gavel_rounded,
                    isSelected: isArtisanSelected,
                    onTap: () {
                      setState(() {
                        _selectedRole =
                            UserRoleType.artisan;
                      });
                    },
                  ),

                  const SizedBox(width: 24),

                  // CUSTOMER
                  _buildRoleCircle(
                    title: 'CUSTOMER',
                    icon: Icons.shopping_cart_outlined,
                    isSelected: !isArtisanSelected,
                    onTap: () {
                      setState(() {
                        _selectedRole =
                            UserRoleType.customer;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==================================================
              // PEHCHAN ID
              // ==================================================

              if (isArtisanSelected) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isPehchanVerified
                        ? const Color(0xFFEFF8F1)
                        : const Color(0xFFFDF7F3),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isPehchanVerified
                          ? const Color(0xFF70B888)
                          : const Color(0xFFE4AE9B),
                      width: 1.3,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isPehchanVerified
                                    ? Icons.verified
                                    : Icons.badge_outlined,
                                color: _isPehchanVerified
                                    ? AppTheme.forestGreen
                                    : AppTheme.terracotta,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Artisan Pehchan ID / Card',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _isPehchanVerified
                                  ? AppTheme.forestGreen
                                  : AppTheme.terracotta,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isPehchanVerified
                                  ? 'VERIFIED'
                                  : 'REQUIRED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _isPehchanVerified
                            ? 'Identity verified: '
                                '${_pehchanIdCode ?? "ID-ART-8821"} '
                                '(Ministry of Textiles, DC Handicrafts)'
                            : 'Upload your Govt. of India Pehchan '
                                'Artisan Card or Aadhaar for priority '
                                'digital verification.',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isPehchanVerified
                              ? AppTheme.forestGreenDark
                              : AppTheme.textMuted,
                          height: 1.3,
                        ),
                      ),

                      if (_isPehchanVerified &&
                          _pehchanDocUrl != null) ...[
                        const SizedBox(height: 8),

                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(8),
                          child: Image.network(
                            ApiService.resolveImageUrl(
                              _pehchanDocUrl,
                            ),
                            height: 50,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, trace) =>
                                    const SizedBox(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: _isVerifyingPehchan
                              ? null
                              : _handleScanPehchanId,
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                _isPehchanVerified
                                    ? AppTheme.forestGreen
                                    : AppTheme.terracotta,
                            side: BorderSide(
                              color: _isPehchanVerified
                                  ? AppTheme.forestGreen
                                  : AppTheme.terracotta,
                              width: 1.2,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isVerifyingPehchan
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _isPehchanVerified
                                      ? Icons
                                          .check_circle_outline
                                      : Icons
                                          .camera_alt_outlined,
                                  size: 18,
                                ),
                          label: Text(
                            _isPehchanVerified
                                ? 'Pehchan ID Verified • '
                                    'Tap to re-scan'
                                : 'Tap to scan Pehchan ID '
                                    'with Camera',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],

              // ==================================================
              // MOBILE NUMBER
              // ==================================================

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mobile number',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleVoiceHelp,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.mic,
                              size: 14,
                              color: AppTheme.forestGreen,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Speak (Bhashini)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.forestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.borderLight,
                        width: 1.2,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.smartphone_outlined,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),

                        const SizedBox(width: 10),

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
                            keyboardType:
                                TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration:
                                const InputDecoration(
                              hintText: '98765 43210',
                              border: InputBorder.none,
                              enabledBorder:
                                  InputBorder.none,
                              focusedBorder:
                                  InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: _isSendingOtp
                                ? null
                                : _handleSendOtp,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.terracotta,
                              foregroundColor:
                                  Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSendingOtp
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Send OTP',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.bold,
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

              // ==================================================
              // OTP
              // ==================================================

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.borderLight,
                        width: 1.2,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
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
                            keyboardType:
                                TextInputType.number,
                            style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 4.0,
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration:
                                const InputDecoration(
                              hintText: '••••••',
                              border: InputBorder.none,
                              enabledBorder:
                                  InputBorder.none,
                              focusedBorder:
                                  InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed: _isSendingOtp
                              ? null
                              : _handleSendOtp,
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

              const SizedBox(height: 28),

              // ==================================================
              // CONTINUE
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppTheme.terracotta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    elevation: 1,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
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

              const SizedBox(height: 22),

              const Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ROLE CIRCLE
  // ============================================================

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
          color: isSelected
              ? AppTheme.terracotta
              : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppTheme.terracotta
                : AppTheme.borderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.terracotta.withValues(
                      alpha: 0.35,
                    )
                  : Colors.black.withValues(
                      alpha: 0.04,
                    ),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : AppTheme.textDark,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? Colors.white
                  : AppTheme.textDark,
            ),
          ],
        ),
      ),
    );
  }
}
