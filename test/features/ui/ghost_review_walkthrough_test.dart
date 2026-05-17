import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/common/widgets/clay_card.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/grammar_screen.dart';
import 'package:jpstudy/features/grammar/screens/ghost_review_screen.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/grammar/widgets/cloze_test_widget.dart';
import 'package:jpstudy/features/grammar/widgets/multiple_choice_widget.dart'
    as grammar_widgets;
import 'package:jpstudy/features/grammar/widgets/sentence_builder_widget.dart';

void main() {
  Future<int> seedGhostGrammar(AppDatabase db) async {
    final grammarId = await db
        .into(db.grammarPoints)
        .insert(
          GrammarPointsCompanion.insert(
            lessonId: const Value(1),
            grammarPoint: 'です',
            titleEn: const Value('desu'),
            meaning: 'is',
            meaningVi: const Value('la'),
            meaningEn: const Value('is'),
            connection: 'Noun + です',
            connectionEn: const Value('Noun + desu'),
            explanation: 'polite copula',
            explanationVi: const Value('tro dong tu lich su'),
            explanationEn: const Value('polite copula'),
            jlptLevel: 'N5',
            isLearned: const Value(true),
          ),
        );

    await db
        .into(db.grammarExamples)
        .insert(
          GrammarExamplesCompanion.insert(
            grammarId: grammarId,
            japanese: 'ABC',
            translation: 'Sample sentence',
            translationVi: const Value('Cau vi du'),
            translationEn: const Value('Sample sentence'),
          ),
        );

    await db.grammarDao.initializeSrsState(grammarId);
    await db.grammarDao.updateSrsState(
      grammarId: grammarId,
      streak: 0,
      stability: 1.0,
      difficulty: 5.0,
      nextReviewAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ghostReviewsDue: 1,
    );

    await db.mistakeDao.addMistake(
      'grammar',
      grammarId,
      prompt: 'Prompt ghost',
      correctAnswer: 'is',
      userAnswer: 'wrong',
      source: 'grammar_practice',
    );
    return grammarId;
  }

  GoRouter buildGrammarRouter() {
    return GoRouter(
      initialLocation: '/grammar',
      routes: [
        GoRoute(
          path: '/grammar',
          builder: (context, state) => const GrammarScreen(),
        ),
        GoRoute(
          name: 'grammar-practice',
          path: '/grammar-practice',
          builder: (context, state) {
            var mode = GrammarPracticeMode.normal;
            if (state.extra is GrammarPracticeMode) {
              mode = state.extra! as GrammarPracticeMode;
            }
            return GrammarPracticeScreen(mode: mode);
          },
        ),
      ],
    );
  }

  Future<void> answerCurrentQuestionCorrectly(WidgetTester tester) async {
    if (find.byType(SentenceBuilderWidget).evaluate().isNotEmpty) {
      final scope = find.byType(SentenceBuilderWidget);

      // New tokenizer may keep the fake test sentence "ABC" as one chunk
      // instead of splitting it into A / B / C. Prefer the full chunk when
      // present, then fall back to the older per-character taps.
      final fullChunk = find.descendant(of: scope, matching: find.text('ABC'));
      if (fullChunk.evaluate().isNotEmpty) {
        await tester.ensureVisible(fullChunk.first);
        await tester.tap(fullChunk.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 30));
      } else {
        for (final char in ['A', 'B', 'C']) {
          final finder = find.descendant(of: scope, matching: find.text(char));
          if (finder.evaluate().isEmpty) continue;
          await tester.ensureVisible(finder.first);
          await tester.tap(finder.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 30));
        }
      }

      final checkFinder = find
          .descendant(of: scope, matching: find.text('Check'))
          .first;
      await tester.ensureVisible(checkFinder);
      await tester.tap(checkFinder, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
      return;
    }

    if (find.byType(ClozeTestWidget).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const ValueKey('grammar_cloze_option_0')));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.tap(find.byKey(const ValueKey('grammar_cloze_check')));
      await tester.pump(const Duration(milliseconds: 100));
      return;
    }

    if (find
        .byType(grammar_widgets.MultipleChoiceWidget)
        .evaluate()
        .isNotEmpty) {
      await tester.tap(find.byKey(const ValueKey('grammar_mc_option_0')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const ValueKey('grammar_mc_confirm')));
      await tester.pump(const Duration(milliseconds: 100));
      return;
    }

    fail('Unsupported grammar question widget in ghost walkthrough.');
  }

  testWidgets('Ghost banner opens grammar practice (ghost mode)', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
    });
    await seedGhostGrammar(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          grammarGhostCountProvider.overrideWith((ref) => Stream.value(1)),
        ],
        child: MaterialApp.router(routerConfig: buildGrammarRouter()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLanguage.en.ghostReviewBannerActionLabel));
    await tester.pumpAndSettle();

    expect(find.byType(GrammarPracticeScreen), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data?.startsWith('Question 1 of ') ?? false),
      ),
      findsOneWidget,
    );
    expect(find.text('Source: Ghost review'), findsNothing);
    expect(find.text('Session: Mastery'), findsNothing);
  });

  testWidgets('Ghost review shows mistake context (prompt/answer/source)', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
    });
    await seedGhostGrammar(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: GhostReviewScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byType(ClayCard).first);
    await tester.pumpAndSettle();

    expect(find.text(AppLanguage.en.mistakePromptLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.mistakeYourAnswerLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.mistakeCorrectAnswerLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.mistakeSourceLabel), findsOneWidget);
    expect(find.text('Prompt ghost'), findsOneWidget);
    expect(find.text('wrong'), findsOneWidget);
    expect(find.text('is'), findsOneWidget);
    expect(
      find.text(AppLanguage.en.mistakeSourceGrammarPracticeLabel),
      findsOneWidget,
    );
  });

  testWidgets(
    'Correct answer in ghost practice reduces grammar mistake count',
    (tester) async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(() async {
        await db.close();
      });
      final grammarId = await seedGhostGrammar(db);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            home: GrammarPracticeScreen(mode: GrammarPracticeMode.ghost),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await answerCurrentQuestionCorrectly(tester);
      await tester.pump(const Duration(milliseconds: 200));

      final mistakes = await db.mistakeDao.getMistakesByType('grammar');
      final target = mistakes.where((m) => m.itemId == grammarId).toList();
      expect(target, hasLength(1));
      expect(target.first.wrongCount, equals(1));

      // Let delayed transition timer in GrammarPracticeScreen complete.
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
