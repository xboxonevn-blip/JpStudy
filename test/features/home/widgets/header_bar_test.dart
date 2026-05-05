import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/header_bar.dart';

const _dashboard = DashboardState(
  streak: 2,
  todayXp: 10,
  vocabDue: 1,
  grammarDue: 2,
  kanjiDue: 3,
  vocabMistakeCount: 0,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 0,
);

void main() {
  testWidgets('header action pills expose button semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith((ref) => Stream.value(_dashboard)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: HeaderBar(
                level: StudyLevel.n5,
                language: AppLanguage.en,
                onLanguageTap: () {},
                onLevelChanged: (_) {},
                onSettingsTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final languageSemantics = tester.getSemantics(find.byTooltip('Language'));
      final levelSemantics = tester.getSemantics(
        find.byTooltip('Change level'),
      );

      expect(languageSemantics.flagsCollection.isButton, isTrue);
      expect(levelSemantics.flagsCollection.isButton, isTrue);
    } finally {
      semantics.dispose();
    }
  });
}
