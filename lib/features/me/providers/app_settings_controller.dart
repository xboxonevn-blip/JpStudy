import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/notifications/notification_service.dart';

const _prefDailyReminder = 'notifications.daily';
const _prefDailyReminderTime = 'notifications.daily.time';
const _prefDailyReminderLast = 'notifications.daily.last';
const _prefStrokeGuideDefaultExpanded =
    'write.handwriting.strokeGuide.defaultExpanded';

final appSettingsControllerProvider =
    NotifierProvider<AppSettingsController, AppSettingsState>(
      AppSettingsController.new,
    );

class AppSettingsState {
  const AppSettingsState({
    this.isReady = false,
    this.reminderEnabled = false,
    this.reminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.strokeGuideDefaultExpanded = true,
  });

  final bool isReady;
  final bool reminderEnabled;
  final TimeOfDay reminderTime;
  final bool strokeGuideDefaultExpanded;

  AppSettingsState copyWith({
    bool? isReady,
    bool? reminderEnabled,
    TimeOfDay? reminderTime,
    bool? strokeGuideDefaultExpanded,
  }) {
    return AppSettingsState(
      isReady: isReady ?? this.isReady,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      strokeGuideDefaultExpanded:
          strokeGuideDefaultExpanded ?? this.strokeGuideDefaultExpanded,
    );
  }
}

class AppSettingsController extends Notifier<AppSettingsState> {
  Timer? _inAppReminderTimer;
  SharedPreferences? _prefs;
  BuildContext? _hostContext;
  Future<void>? _initializeFuture;
  bool _disposed = false;

  @override
  AppSettingsState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _initializeFuture = null;
      _inAppReminderTimer?.cancel();
      _hostContext = null;
    });
    return const AppSettingsState();
  }

  bool get supportsNotifications => NotificationService.instance.isSupported;

  void bindHostContext(BuildContext context) {
    _hostContext = context;
    if (!state.isReady) {
      unawaited(initialize(hostContext: context));
    }
  }

  void unbindHostContext(BuildContext context) {
    if (_hostContext == context) {
      _hostContext = null;
    }
  }

  Future<void> initialize({BuildContext? hostContext}) async {
    if (hostContext != null) {
      _hostContext = hostContext;
    }
    if (state.isReady) {
      return;
    }
    final pending = _initializeFuture;
    if (pending != null) {
      await pending;
      return;
    }

    final tracked = refresh().whenComplete(() {
      _initializeFuture = null;
    });
    _initializeFuture = tracked;
    await tracked;
  }

  Future<void> refresh() async {
    final prefs = await _ensurePrefs();
    if (_disposed) {
      return;
    }
    state = state.copyWith(
      isReady: true,
      reminderEnabled: prefs.getBool(_prefDailyReminder) ?? false,
      reminderTime:
          _reminderTimeFromPrefs(prefs) ?? const TimeOfDay(hour: 20, minute: 0),
      strokeGuideDefaultExpanded:
          prefs.getBool(_prefStrokeGuideDefaultExpanded) ?? true,
    );
    _syncReminderSchedule();
  }

  Future<void> setStrokeGuideDefaultExpanded(bool value) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool(_prefStrokeGuideDefaultExpanded, value);
    state = state.copyWith(strokeGuideDefaultExpanded: value, isReady: true);
  }

  Future<void> setDailyReminder(bool enabled, AppLanguage language) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool(_prefDailyReminder, enabled);

    if (supportsNotifications) {
      if (enabled) {
        await NotificationService.instance.enableDailyReminder(
          title: language.reminderTitle,
          body: language.reminderBody,
        );
      } else {
        await NotificationService.instance.disableDailyReminder();
      }
    } else if (enabled) {
      _scheduleInAppReminder();
    } else {
      _inAppReminderTimer?.cancel();
    }

    state = state.copyWith(reminderEnabled: enabled, isReady: true);
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    final prefs = await _ensurePrefs();
    await _saveReminderTime(prefs, time);
    state = state.copyWith(reminderTime: time, isReady: true);
    if (state.reminderEnabled && !supportsNotifications) {
      _scheduleInAppReminder();
    }
  }

  Future<void> testReminder(
    AppLanguage language, {
    BuildContext? context,
  }) async {
    if (supportsNotifications) {
      await NotificationService.instance.showTestNotification(
        title: language.reminderTitle,
        body: language.reminderTestBody,
      );
      return;
    }
    _showSnackBar(context ?? _hostContext, language.reminderBody);
  }

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  void _syncReminderSchedule() {
    if (state.reminderEnabled && !supportsNotifications) {
      _scheduleInAppReminder();
    } else {
      _inAppReminderTimer?.cancel();
    }
  }

  void _scheduleInAppReminder() {
    _inAppReminderTimer?.cancel();
    if (_disposed || !state.reminderEnabled) {
      return;
    }

    final now = DateTime.now();
    final next = _nextReminderTime(now, state.reminderTime);
    _inAppReminderTimer = Timer(next.difference(now), _handleInAppReminder);
  }

  Future<void> _handleInAppReminder() async {
    final prefs = await _ensurePrefs();
    if (_disposed) {
      return;
    }
    final todayKey = _dateKey(DateTime.now());
    final lastShown = prefs.getString(_prefDailyReminderLast);
    if (lastShown != todayKey) {
      await prefs.setString(_prefDailyReminderLast, todayKey);
      if (_disposed) {
        return;
      }
      _showSnackBar(_hostContext, ref.read(appLanguageProvider).reminderBody);
    }
    _scheduleInAppReminder();
  }

  DateTime _nextReminderTime(DateTime now, TimeOfDay time) {
    var next = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  TimeOfDay? _reminderTimeFromPrefs(SharedPreferences prefs) {
    final stored = prefs.getString(_prefDailyReminderTime);
    if (stored == null || stored.isEmpty) {
      return null;
    }
    final parts = stored.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _saveReminderTime(
    SharedPreferences prefs,
    TimeOfDay time,
  ) async {
    final value =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_prefDailyReminderTime, value);
  }

  String _dateKey(DateTime time) {
    return '${time.year.toString().padLeft(4, '0')}-'
        '${time.month.toString().padLeft(2, '0')}-'
        '${time.day.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(BuildContext? context, String message) {
    if (context == null || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
