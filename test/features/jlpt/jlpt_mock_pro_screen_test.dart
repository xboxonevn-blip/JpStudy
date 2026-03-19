import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/jlpt/data/jlpt_mock_bank.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_mock_models.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_mock_pro_screen.dart';

void main() {
  const mockSections = <JlptMockSection>[
    JlptMockSection(
      id: 'vocab',
      title: 'Vocabulary',
      minutes: 8,
      questions: [
        JlptMockQuestion(
          id: 'v-1',
          area: JlptSkillArea.vocabulary,
          prompt: '"予約" có nghĩa là gì?',
          options: ['Đặt trước', 'Hủy lịch', 'Rời đi ngay', 'Mượn tiền'],
          correctIndex: 0,
          explanation: '予約 = đặt trước.',
        ),
        JlptMockQuestion(
          id: 'v-2',
          area: JlptSkillArea.vocabulary,
          prompt: '"毎週" có nghĩa là gì?',
          options: ['Mỗi tuần', 'Mỗi tháng', 'Mỗi ngày', 'Mỗi năm'],
          correctIndex: 0,
          explanation: '毎週 = mỗi tuần.',
        ),
      ],
    ),
  ];

  testWidgets('JlptMockProScreen hiển thị nhãn tiếng Việt đúng', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.vi),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          jlptMockSectionsProvider((
            level: StudyLevel.n5,
            language: AppLanguage.vi,
          )).overrideWith((ref) async => mockSections),
        ],
        child: const MaterialApp(home: JlptMockProScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Đề thi thử JLPT Pro'), findsWidgets);
    expect(
      find.text(
        'Mô phỏng đủ phần thi, có bấm giờ theo từng section và dự đoán khả năng đậu.',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Bắt đầu thi thử đầy đủ'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final startButton = find.text('Bắt đầu thi thử đầy đủ');
    expect(startButton, findsOneWidget);

    await tester.tap(startButton);
    await tester.pump();

    expect(find.text('Kết thúc ngay'), findsOneWidget);
    expect(find.text('Câu tiếp'), findsOneWidget);
  });
}
