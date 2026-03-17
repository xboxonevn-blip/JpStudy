import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_mock_pro_screen.dart';

void main() {
  testWidgets('JlptMockProScreen hiển thị nhãn tiếng Việt đúng', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.vi)],
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
