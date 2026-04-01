import 'package:flutter/material.dart';

/// Centralized color palette for the TaskFlow application.
///
/// Provides brand colors, surface colors for light/dark themes,
/// category colors, and priority-level colors.
class AppColors {
  AppColors._();

  // ── Primary Brand ──────────────────────────────────────────────
  /// Soft violet – main brand color.
  static const Color primary = Color(0xFF6C63FF);

  /// Lighter variant of the primary color.
  static const Color primaryLight = Color(0xFF8B85FF);

  /// Darker variant of the primary color.
  static const Color primaryDark = Color(0xFF4B44CC);

  // ── Accents ────────────────────────────────────────────────────
  /// Mint teal accent.
  static const Color accent = Color(0xFF00D4AA);

  /// Coral red – used for high-priority indicators.
  static const Color accentWarm = Color(0xFFFF6B6B);

  /// Warm amber – used for medium-priority indicators.
  static const Color accentAmber = Color(0xFFFFB347);

  /// Success green – used for low-priority and completed indicators.
  static const Color accentGreen = Color(0xFF4CAF50);

  // ── Light Theme Surfaces ───────────────────────────────────────
  /// Soft lavender-white background.
  static const Color lightBackground = Color(0xFFF5F4FF);

  /// Pure white surface.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Card background for light mode.
  static const Color lightCard = Color(0xFFFFFFFF);

  /// Border color for light mode.
  static const Color lightBorder = Color(0xFFE8E6FF);

  // ── Dark Theme Surfaces ────────────────────────────────────────
  /// Deep dark violet background.
  static const Color darkBackground = Color(0xFF0F0E1A);

  /// Dark surface.
  static const Color darkSurface = Color(0xFF1A1830);

  /// Card background for dark mode.
  static const Color darkCard = Color(0xFF211F38);

  /// Border color for dark mode.
  static const Color darkBorder = Color(0xFF2E2B50);

  // ── Text ───────────────────────────────────────────────────────
  /// Primary text color for light mode.
  static const Color textPrimaryLight = Color(0xFF1A1830);

  /// Secondary text color for light mode.
  static const Color textSecondaryLight = Color(0xFF6B6B8A);

  /// Primary text color for dark mode.
  static const Color textPrimaryDark = Color(0xFFF0EEFF);

  /// Secondary text color for dark mode.
  static const Color textSecondaryDark = Color(0xFF9B99B8);

  // ── Category Colors ────────────────────────────────────────────
  /// Color for the Work category.
  static const Color catWork = Color(0xFF6C63FF);

  /// Color for the Personal category.
  static const Color catPersonal = Color(0xFFFF6B9D);

  /// Color for the Health category.
  static const Color catHealth = Color(0xFF4CAF50);

  /// Color for the Study category.
  static const Color catStudy = Color(0xFFFFB347);

  /// Color for the Other category.
  static const Color catOther = Color(0xFF00D4AA);

  // ── Priority Colors ────────────────────────────────────────────
  /// High priority – coral red.
  static const Color priorityHigh = Color(0xFFFF6B6B);

  /// Medium priority – warm amber.
  static const Color priorityMedium = Color(0xFFFFB347);

  /// Low priority – success green.
  static const Color priorityLow = Color(0xFF4CAF50);

  /// Returns the [Color] for a given [category] name.
  static Color categoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'work':
        return catWork;
      case 'personal':
        return catPersonal;
      case 'health':
        return catHealth;
      case 'study':
        return catStudy;
      default:
        return catOther;
    }
  }

  /// Returns the [Color] for a given priority level [value].
  ///
  /// 1 = Low, 2 = Medium, 3 = High.
  static Color priorityColor(int? value) {
    switch (value) {
      case 3:
        return priorityHigh;
      case 2:
        return priorityMedium;
      default:
        return priorityLow;
    }
  }
}
