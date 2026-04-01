import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/subtask.dart';

/// A list tile for an individual [Subtask] with a checkbox.
class SubtaskTile extends StatelessWidget {
  /// The subtask to display.
  final Subtask subtask;

  /// Called when the checkbox is toggled.
  final VoidCallback? onToggle;

  /// Called when the delete button is pressed.
  final VoidCallback? onDelete;

  /// Creates a [SubtaskTile].
  const SubtaskTile({
    super.key,
    required this.subtask,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: subtask.isCompleted
                    ? AppColors.accentGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: subtask.isCompleted
                      ? AppColors.accentGreen
                      : isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                  width: 1.5,
                ),
              ),
              child: subtask.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              subtask.title,
              style: AppTextStyles.body(
                color: subtask.isCompleted
                    ? (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight)
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ).copyWith(
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
