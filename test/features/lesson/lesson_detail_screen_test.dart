import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/lesson/lesson_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserLessonTermData _term(
  int id,
  String term,
  String definition, {
  String reading = '',
}) =>
    UserLessonTermData(
      id: id,
      lessonId: 1,
      term: term,
      reading: reading,
      definition: definition,
      definitionEn: definition,
      mnemonicVi: '',
      mnemonicEn: '',
      kanjiMeaning: '',
      isStarred: false,
      isLearned: false,
      orderIndex: id,
    );

double _contrast(Color foreground, Color background) {
  final resolvedForeground = foreground.a < 1
      ? Color.alphaBlend(foreground, background)
      : foreground;
  final foregroundLuminance = resolvedForeground.computeLuminance() + 0.05;
  final backgroundLuminance = background.computeLuminance() + 0.05;
  return foregroundLuminance > backgroundLuminance
      ? foregroundLuminance / backgroundLuminance
      : backgroundLuminance / foregroundLuminance;
}

Widget buildScreen(
  List<UserLessonTermData> terms, {
  Future<List<UserLessonTermData>>? termsFuture,
}) {
  final fallbackTitle = AppLanguage.en.lessonTitle(1);
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.en),
      ),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      lessonTitleProvider(
        LessonTitleArgs(1, fallbackTitle),
      ).overrideWith((ref) async => fallbackTitle),
      lessonTermsProvider(
        LessonTermsArgs(1, 'N5', fallbackTitle, sourceLessonId: 1),
      ).overrideWith((ref) => termsFuture ?? Future.value(terms)),
      lessonGrammarProvider(
        const LessonTermsArgs(1, 'N5', ''),
      ).overrideWith((ref) async => const []),
      grammarDueCountProvider.overrideWith((ref) async => 0),
      grammarGhostCountProvider.overrideWith((ref) => Stream.value(0)),
      lessonKanjiProvider(1).overrideWith((ref) async => const []),
      lessonDueTermsProvider(
        1,
      ).overrideWith((ref) async => const <UserLessonTermData>[]),
      srsStateProvider(1).overrideWith((ref) async => null),
    ],
    child: const MaterialApp(home: LessonDetailScreen(lessonId: 1)),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows app bar back control and lesson tabs', (tester) async {
    await tester.pumpWidget(buildScreen([_term(1, '犬', 'dog')]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
  });

  testWidgets('shows tab bar with Vocab, Grammar, Kanji tabs', (tester) async {
    await tester.pumpWidget(buildScreen([_term(1, '犬', 'dog')]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(AppLanguage.en.lessonVocabTabLabel), findsWidgets);
    expect(find.text(AppLanguage.en.flashcardsAction), findsWidgets);
    expect(find.text(AppLanguage.en.grammarLabel), findsWidgets);
    expect(find.text(AppLanguage.en.kanjiLabel), findsWidgets);
  });

  testWidgets('lesson tabs switch to grammar and kanji panels', (tester) async {
    await tester.pumpWidget(buildScreen([_term(1, '犬', 'dog')]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text(AppLanguage.en.grammarLabel));
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      DefaultTabController.of(tester.element(find.byType(TabBar))).index,
      1,
    );

    await tester.tap(find.text(AppLanguage.en.kanjiLabel));
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      DefaultTabController.of(tester.element(find.byType(TabBar))).index,
      2,
    );
  });

  testWidgets('curriculum lesson menu hides user-set editing actions', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen([_term(1, '犬', 'dog')]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    expect(find.text(AppLanguage.en.copySetLabel), findsNothing);
    expect(find.text(AppLanguage.en.addTermLabel), findsNothing);
    expect(find.text(AppLanguage.en.combineSetLabel), findsNothing);
    expect(find.text(AppLanguage.en.resetProgressLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.reportLabel), findsOneWidget);
  });

  testWidgets('does not show zero totals while lesson terms are loading', (
    tester,
  ) async {
    final pending = Completer<List<UserLessonTermData>>().future;

    await tester.pumpWidget(buildScreen(const [], termsFuture: pending));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text(AppLanguage.en.statsTotalLabel), findsNothing);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('flashcard helper labels meet light-surface AA contrast', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen([_term(1, '犬', 'dog', reading: 'いぬ')]),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    for (final label in [
      AppLanguage.en.termLabel,
      AppLanguage.en.readingLabel,
      AppLanguage.en.meaningLabel,
    ]) {
      final text = tester.widget<Text>(find.text(label).first);
      final color = text.style?.color;
      expect(color, isNotNull, reason: label);
      expect(
        _contrast(color!, AppThemePalette.light.elevated),
        greaterThanOrEqualTo(4.5),
        reason: label,
      );
    }
  });
}
