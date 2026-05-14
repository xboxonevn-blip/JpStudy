import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/home/models/textbook_roadmap.dart';

void main() {
  test('N5 roadmap starts with kana and Minna I phases', () {
    final roadmap = textbookRoadmapForLevel(StudyLevel.n5);

    expect(roadmap.level, StudyLevel.n5);
    expect(roadmap.phases, hasLength(4));
    expect(roadmap.phases.first.resourceKeys, contains('kana'));
    expect(roadmap.phases[1].resourceKeys, contains('minna_i'));
    expect(roadmap.phases[2].resourceKeys, contains('hajimete_n5'));
  });

  test('N3 roadmap uses Hajimete plus Shin Kanzen tracks', () {
    final roadmap = textbookRoadmapForLevel(StudyLevel.n3);
    final allResources = roadmap.phases
        .expand((phase) => phase.resourceKeys)
        .toSet();

    expect(allResources, contains('hajimete_n3'));
    expect(allResources, contains('shin_kanzen_n3_vocab'));
    expect(allResources, contains('shin_kanzen_n3_grammar'));
    expect(allResources, contains('shin_kanzen_n3_reading'));
    expect(allResources, contains('shin_kanzen_n3_listening'));
    expect(allResources, contains('shin_kanzen_n3_kanji'));
  });

  test('N1 roadmap adds immersion after Shin Kanzen coverage', () {
    final roadmap = textbookRoadmapForLevel(StudyLevel.n1);

    expect(roadmap.phases.last.resourceKeys, contains('immersion_n1'));
    expect(roadmap.phases.last.durationKey, 'n1_immersion');
  });
}
