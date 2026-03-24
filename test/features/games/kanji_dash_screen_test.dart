import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/repositories/content_repository.dart';
import 'package:jpstudy/features/games/kanji_dash/kanji_dash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

VocabData _vocab(int id, String term, String meaning) => VocabData(
      id: id,
      term: term,
      reading: null,
      meaning: meaning,
      meaningEn: meaning,
      level: 'N5',
    );

Widget buildScreen(List<VocabData> items) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
        vocabPreviewProvider('N5').overrideWith((ref) async => items),
      ],
      child: const MaterialApp(home: KanjiDashScreen()),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Kanji Dash app bar title with level', (tester) async {
    await tester.pumpWidget(buildScreen([_vocab(1, '火', 'fire')]));
    await tester.pump();
    expect(find.text('Kanji Dash (N5)'), findsOneWidget);
  });

  testWidgets('shows start button when vocab exists', (tester) async {
    await tester.pumpWidget(buildScreen([
      _vocab(1, '火', 'fire'),
      _vocab(2, '水', 'water'),
      _vocab(3, '木', 'tree'),
      _vocab(4, '金', 'gold'),
    ]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('shows empty-state when no vocab exists', (tester) async {
    await tester.pumpWidget(buildScreen(const []));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(AppLanguage.en.kanjiDashNoVocab), findsOneWidget);
  });
}
