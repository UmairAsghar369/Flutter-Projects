import 'package:flutter/material.dart';

/// Curated color palette for the app.
class AppColors {
  // ── Primary Gradient ────────────────────────────────
  static const Color primaryStart = Color(0xFF6C63FF); // Vibrant indigo
  static const Color primaryEnd = Color(0xFF3F51B5); // Deep indigo
  static const Color accent = Color(0xFF00BFA6); // Teal accent

  // ── Light Theme ─────────────────────────────────────
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color lightCard = Colors.white;
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightSubText = Color(0xFF6B7280);

  // ── Dark Theme ──────────────────────────────────────
  static const Color darkBg = Color(0xFF0F0F23);
  static const Color darkCard = Color(0xFF1A1A3E);
  static const Color darkText = Color(0xFFF0F0F0);
  static const Color darkSubText = Color(0xFF9CA3AF);

  // ── GPA Colors ──────────────────────────────────────
  static const Color gpaExcellent = Color(0xFF4CAF50); // A range
  static const Color gpaGood = Color(0xFF8BC34A); // B range
  static const Color gpaAverage = Color(0xFFFFC107); // C range
  static const Color gpaPoor = Color(0xFFFF5722); // D-F range

  // ── Gradients ───────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00BFA6), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Get color based on GPA value
  static Color colorForGpa(double gpa) {
    if (gpa >= 3.5) return gpaExcellent;
    if (gpa >= 2.5) return gpaGood;
    if (gpa >= 1.5) return gpaAverage;
    return gpaPoor;
  }
}
