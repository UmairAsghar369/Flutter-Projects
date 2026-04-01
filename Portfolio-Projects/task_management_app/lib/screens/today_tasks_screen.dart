import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/empty_state_widget.dart';
import 'add_edit_task_screen.dart';

/// Shows tasks due today that are not yet completed.
///
/// Supports pull-to-refresh, swipe-to-delete with undo,
/// and checkbox toggle with smooth animations.
class TodayTasksScreen extends StatefulWidget {
  /// Creates a [TodayTasksScreen].
  const TodayTasksScreen({super.key});

  @override
  State<TodayTasksScreen> createState() => _TodayTasksScreenState();
}

class _TodayTasksScreenState extends State<TodayTasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: 5,
            itemBuilder: (_, _) => const ShimmerCard(),
          );
        }

        final tasks = provider.todayTasks;

        if (tasks.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => provider.loadTasks(),
            child: ListView(
              children: const [
                SizedBox(height: 80),
                EmptyStateWidget(
                  icon: Icons.wb_sunny_rounded,
                  title: 'No tasks for today',
                  subtitle: 'Tap the + button to add a new task',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadTasks(),
          child: ListView.builder(
            key: ValueKey(tasks.length),
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final subtasks = provider.subtasksFor(task.id!);

              return Dismissible(
                key: ValueKey(task.id),
                direction: DismissDirection.endToStart,
                background: _buildDismissBackground(),
                confirmDismiss: (_) async => true,
                onDismissed: (_) {
                  provider.deleteTask(task.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('\'${task.title}\' deleted'),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          provider.addTask(task,
                              subtasks:
                                  subtasks.map((s) => s.title).toList());
                        },
                      ),
                    ),
                  );
                },
                child: TaskCard(
                  task: task,
                  subtasks: subtasks,
                  onToggleComplete: () async {
                    await provider.toggleComplete(task.id!);
                    // Check if all subtasks completed
                    if (provider.allSubtasksCompleted(task.id!) &&
                        !task.isCompleted) {
                      if (context.mounted) {
                        _showCompletePrompt(context, provider, task.id!);
                      }
                    }
                  },
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditTaskScreen(task: task),
                      ),
                    );
                  },
                  onToggleSubtask: (subtaskId) async {
                    await provider.toggleSubtask(subtaskId, task.id!);
                    if (provider.allSubtasksCompleted(task.id!)) {
                      if (context.mounted) {
                        _showCompletePrompt(context, provider, task.id!);
                      }
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
    );
  }

  void _showCompletePrompt(
      BuildContext context, TaskProvider provider, int taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('All subtasks done! 🎉'),
        content: const Text('Mark this task as complete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not yet'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.toggleComplete(taskId);
              Navigator.pop(ctx);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
