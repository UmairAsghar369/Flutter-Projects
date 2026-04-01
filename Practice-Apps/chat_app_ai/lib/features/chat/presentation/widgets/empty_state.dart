// lib/features/chat/presentation/widgets/empty_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.onPromptSelected});

  final void Function(String prompt) onPromptSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.purplePrimary, AppColors.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purplePrimary.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 40),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.95, end: 1.0, duration: 1800.ms)
                .then()
                .animate()
                .fadeIn(duration: 700.ms)
                .scaleXY(begin: 0.6, end: 1.0, curve: Curves.easeOutBack),

            const Gap(20),

            Text(
              'How can I help you?',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0),

            const Gap(8),

            Text(
              'Ask me anything — I\'m powered by Gemini.',
              style: GoogleFonts.poppins(fontSize: 14, color: textSec),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 600.ms),

            const Gap(36),

            // Starter prompt chips
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: AppConstants.starterPrompts.asMap().entries.map((entry) {
                final i = entry.key;
                final prompt = entry.value;
                return _PromptChip(
                  prompt: prompt,
                  delay: Duration(milliseconds: 400 + i * 80),
                  onTap: () => onPromptSelected(prompt),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptChip extends StatefulWidget {
  const _PromptChip({
    required this.prompt,
    required this.delay,
    required this.onTap,
  });

  final String prompt;
  final Duration delay;
  final VoidCallback onTap;

  @override
  State<_PromptChip> createState() => _PromptChipState();
}

class _PromptChipState extends State<_PromptChip> {
  final bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.purplePrimary.withValues(alpha: 0.15) : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered ? AppColors.purplePrimary : border,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.purplePrimary.withValues(alpha: 0.15),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: Text(
          widget.prompt,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: _hovered ? AppColors.purpleLight : textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: widget.delay, duration: 500.ms)
        .scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOut);
  }
}
