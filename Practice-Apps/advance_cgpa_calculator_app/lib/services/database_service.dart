import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';
import '../models/semester.dart';
import '../models/student_profile.dart';
import '../models/grade_scale.dart';
import '../models/app_settings.dart';

/// Handles all Hive database initialization and CRUD operations.
class DatabaseService {
  static const String profilesBox = 'profiles';
  static const String settingsBox = 'settings';
  static const String gradeScalesBox = 'gradeScales';

  /// Initialize Hive and register all adapters
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters (order matters — register child types first)
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(SemesterAdapter());
    Hive.registerAdapter(StudentProfileAdapter());
    Hive.registerAdapter(GradeScaleAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    // Open boxes
    await Hive.openBox<StudentProfile>(profilesBox);
    await Hive.openBox<AppSettings>(settingsBox);
    await Hive.openBox<GradeScale>(gradeScalesBox);
  }

  // ── Profiles ──────────────────────────────────────────

  static Box<StudentProfile> get _profilesBox =>
      Hive.box<StudentProfile>(profilesBox);

  static List<StudentProfile> getAllProfiles() =>
      _profilesBox.values.toList();

  static Future<void> saveProfile(StudentProfile profile) async =>
      await _profilesBox.put(profile.id, profile);

  static Future<void> deleteProfile(String id) async =>
      await _profilesBox.delete(id);

  static StudentProfile? getProfile(String id) =>
      _profilesBox.get(id);

  // ── Settings ──────────────────────────────────────────

  static Box<AppSettings> get _settingsBox =>
      Hive.box<AppSettings>(settingsBox);

  static AppSettings getSettings() {
    final settings = _settingsBox.get('app_settings');
    if (settings == null) {
      final defaultSettings = AppSettings();
      _settingsBox.put('app_settings', defaultSettings);
      return defaultSettings;
    }
    return settings;
  }

  static Future<void> saveSettings(AppSettings settings) async =>
      await _settingsBox.put('app_settings', settings);

  // ── Grade Scales ──────────────────────────────────────

  static Box<GradeScale> get _gradeScalesBox =>
      Hive.box<GradeScale>(gradeScalesBox);

  static List<GradeScale> getAllGradeScales() {
    final scales = _gradeScalesBox.values.toList();
    // Ensure default scale always exists
    if (!scales.any((s) => s.id == 'default')) {
      final defaultScale = GradeScale.defaultScale;
      _gradeScalesBox.put('default', defaultScale);
      scales.insert(0, defaultScale);
    }
    return scales;
  }

  static Future<void> saveGradeScale(GradeScale scale) async =>
      await _gradeScalesBox.put(scale.id, scale);

  static Future<void> deleteGradeScale(String id) async =>
      await _gradeScalesBox.delete(id);

  static GradeScale? getGradeScale(String id) =>
      _gradeScalesBox.get(id);
}
