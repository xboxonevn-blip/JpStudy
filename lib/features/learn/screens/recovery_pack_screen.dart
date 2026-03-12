import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/screens/learn_screen.dart';

class RecoveryPackScreen extends ConsumerWidget {
  const RecoveryPackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final packAsync = ref.watch(recoveryPackProvider);

    return packAsync.when(
      data: (pack) {
        if (pack == null) {
          return _RecoveryPackEmpty(language: language);
        }

        return FutureBuilder(
          future: ref
              .read(lessonRepositoryProvider)
              .fetchVocabTermsByIds(pack.termIds),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(title: Text(_title(language))),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final items = snapshot.data ?? const [];
            if (items.isEmpty) {
              return _RecoveryPackEmpty(language: language);
            }

            return LearnScreen(
              items: items,
              lessonId: RecoveryPackService.recoveryLessonId,
              lessonTitle: _lessonTitle(language, pack.lessonTitle),
              config: LearnConfig(
                questionCount: items.length.clamp(1, 12),
                enableHints: true,
                showCorrectAnswer: true,
              ).normalized(maxQuestions: items.length),
            );
          },
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(_title(language))),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _RecoveryPackEmpty(language: language),
    );
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Recovery Pack';
      case AppLanguage.vi:
        return 'Gói phục hồi';
      case AppLanguage.ja:
        return 'Recovery Pack';
    }
  }

  String _lessonTitle(AppLanguage language, String sourceTitle) {
    switch (language) {
      case AppLanguage.en:
        return 'Recovery Pack - $sourceTitle';
      case AppLanguage.vi:
        return 'Gói phục hồi - $sourceTitle';
      case AppLanguage.ja:
        return 'Recovery Pack - $sourceTitle';
    }
  }
}

class _RecoveryPackEmpty extends StatelessWidget {
  const _RecoveryPackEmpty({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Color(0xFF64748B),
              ),
              const SizedBox(height: 12),
              Text(
                _emptyTitle(language),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _emptyBody(language),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Recovery Pack';
      case AppLanguage.vi:
        return 'Gói phục hồi';
      case AppLanguage.ja:
        return 'Recovery Pack';
    }
  }

  String _emptyTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'No recovery pack available';
      case AppLanguage.vi:
        return 'Chưa có gói phục hồi';
      case AppLanguage.ja:
        return 'No recovery pack available';
    }
  }

  String _emptyBody(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Finish a mock exam or weak-term session to generate one.';
      case AppLanguage.vi:
        return 'Hãy hoàn thành một bài thi thử hoặc phiên học mục yếu để tạo gói này.';
      case AppLanguage.ja:
        return 'Finish a mock exam or weak-term session to generate one.';
    }
  }
}
