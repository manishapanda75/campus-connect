import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C8FFF);
  static const Color secondary = Color(0xFF00D9A5);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFD93D);

  static const Color bgDark = Color(0xFF0D0E1A);
  static const Color bgCard = Color(0xFF161829);
  static const Color bgCardLight = Color(0xFF1E2035);
  static const Color surface = Color(0xFF252743);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B3C6);
  static const Color textMuted = Color(0xFF6B6F8A);

  static const Color divider = Color(0xFF2A2D45);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: bgCard,
        error: accent,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
              displayLarge: const TextStyle(
                color: textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
              displayMedium: const TextStyle(
                color: textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              headlineLarge: const TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              headlineMedium: const TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              bodyLarge: const TextStyle(
                color: textPrimary,
                fontSize: 16,
              ),
              bodyMedium: const TextStyle(
                color: textSecondary,
                fontSize: 14,
              ),
              bodySmall: const TextStyle(
                color: textMuted,
                fontSize: 12,
              ),
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: const CardTheme(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: textSecondary),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
