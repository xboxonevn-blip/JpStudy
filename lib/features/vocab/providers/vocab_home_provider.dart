import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/vocab/vocab_content_timeout.dart';

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
    return null;
  }

  VocabTrackSummary? get selectedCompanionTrack {
    for (final track in liveTracks) {
      if (track.levelCode == selectedLevelCode && track.isCompanion) {
        return track;
      }
    }
    return null;
  }
}

final vocabNextReviewSnapshotProvider = Provider<DateTime?>((ref) {
  return ref.watch(nextVocabReviewProvider).value;
});

final vocabHomeSectionProvider = FutureProvider<VocabHomeSection>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  final selectedLevel = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
  final dueTermsFuture = ref.watch(allDueTermsProvider.future);
  final nextReview = ref.watch(vocabNextReviewSnapshotProvider);

  final dueCount = (await withVocabContentTimeout(
    dueTermsFuture,
    ref: ref,
  )).length;

  // Fire all remaining independent queries concurrently.
  final n5Future = repo.countVocabByLevelAndSeries('N5', 'hajimete');
  final n4Future = repo.countVocabByLevelAndSeries('N4', 'hajimete');
  final n3Future = repo.countVocabByLevelAndSeries('N3', 'hajimete');
  final n2Future = repo.countVocabByLevelAndSeries('N2', 'hajimete');
  final n1Future = repo.countVocabByLevelAndSeries('N1', 'hajimete');
  // Count using a SQL COUNT(*) backed by idx_vocab_level_series — avoids
  // fetching full VocabItem rows just to call .length on the result.
  // N5 minna = lessons 1-25 (the entire N5 minna series) and likewise for N4.
  final minnaN5Future = repo.countVocabByLevelAndSeries('N5', 'minna');
  final minnaN4Future = repo.countVocabByLevelAndSeries('N4', 'minna');

  final counts = await withVocabContentTimeout(
    Future.wait<int>([
      n5Future,
      n4Future,
      n3Future,
      n2Future,
      n1Future,
      minnaN5Future,
      minnaN4Future,
    ]),
    ref: ref,
  );
  final n5Core = counts[0];
  final n4Core = counts[1];
  final n3Core = counts[2];
  final n2Core = counts[3];
  final n1Core = counts[4];
  final minnaN5 = counts[5];
  final minnaN4 = counts[6];

  return VocabHomeSection(
    selectedLevelCode: selectedLevel.shortLabel,
    dueCount: dueCount,
    nextReview: nextReview,
    liveTracks: [
      VocabTrackSummary(
        key: 'n5_core',
        levelCode: 'N5',
        title: 'Hajimete N5',
        subtitle: 'Core JLPT vocabulary path',
        termCount: n5Core,
        isInteractive: n5Core > 0,
        isPreview: false,
        isCompanion: false,
      ),
      VocabTrackSummary(
        key: 'n5_minna',
        levelCode: 'N5',
        title: 'Minna no Nihongo I',
        subtitle: 'Textbook companion review',
        termCount: minnaN5,
        isInteractive: minnaN5 > 0,
        isPreview: false,
        isCompanion: true,
      ),
      VocabTrackSummary(
        key: 'n4_core',
        levelCode: 'N4',
        title: 'Hajimete N4',
        subtitle: 'Core JLPT vocabulary path',
        termCount: n4Core,
        isInteractive: n4Core > 0,
        isPreview: false,
        isCompanion: false,
      ),
      VocabTrackSummary(
        key: 'n4_minna',
        levelCode: 'N4',
        title: 'Minna no Nihongo II',
        subtitle: 'Textbook companion review',
        termCount: minnaN4,
        isInteractive: minnaN4 > 0,
        isPreview: false,
        isCompanion: true,
      ),
      VocabTrackSummary(
        key: 'n3_core',
        levelCode: 'N3',
        title: 'Hajimete N3',
        subtitle: 'Core JLPT vocabulary path',
        termCount: n3Core,
        isInteractive: n3Core > 0,
        isPreview: false,
        isCompanion: false,
      ),
      VocabTrackSummary(
        key: 'n2_core',
        levelCode: 'N2',
        title: 'Hajimete N2',
        subtitle: 'Core JLPT vocabulary path',
        termCount: n2Core,
        isInteractive: n2Core > 0,
        isPreview: false,
        isCompanion: false,
      ),
      VocabTrackSummary(
        key: 'n1_core',
        levelCode: 'N1',
        title: 'Hajimete N1',
        subtitle: 'Core JLPT vocabulary path',
        termCount: n1Core,
        isInteractive: n1Core > 0,
        isPreview: false,
        isCompanion: false,
      ),
    ],
    previewTracks: [
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
