/// Represents a subtask belonging to a parent [Task].
///
/// Subtasks track individual action items within a larger task
/// and each has its own completion state.
class Subtask {
  /// Unique identifier (auto-incremented by SQLite).
  final int? id;

  /// Foreign key referencing the parent task.
  final int taskId;

  /// The subtask title.
  final String title;

  /// Whether this subtask has been completed.
  final bool isCompleted;

  /// Creates a [Subtask] instance.
  const Subtask({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
  });

  /// Constructs a [Subtask] from a SQLite row [map].
  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      title: map['title'] as String,
      isCompleted: (map['is_completed'] as int?) == 1,
    );
  }

  /// Converts this [Subtask] to a SQLite-compatible [Map].
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  /// Returns a copy of this subtask with the given fields replaced.
  Subtask copyWith({
    int? id,
    int? taskId,
    String? title,
    bool? isCompleted,
  }) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
