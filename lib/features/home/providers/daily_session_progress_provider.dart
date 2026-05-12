import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dailySessionPrefPrefix = 'daily.session';
const _dailySessionRefreshKey = 'daily.session.refresh';

final dailySessionRefreshProvider = StateProvider<int>((ref) => 0);

final _dailySessionClockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  while (true) {
    await Future<void>.delayed(const Duration(minutes: 15));
    yield DateTime.now();
  }
});

final dailySessionProgressProvider = FutureProvider<DailySessionProgress>((
  ref,
) async {
  ref.watch(dailySessionRefreshProvider);
  ref.watch(_dailySessionClockProvider);
  return DailySessionProgressStore.loadToday();
});

void refreshDailySessionProgress(WidgetRef ref) {
  final current = ref.read(dailySessionRefreshProvider);
  ref.read(dailySessionRefreshProvider.notifier).state = current + 1;
}

class DailySessionProgressStore {
  const DailySessionProgressStore._();

  static Future<DailySessionProgress> loadToday() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    final storedDate = prefs.getString('$_dailySessionPrefPrefix.date');

    if (storedDate != todayKey) {
      await _resetForDate(prefs, todayKey);
      return DailySessionProgress.empty(todayKey);
    }

    final started = prefs.getBool('$_dailySessionPrefPrefix.started') ?? false;
    final doneSteps = _decodeDoneSteps(
      prefs.getString('$_dailySessionPrefPrefix.doneSteps'),
    );
    final lastRoute = prefs.getString('$_dailySessionPrefPrefix.lastRoute');
    final updatedAtRaw = prefs.getString('$_dailySessionPrefPrefix.updatedAt');
    final updatedAt = updatedAtRaw == null
        ? null
        : DateTime.tryParse(updatedAtRaw);

    return DailySessionProgress(
      dateKey: todayKey,
      started: started,
      doneSteps: doneSteps,
      lastRoute: lastRoute,
      updatedAt: updatedAt,
    );
  }

  static Future<void> startSession({String? route}) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    await _ensureDate(prefs, todayKey);
    await prefs.setBool('$_dailySessionPrefPrefix.started', true);
    if (route != null && route.isNotEmpty) {
      await prefs.setString('$_dailySessionPrefPrefix.lastRoute', route);
    }
    await prefs.setString(
      '$_dailySessionPrefPrefix.updatedAt',
      DateTime.now().toIso8601String(),
    );
  }

  static Future<void> setLastRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    await _ensureDate(prefs, todayKey);
    await prefs.setString('$_dailySessionPrefPrefix.lastRoute', route);
    await prefs.setString(
      '$_dailySessionPrefPrefix.updatedAt',
      DateTime.now().toIso8601String(),
    );
  }

  static Future<void> markStepDone(int step) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    await _ensureDate(prefs, todayKey);
    final current = _decodeDoneSteps(
      prefs.getString('$_dailySessionPrefPrefix.doneSteps'),
    );
    if (current.contains(step)) {
      return;
    }
    current.add(step);
    await prefs.setString(
      '$_dailySessionPrefPrefix.doneSteps',
      jsonEncode(current.toList()..sort()),
    );
    await prefs.setString(
      '$_dailySessionPrefPrefix.updatedAt',
      DateTime.now().toIso8601String(),
    );
  }

  static Future<void> completeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    await _ensureDate(prefs, todayKey);
    await prefs.setString('$_dailySessionPrefPrefix.doneSteps', '[1,2,3]');
    await prefs.setString(
      '$_dailySessionPrefPrefix.updatedAt',
      DateTime.now().toIso8601String(),
    );
  }

  static Set<int> _decodeDoneSteps(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <int>{};
    }
    try {
      final list = (jsonDecode(raw) as List<dynamic>).whereType<num>();
      return list.map((value) => value.toInt()).toSet();
    } catch (_) {
      return <int>{};
    }
  }

  static Future<void> _ensureDate(
    SharedPreferences prefs,
    String todayKey,
  ) async {
    final storedDate = prefs.getString('$_dailySessionPrefPrefix.date');
    if (storedDate == todayKey) {
      return;
    }
    await _resetForDate(prefs, todayKey);
  }

  static Future<void> _resetForDate(
    SharedPreferences prefs,
    String todayKey,
  ) async {
    await prefs.setString('$_dailySessionPrefPrefix.date', todayKey);
    await prefs.setBool('$_dailySessionPrefPrefix.started', false);
    await prefs.setString('$_dailySessionPrefPrefix.doneSteps', '[]');
    await prefs.remove('$_dailySessionPrefPrefix.lastRoute');
    await prefs.remove('$_dailySessionPrefPrefix.updatedAt');
    final refresh = prefs.getInt(_dailySessionRefreshKey) ?? 0;
    await prefs.setInt(_dailySessionRefreshKey, refresh + 1);
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class DailySessionProgress {
  const DailySessionProgress({
    required this.dateKey,
    required this.started,
    required this.doneSteps,
    required this.lastRoute,
    required this.updatedAt,
  });

  factory DailySessionProgress.empty(String dateKey) {
    return DailySessionProgress(
      dateKey: dateKey,
      started: false,
      doneSteps: const <int>{},
      lastRoute: null,
      updatedAt: null,
    );
  }

  final String dateKey;
  final bool started;
  final Set<int> doneSteps;
  final String? lastRoute;
  final DateTime? updatedAt;

  int completionPercent({bool step1Done = false, bool step2Done = false}) {
    final completed = {...doneSteps, if (step1Done) 1, if (step2Done) 2};
    return ((completed.length.clamp(0, 3) / 3) * 100).round();
  }

  bool get isComplete =>
      doneSteps.contains(1) && doneSteps.contains(2) && doneSteps.contains(3);
}
