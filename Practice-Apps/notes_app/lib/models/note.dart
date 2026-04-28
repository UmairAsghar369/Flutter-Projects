import 'dart:convert';

/// Available note categories with associated colors
enum NoteCategory {
  personal,
  work,
  ideas,
  todo,
  other;

  String get label {
    switch (this) {
      case NoteCategory.personal:
        return 'Personal';
      case NoteCategory.work:
        return 'Work';
      case NoteCategory.ideas:
        return 'Ideas';
      case NoteCategory.todo:
        return 'To-Do';
      case NoteCategory.other:
        return 'Other';
    }
  }

  /// Color index used to map to theme colors in the UI
  int get colorIndex {
    switch (this) {
      case NoteCategory.personal:
        return 0;
      case NoteCategory.work:
        return 1;
      case NoteCategory.ideas:
        return 2;
      case NoteCategory.todo:
        return 3;
      case NoteCategory.other:
        return 4;
    }
  }
}

/// Priority levels for notes
enum NotePriority {
  low,
  medium,
  high,
  urgent;

  String get label {
    switch (this) {
      case NotePriority.low:
        return 'Low';
      case NotePriority.medium:
        return 'Medium';
      case NotePriority.high:
        return 'High';
      case NotePriority.urgent:
        return 'Urgent';
    }
  }

  String get emoji {
    switch (this) {
      case NotePriority.low:
        return '🟢';
      case NotePriority.medium:
        return '🟡';
      case NotePriority.high:
        return '🟠';
      case NotePriority.urgent:
        return '🔴';
    }
  }
}

/// Note data model
class Note {
  final String id;
  final String title;
  final String body;
  final NoteCategory category;
  final NotePriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? body,
    NoteCategory? category,
    NotePriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category.index,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: NoteCategory.values[json['category'] as int],
      priority: NotePriority.values[json['priority'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Note.fromJsonString(String jsonString) {
    return Note.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
