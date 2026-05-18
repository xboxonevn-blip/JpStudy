import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/jlpt/data/jlpt_mock_bank.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _EmptyLessonRepository extends LessonRepository {
  _EmptyLessonRepository(super.db, super.contentDb);

  @override
  Future<List<VocabItem>> getVocabByLevel(String level) async => const [];

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async => const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'JLPT mock grammar section seeds requested level even when active level differs',
    () async {
      SharedPreferences.setMockInitialValues({'onboarding.level': 'N5'});
      final appDb = AppDatabase(executor: NativeDatabase.memory());
      final contentDb = ContentDatabase(executor: NativeDatabase.memory());
      final repo = _EmptyLessonRepository(appDb, contentDb);
      addTearDown(contentDb.close);
      addTearDown(appDb.close);

      final sections = await buildJlptMockSections(
        level: StudyLevel.n4,
        language: AppLanguage.en,
        contentDb: contentDb,
        lessonRepo: repo,
        random: Random(1),
      );

      expect(sections.map((section) => section.id), contains('grammar'));
    },
  );

  test(
    'JLPT mock grammar section reuses shared grammar practice bank questions',
    () async {
      SharedPreferences.setMockInitialValues({'onboarding.level': 'N5'});
      final appDb = AppDatabase(executor: NativeDatabase.memory());
      final contentDb = ContentDatabase(executor: NativeDatabase.memory());
      final repo = _EmptyLessonRepository(appDb, contentDb);
      addTearDown(contentDb.close);
      addTearDown(appDb.close);

      final sections = await buildJlptMockSections(
        level: StudyLevel.n5,
        language: AppLanguage.en,
        contentDb: contentDb,
        lessonRepo: repo,
        random: Random(2),
      );
      final grammar = sections.singleWhere(
        (section) => section.id == 'grammar',
      );

      final sharedBankId = RegExp(
        r'^grammar-\d+-(sentenceBuilder|cloze|multipleChoice|reverseMultipleChoice|contextChoice|errorCorrection|transformation|pairContrast|errorReason)-',
      );
      expect(grammar.questions, isNotEmpty);
      expect(
        grammar.questions.every(
          (question) => sharedBankId.hasMatch(question.id),
        ),
        isTrue,
      );
    },
  );
}
