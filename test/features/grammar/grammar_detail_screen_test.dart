import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/grammar_repository.dart';
import 'package:jpstudy/features/grammar/screens/grammar_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _kGrammarId = 1;

const _stubPoint = GrammarPoint(
  id: _kGrammarId,
  grammarPoint: 'てもいい',
  meaning: 'được phép',
  meaningVi: 'được phép',
  meaningEn: 'is okay to do',
  connection: 'V-て + もいい',
  connectionEn: null,
  explanation: 'Expresses permission to do something.',
  explanationVi: 'Dùng để diễn đạt sự cho phép.',
  explanationEn: 'Use this pattern to express that something is allowed.',
  jlptLevel: 'N5',
  isLearned: false,
);

const _learnedPoint = GrammarPoint(
  id: _kGrammarId,
  grammarPoint: 'てもいい',
  meaning: 'được phép',
  meaningEn: 'is okay to do',
  connection: 'V-て + もいい',
  explanation: 'Expresses permission to do something.',
  jlptLevel: 'N5',
  isLearned: true,
);

const _stubExample = GrammarExample(
  id: 10,
  grammarId: _kGrammarId,
  japanese: '食べてもいいですか？',
  translation: 'Có thể ăn không?',
  translationVi: 'Có thể ăn không?',
  translationEn: 'May I eat?',
);

typedef _GrammarDetailRecord = ({
  GrammarPoint point,
  List<GrammarExample> examples,
});

// ---------------------------------------------------------------------------
// Fake repository — no-ops markAsLearned so no DB write is attempted
// ---------------------------------------------------------------------------

class _FakeGrammarRepository extends GrammarRepository {
  _FakeGrammarRepository()
    : super(AppDatabase(executor: NativeDatabase.memory()));

  @override
  Future<void> markAsLearned(int grammarId) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen({
  AppLanguage language = AppLanguage.en,
  _GrammarDetailRecord? detail,
  GrammarRepository? repo,
}) {
  final overrides = <Override>[
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(language),
    ),
    grammarDetailProvider(_kGrammarId).overrideWith((_) async => detail),
    if (repo != null) grammarRepositoryProvider.overrideWithValue(repo),
  ];

  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: GrammarDetailScreen(grammarId: _kGrammarId)),
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
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows "not found" when provider returns null', (tester) async {
    await tester.pumpWidget(_buildScreen(detail: null));
    await _pump(tester);

    expect(find.text('Grammar point not found.'), findsOneWidget);
  });

  testWidgets('renders headline, JLPT badge, connection and explanation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(detail: (point: _stubPoint, examples: const [])),
    );
    await _pump(tester);

    // AppBar title in EN
    expect(find.text('Grammar'), findsWidgets);
    // JLPT badge chip
    expect(find.text('N5'), findsWidgets);
    // EN headline via resolveEnglishGrammarConnection: falls back to connection
    expect(find.textContaining('V-て'), findsWidgets);
    // Explanation section header (uppercased via .toUpperCase())
    expect(find.textContaining('EXPLANATION'), findsOneWidget);
    // Explanation body
    expect(
      find.text('Use this pattern to express that something is allowed.'),
      findsOneWidget,
    );
  });

  testWidgets('renders examples when list is non-empty', (tester) async {
    await tester.pumpWidget(
      _buildScreen(detail: (point: _stubPoint, examples: const [_stubExample])),
    );
    await _pump(tester);

    expect(find.text('食べてもいいですか？'), findsWidgets);
  });

  testWidgets('"Mark done" button appears when point is not yet learned', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(detail: (point: _stubPoint, examples: const [])),
    );
    await _pump(tester);

    expect(find.text('Mark done'), findsOneWidget);
  });

  testWidgets('"Mark done" button is absent when point is already learned', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(detail: (point: _learnedPoint, examples: const [])),
    );
    await _pump(tester);

    expect(find.text('Mark done'), findsNothing);
  });

  testWidgets('"Mark done" tap shows confirmation snackbar', (tester) async {
    await tester.pumpWidget(
      _buildScreen(
        detail: (point: _stubPoint, examples: const []),
        repo: _FakeGrammarRepository(),
      ),
    );
    await _pump(tester);

    await tester.tap(find.text('Mark done'));
    await _pump(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Added to your review list.'), findsOneWidget);
  });

  testWidgets('VI locale shows Vietnamese app bar title', (tester) async {
    await tester.pumpWidget(
      _buildScreen(
        language: AppLanguage.vi,
        detail: (point: _stubPoint, examples: const []),
      ),
    );
    await _pump(tester);

    expect(find.text('Điểm ngữ pháp'), findsOneWidget);
  });

  testWidgets('JA locale shows Japanese app bar title', (tester) async {
    await tester.pumpWidget(
      _buildScreen(
        language: AppLanguage.ja,
        detail: (point: _stubPoint, examples: const []),
      ),
    );
    await _pump(tester);

    expect(find.text('文法ポイント'), findsOneWidget);
  });
}
