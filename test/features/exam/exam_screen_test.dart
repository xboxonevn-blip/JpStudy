import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/exam/exam_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildExamScreen() {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
    ],
    child: const MaterialApp(home: ExamScreen()),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows AppBar title "Mock Exam"', (tester) async {
    await tester.pumpWidget(buildExamScreen());
    await tester.pump();
    expect(find.text('Mock Exam'), findsWidgets);
  });

  testWidgets('shows N5 and N4 level cards', (tester) async {
    await tester.pumpWidget(buildExamScreen());
    await tester.pump();

    expect(find.text('JLPT N5'), findsOneWidget);
    expect(find.text('JLPT N4'), findsOneWidget);
  });

  testWidgets('shows level subtitles with timer and scoring', (tester) async {
    await tester.pumpWidget(buildExamScreen());
    await tester.pump();

    expect(find.text('N5 timer, scoring, and review.'), findsOneWidget);
    expect(find.text('N4 timer, scoring, and review.'), findsOneWidget);
  });

  testWidgets('shows "Choose level" section header', (tester) async {
    await tester.pumpWidget(buildExamScreen());
    await tester.pump();

    expect(find.text('Choose level'), findsOneWidget);
  });
}
