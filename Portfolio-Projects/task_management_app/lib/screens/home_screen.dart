import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/custom_bottom_nav.dart';
import 'today_tasks_screen.dart';
import 'completed_tasks_screen.dart';
import 'repeated_tasks_screen.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';
import '../constants/app_colors.dart';
import '../services/notification_service.dart';

/// Main home screen with bottom navigation for Today, Completed, and Repeated tabs.
///
/// Handles the full permission flow (notifications + exact alarms) on first launch
/// with clear user-facing dialogs for every Android version.
class HomeScreen extends StatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TodayTasksScreen(),
    CompletedTasksScreen(),
    RepeatedTasksScreen(),
  ];

  static const List<String> _titles = ['Today', 'Completed', 'Repeated'];

  late AnimationController _fabPulseController;
  late Animation<double> _fabPulse;

  @override
  void initState() {
    super.initState();

    _fabPulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _fabPulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _fabPulseController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    // Run the permission flow after the UI is fully ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runPermissionFlow();
    });
  }

  // ── Permission Flow ─────────────────────────────────────────────

  /// Step-by-step permission flow: notifications first, then exact alarms.
  Future<void> _runPermissionFlow() async {
    if (!mounted) return;
    await _ensureNotificationPermission();
    if (!mounted) return;
    await _ensureExactAlarmPermission();
  }

  /// Ensures the POST_NOTIFICATIONS permission is granted (Android 13+).
  ///
  /// On older Android, notifications are auto-granted so this is a no-op.
  Future<void> _ensureNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return;

    if (!mounted) return;

    if (status.isPermanentlyDenied) {
      // User has blocked it — guide them to App Settings
      await _showPermissionDialog(
        icon: Icons.notifications_off_rounded,
        iconColor: Colors.orange,
        title: 'Notifications Blocked',
        message:
            'Notifications have been blocked for TaskFlow.\n\n'
            'To fix this:\nSettings → Apps → TaskFlow → Notifications → Enable',
        primaryLabel: 'Open App Settings',
        onPrimary: () async => openAppSettings(),
      );
      return;
    }

    // Show our explanation dialog, then trigger the system popup
    final proceed = await _showPermissionDialog(
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.primary,
      title: 'Allow Notifications',
      message:
          'TaskFlow needs to send you notifications so you know when:\n\n'
          '• A new task is added ✓\n'
          '• A task reminder timer goes off ⏰\n'
          '• A task is due right now 🔔',
      primaryLabel: 'Allow',
      onPrimary: () async {
        await Permission.notification.request();
      },
    );
    if (proceed && mounted) {
      // Also initialise through the plugin itself (needed on some devices)
      await NotificationService.instance.requestPermissions();
    }
  }

  /// Ensures the SCHEDULE_EXACT_ALARM permission is granted (Android 12+).
  ///
  /// On Android < 12, exact alarms are automatically allowed, so this exits early.
  Future<void> _ensureExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) return;

    if (!mounted) return;

    if (status.isPermanentlyDenied) {
      await _showPermissionDialog(
        icon: Icons.alarm_off_rounded,
        iconColor: Colors.red.shade400,
        title: '"Alarms & Reminders" Blocked',
        message:
            'The alarm permission is blocked. To re-enable it:\n\n'
            'Settings → Apps → TaskFlow\n→ Alarms & Reminders → Allow',
        primaryLabel: 'Open App Settings',
        onPrimary: () async => openAppSettings(),
      );
      return;
    }

    // Show explanation then open the system Alarms & Reminders settings
    await _showPermissionDialog(
      icon: Icons.alarm_add_rounded,
      iconColor: AppColors.primary,
      title: 'Enable Alarm Reminders',
      message:
          'To fire notifications exactly when a task timer runs out, '
          'TaskFlow needs the "Alarms & Reminders" permission.\n\n'
          'Tap "Enable" → find TaskFlow → toggle it ON.',
      primaryLabel: 'Enable',
      onPrimary: () async {
        await Permission.scheduleExactAlarm.request();
      },
    );
  }

  /// Shows a styled permission explanation dialog.
  ///
  /// Returns `true` if the user tapped the primary action, `false` if they skipped.
  Future<bool> _showPermissionDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String primaryLabel,
    required Future<void> Function() onPrimary,
  }) async {
    if (!mounted) return false;
    bool acted = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        icon: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 36, color: iconColor),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(height: 1.6, fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Skip'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () async {
              acted = true;
              Navigator.pop(ctx);
              await onPrimary();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(primaryLabel),
          ),
        ],
      ),
    );
    return acted;
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabPulse,
        child: FloatingActionButton(
          heroTag: 'add_task_fab',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
