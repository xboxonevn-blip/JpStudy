import 'package:jpstudy/core/study_level.dart';

class TextbookRoadmap {
  const TextbookRoadmap({required this.level, required this.phases});

  final StudyLevel level;
  final List<TextbookRoadmapPhase> phases;
}

class TextbookRoadmapPhase {
  const TextbookRoadmapPhase({
    required this.id,
    required this.durationKey,
    required this.resourceKeys,
  });

  final String id;
  final String durationKey;
  final List<String> resourceKeys;
}

TextbookRoadmap textbookRoadmapForLevel(StudyLevel level) {
  return switch (level) {
    StudyLevel.n5 => const TextbookRoadmap(
      level: StudyLevel.n5,
      phases: [
        TextbookRoadmapPhase(
          id: 'n5_kana_kanji',
          durationKey: 'n5_weeks_1_2',
          resourceKeys: ['kana', 'kanji_n5_core'],
        ),
        TextbookRoadmapPhase(
          id: 'n5_minna_1_12',
          durationKey: 'n5_weeks_3_6',
          resourceKeys: ['minna_i', 'minna_i_l1_12'],
        ),
        TextbookRoadmapPhase(
          id: 'n5_minna_13_25',
          durationKey: 'n5_weeks_7_10',
          resourceKeys: ['minna_i_l13_25', 'hajimete_n5', 'kanji_n5_plus'],
        ),
        TextbookRoadmapPhase(
          id: 'n5_mock_review',
          durationKey: 'n5_weeks_11_12',
          resourceKeys: ['jlpt_n5_mock', 'weak_point_review'],
        ),
      ],
    ),
    StudyLevel.n4 => const TextbookRoadmap(
      level: StudyLevel.n4,
      phases: [
        TextbookRoadmapPhase(
          id: 'n4_minna_26_37',
          durationKey: 'n4_weeks_1_4',
          resourceKeys: ['minna_ii_l26_37', 'hajimete_n4_ch1_10'],
        ),
        TextbookRoadmapPhase(
          id: 'n4_minna_38_50',
          durationKey: 'n4_weeks_5_8',
          resourceKeys: ['minna_ii_l38_50', 'hajimete_n4_ch11_20'],
        ),
        TextbookRoadmapPhase(
          id: 'n4_mock_reading',
          durationKey: 'n4_weeks_9_12',
          resourceKeys: ['jlpt_n4_mock', 'n4_reading_practice'],
        ),
      ],
    ),
    StudyLevel.n3 => _upperRoadmap(
      level: StudyLevel.n3,
      levelCode: 'n3',
      hajimete: 'hajimete_n3',
    ),
    StudyLevel.n2 => _upperRoadmap(
      level: StudyLevel.n2,
      levelCode: 'n2',
      hajimete: 'hajimete_n2',
    ),
    StudyLevel.n1 => const TextbookRoadmap(
      level: StudyLevel.n1,
      phases: [
        TextbookRoadmapPhase(
          id: 'n1_vocab_grammar',
          durationKey: 'upper_month_1',
          resourceKeys: [
            'hajimete_n1',
            'shin_kanzen_n1_vocab',
            'shin_kanzen_n1_grammar',
          ],
        ),
        TextbookRoadmapPhase(
          id: 'n1_reading_listening_kanji',
          durationKey: 'upper_month_2',
          resourceKeys: [
            'shin_kanzen_n1_reading',
            'shin_kanzen_n1_listening',
            'shin_kanzen_n1_kanji',
          ],
        ),
        TextbookRoadmapPhase(
          id: 'n1_mock_repair',
          durationKey: 'upper_month_3',
          resourceKeys: ['jlpt_n1_mock', 'weak_point_review'],
        ),
        TextbookRoadmapPhase(
          id: 'n1_immersion',
          durationKey: 'n1_immersion',
          resourceKeys: ['immersion_n1'],
        ),
      ],
    ),
  };
}

TextbookRoadmap _upperRoadmap({
  required StudyLevel level,
  required String levelCode,
  required String hajimete,
}) {
  return TextbookRoadmap(
    level: level,
    phases: [
      TextbookRoadmapPhase(
        id: '${levelCode}_vocab',
        durationKey: 'upper_month_1',
        resourceKeys: [
          hajimete,
          'shin_kanzen_${levelCode}_vocab',
          'shin_kanzen_${levelCode}_grammar',
        ],
      ),
      TextbookRoadmapPhase(
        id: '${levelCode}_reading_listening_kanji',
        durationKey: 'upper_month_2',
        resourceKeys: [
          'shin_kanzen_${levelCode}_reading',
          'shin_kanzen_${levelCode}_listening',
          'shin_kanzen_${levelCode}_kanji',
        ],
      ),
      TextbookRoadmapPhase(
        id: '${levelCode}_mock_repair',
        durationKey: 'upper_month_3',
        resourceKeys: ['jlpt_${levelCode}_mock', 'weak_point_review'],
      ),
      TextbookRoadmapPhase(
        id: '${levelCode}_retention',
        durationKey: 'upper_mock_cycle',
        resourceKeys: ['reading_replay', 'weak_point_review'],
      ),
    ],
  );
}
