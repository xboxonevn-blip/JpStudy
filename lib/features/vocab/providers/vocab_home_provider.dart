import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';

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
  final selectedLevel = ref.watch(studyLevelProvider) ?? StudyLevel.n5;

  // Fire all independent queries concurrently.
  // Due count comes from the dashboard snapshot, which already uses aggregate
  // DAO queries and is the shared source of truth for home/release surfaces.
  final dashboardFuture = ref.watch(dashboardProvider.future);
  final nextReviewFuture = ref.watch(nextVocabReviewProvider.future);
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

  final dashboard = await dashboardFuture;
  final nextReview = await nextReviewFuture;
  final n5Core = await n5Future;
  final n4Core = await n4Future;
  final n3Core = await n3Future;
  final n2Core = await n2Future;
  final n1Core = await n1Future;
  final minnaN5 = await minnaN5Future;
  final minnaN4 = await minnaN4Future;

  return VocabHomeSection(
    selectedLevelCode: selectedLevel.shortLabel,
    dueCount: dashboard.vocabDue,
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
