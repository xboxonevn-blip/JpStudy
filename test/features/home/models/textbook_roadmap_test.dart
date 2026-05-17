import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/home/models/textbook_roadmap.dart';

void main() {
  test('N5 roadmap starts with kana and Minna I phases', () {
    final roadmap = textbookRoadmapForLevel(StudyLevel.n5);

    expect(roadmap.level, StudyLevel.n5);
    expect(roadmap.phases, hasLength(4));
    expect(roadmap.phases.first.resourceKeys, contains('kana'));
    expect(roadmap.phases[1].resourceKeys, contains('minna_i_l1_12'));
    expect(roadmap.phases[2].resourceKeys, contains('hajimete_n5_optional'));
  });

  test('N3 roadmap sequences Shin Kanzen vocab before grammar', () {
    final roadmap = textbookRoadmapForLevel(StudyLevel.n3);
    final allResources = roadmap.phases
        .expand((phase) => phase.resourceKeys)
        .toSet();

    expect(allResources, contains('shin_kanzen_n3_vocab'));
    expect(allResources, contains('hajimete_n3_optional'));
    expect(allResources, contains('grammar_n3'));
    expect(allResources, contains('kanji_n3'));
    expect(allResources, contains('immersion_n3'));
    expect(roadmap.phases[0].resourceKeys, contains('shin_kanzen_n3_vocab'));
    expect(roadmap.phases[1].resourceKeys, contains('grammar_n3'));
    expect(roadmap.phases[0].resources.last.optional, isTrue);
  });

  test(
    'upper roadmap hides unavailable listening tracks and month promises',
    () {
      for (final level in [StudyLevel.n3, StudyLevel.n2, StudyLevel.n1]) {
        final roadmap = textbookRoadmapForLevel(level);
        final allResources = roadmap.phases.expand((phase) => phase.resources);
        final allResourceKeys = allResources.map((resource) => resource.key);
        final durationKeys = roadmap.phases.map((phase) => phase.durationKey);

        expect(
          allResourceKeys.where((key) => key.contains('listening')),
          isEmpty,
        );
        expect(
          durationKeys.where((key) => key.startsWith('upper_month_')),
          isEmpty,
        );
        expect(
          allResources.map((resource) => resource.destination),
          everyElement(isNot(isEmpty)),
        );
      }
    },
  );

  test(
    'N1 roadmap keeps immersion but does not claim full Shin Kanzen coverage',
    () {
      final roadmap = textbookRoadmapForLevel(StudyLevel.n1);

      expect(roadmap.phases[2].resourceKeys, contains('immersion_n1'));
      expect(roadmap.phases.last.resourceKeys, contains('jlpt_n1_mock'));
      expect(roadmap.phases.last.durationKey, 'upper_mock_hours');
    },
  );
}
