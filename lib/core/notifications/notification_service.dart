import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  // Lazy-loaded plugin to avoid loading native libraries on unsupported platforms
  FlutterLocalNotificationsPlugin? _pluginInstance;
  FlutterLocalNotificationsPlugin get _plugin {
    _pluginInstance ??= FlutterLocalNotificationsPlugin();
    return _pluginInstance!;
  }

  static const int _dailyReminderId = 1001;

  bool get isSupported => !kIsWeb;

  /// Whether native OS notifications are supported on this platform.
  /// Web and Windows do not support native notifications.
  bool get _supportsNativeNotifications => !kIsWeb;

  Future<void> initialize() async {
    if (!_supportsNativeNotifications) {
      // Windows: Skip native plugin, use in-app reminders instead
      return;
    }
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(initSettings);
  }

  Future<void> enableDailyReminder({
    required String title,
    required String body,
  }) async {
    if (!_supportsNativeNotifications) {
      return;
    }
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily reminder',
      channelDescription: 'Daily study reminder',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.periodicallyShow(
      _dailyReminderId,
      title,
      body,
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> disableDailyReminder() async {
    if (!_supportsNativeNotifications) {
      return;
    }
    await _plugin.cancel(_dailyReminderId);
  }

  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    if (!_supportsNativeNotifications) {
      return;
    }
    const androidDetails = AndroidNotificationDetails(
      'test_reminder',
      'Test reminder',
      channelDescription: 'Test notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(9999, title, body, details);
  }
}
