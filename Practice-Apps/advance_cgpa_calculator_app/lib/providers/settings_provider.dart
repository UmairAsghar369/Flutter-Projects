import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/database_service.dart';

/// Manages app-wide settings.
class SettingsProvider extends ChangeNotifier {
  late AppSettings _settings;

  SettingsProvider() {
    _settings = DatabaseService.getSettings();
  }

  AppSettings get settings => _settings;
  bool get isFirstLaunch => _settings.isFirstLaunch;

  /// Mark onboarding as complete
  void completeOnboarding() {
    _settings.isFirstLaunch = false;
    DatabaseService.saveSettings(_settings);
    notifyListeners();
  }

  /// Refresh settings from disk
  void reload() {
    _settings = DatabaseService.getSettings();
    notifyListeners();
  }
}
