import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/immersion/immersion_home_screen.dart';
import 'package:jpstudy/features/immersion/models/immersion_article.dart';
import 'package:jpstudy/features/immersion/providers/immersion_providers.dart';
import 'package:jpstudy/features/immersion/screens/immersion_reader_screen.dart';
import 'package:jpstudy/features/immersion/services/immersion_service.dart';

class FakeImmersionService extends ImmersionService {
  FakeImmersionService({
    required this.localArticles,
    required this.nhkArticles,
    Set<String>? initialReadIds,
  }) : _readIds = {...?initialReadIds};

  final List<ImmersionArticle> localArticles;
  final List<ImmersionArticle> nhkArticles;
  final Set<String> _readIds;
  final Map<String, List<ImmersionQuizAttempt>> _history = {};

  Set<String> get readIds => _readIds;

  @override
  Future<List<ImmersionArticle>> loadLocalSamples() async {
    return localArticles;
  }

  @override
  Future<List<ImmersionArticle>> loadNhkEasySummaries({
    bool forceRefresh = false,
    int limit = 12,
  }) async {
    return nhkArticles.take(limit).toList();
  }

  @override
  Future<ImmersionArticle?> loadNhkArticleDetail(
    String newsId, {
    bool forceRefresh = false,
  }) async {
    return null;
  }

  @override
  Future<Set<String>> getReadArticleIds() async {
    return {..._readIds};
  }

  @override
  Future<void> markArticleAsRead(String id, bool isRead) async {
    if (isRead) {
      _readIds.add(id);
    } else {
      _readIds.remove(id);
    }
  }

  @override
  Future<List<ImmersionQuizAttempt>> getQuizHistory(
    String articleId, {
    int limit = 10,
  }) async {
    return (_history[articleId] ?? const []).take(limit).toList();
  }

  @override
  Future<void> saveQuizAttempt({
    required String articleId,
    required int correct,
    required int total,
    int keep = 20,
  }) async {
    final current = [...(_history[articleId] ?? const <ImmersionQuizAttempt>[])];
    current.insert(
      0,
      ImmersionQuizAttempt(
        correct: correct,
        total: total,
        attemptedAt: DateTime.now(),
      ),
    );
    if (current.length > keep) {
      current.removeRange(keep, current.length);
    }
    _history[articleId] = current;
  }
}

void main() {
  final fallbackArticle = ImmersionArticle(
    id: 'fallback_1',
    title: 'Fallback article',
    officialLevel: 'N5',
    source: 'Watanoc',
    publishedAt: DateTime(2026, 2, 4),
    paragraphs: [
      [ImmersionToken(surface: '学ぶ', reading: 'まなぶ', meaningEn: 'learn')],
    ],
  );

  final repeatedParagraphs = List<List<ImmersionToken>>.generate(
    30,
    (_) => const [
      ImmersionToken(
        surface: '日本語',
        reading: 'にほんご',
        meaningEn: 'Japanese language',
        meaningVi: 'tieng Nhat',
      ),
    ],
  );

  final localArticle = ImmersionArticle(
    id: 'local_1',
    title: 'Local article',
    titleFurigana: 'ろーかる',
    officialLevel: 'N5',
    source: 'Local',
    publishedAt: DateTime(2026, 2, 4),
    paragraphs: repeatedParagraphs,
    translation: 'This is a local translation.',
  );

  testWidgets('Immersion home shows NHK fallback notice and still loads articles', (
    tester,
  ) async {
    final fakeService = FakeImmersionService(
      localArticles: [localArticle],
      nhkArticles: [fallbackArticle],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          immersionServiceProvider.overrideWithValue(fakeService),
        ],
        child: const MaterialApp(home: ImmersionHomeScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLanguage.en.immersionSourceNhkLabel).first);
    await tester.pumpAndSettle();

    expect(find.text(AppLanguage.en.immersionFallbackToLocalLabel), findsOneWidget);
    expect(find.text('Fallback article'), findsOneWidget);
  });

  testWidgets('Immersion reader walkthrough: furigana/translation/read status/SRS/auto-scroll', (
    tester,
  ) async {
    final fakeService = FakeImmersionService(
      localArticles: [localArticle],
      nhkArticles: [fallbackArticle],
    );
    final db = AppDatabase(executor: NativeDatabase.memory());
    final contentDb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = LessonRepository(db, contentDb);
    addTearDown(() async {
      await contentDb.close();
      await db.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lessonRepositoryProvider.overrideWithValue(repo),
          immersionServiceProvider.overrideWithValue(fakeService),
        ],
        child: MaterialApp(
          home: ImmersionReaderScreen(article: localArticle),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Furigana on by default.
    expect(find.text('にほんご'), findsWidgets);
    await tester.tap(find.byTooltip(AppLanguage.en.immersionFuriganaLabel));
    await tester.pumpAndSettle();
    expect(find.text('にほんご'), findsNothing);

    // Translation toggle in app bar.
    await tester.tap(find.byTooltip(AppLanguage.en.immersionTranslateLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(AppLanguage.en.immersionTranslateLabel));
    await tester.pumpAndSettle();

    // Mark as learned/read.
    await tester.tap(find.byTooltip(AppLanguage.en.immersionMarkReadLabel));
    await tester.pumpAndSettle();
    expect(fakeService.readIds.contains(localArticle.id), isTrue);

    // Tap token, then add to SRS.
    await tester.tap(find.text('日本語').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLanguage.en.immersionAddSrsLabel));
    await tester.pumpAndSettle();
    final saved = await repo.findTermInLesson(9999, '日本語', 'にほんご');
    expect(saved, isNotNull);

    // Auto-scroll toggle from FAB.
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });
}
