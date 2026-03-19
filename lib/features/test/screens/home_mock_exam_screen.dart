import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/services/session_storage_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';

import '../models/home_mock_exam_launch_args.dart';
import '../models/test_config.dart';
import '../screens/test_config_screen.dart';
import '../screens/test_screen.dart';

class HomeMockExamScreen extends ConsumerWidget {
  const HomeMockExamScreen({super.key, this.launchArgs});

  final HomeMockExamLaunchArgs? launchArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);

    if (level == null) {
      return Scaffold(
        appBar: AppBar(title: Text(language.practiceExamLabel)),
        body: Center(child: Text(language.levelMenuTitle)),
      );
    }

    final levelLabel = level.shortLabel;
    final repo = ref.read(lessonRepositoryProvider);
    final screenTitle =
        launchArgs?.titleOverride ?? language.mockExamTitle(levelLabel);

    return FutureBuilder(
      future: repo.getVocabByLevel(levelLabel),
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

        final allVocab = snapshot.data ?? const [];
        if (allVocab.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(screenTitle)),
            body: Center(child: Text(language.noTermsAvailableLabel)),
          );
        }

        final suffix = launchArgs?.sessionKeySuffix?.trim();
        final sessionKey = (suffix == null || suffix.isEmpty)
            ? 'mock_$levelLabel'
            : 'mock_${suffix}_$levelLabel';
        final initialConfig =
            launchArgs?.initialConfig ??
            TestConfig.mockExam(questionCount: allVocab.length);
        final storage = ref.read(sessionStorageProvider);

        return FutureBuilder(
          future: storage.loadTestSession(sessionKey),
          builder: (context, resumeSnapshot) {
            final resume = resumeSnapshot.data;
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
      },
    );
  }
}
