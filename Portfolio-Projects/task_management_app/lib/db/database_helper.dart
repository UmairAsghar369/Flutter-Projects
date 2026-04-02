import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subtask.dart';
import '../models/task.dart';

/// Singleton helper that manages the SQLite database for TaskFlow.
///
/// Provides CRUD operations for [Task] and [Subtask] models,
/// with foreign-key support and cascade deletes. On Web, it falls back
/// to SharedPreferences to avoid broken WebAssembly implementations.
class DatabaseHelper {
  DatabaseHelper._();

  /// Singleton instance.
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  /// Database file name.
  static const String _dbName = 'taskflow.db';

  /// Current schema version.
  static const int _dbVersion = 1;

  bool get _useWeb => kIsWeb;

  // ── Web Fallback Data Logic ────────────────────────────────────

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Task>> _getWebTasks() async {
    final p = await _prefs;
    final strList = p.getStringList('web_tasks') ?? [];
    return strList.map((e) => Task.fromMap(jsonDecode(e))).toList();
  }

  Future<void> _saveWebTasks(List<Task> tasks) async {
    final p = await _prefs;
    await p.setStringList('web_tasks', tasks.map((e) => jsonEncode(e.toMap())).toList());
  }

  Future<List<Subtask>> _getWebSubtasks() async {
    final p = await _prefs;
    final strList = p.getStringList('web_subtasks') ?? [];
    return strList.map((e) => Subtask.fromMap(jsonDecode(e))).toList();
  }

  Future<void> _saveWebSubtasks(List<Subtask> subtasks) async {
    final p = await _prefs;
    await p.setStringList('web_subtasks', subtasks.map((e) => jsonEncode(e.toMap())).toList());
  }

  // ── SQLite Initialization ──────────────────────────────────────

  /// Returns the open [Database], creating it on first access.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is disabled on Web. Using SharedPreferences fallback.');
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        due_time TEXT,
        is_completed INTEGER DEFAULT 0,
        is_repeating INTEGER DEFAULT 0,
        repeat_type TEXT,
        repeat_days TEXT,
        category TEXT,
        priority INTEGER DEFAULT 1,
        last_completed_date TEXT,
        reminder_minutes INTEGER,
        notification_id INTEGER,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
  }

  // ── Task CRUD ──────────────────────────────────────────────────

  /// Inserts a new [task] and returns the auto-generated id.
  Future<int> insertTask(Task task) async {
    if (_useWeb) {
      final tasks = await _getWebTasks();
      final newId = DateTime.now().millisecondsSinceEpoch;
      final newTaskMap = task.toMap();
      newTaskMap['id'] = newId;
      newTaskMap['created_at'] = DateTime.now().toIso8601String();
      tasks.add(Task.fromMap(newTaskMap));
      await _saveWebTasks(tasks);
      return newId;
    }

    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  /// Updates an existing [task] by its [Task.id].
  Future<int> updateTask(Task task) async {
    if (_useWeb) {
      final tasks = await _getWebTasks();
      final int idx = tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        tasks[idx] = task;
        await _saveWebTasks(tasks);
        return 1;
      }
      return 0;
    }

    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Deletes a task by [id]. Subtasks are cascade-deleted.
  Future<int> deleteTask(int id) async {
    if (_useWeb) {
      final tasks = await _getWebTasks();
      tasks.removeWhere((t) => t.id == id);
      await _saveWebTasks(tasks);

      // Cascade delete subtasks
      final subtasks = await _getWebSubtasks();
      subtasks.removeWhere((s) => s.taskId == id);
      await _saveWebSubtasks(subtasks);
      return 1;
    }

    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Retrieves all tasks ordered by creation date descending.
  Future<List<Task>> getAllTasks() async {
    if (_useWeb) {
      final tasks = await _getWebTasks();
      tasks.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
      return tasks;
    }

    final db = await database;
    final rows = await db.query('tasks', orderBy: 'created_at DESC');
    return rows.map((r) => Task.fromMap(r)).toList();
  }

  /// Retrieves a single task by [id].
  Future<Task?> getTaskById(int id) async {
    if (_useWeb) {
      final tasks = await _getWebTasks();
      try {
        return tasks.firstWhere((t) => t.id == id);
      } catch (_) {
        return null;
      }
    }

    final db = await database;
    final rows = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Task.fromMap(rows.first);
  }

  /// Returns tasks whose [due_date] matches [date] and are not completed.
  Future<List<Task>> getTasksByDate(String date) async {
    if (_useWeb) {
      final tasks = await _getWebTasks();
      final filtered = tasks.where((t) => t.dueDate == date && t.isCompleted == false).toList();
      filtered.sort((a, b) => (a.dueTime ?? '').compareTo(b.dueTime ?? ''));
      return filtered;
    }

    final db = await database;
    final rows = await db.query(
      'tasks',
      where: 'due_date = ? AND is_completed = 0',
      whereArgs: [date],
      orderBy: 'due_time ASC',
    );
    return rows.map((r) => Task.fromMap(r)).toList();
  }

  /// Returns all completed tasks.
  Future<List<Task>> getCompletedTasks() async {
    if (_useWeb) {
      final tasks = await _getWebTasks();
      final filtered = tasks.where((t) => t.isCompleted == true).toList();
      filtered.sort((a, b) {
        final cmp1 = (b.lastCompletedDate ?? '').compareTo(a.lastCompletedDate ?? '');
        if (cmp1 != 0) return cmp1;
        return (b.createdAt ?? '').compareTo(a.createdAt ?? '');
      });
      return filtered;
    }

    final db = await database;
    final rows = await db.query(
      'tasks',
      where: 'is_completed = 1',
      orderBy: 'last_completed_date DESC, created_at DESC',
    );
    return rows.map((r) => Task.fromMap(r)).toList();
  }

  /// Returns all repeating tasks.
  Future<List<Task>> getRepeatingTasks() async {
    if (_useWeb) {
      final tasks = await _getWebTasks();
      final filtered = tasks.where((t) => t.isRepeating == true).toList();
      filtered.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
      return filtered;
    }

    final db = await database;
    final rows = await db.query(
      'tasks',
      where: 'is_repeating = 1',
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => Task.fromMap(r)).toList();
  }

  // ── Subtask CRUD ───────────────────────────────────────────────

  /// Inserts a new [subtask] and returns its id.
  Future<int> insertSubtask(Subtask subtask) async {
    if (_useWeb) {
      final subtasks = await _getWebSubtasks();
      final newId = DateTime.now().millisecondsSinceEpoch;
      final newSubtaskMap = subtask.toMap();
      newSubtaskMap['id'] = newId;
      subtasks.add(Subtask.fromMap(newSubtaskMap));
      await _saveWebSubtasks(subtasks);
      return newId;
    }

    final db = await database;
    return db.insert('subtasks', subtask.toMap());
  }

  /// Updates an existing [subtask].
  Future<int> updateSubtask(Subtask subtask) async {
    if (_useWeb) {
      final subtasks = await _getWebSubtasks();
      final int idx = subtasks.indexWhere((s) => s.id == subtask.id);
      if (idx != -1) {
        subtasks[idx] = subtask;
        await _saveWebSubtasks(subtasks);
        return 1;
      }
      return 0;
    }

    final db = await database;
    return db.update(
      'subtasks',
      subtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  /// Deletes a subtask by [id].
  Future<int> deleteSubtask(int id) async {
    if (_useWeb) {
      final subtasks = await _getWebSubtasks();
      subtasks.removeWhere((s) => s.id == id);
      await _saveWebSubtasks(subtasks);
      return 1;
    }

    final db = await database;
    return db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns all subtasks for a given [taskId].
  Future<List<Subtask>> getSubtasksForTask(int taskId) async {
    if (_useWeb) {
      final subtasks = await _getWebSubtasks();
      final filtered = subtasks.where((s) => s.taskId == taskId).toList();
      filtered.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      return filtered;
    }

    final db = await database;
    final rows = await db.query(
      'subtasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'id ASC',
    );
    return rows.map((r) => Subtask.fromMap(r)).toList();
  }

  /// Deletes all subtasks for a given [taskId].
  Future<int> deleteSubtasksForTask(int taskId) async {
    if (_useWeb) {
      final subtasks = await _getWebSubtasks();
      int originalLength = subtasks.length;
      subtasks.removeWhere((s) => s.taskId == taskId);
      await _saveWebSubtasks(subtasks);
      return originalLength - subtasks.length;
    }

    final db = await database;
    return db.delete('subtasks', where: 'task_id = ?', whereArgs: [taskId]);
  }

  /// Toggles the completion state of a subtask by [id].
  Future<void> toggleSubtask(int id) async {
    if (_useWeb) {
      final subtasks = await _getWebSubtasks();
      final int idx = subtasks.indexWhere((s) => s.id == id);
      if (idx != -1) {
        final currentMap = subtasks[idx].toMap();
        currentMap['is_completed'] = currentMap['is_completed'] == 0 ? 1 : 0;
        subtasks[idx] = Subtask.fromMap(currentMap);
        await _saveWebSubtasks(subtasks);
      }
      return;
    }

    final db = await database;
    await db.rawUpdate(
      'UPDATE subtasks SET is_completed = CASE WHEN is_completed = 0 THEN 1 ELSE 0 END WHERE id = ?',
      [id],
    );
  }
}
