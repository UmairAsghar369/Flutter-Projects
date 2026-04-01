import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

/// Callback invoked when the user taps a notification.
///
/// Receives the task ID extracted from the notification payload.
typedef NotificationTapCallback = void Function(int taskId);

/// Manages all local notification concerns for TaskFlow.
///
/// Handles initialization, permission requests, instant notifications,
/// and scheduled reminder notifications.
class NotificationService {
  NotificationService._();

  /// Singleton instance.
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Optional callback when the user taps a notification.
  NotificationTapCallback? onNotificationTap;

  /// Whether the service has been initialised.
  bool _initialized = false;

  // ── Initialization ─────────────────────────────────────────────

  /// Initializes the notification plugin and timezone database.
  ///
  /// Must be called before [runApp] in [main].
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && onNotificationTap != null) {
      final taskId = int.tryParse(payload);
      if (taskId != null) {
        onNotificationTap!(taskId);
      }
    }
  }

  // ── Permissions ────────────────────────────────────────────────

  /// Requests all required notification permissions.
  Future<void> requestPermissions() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  // ── Notification Channels ──────────────────────────────────────

  /// Returns [NotificationDetails] using the given [soundName].
  NotificationDetails _details({String? soundName}) {
    final androidDetails = AndroidNotificationDetails(
      'taskflow_channel',
      'TaskFlow Notifications',
      channelDescription: 'Notifications for TaskFlow task management',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      sound: soundName != null
          ? RawResourceAndroidNotificationSound(soundName)
          : null,
    );

    return NotificationDetails(android: androidDetails);
  }

  // ── Instant Notification ───────────────────────────────────────

  /// Shows an instant notification when a new task is created.
  ///
  /// [taskId] is embedded as the payload for tap navigation.
  Future<void> showTaskAddedNotification({
    required int taskId,
    required String taskTitle,
    String? soundName,
  }) async {
    await _plugin.show(
      taskId + 100000, // offset to avoid collision with reminder IDs
      'New Task Added ✓',
      '\'$taskTitle\' has been added to your tasks.',
      _details(soundName: soundName),
      payload: '$taskId',
    );
  }

  // ── Scheduled Reminder ─────────────────────────────────────────

  /// Schedules a reminder notification for a task.
  ///
  /// [notificationId] should be stored in the database.
  /// [scheduledDate] is the exact TZDateTime when the reminder fires.
  Future<void> scheduleReminder({
    required int notificationId,
    required String taskTitle,
    required DateTime scheduledDate,
    required int reminderMinutes,
    String? soundName,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Don't schedule if the time is in the past.
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    String body;
    if (reminderMinutes >= 60) {
      final hours = reminderMinutes ~/ 60;
      body = '\'$taskTitle\' is due in $hours hour${hours > 1 ? 's' : ''}!';
    } else {
      body = '\'$taskTitle\' is due in $reminderMinutes minutes!';
    }

    await _plugin.zonedSchedule(
      notificationId,
      'Task Reminder ⏰',
      body,
      tzDate,
      _details(soundName: soundName),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '$notificationId',
    );
  }

  // ── Cancel ─────────────────────────────────────────────────────

  /// Cancels a scheduled notification by [notificationId].
  Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  /// Cancels all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
