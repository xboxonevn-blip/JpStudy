import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../data/models/vocab_item.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../../core/level_provider.dart';
import '../../../core/study_level.dart';
import '../screens/test_config_screen.dart';
import '../screens/test_screen.dart';
import '../../../core/services/session_storage_provider.dart';
import '../../../core/services/session_storage.dart';

/// Integration screen that shows config first, then navigates to test mode
class TestModeIntegration extends ConsumerWidget {
  final int lessonId;
  final String lessonTitle;

  const TestModeIntegration({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final safeTitle = lessonTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    final sessionKey = 'lesson_${lessonId}_$safeTitle';
    final termsAsync = ref.watch(
      lessonTermsProvider(
        LessonTermsArgs(lessonId, level.shortLabel, lessonTitle),
      ),
    );

    return termsAsync.when(
      data: (terms) {
        if (terms.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${language.testModeLabel}: $lessonTitle'),
            ),
            body: Center(child: Text(language.noTermsAvailableLabel)),
          );
        }

        // Convert to VocabItem
        final vocabItems = _convertToVocabItems(terms, level.shortLabel);

        final storage = ref.read(sessionStorageProvider);
        return FutureBuilder<TestSessionSnapshot?>(
          future: storage.loadTestSession(sessionKey),
          builder: (context, snapshot) {
            final resumeSnapshot = snapshot.data;
            return TestConfigScreen(
              lessonId: lessonId,
              lessonTitle: lessonTitle,
              maxQuestions: vocabItems.length,
              resumeSnapshot: resumeSnapshot,
              onResume: resumeSnapshot == null
                  ? null
                  : () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => TestScreen(
                            lessonId: lessonId,
                            lessonTitle: lessonTitle,
                            items: vocabItems,
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
                      lessonId: lessonId,
                      lessonTitle: lessonTitle,
                      items: vocabItems,
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
      loading: () => Scaffold(
        appBar: AppBar(title: Text('${language.testModeLabel}: $lessonTitle')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text('${language.testModeLabel}: $lessonTitle')),
        body: Center(child: Text(language.loadErrorLabel)),
      ),
    );
  }

  List<VocabItem> _convertToVocabItems(
    List<UserLessonTermData> terms,
    String levelLabel,
  ) {
    return terms
        .map(
          (term) => VocabItem(
            id: term.id,
            term: term.term,
            reading: term.reading,
            meaning: term.definition,
            meaningEn: term.definitionEn,
            level: levelLabel,
          ),
        )
        .toList();
  }
}
