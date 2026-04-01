import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state_widget.dart';
import 'add_edit_task_screen.dart';

/// Displays all completed tasks, grouped by completion date.
///
/// Users can un-complete a task by tapping the checkbox again.
class CompletedTasksScreen extends StatelessWidget {
  /// Creates a [CompletedTasksScreen].
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final tasks = provider.completedTasks;

        if (tasks.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.check_circle_outline_rounded,
            title: 'No completed tasks',
            subtitle: 'Tasks you finish will appear here',
          );
        }

        // Group by completion date
        final grouped = <String, List<dynamic>>{};
        for (final task in tasks) {
          final dateKey = task.lastCompletedDate ?? 'Unknown';
          grouped.putIfAbsent(dateKey, () => []).add(task);
        }

        final sortedKeys = grouped.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final dateKey = sortedKeys[index];
            final groupTasks = grouped[dateKey]!;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            String displayDate = dateKey;
            try {
              final parsed = DateTime.parse(dateKey);
              final now = DateTime.now();
              if (DateFormat('yyyy-MM-dd').format(now) == dateKey) {
                displayDate = 'Today';
              } else if (DateFormat('yyyy-MM-dd')
                      .format(now.subtract(const Duration(days: 1))) ==
                  dateKey) {
                displayDate = 'Yesterday';
              } else {
                displayDate = DateFormat('MMM d, yyyy').format(parsed);
              }
            } catch (_) {}

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    displayDate,
                    style: AppTextStyles.caption(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                ...groupTasks.map(
                  (task) => TaskCard(
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
                ),
              ],
            );
          },
        );
      },
    );
  }
}
