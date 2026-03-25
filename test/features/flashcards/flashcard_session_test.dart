import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/flashcards/models/flashcard_session.dart';

void main() {
  FlashcardSession _session({
    List<int> known = const [],
    List<int> needPractice = const [],
    List<int> starred = const [],
    List<int> skipped = const [],
    DateTime? completedAt,
    DateTime? startedAt,
  }) {
    return FlashcardSession(
      sessionId: 'test-session',
      lessonId: 1,
      startedAt: startedAt ?? DateTime(2024, 6, 1, 10, 0),
      completedAt: completedAt,
      knownTermIds: known.toList(),
      needPracticeTermIds: needPractice.toList(),
      starredTermIds: starred.toList(),
      skippedTermIds: skipped.toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // totalSeen
  // ---------------------------------------------------------------------------

  group('totalSeen', () {
    test('returns 0 when all lists are empty', () {
      final session = _session();
      expect(session.totalSeen, 0);
    });

    test('counts known + needPractice + skipped (excludes starred)', () {
      final session = _session(
        known: [1, 2],
        needPractice: [3],
        skipped: [4, 5],
        starred: [10, 11, 12], // not counted
      );
      expect(session.totalSeen, 5);
    });

    test('only known terms', () {
      final session = _session(known: [1, 2, 3]);
      expect(session.totalSeen, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // accuracy
  // ---------------------------------------------------------------------------

  group('accuracy', () {
    test('returns 0.0 when totalSeen is 0', () {
      final session = _session();
      expect(session.accuracy, 0.0);
    });

    test('returns 1.0 when all seen terms are known', () {
      final session = _session(known: [1, 2, 3]);
      expect(session.accuracy, 1.0);
    });

    test('returns 0.0 when no known terms but some seen', () {
      final session = _session(needPractice: [1, 2]);
      expect(session.accuracy, 0.0);
    });

    test('returns correct fraction', () {
      // 3 known / (3 known + 1 needPractice + 1 skipped) = 3/5 = 0.6
      final session = _session(
        known: [1, 2, 3],
        needPractice: [4],
        skipped: [5],
      );
      expect(session.accuracy, closeTo(0.6, 0.001));
    });
  });

  // ---------------------------------------------------------------------------
  // duration
  // ---------------------------------------------------------------------------

  group('duration', () {
    test('returns null when completedAt is null', () {
      final session = _session();
      expect(session.duration, isNull);
    });

    test('returns correct duration when session is completed', () {
      final started = DateTime(2024, 6, 1, 10, 0);
      final ended = DateTime(2024, 6, 1, 10, 8);
      final session = _session(startedAt: started, completedAt: ended);
      expect(session.duration, const Duration(minutes: 8));
    });
  });

  // ---------------------------------------------------------------------------
  // isComplete
  // ---------------------------------------------------------------------------

  group('isComplete', () {
    test('returns false when completedAt is null', () {
      final session = _session();
      expect(session.isComplete, isFalse);
    });

    test('returns true when completedAt is set', () {
      final session = _session(completedAt: DateTime.now());
      expect(session.isComplete, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // calculateXP
  // ---------------------------------------------------------------------------

  group('calculateXP', () {
    test('returns 0 when no known terms', () {
      final session = _session();
      expect(session.calculateXP(), 0);
    });

    test('base XP is 5 per known term with accuracy bonus applied', () {
      // 3 known, 0 others → accuracy = 100% → accuracy bonus of 20 applies
      // base: 3 * 5 = 15, accuracy bonus: +20, no duration → total 35
      final session = _session(known: [1, 2, 3]);
      expect(session.calculateXP(), 35);
    });

    test('adds 20 bonus when accuracy >= 90%', () {
      // 9 known / 10 total = 90% → bonus applies
      final session = _session(
        known: [1, 2, 3, 4, 5, 6, 7, 8, 9],
        needPractice: [10],
      );
      // base: 9 * 5 = 45, accuracy bonus: 20 → 65
      expect(session.calculateXP(), 65);
    });

    test('no accuracy bonus when accuracy < 90%', () {
      final session = _session(
        known: [1, 2],
        needPractice: [3, 4, 5], // 2/5 = 40%
      );
      // base: 2 * 5 = 10, no bonus
      expect(session.calculateXP(), 10);
    });

    test('adds 10 bonus when session took under 10 minutes', () {
      final started = DateTime(2024, 6, 1, 10, 0);
      final ended = DateTime(2024, 6, 1, 10, 5); // 5 minutes
      final session = _session(
        known: [1],
        startedAt: started,
        completedAt: ended,
      );
      // base: 5, accuracy: 1/1 = 100% → +20, speed bonus: +10 → 35
      expect(session.calculateXP(), 35);
    });

    test('no speed bonus when session took 10+ minutes', () {
      final started = DateTime(2024, 6, 1, 10, 0);
      final ended = DateTime(2024, 6, 1, 10, 15); // 15 minutes
      final session = _session(
        known: [1],
        startedAt: started,
        completedAt: ended,
      );
      // base: 5, accuracy bonus: +20, no speed bonus → 25
      expect(session.calculateXP(), 25);
    });

    test('no speed bonus when duration is null', () {
      final session = _session(known: [1]);
      // base: 5, accuracy 1/1 = 100% → +20, no speed bonus → 25
      expect(session.calculateXP(), 25);
    });
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  group('copyWith', () {
    test('creates new session with updated knownTermIds', () {
      final original = _session(known: [1, 2]);
      final updated = original.copyWith(knownTermIds: [1, 2, 3]);

      expect(updated.knownTermIds, [1, 2, 3]);
      expect(original.knownTermIds, [1, 2]); // Original unchanged
    });

    test('preserves unchanged fields', () {
      final original = _session(known: [1], needPractice: [2]);
      final updated = original.copyWith(knownTermIds: [1, 3]);

      expect(updated.needPracticeTermIds, [2]);
      expect(updated.lessonId, 1);
      expect(updated.sessionId, 'test-session');
    });

    test('can set completedAt via copyWith', () {
      final original = _session();
      expect(original.isComplete, isFalse);

      final completed = original.copyWith(completedAt: DateTime.now());
      expect(completed.isComplete, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Default list initialization
  // ---------------------------------------------------------------------------

  group('default list initialization', () {
    test('all term lists default to empty when not provided', () {
      final session = FlashcardSession(
        sessionId: 'x',
        lessonId: 1,
        startedAt: DateTime.now(),
      );
      expect(session.knownTermIds, isEmpty);
      expect(session.needPracticeTermIds, isEmpty);
      expect(session.starredTermIds, isEmpty);
      expect(session.skippedTermIds, isEmpty);
    });
  });
}
