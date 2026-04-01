import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// A small badge indicating a task's priority level.
///
/// Displays "High", "Medium", or "Low" with corresponding color coding.
class PriorityBadge extends StatelessWidget {
  /// Priority value: 1 = Low, 2 = Medium, 3 = High.
  final int priority;

  /// Creates a [PriorityBadge].
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (priority) {
      case 3:
        label = 'High';
        color = AppColors.priorityHigh;
        break;
      case 2:
        label = 'Medium';
        color = AppColors.priorityMedium;
        break;
      default:
        label = 'Low';
        color = AppColors.priorityLow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: color).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
