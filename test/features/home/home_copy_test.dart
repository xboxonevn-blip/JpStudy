import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/home/home_copy.dart';

void main() {
  test('learning path Vietnamese copy avoids mixed lane/session wording', () {
    expect(
      AppLanguage.vi.learningPathStudyPromptSubtitle(),
      'Màn hình này giờ ưu tiên buổi học, bài luyện và bước tiếp theo thật rõ ràng.',
    );
    expect(AppLanguage.vi.learningHeroPrimaryLabel(), 'Bắt đầu học');
    expect(AppLanguage.vi.learningOpenLaneLabel(), 'Mở hướng này');
  });

  test('learning path Japanese copy stays fully localized', () {
    expect(AppLanguage.ja.learningPathFocusChipLabel(3), '3件の復習が待機中');
    expect(
      AppLanguage.ja.learningLanesSubtitle(),
      '記事一覧ではなく、ドリル・試験・実読の3レーンから始めます。',
    );
  });

  test('home provider route hints do not contain mojibake markers', () {
    final files = [
      File('lib/features/home/providers/daily_plan_provider.dart'),
      File('lib/features/home/providers/weakness_radar_provider.dart'),
    ];

    for (final file in files) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('???')), reason: file.path);
      expect(source, isNot(contains('H??ng')), reason: file.path);
      expect(source, isNot(contains('Nh??m')), reason: file.path);
    }
  });
}
