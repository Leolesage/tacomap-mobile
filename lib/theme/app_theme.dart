import 'package:flutter/material.dart';

class AppTheme {
  // Web color palette
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color dark = Color(0xFF1A202C);
  static const Color surface = Color(0xFFF7FAFC);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF48BB78);
  static const Color danger = Color(0xFFFC8181);
  static const Color navy = Color(0xFF12175E);

  static ThemeData theme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: navy,
      surface: surface,
      error: danger,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: dark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: navy,
          letterSpacing: 0.3,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: textMuted),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.w600),
        floatingLabelStyle: const TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        shadowColor: Colors.black12,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      useMaterial3: true,
    );
  }
}
