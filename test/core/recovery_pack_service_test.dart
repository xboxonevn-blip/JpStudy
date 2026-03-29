import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // ── RecoveryPack.fromJson ─────────────────────────────────────────────────

  group('RecoveryPack.fromJson', () {
    Map<String, dynamic> valid({
      List<int> ids = const [1, 2, 3],
      String? createdAt,
    }) => {
      'source': 'mock_exam',
      'lessonTitle': 'Lesson 1',
      'termIds': ids,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };

    test('parses valid json', () {
      final pack = RecoveryPack.fromJson(valid());
      expect(pack, isNotNull);
      expect(pack!.termIds, [1, 2, 3]);
      expect(pack.source, 'mock_exam');
    });

    test('returns null when termIds is not a list', () {
      final json = valid()..['termIds'] = 'bad';
      expect(RecoveryPack.fromJson(json), isNull);
    });

    test('returns null when termIds is empty', () {
      final json = valid(ids: []);
      expect(RecoveryPack.fromJson(json), isNull);
    });

    test('returns null when createdAt is invalid', () {
      final json = valid()..['createdAt'] = 'not-a-date';
      expect(RecoveryPack.fromJson(json), isNull);
    });

    test('falls back to default source and lessonTitle when missing', () {
      final json = {'termIds': [5], 'createdAt': DateTime.now().toIso8601String()};
      final pack = RecoveryPack.fromJson(json)!;
      expect(pack.source, 'exam');
      expect(pack.lessonTitle, 'Recovery Pack');
    });
  });

  // ── RecoveryPack.isFresh ──────────────────────────────────────────────────

  group('RecoveryPack.isFresh', () {
    RecoveryPack pack0(DateTime createdAt) => RecoveryPack(
          source: 'mock_exam',
          lessonTitle: 'L1',
          termIds: [1],
          createdAt: createdAt,
        );

    test('fresh when created now', () {
      expect(pack0(DateTime.now()).isFresh, isTrue);
    });

    test('fresh when created 1 day ago', () {
      expect(pack0(DateTime.now().subtract(const Duration(days: 1))).isFresh, isTrue);
    });

    test('stale when created 3 days ago', () {
      expect(pack0(DateTime.now().subtract(const Duration(days: 3))).isFresh, isFalse);
    });
  });

  // ── RecoveryPackService.saveExamPack / load / clear ───────────────────────

  group('RecoveryPackService', () {
    test('save and load returns same termIds (deduped + sorted)', () async {
      await RecoveryPackService.saveExamPack(
        lessonTitle: 'Lesson A',
        termIds: [3, 1, 2, 1],
      );
      final pack = await RecoveryPackService.load();
      expect(pack, isNotNull);
      expect(pack!.termIds, [1, 2, 3]);
    });

    test('save with empty ids clears the pack', () async {
      await RecoveryPackService.saveExamPack(lessonTitle: 'L', termIds: [1]);
      await RecoveryPackService.saveExamPack(lessonTitle: 'L', termIds: []);
      expect(await RecoveryPackService.load(), isNull);
    });

    test('uses default title when lessonTitle is blank', () async {
      await RecoveryPackService.saveExamPack(lessonTitle: '  ', termIds: [1]);
      final pack = await RecoveryPackService.load();
      expect(pack!.lessonTitle, RecoveryPackService.recoveryLessonTitle);
    });

    test('clear removes the pack', () async {
      await RecoveryPackService.saveExamPack(lessonTitle: 'L', termIds: [1]);
      await RecoveryPackService.clear();
      expect(await RecoveryPackService.load(), isNull);
    });

    test('load returns null when nothing saved', () async {
      expect(await RecoveryPackService.load(), isNull);
    });
  });
}
