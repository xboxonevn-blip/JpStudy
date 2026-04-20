import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/kanji_hub/providers/kanji_home_provider.dart';
import 'package:jpstudy/features/kanji_hub/screens/kanji_practice_hub_screen.dart';

Widget _buildScreen({
  StudyLevel level = StudyLevel.n5,
  KanjiPracticeArgs? launchArgs,
  Map<String, KanjiHomeSummary> summaries = const {},
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => level),
      kanjiHomeSummaryByLevelCodeProvider.overrideWith(
        (ref, levelCode) async =>
            summaries[levelCode] ??
            KanjiHomeSummary(
              levelCode: levelCode,
              dueCount: 0,
              newCount: 0,
              exploreCount: 0,
            ),
      ),
    ],
    child: MaterialApp(home: KanjiPracticeHubScreen(launchArgs: launchArgs)),
  );
}

void main() {
  testWidgets(
    'launchArgs levelCode overrides selected level for summary copy',
    (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          level: StudyLevel.n5,
          launchArgs: const KanjiPracticeArgs(
            mode: KanjiPracticeMode.both,
            source: 'daily_plan_due',
            levelCode: 'N4',
          ),
          summaries: const {
            'N4': KanjiHomeSummary(
              levelCode: 'N4',
              dueCount: 1,
              newCount: 9,
              exploreCount: 40,
            ),
            'N5': KanjiHomeSummary(
              levelCode: 'N5',
              dueCount: 7,
              newCount: 3,
              exploreCount: 80,
            ),
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('N4'), findsOneWidget);
      expect(
        find.text('Start with your 1 kanji that are due today.'),
        findsOneWidget,
      );
      expect(
        find.text('1 kanji ready – drill readings with quick flashcards.'),
        findsOneWidget,
      );
      expect(find.textContaining('7 kanji'), findsNothing);
    },
  );

  testWidgets('source token new uses fresh batch copy', (tester) async {
    await tester.pumpWidget(
      _buildScreen(
        level: StudyLevel.n5,
        launchArgs: const KanjiPracticeArgs(
          mode: KanjiPracticeMode.both,
          source: 'daily_plan_new',
          levelCode: 'N4',
        ),
        summaries: const {
          'N4': KanjiHomeSummary(
            levelCode: 'N4',
            dueCount: 2,
            newCount: 3,
            exploreCount: 40,
          ),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open 3 unseen kanji as a fresh batch.'), findsOneWidget);
    expect(
      find.text('3 new kanji – read then write the full batch.'),
      findsOneWidget,
    );
  });

  testWidgets('focus source uses focused practice copy', (tester) async {
    await tester.pumpWidget(
      _buildScreen(
        level: StudyLevel.n5,
        launchArgs: const KanjiPracticeArgs(
          mode: KanjiPracticeMode.both,
          source: 'focus',
          levelCode: 'N4',
          kanjiIds: [5],
          preferredKanjiId: 5,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Focused practice for one kanji.'), findsOneWidget);
    expect(
      find.text('Read then write the selected kanji in one focused pass.'),
      findsOneWidget,
    );
  });
}
