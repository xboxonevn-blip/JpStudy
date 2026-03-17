import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/design_lab/design_lab_screen.dart';

void main() {
  testWidgets('DesignLabScreen hiển thị tiếng Việt khi chọn tiếng Việt', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.vi),
        ],
        child: const MaterialApp(home: DesignLabScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Phòng thí nghiệm thiết kế'), findsOneWidget);
    expect(find.text('Giai đoạn hiện tại'), findsOneWidget);
    expect(find.text('Khám phá'), findsOneWidget);
  });
}
