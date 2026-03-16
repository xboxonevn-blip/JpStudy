import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final selectedLevel = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final lessonsAsync = ref.watch(
      lessonMetaProvider(selectedLevel.shortLabel),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(language)),
        actions: [
          IconButton(
            tooltip: _searchLabel(language),
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              HomeSurface.pageHorizontalPadding,
              16,
              HomeSurface.pageHorizontalPadding,
              96,
            ),
            children: [
              _LibraryHero(level: selectedLevel, language: language),
              const SizedBox(height: 16),
              _QuickAccessRow(language: language),
              const SizedBox(height: 16),
              _LessonSection(language: language, lessonsAsync: lessonsAsync),
            ],
          ),
        ),
      ),
    );
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Study';
      case AppLanguage.vi:
        return 'Học';
      case AppLanguage.ja:
        return '学習';
    }
  }

  String _searchLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Search';
      case AppLanguage.vi:
        return 'Tìm kiếm';
      case AppLanguage.ja:
        return '検索';
    }
  }
}

class _LibraryHero extends ConsumerWidget {
  const _LibraryHero({required this.level, required this.language});

  final StudyLevel level;
  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: HomeSurface.softPanel(
        colors: const [Color(0xFFF8FCFF), Color(0xFFECFEFF)],
        radius: 28,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${level.shortLabel} ${_focusLabel(language)}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            level.description(language),
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final candidate in StudyLevel.values)
                ChoiceChip(
                  label: Text(candidate.shortLabel),
                  selected: candidate == level,
                  onSelected: (_) {
                    ref.read(studyLevelProvider.notifier).state = candidate;
                    if (candidate != StudyLevel.n3 &&
                        ref.read(appLanguageProvider) == AppLanguage.ja) {
                      ref.read(appLanguageProvider.notifier).state =
                          AppLanguage.en;
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _focusLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Study';
      case AppLanguage.vi:
        return 'Học';
      case AppLanguage.ja:
        return '学習';
    }
  }
}

class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickCard(
            icon: Icons.translate_rounded,
            title: _vocabLabel(language),
            subtitle: _vocabHint(language),
            onTap: () => context.push('/vocab'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickCard(
            icon: Icons.auto_stories_rounded,
            title: _grammarLabel(language),
            subtitle: _grammarHint(language),
            onTap: () => context.push('/grammar'),
          ),
        ),
      ],
    );
  }

  String _vocabLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Vocab';
      case AppLanguage.vi:
        return 'Từ vựng';
      case AppLanguage.ja:
        return '単語';
    }
  }

  String _vocabHint(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Terms by level';
      case AppLanguage.vi:
        return 'Từ theo cấp độ';
      case AppLanguage.ja:
        return 'レベル別の単語';
    }
  }

  String _grammarLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Grammar';
      case AppLanguage.vi:
        return 'Ngữ pháp';
      case AppLanguage.ja:
        return '文法';
    }
  }

  String _grammarHint(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Points and examples';
      case AppLanguage.vi:
        return 'Mẫu và ví dụ';
      case AppLanguage.ja:
        return 'パターンと例文';
    }
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({required this.language, required this.lessonsAsync});

  final AppLanguage language;
  final AsyncValue<List<LessonMeta>> lessonsAsync;

  @override
  Widget build(BuildContext context) {
    return lessonsAsync.when(
      data: (lessons) {
        if (lessons.isEmpty) {
          return _EmptyLibrary(language: language);
        }
        return Column(
          children: [
            for (final lesson in lessons)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LessonTile(
                  language: language,
                  lesson: lesson,
                  onTap: () => context.push('/lesson/${lesson.id}'),
                ),
              ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text(language.loadErrorLabel),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: HomeSurface.softPanel(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF0F766E)),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.language,
    required this.lesson,
    required this.onTap,
  });

  final AppLanguage language;
  final LessonMeta lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = lesson.termCount == 0
        ? 0.0
        : lesson.completedCount / lesson.termCount;


    String dueLabel(AppLanguage language, int count) {
      switch (language) {
        case AppLanguage.en:
          return '$count due';
        case AppLanguage.vi:
          return '$count đến hạn';
        case AppLanguage.ja:
          return '$count 件';
      }
    }

    String progressLabel(AppLanguage language, int completed, int total) {
      switch (language) {
        case AppLanguage.en:
          return '$completed/$total complete';
        case AppLanguage.vi:
          return '$completed/$total hoàn thành';
        case AppLanguage.ja:
          return '$completed/$total 完了';
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: HomeSurface.softPanel(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (lesson.dueCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        dueLabel(language, lesson.dueCount),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                progressLabel(language, lesson.completedCount, lesson.termCount),
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF0EA5E9)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HomeSurface.softPanel(),
      padding: const EdgeInsets.all(24),
      child: Text(switch (language) {
        AppLanguage.en => 'No lessons for this level yet.',
        AppLanguage.vi => 'Chưa có bài học cho cấp độ này.',
        AppLanguage.ja => 'このレベルにはまだレッスンがありません。',
      }),
    );
  }
}


