import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/app_language.dart'; // Explicit import
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/test/screens/test_config_screen.dart';
import 'package:jpstudy/features/test/screens/test_screen.dart';
import 'package:jpstudy/core/services/session_storage_provider.dart';
import '../models/test_config.dart';

class PracticeTestDashboard extends ConsumerWidget {
  const PracticeTestDashboard({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine the level color theme
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    late final Color color;
    late final String levelLabel;
    switch (level) {
      case StudyLevel.n5:
        color = Colors.pink;
        levelLabel = 'N5';
        break;
      case StudyLevel.n4:
        color = Colors.orange;
        levelLabel = 'N4';
        break;
      case StudyLevel.n3:
        color = Colors.teal;
        levelLabel = 'N3';
        break;
    }

    // Localization
    final language = ref.watch(appLanguageProvider);

    final card = _buildTestCard(
      context,
      ref,
      levelLabel,
      color,
      language,
      embedded: embedded,
    );
    if (embedded) {
      return card;
    }
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: card);
  }

  Widget _buildTestCard(
    BuildContext context,
    WidgetRef ref,
    String level,
    Color color,
    AppLanguage language, {
    required bool embedded,
  }) {
    return Card(
      margin: embedded
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: embedded ? 0 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _startLevelTest(context, ref, level, language),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.85), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(embedded ? 16 : 20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(embedded ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.mockExamTitle(level),
                      style: TextStyle(
                        fontSize: embedded ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language.mockExamSubtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startLevelTest(
    BuildContext context,
    WidgetRef ref,
    String level,
    AppLanguage language,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Fetch data
      final repo = ref.read(lessonRepositoryProvider);
      final allVocab = await repo.getVocabByLevel(level);
      final sessionKey = 'mock_$level';

      if (!context.mounted) return;
      Navigator.pop(context); // Hide loading

      if (allVocab.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(language.noTermsAvailableLabel)));
        return;
      }

      // Navigate to Config Screen
      final storage = ref.read(sessionStorageProvider);
      final resumeSnapshot = await storage.loadTestSession(sessionKey);
      final initialConfig = TestConfig.mockExam(questionCount: allVocab.length);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TestConfigScreen(
            lessonId: -1, // Special ID for Mock Tests
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
                    items:
                        allVocab, // Pass all, TestScreen handles selection/shuffling based on count
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
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.loadErrorLabel)));
    }
  }
}
