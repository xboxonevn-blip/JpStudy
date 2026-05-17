import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_route_locations.dart';
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
    required this.resources,
  });

  final String id;
  final String durationKey;
  final List<TextbookRoadmapResource> resources;

  List<String> get resourceKeys =>
      resources.map((resource) => resource.key).toList(growable: false);
}

class TextbookRoadmapResource {
  const TextbookRoadmapResource({
    required this.key,
    required this.destination,
    this.optional = false,
  });

  final String key;
  final String destination;
  final bool optional;
}

TextbookRoadmap textbookRoadmapForLevel(StudyLevel level) {
  return switch (level) {
    StudyLevel.n5 => TextbookRoadmap(
      level: StudyLevel.n5,
      phases: [
        TextbookRoadmapPhase(
          id: 'n5_kana_kanji',
          durationKey: 'n5_weeks_1_2',
          resources: [
            TextbookRoadmapResource(
              key: 'kana',
              destination: AppRoutePath.foundations,
            ),
            TextbookRoadmapResource(
              key: 'kanji_n5_core',
              destination: AppRoutePath.kanji,
            ),
          ],
        ),
        TextbookRoadmapPhase(
          id: 'n5_minna_1_12',
          durationKey: 'n5_weeks_3_6',
          resources: [
            TextbookRoadmapResource(
              key: 'minna_i_l1_12',
              destination: AppRouteLocation.minnaCatalog(
                levelCode: 'N5',
                title: 'Minna no Nihongo I',
                lessonStart: 1,
                lessonEnd: 12,
              ),
            ),
          ],
        ),
        TextbookRoadmapPhase(
          id: 'n5_minna_13_25',
          durationKey: 'n5_weeks_7_10',
          resources: [
            TextbookRoadmapResource(
              key: 'minna_i_l13_25',
              destination: AppRouteLocation.minnaCatalog(
                levelCode: 'N5',
                title: 'Minna no Nihongo I',
                lessonStart: 13,
                lessonEnd: 25,
              ),
            ),
            TextbookRoadmapResource(
              key: 'hajimete_n5_optional',
              destination: AppRouteLocation.hajimeteCatalog(
                levelCode: 'N5',
                title: 'Hajimete no Nihongo Tango N5',
              ),
              optional: true,
            ),
            TextbookRoadmapResource(
              key: 'kanji_n5_plus',
              destination: AppRoutePath.kanji,
            ),
          ],
        ),
        TextbookRoadmapPhase(
          id: 'n5_mock_review',
          durationKey: 'n5_weeks_11_12',
          resources: [
            TextbookRoadmapResource(
              key: 'jlpt_n5_mock',
              destination: AppRoutePath.examCenter,
            ),
          ],
        ),
      ],
    ),
    StudyLevel.n4 => TextbookRoadmap(
      level: StudyLevel.n4,
      phases: [
        TextbookRoadmapPhase(
          id: 'n4_minna_26_37',
          durationKey: 'n4_weeks_1_4',
          resources: [
            TextbookRoadmapResource(
              key: 'minna_ii_l26_37',
              destination: AppRouteLocation.minnaCatalog(
                levelCode: 'N4',
                title: 'Minna no Nihongo II',
                lessonStart: 26,
                lessonEnd: 37,
              ),
            ),
            TextbookRoadmapResource(
              key: 'hajimete_n4_optional',
              destination: AppRouteLocation.hajimeteCatalog(
                levelCode: 'N4',
                title: 'Hajimete no Nihongo Tango N4',
              ),
              optional: true,
            ),
          ],
        ),
        TextbookRoadmapPhase(
          id: 'n4_minna_38_50',
          durationKey: 'n4_weeks_5_8',
          resources: [
            TextbookRoadmapResource(
              key: 'minna_ii_l38_50',
              destination: AppRouteLocation.minnaCatalog(
                levelCode: 'N4',
                title: 'Minna no Nihongo II',
                lessonStart: 38,
                lessonEnd: 50,
              ),
            ),
          ],
        ),
        TextbookRoadmapPhase(
          id: 'n4_mock_reading',
          durationKey: 'n4_weeks_9_12',
          resources: [
            TextbookRoadmapResource(
              key: 'jlpt_n4_mock',
              destination: AppRoutePath.examCenter,
            ),
          ],
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
    StudyLevel.n1 => TextbookRoadmap(
      level: StudyLevel.n1,
      phases: [
        TextbookRoadmapPhase(
          id: 'n1_vocab',
          durationKey: 'upper_vocab_hours',
          resources: [
            TextbookRoadmapResource(
              key: 'shin_kanzen_n1_vocab',
              destination: AppRouteLocation.shinkanzenCatalog(
                levelCode: 'N1',
                title: 'Shin Kanzen Master N1',
              ),
            ),
            TextbookRoadmapResource(
              key: 'hajimete_n1_optional',
              destination: AppRouteLocation.hajimeteCatalog(
                levelCode: 'N1',
                title: 'Hajimete no Nihongo Tango N1',
              ),
              optional: true,
            ),
          ],
        ),
        TextbookRoadmapPhase(
          id: 'n1_grammar',
          durationKey: 'upper_grammar_hours',
          resources: [
            TextbookRoadmapResource(
              key: 'grammar_n1',
              destination: AppRoutePath.grammar,
            ),
          ],
        ),
        TextbookRoadmapPhase(
          id: 'n1_reading_kanji',
          durationKey: 'upper_skill_hours',
          resources: [
            TextbookRoadmapResource(
              key: 'kanji_n1',
              destination: AppRoutePath.kanji,
            ),
            TextbookRoadmapResource(
              key: 'immersion_n1',
              destination: AppRoutePath.immersion,
            ),
          ],
        ),
        TextbookRoadmapPhase(
          id: 'n1_mock_repair',
          durationKey: 'upper_mock_hours',
          resources: [
            TextbookRoadmapResource(
              key: 'jlpt_n1_mock',
              destination: AppRoutePath.examCenter,
            ),
          ],
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
        durationKey: 'upper_vocab_hours',
        resources: [
          TextbookRoadmapResource(
            key: 'shin_kanzen_${levelCode}_vocab',
            destination: AppRouteLocation.shinkanzenCatalog(
              levelCode: level.shortLabel,
              title: 'Shin Kanzen Master ${level.shortLabel}',
            ),
          ),
          TextbookRoadmapResource(
            key: '${hajimete}_optional',
            destination: AppRouteLocation.hajimeteCatalog(
              levelCode: level.shortLabel,
              title: 'Hajimete no Nihongo Tango ${level.shortLabel}',
            ),
            optional: true,
          ),
        ],
      ),
      TextbookRoadmapPhase(
        id: '${levelCode}_grammar',
        durationKey: 'upper_grammar_hours',
        resources: [
          TextbookRoadmapResource(
            key: 'grammar_$levelCode',
            destination: AppRoutePath.grammar,
          ),
        ],
      ),
      TextbookRoadmapPhase(
        id: '${levelCode}_reading_kanji',
        durationKey: 'upper_skill_hours',
        resources: [
          TextbookRoadmapResource(
            key: 'kanji_$levelCode',
            destination: AppRoutePath.kanji,
          ),
          TextbookRoadmapResource(
            key: 'immersion_$levelCode',
            destination: AppRoutePath.immersion,
          ),
        ],
      ),
      TextbookRoadmapPhase(
        id: '${levelCode}_mock_repair',
        durationKey: 'upper_mock_hours',
        resources: [
          TextbookRoadmapResource(
            key: 'jlpt_${levelCode}_mock',
            destination: AppRoutePath.examCenter,
          ),
        ],
      ),
    ],
  );
}
