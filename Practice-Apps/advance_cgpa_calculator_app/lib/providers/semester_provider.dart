import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/semester.dart';
import '../models/subject.dart';
import '../models/student_profile.dart';
import '../models/grade_scale.dart';
import '../services/database_service.dart';

/// Manages semesters and subjects for the active profile.
/// Also calculates GPA and CGPA.
class SemesterProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  StudentProfile? _profile;

  List<Semester> get semesters => _profile?.semesters ?? [];

  double get cgpa => _profile?.cgpa ?? 0.0;

  int get totalCredits => _profile?.totalCredits ?? 0;

  /// Set the active profile (called when profile changes)
  void setProfile(StudentProfile? profile) {
    _profile = profile;
    notifyListeners();
  }

  // ── Semester CRUD ─────────────────────────────────────

  void addSemester(String name) {
    final semester = Semester(id: _uuid.v4(), name: name);
    _profile?.semesters.add(semester);
    _save();
    notifyListeners();
  }

  void updateSemesterName(String semesterId, String newName) {
    final sem = _findSemester(semesterId);
    if (sem != null) {
      sem.name = newName;
      _save();
      notifyListeners();
    }
  }

  void deleteSemester(String semesterId) {
    _profile?.semesters.removeWhere((s) => s.id == semesterId);
    _save();
    notifyListeners();
  }

  // ── Subject CRUD ──────────────────────────────────────

  void addSubject(
    String semesterId, {
    required String name,
    required int creditHours,
    required String grade,
    required GradeScale scale,
  }) {
    final sem = _findSemester(semesterId);
    if (sem != null) {
      sem.subjects.add(Subject(
        id: _uuid.v4(),
        name: name,
        creditHours: creditHours,
        grade: grade,
        gradePoints: scale.pointsFor(grade),
      ));
      _save();
      notifyListeners();
    }
  }

  void updateSubject(
    String semesterId,
    String subjectId, {
    required String name,
    required int creditHours,
    required String grade,
    required GradeScale scale,
  }) {
    final sem = _findSemester(semesterId);
    if (sem != null) {
      final sub = sem.subjects.firstWhere((s) => s.id == subjectId);
      sub.name = name;
      sub.creditHours = creditHours;
      sub.grade = grade;
      sub.gradePoints = scale.pointsFor(grade);
      _save();
      notifyListeners();
    }
  }

  void deleteSubject(String semesterId, String subjectId) {
    final sem = _findSemester(semesterId);
    if (sem != null) {
      sem.subjects.removeWhere((s) => s.id == subjectId);
      _save();
      notifyListeners();
    }
  }

  // ── Helpers ───────────────────────────────────────────

  Semester? _findSemester(String id) {
    try {
      return _profile?.semesters.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    if (_profile != null) {
      await DatabaseService.saveProfile(_profile!);
    }
  }
}
