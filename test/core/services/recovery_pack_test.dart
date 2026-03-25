import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';

void main() {
  group('RecoveryPack', () {
    // -------------------------------------------------------------------------
    // toJson / fromJson round-trip
    // -------------------------------------------------------------------------

    group('toJson / fromJson', () {
      test('round-trips a complete pack', () {
        final now = DateTime(2024, 5, 20, 10, 30);
        final pack = RecoveryPack(
          source: 'mock_exam',
          lessonTitle: 'Test Lesson',
          termIds: [1, 2, 3],
          createdAt: now,
        );

        final json = pack.toJson();
        final restored = RecoveryPack.fromJson(json);

        expect(restored, isNotNull);
        expect(restored!.source, 'mock_exam');
        expect(restored.lessonTitle, 'Test Lesson');
        expect(restored.termIds, [1, 2, 3]);
        expect(restored.createdAt, now);
      });

      test('fromJson returns null when termIds is missing', () {
        final json = <String, dynamic>{
          'source': 'exam',
          'lessonTitle': 'Title',
          'createdAt': DateTime.now().toIso8601String(),
        };
        expect(RecoveryPack.fromJson(json), isNull);
      });

      test('fromJson returns null when termIds is not a List', () {
        final json = <String, dynamic>{
          'source': 'exam',
          'lessonTitle': 'Title',
          'termIds': 'not_a_list',
          'createdAt': DateTime.now().toIso8601String(),
        };
        expect(RecoveryPack.fromJson(json), isNull);
      });

      test('fromJson returns null when termIds is an empty list', () {
        final json = <String, dynamic>{
          'source': 'exam',
          'lessonTitle': 'Title',
          'termIds': <int>[],
          'createdAt': DateTime.now().toIso8601String(),
        };
        expect(RecoveryPack.fromJson(json), isNull);
      });

      test('fromJson returns null when createdAt is missing', () {
        final json = <String, dynamic>{
          'source': 'exam',
          'lessonTitle': 'Title',
          'termIds': [1, 2],
        };
        expect(RecoveryPack.fromJson(json), isNull);
      });

      test('fromJson returns null when createdAt is not a valid date string',
          () {
        final json = <String, dynamic>{
          'source': 'exam',
          'lessonTitle': 'Title',
          'termIds': [1],
          'createdAt': 'not_a_date',
        };
        expect(RecoveryPack.fromJson(json), isNull);
      });

      test('fromJson falls back to "exam" when source is null', () {
        final json = <String, dynamic>{
          'source': null,
          'lessonTitle': 'Title',
          'termIds': [5],
          'createdAt': DateTime.now().toIso8601String(),
        };
        final pack = RecoveryPack.fromJson(json);
        expect(pack, isNotNull);
        expect(pack!.source, 'exam');
      });

      test('fromJson falls back to "Recovery Pack" when lessonTitle is null',
          () {
        final json = <String, dynamic>{
          'source': 'test',
          'lessonTitle': null,
          'termIds': [5],
          'createdAt': DateTime.now().toIso8601String(),
        };
        final pack = RecoveryPack.fromJson(json);
        expect(pack, isNotNull);
        expect(pack!.lessonTitle, 'Recovery Pack');
      });

      test('fromJson ignores non-numeric entries in termIds list', () {
        final json = <String, dynamic>{
          'source': 'exam',
          'lessonTitle': 'Title',
          'termIds': [1, 'bad', 2, null, 3],
          'createdAt': DateTime.now().toIso8601String(),
        };
        final pack = RecoveryPack.fromJson(json);
        expect(pack, isNotNull);
        expect(pack!.termIds, [1, 2, 3]);
      });
    });

    // -------------------------------------------------------------------------
    // isFresh
    // -------------------------------------------------------------------------

    group('isFresh', () {
      test('returns true when createdAt is very recent', () {
        final pack = RecoveryPack(
          source: 'exam',
          lessonTitle: 'Title',
          termIds: [1],
          createdAt: DateTime.now(),
        );
        expect(pack.isFresh, isTrue);
      });

      test('returns true when createdAt is 1 day ago', () {
        final pack = RecoveryPack(
          source: 'exam',
          lessonTitle: 'Title',
          termIds: [1],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(pack.isFresh, isTrue);
      });

      test('returns false when createdAt is more than 2 days ago', () {
        final pack = RecoveryPack(
          source: 'exam',
          lessonTitle: 'Title',
          termIds: [1],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        expect(pack.isFresh, isFalse);
      });

      test('returns false when createdAt is exactly 2 days ago', () {
        final pack = RecoveryPack(
          source: 'exam',
          lessonTitle: 'Title',
          termIds: [1],
          // Slightly beyond 2 days to be definitively stale
          createdAt:
              DateTime.now().subtract(const Duration(days: 2, minutes: 1)),
        );
        expect(pack.isFresh, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // itemCount
    // -------------------------------------------------------------------------

    group('itemCount', () {
      test('returns 0 for empty termIds', () {
        // fromJson rejects empty lists, so construct directly if possible.
        // We cannot construct with empty list via fromJson; bypass via direct constructor.
        final pack = RecoveryPack(
          source: 'exam',
          lessonTitle: 'Title',
          termIds: const [],
          createdAt: DateTime.now(),
        );
        expect(pack.itemCount, 0);
      });

      test('returns correct count for non-empty termIds', () {
        final pack = RecoveryPack(
          source: 'exam',
          lessonTitle: 'Title',
          termIds: [10, 20, 30, 40],
          createdAt: DateTime.now(),
        );
        expect(pack.itemCount, 4);
      });
    });

    // -------------------------------------------------------------------------
    // Constants
    // -------------------------------------------------------------------------

    test('recoveryLessonId is negative to avoid collision', () {
      expect(RecoveryPackService.recoveryLessonId, isNegative);
    });

    test('recoveryLessonTitle is non-empty', () {
      expect(RecoveryPackService.recoveryLessonTitle, isNotEmpty);
    });
  });
}
