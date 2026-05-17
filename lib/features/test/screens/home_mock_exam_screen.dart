import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/services/session_storage_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';

import '../../../core/services/session_storage.dart';
import '../models/home_mock_exam_launch_args.dart';
import '../models/test_config.dart';
import '../screens/test_config_screen.dart';
import '../screens/test_screen.dart';

typedef _MockExamData = ({List<VocabItem> vocab, TestSessionSnapshot? resume});

class ExamCenterHubScreen extends ConsumerWidget {
  const ExamCenterHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final selectedLevel = ref.watch(studyLevelProvider);
    final level = selectedLevel ?? StudyLevel.n5;
    final levelLabel = level.shortLabel;
    final daysUntilJlpt = _daysUntilNextJlpt(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            language,
            'JLPT Exam Center',
            '\u0110\u1ec1 thi JLPT',
            'JLPT\u8a66\u9a13',
          ),
        ),
      ),
      body: AppPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _text(
                      language,
                      'JLPT $levelLabel exam practice',
                      'Trung t\u00e2m luy\u1ec7n \u0111\u1ec1 JLPT $levelLabel',
                      'JLPT $levelLabel \u5bfe\u7b56',
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _text(
                      language,
                      'Mock exams, reading practice, weak-point recommendations, and history in one place.',
                      'Thi th\u1eed, luy\u1ec7n \u0111\u1ecdc, g\u1ee3i \u00fd \u0111i\u1ec3m y\u1ebfu v\u00e0 l\u1ecbch s\u1eed l\u00e0m b\u00e0i trong m\u1ed9t n\u01a1i.',
                      '\u6a21\u8a66\u3001\u8aad\u89e3\u3001\u5f31\u70b9\u30b3\u30fc\u30c1\u3001\u5c65\u6b74\u3092\u307e\u3068\u3081\u3066\u78ba\u8a8d\u3067\u304d\u307e\u3059\u3002',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppStatusChip(
                        label: _text(
                          language,
                          '$levelLabel default',
                          'M\u1eb7c \u0111\u1ecbnh $levelLabel',
                          levelLabel,
                        ),
                      ),
                      AppStatusChip(
                        label: _text(
                          language,
                          '$daysUntilJlpt days to JLPT',
                          'C\u00f2n $daysUntilJlpt ng\u00e0y t\u1edbi JLPT',
                          'JLPT\u307e\u3067$daysUntilJlpt\u65e5',
                        ),
                      ),
                      AppStatusChip(
                        label: _text(
                          language,
                          '105-min mock exam',
                          'Thi th\u1eed 105 ph\u00fat',
                          '105\u5206\u6a21\u8a66',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppFluidGrid(
              minItemWidth: 260,
              maxColumns: 2,
              children: [
                AppFeatureCard(
                  icon: Icons.assignment_turned_in_rounded,
                  title: _text(
                    language,
                    '$levelLabel mock exam (105 min)',
                    'Thi th\u1eed $levelLabel (105 ph\u00fat)',
                    '$levelLabel\u6a21\u8a66\uff08105\u5206\uff09',
                  ),
                  subtitle: _text(
                    language,
                    'Realistic full flow: vocabulary, grammar/reading, and listening timing.',
                    'M\u00f4 ph\u1ecfng b\u00e0i th\u1eadt: t\u1eeb v\u1ef1ng, ng\u1eef ph\u00e1p/\u0111\u1ecdc hi\u1ec3u v\u00e0 nghe theo \u0111\u00fang nh\u1ecbp thi.',
                    '\u8a9e\u5f59\u30fb\u6587\u6cd5/\u8aad\u89e3\u30fb\u8074\u89e3\u3092\u672c\u756a\u306b\u8fd1\u3044\u6642\u9593\u3067\u7df4\u7fd2\u3057\u307e\u3059\u3002',
                  ),
                  primaryLabel: _text(
                    language,
                    'Start mock',
                    'B\u1eaft \u0111\u1ea7u thi th\u1eed',
                    '\u958b\u59cb',
                  ),
                  onPrimaryTap: () => context.go(AppRoutePath.jlptMockPro),
                ),
                AppFeatureCard(
                  icon: Icons.menu_book_rounded,
                  title: _text(
                    language,
                    '$levelLabel reading practice',
                    'Luy\u1ec7n \u0111\u1ecdc $levelLabel',
                    '$levelLabel\u8aad\u89e3',
                  ),
                  subtitle: _text(
                    language,
                    'Short passages, comprehension questions, and mobile-friendly reading.',
                    '\u0110o\u1ea1n v\u0103n ng\u1eafn, c\u00e2u h\u1ecfi \u0111\u1ecdc hi\u1ec3u v\u00e0 b\u1ed1 c\u1ee5c d\u1ec5 \u0111\u1ecdc tr\u00ean \u0111i\u1ec7n tho\u1ea1i.',
                    '\u77ed\u3044\u6587\u7ae0\u3068\u8aad\u89e3\u554f\u984c\u3092\u30b9\u30de\u30db\u3067\u3082\u8aad\u307f\u3084\u3059\u304f\u7df4\u7fd2\u3057\u307e\u3059\u3002',
                  ),
                  primaryLabel: _text(
                    language,
                    'Practice reading',
                    'Luy\u1ec7n \u0111\u1ecdc',
                    '\u7df4\u7fd2',
                  ),
                  onPrimaryTap: () => context.go(AppRoutePath.jlptReading),
                ),
                AppFeatureCard(
                  icon: Icons.psychology_alt_rounded,
                  title: _text(
                    language,
                    'JLPT Coach',
                    'Coach JLPT',
                    'JLPT\u30b3\u30fc\u30c1',
                  ),
                  subtitle: _text(
                    language,
                    'Find weak points and get the next focused drill.',
                    'T\u00ecm \u0111i\u1ec3m y\u1ebfu tu\u1ea7n n\u00e0y v\u00e0 g\u1ee3i \u00fd b\u00e0i luy\u1ec7n ti\u1ebfp theo.',
                    '\u5f31\u70b9\u3092\u898b\u3064\u3051\u3066\u6b21\u306e\u7df4\u7fd2\u3092\u63d0\u6848\u3057\u307e\u3059\u3002',
                  ),
                  primaryLabel: _text(
                    language,
                    'Open recommendations',
                    'M\u1edf g\u1ee3i \u00fd',
                    '\u958b\u304f',
                  ),
                  onPrimaryTap: () => context.go(AppRoutePath.jlptCoach),
                ),
                AppFeatureCard(
                  icon: Icons.history_rounded,
                  title: _text(
                    language,
                    'Exam history',
                    'L\u1ecbch s\u1eed thi',
                    '\u5c65\u6b74',
                  ),
                  subtitle: _text(
                    language,
                    'Review attempts, scores, wrong answers, and progress over time.',
                    'Xem l\u1ea1i l\u01b0\u1ee3t l\u00e0m b\u00e0i, \u0111i\u1ec3m s\u1ed1, c\u00e2u sai v\u00e0 ti\u1ebfn b\u1ed9 theo th\u1eddi gian.',
                    '\u53d7\u9a13\u5c65\u6b74\u3001\u70b9\u6570\u3001\u9593\u9055\u3044\u3001\u6210\u9577\u3092\u78ba\u8a8d\u3057\u307e\u3059\u3002',
                  ),
                  primaryLabel: _text(
                    language,
                    'View history',
                    'Xem l\u1ecbch s\u1eed',
                    '\u5c65\u6b74',
                  ),
                  onPrimaryTap: () =>
                      context.go(AppRoutePath.lessonTestHistory),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCompactRow(
              icon: Icons.tune_rounded,
              title: _text(
                language,
                'Quick configurable mock',
                '\u0110\u1ec1 luy\u1ec7n t\u00f9y ch\u1ec9nh nhanh',
                '\u30af\u30a4\u30c3\u30af\u8a2d\u5b9a\u6a21\u8a66',
              ),
              subtitle: _text(
                language,
                'Choose question count, timer, and mode before starting.',
                'Ch\u1ecdn s\u1ed1 c\u00e2u, timer v\u00e0 ki\u1ec3u luy\u1ec7n tr\u01b0\u1edbc khi b\u1eaft \u0111\u1ea7u.',
                '\u554f\u984c\u6570\u3001\u30bf\u30a4\u30de\u30fc\u3001\u7df4\u7fd2\u5f62\u5f0f\u3092\u9078\u3093\u3067\u958b\u59cb\u3057\u307e\u3059\u3002',
              ),
              onTap: () => context.go(AppRoutePath.practiceMockExam),
            ),
          ],
        ),
      ),
    );
  }

  static String _text(AppLanguage language, String en, String vi, String ja) {
    return switch (language) {
      AppLanguage.en => en,
      AppLanguage.vi => vi,
      AppLanguage.ja => ja,
    };
  }

  static int _daysUntilNextJlpt(DateTime now) {
    final first = DateTime(now.year, 7, 12);
    final second = DateTime(now.year, 12, 12);
    final target = now.isBefore(first)
        ? first
        : now.isBefore(second)
        ? second
        : DateTime(now.year + 1, 7, 12);
    return target.difference(DateTime(now.year, now.month, now.day)).inDays;
  }
}

class HomeMockExamScreen extends ConsumerWidget {
  const HomeMockExamScreen({super.key, this.launchArgs});

  final HomeMockExamLaunchArgs? launchArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final selectedLevel = ref.watch(studyLevelProvider);
    final level = selectedLevel ?? StudyLevel.n5;

    final levelLabel = level.shortLabel;
    final repo = ref.read(lessonRepositoryProvider);
    final screenTitle =
        launchArgs?.titleOverride ?? language.mockExamTitle(levelLabel);

    // Compute sessionKey upfront so both futures can start concurrently.
    final suffix = launchArgs?.sessionKeySuffix?.trim();
    final sessionKey = (suffix == null || suffix.isEmpty)
        ? 'mock_$levelLabel'
        : 'mock_${suffix}_$levelLabel';
    final storage = ref.read(sessionStorageProvider);

    // Fire vocab fetch and resume-session load concurrently; they are independent.
    final combinedFuture = () async {
      final vocabFuture = repo.getVocabByLevel(levelLabel);
      final resumeFuture = storage.loadTestSession(sessionKey);
      return (vocab: await vocabFuture, resume: await resumeFuture);
    }();

    return FutureBuilder<_MockExamData>(
      future: combinedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(screenTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(screenTitle)),
            body: Center(child: Text(language.loadErrorLabel)),
          );
        }

        final allVocab = snapshot.data?.vocab ?? const [];
        if (allVocab.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(screenTitle)),
            body: Center(child: Text(language.noTermsAvailableLabel)),
          );
        }

        final resume = snapshot.data?.resume;
        final initialConfig =
            launchArgs?.initialConfig ??
            TestConfig.mockExam(questionCount: allVocab.length);

        return TestConfigScreen(
          lessonId: -1,
          lessonTitle: screenTitle,
          maxQuestions: allVocab.length,
          initialConfig: initialConfig,
          resumeSnapshot: resume,
          onResume: resume == null
              ? null
              : () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => TestScreen(
                        items: allVocab,
                        lessonId: -1,
                        lessonTitle: screenTitle,
                        config: resume.config,
                        resumeSnapshot: resume,
                        sessionKey: sessionKey,
                      ),
                    ),
                  );
                },
          onDiscardResume: resume == null
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
                  lessonTitle: screenTitle,
                  config: config,
                  sessionKey: sessionKey,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
