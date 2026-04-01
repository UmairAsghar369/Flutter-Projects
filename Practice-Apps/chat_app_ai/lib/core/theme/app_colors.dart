// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Centralized color tokens for AuraAI
class AppColors {
  AppColors._();

  // --- Dark theme ---
  static const Color darkBackground    = Color(0xFF0D0E1A);
  static const Color darkSurface       = Color(0xFF151627);
  static const Color darkCard          = Color(0xFF1C1D32);
  static const Color darkBorder        = Color(0xFF2A2B45);

  static const Color purplePrimary     = Color(0xFF7C5CFC);
  static const Color purpleLight       = Color(0xFF9B82FD);
  static const Color purpleDark        = Color(0xFF5B3EE0);

  static const Color accentBlue        = Color(0xFF4FC3F7);
  static const Color accentGradStart   = Color(0xFF7C5CFC);
  static const Color accentGradEnd     = Color(0xFF4FC3F7);

  static const Color darkTextPrimary   = Color(0xFFF0F0FF);
  static const Color darkTextSecondary = Color(0xFF9395B4);
  static const Color darkTextMuted     = Color(0xFF5A5C7A);

  // --- Light theme ---
  static const Color lightBackground   = Color(0xFFF5F5FF);
  static const Color lightSurface      = Color(0xFFFFFFFF);
  static const Color lightCard         = Color(0xFFEEEEFF);
  static const Color lightBorder       = Color(0xFFDDDDFF);

  static const Color lightPrimary      = Color(0xFF6644EE);
  static const Color lightPrimaryLight = Color(0xFF8866FF);

  static const Color lightTextPrimary  = Color(0xFF0D0E1A);
  static const Color lightTextSecondary= Color(0xFF5A5C7A);
  static const Color lightTextMuted    = Color(0xFF9395B4);

  // --- Shared ---
  static const Color error             = Color(0xFFFF5370);
  static const Color success           = Color(0xFF4CAF50);
  static const Color userBubbleGradStart = Color(0xFF7C5CFC);
  static const Color userBubbleGradEnd   = Color(0xFF4FC3F7);
}
