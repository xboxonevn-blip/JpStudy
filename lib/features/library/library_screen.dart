import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
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
    final lessons = lessonsAsync.valueOrNull ?? const <LessonMeta>[];
    final primaryLessonId = lessons.isNotEmpty
        ? lessons.first.id
        : _firstLessonIdForLevel(selectedLevel);

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
      body: AppPageShell(
        topPadding: AppSpacing.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LibraryHero(
              level: selectedLevel,
              language: language,
              onPrimaryTap: () => context.push('/lesson/$primaryLessonId'),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSectionHeader(
              title: _sectionsTitle(language),
              caption: _sectionsCaption(language),
            ),
            const SizedBox(height: AppSpacing.md),
            _QuickAccessRow(language: language),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: _lessonsTitle(language),
              caption: selectedLevel.shortLabel,
            ),
            const SizedBox(height: AppSpacing.md),
            _LessonSection(language: language, lessonsAsync: lessonsAsync),
          ],
        ),
      ),
    );
  }

  int _firstLessonIdForLevel(StudyLevel level) {
    switch (level) {
      case StudyLevel.n5:
        return 1;
      case StudyLevel.n4:
        return 26;
      case StudyLevel.n3:
        return 51;
    }
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Library';
      case AppLanguage.vi:
        return 'Thư viện';
      case AppLanguage.ja:
        return 'ライブラリ';
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

String _sectionsTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Sections',
  AppLanguage.vi => 'Nhóm học',
  AppLanguage.ja => 'セクション',
};

String _sectionsCaption(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open content by area',
  AppLanguage.vi => 'Mở nội dung theo nhóm',
  AppLanguage.ja => '分野ごとに開く',
};

String _lessonsTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Lessons',
  AppLanguage.vi => 'Bài học',
  AppLanguage.ja => 'レッスン',
};

class _LibraryHero extends ConsumerWidget {
  const _LibraryHero({
    required this.level,
    required this.language,
    required this.onPrimaryTap,
  });

  final StudyLevel level;
  final AppLanguage language;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppFeatureCard(
      icon: Icons.layers_rounded,
      title: _title(language),
      subtitle: level.description(language),
      primaryLabel: _primaryLabel(language),
      onPrimaryTap: onPrimaryTap,
      status: AppStatusChip(
        label: level.shortLabel,
        tone: AppStatusTone.primary,
      ),
    );
  }

  String _title(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Library',
    AppLanguage.vi => 'Thư viện',
    AppLanguage.ja => 'ライブラリ',
  };

  String _primaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Open lessons',
    AppLanguage.vi => 'Mở bài học',
    AppLanguage.ja => 'レッスンを開く',
  };
}

class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= AppBreakpoints.tablet;
        final cards = [
          AppCompactRow(
            icon: Icons.translate_rounded,
            title: _vocabLabel(language),
            subtitle: _vocabHint(language),
            onTap: () => context.push('/vocab'),
          ),
          AppCompactRow(
            icon: Icons.auto_stories_rounded,
            title: _grammarLabel(language),
            subtitle: _grammarHint(language),
            onTap: () => context.push('/grammar'),
          ),
        ];

        if (!useTwoColumns) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: AppSpacing.md),
              cards[1],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }

  String _vocabLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Vocab';
      case AppLanguage.vi:
        return 'Từ vựng';
      case AppLanguage.ja:
        return '語彙';
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
        return '文型と例文';
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= AppBreakpoints.desktop
                ? 2
                : 1;
            final spacing = AppSpacing.md;
            final itemWidth = columns == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - spacing) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final lesson in lessons)
                  SizedBox(
                    width: itemWidth,
                    child: _LessonTile(
                      language: language,
                      lesson: lesson,
                      onTap: () => context.push('/lesson/${lesson.id}'),
                    ),
                  ),
              ],
            );
          },
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
    final due = lesson.dueCount;
    final completed = lesson.completedCount;
    final total = lesson.termCount;

    return AppCompactRow(
      icon: Icons.menu_book_rounded,
      title: lesson.title,
      subtitle: _progressLabel(language, completed, total),
      status: AppStatusChip(
        label: due > 0 ? _dueLabel(language, due) : '$completed/$total',
        tone: due > 0 ? AppStatusTone.warning : AppStatusTone.neutral,
      ),
      onTap: onTap,
    );
  }

  String _dueLabel(AppLanguage language, int count) {
    switch (language) {
      case AppLanguage.en:
        return '$count due';
      case AppLanguage.vi:
        return '$count đến hạn';
      case AppLanguage.ja:
        return '$count 件';
    }
  }

  String _progressLabel(AppLanguage language, int completed, int total) {
    switch (language) {
      case AppLanguage.en:
        return '$completed/$total complete';
      case AppLanguage.vi:
        return '$completed/$total hoàn thành';
      case AppLanguage.ja:
        return '$completed/$total 完了';
    }
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
        AppLanguage.ja => 'このレベルのレッスンはまだありません。',
      }),
    );
  }
}
