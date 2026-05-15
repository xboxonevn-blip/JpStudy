import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';
import 'package:jpstudy/data/daos/grammar_dao.dart';
import 'package:jpstudy/data/db/app_database.dart';

void main() {
  late AppDatabase db;
  late GrammarDao dao;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    dao = GrammarDao(db);
  });

  tearDown(() => db.close());

  Future<int> insertGrammarPoint() async {
    return db
        .into(db.grammarPoints)
        .insert(
          GrammarPointsCompanion.insert(
            grammarPoint: 'ている',
            meaning: 'đang',
            connection: 'Vて + いる',
            explanation: 'ongoing action',
            jlptLevel: 'N5',
          ),
        );
  }

  group('getCriticalDueCount', () {
    test('counts due FSRS learning cards regardless of stability', () async {
      final grammarId = await insertGrammarPoint();
      final past = DateTime.now().subtract(const Duration(minutes: 1));
      await dao.initializeSrsState(grammarId);
      await dao.updateSrsState(
        grammarId: grammarId,
        streak: 1,
        ease: 2.5,
        stability: 2.3065,
        difficulty: 5,
        nextReviewAt: past,
        fsrsState: FsrsCardState.learning,
        fsrsStep: 1,
      );

      expect(await dao.getCriticalDueCount(), 1);
    });

    test(
      'does not count due graduated review cards with low stability',
      () async {
        final grammarId = await insertGrammarPoint();
        final past = DateTime.now().subtract(const Duration(minutes: 1));
        await dao.initializeSrsState(grammarId);
        await dao.updateSrsState(
          grammarId: grammarId,
          streak: 1,
          ease: 2.5,
          stability: 0.5,
          difficulty: 5,
          nextReviewAt: past,
          fsrsState: FsrsCardState.review,
          fsrsStep: null,
        );

        expect(await dao.getCriticalDueCount(), 0);
      },
    );
  });
}
