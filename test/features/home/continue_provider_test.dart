import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';

void main() {
  test('upper JLPT next lesson label uses Shin Kanzen source title', () {
    expect(
      continueLessonLabelForTesting(AppLanguage.vi, StudyLevel.n2, 200001),
      'Shin Kanzen N2 Bài 1',
    );
  });
}
