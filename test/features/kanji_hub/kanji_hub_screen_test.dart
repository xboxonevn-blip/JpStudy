import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/kanji_hub/kanji_hub_screen.dart';
import 'package:jpstudy/features/kanji_hub/providers/kanji_home_provider.dart';

class _FakeKanjiHubLessonRepository extends LessonRepository {
  _FakeKanjiHubLessonRepository({
    required this.n5Kanji,
    required this.n4Kanji,
    required this.n3Kanji,
    this.dueKanji = const {},
    this.unseenKanji = const {},
  }) : super(
         AppDatabase(executor: NativeDatabase.memory()),
         ContentDatabase(executor: NativeDatabase.memory()),
       );

  final List<KanjiItem> n5Kanji;
  final List<KanjiItem> n4Kanji;
  final List<KanjiItem> n3Kanji;

  /// Per-level due kanji (SRS-scheduled reviews). Defaults to empty (nothing due).
  final Map<String, List<KanjiItem>> dueKanji;

  /// Per-level unseen kanji (never practiced). Defaults to empty.
  final Map<String, List<KanjiItem>> unseenKanji;

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async {
    return switch (level) {
      'N5' => n5Kanji,
      'N4' => n4Kanji,
      'N3' => n3Kanji,
      _ => const [],
    };
  }

  @override
  Future<List<KanjiItem>> fetchDueKanjiByLevel(String level) async {
    return dueKanji[level] ?? const [];
  }

  @override
  Future<List<KanjiItem>> fetchUnseenKanjiByLevel(
    String level, {
    int limit = 15,
  }) async {
    final items = unseenKanji[level] ?? const [];
    return items.take(limit).toList();
  }

  @override
  Future<Set<int>> fetchSeenKanjiIds() async => const {};

  @override
  Future<Set<int>> fetchDueKanjiIds() async => const {};

  @override
  Future<int> countDueKanjiByLevel(String level) async =>
      dueKanji[level]?.length ?? 0;

  @override
  Future<int> countUnseenKanjiByLevel(String level) async =>
      unseenKanji[level]?.length ??
      fetchKanjiByLevel(level).then((items) => items.length);

  @override
  Future<int> countKanjiByLevel(String level) async =>
      fetchKanjiByLevel(level).then((items) => items.length);
}

Widget _buildSubject({
  required LessonRepository repo,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    retry: (retryCount, error) => null,
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.en),
      ),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      lessonRepositoryProvider.overrideWithValue(repo),
      ...overrides,
    ],
    child: const MaterialApp(home: KanjiHubScreen()),
  );
}

Future<void> _pumpKanjiHub(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _mockRadicalsAsset() async {
  const radicalsJson = [
    {
      'id': 72,
      'kanji': '\u65e5',
      'strokes': 4,
      'vi_meaning': 'nhat (mat troi)',
      'vi_meaning_raw': 'nhat (mat troi)',
    },
  ];
  final payload = ByteData.view(
    Uint8List.fromList(utf8.encode(jsonEncode(radicalsJson))).buffer,
  );
  TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key == 'assets/data/support/kanji/radicals_214.json') {
          return payload;
        }
        return null;
      });
}

_FakeKanjiHubLessonRepository _buildRepo({
  Map<String, List<KanjiItem>> dueKanji = const {},
  Map<String, List<KanjiItem>> unseenKanji = const {},
}) {
  return _FakeKanjiHubLessonRepository(
    dueKanji: dueKanji,
    unseenKanji: unseenKanji,
    n5Kanji: const [
      KanjiItem(
        id: 1,
        lessonId: 1,
        character: '\u660e',
        strokeCount: 8,
        meaning: 'bright',
        meaningEn: 'bright',
        examples: [],
        jlptLevel: 'N5',
        decomposition: KanjiDecomposition(components: ['\u65e5', '\u6708']),
      ),
      KanjiItem(
        id: 2,
        lessonId: 1,
        character: '\u4f11',
        strokeCount: 6,
        meaning: 'rest',
        meaningEn: 'rest',
        examples: [],
        jlptLevel: 'N5',
        decomposition: KanjiDecomposition(components: ['\u4ebb', '\u6728']),
      ),
    ],
    n4Kanji: const [
      KanjiItem(
        id: 3,
        lessonId: 2,
        character: '\u6642',
        strokeCount: 10,
        onyomi: '\u30b8',
        kunyomi: '\u3068\u304d',
        meaning: 'time',
        meaningEn: 'time',
        examples: [
          KanjiExample(
            word: '\u6642\u9593',
            reading: '\u3058\u304b\u3093',
            meaning: 'time',
            meaningEn: 'time',
          ),
        ],
        jlptLevel: 'N4',
        decomposition: KanjiDecomposition(components: ['\u65e5', '\u5bfa']),
      ),
    ],
    n3Kanji: const [
      KanjiItem(
        id: 4,
        lessonId: 3,
        character: '\u65e7',
        strokeCount: 5,
        meaning: 'old',
        meaningEn: 'old',
        examples: [],
        jlptLevel: 'N3',
        decomposition: KanjiDecomposition(relatedKanji: ['\u65e5']),
      ),
    ],
  );
}

void main() {
  testWidgets('kanji hub surfaces due/new/explore CTAs first', (tester) async {
    await _mockRadicalsAsset();
    await tester.pumpWidget(_buildSubject(repo: _buildRepo()));
    await _pumpKanjiHub(tester);

    expect(find.byKey(const ValueKey('kanji_today_panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('kanji_cta_due')), findsOneWidget);
    expect(find.byKey(const ValueKey('kanji_cta_new')), findsOneWidget);
    expect(find.byKey(const ValueKey('kanji_cta_explore')), findsOneWidget);
  });

  testWidgets('kanji hub shows loading card while today summary resolves', (
    tester,
  ) async {
    await _mockRadicalsAsset();
    final completer = Completer<KanjiHomeSummary>();

    await tester.pumpWidget(
      _buildSubject(
        repo: _buildRepo(),
        overrides: [
          kanjiHomeSummaryProvider.overrideWith((ref) => completer.future),
        ],
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('kanji_today_loading')), findsOneWidget);
    expect(find.text("Preparing today's kanji"), findsOneWidget);
  });

  testWidgets('kanji hub shows retry card when today summary fails', (
    tester,
  ) async {
    await _mockRadicalsAsset();

    await tester.pumpWidget(
      _buildSubject(
        repo: _buildRepo(),
        overrides: [
          kanjiHomeSummaryProvider.overrideWith(
            (ref) async => throw Exception('boom'),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const ValueKey('kanji_today_error')), findsOneWidget);
    expect(find.text('Could not load kanji summary'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
