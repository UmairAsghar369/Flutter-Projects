import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentController extends ChangeNotifier {
  // Singleton instance
  static final StudentController instance = StudentController._internal();

  StudentController._internal();

  final List<Student> _students = [
    Student(
      id: '1',
      name: 'Ali Khan',
      rollNo: 'CS-012',
      department: 'Computer Science',
      grade: 'A',
      avatarColor: const Color(0xFF6C63FF),
    ),
    Student(
      id: '2',
      name: 'Ayesha Tariq',
      rollNo: 'SE-088',
      department: 'Software Engineering',
      grade: 'A+',
      avatarColor: const Color(0xFFFF6584),
    ),
    Student(
      id: '3',
      name: 'Bilal Ahmed',
      rollNo: 'IT-045',
      department: 'Information Tech',
      grade: 'B+',
      avatarColor: const Color(0xFF43E08F),
    ),
  ];

  List<Student> get students => _students;

  void addStudent(Student student) {
    _students.insert(0, student);
    notifyListeners();
  }

  void updateStudent(Student student) {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
      notifyListeners();
    }
  }

  void deleteStudent(String id) {
    _students.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
