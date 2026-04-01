import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// A small chip showing a task's category with its associated color.
class CategoryChip extends StatelessWidget {
  /// The category label (e.g., "Work", "Personal").
  final String category;

  /// Creates a [CategoryChip].
  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: AppTextStyles.caption(color: color).copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
