import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides theme mode state to the widget tree via [ChangeNotifier].
///
/// Persists the user's dark/light preference using [SharedPreferences].
class ThemeProvider extends ChangeNotifier {
  /// Storage key for theme mode.
  static const String _themeKey = 'theme_mode';

  /// Storage key for notification sound.
  static const String _soundKey = 'notification_sound';

  ThemeMode _themeMode = ThemeMode.light;
  String _notificationSound = 'default';

  /// The current [ThemeMode].
  ThemeMode get themeMode => _themeMode;

  /// Whether dark mode is active.
  bool get isDark => _themeMode == ThemeMode.dark;

  /// The selected notification sound name.
  String get notificationSound => _notificationSound;

  /// Loads persisted preferences. Call during app startup.
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeKey);
    if (stored == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    _notificationSound = prefs.getString(_soundKey) ?? 'default';
    notifyListeners();
  }

  /// Toggles between light and dark mode and persists the choice.
  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  /// Sets the notification sound and persists it.
  Future<void> setNotificationSound(String sound) async {
    _notificationSound = sound;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundKey, sound);
    notifyListeners();
  }
}
