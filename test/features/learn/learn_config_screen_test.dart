import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/screens/learn_config_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildConfigScreen({
  String lessonTitle = 'Lesson 1',
  int maxTerms = 20,
  LearnConfig? startedWith,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.en),
      ),
    ],
    child: MaterialApp(
      home: LearnConfigScreen(
        lessonId: 1,
        lessonTitle: lessonTitle,
        maxTerms: maxTerms,
        onStart: (_) {},
      ),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows AppBar title with lesson name', (tester) async {
    await tester.pumpWidget(buildConfigScreen(lessonTitle: 'Basic Greetings'));
    await tester.pump();
    expect(find.text('Learn: Basic Greetings'), findsOneWidget);
  });

  testWidgets('shows "Start Learning" button', (tester) async {
    await tester.pumpWidget(buildConfigScreen());
    await tester.pump();
    expect(find.text('Start Learning'), findsOneWidget);
  });

  testWidgets('calls onStart when Start Learning tapped', (tester) async {
    LearnConfig? captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith(
            (ref) => AppLanguageController.test(AppLanguage.en),
          ),
        ],
        child: MaterialApp(
          home: LearnConfigScreen(
            lessonId: 1,
            lessonTitle: 'Test Lesson',
            maxTerms: 10,
            onStart: (config) => captured = config,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Start Learning'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Start Learning'));
    await tester.pump();
    expect(captured, isNotNull);
  });

  testWidgets('shows question types section', (tester) async {
    await tester.pumpWidget(buildConfigScreen());
    await tester.pump();
    // Question types header should be visible
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });
}
