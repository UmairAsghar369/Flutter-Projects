import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

/// Singleton service for managing local push notifications
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification plugin
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permission (Android 13+ / iOS)
  Future<bool> requestPermission() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    }
    if (!kIsWeb && Platform.isIOS) {
      final iosPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return true;
  }

  /// Format the current date-time nicely
  String _formattedNow() {
    final now = DateTime.now();
    return DateFormat('EEE, d MMM yyyy · h:mm a').format(now);
  }

  /// Android notification details
  AndroidNotificationDetails get _androidDetails {
    return const AndroidNotificationDetails(
      'notes_app_channel',
      'Notes App',
      channelDescription: 'Notifications for note actions',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
  }

  /// Notification details for all platforms
  NotificationDetails get _notificationDetails {
    return NotificationDetails(
      android: _androidDetails,
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Show notification when a note is added
  Future<void> showNoteAdded(String title) async {
    final dateTime = _formattedNow();
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '📝 Note Added',
      '$title\n$dateTime',
      _notificationDetails,
      payload: 'note_added',
    );
  }

  /// Show notification when a note is updated
  Future<void> showNoteUpdated(String title) async {
    final dateTime = _formattedNow();
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '✏️ Note Updated',
      '$title\n$dateTime',
      _notificationDetails,
      payload: 'note_updated',
    );
  }

  /// Show notification when a note is deleted
  Future<void> showNoteDeleted(String title) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🗑️ Note Removed',
      'Note Removed: $title',
      _notificationDetails,
      payload: 'note_deleted',
    );
  }
}
