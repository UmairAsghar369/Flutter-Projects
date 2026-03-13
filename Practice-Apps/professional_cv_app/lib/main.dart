import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/cv_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

/// Dynamic CV App — entry point.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Transparent status bar for full-bleed gradient headers.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DynamicCvApp());
}

class DynamicCvApp extends StatelessWidget {
  const DynamicCvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CvProviderScope(
      child: MaterialApp(
        title: 'Dynamic CV App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        home: const SplashScreen(),
      ),
    );
  }
}
