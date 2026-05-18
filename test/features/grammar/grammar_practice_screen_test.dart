import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';
import 'package:jpstudy/features/grammar/widgets/multiple_choice_widget.dart';

void main() {
  Future<int> seedPoint(
    AppDatabase db, {
    required int lessonId,
    required String jlptLevel,
    required String grammarPoint,
    required String titleEn,
    required String meaningEn,
    required String sentence,
    required String translationEn,
  }) async {
    final grammarId = await db
        .into(db.grammarPoints)
        .insert(
          GrammarPointsCompanion.insert(
            lessonId: Value(lessonId),
            grammarPoint: grammarPoint,
            titleEn: Value(titleEn),
            meaning: meaningEn,
            meaningVi: Value(meaningEn),
            meaningEn: Value(meaningEn),
            connection: grammarPoint,
            connectionEn: Value(grammarPoint),
            explanation: 'Use $grammarPoint correctly.',
            explanationVi: Value('Use $grammarPoint correctly.'),
            explanationEn: Value('Use $grammarPoint correctly.'),
            jlptLevel: jlptLevel,
            isLearned: const Value(false),
          ),
        );

    await db
        .into(db.grammarExamples)
        .insert(
          GrammarExamplesCompanion.insert(
            grammarId: grammarId,
            japanese: sentence,
            translation: translationEn,
            translationVi: Value(translationEn),
            translationEn: Value(translationEn),
          ),
        );

    return grammarId;
  }

  testWidgets(
    'uses the selected JLPT level and keeps question chrome compact',
    (tester) async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(() async {
        await db.close();
      });

      await seedPoint(
        db,
        lessonId: 26,
        jlptLevel: 'N4',
        grammarPoint: 'ながら',
        titleEn: 'N4 Alpha',
        meaningEn: 'while doing',
        sentence: '音楽を聞きながら勉強します。',
        translationEn: 'I study while listening to music.',
      );
      await seedPoint(
        db,
        lessonId: 27,
        jlptLevel: 'N4',
        grammarPoint: 'ので',
        titleEn: 'N4 Beta',
        meaningEn: 'because',
        sentence: '雨なので、出かけません。',
        translationEn: 'Because it is raining, I will not go out.',
      );
      await seedPoint(
        db,
        lessonId: 28,
        jlptLevel: 'N4',
        grammarPoint: 'たら',
        titleEn: 'N4 Gamma',
        meaningEn: 'if / when',
        sentence: '家に帰ったら、電話します。',
        translationEn: 'When I get home, I will call.',
      );
      await seedPoint(
        db,
        lessonId: 1,
        jlptLevel: 'N5',
        grammarPoint: 'だけ',
        titleEn: 'N5 Alpha',
        meaningEn: 'only',
        sentence: '水だけ飲みます。',
        translationEn: 'I only drink water.',
      );
      await seedPoint(
        db,
        lessonId: 2,
        jlptLevel: 'N5',
        grammarPoint: 'から',
        titleEn: 'N5 Beta',
        meaningEn: 'because',
        sentence: '忙しいから、行きません。',
        translationEn: 'Because I am busy, I will not go.',
      );
      await seedPoint(
        db,
        lessonId: 3,
        jlptLevel: 'N5',
        grammarPoint: 'です',
        titleEn: 'N5 Gamma',
        meaningEn: 'to be',
        sentence: '私は学生です。',
        translationEn: 'I am a student.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            appLanguageProvider.overrideWith(
              (ref) => AppLanguageController.test(AppLanguage.en),
            ),
            studyLevelProvider.overrideWith((ref) => StudyLevel.n4),
          ],
          child: const MaterialApp(
            home: GrammarPracticeScreen(
              allowedTypes: [GrammarQuestionType.reverseMultipleChoice],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data?.startsWith('Question 1 of ') ?? false),
        ),
        findsOneWidget,
      );
      expect(find.text('Pattern'), findsOneWidget);
      expect(find.text('Session: Mastery'), findsNothing);
      expect(find.text('Source: Practice queue'), findsNothing);
      expect(find.text('Scope: N4 full mix'), findsNothing);
      expect(find.text('Goal: Balanced JLPT'), findsNothing);
      expect(find.text('Mode: Quiz'), findsNothing);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              const {'N4 Alpha', 'N4 Beta', 'N4 Gamma'}.contains(widget.data),
        ),
        findsAtLeastNWidgets(1),
      );
      expect(find.text('N5 Alpha'), findsNothing);
      expect(find.text('N5 Beta'), findsNothing);
      expect(find.text('N5 Gamma'), findsNothing);
    },
  );

  testWidgets('practice gate runs a focused five-question check', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
    });

    final targetId = await seedPoint(
      db,
      lessonId: 1,
      jlptLevel: 'N5',
      grammarPoint: 'てもいい',
      titleEn: 'May do',
      meaningEn: 'permission',
      sentence: 'ここで写真を撮ってもいいです。',
      translationEn: 'You may take photos here.',
    );
    await seedPoint(
      db,
      lessonId: 1,
      jlptLevel: 'N5',
      grammarPoint: 'てはいけない',
      titleEn: 'Must not',
      meaningEn: 'prohibition',
      sentence: 'ここで写真を撮ってはいけません。',
      translationEn: 'You must not take photos here.',
    );
    await seedPoint(
      db,
      lessonId: 1,
      jlptLevel: 'N5',
      grammarPoint: 'なくてもいい',
      titleEn: 'Need not',
      meaningEn: 'not necessary',
      sentence: '今日は来なくてもいいです。',
      translationEn: 'You do not need to come today.',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          appLanguageProvider.overrideWith(
            (ref) => AppLanguageController.test(AppLanguage.en),
          ),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
        ],
        child: MaterialApp(
          home: GrammarPracticeScreen(
            initialIds: [targetId],
            gateGrammarId: targetId,
            targetCount: 5,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Practice check'), findsWidgets);
    expect(find.text('Question 1 of 5'), findsOneWidget);
  });

  testWidgets('practice gate pass marks the grammar point understood', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
    });

    final targetId = await seedPoint(
      db,
      lessonId: 1,
      jlptLevel: 'N5',
      grammarPoint: 'てもいい',
      titleEn: 'May do',
      meaningEn: 'permission',
      sentence: 'ここで写真を撮ってもいいです。',
      translationEn: 'You may take photos here.',
    );
    await seedPoint(
      db,
      lessonId: 1,
      jlptLevel: 'N5',
      grammarPoint: 'てはいけない',
      titleEn: 'Must not',
      meaningEn: 'prohibition',
      sentence: 'ここで写真を撮ってはいけません。',
      translationEn: 'You must not take photos here.',
    );
    await seedPoint(
      db,
      lessonId: 1,
      jlptLevel: 'N5',
      grammarPoint: 'なくてもいい',
      titleEn: 'Need not',
      meaningEn: 'not necessary',
      sentence: '今日は来なくてもいいです。',
      translationEn: 'You do not need to come today.',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          appLanguageProvider.overrideWith(
            (ref) => AppLanguageController.test(AppLanguage.en),
          ),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
        ],
        child: MaterialApp(
          home: GrammarPracticeScreen(
            initialIds: [targetId],
            gateGrammarId: targetId,
            targetCount: 5,
            allowedTypes: const [
              GrammarQuestionType.multipleChoice,
              GrammarQuestionType.reverseMultipleChoice,
              GrammarQuestionType.contextChoice,
              GrammarQuestionType.errorCorrection,
              GrammarQuestionType.transformation,
              GrammarQuestionType.pairContrast,
              GrammarQuestionType.errorReason,
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      final widget = tester.widget<MultipleChoiceWidget>(
        find.byType(MultipleChoiceWidget),
      );
      await tester.tap(find.text(widget.correctAnswer).last);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('grammar_mc_confirm')));
      await tester.pump(const Duration(milliseconds: 950));
    }
    await tester.pumpAndSettle();

    expect(find.textContaining('Practice check passed'), findsOneWidget);
    final point = await (db.select(
      db.grammarPoints,
    )..where((tbl) => tbl.id.equals(targetId))).getSingle();
    expect(point.isLearned, isTrue);
  });
}
