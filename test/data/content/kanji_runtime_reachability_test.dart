import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'all authored kanji entries are reachable through runtime repository',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({
        'onboarding.completed': true,
        'onboarding.level': 'n5',
        'onboarding.goal': 'jlpt',
      });

      final appDb = AppDatabase(executor: NativeDatabase.memory());
      final contentDb = ContentDatabase(executor: NativeDatabase.memory());
      addTearDown(appDb.close);
      addTearDown(contentDb.close);

      final repo = LessonRepository(appDb, contentDb);
      final expected = _scanAuthoredKanjiEntries();

      for (final level in const ['N5', 'N4', 'N3', 'N2', 'N1']) {
        final actual = (await repo.fetchKanjiByLevel(level))
            .map(
              (item) =>
                  _KanjiReachabilityKey(level, item.lessonId, item.character),
            )
            .toSet();
        expect(
          actual,
          expected[level],
          reason:
              'Kanji $level asset entries must seed into the content DB and be '
              'returned by LessonRepository.fetchKanjiByLevel, which backs grid, '
              'search, SRS, reading, and writing practice.',
        );
      }
    },
  );
}

Map<String, Set<_KanjiReachabilityKey>> _scanAuthoredKanjiEntries() {
  final result = {
    for (final level in const ['N5', 'N4', 'N3', 'N2', 'N1'])
      level: <_KanjiReachabilityKey>{},
  };
  final root = Directory('assets/data/content/kanji');
  final files =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final level = _levelFromPath(file);
    if (level == null) continue;
    final payload = jsonDecode(file.readAsStringSync());
    if (payload is! Map<String, dynamic>) continue;
    final entries = payload['entries'];
    if (entries is! List) continue;
    final fallbackLessonId = _lessonIdFromPath(file);

    for (final rawEntry in entries) {
      if (rawEntry is! Map<String, dynamic>) continue;
      final character = (rawEntry['character'] as String?)?.trim();
      if (character == null || character.isEmpty) continue;
      final lessonId = rawEntry['lessonId'] is int
          ? rawEntry['lessonId'] as int
          : fallbackLessonId;
      if (lessonId == null) continue;
      result[level]!.add(_KanjiReachabilityKey(level, lessonId, character));
    }
  }

  return result;
}

String? _levelFromPath(File file) {
  final parts = file.path.replaceAll('\\', '/').split('/');
  final index = parts.indexOf('kanji');
  if (index == -1 || index + 1 >= parts.length) return null;
  final level = parts[index + 1].toUpperCase();
  return RegExp(r'^N[1-5]$').hasMatch(level) ? level : null;
}

int? _lessonIdFromPath(File file) {
  final name = file.uri.pathSegments.last;
  final match = RegExp(r'lesson_(\d+)\.json$').firstMatch(name);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

class _KanjiReachabilityKey {
  const _KanjiReachabilityKey(this.level, this.lessonId, this.character);

  final String level;
  final int lessonId;
  final String character;

  @override
  bool operator ==(Object other) {
    return other is _KanjiReachabilityKey &&
        other.level == level &&
        other.lessonId == lessonId &&
        other.character == character;
  }

  @override
  int get hashCode => Object.hash(level, lessonId, character);

  @override
  String toString() => '$level/$lessonId/$character';
}
