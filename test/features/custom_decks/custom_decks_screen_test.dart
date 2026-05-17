import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/custom_decks/custom_decks_screen.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/study_hub/providers/study_hub_board_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildRouterScreen({AppLanguage language = AppLanguage.en}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CustomDecksScreen(),
      ),
      GoRoute(
        path: '/vocab/review',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Text(
              'VOCAB_REVIEW_source=${state.uri.queryParameters['source']}'
              '_title=${state.uri.queryParameters['title']}',
            ),
          ),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
      dashboardProvider.overrideWith(
        (ref) => Stream.value(
          const DashboardState(
            streak: 0,
            todayXp: 0,
            vocabDue: 0,
            grammarDue: 0,
            kanjiDue: 0,
            vocabMistakeCount: 0,
            grammarMistakeCount: 0,
            kanjiMistakeCount: 0,
            totalMistakeCount: 0,
          ),
        ),
      ),
      studyHubDecksProvider.overrideWith(
        (ref) async => const StudyHubDecksBoard(
          nextUp: null,
          activeDecks: [],
          completedDecks: [],
        ),
      ),
      continueActionProvider.overrideWith(
        (ref) async => const ContinueAction(
          type: ContinueActionType.practiceMixed,
          label: 'Practice',
        ),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Tapping urgent review item navigates to /vocab/review with source=cram',
    (tester) async {
      await tester.pumpWidget(_buildRouterScreen());
      await _pump(tester);

      // Scroll down to reveal the Active toolkit section (it's below the recipe card)
      await tester.ensureVisible(find.text('Urgent review'));
      await _pump(tester);

      await tester.tap(find.text('Urgent review'));
      await _pump(tester);

      expect(find.textContaining('VOCAB_REVIEW_source=cram'), findsOneWidget);
      expect(find.textContaining('title=Tonight Review'), findsOneWidget);
    },
  );

  testWidgets('Tapping Custom quiz shows snackbar (not cram navigation)', (
    tester,
  ) async {
    await tester.pumpWidget(_buildRouterScreen());
    await _pump(tester);

    await tester.ensureVisible(find.text('Custom quiz'));
    await _pump(tester);

    await tester.tap(find.text('Custom quiz'));
    await _pump(tester);

    // Should still be on the main screen — snackbar shown, not navigated away
    expect(find.byType(CustomDecksScreen), findsOneWidget);
    expect(find.textContaining('VOCAB_REVIEW'), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Urgent review in VI language navigates with title=Nhồi nhanh', (
    tester,
  ) async {
    await tester.pumpWidget(_buildRouterScreen(language: AppLanguage.vi));
    await _pump(tester);

    await tester.ensureVisible(find.text('Ôn gấp'));
    await _pump(tester);

    await tester.tap(find.text('Ôn gấp'));
    await _pump(tester);

    expect(find.textContaining('VOCAB_REVIEW_source=cram'), findsOneWidget);
    expect(find.textContaining('title=Nhồi nhanh'), findsOneWidget);
  });

  testWidgets('VI starter templates use accented Vietnamese glossary copy', (
    tester,
  ) async {
    await tester.pumpWidget(_buildRouterScreen(language: AppLanguage.vi));
    await _pump(tester);

    await tester.ensureVisible(find.text('Bắt đầu nhanh'));
    await _pump(tester);

    expect(find.text('Bộ thẻ kanji'), findsOneWidget);
    expect(find.text('Bài ngữ pháp'), findsOneWidget);
    expect(find.text('Luyện shadowing'), findsOneWidget);
    expect(find.text('Bộ luyện nhanh'), findsOneWidget);
    expect(find.text('250 thẻ'), findsOneWidget);
    expect(find.text('12 bộ'), findsOneWidget);
    expect(find.text('Sẵn âm thanh'), findsOneWidget);
    expect(find.textContaining('?'), findsNothing);
    expect(find.text('Deck Kanji'), findsNothing);
  });

  testWidgets(
    'Urgent review in JA language navigates with title=Tonight Review',
    (tester) async {
      await tester.pumpWidget(_buildRouterScreen(language: AppLanguage.ja));
      await _pump(tester);

      // JA uses the same urgent-review title as EN.
      await tester.ensureVisible(
        find.byWidgetPredicate(
          (w) => w is Text && w.data == 'Urgent review',
          description: 'JA urgent review item',
        ),
      );
      await _pump(tester);

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is Text && w.data == 'Urgent review',
          description: 'JA urgent review item',
        ),
      );
      await _pump(tester);

      expect(find.textContaining('VOCAB_REVIEW_source=cram'), findsOneWidget);
      expect(find.textContaining('title=Tonight Review'), findsOneWidget);
    },
  );
}
