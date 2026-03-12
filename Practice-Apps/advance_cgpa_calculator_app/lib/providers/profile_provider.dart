import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/student_profile.dart';
import '../services/database_service.dart';

/// Manages multiple student profiles.
class ProfileProvider extends ChangeNotifier {
  List<StudentProfile> _profiles = [];
  String _activeProfileId = '';
  final _uuid = const Uuid();

  ProfileProvider() {
    _loadProfiles();
  }

  List<StudentProfile> get profiles => _profiles;

  String get activeProfileId => _activeProfileId;

  StudentProfile? get activeProfile {
    try {
      return _profiles.firstWhere((p) => p.id == _activeProfileId);
    } catch (_) {
      return _profiles.isNotEmpty ? _profiles.first : null;
    }
  }

  void _loadProfiles() {
    _profiles = DatabaseService.getAllProfiles();
    final settings = DatabaseService.getSettings();
    _activeProfileId = settings.activeProfileId;

    // If no active profile is set but profiles exist, pick the first one
    if (_activeProfileId.isEmpty && _profiles.isNotEmpty) {
      _activeProfileId = _profiles.first.id;
      _saveActiveId();
    }
    notifyListeners();
  }

  /// Create a new profile
  Future<void> addProfile(String name, {int avatarIndex = 0}) async {
    final profile = StudentProfile(
      id: _uuid.v4(),
      name: name,
      avatarIndex: avatarIndex,
    );
    await DatabaseService.saveProfile(profile);
    _profiles.add(profile);

    // Auto-switch if this is the first profile
    if (_profiles.length == 1) {
      _activeProfileId = profile.id;
      _saveActiveId();
    }
    notifyListeners();
  }

  /// Update profile name/avatar
  Future<void> updateProfile(String id, String name, int avatarIndex) async {
    final profile = _profiles.firstWhere((p) => p.id == id);
    profile.name = name;
    profile.avatarIndex = avatarIndex;
    await DatabaseService.saveProfile(profile);
    notifyListeners();
  }

  /// Delete a profile
  Future<void> deleteProfile(String id) async {
    await DatabaseService.deleteProfile(id);
    _profiles.removeWhere((p) => p.id == id);

    if (_activeProfileId == id) {
      _activeProfileId = _profiles.isNotEmpty ? _profiles.first.id : '';
      _saveActiveId();
    }
    notifyListeners();
  }

  /// Switch active profile
  void switchProfile(String id) {
    _activeProfileId = id;
    _saveActiveId();
    notifyListeners();
  }

  /// Save the current profile to disk (call after modifying semesters)
  Future<void> saveCurrentProfile() async {
    final profile = activeProfile;
    if (profile != null) {
      await DatabaseService.saveProfile(profile);
    }
  }

  void _saveActiveId() {
    final settings = DatabaseService.getSettings();
    settings.activeProfileId = _activeProfileId;
    DatabaseService.saveSettings(settings);
  }
}
