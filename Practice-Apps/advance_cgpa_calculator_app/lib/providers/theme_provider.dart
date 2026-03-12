import 'package:flutter/material.dart';
import '../services/database_service.dart';

/// Manages dark/light theme and persists the choice.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;

  ThemeProvider(this._isDarkMode);

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _save();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _save();
    notifyListeners();
  }

  void _save() {
    final settings = DatabaseService.getSettings();
    settings.isDarkMode = _isDarkMode;
    DatabaseService.saveSettings(settings);
  }
}
