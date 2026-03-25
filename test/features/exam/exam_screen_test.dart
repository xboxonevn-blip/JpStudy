import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/core/services/session_storage_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/exam/exam_screen.dart';
import 'package:jpstudy/features/test/screens/test_config_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLessonRepository extends LessonRepository {
  _FakeLessonRepository({required this.items, this.throwOnFetch = false})
      : super(
          AppDatabase(executor: NativeDatabase.memory()),
          ContentDatabase(executor: NativeDatabase.memory()),
        );

  final List<VocabItem> items;
  final bool throwOnFetch;

  @override
  Future<List<VocabItem>> getVocabByLevel(String level) async {
    if (throwOnFetch) {
      throw Exception('boom');
    }
    return items;
  }
}

class _FakeSessionStorage extends SessionStorage {
  @override
  Future<TestSessionSnapshot?> loadTestSession(String sessionKey) async => null;
}

const _sampleItem = VocabItem(
  id: 1,
  term: '猫',
  reading: 'ねこ',
  meaning: 'mèo',
  meaningEn: 'cat',
  level: 'N5',
);

Widget buildExamScreen({
  LessonRepository? repo,
  SessionStorage? storage,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      if (repo != null) lessonRepositoryProvider.overrideWithValue(repo),
      if (storage != null) sessionStorageProvider.overrideWithValue(storage),
    ],
    child: const MaterialApp(home: ExamScreen()),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows AppBar title "Mock Exam"', (tester) async {
    await tester.pumpWidget(buildExamScreen());
    await tester.pump();
    expect(find.text('Mock Exam'), findsWidgets);
  });

  testWidgets('shows N5 and N4 level cards', (tester) async {
    await tester.pumpWidget(buildExamScreen());
    await tester.pump();

    expect(find.text('JLPT N5'), findsOneWidget);
    expect(find.text('JLPT N4'), findsOneWidget);
  });

  testWidgets('shows level subtitles with timer and scoring', (tester) async {
    await tester.pumpWidget(buildExamScreen());
    await tester.pump();

    expect(find.text('N5 timer, scoring, and review.'), findsOneWidget);
    expect(find.text('N4 timer, scoring, and review.'), findsOneWidget);
  });

  testWidgets('shows "Choose level" section header', (tester) async {
    await tester.pumpWidget(buildExamScreen());
    await tester.pump();

    expect(find.text('Choose level'), findsOneWidget);
  });

  testWidgets('shows snackbar when selected level has no terms', (tester) async {
    final repo = _FakeLessonRepository(items: const []);

    await tester.pumpWidget(buildExamScreen(repo: repo));
    await tester.pump();

    await tester.tap(find.text('JLPT N5'));
    await tester.pump(); // dialog appears
    await tester.pump(); // async repo returns
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppLanguage.en.noTermsAvailableLabel), findsOneWidget);
  });

  testWidgets('shows load error snackbar when repository throws', (tester) async {
    final repo = _FakeLessonRepository(items: const [], throwOnFetch: true);

    await tester.pumpWidget(buildExamScreen(repo: repo));
    await tester.pump();

    await tester.tap(find.text('JLPT N5'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppLanguage.en.loadErrorLabel), findsOneWidget);
  });

  testWidgets('navigates to TestConfigScreen when terms are available',
      (tester) async {
    final repo = _FakeLessonRepository(items: const [_sampleItem]);
    final storage = _FakeSessionStorage();

    await tester.pumpWidget(buildExamScreen(repo: repo, storage: storage));
    await tester.pump();

    await tester.tap(find.text('JLPT N5'));
    await tester.pump(); // loading dialog
    await tester.pump(); // async nav completes
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TestConfigScreen), findsOneWidget);
    expect(find.textContaining(AppLanguage.en.mockExamTitle('N5')), findsWidgets);
  });
}
