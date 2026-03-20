import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/search/search_screen.dart';

void main() {
  testWidgets(
    'Search screen renders responsive lookup shell and updates query chrome',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => AppLanguage.en),
            studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
            searchIndexProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lookup'), findsAtLeastNWidgets(1));
      expect(find.text('Current search bank'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Vocab'), findsAtLeastNWidgets(1));
      expect(find.text('Kanji'), findsAtLeastNWidgets(1));
      expect(find.text('Kana'), findsAtLeastNWidgets(1));
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'taberu');
      await tester.pump(const Duration(milliseconds: 220));

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(
        find.text('No matches. Try a word, kanji, or reading.'),
        findsOneWidget,
      );
    },
  );
}
