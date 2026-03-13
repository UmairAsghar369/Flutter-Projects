import 'package:flutter/material.dart';

/// App-wide theme configuration using Material 3.
class AppTheme {
  // ─── Professional CV palette ───
  static const Color proPrimary = Color(0xFF1A237E); // Deep indigo
  static const Color proSecondary = Color(0xFF283593);
  static const Color proAccent = Color(0xFF448AFF);
  static const Color proSurface = Color(0xFFF5F7FA);
  static const Color proCardBg = Colors.white;

  // ─── Hobby CV palette ───
  static const Color hobbyPrimary = Color(0xFF00695C); // Teal
  static const Color hobbySecondary = Color(0xFF00897B);
  static const Color hobbyAccent = Color(0xFF26A69A);
  static const Color hobbySurface = Color(0xFFF0F9F7);
  static const Color hobbyCardBg = Colors.white;

  // ─── Shared ───
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);
  static const Color dividerColor = Color(0xFFE0E0E0);

  /// Professional CV gradient.
  static const LinearGradient proGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
  );

  /// Hobby CV gradient.
  static const LinearGradient hobbyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00695C), Color(0xFF00897B), Color(0xFF4DB6AC)],
  );

  /// Material 3 ThemeData for the app.
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: proPrimary,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: proSurface,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
