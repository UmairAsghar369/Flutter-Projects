import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/subtask.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

/// Provides task state to the widget tree via [ChangeNotifier].
///
/// Encapsulates all CRUD operations, repeat-task reset logic,
/// and notification scheduling for tasks and subtasks.
class TaskProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Task> _allTasks = [];
  Map<int, List<Subtask>> _subtasksMap = {};
  bool _isLoading = false;

  /// Whether data is currently being loaded from the database.
  bool get isLoading => _isLoading;

  /// All tasks in the database.
  List<Task> get allTasks => _allTasks;

  /// Tasks due today that are not completed.
  List<Task> get todayTasks {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _allTasks
        .where((t) => t.dueDate == today && !t.isCompleted)
        .toList();
  }

  /// All completed tasks.
  List<Task> get completedTasks =>
      _allTasks.where((t) => t.isCompleted).toList();

  /// All repeating tasks.
  List<Task> get repeatingTasks =>
      _allTasks.where((t) => t.isRepeating).toList();

  /// Returns cached subtasks for a given [taskId].
  List<Subtask> subtasksFor(int taskId) => _subtasksMap[taskId] ?? [];

  // ── Load ───────────────────────────────────────────────────────

  /// Loads all tasks and their subtasks from the database.
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTasks = await _db.getAllTasks();
      _subtasksMap = {};
      for (final task in _allTasks) {
        if (task.id != null) {
          _subtasksMap[task.id!] = await _db.getSubtasksForTask(task.id!);
        }
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Create ─────────────────────────────────────────────────────

  /// Inserts a new [task] with optional [subtasks].
  ///
  /// Returns the newly created task with its assigned id.
  Future<Task> addTask(Task task, {List<String> subtasks = const []}) async {
    final now = DateTime.now().toIso8601String();
    final newTask = task.copyWith(
      createdAt: now,
      notificationId: DateTime.now().millisecondsSinceEpoch % 100000,
    );

    final id = await _db.insertTask(newTask);
    final savedTask = newTask.copyWith(id: id, notificationId: id);
    await _db.updateTask(savedTask);

    // Insert subtasks
    final subs = <Subtask>[];
    for (final title in subtasks) {
      if (title.trim().isEmpty) continue;
      final subId = await _db.insertSubtask(
        Subtask(taskId: id, title: title.trim()),
      );
      subs.add(Subtask(id: subId, taskId: id, title: title.trim()));
    }

    _allTasks.insert(0, savedTask);
    _subtasksMap[id] = subs;
    notifyListeners();

    return savedTask;
  }

  // ── Update ─────────────────────────────────────────────────────

  /// Updates an existing [task] and replaces its subtask titles.
  Future<void> updateTask(Task task,
      {List<String> subtasks = const []}) async {
    await _db.updateTask(task);

    // Replace subtasks
    if (task.id != null) {
      await _db.deleteSubtasksForTask(task.id!);
      final subs = <Subtask>[];
      for (final title in subtasks) {
        if (title.trim().isEmpty) continue;
        final subId = await _db.insertSubtask(
          Subtask(taskId: task.id!, title: title.trim()),
        );
        subs.add(Subtask(id: subId, taskId: task.id!, title: title.trim()));
      }
      _subtasksMap[task.id!] = subs;
    }

    final idx = _allTasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _allTasks[idx] = task;
    notifyListeners();
  }

  // ── Delete ─────────────────────────────────────────────────────

  /// Deletes a task by [taskId] and cancels its notifications.
  Future<void> deleteTask(int taskId) async {
    await _db.deleteTask(taskId);
    // cancelNotification now also cancels the due-time notification internally
    await NotificationService.instance.cancelNotification(taskId);
    // Also cancel the "task added" instant notification (offset +100000)
    await NotificationService.instance.cancelNotification(taskId + 100000);
    _allTasks.removeWhere((t) => t.id == taskId);
    _subtasksMap.remove(taskId);
    notifyListeners();
  }

  // ── Toggle Complete ────────────────────────────────────────────

  /// Toggles the completion state of a task.
  Future<void> toggleComplete(int taskId) async {
    final idx = _allTasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final task = _allTasks[idx];
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      lastCompletedDate: !task.isCompleted ? now : task.lastCompletedDate,
    );

    await _db.updateTask(updated);
    _allTasks[idx] = updated;

    // Cancel both advance-reminder AND due-time notification when completed
    if (updated.isCompleted && updated.notificationId != null) {
      // cancelNotification already cancels the due-time notification too
      await NotificationService.instance
          .cancelNotification(updated.notificationId!);
    }

    notifyListeners();
  }

  // ── Toggle Subtask ─────────────────────────────────────────────

  /// Toggles a subtask completion state and refreshes the cache.
  Future<void> toggleSubtask(int subtaskId, int taskId) async {
    await _db.toggleSubtask(subtaskId);
    _subtasksMap[taskId] = await _db.getSubtasksForTask(taskId);
    notifyListeners();
  }

  /// Returns `true` if all subtasks for [taskId] are completed.
  bool allSubtasksCompleted(int taskId) {
    final subs = _subtasksMap[taskId];
    if (subs == null || subs.isEmpty) return false;
    return subs.every((s) => s.isCompleted);
  }

  // ── Repeat Reset ───────────────────────────────────────────────

  /// Checks all repeating tasks and resets those due today.
  ///
  /// Should be called on every app launch from [TaskProvider] init.
  Future<void> runRepeatReset() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayWeekday = DateTime.now().weekday; // 1=Mon … 7=Sun

    for (var i = 0; i < _allTasks.length; i++) {
      final task = _allTasks[i];
      if (!task.isRepeating || !task.isCompleted) continue;
      if (task.lastCompletedDate == today) continue;

      bool shouldReset = false;
      if (task.repeatType == 'daily') {
        shouldReset = true;
      } else if (task.repeatDays != null && task.repeatDays!.isNotEmpty) {
        final days = task.repeatDays!
            .split(',')
            .map((d) => int.tryParse(d.trim()))
            .whereType<int>()
            .toList();
        if (days.contains(todayWeekday)) {
          shouldReset = true;
        }
      }

      if (shouldReset) {
        final updated = task.copyWith(
          isCompleted: false,
          dueDate: today,
        );
        await _db.updateTask(updated);
        _allTasks[i] = updated;

        // Reset subtasks
        if (task.id != null) {
          final subs = _subtasksMap[task.id!] ?? [];
          for (final sub in subs) {
            if (sub.isCompleted) {
              await _db.toggleSubtask(sub.id!);
            }
          }
          _subtasksMap[task.id!] = await _db.getSubtasksForTask(task.id!);
        }

        // Reschedule reminder
        if (updated.notificationId != null &&
            updated.reminderMinutes != null &&
            updated.dueTime != null) {
          _scheduleReminderForTask(updated);
        }
      }
    }
    notifyListeners();
  }

  /// Internal helper to schedule reminders for a repeating task after reset.
  ///
  /// Schedules both the advance reminder (X minutes before due) and the
  /// due-time notification (fires exactly at the due date/time).
  void _scheduleReminderForTask(Task task) {
    if (task.dueDate == null || task.dueTime == null) return;
    try {
      final dateParts = task.dueDate!.split('-');
      final timeParts = task.dueTime!.split(':');
      final dueDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      // Schedule advance reminder if set
      if (task.reminderMinutes != null && task.reminderMinutes! > 0) {
        final reminderTime =
            dueDateTime.subtract(Duration(minutes: task.reminderMinutes!));
        NotificationService.instance.scheduleReminder(
          notificationId: task.notificationId ?? task.id!,
          taskTitle: task.title,
          scheduledDate: reminderTime,
          reminderMinutes: task.reminderMinutes!,
        );
      }

      // Always schedule due-time notification when due date/time is set
      NotificationService.instance.scheduleDueTimeNotification(
        taskId: task.id!,
        taskTitle: task.title,
        dueDateTime: dueDateTime,
      );
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }
}
