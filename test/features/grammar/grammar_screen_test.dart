import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/grammar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _stubPoint = GrammarPoint(
  id: 1,
  grammarPoint: 'てもいい',
  meaning: 'được phép làm gì',
  meaningVi: 'được phép làm gì',
  meaningEn: 'is okay to do',
  connection: 'V-て + もいい',
  explanation: 'Expresses permission.',
  jlptLevel: 'N5',
  isLearned: false,
);

const _learnedPoint = GrammarPoint(
  id: 2,
  grammarPoint: 'てはいけない',
  meaning: 'không được phép làm',
  connection: 'V-て + はいけない',
  explanation: 'Expresses prohibition.',
  jlptLevel: 'N5',
  isLearned: true,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Simple wrapper — no router (navigation tests use [_buildRouterScreen]).
Widget _buildScreen({
  AppLanguage language = AppLanguage.en,
  List<GrammarPoint> points = const [],
  int dueCount = 0,
  int ghostCount = 0,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => language),
      studyLevelProvider.overrideWith(
        (ref) => null,
      ), // levelLabel defaults to 'N5'
      grammarPointsProvider('N5').overrideWith((_) async => points),
      grammarDueCountProvider.overrideWith((_) async => dueCount),
      grammarGhostCountProvider.overrideWith((_) => Stream.value(ghostCount)),
    ],
    child: const MaterialApp(home: GrammarScreen()),
  );
}

/// GoRouter wrapper for navigation tests.
Widget _buildRouterScreen({
  AppLanguage language = AppLanguage.en,
  List<GrammarPoint> points = const [],
  int dueCount = 0,
  int ghostCount = 0,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const GrammarScreen()),
      GoRoute(
        name: 'grammar-practice',
        path: '/grammar-practice',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('GRAMMAR_PRACTICE'))),
      ),
      GoRoute(
        path: '/grammar/:id',
        builder: (context, state) => Scaffold(
          body: Center(child: Text('GRAMMAR_ID=${state.pathParameters['id']}')),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => language),
      studyLevelProvider.overrideWith((ref) => null),
      grammarPointsProvider('N5').overrideWith((_) async => points),
      grammarDueCountProvider.overrideWith((_) async => dueCount),
      grammarGhostCountProvider.overrideWith((_) => Stream.value(ghostCount)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'foundations.softSuggest.grammar.shown': true,
    });
  });

  testWidgets(
    'renders Grammar app bar and all-clear chips when nothing is due',
    (tester) async {
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.text('Grammar'), findsWidgets);
      expect(find.text('All clear'), findsWidgets);
      // Hero metric tiles are always shown
      expect(find.text('Deck size'), findsOneWidget);
      expect(find.text('Learned'), findsWidgets);
      expect(find.text('Ready now'), findsOneWidget);
      expect(find.text('Weak spots'), findsOneWidget);
    },
  );

  testWidgets(
    'shows due count badge and review button label when reviews are waiting',
    (tester) async {
      await tester.pumpWidget(_buildScreen(points: [_stubPoint], dueCount: 3));
      await _pump(tester);

      expect(find.text('3 ready'), findsWidgets); // status chip + metric tile
      expect(find.textContaining('Review 3 now'), findsWidgets);
    },
  );

  testWidgets('shows ghost count badge when weak spots exist', (tester) async {
    await tester.pumpWidget(_buildScreen(ghostCount: 2));
    await _pump(tester);

    expect(find.text('2 weak spots'), findsWidgets);
  });

  testWidgets('empty bank renders no-content placeholder', (tester) async {
    await tester.pumpWidget(_buildScreen(points: []));
    await _pump(tester);

    expect(find.textContaining('No grammar loaded for N5'), findsOneWidget);
  });

  testWidgets('grammar point rows render with learned / new badges', (
    tester,
  ) async {
    // VI locale: _GrammarPointRow title is point.grammarPoint directly
    await tester.pumpWidget(
      _buildScreen(
        language: AppLanguage.vi,
        points: [_stubPoint, _learnedPoint],
      ),
    );
    await _pump(tester);

    expect(find.text('てもいい'), findsOneWidget);
    expect(find.text('てはいけない'), findsOneWidget);
    // VI locale badge labels: 'Mới' for unlearned, 'Đã học' for learned
    expect(find.text('Mới'), findsOneWidget);
    // 'Đã học' appears in both the status chip and hero metric tile
    expect(find.text('Đã học'), findsWidgets);
  });

  testWidgets('tapping grammar point row navigates to detail page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // VI locale so the row title is point.grammarPoint = 'てもいい' directly
    await tester.pumpWidget(
      _buildRouterScreen(language: AppLanguage.vi, points: [_stubPoint]),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('てもいい'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('てもいい'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('GRAMMAR_ID=1'), findsOneWidget);
  });

  testWidgets(
    'hero primary action navigates to grammar practice when due count > 0',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildRouterScreen(points: [_stubPoint], dueCount: 3),
      );
      await tester.pumpAndSettle();

      // Hero card's FilledButton renders at the top — tap first occurrence
      await tester.tap(
        find.textContaining('Review 3 now').first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('GRAMMAR_PRACTICE'), findsOneWidget);
    },
  );

  testWidgets('VI locale shows Vietnamese app bar title', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.vi));
    await _pump(tester);

    expect(find.text('Ngữ pháp'), findsWidgets);
  });

  testWidgets('JA locale shows Japanese app bar title', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.ja));
    await _pump(tester);

    expect(find.text('文法'), findsWidgets);
  });
}
