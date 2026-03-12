import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Animated CGPA summary card with circular progress and stats.
class CgpaSummaryCard extends StatelessWidget {
  final double cgpa;
  final int totalCredits;
  final int semesterCount;

  const CgpaSummaryCard({
    super.key,
    required this.cgpa,
    required this.totalCredits,
    required this.semesterCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStart.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your CGPA',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Animated CGPA number
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: cgpa),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                value.toStringAsFixed(2),
                style: theme.textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 52,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          // Scale label
          Text(
            '/ 4.00',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                label: 'Semesters',
                value: semesterCount.toString(),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white24,
              ),
              _StatItem(
                label: 'Credits',
                value: totalCredits.toString(),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white24,
              ),
              _StatItem(
                label: 'Status',
                value: _getStatus(cgpa),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 600.ms);
  }

  String _getStatus(double gpa) {
    if (gpa >= 3.5) return 'Excellent';
    if (gpa >= 3.0) return 'Very Good';
    if (gpa >= 2.5) return 'Good';
    if (gpa >= 2.0) return 'Average';
    if (gpa > 0) return 'Needs Work';
    return '—';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
