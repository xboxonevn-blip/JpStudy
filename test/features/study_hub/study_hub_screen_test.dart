import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/study_hub/study_hub_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildScreen() => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      ],
      child: const MaterialApp(home: StudyHubScreen()),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Study Hub app bar title', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Study Hub'), findsOneWidget);
  });

  testWidgets('shows JLPT Prep section and textbook tracker', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JLPT Prep'), findsOneWidget);
    expect(find.text('Textbook Tracker'), findsOneWidget);
  });

  testWidgets('shows onboarding roadmap and exam checklist sections',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Onboarding Roadmap'), findsOneWidget);
    expect(find.text('Exam Checklist'), findsOneWidget);
  });
}
