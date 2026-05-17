import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme_palette.dart';
import '../../core/app_language.dart';
import '../../core/language_provider.dart';
import '../../core/level_provider.dart';
import '../../core/services/session_storage_provider.dart';
import '../../core/study_level.dart';
import '../../data/repositories/lesson_repository.dart';
import '../../features/common/widgets/compact_ui.dart';
import '../test/models/test_config.dart';
import '../test/screens/test_config_screen.dart';
import '../test/screens/test_screen.dart';

class ExamScreen extends ConsumerWidget {
  const ExamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final selectedLevel = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final levels = [
      selectedLevel,
      ...StudyLevel.values.where((level) => level != selectedLevel),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(language.examTitle)),
      body: AppPageShell(
        topPadding: AppSpacing.sm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFeatureCard(
              icon: Icons.timer_outlined,
              title: language.examTitle,
              subtitle: language.mockExamSubtitle,
              status: AppStatusChip(
                label: selectedLevel.shortLabel,
                tone: AppStatusTone.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSectionHeader(title: _chooseLevelLabel(language)),
            const SizedBox(height: AppSpacing.sm),
            for (final level in levels) ...[
              _ExamLevelCard(
                level: level.shortLabel,
                subtitle: language.examSubtitle(level.shortLabel),
                onTap: () =>
                    _startMockExam(context, ref, language, level.shortLabel),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }

  String _chooseLevelLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Choose level';
      case AppLanguage.vi:
        return 'Chọn cấp độ';
      case AppLanguage.ja:
        return 'レベルを選ぶ';
    }
  }

  Future<void> _startMockExam(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
    String level,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = ref.read(lessonRepositoryProvider);
      final sessionKey = 'mock_$level';
      final storage = ref.read(sessionStorageProvider);

      // Fire vocab fetch and session resume load concurrently — independent.
      final vocabFuture = repo.getVocabByLevel(level);
      final resumeFuture = storage.loadTestSession(sessionKey);
      final allVocab = await vocabFuture;
      final resumeSnapshot = await resumeFuture;

      if (!context.mounted) return;
      Navigator.pop(context);

      if (allVocab.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(language.noTermsAvailableLabel)));
        return;
      }
      if (!context.mounted) return;

      final initialConfig = TestConfig.mockExam(questionCount: allVocab.length);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TestConfigScreen(
            lessonId: -1,
            lessonTitle: language.mockExamTitle(level),
            maxQuestions: allVocab.length,
            initialConfig: initialConfig,
            resumeSnapshot: resumeSnapshot,
            onResume: resumeSnapshot == null
                ? null
                : () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => TestScreen(
                          items: allVocab,
                          lessonId: -1,
                          lessonTitle: language.mockExamTitle(level),
                          config: resumeSnapshot.config,
                          resumeSnapshot: resumeSnapshot,
                          sessionKey: sessionKey,
                        ),
                      ),
                    );
                  },
            onDiscardResume: resumeSnapshot == null
                ? null
                : () async {
                    await storage.clearTestSession(sessionKey);
                  },
            onStart: (config) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => TestScreen(
                    items: allVocab,
                    lessonId: -1,
                    lessonTitle: language.mockExamTitle(level),
                    config: config,
                    sessionKey: sessionKey,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.loadErrorLabel)));
    }
  }
}

class _ExamLevelCard extends StatelessWidget {
  const _ExamLevelCard({
    required this.level,
    required this.subtitle,
    required this.onTap,
  });

  final String level;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return AppSectionCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [palette.primary, palette.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.timer_outlined,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JLPT $level',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.ink.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: palette.ink.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
