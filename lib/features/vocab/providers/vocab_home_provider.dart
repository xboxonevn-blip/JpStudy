import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';

class VocabTrackSummary {
  const VocabTrackSummary({
    required this.key,
    required this.levelCode,
    required this.title,
    required this.subtitle,
    required this.termCount,
    required this.isInteractive,
    required this.isPreview,
    required this.isCompanion,
  });

  final String key;
  final String levelCode;
  final String title;
  final String subtitle;
  final int termCount;
  final bool isInteractive;
  final bool isPreview;
  final bool isCompanion;
}

class VocabHomeSection {
  const VocabHomeSection({
    required this.selectedLevelCode,
    required this.dueCount,
    required this.nextReview,
    required this.liveTracks,
    required this.previewTracks,
  });

  final String selectedLevelCode;
  final int dueCount;
  final DateTime? nextReview;
  final List<VocabTrackSummary> liveTracks;
  final List<VocabTrackSummary> previewTracks;

  VocabTrackSummary? get recommendedTrack {
    for (final track in liveTracks) {
      if (track.levelCode == selectedLevelCode) {
        return track;
      }
    }
    return liveTracks.isEmpty ? null : liveTracks.first;
  }
}

final vocabHomeSectionProvider = FutureProvider<VocabHomeSection>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  final dueTerms = await ref.watch(allDueTermsProvider.future);
  final nextReview = await ref.watch(nextVocabReviewProvider.future);
  final selectedLevel = ref.watch(studyLevelProvider) ?? StudyLevel.n5;

  Future<int> countLevel(String levelCode, String series) async {
    return (await repo.getVocabByLevelAndSeries(levelCode, series)).length;
  }

  Future<int> countMinna(String levelCode, int start, int end) async {
    return (await repo.getVocabByLessonRange(
      levelCode,
      startLesson: start,
      endLesson: end,
      series: 'minna',
    )).length;
  }

  final n5Core = await countLevel('N5', 'hajimete');
  final n4Core = await countLevel('N4', 'hajimete');
  final n3Core = await countLevel('N3', 'hajimete');
  final n2Core = await countLevel('N2', 'hajimete');
  final n1Core = await countLevel('N1', 'hajimete');
  final minnaN5 = await countMinna('N5', 1, 25);
  final minnaN4 = await countMinna('N4', 26, 50);

  return VocabHomeSection(
    selectedLevelCode: selectedLevel.shortLabel,
    dueCount: dueTerms.length,
    nextReview: nextReview,
    liveTracks: [
      VocabTrackSummary(
        key: 'n5_core',
        levelCode: 'N5',
        title: 'Hajimete N5',
        subtitle: 'Core JLPT lane',
        termCount: n5Core,
        isInteractive: n5Core > 0,
        isPreview: false,
        isCompanion: false,
      ),
      VocabTrackSummary(
        key: 'n5_minna',
        levelCode: 'N5',
        title: 'Minna no Nihongo I',
        subtitle: 'Companion lesson-range review',
        termCount: minnaN5,
        isInteractive: minnaN5 > 0,
        isPreview: false,
        isCompanion: true,
      ),
      VocabTrackSummary(
        key: 'n4_core',
        levelCode: 'N4',
        title: 'Hajimete N4',
        subtitle: 'Core JLPT lane',
        termCount: n4Core,
        isInteractive: n4Core > 0,
        isPreview: false,
        isCompanion: false,
      ),
      VocabTrackSummary(
        key: 'n4_minna',
        levelCode: 'N4',
        title: 'Minna no Nihongo II',
        subtitle: 'Companion lesson-range review',
        termCount: minnaN4,
        isInteractive: minnaN4 > 0,
        isPreview: false,
        isCompanion: true,
      ),
    ],
    previewTracks: [
      VocabTrackSummary(
        key: 'n3_core',
        levelCode: 'N3',
        title: 'Hajimete N3',
        subtitle: 'Preview / roadmap',
        termCount: n3Core,
        isInteractive: false,
        isPreview: n3Core > 0,
        isCompanion: false,
      ),
      VocabTrackSummary(
        key: 'n2_core',
        levelCode: 'N2',
        title: 'Hajimete N2',
        subtitle: 'Preview / roadmap',
        termCount: n2Core,
        isInteractive: false,
        isPreview: n2Core > 0,
        isCompanion: false,
      ),
      VocabTrackSummary(
        key: 'n1_core',
        levelCode: 'N1',
        title: 'Hajimete N1',
        subtitle: 'Preview / roadmap',
        termCount: n1Core,
        isInteractive: false,
        isPreview: n1Core > 0,
        isCompanion: false,
      ),
      const VocabTrackSummary(
        key: 'se_core',
        levelCode: 'SE',
        title: 'Software Engineering Japanese',
        subtitle: 'Preview / roadmap',
        termCount: 0,
        isInteractive: false,
        isPreview: false,
        isCompanion: false,
      ),
    ],
  );
});
