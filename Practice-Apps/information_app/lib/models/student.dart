import 'package:flutter/material.dart';

class Student {
  final String id;
  final String name;
  final String rollNo;
  final String department;
  final String grade;
  final Color avatarColor;

  Student({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.department,
    required this.grade,
    required this.avatarColor,
  });

  Student copyWith({
    String? name,
    String? rollNo,
    String? department,
    String? grade,
    Color? avatarColor,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      rollNo: rollNo ?? this.rollNo,
      department: department ?? this.department,
      grade: grade ?? this.grade,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }
}
