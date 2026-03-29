import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _FakeKanjiHubLessonRepository extends LessonRepository {
  _FakeKanjiHubLessonRepository({
    required this.n5Kanji,
    required this.n4Kanji,
    required this.n3Kanji,
  }) : super(
          AppDatabase(executor: NativeDatabase.memory()),
          ContentDatabase(executor: NativeDatabase.memory()),
        );

  final List<KanjiItem> n5Kanji;
  final List<KanjiItem> n4Kanji;
  final List<KanjiItem> n3Kanji;

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async {
    switch (level) {
      case 'N5':
        return n5Kanji;
      case 'N4':
        return n4Kanji;
      case 'N3':
        return n3Kanji;
      default:
        return const [];
    }
  }
}

Widget _buildSubject({required LessonRepository repo}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      lessonRepositoryProvider.overrideWithValue(repo),
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

Future<void> _openSunRadicalDialog(WidgetTester tester) async {
  final radicalsTabCard = find.ancestor(
    of: find.text('214').first,
    matching: find.byType(GestureDetector),
  );
  await tester.ensureVisible(radicalsTabCard.first);
  await tester.tap(radicalsTabCard.first, warnIfMissed: false);
  await _pumpKanjiHub(tester);

  for (var i = 0; i < 8 && find.text('\u65e5').evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }

  expect(find.text('\u65e5'), findsWidgets);
  final sunRadical = find.text('\u65e5').last;
  await tester.ensureVisible(sunRadical);
  await tester.tap(sunRadical, warnIfMissed: false);
  await _pumpKanjiHub(tester);
}

_FakeKanjiHubLessonRepository _buildRepo() {
  return _FakeKanjiHubLessonRepository(
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
        decomposition: KanjiDecomposition(
          components: ['\u65e5', '\u6708'],
        ),
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
        decomposition: KanjiDecomposition(
          components: ['\u4ebb', '\u6728'],
        ),
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
        decomposition: KanjiDecomposition(
          components: ['\u65e5', '\u5bfa'],
        ),
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
        decomposition: KanjiDecomposition(
          relatedKanji: ['\u65e5'],
        ),
      ),
    ],
  );
}

void main() {
  testWidgets(
    'radical detail groups related kanji by level and can open the chosen lane',
    (tester) async {
      await _mockRadicalsAsset();

      tester.view.physicalSize = const Size(1400, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _buildRepo();

      await tester.pumpWidget(_buildSubject(repo: repo));
      await _pumpKanjiHub(tester);
      await _openSunRadicalDialog(tester);

      expect(find.text('JP Study Flow'), findsAtLeastNWidgets(1));
      expect(find.textContaining('N5 lane'), findsOneWidget);
      expect(find.textContaining('N4 lane'), findsOneWidget);
      expect(find.textContaining('N3 lane'), findsOneWidget);
      expect(find.byKey(const ValueKey('open_related_all')), findsOneWidget);
      expect(find.byKey(const ValueKey('open_related_level_N4')), findsOneWidget);
      expect(find.byKey(const ValueKey('study_flashcard_N4')), findsOneWidget);
      expect(find.byKey(const ValueKey('study_write_N4')), findsOneWidget);
      expect(find.byKey(const ValueKey('preview_N4_\u6642')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('preview_N4_\u6642')));
      await _pumpKanjiHub(tester);

      expect(find.byKey(const ValueKey('micro_detail_\u6642')), findsOneWidget);
      expect(find.text('On: \u30b8'), findsOneWidget);
      expect(find.text('Kun: \u3068\u304d'), findsOneWidget);
      expect(find.byKey(const ValueKey('micro_search_\u6642')), findsOneWidget);
      expect(find.byKey(const ValueKey('micro_flashcard_\u6642')), findsOneWidget);
      expect(find.byKey(const ValueKey('micro_write_\u6642')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('open_related_level_N4')));
      await _pumpKanjiHub(tester);

      expect(find.byKey(const ValueKey('open_related_level_N4')), findsNothing);
      expect(find.textContaining('Flashcard'), findsOneWidget);
      expect(find.textContaining('(N4)'), findsWidgets);
      expect(find.text('\u6642'), findsWidgets);
      expect(find.text('\u660e'), findsNothing);
      expect(find.text('\u4f11'), findsNothing);
    },
  );

}
