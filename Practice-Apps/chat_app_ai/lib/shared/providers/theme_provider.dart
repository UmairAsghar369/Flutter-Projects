// lib/shared/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Toggles between dark and light mode
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.dark,
);
