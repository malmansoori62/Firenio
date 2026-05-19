import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Core palette
  static const Color background   = Color(0xFF0D1117);
  static const Color surface      = Color(0xFF161B22);
  static const Color surfaceAlt   = Color(0xFF21262D);
  static const Color accent       = Color(0xFFFF6B35);
  static const Color accentGold   = Color(0xFFFFD700);
  static const Color textPrimary  = Color(0xFFF0F6FF);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color conflictRed  = Color(0xFFFF4444);
  static const Color allianceGold = Color(0xFFFFD700);
  static const Color correctGreen = Color(0xFF3FB950);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      surface: surface,
      onPrimary: textPrimary,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: 1.2,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle scoreStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: accentGold,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 13,
    color: textSecondary,
    letterSpacing: 0.6,
  );
}
