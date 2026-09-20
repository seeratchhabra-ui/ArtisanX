import 'package:flutter/material.dart';

class AppTheme {
  // Brand Color Palette (Indian Artisan Handicraft Theme)
  static const Color terracotta = Color(0xFFA34828);
  static const Color terracottaDark = Color(0xFF83381E);
  static const Color terracottaLight = Color(0xFFFDECE7);

  static const Color forestGreen = Color(0xFF265337);
  static const Color forestGreenDark = Color(0xFF1B3D28);
  static const Color sageGreen = Color(0xFFEBF6EE);

  static const Color mustardGold = Color(0xFFD49B35);
  static const Color goldLight = Color(0xFFFEF7E6);

  static const Color navyIndigo = Color(0xFF1E3A5F);
  static const Color navyDark = Color(0xFF142740);

  static const Color creamBg = Color(0xFFFAF7F2);
  static const Color surfaceWarm = Color(0xFFF4EFEA);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF232323);
  static const Color textMuted = Color(0xFF7A7570);
  static const Color textLight = Color(0xFFA5A09A);
  static const Color borderLight = Color(0xFFEBE4DC);

  // Status Colors
  static const Color statusReadyToShip = Color(0xFFE05A36);
  static const Color statusProcessing = Color(0xFFC48624);
  static const Color statusDelivered = Color(0xFF2E854B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamBg,
      primaryColor: terracotta,
      colorScheme: const ColorScheme.light(
        primary: terracotta,
        secondary: forestGreen,
        tertiary: mustardGold,
        surface: pureWhite,
        onPrimary: pureWhite,
        onSecondary: pureWhite,
        onSurface: textDark,
      ),
      fontFamily: 'Roboto', // Default fallback font with rich typography
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: terracotta, width: 1.8),
        ),
        hintStyle: const TextStyle(color: textLight, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
