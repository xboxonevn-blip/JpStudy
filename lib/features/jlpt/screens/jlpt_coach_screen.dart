import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/content_database_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_exam_modes_panel.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_plan_panel.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_prep_hero.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_readiness_panel.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_support_panel.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';

import '../data/jlpt_mock_bank.dart';
import '../data/jlpt_reading_bank.dart';
import '../services/jlpt_coach_service.dart';

final jlptPrepOverviewProvider =
    FutureProvider.family<JlptPrepOverview, StudyLevel>((ref, level) async {
      final repo = ref.watch(lessonRepositoryProvider);
      final contentDb = ref.watch(contentDatabaseProvider);
      final language = ref.watch(appLanguageProvider);
      final quickMockBankFuture = repo.getVocabByLevel(level.shortLabel);
      final passagesFuture = loadJlptReadingBank();
      final fullMockSectionsFuture = buildJlptMockSections(
        level: level,
        language: language,
        contentDb: contentDb,
        lessonRepo: repo,
      );

      final quickMockBank = await quickMockBankFuture;
      final passages = await passagesFuture;
      final levelPassages = passages
          .where((entry) => entry.level == level.shortLabel)
          .toList(growable: false);
      final fullMockSections = await fullMockSectionsFuture;

      return JlptPrepOverview(
        quickMockQuestionCount: quickMockBank.length,
        readingPassageCount: levelPassages.length,
        readingQuestionCount: levelPassages.fold<int>(
          0,
          (sum, passage) => sum + passage.questions.length,
        ),
        fullMockQuestionCount: fullMockSections.fold<int>(
          0,
          (sum, section) => sum + section.questions.length,
        ),
        fullMockMinutes: fullMockSections.fold<int>(
          0,
          (sum, section) => sum + section.minutes,
        ),
        fullMockSectionCount: fullMockSections.length,
      );
    });

class JlptPrepOverview {
  const JlptPrepOverview({
    required this.quickMockQuestionCount,
    required this.readingPassageCount,
    required this.readingQuestionCount,
    required this.fullMockQuestionCount,
    required this.fullMockMinutes,
    required this.fullMockSectionCount,
  });

  const JlptPrepOverview.placeholder()
    : quickMockQuestionCount = 0,
      readingPassageCount = 0,
      readingQuestionCount = 0,
      fullMockQuestionCount = 0,
      fullMockMinutes = 0,
      fullMockSectionCount = 0;

  final int quickMockQuestionCount;
  final int readingPassageCount;
  final int readingQuestionCount;
  final int fullMockQuestionCount;
  final int fullMockMinutes;
  final int fullMockSectionCount;
}

class JlptCoachScreen extends ConsumerWidget {
  const JlptCoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final snapshot = ref.watch(jlptCoachSnapshotProvider).value;
    final overviewAsync = ref.watch(jlptPrepOverviewProvider(level));
    final overview =
        overviewAsync.value ?? const JlptPrepOverview.placeholder();
    final mistakeRepo = ref.watch(mistakeRepositoryProvider);
    final (vocabDue, grammarDue, kanjiDue) = ref.watch(
      dashboardProvider.select((v) {
        final d = v.value;
        return (d?.vocabDue ?? 0, d?.grammarDue ?? 0, d?.kanjiDue ?? 0);
      }),
    );
    final dueCount = vocabDue + grammarDue + kanjiDue;

    return Scaffold(
      appBar: AppBar(title: Text(_screenTitle(language))),
      body: AppPageShell(
        topPadding: AppSpacing.sm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JlptPrepHero(
              language: language,
              level: level,
              snapshot: snapshot,
              fullMockQuestionCount: overview.fullMockQuestionCount,
              fullMockMinutes: overview.fullMockMinutes,
              quickMockQuestionCount: overview.quickMockQuestionCount,
              readingPassageCount: overview.readingPassageCount,
              isLoading: overviewAsync.isLoading,
              onPrimaryTap: () => context.openJlptMockPro(),
              onSecondaryTap: () => context.openJlptReading(),
            ),
            const SizedBox(height: AppSpacing.md),
            JlptExamModesPanel(
              language: language,
              level: level,
              snapshot: snapshot,
              fullMockSectionCount: overview.fullMockSectionCount,
              fullMockQuestionCount: overview.fullMockQuestionCount,
              fullMockMinutes: overview.fullMockMinutes,
              quickMockQuestionCount: overview.quickMockQuestionCount,
              readingPassageCount: overview.readingPassageCount,
              readingQuestionCount: overview.readingQuestionCount,
              isLoading: overviewAsync.isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 920;
                final readinessPanel = JlptReadinessPanel(
                  language: language,
                  snapshot: snapshot,
                );
                final supportPanel = JlptSupportPanel(
                  language: language,
                  level: level,
                  dueCount: dueCount,
                  vocabDue: vocabDue,
                  grammarDue: grammarDue,
                  kanjiDue: kanjiDue,
                  mistakeStream: mistakeRepo.watchAllMistakes(),
                );

                if (!wide) {
                  return Column(
                    children: [
                      readinessPanel,
                      const SizedBox(height: AppSpacing.md),
                      supportPanel,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: readinessPanel),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(flex: 5, child: supportPanel),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            JlptPlanPanel(
              language: language,
              snapshot: snapshot,
              levelCode: level.shortLabel,
            ),
          ],
        ),
      ),
    );
  }
}

String _screenTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'JLPT Prep',
  AppLanguage.vi => 'Ôn thi JLPT',
  AppLanguage.ja => 'JLPT試験対策',
};


