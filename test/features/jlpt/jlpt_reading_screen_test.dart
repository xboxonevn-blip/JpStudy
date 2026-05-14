import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/immersion/services/immersion_service.dart';
import 'package:jpstudy/features/jlpt/data/jlpt_reading_bank.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_reading_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'JLPT reading bank loads directly from immersion lessons without duplicate ids',
    () async {
      final jlptReadingBank = await loadJlptReadingBank();
      final immersionArticles = await ImmersionService().loadLocalSamples();

      expect(immersionArticles, isNotEmpty);
      expect(jlptReadingBank.length, immersionArticles.length);

      final ids = jlptReadingBank.map((entry) => entry.id).toList();
      expect(ids.toSet().length, ids.length);

      final immersionIds = immersionArticles
          .map((article) => article.id)
          .toList();
      expect(immersionIds.toSet().length, immersionIds.length);

      expect(jlptReadingBank.any((entry) => entry.level == 'N5'), isTrue);
      expect(jlptReadingBank.any((entry) => entry.level == 'N4'), isTrue);
      expect(jlptReadingBank.any((entry) => entry.level == 'N3'), isTrue);
      expect(
        jlptReadingBank.every((entry) => entry.questions.length == 3),
        isTrue,
      );

      expect(ids.toSet(), immersionIds.toSet());
    },
  );

  testWidgets('JlptReadingScreen hiển thị tiếng Việt đúng', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith(
            (ref) => AppLanguageController.test(AppLanguage.vi),
          ),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n3),
        ],
        child: const MaterialApp(home: JlptReadingScreen()),
      ),
    );

    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.byIcon(Icons.play_arrow_rounded).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.text('Luyện đọc hiểu JLPT'), findsWidgets);
    expect(
      find.text('Chọn đoạn văn và hoàn thành trong thời gian mục tiêu.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  test('JLPT reading meta pills render Vietnamese diacritics', () {
    expect(jlptReadingQuestionCountPillLabel(AppLanguage.vi, 3), '3 câu');
    expect(jlptReadingMinutesPillLabel(AppLanguage.vi, 9), '9 phút');
    expect(jlptReadingQuestionCountPillLabel(AppLanguage.ja, 3), '3問');
    expect(jlptReadingMinutesPillLabel(AppLanguage.ja, 9), '9分');
  });

  testWidgets('JlptReadingScreen follows the selected JLPT track', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith(
            (ref) => AppLanguageController.test(AppLanguage.en),
          ),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n4),
        ],
        child: const MaterialApp(home: JlptReadingScreen()),
      ),
    );

    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.byIcon(Icons.play_arrow_rounded).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.text('N4 track'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
