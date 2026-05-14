import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_goal.dart';

void main() {
  test('Vietnamese study goal labels render with real diacritics', () {
    expect(StudyGoal.jlpt.label(AppLanguage.vi), 'Luyện thi JLPT');
    expect(StudyGoal.reading.label(AppLanguage.vi), 'Đọc tiếng Nhật');
    expect(StudyGoal.writing.label(AppLanguage.vi), 'Luyện viết');
    expect(
      StudyGoal.jlpt.description(AppLanguage.vi),
      'Chuẩn bị kỳ thi N5, N4, N3, N2, N1',
    );
    expect(
      StudyGoal.reading.description(AppLanguage.vi),
      'Manga, tin tức, sách',
    );
  });
}
