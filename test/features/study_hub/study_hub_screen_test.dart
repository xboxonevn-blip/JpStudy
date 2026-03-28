import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/study_hub/study_hub_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildScreen() {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const StudyHubScreen()),
      GoRoute(
        path: '/jlpt/coach',
        builder: (_, _) => const Scaffold(body: Center(child: Text('JLPT Coach'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows core Study Hub sections', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Study Hub'), findsOneWidget);
    expect(find.text('JLPT Prep'), findsOneWidget);
    expect(find.text('Textbook Tracker'), findsOneWidget);
    expect(find.text('Onboarding Roadmap'), findsOneWidget);
    expect(find.text('Exam Checklist'), findsOneWidget);
    expect(find.text('Community Q&A'), findsOneWidget);
  });

  testWidgets('JLPT hero CTA opens coach route', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start prep'));
    await tester.pumpAndSettle();

    expect(find.text('JLPT Coach'), findsOneWidget);
  });

  testWidgets('resource filters narrow results and clear restores them', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('N5 Grammar Fast Path'), findsOneWidget);
    expect(find.text('N4 Reading Bridge'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Beginner'));
    await tester.pumpAndSettle();

    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('N5 Grammar Fast Path'), findsOneWidget);
    expect(find.text('N4 Reading Bridge'), findsNothing);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('N4 Reading Bridge'), findsOneWidget);
  });

  testWidgets('textbook tracker and exam date controls update UI state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Lesson 0 / 25'), findsAtLeastNWidgets(1));
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Lesson 1 / 25'), findsOneWidget);

    expect(find.text('No target exam date set yet.'), findsOneWidget);
    await tester.tap(find.text('Set +90 days'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Target:'), findsOneWidget);
    expect(find.text('Clear date'), findsOneWidget);

    await tester.tap(find.text('Clear date'));
    await tester.pumpAndSettle();
    expect(find.text('No target exam date set yet.'), findsOneWidget);
  });

  testWidgets('Q&A flow can ask and answer a new question', (tester) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Ask'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();
    expect(find.text('Ask a question'), findsOneWidget);

    final askFields = find.byType(TextField);
    await tester.enterText(askFields.at(0), 'Is N3 hard?');
    await tester.enterText(askFields.at(1), 'I am wondering how big the jump is.');
    await tester.tap(find.text('Post'));
    await tester.pumpAndSettle();

    expect(find.text('Is N3 hard?'), findsOneWidget);

    await tester.tap(find.text('Is N3 hard?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Answer').first);
    await tester.pumpAndSettle();

    expect(find.text('Add an answer'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'It is manageable with steady reading.');
    await tester.tap(find.text('Post'));
    await tester.pumpAndSettle();

    expect(find.text('It is manageable with steady reading.'), findsOneWidget);
    expect(find.text('Reopen'), findsWidgets);
  });
}
