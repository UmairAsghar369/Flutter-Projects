import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state_widget.dart';
import 'add_edit_task_screen.dart';

/// Displays all repeating tasks with day-of-week pills.
///
/// Long-press opens a context menu with a "Reset for Today" option.
class RepeatedTasksScreen extends StatelessWidget {
  /// Creates a [RepeatedTasksScreen].
  const RepeatedTasksScreen({super.key});

  static const List<String> _dayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final tasks = provider.repeatingTasks;

        if (tasks.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.repeat_rounded,
            title: 'No repeated tasks',
            subtitle: 'Create a repeating task to see it here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;

            // Parse active days
            List<int> activeDays = [];
            if (task.repeatType == 'daily') {
              activeDays = [1, 2, 3, 4, 5, 6, 7];
            } else if (task.repeatDays != null &&
                task.repeatDays!.isNotEmpty) {
              activeDays = task.repeatDays!
                  .split(',')
                  .map((d) => int.tryParse(d.trim()))
                  .whereType<int>()
                  .toList();
            }

            // Calculate next occurrence
            String nextOccurrence = _getNextOccurrence(activeDays);

            return GestureDetector(
              onLongPress: () {
                _showContextMenu(context, provider, task.id!);
              },
              child: Column(
                children: [
                  TaskCard(
                    task: task,
                    subtasks: provider.subtasksFor(task.id!),
                    onToggleComplete: () =>
                        provider.toggleComplete(task.id!),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditTaskScreen(task: task),
                        ),
                      );
                    },
                  ),
                  // Day pills
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        ...List.generate(7, (dayIndex) {
                          final dayNum = dayIndex + 1;
                          final isActive = activeDays.contains(dayNum);
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              width: 36,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : (isDark
                                        ? AppColors.darkSurface
                                        : AppColors.lightBackground),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                  width: isActive ? 1.5 : 0.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _dayLabels[dayIndex],
                                style: AppTextStyles.caption(
                                  color: isActive
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                                ).copyWith(
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          );
                        }),
                        const Spacer(),
                        Text(
                          'Next: $nextOccurrence',
                          style: AppTextStyles.caption(
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getNextOccurrence(List<int> activeDays) {
    if (activeDays.isEmpty) return 'N/A';

    final now = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      final candidate = now.add(Duration(days: i));
      if (activeDays.contains(candidate.weekday)) {
        return DateFormat('EEE, MMM d').format(candidate);
      }
    }
    return 'Tomorrow';
  }

  void _showContextMenu(
      BuildContext context, TaskProvider provider, int taskId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Reset for Today'),
              onTap: () {
                provider.toggleComplete(taskId);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task reset for today')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: Colors.red.shade400),
              title: Text('Delete',
                  style: TextStyle(color: Colors.red.shade400)),
              onTap: () {
                provider.deleteTask(taskId);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
