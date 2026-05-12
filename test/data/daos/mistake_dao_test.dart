import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/mistake_dao.dart';

void main() {
  late AppDatabase db;
  late MistakeDao dao;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    dao = MistakeDao(db);
  });

  tearDown(() => db.close());

  // ---------------------------------------------------------------------------
  // addMistake
  // ---------------------------------------------------------------------------

  group('addMistake', () {
    test('inserts a new mistake and can be retrieved', () async {
      await dao.addMistake('vocab', 1);
      final mistakes = await dao.getMistakesByType('vocab');
      expect(mistakes, hasLength(1));
      expect(mistakes.first.itemId, 1);
      expect(mistakes.first.type, 'vocab');
    });

    test('increments wrongCount on duplicate insert', () async {
      await dao.addMistake('vocab', 1);
      await dao.addMistake('vocab', 1);
      final mistakes = await dao.getMistakesByType('vocab');
      expect(mistakes, hasLength(1));
      // First insert sets wrongCount = requiredCorrectStreak (2),
      // then on conflict increments by 1 → 3.
      expect(
        mistakes.first.wrongCount,
        greaterThan(MistakeDao.requiredCorrectStreak),
      );
    });

    test('stores context fields when provided', () async {
      await dao.addMistake(
        'grammar',
        10,
        prompt: 'What does ～ても mean?',
        correctAnswer: 'even if',
        userAnswer: 'although',
        source: 'practice',
        extraJson: '{"level":"N4"}',
      );
      final mistakes = await dao.getMistakesByType('grammar');
      expect(mistakes, hasLength(1));
      final m = mistakes.first;
      expect(m.prompt, 'What does ～ても mean?');
      expect(m.correctAnswer, 'even if');
      expect(m.userAnswer, 'although');
      expect(m.source, 'practice');
      expect(m.extraJson, '{"level":"N4"}');
    });

    test(
      'different type+itemId combinations are stored as separate rows',
      () async {
        await dao.addMistake('vocab', 1);
        await dao.addMistake('grammar', 1);
        await dao.addMistake('vocab', 2);

        final all = await dao.getAllMistakes();
        expect(all, hasLength(3));
      },
    );

    test('null context fields are accepted', () async {
      await dao.addMistake('kanji', 5);
      final mistakes = await dao.getMistakesByType('kanji');
      expect(mistakes, hasLength(1));
      expect(mistakes.first.prompt, isNull);
      expect(mistakes.first.correctAnswer, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // removeMistake
  // ---------------------------------------------------------------------------

  group('removeMistake', () {
    test('removes an existing mistake', () async {
      await dao.addMistake('vocab', 1);
      await dao.removeMistake('vocab', 1);
      final mistakes = await dao.getMistakesByType('vocab');
      expect(mistakes, isEmpty);
    });

    test('does not throw when removing non-existent mistake', () async {
      // Should be a no-op
      await dao.removeMistake('vocab', 999);
      final all = await dao.getAllMistakes();
      expect(all, isEmpty);
    });

    test('removes only the matching type+itemId', () async {
      await dao.addMistake('vocab', 1);
      await dao.addMistake('vocab', 2);
      await dao.removeMistake('vocab', 1);

      final mistakes = await dao.getMistakesByType('vocab');
      expect(mistakes, hasLength(1));
      expect(mistakes.first.itemId, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // markCorrect
  // ---------------------------------------------------------------------------

  group('markCorrect', () {
    test('is a no-op for unknown mistake', () async {
      await dao.markCorrect('vocab', 999);
      final all = await dao.getAllMistakes();
      expect(all, isEmpty);
    });

    test('removes mistake when wrongCount reaches 1', () async {
      // Add once so wrongCount = requiredCorrectStreak (2).
      await dao.addMistake('vocab', 1);
      // First markCorrect: 2 → 1
      await dao.markCorrect('vocab', 1);
      // wrongCount is now 1, next markCorrect should remove it
      await dao.markCorrect('vocab', 1);

      final mistakes = await dao.getMistakesByType('vocab');
      expect(mistakes, isEmpty);
    });

    test('decrements wrongCount when > 1', () async {
      // Add three times to get wrongCount = 2 + 2 increments = 4
      await dao.addMistake('vocab', 1);
      await dao.addMistake('vocab', 1);
      await dao.addMistake('vocab', 1);
      final before = (await dao.getMistakesByType('vocab')).first.wrongCount;

      await dao.markCorrect('vocab', 1);

      final after = (await dao.getMistakesByType('vocab')).first.wrongCount;
      expect(after, before - 1);
    });

    // Pins the WHERE clause — a refactor that accidentally broadens the filter
    // (e.g. drops the itemId predicate) would decrement/delete sibling rows
    // and silently corrupt the SRS bucket.
    test('does not affect sibling rows with a different itemId', () async {
      await dao.addMistake('vocab', 1);
      await dao.addMistake('vocab', 2);
      // Bump item 1 to wrongCount=3 so markCorrect decrements (not deletes).
      await dao.addMistake('vocab', 1);

      await dao.markCorrect('vocab', 1);

      final rows = await dao.getMistakesByType('vocab');
      expect(rows, hasLength(2));
      final item2 = rows.firstWhere((m) => m.itemId == 2);
      // item 2 must be untouched: wrongCount == requiredCorrectStreak (the
      // value set on initial insert).
      expect(item2.wrongCount, MistakeDao.requiredCorrectStreak);
    });

    // Same WHERE-clause invariant, but across types — a cross-type regression
    // would e.g. decrement a vocab mistake when the user answered a grammar
    // question with the same id correctly.
    test('does not affect rows with a different type', () async {
      await dao.addMistake('vocab', 1);
      await dao.addMistake('grammar', 1);

      // vocab starts at wrongCount = requiredCorrectStreak (2). markCorrect
      // decrements to 1; grammar must be untouched.
      await dao.markCorrect('vocab', 1);

      final vocab = await dao.getMistakesByType('vocab');
      expect(vocab, hasLength(1));
      expect(vocab.first.wrongCount, 1);

      final grammar = await dao.getMistakesByType('grammar');
      expect(grammar, hasLength(1));
      expect(grammar.first.wrongCount, MistakeDao.requiredCorrectStreak);
    });

    // Pins that markCorrect refreshes lastMistakeAt on each decrement. The
    // column feeds mistake-page recency ordering (watchAllMistakes orderBy),
    // so a refactor dropping the timestamp write would silently change the
    // order users see their mistakes in.
    //
    // NOTE: this compares two markCorrect calls (not addMistake → markCorrect)
    // because addMistake's raw SQL writes ms-since-epoch while Drift's
    // DateTimeColumn default decodes as seconds-since-epoch — an unrelated
    // encoding bug in addMistake that would otherwise mask this assertion.
    // Drift's default DateTime storage is 1s precision, so we wait > 1s.
    test('refreshes lastMistakeAt on each decrement', () async {
      // Seed wrongCount high enough for two decrement-path markCorrect calls.
      // addMistake x3 → wrongCount = 2 (init) + 1 + 1 = 4.
      await dao.addMistake('vocab', 1);
      await dao.addMistake('vocab', 1);
      await dao.addMistake('vocab', 1);

      // First decrement (wrongCount 4 → 3). Both writes from here on go
      // through Drift's encoder, so the stored integers are comparable.
      await dao.markCorrect('vocab', 1);
      final before = (await dao.getMistakesByType('vocab')).first.lastMistakeAt;

      await Future<void>.delayed(const Duration(milliseconds: 1100));

      // Second decrement (wrongCount 3 → 2) must refresh the timestamp.
      await dao.markCorrect('vocab', 1);
      final after = (await dao.getMistakesByType('vocab')).first.lastMistakeAt;

      expect(
        after.isAfter(before),
        isTrue,
        reason: 'second markCorrect must refresh lastMistakeAt',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getMistakesByType
  // ---------------------------------------------------------------------------

  group('getMistakesByType', () {
    test('returns empty list when no mistakes of that type', () async {
      final result = await dao.getMistakesByType('kanji');
      expect(result, isEmpty);
    });

    test('filters by type correctly', () async {
      await dao.addMistake('vocab', 1);
      await dao.addMistake('grammar', 2);
      await dao.addMistake('vocab', 3);

      final vocabMistakes = await dao.getMistakesByType('vocab');
      expect(vocabMistakes, hasLength(2));
      expect(vocabMistakes.every((m) => m.type == 'vocab'), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getAllMistakes
  // ---------------------------------------------------------------------------

  group('getAllMistakes', () {
    test('returns empty list when no mistakes', () async {
      final all = await dao.getAllMistakes();
      expect(all, isEmpty);
    });

    test('returns all mistakes across all types', () async {
      await dao.addMistake('vocab', 1);
      await dao.addMistake('grammar', 2);
      await dao.addMistake('kanji', 3);

      final all = await dao.getAllMistakes();
      expect(all, hasLength(3));
    });
  });

  // ---------------------------------------------------------------------------
  // watchTotalMistakes
  // ---------------------------------------------------------------------------

  group('watchTotalMistakes', () {
    test('emits 0 when no mistakes exist', () async {
      final total = await dao.watchTotalMistakes().first;
      expect(total, 0);
    });

    test('sums wrongCount across all mistakes', () async {
      // Each addMistake creates a row with wrongCount = requiredCorrectStreak (2).
      await dao.addMistake('vocab', 1);
      await dao.addMistake('grammar', 2);

      final total = await dao.watchTotalMistakes().first;
      // 2 rows × requiredCorrectStreak (2) = 4
      expect(total, MistakeDao.requiredCorrectStreak * 2);
    });

    test('updates when a mistake is removed', () async {
      await dao.addMistake('vocab', 1);
      final beforeRemoval = await dao.watchTotalMistakes().first;
      expect(beforeRemoval, MistakeDao.requiredCorrectStreak);

      await dao.removeMistake('vocab', 1);
      final afterRemoval = await dao.watchTotalMistakes().first;
      expect(afterRemoval, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // watchMistakeItemCount
  // ---------------------------------------------------------------------------

  group('watchMistakeItemCount', () {
    test('emits 0 when no mistakes', () async {
      final count = await dao.watchMistakeItemCount().first;
      expect(count, 0);
    });

    test('counts unique items across all types when no filter', () async {
      await dao.addMistake('vocab', 1);
      await dao.addMistake('grammar', 2);
      await dao.addMistake('kanji', 3);

      final count = await dao.watchMistakeItemCount().first;
      expect(count, 3);
    });

    test('filters by type when type parameter is provided', () async {
      await dao.addMistake('vocab', 1);
      await dao.addMistake('vocab', 2);
      await dao.addMistake('grammar', 3);

      final vocabCount = await dao.watchMistakeItemCount(type: 'vocab').first;
      expect(vocabCount, 2);

      final grammarCount = await dao
          .watchMistakeItemCount(type: 'grammar')
          .first;
      expect(grammarCount, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // watchAllMistakes
  // ---------------------------------------------------------------------------

  group('watchAllMistakes', () {
    test('emits empty list when no mistakes', () async {
      final list = await dao.watchAllMistakes().first;
      expect(list, isEmpty);
    });

    test('emits all mistakes ordered by lastMistakeAt desc', () async {
      await dao.addMistake('vocab', 1);
      // Add a slight delay to get distinct timestamps
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await dao.addMistake('grammar', 2);

      final list = await dao.watchAllMistakes().first;
      expect(list, hasLength(2));
      // Most recent first
      expect(list.first.type, 'grammar');
    });
  });
}
