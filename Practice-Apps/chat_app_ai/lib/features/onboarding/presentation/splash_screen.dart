// lib/features/onboarding/presentation/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated glowing orb logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [AppColors.purpleLight, AppColors.purpleDark],
                  radius: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purplePrimary.withValues(alpha: 0.6),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 52,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.92, end: 1.0, duration: 1200.ms, curve: Curves.easeInOut)
                .then()
                .animate()
                .fadeIn(duration: 600.ms)
                .scaleXY(begin: 0.6, end: 1.0, curve: Curves.easeOutBack),

            const SizedBox(height: 28),

            Text(
              'AuraAI',
              style: GoogleFonts.poppins(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 10),

            Text(
              'Powered by Gemini',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.darkTextSecondary,
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms),

            const SizedBox(height: 80),

            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.purplePrimary.withValues(alpha: 0.7),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
