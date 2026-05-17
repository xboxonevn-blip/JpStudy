import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/foundations/widgets/foundations_soft_suggest_gate.dart';

void main() {
  test('foundations soft suggest is limited to N5 learners', () {
    expect(shouldSuggestFoundationsForLevel(null), isTrue);
    expect(shouldSuggestFoundationsForLevel(StudyLevel.n5), isTrue);

    expect(shouldSuggestFoundationsForLevel(StudyLevel.n4), isFalse);
    expect(shouldSuggestFoundationsForLevel(StudyLevel.n3), isFalse);
    expect(shouldSuggestFoundationsForLevel(StudyLevel.n2), isFalse);
    expect(shouldSuggestFoundationsForLevel(StudyLevel.n1), isFalse);
  });
}
