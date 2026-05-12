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
import 'package:jpstudy/features/kanji_hub/providers/kanji_home_provider.dart';

class _Repo extends LessonRepository {
  _Repo()
    : super(
        AppDatabase(executor: NativeDatabase.memory()),
        ContentDatabase(executor: NativeDatabase.memory()),
      );

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async => level == 'N5'
      ? [
          KanjiItem(
            id: 1,
            lessonId: 1,
            character: String.fromCharCode(0x5b66),
            strokeCount: 8,
            onyomi: 'GAKU',
            kunyomi: 'manabu',
            meaning: 'hoc',
            meaningEn: 'study',
            examples: const [],
            jlptLevel: 'N5',
            decomposition: const KanjiDecomposition(hanViet: 'hoc'),
          ),
        ]
      : const [];

  @override
  Future<List<KanjiItem>> fetchDueKanjiByLevel(String level) async => const [];
  @override
  Future<List<KanjiItem>> fetchUnseenKanjiByLevel(
    String level, {
    int limit = 15,
  }) async => fetchKanjiByLevel(level);
  @override
  Future<Set<int>> fetchSeenKanjiIds() async => const {};
  @override
  Future<Set<int>> fetchDueKanjiIds() async => const {};
  @override
  Future<int> countDueKanjiByLevel(String level) async => 0;
  @override
  Future<int> countUnseenKanjiByLevel(String level) async => 1;
  @override
  Future<int> countKanjiByLevel(String level) async => level == 'N5' ? 1 : 0;
}

class _FilterSemanticsProbe extends StatefulWidget {
  const _FilterSemanticsProbe();
  @override
  State<_FilterSemanticsProbe> createState() => _FilterSemanticsProbeState();
}

class _FilterSemanticsProbeState extends State<_FilterSemanticsProbe> {
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Semantics(
          button: true,
          selected: selected,
          label: 'New (1)',
          child: ChoiceChip(
            label: const Text('New (1)'),
            selected: selected,
            onSelected: (value) => setState(() => selected = value),
          ),
        ),
      ),
    );
  }
}

Future<void> _mockRadicalsAsset() async {
  final payload = ByteData.view(
    Uint8List.fromList(utf8.encode(jsonEncode(const []))).buffer,
  );
  TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        return key == 'assets/data/support/kanji/radicals_214.json'
            ? payload
            : null;
      });
}

Widget _subject() => ProviderScope(
  retry: (retryCount, error) => null,
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.vi),
    ),
    studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
    lessonRepositoryProvider.overrideWithValue(_Repo()),
    kanjiHomeSummaryProvider.overrideWith(
      (ref) async => const KanjiHomeSummary(
        levelCode: 'N5',
        dueCount: 0,
        newCount: 1,
        exploreCount: 1,
      ),
    ),
  ],
  child: const MaterialApp(home: KanjiHubScreen()),
);

void main() {
  testWidgets(
    'kanji cards expose spoken label and filter chips announce selected state',
    (tester) async {
      await _mockRadicalsAsset();
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_subject());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));

        final allFilterNode = tester.getSemantics(
          find.bySemanticsLabel(RegExp('T\\u1ea5t c\\u1ea3')).last,
        );
        expect(
          allFilterNode.flagsCollection.isSelected.toString(),
          contains('isTrue'),
        );

        await tester.ensureVisible(find.text(String.fromCharCode(0x5b66)).last);
        await tester.pump(const Duration(milliseconds: 200));
        final kanjiFinder = find.bySemanticsLabel(RegExp('onyomi GAKU'));
        expect(kanjiFinder, findsOneWidget);
        final kanjiNode = tester.getSemantics(kanjiFinder);
        expect(kanjiNode.label, contains('kunyomi manabu'));
        expect(kanjiNode.label, contains('N5'));

        await tester.pumpWidget(const _FilterSemanticsProbe());
        await tester.pump();
        await tester.tap(find.byType(ChoiceChip));
        await tester.pump();
        final selectedFilterNode = tester.getSemantics(
          find.bySemanticsLabel(RegExp('New')).last,
        );
        expect(
          selectedFilterNode.flagsCollection.isSelected.toString(),
          contains('isTrue'),
        );
      } finally {
        semantics.dispose();
      }
    },
  );
}
