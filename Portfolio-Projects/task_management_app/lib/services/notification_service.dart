import 'dart:async';
import 'package:flutter/foundation.dart';
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

  final Map<int, Timer> _webTimers = {};

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

    // ── Corrupted-state recovery ──────────────────────────────────
    // flutter_local_notifications v17 uses Gson to persist scheduled
    // notifications. After an app update the stored JSON may be missing
    // a required type parameter, causing every zonedSchedule call to
    // throw "Missing type parameter". Probing pendingNotificationRequests
    // triggers the same deserialization path; if it throws we wipe the
    // stale data with cancelAll() so fresh schedules always succeed.
    if (!kIsWeb) {
      try {
        await _plugin.pendingNotificationRequests();
      } catch (e) {
        debugPrint(
            'NotificationService: corrupted state detected – clearing. $e');
        try {
          await _plugin.cancelAll();
        } catch (_) {}
      }
    }

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

  // ── Permissions ─────────────────────────────────────────────────

  /// Requests all required notification permissions.
  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  // ── Notification Channels ───────────────────────────────────────

  /// Returns [NotificationDetails] using the given [soundName].
  NotificationDetails _details({String? soundName}) {
    // We append v4 to the channel ID to force Android to generate a brand new
    // channel with max importance, overwriting any previous buggy channels.
    const androidDetails = AndroidNotificationDetails(
      'taskflow_channel_v4',
      'TaskFlow Notifications',
      channelDescription: 'Notifications for TaskFlow task management',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      // Ignoring custom soundName since no audio files exist in res/raw.
      // Trying to play non-existent sounds causes complete failure of Notifications natively.
      playSound: true,
    );
    return const NotificationDetails(android: androidDetails);
  }

  // ── Internal safe zonedSchedule helper ──────────────────────────

  /// Wraps [_plugin.zonedSchedule] with automatic retry-after-cancelAll
  /// to handle the Gson "Missing type parameter" crash gracefully.
  ///
  /// Never throws – all exceptions are caught and logged.
  Future<void> _safeZonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime tzDate,
    required NotificationDetails details,
    required String payload,
  }) async {
    Future<void> attempt() => _plugin.zonedSchedule(
          id,
          title,
          body,
          tzDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );

    try {
      await attempt();
    } catch (e) {
      debugPrint(
          'NotificationService: zonedSchedule failed ($e). Clearing state and retrying…');
      // Clear corrupted persisted data, then retry once.
      try {
        await _plugin.cancelAll();
      } catch (_) {}
      try {
        await attempt();
        debugPrint('NotificationService: retry succeeded for id=$id');
      } catch (e2) {
        debugPrint(
            'NotificationService: retry also failed – notification skipped. $e2');
      }
    }
  }

  // ── Instant Notification ────────────────────────────────────────

  /// Shows an instant notification when a new task is created.
  ///
  /// [taskId] is embedded as the payload for tap navigation.
  /// Never throws.
  Future<void> showTaskAddedNotification({
    required int taskId,
    required String taskTitle,
    String? soundName,
  }) async {
    try {
      await _plugin.show(
        taskId + 100000, // offset to avoid collision with reminder IDs
        'New Task Added ✓',
        '\'$taskTitle\' has been added to your tasks.',
        kIsWeb ? const NotificationDetails() : _details(soundName: soundName),
        payload: '$taskId',
      );
    } catch (e) {
      debugPrint('NotificationService: showTaskAddedNotification error: $e');
    }
  }

  // ── Scheduled Reminder ──────────────────────────────────────────

  /// ID offset for due-time notifications to avoid collision with reminder IDs.
  static const int _dueTimeIdOffset = 200000;

  /// Returns the due-time notification ID for a given [taskId].
  static int dueTimeNotificationId(int taskId) => taskId + _dueTimeIdOffset;

  /// Schedules a reminder notification for a task.
  ///
  /// Fires [reminderMinutes] before the [scheduledDate].
  /// Never throws – failures are logged and skipped gracefully.
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

    if (kIsWeb) {
      final duration = scheduledDate.difference(DateTime.now());
      if (duration.isNegative) return;
      _webTimers[notificationId]?.cancel();
      _webTimers[notificationId] = Timer(duration, () {
        _plugin
            .show(
              notificationId,
              'Task Reminder ⏰',
              body,
              const NotificationDetails(),
              payload: '$notificationId',
            )
            .catchError((e) {
          debugPrint('NotificationService: web reminder error: $e');
          return null;
        });
      });
      return;
    }

    await _safeZonedSchedule(
      id: notificationId,
      title: 'Task Reminder ⏰',
      body: body,
      tzDate: tzDate,
      details: _details(soundName: soundName),
      payload: '$notificationId',
    );
  }

  // ── Due-Time Notification ───────────────────────────────────────

  /// Schedules a notification that fires exactly at the task's due date/time.
  ///
  /// Uses [taskId] + [_dueTimeIdOffset] as the notification ID so it never
  /// collides with the advance-reminder notification.
  /// Never throws – failures are logged and skipped gracefully.
  Future<void> scheduleDueTimeNotification({
    required int taskId,
    required String taskTitle,
    required DateTime dueDateTime,
    String? soundName,
  }) async {
    final notifId = dueTimeNotificationId(taskId);

    if (kIsWeb) {
      final duration = dueDateTime.difference(DateTime.now());
      if (duration.isNegative) return;
      _webTimers[notifId]?.cancel();
      _webTimers[notifId] = Timer(duration, () {
        _plugin
            .show(
              notifId,
              '⏰ Task Due Now!',
              '\'$taskTitle\' is due right now!',
              const NotificationDetails(),
              payload: '$taskId',
            )
            .catchError((e) {
          debugPrint('NotificationService: web due-time error: $e');
          return null;
        });
      });
      return;
    }

    final tzDate = tz.TZDateTime.from(dueDateTime, tz.local);
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _safeZonedSchedule(
      id: notifId,
      title: '⏰ Task Due Now!',
      body: '\'$taskTitle\' is due right now!',
      tzDate: tzDate,
      details: _details(soundName: soundName),
      payload: '$taskId',
    );
  }

  // ── Cancel ──────────────────────────────────────────────────────

  /// Cancels a scheduled advance-reminder notification by [notificationId].
  /// Also cancels the corresponding due-time notification automatically.
  Future<void> cancelNotification(int notificationId) async {
    final dueTimeId = dueTimeNotificationId(notificationId);
    if (kIsWeb) {
      _webTimers[notificationId]?.cancel();
      _webTimers.remove(notificationId);
      _webTimers[dueTimeId]?.cancel();
      _webTimers.remove(dueTimeId);
      return;
    }
    try {
      await _plugin.cancel(notificationId);
    } catch (_) {}
    try {
      await _plugin.cancel(dueTimeId);
    } catch (_) {}
  }

  /// Cancels all notifications.
  Future<void> cancelAll() async {
    if (kIsWeb) {
      for (final timer in _webTimers.values) {
        timer.cancel();
      }
      _webTimers.clear();
      return;
    }
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
