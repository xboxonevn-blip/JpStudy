import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/common/widgets/clay_button.dart';
import 'package:jpstudy/features/games/kanji_dash/kanji_dash_screen.dart';
import 'package:jpstudy/features/games/providers/game_vocab_pool_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

VocabItem _vocab(int id, String term, String meaning) => VocabItem(
      id: id,
      term: term,
      reading: '',
      meaning: meaning,
      meaningEn: meaning,
      level: 'N5',
    );

Widget buildScreen(List<VocabItem> items) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
        gameVocabPoolProvider.overrideWith((ref) async => items),
      ],
      child: const MaterialApp(home: KanjiDashScreen()),
    );

Future<void> _pumpReady(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Kanji Dash app bar title with level', (tester) async {
    await tester.pumpWidget(buildScreen([_vocab(1, '?', 'fire')]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('${AppLanguage.en.kanjiDashTitle} (N5)'), findsOneWidget);
    await _pumpReady(tester);
  });

  testWidgets('shows start button when vocab exists', (tester) async {
    await tester.pumpWidget(buildScreen([
      _vocab(1, '?', 'fire'),
      _vocab(2, '?', 'water'),
      _vocab(3, '?', 'tree'),
      _vocab(4, '?', 'gold'),
    ]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.widgetWithText(ClayButton, AppLanguage.en.kanjiDashStart.toUpperCase()),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    await _pumpReady(tester);
  });

  testWidgets('shows empty-state when no vocab exists', (tester) async {
    await tester.pumpWidget(buildScreen(const []));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(AppLanguage.en.kanjiDashNoVocab), findsOneWidget);
    await _pumpReady(tester);
  });
}
