import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Text Colors ──
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);

  // ── Accent Aurora Colors ──
  static const Color accentCold = Color(0xFF38BDF8);
  static const Color accentWarm = Color(0xFFFB923C);
  static const Color accentStorm = Color(0xFFA78BFA);
  static const Color accentNight = Color(0xFF818CF8);

  // ── Card Glass ──
  static const Color cardBackground = Color(0x14FFFFFF);
  static const Color cardBorder = Color(0x20FFFFFF);

  // ── Background Gradients ──
  static const List<Color> clearDayGradient = [
    Color(0xFF0A0E1A),
    Color(0xFF1A1040),
    Color(0xFF0D2137),
  ];

  static const List<Color> rainyGradient = [
    Color(0xFF0A0F1E),
    Color(0xFF1A2744),
    Color(0xFF0E1929),
  ];

  static const List<Color> sunnyGradient = [
    Color(0xFF1A0A00),
    Color(0xFF2D1B00),
    Color(0xFF0F1A2D),
  ];

  static const List<Color> nightGradient = [
    Color(0xFF000510),
    Color(0xFF0A0020),
    Color(0xFF050015),
  ];

  static const List<Color> snowGradient = [
    Color(0xFF0A1520),
    Color(0xFF152535),
    Color(0xFF0D1F30),
  ];

  /// Resolve gradient based on weather code + hour of day
  static List<Color> getBackgroundGradient(int weatherCode, int hour) {
    final isNight = hour < 6 || hour >= 20;
    if (isNight) return nightGradient;

    if ([61, 63, 65, 80, 51, 95, 99].contains(weatherCode)) {
      return rainyGradient;
    }
    if ([71, 73, 75].contains(weatherCode)) return snowGradient;
    if ([0, 1].contains(weatherCode)) {
      return hour >= 10 && hour <= 16 ? sunnyGradient : clearDayGradient;
    }
    return clearDayGradient;
  }

  /// Resolve accent color based on weather code + hour
  static Color getAccentColor(int weatherCode, int hour) {
    final isNight = hour < 6 || hour >= 20;
    if (isNight) return accentNight;
    if ([61, 63, 65, 80, 95, 99].contains(weatherCode)) return accentStorm;
    if ([0, 1].contains(weatherCode) && hour >= 10 && hour <= 16) {
      return accentWarm;
    }
    return accentCold;
  }

  // ── Typography ──
  static TextStyle temperatureDisplay({Color? color}) => GoogleFonts.outfit(
        fontSize: 96,
        fontWeight: FontWeight.w200,
        letterSpacing: -4,
        color: color ?? textPrimary,
      );

  static TextStyle cityName({Color? color}) => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: color ?? textPrimary,
      );

  static TextStyle dataNumber({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color ?? textPrimary,
      );

  static TextStyle label({Color? color}) => GoogleFonts.outfit(
        fontSize: 12,
        letterSpacing: 2,
        fontWeight: FontWeight.w500,
        color: color ?? textSecondary,
      );

  static TextStyle body({Color? color}) => GoogleFonts.outfit(
        fontSize: 15,
        height: 1.6,
        color: color ?? textPrimary,
      );

  static TextStyle subtitle({Color? color}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color ?? textSecondary,
      );

  static TextStyle heading({Color? color}) => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? textPrimary,
      );

  // ── Glass Card Decoration ──
  static BoxDecoration glassCard({
    double borderRadius = 24,
    Color? borderColor,
    Color? bgColor,
  }) {
    return BoxDecoration(
      color: bgColor ?? cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? cardBorder, width: 1),
    );
  }

  static BoxDecoration glassCardWithGlow({
    required Color glowColor,
    double borderRadius = 24,
  }) {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: glowColor.withValues(alpha: 0.4), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.15),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
