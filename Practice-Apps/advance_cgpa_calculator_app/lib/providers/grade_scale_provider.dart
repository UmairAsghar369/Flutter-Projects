import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/grade_scale.dart';
import '../services/database_service.dart';

/// Manages custom grade scales.
class GradeScaleProvider extends ChangeNotifier {
  List<GradeScale> _scales = [];
  String _activeScaleId = 'default';
  final _uuid = const Uuid();

  GradeScaleProvider() {
    _load();
  }

  List<GradeScale> get scales => _scales;
  String get activeScaleId => _activeScaleId;

  GradeScale get activeScale {
    try {
      return _scales.firstWhere((s) => s.id == _activeScaleId);
    } catch (_) {
      return GradeScale.defaultScale;
    }
  }

  void _load() {
    _scales = DatabaseService.getAllGradeScales();
    final settings = DatabaseService.getSettings();
    _activeScaleId = settings.activeGradeScaleId;
    notifyListeners();
  }

  /// Set the active grade scale
  void setActiveScale(String id) {
    _activeScaleId = id;
    final settings = DatabaseService.getSettings();
    settings.activeGradeScaleId = id;
    DatabaseService.saveSettings(settings);
    notifyListeners();
  }

  /// Add a new custom scale
  Future<void> addScale(String name, Map<String, double> gradeMap) async {
    final scale = GradeScale(
      id: _uuid.v4(),
      name: name,
      gradeMap: gradeMap,
    );
    await DatabaseService.saveGradeScale(scale);
    _scales.add(scale);
    notifyListeners();
  }

  /// Update an existing scale
  Future<void> updateScale(
      String id, String name, Map<String, double> gradeMap) async {
    final scale = _scales.firstWhere((s) => s.id == id);
    scale.name = name;
    scale.gradeMap = gradeMap;
    await DatabaseService.saveGradeScale(scale);
    notifyListeners();
  }

  /// Delete a custom scale (cannot delete default)
  Future<void> deleteScale(String id) async {
    if (id == 'default') return;
    await DatabaseService.deleteGradeScale(id);
    _scales.removeWhere((s) => s.id == id);
    if (_activeScaleId == id) {
      setActiveScale('default');
    }
    notifyListeners();
  }
}
