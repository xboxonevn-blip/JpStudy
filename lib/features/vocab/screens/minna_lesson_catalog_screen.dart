import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';

class MinnaLessonCatalogArgs {
  const MinnaLessonCatalogArgs({
    required this.levelCode,
    required this.title,
    required this.lessonStart,
    required this.lessonEnd,
    this.subtitle,
  });

  final String levelCode;
  final String title;
  final int lessonStart;
  final int lessonEnd;
  final String? subtitle;

  @override
  bool operator ==(Object other) {
    return other is MinnaLessonCatalogArgs &&
        other.levelCode == levelCode &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.lessonStart == lessonStart &&
        other.lessonEnd == lessonEnd;
  }

  @override
  int get hashCode =>
      Object.hash(levelCode, title, subtitle, lessonStart, lessonEnd);
}

final minnaLessonCatalogProvider =
    FutureProvider.family<_MinnaLessonCatalogData, MinnaLessonCatalogArgs>((
      ref,
      args,
    ) async {
      final repo = ref.watch(lessonRepositoryProvider);
      await repo.fetchTermsForLessonRange(
        args.levelCode,
        startLesson: args.lessonStart,
        endLesson: args.lessonEnd,
      );
      final meta = await repo.fetchLessonMeta(args.levelCode);
      final lessons =
          meta
              .where(
                (lesson) =>
                    lesson.id >= args.lessonStart &&
                    lesson.id <= args.lessonEnd,
              )
              .toList()
            ..sort((left, right) => left.id.compareTo(right.id));

      final totalTerms = lessons.fold<int>(
        0,
        (sum, lesson) => sum + lesson.termCount,
      );
      final completedTerms = lessons.fold<int>(
        0,
        (sum, lesson) => sum + lesson.completedCount,
      );
      final completedLessons = lessons
          .where(
            (lesson) =>
                lesson.termCount > 0 &&
                lesson.completedCount >= lesson.termCount,
          )
          .length;
      final startedLessons = lessons
          .where((lesson) => lesson.completedCount > 0 || lesson.dueCount > 0)
          .length;

      return _MinnaLessonCatalogData(
        lessons: lessons,
        totalTerms: totalTerms,
        completedTerms: completedTerms,
        completedLessons: completedLessons,
        startedLessons: startedLessons,
      );
    });

class MinnaLessonCatalogScreen extends ConsumerWidget {
  const MinnaLessonCatalogScreen({
    super.key,
    required this.levelCode,
    required this.title,
    required this.lessonStart,
    required this.lessonEnd,
    this.subtitle,
  });

  final String levelCode;
  final String title;
  final int lessonStart;
  final int lessonEnd;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final args = MinnaLessonCatalogArgs(
      levelCode: levelCode,
      title: title,
      subtitle: subtitle,
      lessonStart: lessonStart,
      lessonEnd: lessonEnd,
    );
    final catalogAsync = ref.watch(minnaLessonCatalogProvider(args));

    return Scaffold(
      body: AppPageShell(
        topPadding: AppSpacing.md,
        child: catalogAsync.when(
          data: (catalog) => _MinnaCatalogBody(
            args: args,
            catalog: catalog,
            language: language,
          ),
          loading: () => const _MinnaLoadingState(),
          error: (error, stack) => _MinnaErrorState(
            language: language,
            onRetry: () => ref.invalidate(minnaLessonCatalogProvider(args)),
          ),
        ),
      ),
    );
  }
}

class _MinnaCatalogBody extends StatelessWidget {
  const _MinnaCatalogBody({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final _MinnaLessonCatalogData catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BackRow(language: language),
        const SizedBox(height: AppSpacing.md),
        _CatalogHero(args: args, catalog: catalog, language: language),
        const SizedBox(height: AppSpacing.xl),
        AppSectionHeader(
          title: _lessonGridTitle(language),
          caption: _lessonGridCaption(
            language,
            args.lessonStart,
            args.lessonEnd,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LessonGrid(args: args, catalog: catalog, language: language),
        const SizedBox(height: AppSpacing.xl),
        _ReviewCta(args: args, language: language),
      ],
    );
  }
}

class _BackRow extends StatelessWidget {
  const _BackRow({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
            return;
          }
          context.go('/vocab');
        },
        icon: const Icon(Icons.arrow_back_rounded),
        label: Text(_backLabel(language)),
        style: TextButton.styleFrom(
          foregroundColor: palette.ink,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _CatalogHero extends StatelessWidget {
  const _CatalogHero({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final _MinnaLessonCatalogData catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 940;
    return AppSectionCard(
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _HeroCopy(
                    args: args,
                    catalog: catalog,
                    language: language,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  flex: 4,
                  child: _HeroProgressCard(
                    args: args,
                    catalog: catalog,
                    language: language,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCopy(args: args, catalog: catalog, language: language),
                const SizedBox(height: AppSpacing.lg),
                _HeroProgressCard(
                  args: args,
                  catalog: catalog,
                  language: language,
                ),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final _MinnaLessonCatalogData catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            AppStatusChip(label: args.levelCode, tone: AppStatusTone.warning),
            AppStatusChip(
              label: _bookBadge(args.lessonStart, language),
              tone: AppStatusTone.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _catalogTitle(language, args.levelCode),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: palette.ink,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          args.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          args.subtitle?.trim().isNotEmpty == true
              ? args.subtitle!
              : _heroSubtitle(language, args.lessonStart, args.lessonEnd),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.ink.withValues(alpha: 0.72),
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatPill(
              icon: Icons.menu_book_rounded,
              label: _statLessons(language, catalog.lessons.length),
            ),
            _StatPill(
              icon: Icons.translate_rounded,
              label: _statTerms(language, catalog.totalTerms),
            ),
            _StatPill(
              icon: Icons.play_circle_fill_rounded,
              label: _statStarted(language, catalog.startedLessons),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final _MinnaLessonCatalogData catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final progress = catalog.totalTerms == 0
        ? 0.0
        : catalog.completedTerms / catalog.totalTerms;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _progressTitle(language),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _progressSummary(
              language,
              catalog.completedLessons,
              catalog.lessons.length,
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.ink.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _progressTrailing(language),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.ink.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppProgressStrip(
            value: progress,
            label: _progressWords(
              language,
              catalog.completedTerms,
              catalog.totalTerms,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonGrid extends StatelessWidget {
  const _LessonGrid({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final _MinnaLessonCatalogData catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    if (catalog.lessons.isEmpty) {
      return AppSectionCard(
        child: Text(
          _emptyState(language),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 760 ? 2 : 1;
    final ratio = width >= 1180
        ? 2.25
        : width >= 760
        ? 1.85
        : 1.65;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: catalog.lessons.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: ratio,
      ),
      itemBuilder: (context, index) {
        final lesson = catalog.lessons[index];
        return _LessonCard(args: args, lesson: lesson, language: language);
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.args,
    required this.lesson,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final LessonMeta lesson;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final progress = lesson.termCount == 0
        ? 0.0
        : lesson.completedCount / lesson.termCount;
    final isDone =
        lesson.termCount > 0 && lesson.completedCount >= lesson.termCount;
    final isStarted = lesson.completedCount > 0 || lesson.dueCount > 0;
    final theme = _lessonTheme(language, lesson.id);

    return InkWell(
      key: ValueKey('minna_lesson_${lesson.id}'),
      onTap: () => context.push('/lesson/${lesson.id}'),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.elevated, palette.base],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDone
                ? palette.success.withValues(alpha: 0.26)
                : isStarted
                ? palette.primary.withValues(alpha: 0.18)
                : palette.outline.withValues(alpha: 0.92),
          ),
          boxShadow: [
            BoxShadow(
              color: palette.ink.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _lessonBadge(language, lesson.id),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                AppStatusChip(
                  label: isDone
                      ? _lessonStatusDone(language)
                      : isStarted
                      ? _lessonStatusInProgress(language)
                      : _lessonStatusReady(language),
                  tone: isDone
                      ? AppStatusTone.success
                      : isStarted
                      ? AppStatusTone.primary
                      : AppStatusTone.neutral,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              theme,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.ink,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
            const Spacer(),
            Text(
              _lessonFootnote(language, lesson.termCount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.ink.withValues(alpha: 0.68),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppProgressStrip(
              value: progress,
              label: _lessonProgress(
                language,
                lesson.completedCount,
                lesson.termCount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCta extends StatelessWidget {
  const _ReviewCta({required this.args, required this.language});

  final MinnaLessonCatalogArgs args;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _reviewTitle(language),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _reviewBody(language, args.lessonStart, args.lessonEnd),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.ink.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          FilledButton.icon(
            key: const ValueKey('minna_review_cta'),
            onPressed: () {
              final uri = Uri(
                path: '/vocab/review',
                queryParameters: {
                  'title': args.title,
                  'subtitle':
                      args.subtitle ??
                      _heroSubtitle(language, args.lessonStart, args.lessonEnd),
                  'lessonStart': '${args.lessonStart}',
                  'lessonEnd': '${args.lessonEnd}',
                },
              );
              context.push(uri.toString());
            },
            icon: const Icon(Icons.auto_stories_rounded),
            label: Text(_reviewButton(language)),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.outlineSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: palette.outline.withValues(alpha: 0.92)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: palette.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MinnaLoadingState extends StatelessWidget {
  const _MinnaLoadingState();

  @override
  Widget build(BuildContext context) {
    return const AppSectionCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _MinnaErrorState extends StatelessWidget {
  const _MinnaErrorState({required this.language, required this.onRetry});

  final AppLanguage language;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _errorTitle(language),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _errorBody(language),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: Text(_retryLabel(language))),
        ],
      ),
    );
  }
}

class _MinnaLessonCatalogData {
  const _MinnaLessonCatalogData({
    required this.lessons,
    required this.totalTerms,
    required this.completedTerms,
    required this.completedLessons,
    required this.startedLessons,
  });

  final List<LessonMeta> lessons;
  final int totalTerms;
  final int completedTerms;
  final int completedLessons;
  final int startedLessons;
}

String _catalogTitle(AppLanguage language, String levelCode) =>
    switch (language) {
      AppLanguage.en => 'Minna $levelCode',
      AppLanguage.vi => 'Minna $levelCode',
      AppLanguage.ja => '??? $levelCode',
    };

String _heroSubtitle(
  AppLanguage language,
  int start,
  int end,
) => switch (language) {
  AppLanguage.en =>
    'Lesson catalog for Minna no Nihongo ${start == 1 ? 'I' : 'II'} ? lessons $start?$end.',
  AppLanguage.vi =>
    'Danh m?c b?i h?c b?m theo Minna no Nihongo ${start == 1 ? 'I' : 'II'} ? b?i $start?$end.',
  AppLanguage.ja =>
    '??????? ${start == 1 ? 'I' : 'II'} ?????$start???$end???????',
};

String _bookBadge(int lessonStart, AppLanguage language) => switch (language) {
  AppLanguage.en => lessonStart == 1 ? 'Book I' : 'Book II',
  AppLanguage.vi => lessonStart == 1 ? 'Quy?n I' : 'Quy?n II',
  AppLanguage.ja => lessonStart == 1 ? '?? I' : '?? II',
};

String _backLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Back to vocab',
  AppLanguage.vi => 'V? t? v?ng',
  AppLanguage.ja => '?????',
};

String _statLessons(AppLanguage language, int count) => switch (language) {
  AppLanguage.en => '$count lessons',
  AppLanguage.vi => '$count b?i h?c',
  AppLanguage.ja => '$count ????',
};

String _statTerms(AppLanguage language, int count) => switch (language) {
  AppLanguage.en => '$count terms',
  AppLanguage.vi => '$count t?',
  AppLanguage.ja => '$count ?',
};

String _statStarted(AppLanguage language, int count) => switch (language) {
  AppLanguage.en => '$count started',
  AppLanguage.vi => '$count ?? b?t ??u',
  AppLanguage.ja => '$count ????',
};

String _progressTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Progress',
  AppLanguage.vi => 'Ti?n ??',
  AppLanguage.ja => '??',
};

String _progressSummary(AppLanguage language, int done, int total) =>
    switch (language) {
      AppLanguage.en => '$done/$total lessons completed',
      AppLanguage.vi => 'Ho?n th?nh $done/$total b?i',
      AppLanguage.ja => '$done/$total ??????',
    };

String _progressTrailing(AppLanguage language) => switch (language) {
  AppLanguage.en => 'complete',
  AppLanguage.vi => 'ho?n th?nh',
  AppLanguage.ja => '??',
};

String _progressWords(AppLanguage language, int done, int total) =>
    switch (language) {
      AppLanguage.en => 'Words progress: $done/$total',
      AppLanguage.vi => 'Ti?n ?? t? v?ng: $done/$total',
      AppLanguage.ja => '????: $done/$total',
    };

String _lessonGridTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Lessons',
  AppLanguage.vi => 'C?c b?i h?c',
  AppLanguage.ja => '????',
};

String _lessonGridCaption(AppLanguage language, int start, int end) =>
    switch (language) {
      AppLanguage.en => 'Browse each lesson exactly in textbook order.',
      AppLanguage.vi =>
        'M? t?ng b?i theo ??ng th? t? gi?o tr?nh t? b?i $start ??n $end.',
      AppLanguage.ja => '????????????????????',
    };

String _lessonBadge(AppLanguage language, int id) => switch (language) {
  AppLanguage.en => 'Lesson $id',
  AppLanguage.vi => 'B?i $id',
  AppLanguage.ja => '?$id?',
};

String _lessonFootnote(AppLanguage language, int termCount) =>
    switch (language) {
      AppLanguage.en => '$termCount words in this lesson',
      AppLanguage.vi => '$termCount t? trong b?i n?y',
      AppLanguage.ja => '?????? $termCount ?',
    };

String _lessonProgress(AppLanguage language, int done, int total) =>
    switch (language) {
      AppLanguage.en => 'Progress $done/$total',
      AppLanguage.vi => 'Ti?n ?? $done/$total',
      AppLanguage.ja => '?? $done/$total',
    };

String _lessonStatusDone(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Done',
  AppLanguage.vi => 'Xong',
  AppLanguage.ja => '??',
};

String _lessonStatusInProgress(AppLanguage language) => switch (language) {
  AppLanguage.en => 'In progress',
  AppLanguage.vi => '?ang h?c',
  AppLanguage.ja => '???',
};

String _lessonStatusReady(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Ready',
  AppLanguage.vi => 'S?n s?ng',
  AppLanguage.ja => '????',
};

String _reviewTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Review the whole book range',
  AppLanguage.vi => '?n c? ch?ng gi?o tr?nh',
  AppLanguage.ja => '???????????',
};

String _reviewBody(AppLanguage language, int start, int end) =>
    switch (language) {
      AppLanguage.en =>
        'Start one consolidated review session for lessons $start?$end.',
      AppLanguage.vi => 'M? m?t phi?n ?n t?ng h?p cho to?n b? b?i $start?$end.',
      AppLanguage.ja => '$start??$end????????????????????',
    };

String _reviewButton(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Review',
  AppLanguage.vi => 'Review',
  AppLanguage.ja => '??',
};

String _emptyState(AppLanguage language) => switch (language) {
  AppLanguage.en => 'No lessons are available for this catalog yet.',
  AppLanguage.vi => 'Ch?a c? b?i h?c n?o cho catalog n?y.',
  AppLanguage.ja => '?????????????????????????',
};

String _errorTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Could not load lessons',
  AppLanguage.vi => 'Kh?ng t?i ???c b?i h?c',
  AppLanguage.ja => '???????????????',
};

String _errorBody(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Please try again. The catalog will appear once the lesson data is ready.',
  AppLanguage.vi =>
    'H?y th? l?i. Danh m?c s? hi?n khi d? li?u b?i h?c ?? s?n s?ng.',
  AppLanguage.ja => '???????????????????????????????????',
};

String _retryLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Retry',
  AppLanguage.vi => 'Th? l?i',
  AppLanguage.ja => '???',
};

String _lessonTheme(AppLanguage language, int lessonId) {
  final themes = _lessonThemes[lessonId];
  if (themes == null) {
    return switch (language) {
      AppLanguage.en => 'Core expressions and vocabulary flow',
      AppLanguage.vi => 'M?ch t? v?ng v? m?u c?u c?t l?i',
      AppLanguage.ja => '??????????',
    };
  }
  return switch (language) {
    AppLanguage.en => themes.en,
    AppLanguage.vi => themes.vi,
    AppLanguage.ja => themes.ja,
  };
}

const _lessonThemes = <int, _LessonTheme>{
  1: _LessonTheme(
    'Greetings and self-introduction',
    'Ch?o h?i v? t? gi?i thi?u',
    '?????????',
  ),
  2: _LessonTheme(
    'This, that, and everyday objects',
    'C?i n?y, c?i kia v? ?? v?t quen thu?c',
    '?????????????',
  ),
  3: _LessonTheme(
    'Places, floors, and locations',
    '??a ?i?m, t?ng v? n?i ch?n',
    '???????',
  ),
  4: _LessonTheme(
    'Time, schedule, and daily rhythm',
    'Th?i gian, l?ch v? nh?p sinh ho?t',
    '???????????',
  ),
  5: _LessonTheme(
    'Going, coming, and returning',
    '?i, ??n v? tr? v?',
    '????????',
  ),
  6: _LessonTheme(
    'Daily actions and routines',
    'Ho?t ??ng h?ng ng?y',
    '??????????',
  ),
  7: _LessonTheme(
    'Giving, receiving, and gifts',
    'Cho, nh?n v? qu? t?ng',
    '???????????',
  ),
  8: _LessonTheme('Adjectives and description', 'T?nh t? v? m? t?', '??????'),
  9: _LessonTheme(
    'Likes, skills, and understanding',
    'S? th?ch, k? n?ng v? m?c ?? hi?u',
    '????????',
  ),
  10: _LessonTheme(
    'Existence of people and things',
    'S? t?n t?i c?a ng??i v? v?t',
    '??????',
  ),
  11: _LessonTheme(
    'Numbers, counters, and quantity',
    'S? ??m, l??ng v? ??n v?',
    '???????',
  ),
  12: _LessonTheme(
    'Past actions and experiences',
    'H?nh ??ng qu? kh? v? tr?i nghi?m',
    '????????',
  ),
  13: _LessonTheme(
    'Wants, plans, and preferences',
    'Mong mu?n, k? ho?ch v? s? th?ch',
    '????????',
  ),
  14: _LessonTheme(
    'Te-form requests and permission',
    'Th? ?, nh? v? v? xin ph?p',
    '????????',
  ),
  15: _LessonTheme(
    'Permission, prohibition, and ongoing states',
    'Cho ph?p, c?m ?o?n v? tr?ng th?i',
    '????????',
  ),
  16: _LessonTheme(
    'Connecting actions with te-form',
    'N?i h?nh ??ng b?ng th? ?',
    '?????????',
  ),
  17: _LessonTheme(
    'Negative form and obligations',
    'Th? ph? ??nh v? ngh?a v?',
    '??????',
  ),
  18: _LessonTheme(
    'Dictionary form and ability',
    'T? ?i?n th? v? kh? n?ng',
    '??????',
  ),
  19: _LessonTheme(
    'Casual speech and everyday talk',
    'C?ch n?i th?n m?t h?ng ng?y',
    '????????',
  ),
  20: _LessonTheme(
    'Plain style conversations',
    'H?i tho?i b?ng th? th?ng th??ng',
    '??????',
  ),
  21: _LessonTheme(
    'Thoughts, plans, and intentions',
    'Suy ngh?, d? ??nh v? ? ??nh',
    '????????',
  ),
  22: _LessonTheme(
    'Modifying nouns and explanations',
    'B? ngh?a danh t? v? gi?i th?ch',
    '???????',
  ),
  23: _LessonTheme(
    'Timing, before, and after',
    'Th?i ?i?m, tr??c v? sau',
    '???????',
  ),
  24: _LessonTheme(
    'Giving and receiving in context',
    'Cho nh?n trong ng? c?nh',
    '???????',
  ),
  25: _LessonTheme(
    'Hypothesis and advice',
    'Gi? ??nh v? l?i khuy?n',
    '????????',
  ),
  26: _LessonTheme(
    'Plans and schedules with context',
    'K? ho?ch v? l?ch tr?nh theo ng? c?nh',
    '??????????',
  ),
  27: _LessonTheme(
    'Potential actions and ability',
    'Kh? n?ng v? vi?c c? th? l?m',
    '???????',
  ),
  28: _LessonTheme(
    'While doing and combined actions',
    'V?a l?m v?a k?t h?p h?nh ??ng',
    '????????',
  ),
  29: _LessonTheme(
    'Transitivity and result states',
    'Tha ??ng t?, t? ??ng t? v? tr?ng th?i',
    '?????????',
  ),
  30: _LessonTheme(
    'Making things happen',
    'L?m cho ?i?u g? x?y ra',
    '?????????',
  ),
  31: _LessonTheme(
    'Intentional action and purpose',
    'H?nh ??ng c? ch? ??ch v? m?c ??ch',
    '?????',
  ),
  32: _LessonTheme(
    'Advice and recommendation',
    'Khuy?n nh? v? ?? xu?t',
    '???????',
  ),
  33: _LessonTheme('Conditional situations', 'T?nh hu?ng ?i?u ki?n', '?????'),
  34: _LessonTheme('If and when patterns', 'M?u n?u v? khi', '?????????'),
  35: _LessonTheme(
    'Assumptions and expectations',
    'Gi? ??nh v? k? v?ng',
    '??????',
  ),
  36: _LessonTheme(
    'Trying, attempting, and experience',
    'Th? l?m v? kinh nghi?m',
    '?????',
  ),
  37: _LessonTheme('Passive voice basics', 'C?u b? ??ng c? b?n', '??????'),
  38: _LessonTheme(
    'Giving direct instructions',
    'Ra ch? d?n tr?c ti?p',
    '?????',
  ),
  39: _LessonTheme('Cause and consequence', 'Nguy?n nh?n v? k?t qu?', '?????'),
  40: _LessonTheme(
    'Honorific communication',
    'K?nh ng? trong giao ti?p',
    '????',
  ),
  41: _LessonTheme(
    'Humble communication',
    'Khi?m nh??ng ng? trong giao ti?p',
    '????',
  ),
  42: _LessonTheme(
    'Polite business requests',
    'Y?u c?u l?ch s? trong c?ng vi?c',
    '?????',
  ),
  43: _LessonTheme(
    'Looks, appearance, and tendency',
    'V? ngo?i, c?m gi?c v? xu h??ng',
    '?????????',
  ),
  44: _LessonTheme(
    'Too much and degree expressions',
    'M?c ?? v? ? ngh?a qu? m?c',
    '???????',
  ),
  45: _LessonTheme(
    'Possibility and hearsay',
    'Kh? n?ng v? th?ng tin nghe ???c',
    '??????',
  ),
  46: _LessonTheme(
    'Giving reasons and background',
    'N?u l? do v? b?i c?nh',
    '???????',
  ),
  47: _LessonTheme('Concessions and contrast', 'Nh??ng b? v? ??i l?p', '?????'),
  48: _LessonTheme(
    'Final-stage polite nuance',
    'S?c th?i l?ch s? n?ng cao',
    '????????????',
  ),
  49: _LessonTheme(
    'Respectful workplace Japanese',
    'Ti?ng Nh?t c?ng s? t?n k?nh',
    '?????',
  ),
  50: _LessonTheme(
    'Wrap-up and integrated usage',
    'T?ng h?p v? v?n d?ng to?n ch?ng',
    '?????????',
  ),
};

class _LessonTheme {
  const _LessonTheme(this.en, this.vi, this.ja);

  final String en;
  final String vi;
  final String ja;
}
