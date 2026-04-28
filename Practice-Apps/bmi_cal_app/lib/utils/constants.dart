import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0E21);
  static const Color cardDark = Color(0xFF1D1E33);
  static const Color cardLight = Color(0xFF262A4E);
  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color accentBlue = Color(0xFF448AFF);
  static const Color accentCyan = Color(0xFF18FFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8D8E98);
  static const Color sliderActive = Color(0xFF7C4DFF);
  static const Color sliderInactive = Color(0xFF2C2F4A);

  // BMI Category colors
  static const Color underweight = Color(0xFF42A5F5);
  static const Color normal = Color(0xFF66BB6A);
  static const Color overweight = Color(0xFFFFCA28);
  static const Color obese = Color(0xFFEF5350);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPurple, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E21), Color(0xFF151A3A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gaugeGradient = LinearGradient(
    colors: [underweight, normal, overweight, obese],
  );
}

class BMICategory {
  final String label;
  final String emoji;
  final Color color;
  final String description;

  const BMICategory({
    required this.label,
    required this.emoji,
    required this.color,
    required this.description,
  });

  static BMICategory fromBMI(double bmi) {
    if (bmi < 18.5) {
      return const BMICategory(
        label: 'Underweight',
        emoji: '🔵',
        color: AppColors.underweight,
        description: 'You are below normal weight. Consider a balanced diet with more calories.',
      );
    } else if (bmi < 25) {
      return const BMICategory(
        label: 'Normal',
        emoji: '🟢',
        color: AppColors.normal,
        description: 'Great! You have a healthy body weight. Keep it up!',
      );
    } else if (bmi < 30) {
      return const BMICategory(
        label: 'Overweight',
        emoji: '🟡',
        color: AppColors.overweight,
        description: 'You are above normal weight. Consider exercise and dietary changes.',
      );
    } else {
      return const BMICategory(
        label: 'Obese',
        emoji: '🔴',
        color: AppColors.obese,
        description: 'You are well above normal weight. Please consult a healthcare professional.',
      );
    }
  }
}
