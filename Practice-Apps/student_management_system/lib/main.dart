import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/student_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const StudentManagementApp());
}

/// App-wide color constants for a consistent premium dark theme.
class AppColors {
  static const Color background = Color(0xFF0F0F23);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color card = Color(0xFF16213E);
  static const Color cardLight = Color(0xFF1C2A4A);
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentDark = Color(0xFF00A383);
  static const Color secondary = Color(0xFF7C5CFC);
  static const Color secondaryLight = Color(0xFF9B7EFF);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color dangerDark = Color(0xFFEE5A5A);
  static const Color warning = Color(0xFFFFD93D);
  static const Color textPrimary = Color(0xFFEAEAEA);
  static const Color textSecondary = Color(0xFF8892B0);
  static const Color textMuted = Color(0xFF5A6380);
  static const Color divider = Color(0xFF233056);
  static const Color inputFill = Color(0xFF1A1A2E);
  static const Color inputBorder = Color(0xFF2A3050);
}

class StudentManagementApp extends StatelessWidget {
  const StudentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const StudentListScreen(),
    );
  }
}
