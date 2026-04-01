/// Represents a single task in the TaskFlow application.
///
/// A task has a title, optional description, due date/time, priority,
/// category, repeat configuration, and an associated reminder.
class Task {
  /// Unique identifier (auto-incremented by SQLite).
  final int? id;

  /// The task title (required).
  final String title;

  /// An optional longer description.
  final String? description;

  /// ISO-8601 date string (yyyy-MM-dd).
  final String? dueDate;

  /// Time in HH:mm format.
  final String? dueTime;

  /// Whether the task has been completed.
  final bool isCompleted;

  /// Whether the task repeats on a schedule.
  final bool isRepeating;

  /// 'daily' or 'custom'.
  final String? repeatType;

  /// Comma-separated weekday numbers (1 = Mon … 7 = Sun).
  final String? repeatDays;

  /// Category label (Work, Personal, Health, Study, Other).
  final String? category;

  /// Priority level: 1 = Low, 2 = Medium, 3 = High.
  final int priority;

  /// ISO-8601 date of the last time this task was completed.
  final String? lastCompletedDate;

  /// Minutes before due time to fire a reminder notification.
  final int? reminderMinutes;

  /// Unique notification ID for scheduled reminders.
  final int? notificationId;

  /// ISO-8601 timestamp when the task was created.
  final String? createdAt;

  /// Creates a [Task] instance.
  const Task({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    this.isRepeating = false,
    this.repeatType,
    this.repeatDays,
    this.category,
    this.priority = 1,
    this.lastCompletedDate,
    this.reminderMinutes,
    this.notificationId,
    this.createdAt,
  });

  /// Constructs a [Task] from a SQLite row [map].
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] as String?,
      dueTime: map['due_time'] as String?,
      isCompleted: (map['is_completed'] as int?) == 1,
      isRepeating: (map['is_repeating'] as int?) == 1,
      repeatType: map['repeat_type'] as String?,
      repeatDays: map['repeat_days'] as String?,
      category: map['category'] as String?,
      priority: (map['priority'] as int?) ?? 1,
      lastCompletedDate: map['last_completed_date'] as String?,
      reminderMinutes: map['reminder_minutes'] as int?,
      notificationId: map['notification_id'] as int?,
      createdAt: map['created_at'] as String?,
    );
  }

  /// Converts this [Task] to a SQLite-compatible [Map].
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'due_time': dueTime,
      'is_completed': isCompleted ? 1 : 0,
      'is_repeating': isRepeating ? 1 : 0,
      'repeat_type': repeatType,
      'repeat_days': repeatDays,
      'category': category,
      'priority': priority,
      'last_completed_date': lastCompletedDate,
      'reminder_minutes': reminderMinutes,
      'notification_id': notificationId,
      'created_at': createdAt,
    };
  }

  /// Returns a copy of this task with the given fields replaced.
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? dueDate,
    String? dueTime,
    bool? isCompleted,
    bool? isRepeating,
    String? repeatType,
    String? repeatDays,
    String? category,
    int? priority,
    String? lastCompletedDate,
    int? reminderMinutes,
    int? notificationId,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
