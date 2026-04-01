import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/subtask.dart';
import '../models/task.dart';
import 'priority_badge.dart';
import 'category_chip.dart';
import 'animated_checkbox.dart';

/// A richly styled card displaying a [Task] with its metadata.
///
/// Shows the task title, due time, priority badge, category chip,
/// subtask progress, and a completion checkbox.
class TaskCard extends StatefulWidget {
  /// The task to display.
  final Task task;

  /// Subtasks associated with this task.
  final List<Subtask> subtasks;

  /// Called when the completion checkbox is tapped.
  final VoidCallback? onToggleComplete;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Called when a subtask checkbox is toggled.
  final void Function(int subtaskId)? onToggleSubtask;

  /// Creates a [TaskCard].
  const TaskCard({
    super.key,
    required this.task,
    this.subtasks = const [],
    this.onToggleComplete,
    this.onTap,
    this.onToggleSubtask,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedCount =
        widget.subtasks.where((s) => s.isCompleted).length;
    final totalCount = widget.subtasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: checkbox + title + badges ──
                Row(
                  children: [
                    AnimatedCheckbox(
                      value: widget.task.isCompleted,
                      onChanged: widget.onToggleComplete,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.task.title,
                        style: AppTextStyles.h3(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ).copyWith(
                          decoration: widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.accentGreen,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PriorityBadge(priority: widget.task.priority),
                  ],
                ),
                const SizedBox(height: 8),
                // ── Due time + category ──
                Row(
                  children: [
                    if (widget.task.dueTime != null) ...[
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.task.dueTime!,
                        style: AppTextStyles.caption(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (widget.task.category != null)
                      CategoryChip(category: widget.task.category!),
                  ],
                ),
                // ── Subtask progress ──
                if (totalCount > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          builder: (context, value, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.accent,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          '$completedCount/$totalCount · ${(progress * 100).round()}%',
                          key: ValueKey('$completedCount/$totalCount'),
                          style: AppTextStyles.caption(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
