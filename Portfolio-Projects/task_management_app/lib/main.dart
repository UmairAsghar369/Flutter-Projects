import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/add_edit_task_screen.dart';

/// Entry point for the TaskFlow application.
///
/// Initializes notifications, loads user preferences,
/// resets repeating tasks, then launches the UI.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  // Load theme preferences
  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  // Load tasks and run repeat-reset
  final taskProvider = TaskProvider();
  await taskProvider.loadTasks();
  await taskProvider.runRepeatReset();

  // Set up notification tap handler
  NotificationService.instance.onNotificationTap = (taskId) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(
          task: taskProvider.allTasks.firstWhere(
            (t) => t.id == taskId,
            orElse: () => taskProvider.allTasks.first,
          ),
        ),
      ),
    );
  };

  runApp(
    TaskFlowApp(
      themeProvider: themeProvider,
      taskProvider: taskProvider,
    ),
  );
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

/// Root widget for the TaskFlow application.
class TaskFlowApp extends StatelessWidget {
  /// Theme state provider.
  final ThemeProvider themeProvider;

  /// Task state provider.
  final TaskProvider taskProvider;

  /// Creates the [TaskFlowApp].
  const TaskFlowApp({
    super.key,
    required this.themeProvider,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: taskProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return AnimatedTheme(
            data: theme.isDark ? AppTheme.dark : AppTheme.light,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'TaskFlow',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: theme.themeMode,
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
