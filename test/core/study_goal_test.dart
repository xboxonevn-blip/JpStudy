import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_goal.dart';

void main() {
  test('Vietnamese study goal labels render with real diacritics', () {
    expect(StudyGoal.reading.label(AppLanguage.vi), '??c ti?ng Nh?t');
    expect(
      StudyGoal.jlpt.description(AppLanguage.vi),
      'Chu?n b? k? thi N5, N4, N3, N2, N1',
    );
    expect(StudyGoal.writing.label(AppLanguage.vi), 'Luy?n vi?t');
  });
}
